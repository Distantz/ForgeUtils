local global = _G
local api = global.api
local setmetatable = global.setmetatable
local pairs = global.pairs

local TrackedRideDBBindings = require("forgeutils.internal.database.TrackedRides")
local logger = require("forgeutils.logger").Get("FunctionalityBuilder")
local base = require("Main.forgeutils.builders.sub.trackedrides.basebuilder")

--- @class forgeutils.builders.sub.trackedrides.FunctionalityBuilder: forgeutils.builders.sub.trackedrides.BaseBuilder
--- @field __index table
local FunctionalityBuilder = {}
FunctionalityBuilder.__index = FunctionalityBuilder
setmetatable(FunctionalityBuilder, { __index = base })

--- Creates a builder.
--- @return self
function FunctionalityBuilder.new()
    local instance = setmetatable(base.new(), FunctionalityBuilder)
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
end

return FunctionalityBuilder
