local global = _G
local db = require("forgeutils.internal.database.TrackedRideCars")

--- @class forgeutils.builders.database.train.Trains
local Trains = {}
Trains.__index = Trains

--- Adds train data to the database
--- @param trainId string The unique ID for this train
--- @param trainData forgeutils.builders.data.train.TrainData
function Trains.addToDb(trainId, trainData)
    -- Insert required fields first
    db.Trains__Insert(
        trainId,
        trainData.canAddOffStation
    )

    -- Update all other fields
    db.Trains__Update__StaticFriction(trainId, trainData.staticFriction)

    db.Trains__Update__AirResistance(trainId, trainData.airResistance)

    db.Trains__Update__DynamicFriction(trainId, trainData.dynamicFriction)

    if trainData.dynamicFrictionAlternate ~= nil then
        db.Trains__Update__DynamicFriction_Alternate(trainId, trainData.dynamicFrictionAlternate)
    end

    db.Trains__Update__LuaScoringModule(trainId, trainData.luaScoringModule)

    if trainData.baseExcitement ~= nil then
        db.Trains__Update__BaseExcitement(trainId, trainData.baseExcitement)
    end

    if trainData.baseFear ~= nil then
        db.Trains__Update__BaseFear(trainId, trainData.baseFear)
    end

    if trainData.baseNausea ~= nil then
        db.Trains__Update__BaseNausea(trainId, trainData.baseNausea)
    end

    -- Audio stuff
    db.Trains__Update__AudioSpeedThreshold(trainId, trainData.audioSpeedThreshold)
    db.Trains__Update__AudioAccnThreshold(trainId, trainData.audioAccnThreshold)
    db.Trains__Update__AudioWeightThreshold(trainId, trainData.audioWeightThreshold)
    db.Trains__Update__AudioLateralThreshold(trainId, trainData.audioLateralThreshold)
    db.Trains__Update__AudioUseFrontAxelForFlanges(trainId, trainData.audioUseFrontAxelForFlanges)
    db.Trains__Update__AudioIgnoreFrontCarForFlanges(trainId, trainData.audioIgnoreFrontCarForFlanges)
    db.Trains__Update__AudioIgnoreRearCarForFlanges(trainId, trainData.audioIgnoreRearCarForFlanges)
    db.Trains__Update__AudioIgnoreMidCarsForFlanges(trainId, trainData.audioIgnoreMidCarsForFlanges)

    -- Audio prefixes
    db.Trains__Update__AudioChainLiftPrefix(trainId, trainData.audioChainLiftPrefix)
    db.Trains__Update__AudioBrakePrefix(trainId, trainData.audioBrakePrefix)

    -- Music settings
    db.Trains__Update__DefaultRideMusic(trainId, trainData.defaultRideMusic)
    db.Trains__Update__UniqueEngineSound(trainId, trainData.uniqueEngineSound)
    db.Trains__Update__PlayMusicContinuously(trainId, trainData.playMusicContinuously)
    db.Trains__Update__PlayMusicOnAllCarsSimultaneously(trainId, trainData.playMusicOnAllCarsSimultaneously)

    -- Guest audio behavior
    db.Trains__Update__AudioGuestsUseExcitement(trainId, trainData.audioGuestsUseExcitement)
    db.Trains__Update__AudioGuestsUseFear(trainId, trainData.audioGuestsUseFear)
    db.Trains__Update__AudioGuestsUseSpecialBehaviour(trainId, trainData.audioGuestsUseSpecialBehaviour)

    -- Transport and coaster settings
    db.Trains__Update__UseTransportRideMusic(trainId, trainData.useTransportRideMusic)
    db.Trains__Update__TreatAsCoaster(trainId, trainData.treatAsCoaster)
    db.Trains__Update__AudioMaxRange(trainId, trainData.audioMaxRange)

    -- Catch car configuration
    if trainData.catchTrainType ~= nil then
        db.Trains__Update__CatchTrainType(trainId, trainData.catchTrainType)
    end

    db.Trains__Update__NumCatchCars(trainId, trainData.numCatchCars)

    if trainData.reverseCatchTrainType ~= nil then
        db.Trains__Update__ReverseCatchTrainType(trainId, trainData.reverseCatchTrainType)
    end

    db.Trains__Update__NumReverseCatchCars(trainId, trainData.numReverseCatchCars)

    if trainData.splitCatchTrainType ~= nil then
        db.Trains__Update__SplitCatchTrainType(trainId, trainData.splitCatchTrainType)
    end

    db.Trains__Update__SplitNormalTrainDelay(trainId, trainData.splitNormalTrainDelay)

    -- Audio prefix override
    if trainData.audioPrefixOverride ~= nil then
        db.Trains__Update__AudioPrefixOverride(trainId, trainData.audioPrefixOverride)
    end

    -- random stuff
    db.Trains__Update__UseMirrorCarRotation(trainId, trainData.useMirrorCarRotation)
    db.Trains__Update__ForceCarAttachOffsetYToZero(trainId, trainData.forceCarAttachOffsetYToZero)
    db.Trains__Update__ForceCarAttachOffsetYToValue(trainId, trainData.forceCarAttachOffsetYToValue)

    -- Water slide and cabin settings
    db.Trains__Update__AudioCabinIsEnclosed(trainId, trainData.audioCabinIsEnclosed)
    db.Trains__Update__IsWaterSlideTrain(trainId, trainData.isWaterSlideTrain)
end

return Trains
