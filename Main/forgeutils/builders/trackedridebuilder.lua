local global = _G
local api = global.api
local setmetatable = global.setmetatable
local ipairs = global.ipairs

local TrackedRideDBBindings = require("forgeutils.internal.database.TrackedRides")
local logger = require("forgeutils.logger").Get("TrackedRideBuilder")
local base = require("forgeutils.builders.basebuilder")
local check = require("forgeutils.check")

--- @class forgeutils.builders.sub.trackedrides.TrackedRideBuilder: forgeutils.builders.BaseBuilder
--- @field __index table
--- @field simulationData forgeutils.builders.data.trackedride.Simulation
--- @field rideData forgeutils.builders.data.trackedride.RideData
--- @field browserEntry forgeutils.builders.data.trackedride.BrowserEntry
--- @field trains forgeutils.builders.data.trackedride.Train[]
local TrackedRideBuilder = {}
TrackedRideBuilder.__index = TrackedRideBuilder
setmetatable(TrackedRideBuilder, { __index = base })

--- Creates a builder.
--- @return self
function TrackedRideBuilder.new()
    local self = setmetatable(base.new(), TrackedRideBuilder)
    self.trains = {}
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

--- Adds a train for this tracked ride.
--- @param train forgeutils.builders.data.trackedride.Train
--- @return self
function TrackedRideBuilder:withTrain(train)
    self.trains[#self.trains + 1] = train
    return self
end

--- Validates the builder data.
--- Not intended to be used externally but can be if desired.
--- @return boolean valid If the builder contains valid data.
function TrackedRideBuilder:validate()
    local issues = base.validate(self)
    issues = issues or check.IsNil("simulationData", self.simulationData)
    issues = issues or check.IsNil("rideData", self.rideData)
    issues = issues or check.IsNil("browserEntry", self.browserEntry)
    issues = issues or check.IsEmpty("trains", self.trains)
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

    require("forgeutils.builders.database.trackedride.browserentries").addToDb(self.id, self.browserEntry)
end

return TrackedRideBuilder
