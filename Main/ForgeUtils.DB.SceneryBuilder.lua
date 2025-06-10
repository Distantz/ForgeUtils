local global = _G
local api = global.api
local setmetatable = global.setmetatable

--- @class ForgeUtils.DB.SceneryBuilder
--- @field contentPack string
--- @field contentPackID integer
--- @field dataPrefab string
--- @field partID string
--- @field nameFile string
--- @field descFile string
--- SceneryPartBuilder is a fluent builder for database values in ForgeUtils.
--- Example usage, which creates a scenery part with ID PC_ExampleTestID and name and description:
--- ```lua
--- SceneryPartBuilder.new()
---     :withID("PC_ExampleTestID")
---     :withNameFile("PC_ExampleTestID_Name")
---     :withDescriptionFile("PC_ExampleTestID_Desc")
---     :addToDB()
--- ```
--- Note the use of the `addToDB()` call at the end. This is actually what adds the defined values
--- into the DB.
---
local SceneryPartBuilder = {}
SceneryPartBuilder.__index = SceneryPartBuilder

---Creates a SceneryPartBuilder, to define database information.
---@return self
function SceneryPartBuilder.new()
    local instance = setmetatable({}, SceneryPartBuilder)

    -- Defaults
    instance.contentPack = "BaseGame"
    instance.contentPackID = 0
    instance.dataPrefab = "SurfaceScaling"
    return instance
end

--- Sets the ID of the scenery part.
--- Unless the prefab and icon names are set, this will also be those.
--- @param partID string The ID to use for this scenery part
--- @returns self
function SceneryPartBuilder:withID(partID)
    self.partID = partID
    return self
end

---Sets the translation file for the scenery part name.
---@param nameFile string The name of the translation file.
---@return self
function SceneryPartBuilder:withNameFile(nameFile)
    self.nameFile = nameFile
    return self
end

---Sets the translation file for the scenery part description.
---@param descFile string The name of the translation file.
---@return self
function SceneryPartBuilder:withDescriptionFile(descFile)
    self.descFile = descFile
    return self
end

--- Adds the built part within the builder to the DB.
--- This can be called multiple times.
--- @return nil
function SceneryPartBuilder:addToDB()
    -- TODO: Define functionality
end

return SceneryPartBuilder
