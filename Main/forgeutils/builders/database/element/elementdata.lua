local global = _G
local setmetatable = global.setmetatable
local db = require("forgeutils.internal.database.TrackedRides")
local check = require("forgeutils.check")
local logger = require("forgeutils.logger").Get("ElementData", "INFO")

--- @class forgeutils.builders.database.element.ElementData
local ElementData = {}
ElementData.__index = ElementData

-- Decrease if size EVER becomes a concern. We have more problems if that's the case.
ElementData.LastNoOrderingId = -10000000

--- Checks whether the data has errors or not
---@param elementData forgeutils.builders.data.element.ElementData
function ElementData.hasErrors(elementData)
    local issues = false
    issues = check.IsNil("elementData.type", elementData.type) or issues
    issues = check.IsNil("elementData.cost", elementData.cost) or issues
    issues = check.IsNil("elementData.disabledText", elementData.disabledText) or issues
    return issues
end

--- Adds simulation data to the database
---@param id string The ID (or name) of the element.
---@param elementData forgeutils.builders.data.element.ElementData
function ElementData.addToDb(id, elementData)
    -- Ordering addition if not provided.
    local ordering = elementData.ordering
    if ordering == nil then
        ordering = ElementData.LastNoOrderingId
        ElementData.LastNoOrderingId = ElementData.LastNoOrderingId + 1
    end

    db.ElementData__Insert(
        id,
        elementData.type,
        elementData.cost,
        elementData.disabledText,
        ordering
    )
    if elementData.label ~= nil then
        db.ElementData__Update__Label(id, ordering, elementData.label)
    end
    if elementData.icon ~= nil then
        db.ElementData__Update__Icon(id, ordering, elementData.icon)
    end
    if elementData.requiredPower ~= nil then
        db.ElementData__Update__RequiredPower(id, ordering, elementData.requiredPower)
    end
    if elementData.leadsInto ~= nil then
        db.ElementData__Update__LeadsInto(id, ordering, elementData.leadsInto)
    end
    if elementData.trackWearMultiplier ~= nil then
        db.ElementData__Update__TrackWearMultiplier(id, ordering, elementData.trackWearMultiplier)
    end
    if elementData.leadsOutOf ~= nil then
        db.ElementData__Update__LeadsOutOf(id, ordering, elementData.leadsOutOf)
    end
    if elementData.canGoUnderwater ~= nil then
        db.ElementData__Update__CanGoUnderwater(id, ordering, elementData.canGoUnderwater)
    end
    if elementData.descriptionText ~= nil then
        db.ElementData__Update__DescriptionText(id, ordering, elementData.descriptionText)
    end
    if elementData.description2Text ~= nil then
        db.ElementData__Update__Description2Text(id, ordering, elementData.description2Text)
    end
    if elementData.description3Text ~= nil then
        db.ElementData__Update__Description3Text(id, ordering, elementData.description3Text)
    end
end

return ElementData
