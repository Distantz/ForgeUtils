
import os
import tkinter as tk
from tkinter import filedialog
from table_generator import generate_for_database

tk.Tk().withdraw()

generate_dbs = [
    "TrackedRides",
    "TrackedRideCars",
    "ModularScenery",
    "Audio"
]

this_path = dir_path = os.path.dirname(os.path.realpath(__file__))
lua_folder = os.path.join(
    this_path, 
    "..\\", 
    "Main", 
    "forgeutils", 
    "internal", 
    "database"
)

lua_namespace = "forgeutils.internal.database"

pscoll_folder = os.path.join(
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
        pscoll_folder,
        lua_folder,
        lua_namespace
    )
    print("Done!")
