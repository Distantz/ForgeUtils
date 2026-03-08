local global = _G
local setmetatable = global.setmetatable
local db = require("forgeutils.internal.database.TrackedRides")
local check = require("forgeutils.check")

--- @class forgeutils.builders.database.element.ElementData
local ElementData = {}
ElementData.__index = ElementData

--- Checks whether the data has errors or not
---@param elementData forgeutils.builders.data.element.ElementData
function ElementData.hasErrors(elementData)
    local issues = false
    issues = check.IsNil("elementData.type", elementData.type) or issues
    issues = check.IsNil("elementData.cost", elementData.cost) or issues
    issues = check.IsNil("elementData.disabledText", elementData.disabledText) or issues
    issues = check.IsNil("elementData.ordering", elementData.ordering) or issues
    return issues
end

--- Adds simulation data to the database
---@param id string The ID (or name) of the element.
---@param elementData forgeutils.builders.data.element.ElementData
function ElementData.addToDb(id, elementData)
    db.ElementData__Insert(
        id,
        elementData.type,
        elementData.cost,
        elementData.disabledText,
        elementData.ordering
    )
    if elementData.label ~= nil then
        db.ElementData__Update__Label(id, elementData.ordering, elementData.label)
    end
    if elementData.icon ~= nil then
        db.ElementData__Update__Icon(id, elementData.ordering, elementData.icon)
    end
    if elementData.requiredPower ~= nil then
        db.ElementData__Update__RequiredPower(id, elementData.ordering, elementData.requiredPower)
    end
    if elementData.leadsInto ~= nil then
        db.ElementData__Update__LeadsInto(id, elementData.ordering, elementData.leadsInto)
    end
    if elementData.trackWearMultiplier ~= nil then
        db.ElementData__Update__TrackWearMultiplier(id, elementData.ordering, elementData.trackWearMultiplier)
    end
    if elementData.leadsOutOf ~= nil then
        db.ElementData__Update__LeadsOutOf(id, elementData.ordering, elementData.leadsOutOf)
    end
    if elementData.canGoUnderwater ~= nil then
        db.ElementData__Update__CanGoUnderwater(id, elementData.ordering, elementData.canGoUnderwater)
    end
    if elementData.descriptionText ~= nil then
        db.ElementData__Update__DescriptionText(id, elementData.ordering, elementData.descriptionText)
    end
    if elementData.description2Text ~= nil then
        db.ElementData__Update__Description2Text(id, elementData.ordering, elementData.description2Text)
    end
    if elementData.description3Text ~= nil then
        db.ElementData__Update__Description3Text(id, elementData.ordering, elementData.description3Text)
    end
end

return ElementData
