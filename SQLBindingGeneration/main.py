
import os
import tkinter as tk
from tkinter import filedialog
from bindings.table_generator import generate_for_database
from constants.constants_generator import generate_constants_for_database
from configuration import (
    # Folders
    base_lua_folder, 
    constants_lua_folder,

    # Namespaces
    base_lua_namespace,
    constants_lua_namespace,

    # Configuration
    generate_dbs,
    generate_db_constants
)

tk.Tk().withdraw()

this_path = os.path.dirname(os.path.realpath(__file__))
base_path = os.path.join(
    this_path, 
    "..\\", 
)

export_database_lua_folder = os.path.join(
    base_path,
    base_lua_folder
)
export_constants_lua_folder = os.path.join(
    base_path, 
    constants_lua_folder
)

init_folder = os.path.join(
    this_path, 
    "../", 
    "Init"
)

database_folder = filedialog.askdirectory(title="Select folder containing game FDBs to regenerate!")
found_dbs : dict[str, str] = {}

for file in os.listdir(database_folder):
    if file.endswith(".fdb"):
        file_name = file.split("/")[-1].split(".")[0]
        for db in generate_dbs:
            if (file_name.lower() == db.lower()):
                found_dbs[db] = os.path.join(database_folder, file)

for name, path in found_dbs.items():
    print(f"Regenerating {name}...")
    generate_for_database(
        path,
        name,
        init_folder,
        export_database_lua_folder,
        base_lua_namespace
    )

    print("Looking for constants...")
    if name in generate_db_constants:
        generate_constants_for_database(
            path,
            name,
            generate_db_constants[name],
            export_constants_lua_folder,
            constants_lua_namespace
        )
    print("Done!")

print("Finished generation")
