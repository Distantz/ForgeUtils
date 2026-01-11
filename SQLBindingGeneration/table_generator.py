import sqlite3
from tabletypes import TableData, TableParam
from shared_gen import get_insert_name, get_update_name
from luagen import get_pretty_print_for_value, get_update_method, get_insert_method, generate_lua_source_file
from pscolgen import get_root_file, get_insert_statement, get_update_statement
import xml.etree.ElementTree as ET
import sys

def extract_table_data(table_name, cursor) -> TableData:
    cursor.execute(f"PRAGMA table_info({table_name});")
    columns = cursor.fetchall()
    params : dict[str, TableParam] = {
        col[1]: TableParam(
            col[2],
            bool(col[3]),
            col[4],
            bool(col[5])
        )
        for col in columns
    }
    
    cursor.execute(f"PRAGMA foreign_key_list({table_name});")
    foreign_keys = cursor.fetchall()
    foreign_key_columns = {fk[3] for fk in foreign_keys}

    cursor.execute(f"PRAGMA index_list({table_name});")
    indexes = cursor.fetchall()
    unique_columns = []
    for _, index_name, unique, *_ in indexes:
        if unique:
            cursor.execute(f"PRAGMA index_info({index_name});")
            index_cols = cursor.fetchall()
            for col in index_cols:
                unique_columns.append(col[2])
    
    data = TableData()

    for param_name, param_data in params.items():

        # Look at data distribution for this column.
        cursor.execute(f"SELECT {param_name}, COUNT(*) AS freq, ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 2) AS pct_of_total FROM {table_name} GROUP BY {param_name} ORDER BY freq DESC LIMIT 5;")
        results = cursor.fetchall()
        param_data.most_common_values = [
            get_pretty_print_for_value(val[0])
            for val in results
        ]

        data.parameters[param_name] = param_data

        if param_data.primary_key or param_name in foreign_key_columns or param_name in unique_columns:
            data.primary_keys[param_name] = param_data
        elif not (param_data.default is not None or not param_data.not_null):
            data.required_parameters[param_name] = param_data
        else:
            data.optional_parameters[param_name] = param_data

    return data

def _generate_for_table(database_name : str, table_name : str, table_data : TableData, lua_manager : str = "TestManager") -> tuple[ET.Element, str] :
    statements : list[ET.Element] = []

    insert_params = table_data.get_insert_parameters()
    update_params = table_data.get_update_parameters()
    primary_keys = table_data.get_primary_keys()

    lua = ""

    # generate inserter
    statements.append(get_insert_statement(table_name, get_insert_name(table_name), insert_params))
    lua += get_insert_method(
        lua_manager,
        database_name,
        table_name,
        table_data
    )

    if len(update_params) > 0:

        for param_name, param_data in update_params.items():
            statements.append(
                get_update_statement(
                    table_name, 
                    get_update_name(table_name, param_name), 
                    primary_keys,
                    param_name,
                    param_data
                )
            )
            lua += get_update_method(
                lua_manager,
                database_name,
                table_name,
                primary_keys,
                param_name,
                param_data
            )

    root = get_root_file(statements)
    return (root, lua)

def generate_for_database(
        database_path : str,
        database_name : str, 
        pscollection_save_dir : str,
        lua_save_dir : str,
        lua_namespace : str
    ) -> None:

    conn = sqlite3.connect(database_path)
    cursor = conn.cursor()

    cursor.execute("SELECT name FROM sqlite_master WHERE type='table' AND name NOT LIKE 'sqlite_%';")
    tables = [row[0] for row in cursor.fetchall()]

    db_lua = ""
    pscollections : dict[str, ET.Element] = {}

    for table in tables:
        data = extract_table_data(table, cursor)
        pscoll, table_lua = _generate_for_table(database_name, table, data, database_name)
        pscollections[f"{database_name}_{table}"] = pscoll
        db_lua += table_lua

    lua_source = generate_lua_source_file(
        database_name,
        lua_namespace,
        database_name,
        list(pscollections.keys()),
        db_lua
    )

    with open(lua_save_dir + f"\\{database_name}.lua", "w+") as file:
        file.write(lua_source)

    for name, xml in pscollections.items():
        with open(pscollection_save_dir + f"\\{name}.pscollection", "w+") as file:
            file.write(ET.tostring(xml, encoding="unicode"))

    conn.close()
