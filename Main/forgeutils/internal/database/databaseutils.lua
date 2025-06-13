-- This file is responsible of managing the data inside the TestCustomData.fdb and providing it to the game
local global = _G
local api = global.api
local pairs = pairs
local ipairs = ipairs
local type = type
local table = global.table
local tostring = global.tostring
local GameDatabase = require("Database.GameDatabase")
local database = api.database

local logger = require("ForgeUtils.Logger").Get("DatabaseUtils")

---@class forgeutils.internal.database.DatabaseUtils
local DatabaseUtils = {}

--- Exceutes any Prepared Statement query for database modifications.
---@param _sDatabase string The database to execute the query on
---@param _sQueryName string The SQL PCStatement to use to query
---@param ... any Parameters to pass to the SQL query
---@return table|nil Query results
DatabaseUtils.ExecuteQuery = function(_sDatabase, _sQueryName, ...)
    local result = nil
    database.SetReadOnly(_sDatabase, false)
    local tArgs = table.pack(...)

    local cPSInstance = database.GetPreparedStatementInstance(_sDatabase, _sQueryName)
    if cPSInstance ~= nil then
        logger:Info("[" .. cPSInstance .. "] SQL Query start")
        if #tArgs > 0 then
            for i, j in ipairs(tArgs) do
                logger:Info(" - [" .. i .. "] = " .. tostring(j))
                database.BindParameter(cPSInstance, i, j)
            end
        end
        database.BindComplete(cPSInstance)
        database.Step(cPSInstance)

        local tRows = database.GetAllResults(cPSInstance, false)
        logger:Info("[" .. cPSInstance .. "] SQL Query finished")
        result = tRows or nil
    else
        logger:Error("[" .. cPSInstance .. "] SQL Query failed")
    end
    database.SetReadOnly(_sDatabase, true)
    return result
end

return DatabaseUtils
