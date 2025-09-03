-- This file is responsible of managing the data inside the TestCustomData.fdb and providing it to the game
local global = _G
local api = global.api
local type = global.type
local table = global.table
local tostring = global.tostring
local database = api.database
local trainutils = require("forgeutils.prefabs.train")

local logger = require("forgeutils.logger").Get("DatabaseUtils")

---@class forgeutils.internal.database.DatabaseUtils
local DatabaseUtils = {}

--- Exceutes any Prepared Statement query for database modifications.
---@param databaseName string The database to execute the query on.
---@param queryName string The SQL PCStatement to use to query.
---@param args any[] Parameters to pass to the SQL query.
---@param numArgs integer|nil The number of parameters to pass. Leave nil if you want to use #args.
---@return table|nil Query results
function DatabaseUtils.ExecuteQuery(databaseName, queryName, args, numArgs)
    local num = numArgs ~= nil and numArgs or #args

    logger:DebugQuery("Executing query on " .. databaseName .. ": " .. queryName)
    logger:DebugQuery("Args:")
    if num > 0 then
        for i = 1, num do
            local v = args[i]
            logger:DebugQuery(" - [" .. i .. "] = " .. tostring(v))
        end
    end

    local result = nil
    database.SetReadOnly(databaseName, false)
    local cPSInstance = database.GetPreparedStatementInstance(databaseName, queryName)
    if cPSInstance ~= nil then
        logger:DebugQuery("[" .. queryName .. "] SQL Query start")
        if num > 0 then
            for i = 1, num do
                local v = args[i]
                logger:DebugQuery(" - [" .. i .. "] = " .. tostring(v))

                -- Don't bind if nil, that allows us to have NULL
                if v ~= nil then
                    -- one more easy conversion. if a boolean, convert to an int.
                    if type(v) == "boolean" then
                        v = v and 1 or 0
                    end

                    database.BindParameter(cPSInstance, i, v)
                end
            end
        end
        database.BindComplete(cPSInstance)
        database.Step(cPSInstance)

        local tRows = database.GetAllResults(cPSInstance, false)
        trainutils.PrintPrefab(tRows, 2)
        logger:DebugQuery("[" .. queryName .. "] SQL Query finished with result: " .. tostring(table))
        result = tRows or nil
    else
        logger:Error("[" .. queryName .. "] SQL Query failed")
    end
    database.SetReadOnly(databaseName, true)
    return result
end

---Binds a prepared statement to a database
---@param databaseName string
---@param pscollectionName string
---@return boolean result
function DatabaseUtils.BindPreparedStatement(databaseName, pscollectionName)
    logger:DebugQuery("BindPreparedStatements()")
    local bSuccess = false

    database.SetReadOnly(databaseName, false)
    logger:DebugQuery("Binding " .. pscollectionName .. ".pscollection to " .. databaseName)
    bSuccess = database.BindPreparedStatementCollection(databaseName, pscollectionName)
    database.SetReadOnly(databaseName, true)

    if not bSuccess then
        logger:Warn("Warning: Prepared Statement " .. pscollectionName .. " can not be bound to table " .. databaseName)
    else
        logger:DebugQuery("Binding succeeded")
    end

    return bSuccess
end

return DatabaseUtils
