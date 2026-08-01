local global = _G
---@diagnostic disable-next-line: undefined-field
local api = global.api
local setmetatable = global.setmetatable
local ipairs = global.ipairs
local type = global.type
local tostring = global.tostring
local tablePlus = require("Common.tableplus")

--- Logger is a standard utility used for logging in ForgeUtils.
--- Generally loggers should go near the top of the file with the requires.
--- You don't need to include the `levelOverride` (`"INFO"` argument below) argument on the `Get` method. If you don't, it will use `Logger.GLOBAL_LEVEL`.
--- ```lua
--- -- example_filename.lua
--- local logger = require("ForgeUtils.Logger").Get("example_filename", "INFO")
--- ```
---
--- You can then call the logger with
--- ```lua
--- -- Prints: [INFO] example_filename: Hello World
--- logger:Info("Hello World")
--- ```
--- You can also pass any number of values to the logger and it will attempt to convert it into a readable string.
--- This includes tables, which will be output as a readable lua value using `Common.tablePlus`.
--- ```lua
--- -- Prints: [INFO] example_filename: The answer to 2 + 1 is 3
--- logger:Info("The answer to ", 2, " + ", 1, " is ", 2 + 1)
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
    DEBUG_QUERY = 1,
    DEBUG = 2,
    INFO = 3,
    WARN = 4,
    ERROR = 5
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

---Concatenates an array of values into a string representation.
---@private
---@param args any[]
---@return string
function Logger:ToConcatString(args)
    local str = ""

    for _, arg in ipairs(args) do
        local argType = type(arg)
        local out = ""
        if argType == "nil" then
            out = argType
        elseif argType == "table" then
            out = tablePlus.tostring(arg, nil, nil, nil, false) -- not multiline
        else
            out = tostring(arg)
        end
        str = str .. out
    end
    return str
end

---@private
---@param level levels The level to print at.
---@vararg any Values to turn into strings and print.
---@return nil
function Logger:PrintLevel(level, ...)
    if self.levelOverride ~= nil then
        if Logger.LEVELS[level] < Logger.LEVELS[self.levelOverride] then
            return
        end
    else
        if Logger.LEVELS[level] < Logger.LEVELS[Logger.GLOBAL_LEVEL] then
            return
        end
    end

    api.debug.Trace("[" .. level .. "] " .. self.name .. ": " .. self:ToConcatString({ ... }))
end

---Prints to log with the level of debug query.
---@vararg any Values to turn into strings and print.
---@return nil
function Logger:DebugQuery(...)
    self:PrintLevel("DEBUG_QUERY", ...)
end

---Prints to log with the level of debug.
---@vararg any Values to turn into strings and print.
---@return nil
function Logger:Debug(...)
    self:PrintLevel("DEBUG", ...)
end

---Prints to log with the level of info.
---@vararg any Values to turn into strings and print.
---@return nil
function Logger:Info(...)
    self:PrintLevel("INFO", ...)
end

---Prints to log with the level of warn.
---@vararg any Values to turn into strings and print.
---@return nil
function Logger:Warn(...)
    self:PrintLevel("WARN", ...)
end

---Prints to log with the level of error.
---@vararg any Values to turn into strings and print.
---@return nil
function Logger:Error(...)
    self:PrintLevel("ERROR", ...)
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
