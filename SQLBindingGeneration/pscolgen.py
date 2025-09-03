
import xml.etree.ElementTree as ET
from tabletypes import TableParam

# arg_type 0 indicates an integer value
# arg_type 2 indicates a float value
# arg_type 3 indicates a string value.
def map_sqltype_to_pscollection_type(sql_type : str) -> str:
    sql_type = sql_type.lower()
    if sql_type in ("integer"):
        return "0"
    if sql_type in ("real", "double"):
        return "2"
    return "3"

def get_root_file(statements : list[ET.Element]) -> ET.Element:
    root = ET.Element("PscollectionRoot", {"count": str(len(statements)), "game": "Planet Coaster 2"})
    elem = ET.SubElement(root, "prepared_statements", {"pool_type": "4"})

    for statement in statements:
        elem.append(statement)

    return root

def get_arg(arg : TableParam, index : int) -> ET.Element:
    arg_type = map_sqltype_to_pscollection_type(arg.sql_type)
    return ET.Element("arg", {"arg_type": arg_type, "arg_index": str(index)})

def get_prepared_statement(statement_name : str, sql_statement : str, args : list[TableParam]) -> ET.Element:
    ps_statement = ET.Element(
        "prepared_statement",
        {"arg_count": str(len(args))}
    )

    args_elem = ET.SubElement(ps_statement, "args", {"pool_type": "4"})
    for x in range(1, len(args) + 1):
        args_elem.append(get_arg(args[x - 1], x))

    ET.SubElement(ps_statement, "statement_name").text = statement_name
    ET.SubElement(ps_statement, "sql_query").text = sql_statement
    return ps_statement

def get_insert_statement(table : str, statement_name : str, params : dict[str, TableParam]) -> ET.Element:
    args_str = ", ".join(
        [
            f"?{x}"
            for x in range(1, len(params) + 1)
        ]
    )

    params_str = ", ".join(params.keys())
    return get_prepared_statement(
        statement_name,
        f"INSERT OR IGNORE INTO {table} ({params_str}) VALUES ({args_str});",
        list(params.values())
    )

def get_update_statement(table : str, statement_name : str, lookup_name : str, lookup_param : TableParam, param_name : str, param_data : TableParam) -> ET.Element:
    return get_prepared_statement(
        statement_name,
        f"UPDATE {table} SET {param_name} = ?2 WHERE {lookup_name} = ?1;",
        [
            lookup_param,
            param_data
        ]
    )