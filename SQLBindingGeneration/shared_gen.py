def get_insert_name(table : str) -> str:
    return f"{table}__Insert"

def get_update_name(table : str, param_name : str) -> str:
    return f"{table}__Update__{param_name}"