local global = _G
local setmetatable = global.setmetatable

--- @class forgeutils.builders.data.element.ElementParam
--- @field element string
--- @field param string
--- @field min number
--- @field max number
--- @field initial number
--- @field step number
--- @field stepIsRelativeToMin integer?
--- @field labelOverride string?
--- @field valueLabelSetName string?
local ElementParams = {}
ElementParams.__index = ElementParams

--- Create a new ElementParams data object.
--- @return self
function ElementParams.new()
    local self = setmetatable({}, ElementParams)

    -- Sane defaults
    self.param = nil -- needs to be set
    self.min = 0
    self.max = 0
    self.initial = 0
    self.step = 0

    -- DB defaults
    self.stepIsRelativeToMin = nil
    self.labelOverride = nil
    self.valueLabelSetName = nil
    return self
end

--- @param param string
--- @return self
function ElementParams:withParam(param)
    self.param = param
    return self
end

--- @param min number
--- @return self
function ElementParams:withMin(min)
    self.min = min
    return self
end

--- @param max number
--- @return self
function ElementParams:withMax(max)
    self.max = max
    return self
end

--- @param initial number
--- @return self
function ElementParams:withInitial(initial)
    self.initial = initial
    return self
end

--- @param step number
--- @return self
function ElementParams:withStep(step)
    self.step = step
    return self
end

--- @param stepIsRelativeToMin integer?
--- @return self
function ElementParams:withStepRelativeToMin(stepIsRelativeToMin)
    self.stepIsRelativeToMin = stepIsRelativeToMin
    return self
end

--- @param labelOverride string?
--- @return self
function ElementParams:withLabelOverride(labelOverride)
    self.labelOverride = labelOverride
    return self
end

--- @param valueLabelSetName string?
--- @return self
function ElementParams:withValueLabelSetName(valueLabelSetName)
    self.valueLabelSetName = valueLabelSetName
    return self
end

return ElementParams
