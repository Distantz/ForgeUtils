local global = _G
---@type Api
---@diagnostic disable-next-line: undefined-field
local api = global.api
local setmetatable = global.setmetatable
local ipairs = global.ipairs

local check = require("forgeutils.check")
local logger = require("forgeutils.logger").Get("ElementParamLabelBuilder")
local trybuild = require("forgeutils.builders.utils.trybuild")

--- @class forgeutils.builders.train.ElementParamLabelBuilder
--- @field __index table
--- @field id string
--- @field labels { [integer]: string }
local ElementParamLabelBuilder = {}
ElementParamLabelBuilder.__index = ElementParamLabelBuilder

--- Creates a new ElementBuilder.
--- @return self
function ElementParamLabelBuilder.new()
    local self = setmetatable({}, ElementParamLabelBuilder)
    self.id = nil
    self.labels = {}
    return self
end

--- Sets the ID.
--- @param id string
--- @return self
function ElementParamLabelBuilder:withId(id)
    self.id = id
    return self
end

--- Adds a label pair.
---@param paramValue integer
---@param label string
---@return self
function ElementParamLabelBuilder:withLabel(paramValue, label)
    self.labels[paramValue] = label
    return self
end

--- Validates the builder data.
--- @return boolean valid If the builder has errors.
function ElementParamLabelBuilder:hasErrors()
    local issues = false
    issues = check.IsNil("id", self.id) or issues
    issues = check.IsNil("self.labels", self.labels) or issues
    issues = check.IsEmpty("self.labels", self.labels) or issues
    return issues
end

--- Adds the train and cars to the database.
function ElementParamLabelBuilder:addToDB()
    -- Insert train data first
    local db = require("forgeutils.internal.database.TrackedRides")
    for value, label in global.ipairs(self.labels) do
        db.ElementParamValueLabels__Insert(
            self.id,
            value,
            label
        )
    end
end

--- Tries to build the database.
function ElementParamLabelBuilder:tryBuild()
    return trybuild(self, logger)
end

return ElementParamLabelBuilder
