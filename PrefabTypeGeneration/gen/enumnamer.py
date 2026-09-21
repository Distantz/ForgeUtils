from xml.etree.ElementTree import Element


class Enumnamer:
    def __init__(self, name: str):
        self.name = name
        self.values = []

    def load(self, xml_element: Element) -> None:
        pointers = xml_element.find("strings").findall("pointer")
        self.values = [pointer.text for pointer in pointers]
        pass

    def __repr__(self) -> str:
            return f"Enumnamer(name={self.name}, values={len(self.values)})"
    
    def __str__(self) -> str:
        lines = [f"Enumnamer: {self.name}"]
        for value in self.values:
            lines.append(value)
        return "\n".join(lines)

# <EnumnamerRoot game="Planet Coaster 2">
# 	<strings pool_type="3">
# 		<pointer pool_type="3">Flat</pointer>
# 		<pointer pool_type="3">Tracked</pointer>
# 	</strings>
# </EnumnamerRoot>
