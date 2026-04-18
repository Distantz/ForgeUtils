local global = _G
---@type Api
---@diagnostic disable-next-line: undefined-field
local api = global.api
local setmetatable = global.setmetatable
local ipairs = global.ipairs

local db = require("forgeutils.internal.database.TrackedRides")
local logger = require("forgeutils.logger").Get("TrackedRideBuilder")
local trybuild = require("forgeutils.builders.utils.trybuild")
local check = require("forgeutils.check")

local contentPack = require("forgeutils.builders.data.shared.contentpack")
local rideParam = require("forgeutils.builders.database.trackedride.rideparam")
local rideParamData = require("forgeutils.builders.data.trackedride.rideparam")
local flexicolour = require("forgeutils.builders.database.trackedride.flexicolour")
local constants = require("forgeutils.internal.database.constants.TrackedRides")

--- @class forgeutils.builders.TrackedRideBuilder
--- @field __index table
--- @field id string
--- @field contentPack forgeutils.builders.data.shared.ContentPack
--- @field simulationData forgeutils.builders.data.trackedride.Simulation
--- @field rideData forgeutils.builders.data.trackedride.RideData
--- @field browserEntry forgeutils.builders.data.trackedride.BrowserEntry
--- @field trains forgeutils.builders.data.trackedride.Train[]
--- @field elements string[]
--- @field rideParams forgeutils.builders.data.trackedride.RideParam[]
--- @field flexicolours forgeutils.builders.data.trackedride.Flexicolour[]
--- @field trackedRideMenu string
--- @field extraMetadataTags string[]
--- @field propulsionMethod string
--- @field canInvert string
--- @field ageGroup string
--- @field extraTooltips string[]
local TrackedRideBuilder = {}
TrackedRideBuilder.__index = TrackedRideBuilder

---@enum (key) forgeutils.builders.TrackedRideBuilder.TrackedRideMenu
TrackedRideBuilder.TrackedRideMenu = {
    Coaster_AlternateLift = constants.MetadataTags_Menu_Coaster_AlternateLift,
    Coaster_ChainLift = constants.MetadataTags_Menu_Coaster_ChainLift,
    Coaster_Launched = constants.MetadataTags_Menu_Coaster_Launched,
    Coaster_Special = constants.MetadataTags_Menu_Coaster_Special,
    Coaster_Suspended = constants.MetadataTags_Menu_Coaster_Suspended,
    Coaster_Water = constants.MetadataTags_Menu_Coaster_Water,
    Coaster_Wing = constants.MetadataTags_Menu_Coaster_Wing,
    Coaster_Wooden = constants.MetadataTags_Menu_Coaster_Wooden,
    Flume_FlumePlatform = constants.MetadataTags_Menu_Flume_FlumePlatform,
    Flume_FlumeShared = constants.MetadataTags_Menu_Flume_FlumeShared,
    Flume_FlumeSingle = constants.MetadataTags_Menu_Flume_FlumeSingle,
    Flume_WaterSlide = constants.MetadataTags_Menu_Flume_WaterSlide,
    TrackedRide_Powered = constants.MetadataTags_Menu_TrackedRide_Powered,
    TrackedRide_Special = constants.MetadataTags_Menu_TrackedRide_Special,
    TrackedRide_Water = constants.MetadataTags_Menu_TrackedRide_Water,
}

---@enum (key) forgeutils.builders.TrackedRideBuilder.PropulsionMethod
TrackedRideBuilder.PropulsionMethod = {
    CableAndChainLift =
        constants.BrowserTooltips_TrackFeature_CableAndChainLift,
    CableDriven =
        constants.BrowserTooltips_TrackFeature_CableDriven,
    CableLift =
        constants.BrowserTooltips_TrackFeature_CableLift,
    ChainLift =
        constants.BrowserTooltips_TrackFeature_ChainLift,
    ChainLiftAndLinearInductionMotor =
        constants.BrowserTooltips_TrackFeature_ChainLiftAndLinearInductionMotor,
    ChainandDriveTyreLift =
        constants.BrowserTooltips_TrackFeature_ChainandDriveTyreLift,
    ConveyorBeltLift =
        constants.BrowserTooltips_TrackFeature_ConveyerBeltLift,
    FrictionWheelLift =
        constants.BrowserTooltips_TrackFeature_FrictionWheelLift,
    HydraulicLaunch =
        constants.BrowserTooltips_TrackFeature_HydraulicLaunch,
    LinearInductionMotor =
        constants.BrowserTooltips_TrackFeature_LinearInductionMotor,
    LinearSynchronousMotor =
        constants.BrowserTooltips_TrackFeature_LinearSyncronousMotor,
    PoweredCar =
        constants.BrowserTooltips_TrackFeature_PoweredCar,
    PoweredTrain =
        constants.BrowserTooltips_TrackFeature_PoweredTrain,
    PoweredVehicle =
        constants.BrowserTooltips_TrackFeature_PoweredVehicle,
    VerticalChainLiftAndLinearSynchronousMotor =
        constants.BrowserTooltips_TrackFeature_VerticalChainLiftAndLinearSyncronousMotor,
}

---@enum (key) forgeutils.builders.TrackedRideBuilder.CanInvert
TrackedRideBuilder.CanInvert = {
    CanInvert =
        constants.BrowserTooltips_TrackFeature_CanInvert,
    CanPartiallyInvert =
        constants.BrowserTooltips_TrackFeature_CanPartiallyInvert,
    CannotInvert =
        constants.BrowserTooltips_TrackFeature_CannotInvert,
}

---@enum (key) forgeutils.builders.TrackedRideBuilder.AgeGroup
TrackedRideBuilder.AgeGroup = {
    ForEveryone =
        constants.BrowserTooltips_TrackFeature_ForEveryone,
    ForAdultsAndTeensOnly =
        constants.BrowserTooltips_TrackFeature_ForAdultsAndTeensOnly,
}

--- Creates a builder.
--- @return self
function TrackedRideBuilder.new()
    local self = setmetatable({}, TrackedRideBuilder)

    self.id = nil
    self.contentPack = contentPack:new()
    self.trains = {}
    self.elements = {}
    self.flexicolours = {}

    self.rideParams = {
        -- Needed defaults. Game will soft lock without.
        rideParamData.SupportParam,
        rideParamData.TunnelRadiusParam,
        -- Needed default. Game won't let you build a piece.
        rideParamData.LengthParam,

        -- Helper defaults
        rideParamData.CurveRangeParam,
        rideParamData.SlopeRangeParam,
        rideParamData.BankingOffsetParam,
        rideParamData.BankingRangeParam_Invert
    }

    self.trackedRideMenu = TrackedRideBuilder.TrackedRideMenu.Coaster_Special
    self.extraMetadataTags = {}

    self.propulsionMethod = TrackedRideBuilder.PropulsionMethod.ChainLift
    self.canInvert = TrackedRideBuilder.CanInvert.CanInvert
    self.ageGroup = TrackedRideBuilder.AgeGroup.ForEveryone
    self.extraTooltips = {}

    return self
end

--- Sets the ID.
--- @param id string
--- @return self
function TrackedRideBuilder:withId(id)
    self.id = id
    return self
end

--- Sets the content pack.
--- @param contentPack forgeutils.builders.data.shared.ContentPack
--- @return self
function TrackedRideBuilder:withContentPack(contentPack)
    self.contentPack = contentPack
    return self
end

--- Adds simulation data for this tracked ride.
--- @param simulationData forgeutils.builders.data.trackedride.Simulation
--- @return self
function TrackedRideBuilder:withSimulationData(simulationData)
    self.simulationData = simulationData
    return self
end

--- Adds ride data for this tracked ride.
--- @param rideData forgeutils.builders.data.trackedride.RideData
--- @return self
function TrackedRideBuilder:withRideData(rideData)
    self.rideData = rideData
    return self
end

--- Adds a browser entry for this tracked ride.
--- @param browserEntry forgeutils.builders.data.trackedride.BrowserEntry
--- @return self
function TrackedRideBuilder:withBrowserEntry(browserEntry)
    self.browserEntry = browserEntry
    return self
end

--- Adds a train to this tracked ride.
--- @param train forgeutils.builders.data.trackedride.Train
--- @return self
function TrackedRideBuilder:withTrain(train)
    self.trains[#self.trains + 1] = train
    return self
end

--- Adds trains to this tracked ride.
--- @param trains forgeutils.builders.data.trackedride.Train[]
--- @return self
function TrackedRideBuilder:withTrains(trains)
    for _, train in ipairs(trains) do
        self:withTrain(train)
    end
    return self
end

--- Adds a spline element to this tracked ride.
--- @param element string
--- @return self
function TrackedRideBuilder:withElement(element)
    self.elements[#self.elements + 1] = element
    return self
end

--- Adds spline elements to this tracked ride.
--- @param elements string[]
--- @return self
function TrackedRideBuilder:withElements(elements)
    for _, element in ipairs(elements) do
        self:withElement(element)
    end
    return self
end

--- Adds a flexicolour to this tracked ride.
--- @param flexicolour forgeutils.builders.data.trackedride.Flexicolour
--- @return self
function TrackedRideBuilder:withFlexicolour(flexicolour)
    self.flexicolours[#self.flexicolours + 1] = flexicolour
    return self
end

--- Adds flexicolours to this tracked ride.
--- @param flexicolours forgeutils.builders.data.trackedride.Flexicolour[]
--- @return self
function TrackedRideBuilder:withFlexicolours(flexicolours)
    for _, flexicolour in ipairs(flexicolours) do
        self:withFlexicolour(flexicolour)
    end
    return self
end

--- Adds a ride parameter to this tracked ride.
--- @param rideParam forgeutils.builders.data.trackedride.RideParam
--- @return self
function TrackedRideBuilder:withRideParam(rideParam)
    self.rideParams[#self.rideParams + 1] = rideParam
    return self
end

--- Adds ride parameters to this tracked ride.
--- @param rideParams forgeutils.builders.data.trackedride.RideParam[]
function TrackedRideBuilder:withRideParams(rideParams)
    for _, rideParam in ipairs(rideParams) do
        self:withRideParam(rideParam)
    end
    return self
end

--- Adds a metadata tag to this tracked ride.
--- @param metadataTag string
--- @return self
function TrackedRideBuilder:withMetadataTag(metadataTag)
    self.extraMetadataTags[#self.extraMetadataTags + 1] = metadataTag
    return self
end

--- Adds metadata tags to this tracked ride.
--- @param metadataTags string[]
function TrackedRideBuilder:withMetadataTags(metadataTags)
    for _, metadataTag in ipairs(metadataTags) do
        self:withMetadataTag(metadataTag)
    end
    return self
end

--- Adds a tooltip to this tracked ride.
--- @param tooltip string
--- @return self
function TrackedRideBuilder:withTooltip(tooltip)
    self.extraTooltips[#self.extraTooltips + 1] = tooltip
    return self
end

--- Adds tooltips to this tracked ride.
--- @param tooltips string[]
--- @return self
function TrackedRideBuilder:withTooltips(tooltips)
    for _, tooltip in ipairs(tooltips) do
        self:withTooltip(tooltip)
    end
    return self
end

--- Sets the propulsion method of this tracked ride using an enum key.
--- @param propulsionMethod forgeutils.builders.TrackedRideBuilder.PropulsionMethod
--- @return self
function TrackedRideBuilder:withPropulsionMethod(propulsionMethod)
    self.propulsionMethod = TrackedRideBuilder.PropulsionMethod[propulsionMethod]
    return self
end

--- Sets the propulsion method of this tracked ride using a raw constant.
--- @param propulsionMethod string
--- @return self
function TrackedRideBuilder:withRawPropulsionMethod(propulsionMethod)
    self.propulsionMethod = propulsionMethod
    return self
end

--- Sets whether this tracked ride can invert using an enum key.
--- @param canInvert forgeutils.builders.TrackedRideBuilder.CanInvert
--- @return self
function TrackedRideBuilder:withCanInvert(canInvert)
    self.canInvert = TrackedRideBuilder.CanInvert[canInvert]
    return self
end

--- Sets whether this tracked ride can invert using a raw constant.
--- @param canInvert string
--- @return self
function TrackedRideBuilder:withRawCanInvert(canInvert)
    self.canInvert = canInvert
    return self
end

--- Sets the age group of this tracked ride using an enum key.
--- @param ageGroup forgeutils.builders.TrackedRideBuilder.AgeGroup
--- @return self
function TrackedRideBuilder:withAgeGroup(ageGroup)
    self.ageGroup = TrackedRideBuilder.AgeGroup[ageGroup]
    return self
end

--- Sets the age group of this tracked ride using a raw constant.
--- @param ageGroup string
--- @return self
function TrackedRideBuilder:withRawAgeGroup(ageGroup)
    self.ageGroup = ageGroup
    return self
end

--- Sets the menu of this tracked ride using an enum key.
--- @param menu forgeutils.builders.TrackedRideBuilder.TrackedRideMenu
--- @return self
function TrackedRideBuilder:withTrackedRideMenu(menu)
    self.trackedRideMenu = TrackedRideBuilder.TrackedRideMenu[menu]
    return self
end

--- Sets the menu of this tracked ride using a raw constant.
--- @param menu string
--- @return self
function TrackedRideBuilder:withRawTrackedRideMenu(menu)
    self.trackedRideMenu = menu
    return self
end

--- Validates the builder data.
--- @return boolean valid If the builder has errors.
function TrackedRideBuilder:hasErrors()
    local issues = false

    issues = check.IsNil("simulationData", self.simulationData) or issues
    issues = check.IsNil("rideData", self.rideData) or issues
    issues = check.IsNil("browserEntry", self.browserEntry) or issues
    issues = check.IsEmpty("trains", self.trains) or issues
    for _, param in ipairs(self.rideParams) do
        issues = rideParam.hasErrors(param) or issues
    end
    for _, fc in ipairs(self.flexicolours) do
        issues = flexicolour.hasErrors(fc) or issues
    end

    return issues
end

--- Adds the functionality to the DB.
function TrackedRideBuilder:addToDB()
    -- Ride data needs to be inserted first.
    require("forgeutils.builders.database.trackedride.ridedata").addToDb(self.id, self.contentPack, self.rideData)
    require("forgeutils.builders.database.trackedride.simulation").addToDb(self.id, self.simulationData)

    local trainDb = require("forgeutils.builders.database.trackedride.trains")
    for _, train in ipairs(self.trains) do
        trainDb.addToDb(self.id, train)
    end

    -- Add both default spline and default station from rideData
    db.ElementLists__Insert(self.id, self.rideData.splineElement)
    db.ElementLists__Insert(self.id, self.rideData.stationElement)

    for _, element in ipairs(self.elements) do
        db.ElementLists__Insert(self.id, element)
    end
    for _, param in ipairs(self.rideParams) do
        rideParam.addToDb(self.id, param)
    end

    -- Flexicolours
    for _, fc in ipairs(self.flexicolours) do
        flexicolour.addToDb(self.id, fc)
    end

    -- Metadata tags

    db.RideMetadataTags__Insert(self.id, self.trackedRideMenu)
    for _, tag in ipairs(self.extraMetadataTags) do
        db.RideMetadataTags__Insert(self.id, tag)
    end

    -- Tooltips

    db.BrowserTooltips__Insert(self.id, self.propulsionMethod)
    db.BrowserTooltips__Insert(self.id, self.canInvert)
    db.BrowserTooltips__Insert(self.id, self.ageGroup)

    for _, tooltip in ipairs(self.extraTooltips) do
        db.BrowserTooltips__Insert(self.id, tooltip)
    end

    require("forgeutils.builders.database.trackedride.browserentries").addToDb(self.id, self.browserEntry)
end

--- Tries to build the database.
function TrackedRideBuilder:tryBuild()
    return trybuild(self, logger)
end

return TrackedRideBuilder
