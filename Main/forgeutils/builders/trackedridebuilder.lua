local global = _G
local api = global.api
local setmetatable = global.setmetatable
local pairs = global.pairs
local ipairs = global.ipairs

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
--- @field contentPack string
--- @field name string
--- @field class string
--- @field track string
--- @field labelFile string
--- @field iconFile string? Default is nil.
--- @field descriptionFile string
--- @field releaseGroup integer? Default is 1.
--- @field manufacturerFile string? Default is nil.
--- @field trackCost number Default is 1.0.
--- @field specificPowerMultiplier number? Default is 1.0.
--- @field wear number Default is 1.0.
--- @field maxTrackHeightFeet number Default is 999.0.
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
--- @field blockSection boolean Default is true.
--- @field audioType string? Default is Metal.
--- @field heightOffsetOnWater number? Default is 0.
--- @field customPlatformSpatial number? Default is 0.
--- @field flumePlacementOffset number? Default is 0.
--- @field excitementRating number Default is 5.0.
--- @field intensityRating number Default is 5.0.
--- @field nauseaRating number Default is 2.0.
--- @field prestige integer Default is 100.
--- @field ticketCost integer Default is 1000.
--- @field supportsChildGuests boolean Default is true.
--- @field maximumGroupSize integer?
--- @field isTransport boolean Default is false.
--- @field isChildOnly boolean Default is false.
--- @field researchPack integer?
--- @field serviceInterval number? Default is 1800.
--- @field isBoomerang boolean Default is false.
--- @field isLoopedAsDefault boolean Default is false.
--- @field requiresEndLoops boolean Default is false.
--- @field isNonStop boolean Default is false.
--- @field allowsFreeEnds boolean Default is false.
--- @field isWaterSlide boolean Default is false.
--- @field metadataTags { [string]: boolean } Default is empty. You will need to add at least one though.
--- @field elements { [string]: boolean } Default is empty. You will need to add at least one though.
--- @field flexicolours string[] Default is empty.
local TrackedRideBuilder = {}
TrackedRideBuilder.__index = TrackedRideBuilder

---Creates a SceneryPartBuilder, to define database information.
---@return forgeutils.builders.TrackedRideBuilder
function TrackedRideBuilder.new()
    local instance = setmetatable({}, TrackedRideBuilder)

    -- #region Shared
    instance.ride = ""
    -- #endregion

    -- #region RideData

    instance.name = ""
    instance.class = ""
    instance.track = ""

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
    instance.platformHeight = nil          -- default = 2
    instance.heightAbovePlatform = nil     -- default = 0
    instance.trackGapWidth = nil           -- default = 2
    instance.trackBlockWidth = nil         -- default = 4
    instance.platformBlockWidth = nil      -- default = 4
    instance.stationWidth = nil            -- default = 8
    instance.defaultStationRailCount = nil -- default = 1
    instance.maxStationCount = nil         -- default = 0
    -- #endregion

    -- #region elements
    instance.splineElement = "default_spline"
    instance.stationElement = "station_leftleft"
    instance.chainElement = ""
    instance.lastTrackElement = ""
    -- #endregion

    -- #region train configuration
    instance.trainTypeName = nil      -- default = Car
    instance.groupTrainTypeName = nil -- default = Train
    -- #endregion

    -- #region behavior and logic
    instance.blockSection = true
    instance.buildBackwards = false
    instance.shuttleMode = false
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

    -- #endregion

    -- #region Simulation
    instance.researchPack = nil

    -- #region ratings
    instance.excitementRating = 5.0
    instance.intensityRating = 5.0
    instance.nauseaRating = 2.0
    instance.prestige = 100
    instance.ticketCost = 1000
    -- #endregion

    -- #region guest rules
    instance.supportsChildGuests = true -- default = true
    instance.maximumGroupSize = nil
    instance.isTransport = false        -- default = false
    instance.isChildOnly = false        -- default = false
    -- #endregion

    -- #region ride behavior
    instance.serviceInterval = nil     -- default = 1800
    instance.isBoomerang = false       -- default = false
    instance.isLoopedAsDefault = false -- default = false
    instance.requiresEndLoops = false  -- default = false
    instance.isNonStop = false         -- default = false
    instance.allowsFreeEnds = false    -- default = false
    instance.isWaterSlide = false      -- default = false
    -- #endregion

    -- #endregion

    -- #region Browser entry
    instance.labelFile = nil
    instance.iconFile = nil
    instance.descriptionFile = nil
    instance.releaseGroup = nil -- default = 1
    instance.manufacturerFile = nil
    -- #endregion

    -- #region Sets
    instance.metadataTags = {}
    instance.elements = {}
    instance.flexicolours = {}
    -- #endregion

    return instance
end

--- Sets the ID of the tracked ride.
--- Important: The track prefab used for this tracked ride has
--- the prefix `track_*RIDE_ID*`. The name will be set to this ID as well.
--- @param rideID string The ID to use for this tracked ride.
--- @return forgeutils.builders.TrackedRideBuilder
function TrackedRideBuilder:withID(rideID)
    self.ride = rideID
    self.track = "track_" .. rideID
    self.name = rideID
    return self
end

--- Sets the content pack of the tracked ride.
--- @param contentPack string The content pack.
--- @return forgeutils.builders.TrackedRideBuilder
function TrackedRideBuilder:withContentPack(contentPack)
    self.contentPack = contentPack
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

--#region Station setters

--- Sets the height of the track above the station platform.
--- Upwards is positive, and downwards is negative.
--- @param height number The vertical offset from the platform.
--- @return forgeutils.builders.TrackedRideBuilder
function TrackedRideBuilder:withTrackHeightAboveStation(height)
    self.heightAbovePlatform = height
    return self
end

--- Sets the width of the gap that the track occupies in the station.
--- @param width number The width of the gap that the track occupies in the station. Default is 2.
--- @return forgeutils.builders.TrackedRideBuilder
function TrackedRideBuilder:withStationTrackGapWidth(width)
    self.trackGapWidth = width
    return self
end

--- Undocumented.
--- @param width number Default is 4.
--- @return forgeutils.builders.TrackedRideBuilder
function TrackedRideBuilder:withTrackBlockWidth(width)
    self.trackBlockWidth = width
    return self
end

--- Undocumented, but seems to affect the station width.
--- @see forgeutils.builders.TrackedRideBuilder.withStationWidth
--- @param width number The width of one platform block. Default is 4.
--- @return forgeutils.builders.TrackedRideBuilder
function TrackedRideBuilder:withPlatformBlockWidth(width)
    self.platformBlockWidth = width
    return self
end

--- Sets the station width. Weirdly seems to be tied to platform block width
--- @see forgeutils.builders.TrackedRideBuilder.withPlatformBlockWidth
--- @param width number The width of the station area. Default is 8.
--- @return forgeutils.builders.TrackedRideBuilder
function TrackedRideBuilder:withStationWidth(width)
    self.stationWidth = width
    return self
end

--- Sets the default number of rails in the station.
--- @param count integer The number of rails. Default is 1.
--- @return forgeutils.builders.TrackedRideBuilder
function TrackedRideBuilder:withDefaultStationRailCount(count)
    self.defaultStationRailCount = count
    return self
end

--- Undocumented effects.
--- @param count integer Default is 0.
--- @return forgeutils.builders.TrackedRideBuilder
function TrackedRideBuilder:withMaxStationCount(count)
    self.maxStationCount = count
    return self
end

--#endregion

--- Sets the excitement, intensity and nausea stats for this ride. Default is 5, 5, 2.
---@param excitement number
---@param intensity number
---@param nausea number
---@return forgeutils.builders.TrackedRideBuilder
function TrackedRideBuilder:withRatings(excitement, intensity, nausea)
    self.excitementRating = excitement
    self.intensityRating = intensity
    self.nauseaRating = nausea
end

--#region UI Data

--- Sets the ride ID for the browser entry.
--- @param rideID string The ride ID to associate with this entry.
--- @return forgeutils.builders.TrackedRideBuilder
function TrackedRideBuilder:withRide(rideID)
    self.ride = rideID
    return self
end

--- Sets the label for the browser entry.
--- @param labelFile string The label to display.
--- @return forgeutils.builders.TrackedRideBuilder
function TrackedRideBuilder:withLabel(labelFile)
    self.labelFile = labelFile
    return self
end

--- Sets the icon path for the browser entry.
--- @param iconFile string The path or identifier for the icon.
--- @return forgeutils.builders.TrackedRideBuilder
function TrackedRideBuilder:withIcon(iconFile)
    self.iconFile = iconFile
    return self
end

--- Sets the description for the browser entry.
--- @param descriptionFile string The description text.
--- @return forgeutils.builders.TrackedRideBuilder
function TrackedRideBuilder:withDescription(descriptionFile)
    self.descriptionFile = descriptionFile
    return self
end

--- Sets the release group for the browser entry.
--- @param group integer The release group number. Default is 1.
--- @return forgeutils.builders.TrackedRideBuilder
function TrackedRideBuilder:withReleaseGroup(group)
    self.releaseGroup = group
    return self
end

--- Sets the manufacturer for the browser entry.
--- @param manufacturerFile string The manufacturer name.
--- @return forgeutils.builders.TrackedRideBuilder
function TrackedRideBuilder:withManufacturer(manufacturerFile)
    self.manufacturerFile = manufacturerFile
    return self
end

--#endregion

--#region Elements
--- Adds an element to this tracked ride.
--- Note: the default spline, default station and default chain will be added as well.
---@param element string
---@return forgeutils.builders.TrackedRideBuilder
function TrackedRideBuilder:withElement(element)
    self.elements[element] = true
    return self
end

--- Adds a list of elements to this tracked ride.
--- Note: the default spline, default station and default chain will be added as well.
---@param elements string[]
---@return forgeutils.builders.TrackedRideBuilder
function TrackedRideBuilder:withElements(elements)
    for i, element in ipairs(elements) do
        self.elements[element] = true
    end
    return self
end

--- Sets the flexicolours for the coaster type.
--- Note, if you leave any of these as nil,
--- all colours after it will not be added to the DB.
---@param colour1 string? Hexcode for first flexicolour.
---@param colour2 string? Hexcode for second flexicolour.
---@param colour3 string? Hexcode for third flexicolour.
---@param colour4 string? Hexcode for fourth flexicolour.
function TrackedRideBuilder:withFlexicolours(colour1, colour2, colour3, colour4)
    self.flexicolours[1] = colour1
    self.flexicolours[2] = colour2
    self.flexicolours[3] = colour3
    self.flexicolours[4] = colour4
end

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
