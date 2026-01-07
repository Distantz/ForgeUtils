local global = _G
local api = global.api
local setmetatable = global.setmetatable
local pairs = global.pairs

local SceneryDBBindings = require("forgeutils.internal.database.ModularScenery")
local logger = require("forgeutils.logger").Get("SceneryPartBuilder")
local base = require("forgeutils.builders.basebuilder")

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
--- @class forgeutils.builders.SceneryPartBuilder : forgeutils.builders.BaseBuilder
--- @field __index table
--- @field partID string
--- @field contentPack string Default is BaseGame.
--- @field contentPackID integer Default is 0.
--- @field visualsPrefab string? Default is nil, mapping to `*PART_ID*`.
--- @field dataPrefab string Default is SurfaceScaling.
--- @field tags { [string]: boolean } Default is none. You will need to add at least one though. Values are not used in this, it's exclusively a set.
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
--- @field researchPack integer Default is nil.
--- @field requiresUnlock boolean Default is false.
local SceneryPartBuilder = {}
SceneryPartBuilder.__index = SceneryPartBuilder
setmetatable(SceneryPartBuilder, { __index = base })

---Creates a SceneryPartBuilder, to define database information.
---@return self
function SceneryPartBuilder.new()
    local instance = setmetatable(base.new(), SceneryPartBuilder)
    -- Defaults
    instance.dataPrefab = "SurfaceScaling"
    instance.sizeX = 1.0
    instance.sizeY = 1.0
    instance.sizeZ = 1.0

    instance.buildCost = 0
    instance.hourlyRunningCost = 0
    instance.researchPack = nil
    instance.requiresUnlock = false
    instance.tags = {}

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

---Adds a tag to the scenery part. Default is none, but you will need to add one.
---@param tag string
---@return forgeutils.builders.SceneryPartBuilder
function SceneryPartBuilder:withTag(tag)
    self.tags[tag] = true
    return self
end

--- Adds the built part within the builder to the DB.
--- This object can be reused afterwards to reuse parameters if desired.
---@return nil
function SceneryPartBuilder:addToDB()
    logger:Info("Creating new Scenery Part with ID: " .. self.partID)

    if (logger:IsNil(self.partID, "Part ID") or logger:IsNil(self.dataPrefab, "Data prefab")) then
        return
    end

    SceneryDBBindings.ModularSceneryParts__Insert(
        self.partID,
        self.dataPrefab,
        self.contentPack
    )
    SceneryDBBindings.ModularSceneryParts__Update__PrefabName(
        self.partID,
        self.dataPrefab,
        self.contentPack,
        self.visualsPrefab
    )
    SceneryDBBindings.ModularSceneryParts__Update__BoxXSize(
        self.partID,
        self.dataPrefab,
        self.contentPack,
        self.sizeX * 100.0
    )
    SceneryDBBindings.ModularSceneryParts__Update__BoxYSize(
        self.partID,
        self.dataPrefab,
        self.contentPack,
        self.sizeY * 100.0
    )
    SceneryDBBindings.ModularSceneryParts__Update__BoxZSize(
        self.partID,
        self.dataPrefab,
        self.contentPack,
        self.sizeZ * 100.0
    )

    SceneryDBBindings.Simulation__Insert(
        self.partID,
        self.buildCost
    )
    SceneryDBBindings.Simulation__Update__HourlyRunningCost(
        self.partID,
        self.hourlyRunningCost
    )
    SceneryDBBindings.Simulation__Update__ResearchPack(
        self.partID,
        self.researchPack
    )
    SceneryDBBindings.Simulation__Update__RequiresUnlockInSandbox(
        self.partID,
        self.requiresUnlock
    )

    if (logger:IsNil(self.nameFile, "Part name") or logger:IsNil(self.descFile, "Part description")) then
        return
    end

    SceneryDBBindings.UIData__Insert(
        self.partID,
        self.nameFile,
        self.descFile
    )

    SceneryDBBindings.UIData__Update__Icon(
        self.partID,
        self.iconFile
    )

    for k, v in pairs(self.tags) do
        SceneryDBBindings.Metadata_Tags__Insert(
            self.partID,
            k
        )
    end

    if (self.minScale ~= nil and self.maxScale ~= nil) then
        SceneryDBBindings.SceneryScaling__Insert(self.partID, self.minScale, self.maxScale)
    end

    logger:Info("Finished adding new Scenery Part with ID: " .. self.partID)
end

return SceneryPartBuilder
