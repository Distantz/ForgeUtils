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
    required_parameters: dict[str, TableParam] = field(default_factory=dict)
    optional_parameters: dict[str, TableParam] = field(default_factory=dict)

    def get_insert_parameters(self):
        if (len(self.required_parameters) > 0):
            return self.required_parameters
        return self.parameters

    def get_update_parameters(self):
        pk, _ = self.get_primary_key()
        return {k: v for k, v in self.parameters.items() if k != pk}
    
    def get_primary_key(self) -> tuple[str, TableParam]:
        # iterate through params, find the primary key
        for name, param in self.parameters.items():
            if param.primary_key:
                return (name, param)
            
        # sane default is the first insert param
        return next(iter(self.get_insert_parameters().items()))

    def __str__(self):
        return f"Required: {self.required_parameters}, Optional: {self.optional_parameters}"