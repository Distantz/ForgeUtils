local global = _G
local api = global.api
local setmetatable = global.setmetatable
local pairs = global.pairs

local TrackedRideDBBindings = require("forgeutils.internal.database.TrackedRides")
local logger = require("forgeutils.logger").Get("FunctionalityBuilder")
local base = require("Main.forgeutils.builders.sub.trackedrides.basebuilder")

--- @class forgeutils.builders.sub.trackedrides.FunctionalityBuilder: forgeutils.builders.sub.trackedrides.BaseBuilder
--- @field __index table
---
--- RideData
--- @field trackCost number Default = 1.0
--- @field breakdownTimeMultiplier number Default = 3.0
--- @field maxTrackHeightFeet number Default = 399
--- @field defaultSplineElement string Default = "default_spline"
--- @field defaultStationElement string Default = "station_leftleft"
--- @field supportsBlockSections boolean Default = true
---
--- Simulation
--- @field excitement number Default = 5.0
--- @field intensity number Default = 5.0
--- @field nausea number Default = 2.0
--- @field prestige integer Default = 100
--- @field ticketCost integer Default = 1000
---
--- Utility
--- @field utilityType "Power" | "Water" Default = "Power"
--- @field utilityAmount number Default = 30.0
local FunctionalityBuilder = {}
FunctionalityBuilder.__index = FunctionalityBuilder
setmetatable(FunctionalityBuilder, { __index = base })

--- Creates a builder.
--- @return self
function FunctionalityBuilder.new()
    local instance = setmetatable(base.new(), FunctionalityBuilder)

    -- RideData
    instance.trackCost = 1.0
    instance.breakdownTimeMultiplier = 3.0
    instance.maxTrackHeightFeet = 399
    instance.defaultSplineElement = "default_spline"
    instance.defaultStationElement = "station_leftleft"
    instance.supportsBlockSections = true

    -- Simulation
    instance.excitement = 5.0
    instance.intensity = 5.0
    instance.nausea = 2.0
    instance.prestige = 100
    instance.ticketCost = 1000

    -- Utility
    instance.utilityType = "Power"
    instance.utilityAmount = 30
    return instance
end

--- Test
---@param test string
---@return self
function FunctionalityBuilder:withTest(test)
    return self
end

--- Validates the builder data.
--- Not intended to be used externally but can be if desired.
--- @return boolean valid If the builder contains valid data.
function FunctionalityBuilder:validate()
    local issues = base.validate(self)
    return issues
end

--- Adds the functionality to the DB.
function FunctionalityBuilder:addToDB()
    TrackedRideDBBindings.RideData__Insert(
        self.rideID,
        self.trackCost,
        self.breakdownTimeMultiplier,
        self.maxTrackHeightFeet,
        self.defaultSplineElement,
        self.defaultStationElement,
        self.supportsBlockSections,
        self.contentPack
    )

    TrackedRideDBBindings.Simulation__Insert(
        self.rideID,
        self.excitement,
        self.intensity,
        self.nausea,
        self.prestige,
        self.ticketCost
    )

    TrackedRideDBBindings.UtilityConsumer__Insert(
        self.rideID,
        self.utilityType,
        self.utilityAmount
    )
end

return FunctionalityBuilder
