local global = _G
local setmetatable = global.setmetatable

--- @class forgeutils.builders.data.trackedride.Simulation
--- @field excitementRating number
--- @field intensityRating number
--- @field nauseaRating number
--- @field prestige integer
--- @field ticketCost integer
--- @field supportsChildGuests boolean?
--- @field maximumGroupSize integer?
--- @field isTransport boolean?
--- @field researchPack integer?
--- @field isBoomerang boolean?
--- @field isLoopedAsDefault boolean?
--- @field requiresEndLoops boolean?
--- @field isNonStop boolean?
--- @field allowsFreeEnds boolean?
--- @field isWaterSlide boolean?
--- @field isSwimsuit boolean?
--- @field isChildOnly boolean?
--- @field serviceInterval number?
local Simulation = {}
Simulation.__index = Simulation

--- Create a new Simulation data object.
--- @return self
function Simulation.new()
    local self = setmetatable({}, Simulation)

    -- Sane defaults
    self.excitementRating = 5.0
    self.intensityRating = 5.0
    self.nauseaRating = 2.0
    self.prestige = 100
    self.ticketCost = 1000

    -- DB defaults
    self.supportsChildGuests = nil
    self.maximumGroupSize = nil
    self.isTransport = nil
    self.researchPack = nil
    self.isBoomerang = nil
    self.isLoopedAsDefault = nil
    self.requiresEndLoops = nil
    self.isNonStop = nil
    self.allowsFreeEnds = nil
    self.isWaterSlide = nil
    self.isSwimsuit = nil
    self.isChildOnly = nil
    self.serviceInterval = nil

    return self
end

--- @param excitementRating number
--- @return self
function Simulation:withExcitementRating(excitementRating)
    self.excitementRating = excitementRating
    return self
end

--- @param intensityRating number
--- @return self
function Simulation:withIntensityRating(intensityRating)
    self.intensityRating = intensityRating
    return self
end

--- @param nauseaRating number
--- @return self
function Simulation:withNauseaRating(nauseaRating)
    self.nauseaRating = nauseaRating
    return self
end

--- @param prestige integer
--- @return self
function Simulation:withPrestige(prestige)
    self.prestige = prestige
    return self
end

--- @param ticketCost integer
--- @return self
function Simulation:withTicketCost(ticketCost)
    self.ticketCost = ticketCost
    return self
end

--- @param supportsChildGuests boolean?
--- @return self
function Simulation:withSupportsChildGuests(supportsChildGuests)
    self.supportsChildGuests = supportsChildGuests
    return self
end

--- @param maximumGroupSize integer?
--- @return self
function Simulation:withMaximumGroupSize(maximumGroupSize)
    self.maximumGroupSize = maximumGroupSize
    return self
end

--- @param isTransport boolean?
--- @return self
function Simulation:withIsTransport(isTransport)
    self.isTransport = isTransport
    return self
end

--- @param researchPack integer?
--- @return self
function Simulation:withResearchPack(researchPack)
    self.researchPack = researchPack
    return self
end

--- @param isBoomerang boolean?
--- @return self
function Simulation:withIsBoomerang(isBoomerang)
    self.isBoomerang = isBoomerang
    return self
end

--- @param isLoopedAsDefault boolean?
--- @return self
function Simulation:withIsLoopedAsDefault(isLoopedAsDefault)
    self.isLoopedAsDefault = isLoopedAsDefault
    return self
end

--- @param requiresEndLoops boolean?
--- @return self
function Simulation:withRequiresEndLoops(requiresEndLoops)
    self.requiresEndLoops = requiresEndLoops
    return self
end

--- @param isNonStop boolean?
--- @return self
function Simulation:withIsNonStop(isNonStop)
    self.isNonStop = isNonStop
    return self
end

--- @param allowsFreeEnds boolean?
--- @return self
function Simulation:withAllowsFreeEnds(allowsFreeEnds)
    self.allowsFreeEnds = allowsFreeEnds
    return self
end

--- @param isWaterSlide boolean?
--- @return self
function Simulation:withIsWaterSlide(isWaterSlide)
    self.isWaterSlide = isWaterSlide
    return self
end

--- @param isSwimsuit boolean?
--- @return self
function Simulation:withIsSwimsuit(isSwimsuit)
    self.isSwimsuit = isSwimsuit
    return self
end

--- @param isChildOnly boolean?
--- @return self
function Simulation:withIsChildOnly(isChildOnly)
    self.isChildOnly = isChildOnly
    return self
end

--- @param serviceInterval number?
--- @return self
function Simulation:withServiceInterval(serviceInterval)
    self.serviceInterval = serviceInterval
    return self
end

return Simulation
