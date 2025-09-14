local global = _G
local table = global.table
local require = require
local pairs = global.pairs
local ForgeUtils = require("forgeutils")

-- Setup logger
local loggerSetup = require("forgeutils.logger")
local logger = loggerSetup.Get("ForgeUtilsModDB", "DEBUG")

---@class forgeutils.ModDB
---@field registeredMods {[string]: number } Registered mods with the DB.
local ModDB = {}
ModDB.registeredMods = {}

---Registers a mod with the ModDB.
---If a mod is using a version that is higher than the installed ForgeUtils mod,
---it will give an notification for the user to update on the main menu.
---@param modName string The name to display to the user.
---@param usingVersion number|nil The version that this mod was developed for. If nil, will be installed version.
function ModDB.RegisterMod(modName, usingVersion)
    if usingVersion == nil then
        usingVersion = ForgeUtils.version
    end
    logger:Info("Registered new mod with ForgeUtils: " .. tostring(modName) .. "[" .. usingVersion .. "]")
    ModDB.registeredMods[modName] = usingVersion
    logger:Info("Registered Mods: ")
    for mod, ver in pairs(ModDB.registeredMods) do
        logger:Info(mod)
    end
end

---Returns any registered mods that are out of date.
---@return {[string]: number } mods Out of date mods, key being name and value being version.
function ModDB.GetModsOutOfDate()
    local results = {}
    for mod, ver in pairs(ModDB.registeredMods) do
        logger:Info("Found mod: " .. mod)
        if ver > ForgeUtils.version then
            logger:Info("OUT OF DATE: " .. mod)
            results[mod] = ver
        end
    end
    return results
end

return ModDB
