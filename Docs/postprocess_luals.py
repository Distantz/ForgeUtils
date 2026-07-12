import argparse
import shutil
from pathlib import Path
 
def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("input_dir", type=Path, help="Folder to process")
    args = parser.parse_args()
 
    root_dir = args.input_dir.resolve()
    prefix = root_dir.name + "."
 
    for src in list(root_dir.glob("*")):
        if not src.is_file() or not src.name.startswith(prefix):
            continue
 
        parts = src.name[len(prefix):].split(".")
        *folders, name, ext = parts
        target = root_dir.joinpath(*folders, f"{name}.{ext}")
 
        target.parent.mkdir(parents=True, exist_ok=True)
        shutil.move(str(src), str(target))
 
 
if __name__ == "__main__":
    main()
