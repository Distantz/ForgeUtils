-- This file is responsible of managing the data inside the TestCustomData.fdb and providing it to the game
local global = _G
local api = global.api
local pairs = pairs
local ipairs = ipairs
local type = type
local table = global.table
local tostring = global.tostring
local GameDatabase = require("Database.GameDatabase")
local ForgeUtilsDatabaseManager = {}

--
-- Initialization functions. These functions are called during the initialization process only
--

-- This method will be called when our manager gets initialized, early in the game launch after
-- all data has been merged for all the Content Packs. This method allows our manager to know
-- the database is getting initialized.
ForgeUtilsDatabaseManager.Init = function() end

-- This table contains the list of functions our module wants to add to the Game Database.
ForgeUtilsDatabaseManager.tDatabaseFunctions = {}

-- This method will be called when our manager gets initialized to inject custom functions
-- in the Game Database. These functions will be available for the rest of the game Lua modules.
ForgeUtilsDatabaseManager.AddDatabaseFunctions = function(_tDatabaseFunctions)
	for sMethod, fnMethod in pairs(ForgeUtilsDatabaseManager.tDatabaseFunctions) do
		_tDatabaseFunctions[sMethod] = fnMethod
	end
end

-- This method will be called after our manager gets initialized, all Database and Player methods have
-- been added to the main Game Databases.
ForgeUtilsDatabaseManager.Setup = function() end

--
-- Database active functions. These functions are optional and can be called while our Database Manager is active.
--
-- Nothing included yet.

--- Exceutes any Prepared Statement query for database modifications.
---@param _sDatabase string
---@param _sQueryName string
---@param ...args
---@return any
ForgeUtilsDatabaseManager.ExecuteQuery = function(_sDatabase, _sQueryName, ...)
	local result = nil
	GameDatabase.SetReadOnly(_sDatabase, false)
	local tArgs = table.pack(...)

	local cPSInstance = GameDatabase.GetPreparedStatementInstance(_sDatabase, _sQueryName)
	if cPSInstance ~= nil then
		--dbgTrace("binding to: " .. _sInstance)
		if #tArgs > 0 then
			for i, j in ipairs(tArgs) do
				--dbgTrace("binding parameter: " .. j)
				GameDatabase.BindParameter(cPSInstance, i, j)
			end
		end
		GameDatabase.BindComplete(cPSInstance)
		GameDatabase.Step(cPSInstance)

		local tRows = GameDatabase.GetAllResults(cPSInstance, false)
		result = tRows or nil
	else
		dbgTrace("WARNING: COULD NOT GET INSTANCE: " .. _sInstance .. " IN: " .. _sPSCollection)
	end
	GameDatabase.SetReadOnly(_sDatabase, true)
	return result
end

--
-- De-initialization functions. These functions are called during the shutdown or restart processes only
--

-- This method will be called when the Game Database is shutting down for re-initialization. It is a soft Re-Init
-- of the database. We don't need to close or free resources if we don't want, but remember we have them open when
-- the Game Database calls our :Init() function again.
ForgeUtilsDatabaseManager.ShutdownForReInit = function() end

-- This method will be called when the Game Database is shutting down and we need to close any
-- or free any resource we have open. The module will be unloaded after.
ForgeUtilsDatabaseManager.Shutdown = function() end

