local global = _G
local table = global.table
local require = require
local ForgeUtilsLuaDatabase = module(...)

ForgeUtilsLuaDatabase.AddContentToCall = function(_tContentToCall)
    -- We tell the Database Manager to load our custom Database Manager by its Lua name
    -- You can add as many as you want, ideally separating each manager for each content type you add
    -- table.insert(_tContentToCall, require("Database.ExampleContentDatabaseManager"))
end