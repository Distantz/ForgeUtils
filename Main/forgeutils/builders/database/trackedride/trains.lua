local global = _G
local setmetatable = global.setmetatable
local db = require("forgeutils.internal.database.TrackedRides")

--- @class forgeutils.builders.database.trackedride.Trains
local Trains = {}
Trains.__index = Trains

--- Adds simulation data to the database
---@param rideId string The ID (or name) of the tracked ride.
---@param trainData forgeutils.builders.data.trackedride.Train
function Trains.addToDb(rideId, trainData)
    local trainId = trainData.trainId ~= nil and trainData.trainId or rideId
    db.Trains__Insert(
        rideId,
        trainId,
        trainData.numCars,
        trainData.minCars,
        trainData.maxCars,
        trainData.isDefaultTrainForRide
    )

    if (trainData.poweredMinSpeed ~= nil) then
        db.Trains__Update__Powered_MinSpeed(
            rideId,
            trainId,
            trainData.poweredMinSpeed
        )
    end

    if (trainData.poweredMaxSpeed ~= nil) then
        db.Trains__Update__Powered_MaxSpeed(
            rideId,
            trainId,
            trainData.poweredMaxSpeed
        )
    end

    if (trainData.poweredDefaultSpeed ~= nil) then
        db.Trains__Update__Powered_DefaultSpeed(
            rideId,
            trainId,
            trainData.poweredDefaultSpeed
        )
    end

    if (trainData.poweredSpeedRangeMinDelta ~= nil) then
        db.Trains__Update__Powered_SpeedRangeMinDelta(
            rideId,
            trainId,
            trainData.poweredSpeedRangeMinDelta
        )
    end

    if (trainData.poweredSpeedRangeMaxDelta ~= nil) then
        db.Trains__Update__Powered_SpeedRangeMaxDelta(
            rideId,
            trainId,
            trainData.poweredSpeedRangeMaxDelta
        )
    end

    if (trainData.allowCrashTestDummies ~= nil) then
        db.Trains__Update__AllowCrashTestDummies(
            rideId,
            trainId,
            trainData.allowCrashTestDummies
        )
    end

    if (trainData.isRacing ~= nil) then
        db.Trains__Update__IsRacing(
            rideId,
            trainId,
            trainData.isRacing
        )
    end

    if (trainData.numPassesThroughStation ~= nil) then
        db.Trains__Update__NumPassesThroughStation(
            rideId,
            trainId,
            trainData.numPassesThroughStation
        )
    end

    if (trainData.minNumPassesThroughStation ~= nil) then
        db.Trains__Update__MinNumPassesThroughStation(
            rideId,
            trainId,
            trainData.minNumPassesThroughStation
        )
    end

    if (trainData.maxNumPassesThroughStation ~= nil) then
        db.Trains__Update__MaxNumPassesThroughStation(
            rideId,
            trainId,
            trainData.maxNumPassesThroughStation
        )
    end

    if (trainData.hardMaxTrains ~= nil) then
        db.Trains__Update__HardMaxTrains(
            rideId,
            trainId,
            trainData.hardMaxTrains
        )
    end

    if (trainData.poweredBehaviour ~= nil) then
        db.Trains__Update__Powered_Behaviour(
            rideId,
            trainId,
            trainData.poweredBehaviour
        )
    end

    if (trainData.poweredCanChangeBehaviour ~= nil) then
        db.Trains__Update__Powered_CanChangeBehaviour(
            rideId,
            trainId,
            trainData.poweredCanChangeBehaviour
        )
    end
end

return Trains
