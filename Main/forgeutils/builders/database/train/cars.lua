local global = _G
local db = require("forgeutils.internal.database.TrackedRideCars")
local logger = require("forgeutils.logger").Get("TrainBuilder.Database.Cars", "INFO")

--- @class forgeutils.builders.database.train.Cars
local Cars = {}
Cars.__index = Cars

--- Adds car data to the database
--- @param trainId string The train ID this car belongs to
--- @param carData forgeutils.builders.data.train.CarData
function Cars.addToDb(trainId, carData)
    logger:Info("  ----- INSERTING CAR: " .. carData.carId .. " for train " .. trainId .. " -----")

    -- Insert required fields
    logger:Info("    Cars__Insert(" .. trainId .. ", " .. carData.carId .. ", " .. tostring(carData.mass) .. ")")
    db.Cars__Insert(
        trainId,
        carData.carId,
        carData.mass
    )

    -- Update optional fields
    if carData.whichCar ~= nil then
        logger:Info("    WhichCar = " .. tostring(carData.whichCar))
        db.Cars__Update__WhichCar(trainId, carData.carId, carData.whichCar)
    else
        logger:Info("    WhichCar = nil (skipped)")
    end

    if carData.carOrder ~= nil then
        logger:Info("    CarOrder = " .. tostring(carData.carOrder))
        db.Cars__Update__CarOrder(trainId, carData.carId, carData.carOrder)
    else
        logger:Info("    CarOrder = nil (skipped)")
    end

    if carData.prefab ~= nil then
        logger:Info("    Prefab = " .. tostring(carData.prefab))
        db.Cars__Update__Prefab(trainId, carData.carId, carData.prefab)
    else
        logger:Info("    Prefab = nil (skipped)")
    end

    if carData.platformPrefab ~= nil then
        logger:Info("    PlatformPrefab = " .. tostring(carData.platformPrefab))
        db.Cars__Update__PlatformPrefab(trainId, carData.carId, carData.platformPrefab)
    else
        logger:Info("    PlatformPrefab = nil (skipped)")
    end

    if carData.isPowered ~= nil then
        logger:Info("    IsPowered = " .. tostring(carData.isPowered))
        db.Cars__Update__IsPowered(trainId, carData.carId, carData.isPowered)
    else
        logger:Info("    IsPowered = nil (skipped)")
    end

    logger:Info("  ----- CAR INSERT COMPLETE: " .. carData.carId .. " -----")
end

return Cars
