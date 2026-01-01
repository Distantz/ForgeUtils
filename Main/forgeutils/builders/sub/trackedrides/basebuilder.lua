local global = _G
local setmetatable = global.setmetatable
local check = require("forgeutils.validators")

--- @class forgeutils.builders.sub.trackedrides.BaseBuilder
--- @field __index table
--- @field rideID string The ride ID.
--- @field contentPack string The content pack. Default is BaseGame.
local BaseBuilder = {}
BaseBuilder.__index = BaseBuilder

--- Creates a builder. Intended to be overriden.
--- @return self
function BaseBuilder.new()
    local instance = setmetatable({}, BaseBuilder)
    instance.contentPack = "BaseGame"
    return instance
end

--- Sets the ID of the tracked ride.
--- @generic T
--- @param self T
--- @param id string
--- @return T
function BaseBuilder:withID(id)
    self.rideID = id
    return self
end

--- Sets the content pack of the tracked ride.
--- @generic T
--- @param self T
--- @param contentPack string
--- @return T
function BaseBuilder:withContentPack(contentPack)
    self.contentPack = contentPack
    return self
end

--- Validates the builder data.
--- Not intended to be used externally but can be if desired.
--- @return boolean valid If the builder contains valid data.
function BaseBuilder:validate()
    local issues = false
    issues = check.ValueNil("rideID", self.rideID) or issues
    issues = check.ValueNil("contentPack", self.contentPack) or issues
    return issues
end

--- Validates and, if no errors, executes the builder.
function BaseBuilder:tryBuild()
    if self:validate() then
        self:addToDB()
    end
end

--- Non-implemented stub. Intended to be overriden.
function BaseBuilder:addToDB()
end

return BaseBuilder
