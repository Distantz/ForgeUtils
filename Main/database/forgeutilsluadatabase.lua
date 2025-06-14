-- Remove weird table issue
---@diagnostic disable: param-type-mismatch
local global = _G
local table = global.table
local require = require

-- Setup logger
local loggerSetup = require("ForgeUtils.Logger")
local logger = loggerSetup.Get("ForgeUtilsLuaDatabase")

logger:Info("Starting ForgeUtils...")

local _ForgeUtilsLuaDatabase = {}

_ForgeUtilsLuaDatabase.AddContentToCall = function(_tContentToCall)
    -- We tell the Database Manager to load our custom Database Manager by its Lua name
    -- You can add as many as you want, ideally separating each manager for each content type you add
    table.insert(_tContentToCall, require("ForgeUtils.Internal.Database.Scenery"))
end

return _ForgeUtilsLuaDatabase
