local global = _G
local db = require("forgeutils.internal.database.TrackedRideCars")

--- @class forgeutils.builders.database.train.Cars
local Cars = {}
Cars.__index = Cars

--- Adds car data to the database
--- @param trainId string The train ID this car belongs to
--- @param carData forgeutils.builders.data.train.CarData
function Cars.addToDb(trainId, carData)
    -- Insert required fields
    db.Cars__Insert(
        trainId,
        carData.carId,
        carData.mass
    )

    -- Update optional fields
    if carData.whichCar ~= nil then
        db.Cars__Update__WhichCar(trainId, carData.carId, carData.whichCar)
    end

    if carData.carOrder ~= nil then
        db.Cars__Update__CarOrder(trainId, carData.carId, carData.carOrder)
    end

    if carData.prefab ~= nil then
        db.Cars__Update__Prefab(trainId, carData.carId, carData.prefab)
    end

    if carData.platformPrefab ~= nil then
        db.Cars__Update__PlatformPrefab(trainId, carData.carId, carData.platformPrefab)
    end

    if carData.isPowered ~= nil then
        db.Cars__Update__IsPowered(trainId, carData.carId, carData.isPowered)
    end
end

return Cars
