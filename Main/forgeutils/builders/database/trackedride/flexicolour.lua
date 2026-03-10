local global = _G
local setmetatable = global.setmetatable
local db = require("forgeutils.internal.database.TrackedRides")
local check = require("forgeutils.check")

--- @class forgeutils.builders.database.trackedride.Flexicolour
local Flexicolour = {}
Flexicolour.__index = Flexicolour

--- Checks whether the data has errors or not
---@param flexicolour forgeutils.builders.data.trackedride.Flexicolour
function Flexicolour.hasErrors(flexicolour)
    local issues = false
    issues = check.IsNil("flexicolour.semanticTag", flexicolour.semanticTag) or issues
    issues = check.IsNil("flexicolour.materialCustomizationProviderSlot", flexicolour.materialCustomizationProviderSlot) or
        issues
    return issues
end

--- Adds flexicolour data to the database
---@param id string The ID (or name) of the tracked ride.
---@param flexicolour forgeutils.builders.data.trackedride.Flexicolour
function Flexicolour.addToDb(id, flexicolour)
    db.DefaultFlexiColours__Insert(
        id,
        flexicolour.materialCustomizationProviderSlot,
        flexicolour.red,
        flexicolour.green,
        flexicolour.blue
    )
    db.DefaultFlexiColours__Update__SemanticTag(
        id,
        flexicolour.materialCustomizationProviderSlot,
        flexicolour.semanticTag
    )
end

return Flexicolour
