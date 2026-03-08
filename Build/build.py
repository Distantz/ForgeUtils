#!/usr/bin/env python3
"""
OVL Path Processor - Process .ovlpaths file and run ovl_tool_cmd.py for each entry
"""

import os
import sys
import subprocess
import argparse
import ui_package as pkg
from pathlib import Path

def process_uipackages(manifest_dir : Path, ovl_path_line):
    """
    Check for .uipackage file in the OVL directory and process UI packages.
    
    Args:
        manifest_dir: Path to the directory containing Manifest.xml
        ovl_path_line: The path line from .ovlpaths (e.g., "./Main/Test")
    
    Returns:
        List of tuples containing (basis_path, uipackage_folder_path)
    """
    ui_packages = []

    # Mod dir
    ovldata_folder : Path = manifest_dir.parent
    
    # Construct the OVL directory path
    ovl_dir : Path = manifest_dir / ovl_path_line.lstrip('./')
    
    # Check for .uipackage file
    uipackages_list_file = ovl_dir / ".uipackages"
    
    if not uipackages_list_file.exists():
        return ui_packages
    
    print(f"  Found .uipackages file")
    
    # Read the .uipackages file
    with open(uipackages_list_file, 'r') as f:
        lines = f.readlines()
    
    print(f"  Building UI packages...")
    for line in lines:
        line = line.strip()
        
        # Skip empty lines and comments
        if not line or line.startswith('#'):
            continue
        
        # Construct the UI package folder path
        uipackage_folder = ovl_dir / line.lstrip('./')
        print(f"     Building UI package: {line}")
        
        
        if not uipackage_folder.exists():
            print(f"     UI Package: {uipackage_folder} does not exist. Skipping...")
            continue

        uipackage_output = ovl_dir / f"{uipackage_folder.name}.ppuipkg"
        basic_path = Path.relative_to(ovl_dir, ovldata_folder)
        
        with pkg.PPUIPkgFile(str(basic_path).replace("\\", "/"), str(uipackage_output)) as pkgfile:
            pkgfile.importall(str(uipackage_folder))
            pass
    
    print(f"  Finished building UI packages...")


def process_ovlpaths(cobra_tools_path, manifest_path):
    """
    Process the .ovlpaths file relative to the Manifest.xml location
    and run ovl_tool_cmd.py for each path entry.
    
    Args:
        cobra_tools_path: Path to cobra tools
        manifest_path: Path to the Manifest.xml file
    """
    manifest_dir = Path(manifest_path).parent.resolve()
    
    if not cobra_tools_path:
        print("Error: COBRA_TOOLS_PATH environment variable is not set", file=sys.stderr)
        return False
    
    cobra_tools_path = Path(cobra_tools_path)
    ovl_tool_cmd = cobra_tools_path / "ovl_tool_cmd.py"
    
    if not ovl_tool_cmd.exists():
        print(f"Error: ovl_tool_cmd.py not found at {ovl_tool_cmd}", file=sys.stderr)
        return False
    
    # Find the .ovlpaths file
    ovlpaths_file = manifest_dir / ".ovlpaths"
    
    if not ovlpaths_file.exists():
        print(f"Error: .ovlpaths file not found at {ovlpaths_file}", file=sys.stderr)
        return False
    
    print(f"Processing .ovlpaths from: {ovlpaths_file}")
    print(f"Manifest directory: {manifest_dir}")
    print(f"Cobra tools path: {cobra_tools_path}")
    print("-" * 60)
    
    # Read the .ovlpaths file
    with open(ovlpaths_file, 'r') as f:
        lines = f.readlines()
    
    success_count = 0
    fail_count = 0
    
    # Process each line
    for line_num, line in enumerate(lines, 1):
        line = line.strip()
        
        # Skip empty lines and comments
        if not line or line.startswith('#'):
            continue
        
        # Construct input path (relative to manifest directory)
        input_path = manifest_dir / line.lstrip('./')
        
        # Construct output path (add .ovl extension)
        output_path = manifest_dir / f"{line.lstrip('./')}.ovl"
        
        print(f"\n[{line_num}] Processing: {line}")
        print(f"  Input:  {input_path}")
        print(f"  Output: {output_path}")

        process_uipackages(manifest_dir, line)

        print(f"  Packaging OVL...")
        
        # Build the command (currently not working due to cobra tools bug)
        # cmd = [
        #     "python",
        #     Path(__file__).parent / "build-ovl.py",
        #     str(cobra_tools_path),
        #     Path(__file__).parent / "config.py",
        #     "Planet Coaster 2",
        #     str(input_path)
        # ]
        cmd = [
            "python",
            str(ovl_tool_cmd),
            "new",
            "-i", str(input_path),
            "-g", "Planet Coaster 2",
            "-o", str(output_path),
            "--force"
        ]
        
        try:
            # Run the command
            result = subprocess.run(
                cmd,
                cwd=str(manifest_dir),
                capture_output=True,
                text=True,
                check=True
            )
            print(f"  Finished.")
            # if result.stdout:
            #     print(f"  Output: {result.stdout.strip()}")
            success_count += 1
            
        except subprocess.CalledProcessError as e:
            print(f"Failed with exit code {e.returncode}")
            if e.stdout:
                print(f"stdout: {e.stdout.strip()}")
            if e.stderr:
                print(f"stderr: {e.stderr.strip()}")
            fail_count += 1
        except Exception as e:
            print(f"Error: {e}")
            fail_count += 1
    
    print("\n" + "=" * 60)
    print(f"Processing complete: {success_count} succeeded, {fail_count} failed")
    
    return fail_count == 0


def main():
    parser = argparse.ArgumentParser(
        description="Process .ovlpaths file and run ovl_tool_cmd.py for each entry"
    )
    parser.add_argument(
        "cobra_tools_path",
        help="Path to Cobra Tools"
    )
    parser.add_argument(
        "manifest",
        help="Path to the Manifest.xml file"
    )
    parser.add_argument(
        "-launch",
        action="store_true",
        help="If present, Planet Coaster 2 will launch"
    )
    
    args = parser.parse_args()

    cobra_tools_path = Path(args.cobra_tools_path)
    if not cobra_tools_path.exists():
        print(f"Error: Cobra tools path not found: {cobra_tools_path}", file=sys.stderr)
        sys.exit(1)
    
    manifest_path = Path(args.manifest)
    if not manifest_path.exists():
        print(f"Error: Manifest file not found: {manifest_path}", file=sys.stderr)
        sys.exit(1)
    
    success = process_ovlpaths(cobra_tools_path, manifest_path)
    if success:
        if args.launch:
            subprocess.run(['start', f"steam://rungameid/{2688950}"], shell=True, check=True)

    sys.exit(0 if success else 1)

if __name__ == "__main__":
    main()