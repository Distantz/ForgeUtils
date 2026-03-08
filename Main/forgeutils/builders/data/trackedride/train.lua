local global = _G
local setmetatable = global.setmetatable

---@class forgeutils.builders.data.trackedride.Train
---@field trainId string
---@field numCars integer
---@field minCars integer
---@field maxCars integer
---@field poweredMinSpeed number?
---@field poweredMaxSpeed number?
---@field poweredDefaultSpeed number?
---@field poweredSpeedRangeMinDelta number?
---@field poweredSpeedRangeMaxDelta number?
---@field allowCrashTestDummies boolean?
---@field isRacing boolean?
---@field numPassesThroughStation integer?
---@field minNumPassesThroughStation integer?
---@field maxNumPassesThroughStation integer?
---@field hardMaxTrains integer?
---@field poweredBehaviour integer?
---@field poweredCanChangeBehaviour boolean?
---@field isDefaultTrainForRide boolean
local Train = {}
Train.__index = Train

--- Create a new Trains data object.
--- @return self
function Train.new()
    local self = setmetatable({}, Train)

    -- Sane defaults
    self.trainId = nil
    self.numCars = 4
    self.minCars = 1
    self.maxCars = 10
    self.isDefaultTrainForRide = true

    -- DB defaults
    self.poweredMinSpeed = nil
    self.poweredMaxSpeed = nil
    self.poweredDefaultSpeed = nil
    self.poweredSpeedRangeMinDelta = nil
    self.poweredSpeedRangeMaxDelta = nil
    self.allowCrashTestDummies = nil
    self.isRacing = nil
    self.numPassesThroughStation = nil
    self.minNumPassesThroughStation = nil
    self.maxNumPassesThroughStation = nil
    self.hardMaxTrains = nil
    self.poweredBehaviour = nil
    self.poweredCanChangeBehaviour = nil

    return self
end

--- @param trainId string
--- @return self
function Train:withTrainId(trainId)
    self.trainId = trainId
    return self
end

--- @param numCars integer
--- @return self
function Train:withNumCars(numCars)
    self.numCars = numCars
    return self
end

--- @param minCars integer
--- @return self
function Train:withMinCars(minCars)
    self.minCars = minCars
    return self
end

--- @param maxCars integer
--- @return self
function Train:withMaxCars(maxCars)
    self.maxCars = maxCars
    return self
end

--- @param poweredMinSpeed number?
--- @return self
function Train:withPoweredMinSpeed(poweredMinSpeed)
    self.poweredMinSpeed = poweredMinSpeed
    return self
end

--- @param poweredMaxSpeed number?
--- @return self
function Train:withPoweredMaxSpeed(poweredMaxSpeed)
    self.poweredMaxSpeed = poweredMaxSpeed
    return self
end

--- @param poweredDefaultSpeed number?
--- @return self
function Train:withPoweredDefaultSpeed(poweredDefaultSpeed)
    self.poweredDefaultSpeed = poweredDefaultSpeed
    return self
end

--- @param poweredSpeedRangeMinDelta number?
--- @return self
function Train:withPoweredSpeedRangeMinDelta(poweredSpeedRangeMinDelta)
    self.poweredSpeedRangeMinDelta = poweredSpeedRangeMinDelta
    return self
end

--- @param poweredSpeedRangeMaxDelta number?
--- @return self
function Train:withPoweredSpeedRangeMaxDelta(poweredSpeedRangeMaxDelta)
    self.poweredSpeedRangeMaxDelta = poweredSpeedRangeMaxDelta
    return self
end

--- @param allowCrashTestDummies boolean?
--- @return self
function Train:withAllowCrashTestDummies(allowCrashTestDummies)
    self.allowCrashTestDummies = allowCrashTestDummies
    return self
end

--- @param isRacing boolean?
--- @return self
function Train:withIsRacing(isRacing)
    self.isRacing = isRacing
    return self
end

--- @param numPassesThroughStation integer?
--- @return self
function Train:withNumPassesThroughStation(numPassesThroughStation)
    self.numPassesThroughStation = numPassesThroughStation
    return self
end

--- @param minNumPassesThroughStation integer?
--- @return self
function Train:withMinNumPassesThroughStation(minNumPassesThroughStation)
    self.minNumPassesThroughStation = minNumPassesThroughStation
    return self
end

--- @param maxNumPassesThroughStation integer?
--- @return self
function Train:withMaxNumPassesThroughStation(maxNumPassesThroughStation)
    self.maxNumPassesThroughStation = maxNumPassesThroughStation
    return self
end

--- @param hardMaxTrains integer?
--- @return self
function Train:withHardMaxTrains(hardMaxTrains)
    self.hardMaxTrains = hardMaxTrains
    return self
end

--- @param poweredBehaviour integer?
--- @return self
function Train:withPoweredBehaviour(poweredBehaviour)
    self.poweredBehaviour = poweredBehaviour
    return self
end

--- @param poweredCanChangeBehaviour boolean?
--- @return self
function Train:withPoweredCanChangeBehaviour(poweredCanChangeBehaviour)
    self.poweredCanChangeBehaviour = poweredCanChangeBehaviour
    return self
end

--- @param isDefaultTrainForRide boolean
--- @return self
function Train:withIsDefaultTrainForRide(isDefaultTrainForRide)
    self.isDefaultTrainForRide = isDefaultTrainForRide
    return self
end

return Train
