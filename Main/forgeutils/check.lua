local global = _G
local type = global.type
local logger = require("forgeutils.logger").Get("Validation")

---@class forgeutils.Check
local Check = {}

--- Helper function to validate whether a value is a type.
--- An error will be thrown if not.
--- @param valueName string The value name. Used in print outs.
--- @param value any The value to validate.
--- @param valueType type The type to ensure.
--- @return boolean correct Whether the check was true.
function Check.ValueNotOfType(valueName, value, valueType)
    local res = type(value) ~= valueType
    if res then
        logger:Error("Value \"" .. valueName .. "\" was not of expected type \"" .. valueType .. "\".")
    end
    return res
end

--- Helper function to validate whether a value is nil.
--- @param valueName string The value name. Used in print outs.
--- @param value any The value to validate.
--- @return boolean correct Whether the check was true.
function Check.ValueNil(valueName, value)
    local res = value == nil
    if res then
        logger:Error("Value \"" .. valueName .. "\" was nil.")
    end
    return res
end

return Check
