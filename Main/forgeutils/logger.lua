local global = _G
local api = global.api
local setmetatable = global.setmetatable

--- Logger is a standard utility used for logging in ForgeUtils.
--- Generally loggers should go near the top of the file with the requires, like so:
--- ```lua
--- -- example_filename.lua
--- local logger = require("ForgeUtils.Logger"):Get("example_filename")
--- ```
--- You can then call the logger with
--- ```lua
--- -- Prints: [INFO] example_filename: Hello World
--- logger.Info("Hello World")
--- ```
---
--- @class forgeutils.Logger
--- @field __index table
--- @field name string The name of the logger
--- @field levelOverride levels The level override for this specific logger
local Logger = {}
Logger.__index = Logger

---@enum (key) levels
Logger.LEVELS = {
    DEBUG = 1,
    INFO = 2,
    WARN = 3,
    ERROR = 4
}

--- The global default level is ERROR.
--- This allows mod developers to override this.
--- They can also do it for specific loggers as well.
--- @type levels
Logger.GLOBAL_LEVEL = "ERROR"

---Returns a Logger instance with this name.
---@param name string The name of this logger.
---@param levelOverride levels? The level override of this logger.
---@return forgeutils.Logger
function Logger.Get(name, levelOverride)
    local instance = setmetatable({}, Logger)
    instance.name = name
    instance.levelOverride = levelOverride
    return instance
end

---@private
---@param level levels The level to print at.
---@param string string The string to print to the console.
function Logger:PrintLevel(level, string)
    if self.levelOverride ~= nil then
        if Logger.LEVELS[level] < Logger.LEVELS[self.levelOverride] then
            return
        end
    else
        if Logger.LEVELS[level] < Logger.LEVELS[Logger.GLOBAL_LEVEL] then
            return
        end
    end

    api.debug.Trace("[" .. level .. "] " .. self.name .. ": " .. string)
end

---Prints to log with the level of debug.
---@param string string The string to print to the console.
---@return nil
function Logger:Debug(string)
    self:PrintLevel("DEBUG", string)
end

---Prints to log with the level of info.
---@param string string The string to print to the console.
---@return nil
function Logger:Info(string)
    self:PrintLevel("INFO", string)
end

---Prints to log with the level of warn.
---@param string string The string to print to the console.
---@return nil
function Logger:Warn(string)
    self:PrintLevel("WARN", string)
end

---Prints to log with the level of error.
---@param string string The string to print to the console.
---@return nil
function Logger:Error(string)
    self:PrintLevel("ERROR", string)
end

---Helper that checks if `name` is nil, prints an error
---if it is, and returns whether it was nil or not.
---@param object any The object to check.
---@param name string The name of the object.
---@return boolean wasNil Whether the object was nil.
function Logger:IsNil(object, name)
    if object == nil then
        self:PrintLevel("ERROR", name .. " was nil!")
        return true
    end
    return false
end

return Logger
