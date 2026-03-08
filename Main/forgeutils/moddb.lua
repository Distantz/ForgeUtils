local global = _G
local table = global.table
local require = require
local pairs = global.pairs
local ForgeUtils = require("forgeutils")

-- Setup logger
local loggerSetup = require("forgeutils.logger")
local logger = loggerSetup.Get("ForgeUtilsModDB", "INFO")

---@class forgeutils.ModDB
---@field registeredMods {[string]: forgeutils.Version } Registered mods with the DB.
local ModDB = {}
ModDB.registeredMods = {}

---Registers a mod with the ModDB.
---If a mod is using a version that is higher than the installed ForgeUtils mod,
---it will give an notification for the user to update on the main menu.
---@param modName string The name to display to the user.
---@param minimumMajorVersion integer? The minimum major version required. If nil, not checked.
---@param minimumMinorVersion integer? The minimum minor version required. If nil, not checked.
---@param minimumPatchVersion integer? The minimum patch version required. If nil, not checked.
function ModDB.RegisterMod(
    modName,
    minimumMajorVersion,
    minimumMinorVersion,
    minimumPatchVersion
)
    -- backwards compat. make required major version the floor of a float version (previously used)
    if minimumMajorVersion ~= nil and global.type(minimumMajorVersion) == "number" then
        logger:Warn("Float version numbers have been deprecated. Please use the latest function to register mods.")
        minimumMajorVersion = global.math.floor(minimumMajorVersion)
    end

    logger:Info("Registered new mod with ForgeUtils: " .. global.tostring(modName))
    ModDB.registeredMods[modName] = {
        major = minimumMajorVersion,
        minor = minimumMinorVersion,
        patch = minimumPatchVersion
    }

    logger:Info("Checking version compatibility...")
end

local function performSemanticCheck(modValue, forgeValue, shouldBeEqual)
    if modValue == nil or forgeValue == nil then
        return true
    end

    -- used for major
    if shouldBeEqual then
        return modValue == forgeValue
    end

    return modValue >= forgeValue
end

local function logSemanticErrorStr(modName, semanticType, modValue, forgeValue)
    return (
        "Mod [" ..
        modName ..
        "] version mismatch. " ..
        semanticType ..
        " version of mod is " ..
        global.tostring(modValue) ..
        ", current ForgeUtils is " ..
        global.tostring(forgeValue) ..
        ". You should update your ForgeUtils!"
    )
end

--- Checks the mod version against the current install. If
---@param modName string The name to display to the user.
---@return boolean inDate Whether the mod was in date.
function ModDB.CheckVersionForMod(modName)
    local version = ModDB.registeredMods[modName]

    if not performSemanticCheck(version.major, ForgeUtils.version.major, true) then
        logger:Error(logSemanticErrorStr(modName, "major", version.major, ForgeUtils.version.major))
        return false
    end

    if not performSemanticCheck(version.minor, ForgeUtils.version.minor, false) then
        logger:Error(logSemanticErrorStr(modName, "minor", version.minor, ForgeUtils.version.minor))
        return false
    end

    if not performSemanticCheck(version.patch, ForgeUtils.version.patch, false) then
        logger:Error(logSemanticErrorStr(modName, "patch", version.patch, ForgeUtils.version.patch))
        return false
    end

    return true
end

---Returns any registered mods that are out of date.
---@return {[string]: forgeutils.Version } mods Out of date mods, key being name and value being version.
function ModDB.GetModsOutOfDate()
    local results = {}
    for mod, ver in pairs(ModDB.registeredMods) do
        if not ModDB.CheckVersionForMod(mod) then
            logger:Error("OUT OF DATE: " .. mod)
            results[mod] = ver
        end
    end
    return results
end

return ModDB
