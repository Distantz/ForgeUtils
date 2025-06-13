-- This file is responsible of managing the data inside the TestCustomData.fdb and providing it to the game
local global = _G
local api = global.api
local pairs = pairs
local ipairs = ipairs
local type = type
local table = global.table
local tostring = global.tostring
local database = api.database

local logger = require("forgeutils.logger").Get("DatabaseUtils")

---@class forgeutils.internal.database.DatabaseUtils
local DatabaseUtils = {}

--- Exceutes any Prepared Statement query for database modifications.
---@param databaseName string The database to execute the query on
---@param queryName string The SQL PCStatement to use to query
---@param ... any Parameters to pass to the SQL query
---@return table|nil Query results
DatabaseUtils.ExecuteQuery = function(databaseName, queryName, ...)
    logger:Info("Executing query on " .. databaseName .. ": " .. queryName)

    local args = { ... }
    local result = nil

    database.SetReadOnly(databaseName, false)
    local cPSInstance = database.GetPreparedStatementInstance(databaseName, queryName)
    if cPSInstance ~= nil then
        logger:Info("[" .. cPSInstance .. "] SQL Query start")
        if #args > 0 then
            for i, v in ipairs(args) do
                logger:Info(" - [" .. i .. "] = " .. tostring(v))
                database.BindParameter(cPSInstance, i, v)
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
    database.SetReadOnly(databaseName, true)
    return result
end

return DatabaseUtils
