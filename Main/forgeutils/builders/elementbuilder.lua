local global = _G
---@type Api
---@diagnostic disable-next-line: undefined-field
local api = global.api
local setmetatable = global.setmetatable
local ipairs = global.ipairs

local check = require("forgeutils.check")
local logger = require("forgeutils.logger").Get("ElementBuilder")
local trybuild = require("forgeutils.builders.utils.trybuild")
local elementDataDb = require("forgeutils.builders.database.element.elementdata")
local elementParamDb = require("forgeutils.builders.database.element.elementparam")

--- @class forgeutils.builders.train.ElementBuilder
--- @field __index table
--- @field id string
--- @field elementData forgeutils.builders.data.element.ElementData
--- @field elementParams forgeutils.builders.data.element.ElementParam[]
--- @field rideParams string[]
local ElementBuilder = {}
ElementBuilder.__index = ElementBuilder

--- Creates a new ElementBuilder.
--- @return self
function ElementBuilder.new()
    local self = setmetatable({}, ElementBuilder)
    self.id = nil
    self.elementData = nil
    self.elementParams = {}
    self.rideParams = {}
    return self
end

--- Sets the ID.
--- @param id string
--- @return self
function ElementBuilder:withId(id)
    self.id = id
    return self
end

--- Adds element data.
--- @param elementData forgeutils.builders.data.element.ElementData
--- @return self
function ElementBuilder:withElementData(elementData)
    self.elementData = elementData
    return self
end

--- Adds an element parameter to this element.
--- @param elementParam forgeutils.builders.data.element.ElementParam
--- @return self
function ElementBuilder:withElementParam(elementParam)
    self.elementParams[#self.elementParams + 1] = elementParam
    return self
end

--- Adds element parameters to this element.
--- @param elementParams forgeutils.builders.data.element.ElementParam[]
--- @return self
function ElementBuilder:withElementParams(elementParams)
    for _, param in global.ipairs(elementParams) do
        self:withElementParam(param)
    end
    return self
end

--- Sets this element to use this ride parameter.
--- @param rideParam string
--- @return self
function ElementBuilder:withRideParam(rideParam)
    self.rideParams[#self.rideParams + 1] = rideParam
    return self
end

--- Sets this element to use these ride parameters.
--- @param rideParams string[]
--- @return self
function ElementBuilder:withRideParams(rideParams)
    for _, param in global.ipairs(rideParams) do
        self:withRideParam(param)
    end
    return self
end

--- Validates the builder data.
--- @return boolean valid If the builder has errors.
function ElementBuilder:hasErrors()
    local issues = false
    issues = check.IsNil("id", self.id) or issues

    issues = check.IsNil("elementData", self.elementData) or issues
    issues = elementDataDb.hasErrors(self.elementData) or issues

    issues = check.IsEmpty("elementParams", self.elementParams) or issues
    for _, param in global.ipairs(self.elementParams) do
        issues = elementParamDb.hasErrors(param) or issues
    end
    return issues
end

--- Adds the train and cars to the database.
function ElementBuilder:addToDB()
    -- Insert train data first
    local db = require("forgeutils.internal.database.TrackedRides")

    elementDataDb.addToDb(self.id, self.elementData)

    for _, param in global.ipairs(self.elementParams) do
        elementParamDb.addToDb(self.id, param)
    end

    for _, rideParam in global.ipairs(self.rideParams) do
        db.ElementUsesRideParams__Insert(
            self.id,
            rideParam
        )
    end
end

--- Tries to build the database.
function ElementBuilder:tryBuild()
    return trybuild(self, logger)
end

return ElementBuilder
