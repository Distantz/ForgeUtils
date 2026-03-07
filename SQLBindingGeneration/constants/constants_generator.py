import sqlite3
from .luagen import generate_lua_source_file

def get_constants_for_table(
    db : sqlite3.Connection,
    sql_statement : str
) -> list[any]:
    cursor = db.cursor()
    cursor.execute(sql_statement)
    return [row[0] for row in cursor.fetchall()]

def get_constants_for_database(
    dbPath : str,
    db_constants : dict[str, str]
) -> dict[str, list[any]]:
    conn = sqlite3.connect(dbPath)
    return {
        kvp[0]: get_constants_for_table(conn, kvp[1])
        for kvp in db_constants.items()
    }

def generate_constants_for_database(
    dbPath : str,
    name : str,
    db_constants : dict[str, str],
    export_constants_lua_folder : str,
    constants_lua_namespace : str
):
    constants = get_constants_for_database(
        dbPath,
        db_constants
    )

    lua_source = generate_lua_source_file(
        name,
        constants_lua_namespace,
        name,
        constants
    )

    with open(export_constants_lua_folder + f"\\{name}.lua", "w+") as file:
        file.write(lua_source)
    
