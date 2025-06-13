local global = _G
local api = global.api
local setmetatable = global.setmetatable

local SceneryDB = require("forgeutils.internal.database.scenery")
local logger = require("forgeutils.logger").Get("SceneryPartBuilder")

--- SceneryPartBuilder is a fluent builder for database values in ForgeUtils.
--- Example usage, which creates a scenery part with ID PC_ExampleTestID and name and description:
--- ```lua
--- SceneryPartBuilder.new()
---     :asSimplePart()
---     :withID("PC_ExampleTestID")
---     :withNameFile("PC_ExampleTestID_Name")
---     :withDescriptionFile("PC_ExampleTestID_Desc")
---     :addToDB()
--- ```
--- Note the use of the `addToDB()` call at the end. This is actually what adds the defined values
--- into the DB.
---
--- @class forgeutils.builders.SceneryPartBuilder
--- @field __index table
--- @field partID string
--- @field contentPack string Default is BaseGame.
--- @field contentPackID integer Default is 0.
--- @field visualsPrefab string? Default is nil, mapping to `*PART_ID*`.
--- @field dataPrefab string Default is SurfaceScaling.
--- @field nameFile string
--- @field descFile string
--- @field iconFile string? Default is nil, mapping to `uigameface\img\modularscenery\*PART_ID*`.
--- @field minScale number?
--- @field maxScale number?
--- @field sizeX number Default is 1m.
--- @field sizeY number Default is 1m.
--- @field sizeZ number Default is 1m.
--- @field buildCost integer Default is 0.
--- @field hourlyRunningCost integer Default is 0.
--- @field researchPack integer Default is 0.
--- @field requiresUnlock boolean Default is false.
local SceneryPartBuilder = {}
SceneryPartBuilder.__index = SceneryPartBuilder

---Creates a SceneryPartBuilder, to define database information.
---@return forgeutils.builders.SceneryPartBuilder
function SceneryPartBuilder.new()
    local instance = setmetatable({}, SceneryPartBuilder)
    -- Defaults
    instance.contentPack = "BaseGame"
    instance.contentPackID = 0
    instance.dataPrefab = "SurfaceScaling"
    instance.sizeX = 1.0
    instance.sizeY = 1.0
    instance.sizeZ = 1.0

    instance.buildCost = 0
    instance.hourlyRunningCost = 0
    instance.researchPack = 0
    instance.requiresUnlock = false

    return instance
end

--- Sets the part to be a simple (freeform) part.
--- @return forgeutils.builders.SceneryPartBuilder
function SceneryPartBuilder:asSimplePart()
    self.dataPrefab = "SurfaceScaling"
    return self
end

--- Sets the ID of the scenery part.
--- Unless the prefab and icon names are set, this will also be those.
--- @param partID string The ID to use for this scenery part
--- @return forgeutils.builders.SceneryPartBuilder
function SceneryPartBuilder:withID(partID)
    self.partID = partID
    return self
end

---Sets the translation file for the scenery part name.
---@param nameFile string The name of the translation file.
---@return forgeutils.builders.SceneryPartBuilder
function SceneryPartBuilder:withNameFile(nameFile)
    self.nameFile = nameFile
    return self
end

---Sets the translation file for the scenery part description.
---@param descFile string The name of the translation file.
---@return forgeutils.builders.SceneryPartBuilder
function SceneryPartBuilder:withDescriptionFile(descFile)
    self.descFile = descFile
    return self
end

---Sets the content pack for the scenery part. Default is BaseGame and 0.
---@param contentPack string The name of the content pack.
---@param contentPackID integer The ID of the content pack.
---@return forgeutils.builders.SceneryPartBuilder
function SceneryPartBuilder:withContentPack(contentPack, contentPackID)
    self.contentPack = contentPack
    self.contentPackID = contentPackID
    return self
end

---Sets the visual prefab for the scenery part. Default is the same as the partID.
---@param visualPrefabName string The name of the visual prefab.
---@return forgeutils.builders.SceneryPartBuilder
function SceneryPartBuilder:withVisualPrefab(visualPrefabName)
    self.visualsPrefab = visualPrefabName
    return self
end

---Sets the icon for the scenery part. Default is `uigameface\img\modularscenery\*PART_ID*`.
---@param iconPath string The path to the icon within the ppuipkg file.
---@return forgeutils.builders.SceneryPartBuilder
function SceneryPartBuilder:withIcon(iconPath)
    self.iconFile = iconPath
    return self
end

---Sets the scaling range of the scenery part. Default range is not known.
---@param minScale number
---@return forgeutils.builders.SceneryPartBuilder
function SceneryPartBuilder:withScaleRange(minScale, maxScale)
    self.minScale = minScale
    self.maxScale = maxScale
    return self
end

--- Adds the built part within the builder to the DB.
--- This object can be reused afterwards to reuse parameters if desired.
---@return nil
function SceneryPartBuilder:addToDB()
    logger:Info("Creating new Scenery Part with ID: " .. self.partID)

    if (logger:IsNil(self.partID, "Part ID") or logger:IsNil(self.visualsPrefab, "Prefab visuals")) then
        return
    end

    SceneryDB.Forge_AddModularSceneryPart(
        self.partID,
        self.visualsPrefab,
        self.dataPrefab,
        self.contentPack,
        "",
        -- for some reason in the DB, size is defined in MM. so we convert from M.
        self.sizeX * 100.0,
        self.sizeY * 100.0,
        self.sizeZ * 100.0
    )

    SceneryDB.Forge_AddScenerySimulationData(
        self.partID,
        self.buildCost,
        self.hourlyRunningCost,
        self.researchPack,
        self.requiresUnlock and 1 or 0
    )

    if (logger:IsNil(self.nameFile, "Part name") or logger:IsNil(self.descFile, "Part description")) then
        return
    end

    SceneryDB.Forge_AddSceneryUIData(
        self.partID,
        self.nameFile,
        self.descFile,
        self.iconFile,
        self.contentPackID
    )

    logger:Info("Finished adding new Scenery Part with ID: " .. self.partID)
end

return SceneryPartBuilder
