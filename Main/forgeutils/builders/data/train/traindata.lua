local global = _G
local setmetatable = global.setmetatable

---@class forgeutils.builders.data.train.TrainData
---@field staticFriction number
---@field airResistance number
---@field dynamicFriction number
---@field dynamicFrictionAlternate number?
---@field luaScoringModule string
---@field baseExcitement number?
---@field baseFear number?
---@field baseNausea number?
---@field canAddOffStation boolean
---@field audioSpeedThreshold number
---@field audioAccnThreshold number
---@field audioWeightThreshold number
---@field audioLateralThreshold number
---@field audioUseFrontAxelForFlanges number
---@field audioIgnoreFrontCarForFlanges number
---@field audioIgnoreRearCarForFlanges number
---@field audioIgnoreMidCarsForFlanges number
---@field audioChainLiftPrefix string
---@field audioBrakePrefix string
---@field defaultRideMusic string
---@field uniqueEngineSound number
---@field playMusicContinuously boolean
---@field playMusicOnAllCarsSimultaneously boolean
---@field audioGuestsUseExcitement boolean
---@field audioGuestsUseFear boolean
---@field audioGuestsUseSpecialBehaviour boolean
---@field useTransportRideMusic boolean
---@field treatAsCoaster boolean
---@field audioMaxRange number
---@field catchTrainType string?
---@field numCatchCars integer
---@field reverseCatchTrainType string?
---@field numReverseCatchCars integer
---@field splitCatchTrainType string?
---@field splitNormalTrainDelay number
---@field audioPrefixOverride string?
---@field useMirrorCarRotation boolean
---@field forceCarAttachOffsetYToZero boolean
---@field forceCarAttachOffsetYToValue number
---@field audioCabinIsEnclosed boolean
---@field isWaterSlideTrain integer
local TrainData = {}
TrainData.__index = TrainData

--- Create a new TrainData object.
--- @return self
function TrainData.new()
    local self = setmetatable({}, TrainData)

    -- Sane defaults based on most common coaster values
    self.staticFriction = 0.06
    self.airResistance = 0.46
    self.dynamicFriction = 0.35
    self.luaScoringModule = "CoasterScoring"
    self.canAddOffStation = false

    -- Audio constants
    self.audioSpeedThreshold = 25.0
    self.audioAccnThreshold = 30.0
    self.audioWeightThreshold = 100.0
    self.audioLateralThreshold = 50.0
    self.audioUseFrontAxelForFlanges = 0.0

    -- Audio defaults
    self.audioIgnoreFrontCarForFlanges = 0.0
    self.audioIgnoreRearCarForFlanges = 1.0
    self.audioIgnoreMidCarsForFlanges = 1.0
    self.audioChainLiftPrefix = "Mtl"
    self.audioBrakePrefix = "Fri"
    self.defaultRideMusic = "NO_MUSIC"
    self.uniqueEngineSound = 0.0
    self.playMusicContinuously = false
    self.playMusicOnAllCarsSimultaneously = false
    self.audioGuestsUseExcitement = true
    self.audioGuestsUseFear = true
    self.audioGuestsUseSpecialBehaviour = true
    self.useTransportRideMusic = false
    self.treatAsCoaster = true
    self.audioMaxRange = 500.0

    -- Catch car stuff
    self.numCatchCars = 0
    self.numReverseCatchCars = 0
    self.splitNormalTrainDelay = 0.0

    -- Other defaults
    self.useMirrorCarRotation = false
    self.forceCarAttachOffsetYToZero = false
    self.forceCarAttachOffsetYToValue = 0.0
    self.audioCabinIsEnclosed = false
    self.isWaterSlideTrain = 0

    -- DB nullables
    self.dynamicFrictionAlternate = nil
    self.baseExcitement = nil
    self.baseFear = nil
    self.baseNausea = nil
    self.catchTrainType = nil
    self.reverseCatchTrainType = nil
    self.splitCatchTrainType = nil
    self.audioPrefixOverride = nil

    return self
end

--- @param staticFriction number
--- @return self
function TrainData:withStaticFriction(staticFriction)
    self.staticFriction = staticFriction
    return self
end

--- @param airResistance number
--- @return self
function TrainData:withAirResistance(airResistance)
    self.airResistance = airResistance
    return self
end

--- @param dynamicFriction number
--- @return self
function TrainData:withDynamicFriction(dynamicFriction)
    self.dynamicFriction = dynamicFriction
    return self
end

--- @param dynamicFrictionAlternate number?
--- @return self
function TrainData:withDynamicFrictionAlternate(dynamicFrictionAlternate)
    self.dynamicFrictionAlternate = dynamicFrictionAlternate
    return self
end

--- @param luaScoringModule string
--- @return self
function TrainData:withLuaScoringModule(luaScoringModule)
    self.luaScoringModule = luaScoringModule
    return self
end

--- @param baseExcitement number?
--- @return self
function TrainData:withBaseExcitement(baseExcitement)
    self.baseExcitement = baseExcitement
    return self
end

--- @param baseFear number?
--- @return self
function TrainData:withBaseFear(baseFear)
    self.baseFear = baseFear
    return self
end

--- @param baseNausea number?
--- @return self
function TrainData:withBaseNausea(baseNausea)
    self.baseNausea = baseNausea
    return self
end

--- @param canAddOffStation boolean
--- @return self
function TrainData:withCanAddOffStation(canAddOffStation)
    self.canAddOffStation = canAddOffStation
    return self
end

--- @param audioIgnoreFrontCarForFlanges number
--- @return self
function TrainData:withAudioIgnoreFrontCarForFlanges(audioIgnoreFrontCarForFlanges)
    self.audioIgnoreFrontCarForFlanges = audioIgnoreFrontCarForFlanges
    return self
end

--- @param audioIgnoreRearCarForFlanges number
--- @return self
function TrainData:withAudioIgnoreRearCarForFlanges(audioIgnoreRearCarForFlanges)
    self.audioIgnoreRearCarForFlanges = audioIgnoreRearCarForFlanges
    return self
end

--- @param audioIgnoreMidCarsForFlanges number
--- @return self
function TrainData:withAudioIgnoreMidCarsForFlanges(audioIgnoreMidCarsForFlanges)
    self.audioIgnoreMidCarsForFlanges = audioIgnoreMidCarsForFlanges
    return self
end

--- @param audioChainLiftPrefix string
--- @return self
function TrainData:withAudioChainLiftPrefix(audioChainLiftPrefix)
    self.audioChainLiftPrefix = audioChainLiftPrefix
    return self
end

--- @param audioBrakePrefix string
--- @return self
function TrainData:withAudioBrakePrefix(audioBrakePrefix)
    self.audioBrakePrefix = audioBrakePrefix
    return self
end

--- @param defaultRideMusic string
--- @return self
function TrainData:withDefaultRideMusic(defaultRideMusic)
    self.defaultRideMusic = defaultRideMusic
    return self
end

--- @param uniqueEngineSound number
--- @return self
function TrainData:withUniqueEngineSound(uniqueEngineSound)
    self.uniqueEngineSound = uniqueEngineSound
    return self
end

--- @param playMusicContinuously boolean
--- @return self
function TrainData:withPlayMusicContinuously(playMusicContinuously)
    self.playMusicContinuously = playMusicContinuously
    return self
end

--- @param playMusicOnAllCarsSimultaneously boolean
--- @return self
function TrainData:withPlayMusicOnAllCarsSimultaneously(playMusicOnAllCarsSimultaneously)
    self.playMusicOnAllCarsSimultaneously = playMusicOnAllCarsSimultaneously
    return self
end

--- @param audioGuestsUseExcitement boolean
--- @return self
function TrainData:withAudioGuestsUseExcitement(audioGuestsUseExcitement)
    self.audioGuestsUseExcitement = audioGuestsUseExcitement
    return self
end

--- @param audioGuestsUseFear boolean
--- @return self
function TrainData:withAudioGuestsUseFear(audioGuestsUseFear)
    self.audioGuestsUseFear = audioGuestsUseFear
    return self
end

--- @param audioGuestsUseSpecialBehaviour boolean
--- @return self
function TrainData:withAudioGuestsUseSpecialBehaviour(audioGuestsUseSpecialBehaviour)
    self.audioGuestsUseSpecialBehaviour = audioGuestsUseSpecialBehaviour
    return self
end

--- @param useTransportRideMusic boolean
--- @return self
function TrainData:withUseTransportRideMusic(useTransportRideMusic)
    self.useTransportRideMusic = useTransportRideMusic
    return self
end

--- @param treatAsCoaster boolean
--- @return self
function TrainData:withTreatAsCoaster(treatAsCoaster)
    self.treatAsCoaster = treatAsCoaster
    return self
end

--- @param audioMaxRange number
--- @return self
function TrainData:withAudioMaxRange(audioMaxRange)
    self.audioMaxRange = audioMaxRange
    return self
end

--- @param catchTrainType string?
--- @return self
function TrainData:withCatchTrainType(catchTrainType)
    self.catchTrainType = catchTrainType
    return self
end

--- @param numCatchCars integer
--- @return self
function TrainData:withNumCatchCars(numCatchCars)
    self.numCatchCars = numCatchCars
    return self
end

--- @param reverseCatchTrainType string?
--- @return self
function TrainData:withReverseCatchTrainType(reverseCatchTrainType)
    self.reverseCatchTrainType = reverseCatchTrainType
    return self
end

--- @param numReverseCatchCars integer
--- @return self
function TrainData:withNumReverseCatchCars(numReverseCatchCars)
    self.numReverseCatchCars = numReverseCatchCars
    return self
end

--- @param splitCatchTrainType string?
--- @return self
function TrainData:withSplitCatchTrainType(splitCatchTrainType)
    self.splitCatchTrainType = splitCatchTrainType
    return self
end

--- @param splitNormalTrainDelay number
--- @return self
function TrainData:withSplitNormalTrainDelay(splitNormalTrainDelay)
    self.splitNormalTrainDelay = splitNormalTrainDelay
    return self
end

--- @param audioPrefixOverride string?
--- @return self
function TrainData:withAudioPrefixOverride(audioPrefixOverride)
    self.audioPrefixOverride = audioPrefixOverride
    return self
end

--- @param audioCabinIsEnclosed boolean
--- @return self
function TrainData:withAudioCabinIsEnclosed(audioCabinIsEnclosed)
    self.audioCabinIsEnclosed = audioCabinIsEnclosed
    return self
end

--- @param isWaterSlideTrain integer
--- @return self
function TrainData:withIsWaterSlideTrain(isWaterSlideTrain)
    self.isWaterSlideTrain = isWaterSlideTrain
    return self
end

return TrainData
