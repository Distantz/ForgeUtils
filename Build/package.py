import os
import zipfile
import sys
import xml.etree.ElementTree as ET

def get_manifest_name(manifest_path):
    tree = ET.parse(manifest_path)
    root = tree.getroot()
    name_node = root.find("Name")
    if name_node is None or not name_node.text.strip():
        raise ValueError("Manifest.xml does not contain a valid <Name> element.")
    return name_node.text.strip()

def build_archive(archive_dir, output_file):
    archive_dir = os.path.abspath(archive_dir)

    manifest_path = os.path.join(archive_dir, "Manifest.xml")
    if not os.path.isfile(manifest_path):
        raise FileNotFoundError("Manifest.xml not found in the top-level directory.")

    pack_name = get_manifest_name(manifest_path)

    files_to_zip = [manifest_path]

    for name in os.listdir(archive_dir):
        lower = name.lower()
        if lower.startswith("readme") or lower.startswith("license"):
            f = os.path.join(archive_dir, name)
            if os.path.isfile(f):
                files_to_zip.append(f)

    for base, _, files in os.walk(archive_dir):
        for f in files:
            if f.endswith(".ovl") or f.endswith(".ini"):
                files_to_zip.append(os.path.join(base, f))

    with zipfile.ZipFile(output_file, "w", zipfile.ZIP_DEFLATED) as zf:
        for f in files_to_zip:
            rel = os.path.relpath(f, archive_dir)
            zf.write(f, os.path.join(pack_name, rel))  # Insert pack_name as the root folder


if len(sys.argv) < 3:
    print("First argument needs to be the folder to be packaged! The second argument needs to be the name of the outputted file!")
    exit(-1)

folder = sys.argv[1]
output = sys.argv[2]
build_archive(folder, output)