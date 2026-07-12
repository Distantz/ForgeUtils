from dataclasses import dataclass, field

@dataclass
class TableParam:
    """Class to represent table parameters"""
    sql_type: any
    not_null: bool
    default: any
    primary_key: bool
    foreign_key: bool = False
    unique: bool = False
    most_common_values: list[str] = field(default_factory=list)

    @property
    def is_key(self) -> bool:
        return self.primary_key or self.foreign_key or self.unique

    @property
    def required(self) -> bool:
        return not self.is_key and self.default is None and self.not_null

    def __str__(self):
        ret_str = ""
        if self.primary_key:
            ret_str += "PRIMARY_KEY -> "
        if self.foreign_key:
            ret_str += "FOREIGN_KEY -> "
        if self.unique:
            ret_str += "UNIQUE -> "

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

from dataclasses import dataclass, field


@dataclass
class TableData:
    """Class to hold all table parameters, in table-definition order"""
    parameters: dict[str, TableParam] = field(default_factory=dict)

    @property
    def primary_keys(self) -> dict[str, TableParam]:
        return {k: v for k, v in self.parameters.items() if v.is_key}

    @property
    def required_parameters(self) -> dict[str, TableParam]:
        return {k: v for k, v in self.parameters.items() if not v.is_key and v.required}

    @property
    def optional_parameters(self) -> dict[str, TableParam]:
        return {k: v for k, v in self.parameters.items() if not v.is_key and not v.required}

    def get_insert_parameters(self):
        default = {
            k: v for k, v in self.parameters.items()
            if v.is_key or v.required
        }
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
        kvp = next(iter(self.get_insert_parameters().items()))
        return {kvp[0]: kvp[1]}

    def __str__(self):
        return f"PKs: {self.primary_keys}, Required: {self.required_parameters}, Optional: {self.optional_parameters}"