local global = _G
local setmetatable = global.setmetatable
local db = require("forgeutils.internal.database.TrackedRides")

--- @class forgeutils.builders.database.trackedride.Simulation
local Simulation = {}
Simulation.__index = Simulation

--- Adds simulation data to the database
---@param id string The ID (or name) of the tracked ride.
---@param simulationData forgeutils.builders.data.trackedride.Simulation
function Simulation.addToDb(id, simulationData)
    db.Simulation__Insert(
        id,
        simulationData.excitementRating,
        simulationData.intensityRating,
        simulationData.nauseaRating,
        simulationData.prestige,
        simulationData.ticketCost
    )

    if (simulationData.supportsChildGuests ~= nil) then
        db.Simulation__Update__SupportsChildGuests(
            id,
            simulationData.supportsChildGuests
        )
    end

    if (simulationData.maximumGroupSize ~= nil) then
        db.Simulation__Update__MaximumGroupSize(
            id,
            simulationData.maximumGroupSize
        )
    end

    if (simulationData.isTransport ~= nil) then
        db.Simulation__Update__IsTransport(
            id,
            simulationData.isTransport
        )
    end

    if (simulationData.researchPack ~= nil) then
        db.Simulation__Update__ResearchPack(
            id,
            simulationData.researchPack
        )
    end

    if (simulationData.isBoomerang ~= nil) then
        db.Simulation__Update__IsBoomerang(
            id,
            simulationData.isBoomerang
        )
    end

    if (simulationData.isLoopedAsDefault ~= nil) then
        db.Simulation__Update__IsLoopedAsDefault(
            id,
            simulationData.isLoopedAsDefault
        )
    end

    if (simulationData.requiresEndLoops ~= nil) then
        db.Simulation__Update__RequiresEndLoops(
            id,
            simulationData.requiresEndLoops
        )
    end

    if (simulationData.isNonStop ~= nil) then
        db.Simulation__Update__IsNonStop(
            id,
            simulationData.isNonStop
        )
    end

    if (simulationData.allowsFreeEnds ~= nil) then
        db.Simulation__Update__AllowsFreeEnds(
            id,
            simulationData.allowsFreeEnds
        )
    end

    if (simulationData.isWaterSlide ~= nil) then
        db.Simulation__Update__IsWaterSlide(
            id,
            simulationData.isWaterSlide
        )
    end

    if (simulationData.isSwimsuit ~= nil) then
        db.Simulation__Update__IsSwimsuit(
            id,
            simulationData.isSwimsuit
        )
    end

    if (simulationData.isChildOnly ~= nil) then
        db.Simulation__Update__IsChildOnly(
            id,
            simulationData.isChildOnly
        )
    end

    if (simulationData.serviceInterval ~= nil) then
        db.Simulation__Update__ServiceInterval(
            id,
            simulationData.serviceInterval
        )
    end
end

return Simulation
