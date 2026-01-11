local global = _G
local setmetatable = global.setmetatable
local check = require("forgeutils.check")

--- @class forgeutils.builders.BaseBuilder
--- @field __index table
--- @field id string The ID
--- @field contentPack string Default = BaseGame
--- @field contentPackId integer Default = 0
local BaseBuilder = {}
BaseBuilder.__index = BaseBuilder

--- Creates a builder. Intended to be overriden.
--- @return self
function BaseBuilder.new()
    local instance = setmetatable({}, BaseBuilder)
    instance.contentPack = "BaseGame"
    return instance
end

--- Sets the ID.
--- @generic T
--- @param self T
--- @param id string
--- @return T
function BaseBuilder:withId(id)
    self.id = id
    return self
end

--- Sets the content pack.
--- @generic T
--- @param self T
--- @param contentPack string
--- @param contentPackId integer
--- @return T
function BaseBuilder:withContentPack(contentPack, contentPackId)
    self.contentPack = contentPack
    self.contentPackId = contentPackId
    return self
end

--- Validates the builder data.
--- Not intended to be used externally but can be if desired.
--- @return boolean valid If the builder contains valid data.
function BaseBuilder:validate()
    local issues = false
    issues = check.IsNil("ID", self.id) or issues
    issues = check.IsNil("contentPack", self.contentPack) or issues
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
