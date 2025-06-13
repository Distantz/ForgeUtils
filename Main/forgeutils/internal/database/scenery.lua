-- This file is responsible of managing the data inside the TestCustomData.fdb and providing it to the game
local global = _G
local api = global.api
local pairs = pairs
local ipairs = ipairs
local type = type
local table = global.table
local tostring = global.tostring
local GameDatabase = require("Database.GameDatabase")
local DatabaseUtils = require("ForgeUtils.Internal.Database.DatabaseUtils")

local logger = require("ForgeUtils.Logger").Get("SceneryDatabaseManager")

---@class forgeutils.internal.database.SceneryDatabaseManager
local SceneryDatabaseManager = {}

---@private
--- This method will be called when our manager gets initialized, early in the game launch after
--- all data has been merged for all the Content Packs. This method allows our manager to know
--- the database is getting initialized.
SceneryDatabaseManager.Init = function()
    SceneryDatabaseManager.BindPreparedStatements()
end

SceneryDatabaseManager.tPreparedStatements = {
    ModularScenery = "ForgeUtils_Scenery"
}

---@private
function SceneryDatabaseManager.BindPreparedStatements()
    logger:Debug("SceneryDatabaseManager.BindPreparedStatements()")
    local database = api.database
    local bSuccess = 0

    logger:Debug("Starting bind")
    for k, ps in pairs(SceneryDatabaseManager.tPreparedStatements) do
        logger:Debug("Write: " .. k)
        database.SetReadOnly(k, false)

        logger:Debug("Bind: " .. k)
        bSuccess = database.BindPreparedStatementCollection(k, ps)
        if bSuccess == 0 then
            logger:Warn("Warning: Prepared Statement " .. ps .. " can not be bound to table " .. k)
            return nil
        end

        logger:Debug("Readonly: " .. k)
        database.SetReadOnly(k, true)
    end
end

-- This table contains the list of functions our module wants to add to the Game Database.
SceneryDatabaseManager.tDatabaseFunctions = {

    Forge_AddSceneryOwnership = function(UniqueKey, ContentPack)
        return SceneryDatabaseManager.Forge_AddSceneryOwnership(UniqueKey, ContentPack)
    end,

    Forge_AddModularSceneryPart = function(SceneryPartName, PrefabName, DataPrefabName, ContentPack, UGCID, BoxXSize,
                                           BoxYSize, BoxZSize)
        return SceneryDatabaseManager.Forge_AddModularSceneryPart(SceneryPartName, PrefabName, DataPrefabName,
            ContentPack, UGCID, BoxXSize, BoxYSize, BoxZSize)
    end,

    Forge_AddSceneryUIData = function(SceneryPartName, LabelTextSymbol, DescriptionTextSymbol, Icon, ReleaseGroup)
        return SceneryDatabaseManager.Forge_AddSceneryUIData(SceneryPartName, LabelTextSymbol, DescriptionTextSymbol,
            Icon, ReleaseGroup)
    end,

    Forge_AddScenerySimulationData = function(SceneryPartName, BuildCost, HourlyRunningCost, ResearchPack,
                                              RequiresUnlockInSandbox)
        return SceneryDatabaseManager.Forge_AddScenerySimulationData(SceneryPartName, BuildCost, HourlyRunningCost,
            ResearchPack, RequiresUnlockInSandbox)
    end,

    Forge_AddSceneryTag = function(SceneryPartName, Tag)
        return SceneryDatabaseManager.Forge_AddSceneryTag(SceneryPartName, Tag)
    end,

}

---@private
--- This method will be called when our manager gets initialized to inject custom functions
--- in the Game Database. These functions will be available for the rest of the game Lua modules.
function SceneryDatabaseManager.AddDatabaseFunctions(_tDatabaseFunctions)
    logger:Debug("AddDatabaseFunctions called for FORGE")
    for sMethod, fnMethod in pairs(SceneryDatabaseManager.tDatabaseFunctions) do
        _tDatabaseFunctions[sMethod] = fnMethod
    end
end

--- Adds needed ownership for a Scenery part
---@param UniqueKey string
---@param ContentPack nil|string
SceneryDatabaseManager.Forge_AddSceneryOwnership = function(UniqueKey, ContentPack)
    -- Default to basegame
    if ContentPack == nil then
        ContentPack = "BaseGame"
    end

    DatabaseUtils.ExecuteQuery("ModularScenery_Ownership", "ForgeAddSceneryOwnership", UniqueKey, ContentPack)
end

--- Adds needed data for a Scenery Part
---@param SceneryPartName string
---@param PrefabName string
---@param DataPrefabName string|nil
---@param ContentPack string|nil
---@param UGCID string|nil
---@param BoxXSize number
---@param BoxYSize number
---@param BoxZSize number
SceneryDatabaseManager.Forge_AddModularSceneryPart = function(SceneryPartName, PrefabName, DataPrefabName, ContentPack,
                                                              UGCID, BoxXSize, BoxYSize, BoxZSize)
    -- Default to basegame
    if ContentPack == nil then
        ContentPack = "BaseGame"
    end

    if UGCID == nil then
        UGCID = "NULL"
    end

    DatabaseUtils.ExecuteQuery("ModularScenery", "ForgeAddModularSceneryPart", SceneryPartName, PrefabName,
        DataPrefabName, ContentPack, UGCID, BoxXSize, BoxYSize, BoxZSize)
end
--- Adds UI data for a Scenery Part
---@param SceneryPartName string
---@param LabelTextSymbol string
---@param DescriptionTextSymbol string
---@param Icon string|nil
---@param ReleaseGroup integer|nil
---@return nil
SceneryDatabaseManager.Forge_AddSceneryUIData = function(SceneryPartName, LabelTextSymbol, DescriptionTextSymbol, Icon,
                                                         ReleaseGroup)
    -- Default to basegame
    if ReleaseGroup == nil then
        ReleaseGroup = 0
    end

    if Icon == nil then
        Icon = "NULL"
    end

    DatabaseUtils.ExecuteQuery("ModularScenery", "ForgeAddSceneryUIData", SceneryPartName, LabelTextSymbol,
        DescriptionTextSymbol, Icon, ReleaseGroup)
end

--- Adds simulation data for a Scenery Part
---@param SceneryPartName string
---@param BuildCost integer|nil
---@param HourlyRunningCost nil|integer
---@param ResearchPack nil
---@param RequiresUnlockInSandbox nil|integer
SceneryDatabaseManager.Forge_AddScenerySimulationData = function(SceneryPartName, BuildCost, HourlyRunningCost,
                                                                 ResearchPack, RequiresUnlockInSandbox)
    -- Defaults
    if BuildCost == nil then
        BuildCost = 0
    end

    if HourlyRunningCost == nil then
        HourlyRunningCost = 0
    end

    if RequiresUnlockInSandbox == nil then
        RequiresUnlockInSandbox = 0
    end

    DatabaseUtils.ExecuteQuery("ModularScenery", "ForgeAddScenerySimulationData", SceneryPartName, BuildCost,
        HourlyRunningCost, ResearchPack, RequiresUnlockInSandbox)
end

--- Adds a metatag for a Scenery Part
---@param SceneryPartName string
---@param Tag string
SceneryDatabaseManager.Forge_AddSceneryTag = function(SceneryPartName, Tag)
    DatabaseUtils.ExecuteQuery("ModularScenery", "ForgeAddSceneryTag", SceneryPartName, Tag)
end


---@private
--- This method will be called when the Game Database is shutting down for re-initialization. It is a soft Re-Init
--- of the database. We don't need to close or free resources if we don't want, but remember we have them open when
--- the Game Database calls our :Init() function again.
SceneryDatabaseManager.ShutdownForReInit = function() end

---@private
--- This method will be called when the Game Database is shutting down and we need to close any
--- or free any resource we have open. The module will be unloaded after.
SceneryDatabaseManager.Shutdown = function() end

return SceneryDatabaseManager
