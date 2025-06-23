local global = _G
local api = global.api
local setmetatable = global.setmetatable
local pairs = global.pairs

local SceneryDB = require("forgeutils.internal.database.scenery")
local logger = require("forgeutils.logger").Get("TrackedRideBuilder")

--- TrackedRideBuilder is a fluent builder for database values in ForgeUtils.
--- Example usage, TODO:
--- ```lua
---
--- ```
--- Note the use of the `addToDB()` call at the end. This is actually what adds the defined values
--- into the DB.
---
--- @class forgeutils.builders.TrackedRideBuilder
--- @field __index table
--- @field ride string
--- @field name string
--- @field class string
--- @field track string
--- @field trackCost number
--- @field specificPowerMultiplier number? Default is 1.0.
--- @field wear number
--- @field maxTrackHeightFeet number
--- @field maxSlopeDeltaDegrees number? Default is 90.
--- @field maxBankDeltaDegrees number? Default is 90.
--- @field platformHeight number? Default is 2.
--- @field heightAbovePlatform number? Default is 0.
--- @field trackGapWidth number? Default is 2.
--- @field trackBlockWidth number? Default is 4.
--- @field platformBlockWidth number? Default is 4.
--- @field stationWidth number? Default is 8.
--- @field splineElement string Default is default_spline.
--- @field stationElement string Default is station_leftleft.
--- @field chainElement string Default is empty.
--- @field lastTrackElement string?
--- @field trainTypeName string? Default is Car.
--- @field groupTrainTypeName string? Default is Train.
--- @field defaultStationRailCount integer? Default is 1.
--- @field maxStationCount integer? Default is 0.
--- @field buildBackwards boolean Default is false.
--- @field shuttleMode boolean Default is false.
--- @field blockSection boolean
--- @field audioType string? Default is Metal.
--- @field contentPack string
--- @field heightOffsetOnWater number? Default is 0.
--- @field customPlatformSpatial number? Default is 0.
--- @field flumePlacementOffset number? Default is 0.
local TrackedRideBuilder = {}
TrackedRideBuilder.__index = TrackedRideBuilder

---Creates a SceneryPartBuilder, to define database information.
---@return forgeutils.builders.TrackedRideBuilder
function TrackedRideBuilder.new()
    local instance = setmetatable({}, TrackedRideBuilder)

    -- #region identity
    instance.ride = ""
    instance.name = ""
    instance.class = ""
    instance.track = ""
    -- #endregion

    -- #region costs and power
    instance.trackCost = 1.0
    instance.specificPowerMultiplier = nil -- default = 1.0
    -- #endregion

    -- #region wear and track dimensions
    instance.wear = 1.0
    instance.maxTrackHeightFeet = 999.0
    instance.maxSlopeDeltaDegrees = nil -- default = 90
    instance.maxBankDeltaDegrees = nil  -- default = 90
    -- #endregion

    -- #region station data
    instance.platformHeight = nil      -- default = 2
    instance.heightAbovePlatform = nil -- default = 0
    instance.trackGapWidth = nil       -- default = 2
    instance.trackBlockWidth = nil     -- default = 4
    instance.platformBlockWidth = nil  -- default = 4
    instance.stationWidth = nil        -- default = 8
    -- #endregion

    -- #region elements
    instance.splineElement = "default_spline"
    instance.stationElement = "station_leftleft"
    instance.chainElement = ""
    instance.lastTrackElement = ""
    -- #endregion

    -- #region train configuration
    instance.trainTypeName = nil           -- default = Car
    instance.groupTrainTypeName = nil      -- default = Train
    instance.defaultStationRailCount = nil -- default = 1
    instance.maxStationCount = nil         -- default = 0
    instance.buildBackwards = false        -- default = 0
    instance.shuttleMode = false           -- default = 0
    -- #endregion

    -- #region behavior and logic
    instance.blockSection = false
    -- #endregion

    -- #region audio
    instance.audioType = nil -- default = Metal
    -- #endregion

    -- #region content and placement
    instance.contentPack = ""
    instance.heightOffsetOnWater = nil   -- default = 0
    instance.customPlatformSpatial = nil -- default = 0
    instance.flumePlacementOffset = nil  -- default = 0
    -- #endregion

    return instance
end

--- Sets the ID of the tracked ride.
--- Important: The track prefab used for this tracked ride has
--- the prefix `track_*RIDE_ID*`. The name will be set to this ID as well.
--- @param rideID string The ID to use for this tracked ride
--- @return forgeutils.builders.TrackedRideBuilder
function TrackedRideBuilder:withID(rideID)
    self.ride = rideID
    self.track = "track_" .. rideID
    self.name = rideID
    return self
end

--#region Class setters

--- Sets the class of the tracked ride to be a junior ride.
--- @return forgeutils.builders.TrackedRideBuilder
function TrackedRideBuilder:asJuniorRide()
    self.class = "Junior"
    return self
end

--- Sets the class of the tracked ride to be a family ride.
--- @return forgeutils.builders.TrackedRideBuilder
function TrackedRideBuilder:asFamilyRide()
    self.class = "Family"
    return self
end

--- Sets the class of the tracked ride to be a thrill ride.
--- @return forgeutils.builders.TrackedRideBuilder
function TrackedRideBuilder:asThrillRide()
    self.class = "Thrill"
    return self
end

--#endregion

--#region Element setters

--- Sets the standard spline element of the tracked ride.
--- Default is "default_spline". Generally you shouldn't need to change this.
--- @param splineElement string The ID to use for this tracked ride
--- @return forgeutils.builders.TrackedRideBuilder
function TrackedRideBuilder:withSplineElement(splineElement)
    self.splineElement = splineElement
    return self
end

--- Sets the standard station element of the tracked ride.
--- Default is "station_leftleft". Generally you shouldn't need to change this. This
--- is the default station type used when placing down the coaster for the first time.
--- @param stationElement string The ID to use for this tracked ride
--- @return forgeutils.builders.TrackedRideBuilder
function TrackedRideBuilder:withStationElement(stationElement)
    self.stationElement = stationElement
    return self
end

--- Sets the standard chain element of the tracked ride.
--- Default is "". This can be any element. This element is the default element
--- selected after the ride station is built.
--- @param chainElement string The ID to use for this tracked ride
--- @return forgeutils.builders.TrackedRideBuilder
function TrackedRideBuilder:withChainElement(chainElement)
    self.chainElement = chainElement
    return self
end

--#endregion

--- Adds the built part within the builder to the DB.
--- This object can be reused afterwards to reuse parameters if desired.
---@return nil
function TrackedRideBuilder:addToDB()
    logger:Info("Creating new Tracked Ride with ID: " .. self.ride)

    if (logger:IsNil(self.ride, "Tracked Ride ID")) then
        return
    end

    -- SceneryDB.Forge_AddModularSceneryPart(
    --     self.partID,
    --     self.visualsPrefab,
    --     self.dataPrefab,
    --     self.contentPack,
    --     nil,
    --     -- for some reason in the DB, size is defined in MM. so we convert from M.
    --     self.sizeX * 100.0,
    --     self.sizeY * 100.0,
    --     self.sizeZ * 100.0
    -- )


    -- for k, v in pairs(self.tags) do
    --     SceneryDB.Forge_AddSceneryTag(
    --         self.partID,
    --         k
    --     )
    -- end


    logger:Info("Finished adding Tracked Ride with ID: " .. self.ride)
end

return TrackedRideBuilder
