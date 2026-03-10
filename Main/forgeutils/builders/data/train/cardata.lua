local global = _G
local setmetatable = global.setmetatable

---@class forgeutils.builders.data.train.CarData
---@field carId string
---@field whichCar string
---@field carOrder integer
---@field prefab string
---@field mass number
---@field platformPrefab string?
---@field isPowered boolean
local CarData = {}
CarData.__index = CarData

--- Create a new CarData object.
--- @return self
function CarData.new()
    local self = setmetatable({}, CarData)

    -- Sane defaults
    self.whichCar = "Front"
    self.carOrder = 0
    self.mass = 700.0
    self.isPowered = false

    -- Required fields
    self.carId = nil
    self.prefab = nil

    -- DB nullables
    self.platformPrefab = nil

    return self
end

--- @param carId string
--- @return self
function CarData:withCarId(carId)
    self.carId = carId
    return self
end

--- @param whichCar string
--- @return self
function CarData:withWhichCar(whichCar)
    self.whichCar = whichCar
    return self
end

--- @param carOrder integer
--- @return self
function CarData:withCarOrder(carOrder)
    self.carOrder = carOrder
    return self
end

--- @param prefab string
--- @return self
function CarData:withPrefab(prefab)
    self.prefab = prefab
    return self
end

--- @param mass number
--- @return self
function CarData:withMass(mass)
    self.mass = mass
    return self
end

--- @param platformPrefab string?
--- @return self
function CarData:withPlatformPrefab(platformPrefab)
    self.platformPrefab = platformPrefab
    return self
end

--- @param isPowered boolean
--- @return self
function CarData:withIsPowered(isPowered)
    self.isPowered = isPowered
    return self
end

--- Convenience method to set as front car
--- @return self
function CarData:asFrontCar()
    self.whichCar = "Front"
    self.carOrder = 0
    return self
end

--- Convenience method to set as middle car
--- @return self
function CarData:asMiddleCar()
    self.whichCar = "Middle"
    self.carOrder = 1
    return self
end

--- Convenience method to set as rear car
--- @return self
function CarData:asRearCar()
    self.whichCar = "Rear"
    self.carOrder = 2
    return self
end

return CarData
