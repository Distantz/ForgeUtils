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
--- @field metadataTags string[]
--- @field menuMetadataTag string
--- @field typeMetadataTag string
--- @field ageGroupMetadataTag string
--- @field manufacturerTag string
--- @field tooltips string[]
local TrackedRideBuilder = {}
TrackedRideBuilder.__index = TrackedRideBuilder

--- Creates a builder.
--- @return self
function TrackedRideBuilder.new()
    local self = setmetatable({}, TrackedRideBuilder)

    self.id = nil
    self.contentPack = contentPack:new()
    self.trains = {}
    self.elements = {}
    self.flexicolours = {}

    local rideParamDefault = require("forgeutils.builders.data.trackedride.rideparam")
    self.rideParams = {
        rideParamDefault.LengthParam,
        rideParamDefault.CatwalkParam,
        rideParamDefault.SupportParam,
        rideParamDefault.BankingOffsetParam,
        rideParamDefault.CurveRangeParam,
        rideParamDefault.SlopeRangeParam,
        rideParamDefault.TunnelRadiusParam,
        rideParamDefault.BankingRangeParam_Invert -- default is invert because our default is a thrill coaster.
    }
    self.metadataTags = {}
    self.menuMetadataTag = constants.MetadataTags_Menu_Coaster_ChainLift
    self.typeMetadataTag = constants.MetadataTags_Type_TrackedRide_Coaster
    self.ageGroupMetadataTag = constants.MetadataTags_Filter_AgeGroup_TeenAdult
    self.manufacturerTag = constants.MetadataTags_Coaster_Manufacturer_BigMsRides

    self.tooltips = {
        "TrackFeature_ChainLift",
        "TrackFeature_CanInvert",
        "TrackFeature_ForAdultsAndTeensOnly"
    }
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

--- Adds a spline element for this tracked ride.
--- @param element string
--- @return self
function TrackedRideBuilder:withElement(element)
    self.elements[#self.elements + 1] = element
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

--- Adds a spline element for this tracked ride.
--- @param rideParam forgeutils.builders.data.trackedride.RideParam
--- @return self
function TrackedRideBuilder:withRideParam(rideParam)
    self.rideParams[#self.rideParams + 1] = rideParam
    return self
end

--- Adds a metadata tag to this tracked ride.
--- @param tag string
--- @return self
function TrackedRideBuilder:withMetadataTag(tag)
    self.metadataTags[#self.metadataTags + 1] = tag
    return self
end

--- Sets the menu tag of this tracked ride.
--- @param tag string
--- @return self
function TrackedRideBuilder:withMenuTag(tag)
    self.menuMetadataTag = tag
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
    db.RideMetadataTags__Insert(self.id, self.menuMetadataTag)
    db.RideMetadataTags__Insert(self.id, self.typeMetadataTag)
    db.RideMetadataTags__Insert(self.id, self.ageGroupMetadataTag)
    db.RideMetadataTags__Insert(self.id, self.manufacturerTag)
    for _, tag in ipairs(self.metadataTags) do
        db.RideMetadataTags__Insert(self.id, tag)
    end

    for _, tooltip in ipairs(self.tooltips) do
        db.BrowserTooltips__Insert(self.id, tooltip)
    end

    require("forgeutils.builders.database.trackedride.browserentries").addToDb(self.id, self.browserEntry)
end

--- Tries to build the database.
function TrackedRideBuilder:tryBuild()
    return trybuild(self, logger)
end

return TrackedRideBuilder
