local global = _G
local api = global.api
local setmetatable = global.setmetatable
local ipairs = global.ipairs

local logger = require("forgeutils.logger").Get("TrainBuilder", "INFO")
local base = require("forgeutils.builders.basebuilder")
local check = require("forgeutils.check")

--- @class forgeutils.builders.train.TrainBuilder: forgeutils.builders.BaseBuilder
--- @field __index table
--- @field trainData forgeutils.builders.data.train.TrainData
--- @field cars forgeutils.builders.data.train.CarData[]
local TrainBuilder = {}
TrainBuilder.__index = TrainBuilder
setmetatable(TrainBuilder, { __index = base })

--- Creates a new TrainBuilder.
--- @return self
function TrainBuilder.new()
    local self = setmetatable(base.new(), TrainBuilder)

    self.cars = {}

    return self
end

--- Adds train configuration data.
--- @param trainData forgeutils.builders.data.train.TrainData
--- @return self
function TrainBuilder:withTrainData(trainData)
    self.trainData = trainData
    return self
end

--- Adds a car to this train.
--- @param car forgeutils.builders.data.train.CarData
--- @return self
function TrainBuilder:withCar(car)
    self.cars[#self.cars + 1] = car
    logger:Info("Added car: " .. tostring(car.carId) .. " (total cars: " .. #self.cars .. ")")
    return self
end

--- Validates the builder data.
--- @return boolean valid If the builder has errors.
function TrainBuilder:hasErrors()
    logger:Info("Validating train builder for: " .. tostring(self.id))
    local issues = base.hasErrors(self)

    issues = check.IsNil("trainData", self.trainData) or issues
    issues = check.IsEmpty("cars", self.cars) or issues

    -- Validate each car has required fields
    for i, car in ipairs(self.cars) do
        if check.IsNil("cars[" .. i .. "].carId", car.carId) then
            issues = true
        end
        if check.IsNil("cars[" .. i .. "].prefab", car.prefab) then
            issues = true
        end
    end

    if issues then
        logger:Error("Validation FAILED for train: " .. tostring(self.id))
    else
        logger:Info("Validation PASSED for train: " .. tostring(self.id))
    end

    return issues
end

--- Adds the train and cars to the database.
function TrainBuilder:addToDB()
    logger:Info("========================================")
    logger:Info("Starting database insertion for train: " .. self.id)
    logger:Info("Number of cars to insert: " .. #self.cars)
    logger:Info("========================================")

    -- Insert train data first
    local trainsDb = require("forgeutils.builders.database.train.trains")
    trainsDb.addToDb(self.id, self.trainData)

    -- Insert all cars
    local carsDb = require("forgeutils.builders.database.train.cars")
    for i, car in ipairs(self.cars) do
        logger:Info("Inserting car " .. i .. " of " .. #self.cars)
        carsDb.addToDb(self.id, car)
    end

    logger:Info("========================================")
    logger:Info("Database insertion COMPLETE for train: " .. self.id)
    logger:Info("========================================")
end

return TrainBuilder
