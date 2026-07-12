import argparse
import re
import sys
from pathlib import Path

API_MD_FILE = "api.md"
README_MD_FILE = "readme.md"

INDENT = "  "
RESERVED_NAMES = {"summary.md", README_MD_FILE}
API_FOLDER_NAME = "API"

TEMPLATE = """
# [Documentation]({0})
{1}

# [API Reference]({2})
{3}
"""

def find_linked_md(folder: Path) -> Path | None:
    sibling = folder.parent / f"{folder.name}.md"
    if sibling.is_file():
        return sibling
    # respect readme as a shorthand for folder.
    readme = folder / "README.md"
    if readme.is_file():
        return readme
    return None

def capitalize_name(name: str) -> str:
    words = re.split(r"[_-]+", name)
    capped = [w[:1].upper() + w[1:] if w else w for w in words]
    return " ".join(capped).strip()

def get_title(md_file: Path, fallback_name: str) -> str:
    first_line = ""
    try:
        with md_file.open("r", encoding="utf-8") as f:
            first_line = f.readline().strip()
    except OSError:
        pass

    title = first_line.lstrip("#").strip()
    if title:
        return title
    
    return capitalize_name(fallback_name)

def build_toc(
    folder: Path,
    base: Path,
    depth: int = 0,
    exclude_dirs: set[Path] = frozenset(),
    exclude_files: set[str] = frozenset(),
) -> list[str]:
    lines: list[str] = []
    entries = list(folder.iterdir())
    subfolders = [p for p in entries if p.is_dir() and p not in exclude_dirs]

    consumed = {
        md_file
        for sub in subfolders
        if (md_file := find_linked_md(sub)) is not None and md_file.parent == folder
    }

    loose_files = [
        p
        for p in entries
        if p.is_file()
        and p.suffix.lower() == ".md"
        and p.name.lower() not in RESERVED_NAMES
        and p.name.lower() not in exclude_files
        and p not in consumed
    ]

    combined = sorted(subfolders, key=lambda p: p.name.lower()) + sorted(loose_files, key=lambda p: p.name.lower())
    prefix = INDENT * depth

    for item in combined:
        if item.is_dir():
            md_file = find_linked_md(item)
            if md_file is not None:
                title = get_title(md_file, fallback_name=item.name)
                rel_path = md_file.relative_to(base).as_posix()
                lines.append(f"{prefix}- [{title}]({rel_path})")
            else:
                lines.append(f"{prefix}- {capitalize_name(item.name)}")
            lines.extend(build_toc(item, base, depth + 1, exclude_dirs, exclude_files))
        else:
            title = get_title(item, fallback_name=item.stem)
            rel_path = item.relative_to(base).as_posix()
            lines.append(f"{prefix}- [{title}]({rel_path})")

    return lines

def generate_summary(input_folder: Path, output_file: Path) -> None:
    if not input_folder.is_dir():
        sys.exit(f"Error: '{input_folder}' is not a directory")

    api_folder = input_folder / API_FOLDER_NAME
    has_api = api_folder.is_dir()

    toc_lines = build_toc(
        input_folder,
        input_folder,
        exclude_dirs={api_folder} if has_api else frozenset(),
        exclude_files={API_MD_FILE},
    )
    toc_text = "\n".join(toc_lines)

    api_toc_lines = build_toc(api_folder, input_folder) if has_api else []
    api_toc_text = "\n".join(api_toc_lines)

    content = TEMPLATE.format(
        README_MD_FILE,
        toc_text,
        API_MD_FILE,
        api_toc_text,
    )

    output_file.parent.mkdir(parents=True, exist_ok=True)
    output_file.write_text(content, encoding="utf-8")

    total_entries = len(toc_lines) + len(api_toc_lines)
    print(f"Wrote {output_file} ({total_entries} entries).")

def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("input_folder", type=Path, help="Folder to scan")
    parser.add_argument("output_file", type=Path, help="Path to write SUMMARY.md to")
    args = parser.parse_args()
    generate_summary(args.input_folder, args.output_file)

if __name__ == "__main__":
    main()