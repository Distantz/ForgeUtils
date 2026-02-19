local global = _G
local db = require("forgeutils.internal.database.TrackedRideCars")
local logger = require("forgeutils.logger").Get("TrainBuilder.Database.Trains", "INFO")

--- @class forgeutils.builders.database.train.Trains
local Trains = {}
Trains.__index = Trains

--- Adds train data to the database
--- @param trainId string The unique ID for this train
--- @param trainData forgeutils.builders.data.train.TrainData
function Trains.addToDb(trainId, trainData)
    logger:Info("===== INSERTING TRAIN: " .. trainId .. " =====")

    -- Insert required fields first
    logger:Info("  Trains__Insert(" .. trainId .. ", " .. tostring(trainData.canAddOffStation) .. ")")
    db.Trains__Insert(
        trainId,
        trainData.canAddOffStation
    )

    -- Update all other fields
    logger:Info("  StaticFriction = " .. tostring(trainData.staticFriction))
    db.Trains__Update__StaticFriction(trainId, trainData.staticFriction)

    logger:Info("  AirResistance = " .. tostring(trainData.airResistance))
    db.Trains__Update__AirResistance(trainId, trainData.airResistance)

    logger:Info("  DynamicFriction = " .. tostring(trainData.dynamicFriction))
    db.Trains__Update__DynamicFriction(trainId, trainData.dynamicFriction)

    if trainData.dynamicFrictionAlternate ~= nil then
        logger:Info("  DynamicFriction_Alternate = " .. tostring(trainData.dynamicFrictionAlternate))
        db.Trains__Update__DynamicFriction_Alternate(trainId, trainData.dynamicFrictionAlternate)
    else
        logger:Info("  DynamicFriction_Alternate = nil (skipped)")
    end

    logger:Info("  LuaScoringModule = " .. tostring(trainData.luaScoringModule))
    db.Trains__Update__LuaScoringModule(trainId, trainData.luaScoringModule)

    if trainData.baseExcitement ~= nil then
        logger:Info("  BaseExcitement = " .. tostring(trainData.baseExcitement))
        db.Trains__Update__BaseExcitement(trainId, trainData.baseExcitement)
    else
        logger:Info("  BaseExcitement = nil (skipped)")
    end

    if trainData.baseFear ~= nil then
        logger:Info("  BaseFear = " .. tostring(trainData.baseFear))
        db.Trains__Update__BaseFear(trainId, trainData.baseFear)
    else
        logger:Info("  BaseFear = nil (skipped)")
    end

    if trainData.baseNausea ~= nil then
        logger:Info("  BaseNausea = " .. tostring(trainData.baseNausea))
        db.Trains__Update__BaseNausea(trainId, trainData.baseNausea)
    else
        logger:Info("  BaseNausea = nil (skipped)")
    end

    -- Audio thresholds (constants, but set for completeness)
    logger:Info("  AudioSpeedThreshold = " .. tostring(trainData.audioSpeedThreshold))
    db.Trains__Update__AudioSpeedThreshold(trainId, trainData.audioSpeedThreshold)

    logger:Info("  AudioAccnThreshold = " .. tostring(trainData.audioAccnThreshold))
    db.Trains__Update__AudioAccnThreshold(trainId, trainData.audioAccnThreshold)

    logger:Info("  AudioWeightThreshold = " .. tostring(trainData.audioWeightThreshold))
    db.Trains__Update__AudioWeightThreshold(trainId, trainData.audioWeightThreshold)

    logger:Info("  AudioLateralThreshold = " .. tostring(trainData.audioLateralThreshold))
    db.Trains__Update__AudioLateralThreshold(trainId, trainData.audioLateralThreshold)

    logger:Info("  AudioUseFrontAxelForFlanges = " .. tostring(trainData.audioUseFrontAxelForFlanges))
    db.Trains__Update__AudioUseFrontAxelForFlanges(trainId, trainData.audioUseFrontAxelForFlanges)

    -- Audio flange settings
    logger:Info("  AudioIgnoreFrontCarForFlanges = " .. tostring(trainData.audioIgnoreFrontCarForFlanges))
    db.Trains__Update__AudioIgnoreFrontCarForFlanges(trainId, trainData.audioIgnoreFrontCarForFlanges)

    logger:Info("  AudioIgnoreRearCarForFlanges = " .. tostring(trainData.audioIgnoreRearCarForFlanges))
    db.Trains__Update__AudioIgnoreRearCarForFlanges(trainId, trainData.audioIgnoreRearCarForFlanges)

    logger:Info("  AudioIgnoreMidCarsForFlanges = " .. tostring(trainData.audioIgnoreMidCarsForFlanges))
    db.Trains__Update__AudioIgnoreMidCarsForFlanges(trainId, trainData.audioIgnoreMidCarsForFlanges)

    -- Audio prefixes
    logger:Info("  AudioChainLiftPrefix = " .. tostring(trainData.audioChainLiftPrefix))
    db.Trains__Update__AudioChainLiftPrefix(trainId, trainData.audioChainLiftPrefix)

    logger:Info("  AudioBrakePrefix = " .. tostring(trainData.audioBrakePrefix))
    db.Trains__Update__AudioBrakePrefix(trainId, trainData.audioBrakePrefix)

    -- Music settings
    logger:Info("  DefaultRideMusic = " .. tostring(trainData.defaultRideMusic))
    db.Trains__Update__DefaultRideMusic(trainId, trainData.defaultRideMusic)

    logger:Info("  UniqueEngineSound = " .. tostring(trainData.uniqueEngineSound))
    db.Trains__Update__UniqueEngineSound(trainId, trainData.uniqueEngineSound)

    logger:Info("  PlayMusicContinuously = " .. tostring(trainData.playMusicContinuously))
    db.Trains__Update__PlayMusicContinuously(trainId, trainData.playMusicContinuously)

    logger:Info("  PlayMusicOnAllCarsSimultaneously = " .. tostring(trainData.playMusicOnAllCarsSimultaneously))
    db.Trains__Update__PlayMusicOnAllCarsSimultaneously(trainId, trainData.playMusicOnAllCarsSimultaneously)

    -- Guest audio behavior
    logger:Info("  AudioGuestsUseExcitement = " .. tostring(trainData.audioGuestsUseExcitement))
    db.Trains__Update__AudioGuestsUseExcitement(trainId, trainData.audioGuestsUseExcitement)

    logger:Info("  AudioGuestsUseFear = " .. tostring(trainData.audioGuestsUseFear))
    db.Trains__Update__AudioGuestsUseFear(trainId, trainData.audioGuestsUseFear)

    logger:Info("  AudioGuestsUseSpecialBehaviour = " .. tostring(trainData.audioGuestsUseSpecialBehaviour))
    db.Trains__Update__AudioGuestsUseSpecialBehaviour(trainId, trainData.audioGuestsUseSpecialBehaviour)

    -- Transport and coaster settings
    logger:Info("  UseTransportRideMusic = " .. tostring(trainData.useTransportRideMusic))
    db.Trains__Update__UseTransportRideMusic(trainId, trainData.useTransportRideMusic)

    logger:Info("  TreatAsCoaster = " .. tostring(trainData.treatAsCoaster))
    db.Trains__Update__TreatAsCoaster(trainId, trainData.treatAsCoaster)

    logger:Info("  AudioMaxRange = " .. tostring(trainData.audioMaxRange))
    db.Trains__Update__AudioMaxRange(trainId, trainData.audioMaxRange)

    -- Catch car configuration
    if trainData.catchTrainType ~= nil then
        logger:Info("  CatchTrainType = " .. tostring(trainData.catchTrainType))
        db.Trains__Update__CatchTrainType(trainId, trainData.catchTrainType)
    else
        logger:Info("  CatchTrainType = nil (skipped)")
    end

    logger:Info("  NumCatchCars = " .. tostring(trainData.numCatchCars))
    db.Trains__Update__NumCatchCars(trainId, trainData.numCatchCars)

    if trainData.reverseCatchTrainType ~= nil then
        logger:Info("  ReverseCatchTrainType = " .. tostring(trainData.reverseCatchTrainType))
        db.Trains__Update__ReverseCatchTrainType(trainId, trainData.reverseCatchTrainType)
    else
        logger:Info("  ReverseCatchTrainType = nil (skipped)")
    end

    logger:Info("  NumReverseCatchCars = " .. tostring(trainData.numReverseCatchCars))
    db.Trains__Update__NumReverseCatchCars(trainId, trainData.numReverseCatchCars)

    if trainData.splitCatchTrainType ~= nil then
        logger:Info("  SplitCatchTrainType = " .. tostring(trainData.splitCatchTrainType))
        db.Trains__Update__SplitCatchTrainType(trainId, trainData.splitCatchTrainType)
    else
        logger:Info("  SplitCatchTrainType = nil (skipped)")
    end

    logger:Info("  SplitNormalTrainDelay = " .. tostring(trainData.splitNormalTrainDelay))
    db.Trains__Update__SplitNormalTrainDelay(trainId, trainData.splitNormalTrainDelay)

    -- Audio prefix override
    if trainData.audioPrefixOverride ~= nil then
        logger:Info("  AudioPrefixOverride = " .. tostring(trainData.audioPrefixOverride))
        db.Trains__Update__AudioPrefixOverride(trainId, trainData.audioPrefixOverride)
    else
        logger:Info("  AudioPrefixOverride = nil (skipped)")
    end

    -- Advanced settings (constants, but set for completeness)
    logger:Info("  UseMirrorCarRotation = " .. tostring(trainData.useMirrorCarRotation))
    db.Trains__Update__UseMirrorCarRotation(trainId, trainData.useMirrorCarRotation)

    logger:Info("  ForceCarAttachOffsetYToZero = " .. tostring(trainData.forceCarAttachOffsetYToZero))
    db.Trains__Update__ForceCarAttachOffsetYToZero(trainId, trainData.forceCarAttachOffsetYToZero)

    logger:Info("  ForceCarAttachOffsetYToValue = " .. tostring(trainData.forceCarAttachOffsetYToValue))
    db.Trains__Update__ForceCarAttachOffsetYToValue(trainId, trainData.forceCarAttachOffsetYToValue)

    -- Water slide and cabin settings
    logger:Info("  AudioCabinIsEnclosed = " .. tostring(trainData.audioCabinIsEnclosed))
    db.Trains__Update__AudioCabinIsEnclosed(trainId, trainData.audioCabinIsEnclosed)

    logger:Info("  IsWaterSlideTrain = " .. tostring(trainData.isWaterSlideTrain))
    db.Trains__Update__IsWaterSlideTrain(trainId, trainData.isWaterSlideTrain)

    logger:Info("===== TRAIN INSERT COMPLETE: " .. trainId .. " =====")
end

return Trains
