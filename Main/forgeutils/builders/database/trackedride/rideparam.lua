local global = _G
local setmetatable = global.setmetatable
local db = require("forgeutils.internal.database.TrackedRides")
local check = require("forgeutils.check")

--- @class forgeutils.builders.database.trackedride.RideParam
local RideParam = {}
RideParam.__index = RideParam

--- Checks whether the data has errors or not
---@param rideParam forgeutils.builders.data.trackedride.RideParam
function RideParam.hasErrors(rideParam)
    local issues = false
    issues = check.IsNil("rideParam.param", rideParam.param) or issues
    issues = check.IsNil("rideParam.min", rideParam.min) or issues
    issues = check.IsNil("rideParam.max", rideParam.max) or issues
    issues = check.IsNil("rideParam.initial", rideParam.initial) or issues
    issues = check.IsNil("rideParam.step", rideParam.step) or issues
    return issues
end

--- Adds ride param data to the database
---@param id string The ID (or name) of the tracked ride.
---@param rideParam forgeutils.builders.data.trackedride.RideParam
function RideParam.addToDb(id, rideParam)
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

return RideParam
