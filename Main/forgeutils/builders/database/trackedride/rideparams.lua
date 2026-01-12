local global = _G
local setmetatable = global.setmetatable
local db = require("forgeutils.internal.database.TrackedRides")
local check = require("forgeutils.check")

--- @class forgeutils.builders.database.trackedride.RideParams
local RideParams = {}
RideParams.__index = RideParams

--- Checks whether the data has errors or not
---@param rideParam forgeutils.builders.data.trackedride.RideParam
function RideParams.hasErrors(rideParam)
    local issues = false
    issues = check.IsNil("rideParam.param", rideParam.param) or issues
    return issues
end

--- Adds simulation data to the database
---@param id string The ID (or name) of the tracked ride.
---@param rideParam forgeutils.builders.data.trackedride.RideParam
function RideParams.addToDb(id, rideParam)
    db.RideParams__Insert(
        id,
        rideParam.param,
        rideParam.min,
        rideParam.max,
        rideParam.initial,
        rideParam.step
    )

    if rideParam.stepIsRelativeToMin ~= nil then
        db.RideParams__Update__StepIsRelativeToMin(
            id,
            rideParam.param,
            rideParam.stepIsRelativeToMin
        )
    end

    if rideParam.labelOverride ~= nil then
        db.RideParams__Update__LabelOverride(
            id,
            rideParam.param,
            rideParam.labelOverride
        )
    end

    if rideParam.valueLabelSetName ~= nil then
        db.RideParams__Update__ValueLabelSetName(
            id,
            rideParam.param,
            rideParam.valueLabelSetName
        )
    end

    if rideParam.absoluteMin ~= nil then
        db.RideParams__Update__AbsoluteMin(
            id,
            rideParam.param,
            rideParam.absoluteMin
        )
    end

    if rideParam.absoluteMax ~= nil then
        db.RideParams__Update__AbsoluteMax(
            id,
            rideParam.param,
            rideParam.absoluteMax
        )
    end
end

return RideParams
