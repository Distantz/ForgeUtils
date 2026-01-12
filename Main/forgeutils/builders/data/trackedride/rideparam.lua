local global = _G
local setmetatable = global.setmetatable

---@class forgeutils.builders.data.trackedride.RideParam
---@field param string
---@field min number
---@field max number
---@field initial number
---@field step number
---@field stepIsRelativeToMin integer?
---@field labelOverride string?
---@field valueLabelSetName string?
---@field absoluteMin number?
---@field absoluteMax number?
local RideParam = {}
RideParam.__index = RideParam

--- Create a new RideParams data object.
--- @return self
function RideParam.new()
    local self = setmetatable({}, RideParam)

    -- Sane defaults
    self.param = nil
    self.min = 0
    self.max = 0
    self.initial = 0
    self.step = 0

    -- DB defaults
    self.stepIsRelativeToMin = nil
    self.labelOverride = nil
    self.valueLabelSetName = nil
    self.absoluteMin = nil
    self.absoluteMax = nil

    return self
end

--- @param param string
--- @return self
function RideParam:withParam(param)
    self.param = param
    return self
end

--- @param min number
--- @return self
function RideParam:withMin(min)
    self.min = min
    return self
end

--- @param max number
--- @return self
function RideParam:withMax(max)
    self.max = max
    return self
end

--- @param initial number
--- @return self
function RideParam:withInitial(initial)
    self.initial = initial
    return self
end

--- @param step number
--- @return self
function RideParam:withStep(step)
    self.step = step
    return self
end

--- @param stepIsRelativeToMin integer
--- @return self
function RideParam:withStepIsRelativeToMin(stepIsRelativeToMin)
    self.stepIsRelativeToMin = stepIsRelativeToMin
    return self
end

--- @param labelOverride string
--- @return self
function RideParam:withLabelOverride(labelOverride)
    self.labelOverride = labelOverride
    return self
end

--- @param valueLabelSetName string
--- @return self
function RideParam:withValueLabelSetName(valueLabelSetName)
    self.valueLabelSetName = valueLabelSetName
    return self
end

--- @param absoluteMin number
--- @return self
function RideParam:withAbsoluteMin(absoluteMin)
    self.absoluteMin = absoluteMin
    return self
end

--- @param absoluteMax number
--- @return self
function RideParam:withAbsoluteMax(absoluteMax)
    self.absoluteMax = absoluteMax
    return self
end

-- Constants

--- The track length parameter name.
RideParam.LengthParamName = "LengthRangeMetres"

--- The support parameter name.
RideParam.SupportParamName = "DropSupports"

--- The catwalk parameter name.
RideParam.CatwalkParamName = "OptionalCatwalk"

--- The banking offset parameter name.
RideParam.BankingOffsetParamName = "BankPivotRange"

--- The tunnel radius parameter name.
RideParam.TunnelRadiusParamName = "TunnelRadius"

--- The curve range parameter name.
RideParam.CurveRangeParamName = "CurveRangeDegrees"

--- The bank range parameter name.
RideParam.SlopeRangeParamName = "SlopeRangeDegrees"

--- The bank range parameter name.
RideParam.BankingRangeParamName = "BankingRangeDegrees"

--- The track length parameter. 4m to 20m.
RideParam.LengthParam = RideParam.new()
    :withParam(RideParam.LengthParamName)
    :withMin(4)
    :withMax(20)
    :withInitial(12)
    :withStep(1)
    :withAbsoluteMin(-50000)
    :withAbsoluteMax(50000)

--- The support parameter. Allows enabling and disabling of supports.
RideParam.SupportParam = RideParam.new()
    :withParam(RideParam.SupportParamName)
    :withMin(0)
    :withMax(1)
    :withInitial(0)
    :withStep(1)

--- The catwalk parameter. Allows enabling and disabling of catwalks.
RideParam.CatwalkParam = RideParam.new()
    :withParam(RideParam.CatwalkParamName)
    :withMin(0)
    :withMax(1)
    :withInitial(0)
    :withStep(1)

--- The banking offset parameter. -2m to 2m, with 0.1 step.
RideParam.BankingOffsetParam = RideParam.new()
    :withParam(RideParam.BankingOffsetParamName)
    :withMin(-2)
    :withMax(2)
    :withInitial(0)
    :withStep(0.1)

--- The tunnel radius parameter. 4m to 7m.
RideParam.TunnelRadiusParam = RideParam.new()
    :withParam(RideParam.TunnelRadiusParamName)
    :withMin(4)
    :withMax(7)
    :withInitial(5)
    :withStep(1)

--- The curve range parameter. -90 to 90.
RideParam.CurveRangeParam = RideParam.new()
    :withParam(RideParam.CurveRangeParamName)
    :withMin(-90)
    :withMax(90)
    :withInitial(0)
    :withStep(0)

--- The slope range parameter. -90 to 90.
RideParam.SlopeRangeParam = RideParam.new()
    :withParam(RideParam.SlopeRangeParamName)
    :withMin(-90)
    :withMax(90)
    :withInitial(0)
    :withStep(0)

--- The bank range parameter for non-inverting rides. -90 to 90.
RideParam.BankingRangeParam_NoInvert = RideParam.new()
    :withParam(RideParam.BankingRangeParamName)
    :withMin(-90)
    :withMax(90)
    :withInitial(0)
    :withStep(0)
    :withAbsoluteMin(-50000)
    :withAbsoluteMax(50000)

--- The bank range parameter for inverting rides. Default is -50000 to 50000.
RideParam.BankingRangeParam_Invert = RideParam.new()
    :withParam(RideParam.BankingRangeParamName)
    :withMin(-50000)
    :withMax(50000)
    :withInitial(0)
    :withStep(0)

return RideParam
