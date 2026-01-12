local global = _G
local api = global.api
local setmetatable = global.setmetatable
local ipairs = global.ipairs

local db = require("forgeutils.internal.database.TrackedRides")
local logger = require("forgeutils.logger").Get("TrackedRideBuilder", "DEBUG_QUERY")
local base = require("forgeutils.builders.basebuilder")
local check = require("forgeutils.check")

local rideParams = require("forgeutils.builders.database.trackedride.rideparams")
local constants = require("forgeutils.builders.data.trackedride.constants")

--- @class forgeutils.builders.sub.trackedrides.TrackedRideBuilder: forgeutils.builders.BaseBuilder
--- @field __index table
--- @field simulationData forgeutils.builders.data.trackedride.Simulation
--- @field rideData forgeutils.builders.data.trackedride.RideData
--- @field browserEntry forgeutils.builders.data.trackedride.BrowserEntry
--- @field trains forgeutils.builders.data.trackedride.Train[]
--- @field elements string[]
--- @field params forgeutils.builders.data.trackedride.RideParam[]
--- @field metadataTags string[]
--- @field menuMetadataTag string
--- @field typeMetadataTag string
--- @field ageGroupMetadataTag string
local TrackedRideBuilder = {}
TrackedRideBuilder.__index = TrackedRideBuilder
setmetatable(TrackedRideBuilder, { __index = base })

--- Creates a builder.
--- @return self
function TrackedRideBuilder.new()
    local self = setmetatable(base.new(), TrackedRideBuilder)

    self.trains = {}
    self.elements = {}

    local rideParamsDefault = require("forgeutils.builders.data.trackedride.rideparam")
    self.params = {
        rideParamsDefault.LengthParam,
        rideParamsDefault.CatwalkParam,
        rideParamsDefault.SupportParam,
        rideParamsDefault.BankingOffsetParam,
        rideParamsDefault.CurveRangeParam,
        rideParamsDefault.SlopeRangeParam,
        rideParamsDefault.BankingRangeParam_Invert -- default is invert because our default is a thrill coaster.
    }
    self.metadataTags = {}
    self.menuMetadataTag = constants.MetadataTag_Menu_Coaster_ChainLift
    self.typeMetadataTag = constants.MetadataTag_Type_TrackedRide_Coaster
    self.ageGroupMetadataTag = constants.MetadataTag_Filter_AgeGroup_TeenAdult
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
    local issues = base.hasErrors(self)

    issues = check.IsNil("simulationData", self.simulationData) or issues
    issues = check.IsNil("rideData", self.rideData) or issues
    issues = check.IsNil("browserEntry", self.browserEntry) or issues
    issues = check.IsEmpty("trains", self.trains) or issues
    for _, param in ipairs(self.params) do
        issues = rideParams.hasErrors(param) or issues
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
    for _, param in ipairs(self.params) do
        rideParams.addToDb(self.id, param)
    end

    -- Metadata tags
    db.RideMetadataTags__Insert(self.id, self.menuMetadataTag)
    db.RideMetadataTags__Insert(self.id, self.typeMetadataTag)
    db.RideMetadataTags__Insert(self.id, self.ageGroupMetadataTag)
    for _, tag in ipairs(self.metadataTags) do
        db.RideMetadataTags__Insert(self.id, tag)
    end

    require("forgeutils.builders.database.trackedride.browserentries").addToDb(self.id, self.browserEntry)
end

return TrackedRideBuilder
