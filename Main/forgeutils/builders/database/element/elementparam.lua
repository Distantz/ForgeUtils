local global = _G
local setmetatable = global.setmetatable
local db = require("forgeutils.internal.database.TrackedRides")
local check = require("forgeutils.check")

--- @class forgeutils.builders.database.element.ElementParam
local ElementParam = {}
ElementParam.__index = ElementParam

--- Checks whether the data has errors or not
---@param elementParam forgeutils.builders.data.element.ElementParam
function ElementParam.hasErrors(elementParam)
    local issues = false
    issues = check.IsNil("elementParam.param", elementParam.param) or issues
    issues = check.IsNil("elementParam.min", elementParam.min) or issues
    issues = check.IsNil("elementParam.max", elementParam.max) or issues
    issues = check.IsNil("elementParam.initial", elementParam.initial) or issues
    issues = check.IsNil("elementParam.step", elementParam.step) or issues
    return issues
end

--- Adds simulation data to the database
---@param id string The ID (or name) of the element.
---@param elementParam forgeutils.builders.data.element.ElementParam
function ElementParam.addToDb(id, elementParam)
    db.ElementParams__Insert(
        id,
        elementParam.param,
        elementParam.min,
        elementParam.max,
        elementParam.initial,
        elementParam.step
    )
    if elementParam.stepIsRelativeToMin ~= nil then
        db.ElementParams__Update__StepIsRelativeToMin(id, elementParam.param, elementParam.stepIsRelativeToMin)
    end
    if elementParam.labelOverride ~= nil then
        db.ElementParams__Update__LabelOverride(id, elementParam.param, elementParam.labelOverride)
    end
    if elementParam.valueLabelSetName ~= nil then
        db.ElementParams__Update__ValueLabelSetName(id, elementParam.param, elementParam.valueLabelSetName)
    end
end

return ElementParam
