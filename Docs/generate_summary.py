import os

LUADOCS_OUTPUT_SUBDIR = 'API'
MDBOOK_SOURCE_DIR = 'src'
SUMMARY_FILE_PATH = os.path.join(MDBOOK_SOURCE_DIR, 'SUMMARY.md')

def generate_mdbook_summary():
    current_mdbook_src_dir = os.path.join(os.getcwd(), MDBOOK_SOURCE_DIR)
    luals_output_path = os.path.join(current_mdbook_src_dir, LUADOCS_OUTPUT_SUBDIR)

    print(f"Scanning Markdown files in: {os.path.abspath(luals_output_path)}")
    print(f"Adding API to SUMMARY.md at: {os.path.abspath(os.path.join(os.getcwd(), SUMMARY_FILE_PATH))}")

    markdown_files = []

    for root, _, files in os.walk(luals_output_path):
        for file in files:
            if file.endswith('.md') and file != 'SUMMARY.md':
                relative_path = os.path.relpath(os.path.join(root, file), current_mdbook_src_dir)
                markdown_files.append(relative_path)

    markdown_files.sort()

    with open(SUMMARY_FILE_PATH, 'w+') as f:
        if markdown_files:
            f.write("\n# API Reference\n\n")
            for md_file in markdown_files:
                # Create a readable title from the filename
                title = os.path.splitext(os.path.basename(md_file))[0]
                title = title.replace('_', ' ').replace('-', ' ').title()

                # Indent for nested directory if necessary (e.g., api/my_module.md)
                indent_level = md_file.count(os.sep) - LUADOCS_OUTPUT_SUBDIR.count(os.sep)
                indent_str = "  " * indent_level

                content = f"{indent_str}- [{title}]({md_file})\n"
                f.write(content)
                print(f"Wrote: {content}")
        else:
            f.write("\nNo API documentation generated.\n")

    print(f"Added to SUMMARY.md with {len(markdown_files)} API entries")

if __name__ == '__main__':
    generate_mdbook_summary()