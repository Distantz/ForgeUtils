


import sqlite3
from luagen import get_luadoc_comment
from tabletypes import TableParam
from table_generator import extract_table_data
import tkinter as tk
from tkinter import filedialog


tk.Tk().withdraw()

conn = sqlite3.connect(filedialog.askopenfilename())
cursor = conn.cursor()

cursor.execute("SELECT name FROM sqlite_master WHERE type='table' AND name NOT LIKE 'sqlite_%';")
tables = [row[0] for row in cursor.fetchall()]

params : dict[str, tuple[str, TableParam]] = {}

for table in tables:
    data = extract_table_data(table, cursor)
    for key, param in data.get_insert_parameters().items():
        if key not in params:
            params[key] = table, param

print("\n".join([
    get_luadoc_comment(f"{key}", param)
    for key, (table, param) in params.items()
]))
    