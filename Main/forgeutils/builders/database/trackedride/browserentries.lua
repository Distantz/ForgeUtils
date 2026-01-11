local global = _G
local setmetatable = global.setmetatable
local db = require("forgeutils.internal.database.TrackedRides")

--- @class forgeutils.builders.database.trackedride.BrowserEntries
local BrowserEntries = {}
BrowserEntries.__index = BrowserEntries

--- Adds a browser entry to the database
---@param rideId string The ID (or name) of the tracked ride.
---@param browserEntryData forgeutils.builders.data.trackedride.BrowserEntry
function BrowserEntries.addToDb(rideId, browserEntryData)
    db.BrowserEntries__Insert(
        rideId,
        browserEntryData.label,
        browserEntryData.description
    )

    local icon = browserEntryData.icon ~= nil and browserEntryData.icon or rideId
    db.BrowserEntries__Update__Icon(
        rideId,
        icon
    )

    if (browserEntryData.releaseGroup ~= nil) then
        db.BrowserEntries__Update__ReleaseGroup(
            rideId,
            browserEntryData.releaseGroup
        )
    end

    if (browserEntryData.manufacturer ~= nil) then
        db.BrowserEntries__Update__Manufacturer(
            rideId,
            browserEntryData.manufacturer
        )
    end
end

return BrowserEntries
