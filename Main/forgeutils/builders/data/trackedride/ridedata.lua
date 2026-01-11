local global = _G
local setmetatable = global.setmetatable

local classThrill = "Thrill"
local classFamily = "Family"
local classJunior = "Junior"

---@class forgeutils.builders.data.trackedride.RideData
---@field track string?
---@field name string?
---@field class string?
---@field trackCost number
---@field specificPowerMultiplier number?
---@field breakdownTimeMultiplier number
---@field maxTrackHeightFeet number
---@field platformHeight number?
---@field heightAbovePlatform number?
---@field trackGapWidth number?
---@field trackBlockWidth number?
---@field platformBlockWidth number?
---@field splineElement string
---@field stationElement string
---@field chainElement string?
---@field stationWidth number?
---@field audioType string?
---@field blockSection boolean
---@field maxSlopeDeltaDegrees number?
---@field maxBankDeltaDegrees number?
---@field buildBackwards boolean?
---@field heightOffsetOnWater number?
---@field trainTypeName string?
---@field groupTrainTypeName string?
---@field customPlatformSpatial number?
---@field defaultStationRailCount integer?
---@field maxStationCount integer?
---@field lastTrackElement string?
---@field shuttleMode boolean?
---@field flumePlacementOffset number?
local RideData = {}
RideData.__index = RideData

--- Create a new RideData data object.
--- @return self
function RideData.new()
    local self = setmetatable({}, RideData)

    -- Sane defaults
    self.trackCost = 1.0
    self.breakdownTimeMultiplier = 3.0
    self.maxTrackHeightFeet = 399
    self.splineElement = "default_spline"
    self.stationElement = "station_leftleft"
    self.blockSection = true

    -- DB defaults
    self.track = nil
    self.name = nil
    self.class = classThrill
    self.specificPowerMultiplier = nil
    self.platformHeight = nil
    self.heightAbovePlatform = nil
    self.trackGapWidth = nil
    self.trackBlockWidth = nil
    self.platformBlockWidth = nil
    self.chainElement = nil
    self.stationWidth = nil
    self.audioType = nil
    self.maxSlopeDeltaDegrees = nil
    self.maxBankDeltaDegrees = nil
    self.buildBackwards = nil
    self.heightOffsetOnWater = nil
    self.trainTypeName = nil
    self.groupTrainTypeName = nil
    self.customPlatformSpatial = nil
    self.defaultStationRailCount = nil
    self.maxStationCount = nil
    self.lastTrackElement = nil
    self.shuttleMode = nil
    self.flumePlacementOffset = nil

    return self
end

--- @param track string?
--- @return self
function RideData:withTrack(track)
    self.track = track
    return self
end

--- @param name string?
--- @return self
function RideData:withName(name)
    self.name = name
    return self
end

--- @return self
function RideData:asJuniorCoaster()
    self.class = classJunior
    return self
end

--- @return self
function RideData:asFamilyCoaster()
    self.class = classFamily
    return self
end

--- @return self
function RideData:asThrillCoaster()
    self.class = classThrill
    return self
end

--- @param trackCost number
--- @return self
function RideData:withTrackCost(trackCost)
    self.trackCost = trackCost
    return self
end

--- @param specificPowerMultiplier number?
--- @return self
function RideData:withSpecificPowerMultiplier(specificPowerMultiplier)
    self.specificPowerMultiplier = specificPowerMultiplier
    return self
end

--- @param breakdownTimeMultiplier number
--- @return self
function RideData:withBreakdownTimeMultiplier(breakdownTimeMultiplier)
    self.breakdownTimeMultiplier = breakdownTimeMultiplier
    return self
end

--- @param maxTrackHeightFeet number
--- @return self
function RideData:withMaxTrackHeightFeet(maxTrackHeightFeet)
    self.maxTrackHeightFeet = maxTrackHeightFeet
    return self
end

--- @param platformHeight number?
--- @return self
function RideData:withPlatformHeight(platformHeight)
    self.platformHeight = platformHeight
    return self
end

--- @param heightAbovePlatform number?
--- @return self
function RideData:withHeightAbovePlatform(heightAbovePlatform)
    self.heightAbovePlatform = heightAbovePlatform
    return self
end

--- @param trackGapWidth number?
--- @return self
function RideData:withTrackGapWidth(trackGapWidth)
    self.trackGapWidth = trackGapWidth
    return self
end

--- @param trackBlockWidth number?
--- @return self
function RideData:withTrackBlockWidth(trackBlockWidth)
    self.trackBlockWidth = trackBlockWidth
    return self
end

--- @param platformBlockWidth number?
--- @return self
function RideData:withPlatformBlockWidth(platformBlockWidth)
    self.platformBlockWidth = platformBlockWidth
    return self
end

--- @param splineElement string
--- @return self
function RideData:withSplineElement(splineElement)
    self.splineElement = splineElement
    return self
end

--- @param stationElement string
--- @return self
function RideData:withStationElement(stationElement)
    self.stationElement = stationElement
    return self
end

--- @param chainElement string?
--- @return self
function RideData:withChainElement(chainElement)
    self.chainElement = chainElement
    return self
end

--- @param stationWidth number?
--- @return self
function RideData:withStationWidth(stationWidth)
    self.stationWidth = stationWidth
    return self
end

--- @param audioType string?
--- @return self
function RideData:withAudioType(audioType)
    self.audioType = audioType
    return self
end

--- @param blockSection boolean
--- @return self
function RideData:withBlockSection(blockSection)
    self.blockSection = blockSection
    return self
end

--- @param maxSlopeDeltaDegrees number?
--- @return self
function RideData:withMaxSlopeDeltaDegrees(maxSlopeDeltaDegrees)
    self.maxSlopeDeltaDegrees = maxSlopeDeltaDegrees
    return self
end

--- @param maxBankDeltaDegrees number?
--- @return self
function RideData:withMaxBankDeltaDegrees(maxBankDeltaDegrees)
    self.maxBankDeltaDegrees = maxBankDeltaDegrees
    return self
end

--- @param buildBackwards boolean?
--- @return self
function RideData:withBuildBackwards(buildBackwards)
    self.buildBackwards = buildBackwards
    return self
end

--- @param heightOffsetOnWater number?
--- @return self
function RideData:withHeightOffsetOnWater(heightOffsetOnWater)
    self.heightOffsetOnWater = heightOffsetOnWater
    return self
end

--- @param trainTypeName string?
--- @return self
function RideData:withTrainTypeName(trainTypeName)
    self.trainTypeName = trainTypeName
    return self
end

--- @param groupTrainTypeName string?
--- @return self
function RideData:withGroupTrainTypeName(groupTrainTypeName)
    self.groupTrainTypeName = groupTrainTypeName
    return self
end

--- @param customPlatformSpatial number?
--- @return self
function RideData:withCustomPlatformSpatial(customPlatformSpatial)
    self.customPlatformSpatial = customPlatformSpatial
    return self
end

--- @param defaultStationRailCount integer?
--- @return self
function RideData:withDefaultStationRailCount(defaultStationRailCount)
    self.defaultStationRailCount = defaultStationRailCount
    return self
end

--- @param maxStationCount integer?
--- @return self
function RideData:withMaxStationCount(maxStationCount)
    self.maxStationCount = maxStationCount
    return self
end

--- @param lastTrackElement string?
--- @return self
function RideData:withLastTrackElement(lastTrackElement)
    self.lastTrackElement = lastTrackElement
    return self
end

--- @param shuttleMode boolean?
--- @return self
function RideData:withShuttleMode(shuttleMode)
    self.shuttleMode = shuttleMode
    return self
end

--- @param flumePlacementOffset number?
--- @return self
function RideData:withFlumePlacementOffset(flumePlacementOffset)
    self.flumePlacementOffset = flumePlacementOffset
    return self
end

return RideData
