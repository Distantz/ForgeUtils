local global = _G
local setmetatable = global.setmetatable
local db = require("forgeutils.internal.database.TrackedRides")

--- @class forgeutils.builders.database.trackedride.RideData
local RideData = {}
RideData.__index = RideData

--- Adds simulation data to the database
---@param id string The ID (or name) of the tracked ride.
---@param contentPack string The content pack name, must match the DB constants.
---@param rideData forgeutils.builders.data.trackedride.RideData
function RideData.addToDb(id, contentPack, rideData)
    db.RideData__Insert(
        id,
        rideData.trackCost,
        rideData.breakdownTimeMultiplier,
        rideData.maxTrackHeightFeet,
        rideData.splineElement,
        rideData.stationElement,
        rideData.blockSection,
        contentPack
    )

    -- Set default name if not provided by just being the ID.
    db.RideData__Update__Track(
        id,
        contentPack,
        rideData.track ~= nil and rideData.track or id
    )

    -- Set default name if not provided by just being the ID.
    db.RideData__Update__Name(
        id,
        contentPack,
        rideData.name ~= nil and rideData.name or id
    )

    if (rideData.class ~= nil) then
        db.RideData__Update__Class(
            id,
            contentPack,
            rideData.class
        )
    end

    if (rideData.specificPowerMultiplier ~= nil) then
        db.RideData__Update__SpecificPowerMultiplier(
            id,
            contentPack,
            rideData.specificPowerMultiplier
        )
    end

    if (rideData.platformHeight ~= nil) then
        db.RideData__Update__PlatformHeight(
            id,
            contentPack,
            rideData.platformHeight
        )
    end

    if (rideData.heightAbovePlatform ~= nil) then
        db.RideData__Update__HeightAbovePlatform(
            id,
            contentPack,
            rideData.heightAbovePlatform
        )
    end

    if (rideData.trackGapWidth ~= nil) then
        db.RideData__Update__TrackGapWidth(
            id,
            contentPack,
            rideData.trackGapWidth
        )
    end

    if (rideData.trackBlockWidth ~= nil) then
        db.RideData__Update__TrackBlockWidth(
            id,
            contentPack,
            rideData.trackBlockWidth
        )
    end

    if (rideData.platformBlockWidth ~= nil) then
        db.RideData__Update__PlatformBlockWidth(
            id,
            contentPack,
            rideData.platformBlockWidth
        )
    end

    if (rideData.chainElement ~= nil) then
        db.RideData__Update__ChainElement(
            id,
            contentPack,
            rideData.chainElement
        )
    end

    if (rideData.stationWidth ~= nil) then
        db.RideData__Update__StationWidth(
            id,
            contentPack,
            rideData.stationWidth
        )
    end

    if (rideData.audioType ~= nil) then
        db.RideData__Update__AudioType(
            id,
            contentPack,
            rideData.audioType
        )
    end

    if (rideData.maxSlopeDeltaDegrees ~= nil) then
        db.RideData__Update__MaxSlopeDeltaDegrees(
            id,
            contentPack,
            rideData.maxSlopeDeltaDegrees
        )
    end

    if (rideData.maxBankDeltaDegrees ~= nil) then
        db.RideData__Update__MaxBankDeltaDegrees(
            id,
            contentPack,
            rideData.maxBankDeltaDegrees
        )
    end

    if (rideData.buildBackwards ~= nil) then
        db.RideData__Update__BuildBackwards(
            id,
            contentPack,
            rideData.buildBackwards
        )
    end

    if (rideData.heightOffsetOnWater ~= nil) then
        db.RideData__Update__HeightOffsetOnWater(
            id,
            contentPack,
            rideData.heightOffsetOnWater
        )
    end

    if (rideData.trainTypeName ~= nil) then
        db.RideData__Update__TrainTypeName(
            id,
            contentPack,
            rideData.trainTypeName
        )
    end

    if (rideData.groupTrainTypeName ~= nil) then
        db.RideData__Update__GroupTrainTypeName(
            id,
            contentPack,
            rideData.groupTrainTypeName
        )
    end

    if (rideData.customPlatformSpatial ~= nil) then
        db.RideData__Update__CustomPlatformSpatial(
            id,
            contentPack,
            rideData.customPlatformSpatial
        )
    end

    if (rideData.defaultStationRailCount ~= nil) then
        db.RideData__Update__DefaultStationRailCount(
            id,
            contentPack,
            rideData.defaultStationRailCount
        )
    end

    if (rideData.maxStationCount ~= nil) then
        db.RideData__Update__MaxStationCount(
            id,
            contentPack,
            rideData.maxStationCount
        )
    end

    if (rideData.lastTrackElement ~= nil) then
        db.RideData__Update__LastTrackElement(
            id,
            contentPack,
            rideData.lastTrackElement
        )
    end

    if (rideData.shuttleMode ~= nil) then
        db.RideData__Update__ShuttleMode(
            id,
            contentPack,
            rideData.shuttleMode
        )
    end

    if (rideData.flumePlacementOffset ~= nil) then
        db.RideData__Update__FlumePlacementOffset(
            id,
            contentPack,
            rideData.flumePlacementOffset
        )
    end
end

return RideData
