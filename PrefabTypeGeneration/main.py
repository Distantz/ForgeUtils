
import os
import tkinter as tk
import xml.etree.ElementTree as ET
from tkinter import filedialog
from configuration import base_lua_folder, base_lua_namespace, custom_words
from gen.pascal_caser import PascalCaser
from gen.specdef import Specdef
from gen.enumnamer import Enumnamer

tk.Tk().withdraw()

this_path = os.path.dirname(os.path.realpath(__file__))
base_path = os.path.join(
    this_path, 
    "..\\", 
)

export_constants_lua_folder = os.path.join(
    base_path, 
    base_lua_folder
)

specdefs_folder = filedialog.askdirectory(title="Select folder containing Specdefs and Enumnamers to generate for!")

specdef_files = []
enumnamer_files = []

specdefs : dict[str, Specdef] = {}
enumnamers : dict[str, Enumnamer] = {}

for file in os.listdir(specdefs_folder):
    filename = str(file)
    if file.endswith(".specdef"):
        specdef_files.append(filename)
    elif file.endswith(".enumnamer"):
        enumnamer_files.append(filename)

caser = PascalCaser(custom_words)

for specdef_file in specdef_files:
    base_name = os.path.basename(specdef_file)
    file_name, _ = os.path.splitext(base_name)
    
    pascalCase = caser.get_pascal_case(file_name)
    print(f"Processing {pascalCase}")

    file_path = os.path.join(specdefs_folder, specdef_file)
    with open(file_path, "r") as f:
        xml = ET.parse(f)
        specdef_obj = Specdef(pascalCase) 
        specdef_obj.load(xml.getroot())
        specdefs[base_name] = specdef_obj

for enumnamer_file in enumnamer_files:
    base_name = os.path.basename(enumnamer_file)
    file_name, _ = os.path.splitext(base_name)
    
    pascalCase = caser.get_pascal_case(file_name)
    print(f"Processing {pascalCase}")

    file_path = os.path.join(specdefs_folder, enumnamer_file)
    with open(file_path, "r") as f:
        xml = ET.parse(f)
        enumnamer_obj = Enumnamer(pascalCase) 
        enumnamer_obj.load(xml.getroot())
        enumnamers[base_name] = enumnamer_obj




# Somehow, convert these mothers into typed lua.

print(specdefs)
print(enumnamers)