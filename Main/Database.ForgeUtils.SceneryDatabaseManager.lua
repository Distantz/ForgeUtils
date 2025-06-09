-- This file is responsible of managing the data inside the TestCustomData.fdb and providing it to the game
local global = _G
local api = global.api
local pairs = pairs
local ipairs = ipairs
local type = type
local table = global.table
local tostring = global.tostring
local GameDatabase = require("Database.GameDatabase")

---@class SceneryDatabaseManager
local SceneryDatabaseManager = {}

--
-- Initialization functions. These functions are called during the initialization process only
--

-- This method will be called when our manager gets initialized, early in the game launch after
-- all data has been merged for all the Content Packs. This method allows our manager to know
-- the database is getting initialized.
SceneryDatabaseManager.Init = function()

end

SceneryDatabaseManager.tPreparedStatements = {
    ModularScenery = "ForgeUtils_Scenery"
}

SceneryDatabaseManager.BindPreparedStatements = function()
    api.debug.Trace("SceneryDatabaseManager.BindPreparedStatements()")
    local database = api.database
    local bSuccess = 0

    api.debug.Trace("Starting bind")
    for k, ps in pairs(SceneryDatabaseManager.tPreparedStatements) do

        api.debug.Trace("Write: " .. k)
        database.SetReadOnly(k, false)

        api.debug.Trace("Bind: " .. k)
        bSuccess = database.BindPreparedStatementCollection(k, ps)
        if bSuccess == 0 then
            api.debug.Trace("Warning: Prepared Statement " .. ps .. " can not be bound to table " .. k)
            return nil
        end

        api.debug.Trace("Readonly: " .. k)
        database.SetReadOnly(k, true)
    end
end


-- This table contains the list of functions our module wants to add to the Game Database.
SceneryDatabaseManager.tDatabaseFunctions = {

    Forge_AddSceneryOwnership = function(UniqueKey, ContentPack)
        return SceneryDatabaseManager.Forge_AddSceneryOwnership(UniqueKey, ContentPack)
    end,

    Forge_AddModularSceneryPart = function(SceneryPartName, PrefabName, DataPrefabName, ContentPack, UGCID, BoxXSize, BoxYSize, BoxZSize)
        return SceneryDatabaseManager.Forge_AddModularSceneryPart(SceneryPartName, PrefabName, DataPrefabName, ContentPack, UGCID, BoxXSize, BoxYSize, BoxZSize)
    end,

    Forge_AddSceneryUIData = function(SceneryPartName, LabelTextSymbol, DescriptionTextSymbol, Icon, ReleaseGroup)
        return SceneryDatabaseManager.Forge_AddSceneryUIData(SceneryPartName, LabelTextSymbol, DescriptionTextSymbol, Icon, ReleaseGroup)
    end,

    Forge_AddScenerySimulationData = function(SceneryPartName, BuildCost, HourlyRunningCost, ResearchPack, RequiresUnlockInSandbox)
        return SceneryDatabaseManager.Forge_AddScenerySimulationData(SceneryPartName,BuildCost,HourlyRunningCost,ResearchPack,RequiresUnlockInSandbox)
    end,

    Forge_AddSceneryTag = function(SceneryPartName, Tag)
        return SceneryDatabaseManager.Forge_AddSceneryTag(SceneryPartName, Tag)
    end,

}

-- This method will be called when our manager gets initialized to inject custom functions 
-- in the Game Database. These functions will be available for the rest of the game Lua modules.
SceneryDatabaseManager.AddDatabaseFunctions = function(_tDatabaseFunctions)
    api.debug.Trace("AddDatabaseFunctions called for FORGE")
    for sMethod,fnMethod in pairs(SceneryDatabaseManager.tDatabaseFunctions) do
        _tDatabaseFunctions[sMethod] = fnMethod
    end
end

-- This method will be called after our manager gets initialized, all Database and Player methods have 
-- been added to the main Game Databases.
SceneryDatabaseManager.PreBuildPrefabs = function()
    SceneryDatabaseManager.BindPreparedStatements()
end

--
-- Database active functions. These functions are optional and can be called while our Database Manager is active.
--

--- Adds needed ownership for a Scenery part
---@param UniqueKey string
---@param ContentPack nil|string
SceneryDatabaseManager.Forge_AddSceneryOwnership = function(UniqueKey, ContentPack)
    local database = api.database

    database.SetReadOnly("ModularScenery_Ownership", false)

    -- Default to basegame
    if ContentPack == nil then
        ContentPack = "BaseGame"
    end

    local cPSInstance = database.GetPreparedStatementInstance("ModularScenery_Ownership", "ForgeAddSceneryOwnership")
    if cPSInstance ~= nil then
        database.BindParameter(cPSInstance, 1, UniqueKey)
        database.BindParameter(cPSInstance, 2, ContentPack)
        database.BindComplete(cPSInstance)
        database.Step(cPSInstance)
        local tRows = database.GetAllResults(cPSInstance, false)
        api.debug.Trace("RESULT: " .. tostring(tRows[0] or nil))
    else
        api.debug.Trace("Couldn't get cPSInstance")
    end

    database.SetReadOnly("ModularScenery_Ownership", true)
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
SceneryDatabaseManager.Forge_AddModularSceneryPart = function (SceneryPartName, PrefabName, DataPrefabName, ContentPack, UGCID, BoxXSize, BoxYSize, BoxZSize)
    local database = api.database

    -- Default to basegame
    if ContentPack == nil then
        ContentPack = "BaseGame"
    end

    if UGCID == nil then
        UGCID = "NULL"
    end

    database.SetReadOnly("ModularScenery", false)

    local cPSInstance = database.GetPreparedStatementInstance("ModularScenery", "ForgeAddModularSceneryPart")
    if cPSInstance ~= nil then
        database.BindParameter(cPSInstance, 1, SceneryPartName)
        database.BindParameter(cPSInstance, 2, PrefabName)
        database.BindParameter(cPSInstance, 3, DataPrefabName)
        database.BindParameter(cPSInstance, 4, ContentPack)
        database.BindParameter(cPSInstance, 5, UGCID)
        database.BindParameter(cPSInstance, 6, BoxXSize)
        database.BindParameter(cPSInstance, 7, BoxYSize)
        database.BindParameter(cPSInstance, 8, BoxZSize)
        database.BindComplete(cPSInstance)

        database.Step(cPSInstance)
        database.GetAllResults(cPSInstance, false)
    else
        api.debug.Trace("Couldn't get cPSInstance")
    end

    database.SetReadOnly("ModularScenery", true)


end

--- Adds UI data for a Scenery Part
---@param SceneryPartName string
---@param LabelTextSymbol string
---@param DescriptionTextSymbol string
---@param Icon string|nil
---@param ReleaseGroup integer|nil
---@return nil
SceneryDatabaseManager.Forge_AddSceneryUIData = function(SceneryPartName, LabelTextSymbol, DescriptionTextSymbol, Icon, ReleaseGroup)
    local result = nil
    local database = api.database

    -- Default to basegame
    if ReleaseGroup == nil then
        ReleaseGroup = 0
    end

    if Icon == nil then
        Icon = "NULL"
    end

    database.SetReadOnly("ModularScenery", false)

    -- We called our database 'ExampleTestData' in the Databases.ExampleContentPack.Lua file
    -- We created a Prepared Statement called 'GetAllIdFromTestTable1'
    local cPSInstance = database.GetPreparedStatementInstance("ModularScenery", "ForgeAddSceneryUIData")
    if cPSInstance ~= nil then
        database.BindParameter(cPSInstance, 1, SceneryPartName)
        database.BindParameter(cPSInstance, 2, LabelTextSymbol)
        database.BindParameter(cPSInstance, 3, DescriptionTextSymbol)
        database.BindParameter(cPSInstance, 4, Icon)
        database.BindParameter(cPSInstance, 5, ReleaseGroup)
        database.BindComplete(cPSInstance)
        database.Step(cPSInstance)
        database.GetAllResults(cPSInstance, false)
    else
        api.debug.Trace("Couldn't get cPSInstance")
    end

    database.SetReadOnly("ModularScenery", true)
end

--- Adds simulation data for a Scenery Part
---@param SceneryPartName string
---@param BuildCost integer|nil
---@param HourlyRunningCost nil|integer
---@param ResearchPack nil
---@param RequiresUnlockInSandbox nil|integer
SceneryDatabaseManager.Forge_AddScenerySimulationData = function(SceneryPartName, BuildCost, HourlyRunningCost, ResearchPack, RequiresUnlockInSandbox)
    local result = nil
    local database = api.database

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

    database.SetReadOnly("ModularScenery", false)

    -- We called our database 'ExampleTestData' in the Databases.ExampleContentPack.Lua file
    -- We created a Prepared Statement called 'GetAllIdFromTestTable1'
    local cPSInstance = database.GetPreparedStatementInstance("ModularScenery", "ForgeAddScenerySimulationData")
    if cPSInstance ~= nil then
        database.BindParameter(cPSInstance, 1, SceneryPartName)
        database.BindParameter(cPSInstance, 2, BuildCost)
        database.BindParameter(cPSInstance, 3, HourlyRunningCost)
        database.BindParameter(cPSInstance, 4, ResearchPack)
        database.BindParameter(cPSInstance, 5, RequiresUnlockInSandbox)
        database.BindComplete(cPSInstance)
        database.Step(cPSInstance)
        database.GetAllResults(cPSInstance, false)
    else
        api.debug.Trace("Couldn't get cPSInstance")
    end

    database.SetReadOnly("ModularScenery", true)
end

--- Adds a metatag for a Scenery Part
---@param SceneryPartName string
---@param Tag string
SceneryDatabaseManager.Forge_AddSceneryTag = function(SceneryPartName, Tag)
    local result = nil
    local database = api.database

    database.SetReadOnly("ModularScenery", false)

    -- We called our database 'ExampleTestData' in the Databases.ExampleContentPack.Lua file
    -- We created a Prepared Statement called 'GetAllIdFromTestTable1'
    local cPSInstance = database.GetPreparedStatementInstance("ModularScenery", "ForgeAddSceneryTag")
    if cPSInstance ~= nil then
        database.BindParameter(cPSInstance, 1, SceneryPartName)
        database.BindParameter(cPSInstance, 2, Tag)
        database.BindComplete(cPSInstance)
        database.Step(cPSInstance)
        database.GetAllResults(cPSInstance, false)
    else
        api.debug.Trace("Couldn't get cPSInstance")
    end

    database.SetReadOnly("ModularScenery", true)
end

--
-- De-initialization functions. These functions are called during the shutdown or restart processes only
--

-- This method will be called when the Game Database is shutting down for re-initialization. It is a soft Re-Init
-- of the database. We don't need to close or free resources if we don't want, but remember we have them open when
-- the Game Database calls our :Init() function again.
SceneryDatabaseManager.ShutdownForReInit = function()

end

-- This method will be called when the Game Database is shutting down and we need to close any 
-- or free any resource we have open. The module will be unloaded after.
SceneryDatabaseManager.Shutdown = function()

end