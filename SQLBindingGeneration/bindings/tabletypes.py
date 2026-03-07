from dataclasses import dataclass, field


@dataclass
class TableParam:
    """Class to represent table parameters"""
    sql_type: any
    not_null: bool
    default: any
    primary_key: bool
    most_common_values : list[str] = field(default_factory=list)

    def __str__(self):
        ret_str = ""
        if self.primary_key:
            ret_str += "PRIMARY_KEY -> "

        ret_str += self.sql_type

        if self.not_null != None:
            ret_str += f"?"
        if self.default != None:
            ret_str += f" = {self.default}"

        if (len(self.most_common_values) > 0):
            ret_str += f"[Examples = {", ".join(self.most_common_values)}]"
            
        return ret_str
    
    def __repr__(self):
        return self.__str__()
    
@dataclass
class TableData:
    """Class to hold all table parameters"""
    parameters: dict[str, TableParam] = field(default_factory=dict)
    primary_keys : dict[str, TableParam] = field(default_factory=dict)
    required_parameters: dict[str, TableParam] = field(default_factory=dict)
    optional_parameters: dict[str, TableParam] = field(default_factory=dict)

    def get_insert_parameters(self):
        default = {k: v for k, v in self.parameters.items() if k in self.primary_keys.keys() or k in self.required_parameters.keys()}
        if (len(default) > 0):
            return default

        return self.parameters

    def get_update_parameters(self):
        primary_keys = self.get_primary_keys()
        return {k: v for k, v in self.parameters.items() if k not in primary_keys.keys()}
    
    def get_primary_keys(self) -> dict[str, TableParam]:

        if (len(self.primary_keys) > 0):
            return self.primary_keys
            
        # sane default is the first insert param
        tupl = next(iter(self.get_insert_parameters().items()))
        return {tupl[0]: tupl[1]}

    def __str__(self):
        return f"PKs: {self.primary_keys}, Required: {self.required_parameters}, Optional: {self.optional_parameters}"