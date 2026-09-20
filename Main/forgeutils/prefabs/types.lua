---@meta This class only contains typing definitions and shouldn't be imported.

---@class forgeutils.prefabs.Prefab A base class for prefabs in the Cobra Engine.
---@field Prefab string? The name of the base of the prefab (the one to inherit from).
---@field Properties table<string, forgeutils.prefabs.Property>? List of properties on this prefab.
---@field Components forgeutils.prefabs.ComponentList? List of components on this prefab.
---@field Children table<string, forgeutils.prefabs.Prefab>? List of child prefabs which live under the parent.

---@class forgeutils.prefabs.Property
---@field Type forgeutils.prefabs.PropertyType The type of the property.
---@field Enum string? The name of the Enumnamer if this property is an enum.
---@field Default any? The default value of the property if a parent does not override it.
---@field Optional boolean? Whether the property is required or not.

---@enum (key) forgeutils.prefabs.PropertyType
local enum = {
    bool = 1,
    int8 = 2,
    int16 = 3,
    int32 = 4,
    int64 = 5,
    uint8 = 6,
    uint16 = 7,
    uint32 = 8,
    uint64 = 9,
    float = 10,
    string = 11,
    vector2 = 12,
    vector3 = 13,
    array = 14,
    -- no child_item type...
    entity = 16,
}
