local global = _G
---@type Api
---@diagnostic disable-next-line: undefined-field
local api = global.api
local table = global.table
local require = require
local pairs = global.pairs
local ForgeUtils = require("forgeutils")
local version = require("forgeutils.modversion")

-- Setup logger
local loggerSetup = require("forgeutils.logger")
local logger = loggerSetup.Get("ForgeUtilsModDB")

--#region Global Definitions

---@class (Partial) global.api.forgeutils
---@field modDbState forgeutils.HookManager.ModDbState

---@class (Partial) forgeutils.HookManager.ModDbState
---@field registeredMods {[string]: forgeutils.Version } A dictionary of registered mods with ForgeUtils

-- Init global API state if not already.
if not api.forgeutils.modDbState then
    api.forgeutils.modDbState = {
        registeredMods = {}
    }
end
local modDbState = api.forgeutils.modDbState

--#endregion

---@class forgeutils.ModDB
local ModDB = {}

local function getMajorMinorFromFloat(s)
    -- Evil regex.
    local whole, frac = global.string.match(s, "^(-?%d+)%.(%d+)$")
    if whole then
        return global.math.tointeger(global.tonumber(whole)), global.math.tointeger(global.tonumber(frac))
    else
        return global.math.tointeger(global.tonumber(s)), 0
    end
end

---Registers a mod with the ModDB.
---If a mod is using a version that is higher than the installed ForgeUtils mod,
---it will give an notification for the user to update on the main menu.
---@param modName string The name to display to the user.
---@param minimumMajorVersion integer? The minimum major version required. If nil, not checked.
---@param minimumMinorVersion integer? The minimum minor version required. If nil, not checked.
---@param minimumPatchVersion integer? The minimum patch version required. If nil, not checked.
---@return boolean succeeded Returns true if there are no issues with registration.
function ModDB.RegisterMod(
    modName,
    minimumMajorVersion,
    minimumMinorVersion,
    minimumPatchVersion
)
    -- backwards compat. make required major version the floor of a float version (previously used)
    if global.math.type(minimumMajorVersion) == "float" then
        logger:Warn(
            "Float versions are obsolete and will be unsupported in later versions. Major and Minor version will be extracted."
        )
        minimumMajorVersion, minimumMinorVersion = getMajorMinorFromFloat(global.tostring(minimumMajorVersion))
    end

    local modVer = version.new({
        major = minimumMajorVersion,
        minor = minimumMinorVersion,
        patch = minimumPatchVersion
    })

    modDbState.registeredMods[modName] = modVer

    logger:Info("Registered new mod with ForgeUtils: " .. global.tostring(modName) .. " " .. modVer:toString())
    return ModDB.CheckVersionForMod(modName)
end

local function versionErrorStr(modName, semanticType, modValue, forgeValue)
    return (
        "Mod [" ..
        modName ..
        "] version mismatch. " ..
        semanticType ..
        " version of mod is " ..
        global.tostring(modValue) ..
        ", current ForgeUtils is " ..
        global.tostring(forgeValue) ..
        ". You should update these mods if you encounter any issues!"
    )
end

--- Checks the mod version against the current install.
---@param modName string The name to display to the user.
---@return boolean success Whether the mod was in date.
function ModDB.CheckVersionForMod(modName)
    local mod = modDbState.registeredMods[modName]
    local forge = ForgeUtils.version

    local checkMajor = mod.major ~= nil
    local checkMinor = mod.minor ~= nil
    local checkPatch = mod.patch ~= nil

    -- Forge is ahead on major.
    if checkMajor and forge.major > mod.major then
        return true
    end

    -- Major required by mod is higher than forge.
    if checkMajor and forge.major < mod.major then
        logger:Error(versionErrorStr(modName, "major", mod.major, forge.major))
        return false
    end

    -- Forge is ahead on minor, these are new features so fine.
    if checkMinor and forge.minor > mod.minor then
        return true
    end

    -- Forge is behind on minor, bad, mod might rely on new things not present.
    if checkMinor and forge.minor < mod.minor then
        logger:Error(versionErrorStr(modName, "minor", mod.minor, forge.minor))
        return false
    end

    -- Forge must support patch
    if checkPatch and forge.patch < mod.patch then
        logger:Error(versionErrorStr(modName, "patch", mod.patch, forge.patch))
        return false
    end

    return true
end

---Returns any registered mods that are out of date.
---@return {[string]: forgeutils.Version } mods Out of date mods, key being name and value being version.
function ModDB.GetModsOutOfDate()
    local results = {}
    for mod, ver in pairs(modDbState.registeredMods) do
        if not ModDB.CheckVersionForMod(mod) then
            results[mod] = ver
        end
    end
    return results
end

return ModDB
