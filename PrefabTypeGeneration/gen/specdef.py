from typing import Optional, Any
import xml.etree.ElementTree as ET
from xml.etree.ElementTree import Element
from dataclasses import dataclass
from enum import IntEnum


class SpecdefDtype(IntEnum):
    BOOLEAN = 0
    INT_8 = 1
    INT_16 = 2
    INT_32 = 3
    INT_64 = 4
    U_INT_8 = 5
    U_INT_16 = 6
    U_INT_32 = 7
    U_INT_64 = 8
    FLOAT = 9
    STRING = 10
    VECTOR_2 = 11
    VECTOR_3 = 12
    ARRAY = 13
    CHILD_ITEM = 14
    REFERENCE_TO_OBJECT = 15


@dataclass
class SpecdefAttribute:
    name: str
    dtype: SpecdefDtype
    optional: bool = False
    min_value: Optional[float] = None
    max_value: Optional[float] = None
    default_value: Optional[Any] = None
    enum_reference: Optional[str] = None
    child_spec: Optional["Specdef"] = None


class Specdef:
    def __init__(self, name: str):
        self.name = name
        self.attributes: list[SpecdefAttribute] = []
        self.child_specs: list[str] = []

    def load(self, xml_element: Element) -> None:
        """Load and parse a Specdef from an XML element"""
        attribs = xml_element.find("attribs")
        if attribs is not None:
            self.attributes = [
                self._parse_attribute(spec) 
                for spec in attribs.findall("spec")
            ]

        childspecs = xml_element.find("childspecs")
        if childspecs is not None:
            self.child_specs = [
                p.text for p in childspecs.findall("pointer") if p.text
            ]

    def _parse_attribute(self, spec: Element) -> SpecdefAttribute:

        dtype_str = spec.get("dtype", "").removeprefix("SpecdefDtype.")
        try:
            dtype = SpecdefDtype[dtype_str]
        except KeyError:
            dtype = SpecdefDtype.BOOLEAN

        name_ptr = spec.find("name_ptr")
        attributeName = name_ptr.text

        data_ptr = spec.find("data_ptr")
        dtype_elem = data_ptr.find("dtype") if data_ptr is not None else None

        attr = SpecdefAttribute(name=attributeName, dtype=dtype)

        if dtype_elem is None:
            return attr

        # Parse optional
        attr.optional = dtype_elem.get("ioptional") == "1"

        # Parse numeric bounds
        imin = dtype_elem.get("imin")
        imax = dtype_elem.get("imax")
        if imin:
            try:
                attr.min_value = float(imin)
            except ValueError:
                pass
        if imax:
            try:
                attr.max_value = float(imax)
            except ValueError:
                pass

        # Parse default value
        ivalue = dtype_elem.get("ivalue")
        if ivalue:
            attr.default_value = ivalue

        # Parse enum
        enum_elem = dtype_elem.find("enum")
        if enum_elem is not None:
            attr.enum_reference = enum_elem.text

        if dtype in (SpecdefDtype.ARRAY, SpecdefDtype.CHILD_ITEM):
            specdef_elem = dtype_elem.find(".//specdef")
            if specdef_elem is not None:
                if specdef_elem.text and specdef_elem.text.strip() and len(specdef_elem) == 0:
                    attr.child_spec = Specdef(specdef_elem.text.strip())
                else:
                    child = Specdef(f"{self.name}.{attributeName}Item")
                    child.load(specdef_elem)
                    attr.child_spec = child

        return attr

    def __repr__(self) -> str:
        return f"Specdef(name={self.name}, attrs={len(self.attributes)})"

    def __str__(self) -> str:
        lines = [f"Specdef: {self.name}"]
        for attr in self.attributes:
            lines.append(f"  {attr.name}: {attr.dtype.name} (opt={attr.optional})")
            if attr.enum_reference:
                lines.append(f"    enum: {attr.enum_reference}")
            if attr.child_spec:
                lines.append(f"    child: {attr.child_spec.name} ({len(attr.child_spec.attributes)} attrs)")
        return "\n".join(lines)


if __name__ == "__main__":
    xml_str = """
<SpecdefRoot attrib_count="3" flags="0" game="Planet Coaster 2">
	<attribs pool_type="3">
		<spec dtype="SpecdefDtype.STRING">
			<name_ptr pool_type="3">PoseDefinitionName</name_ptr>
			<data_ptr pool_type="3">
				<dtype ioptional="0" />
			</data_ptr>
		</spec>
		<spec dtype="SpecdefDtype.ARRAY">
			<name_ptr pool_type="3">GlobalBlendWeightStreams</name_ptr>
			<data_ptr pool_type="3">
				<dtype dtype="SpecdefDtype.CHILD_ITEM" unused="0">
					<item pool_type="3">
						<dtype>
							<specdef>mogblendweightstream.specdef</specdef>
						</dtype>
					</item>
				</dtype>
			</data_ptr>
		</spec>
		<spec dtype="SpecdefDtype.ARRAY">
			<name_ptr pool_type="3">DebugDrivers</name_ptr>
			<data_ptr pool_type="3">
				<dtype dtype="SpecdefDtype.CHILD_ITEM" unused="0">
					<item pool_type="3">
						<dtype>
							<specdef pool_type="3" attrib_count="6" flags="0">
								<attribs pool_type="3">
									<spec dtype="SpecdefDtype.STRING">
										<name_ptr pool_type="3">SourceBone</name_ptr>
										<data_ptr pool_type="3">
											<dtype ioptional="0" />
										</data_ptr>
									</spec>
									<spec dtype="SpecdefDtype.U_INT_8">
										<name_ptr pool_type="3">SourceTrackType</name_ptr>
										<data_ptr pool_type="3">
											<dtype imin="0" imax="255" ivalue="0" ioptional="1">
												<unused>0 0 0 0</unused>
												<enum>posedrivertracktype.enumnamer</enum>
											</dtype>
										</data_ptr>
									</spec>
									<spec dtype="SpecdefDtype.U_INT_8">
										<name_ptr pool_type="3">SourceTrackAxis</name_ptr>
										<data_ptr pool_type="3">
											<dtype imin="0" imax="255" ivalue="0" ioptional="1">
												<unused>0 0 0 0</unused>
												<enum>posedrivertrackaxis.enumnamer</enum>
											</dtype>
										</data_ptr>
									</spec>
									<spec dtype="SpecdefDtype.STRING">
										<name_ptr pool_type="3">TargetBone</name_ptr>
										<data_ptr pool_type="3">
											<dtype ioptional="0" />
										</data_ptr>
									</spec>
									<spec dtype="SpecdefDtype.U_INT_8">
										<name_ptr pool_type="3">TargetTrackType</name_ptr>
										<data_ptr pool_type="3">
											<dtype imin="0" imax="255" ivalue="0" ioptional="1">
												<unused>0 0 0 0</unused>
												<enum>posedrivertracktype.enumnamer</enum>
											</dtype>
										</data_ptr>
									</spec>
									<spec dtype="SpecdefDtype.ARRAY">
										<name_ptr pool_type="3">Keys</name_ptr>
										<data_ptr pool_type="3">
											<dtype dtype="SpecdefDtype.CHILD_ITEM" unused="0">
												<item pool_type="3">
													<dtype>
														<specdef pool_type="3" attrib_count="2" flags="0">
															<attribs pool_type="3">
																<spec dtype="SpecdefDtype.FLOAT">
																	<name_ptr pool_type="3">Key</name_ptr>
																	<data_ptr pool_type="3">
																		<dtype imin="-3.4028234663852886e+38" imax="3.4028234663852886e+38" ivalue="0.0" ioptional="0" />
																	</data_ptr>
																</spec>
																<spec dtype="SpecdefDtype.VECTOR_3">
																	<name_ptr pool_type="3">OutputPose</name_ptr>
																	<data_ptr pool_type="3">
																		<dtype x="0.0" y="0.0" z="0.0" ioptional="0" />
																	</data_ptr>
																</spec>
															</attribs>
														</specdef>
													</dtype>
												</item>
											</dtype>
										</data_ptr>
									</spec>
								</attribs>
							</specdef>
						</dtype>
					</item>
				</dtype>
			</data_ptr>
		</spec>
	</attribs>
	<names pool_type="3">
		<pointer pool_type="3">posedriver</pointer>
	</names>
	<childspecs pool_type="3">
		<pointer pool_type="3">animation</pointer>
	</childspecs>
	<managers pool_type="3">
		<pointer pool_type="3">symbolsource</pointer>
	</managers>
</SpecdefRoot>


"""

    xml = ET.fromstring(xml_str)
    specdef = Specdef("Test")
    specdef.load(xml)
    print(specdef)