-- Remove weird table issue
---@diagnostic disable: param-type-mismatch
local global = _G
local table = global.table
local require = global.require
local tostring = global.tostring
local pairs = global.pairs

-- Setup logger
local loggerSetup = require("forgeutils.logger")
local logger = loggerSetup.Get("ForgeUtilsLuaDatabase")

logger:Info("Loading ForgeUtils...")

local _ForgeUtilsLuaDatabase = {}
_ForgeUtilsLuaDatabase.hasShownPopup = false

function _ForgeUtilsLuaDatabase.AddContentToCall(_tContentToCall)
    -- We tell the Database Manager to load our custom Database Manager by its Lua name
    -- You can add as many as you want, ideally separating each manager for each content type you add
    table.insert(_tContentToCall, require("database.forgeutilsluadatabase"))
    table.insert(_tContentToCall, require("forgeutils.internal.database.TrackedRides"))
    table.insert(_tContentToCall, require("forgeutils.internal.database.TrackedRideCars"))
    table.insert(_tContentToCall, require("forgeutils.internal.database.ModularScenery"))
    table.insert(_tContentToCall, require("forgeutils.internal.database.Audio"))
end

function _ForgeUtilsLuaDatabase.Init()
    logger:Info("Init ForgeUtils")

    -- Manually hook to Managers.BrowserDataManager
    _ForgeUtilsLuaDatabase._Hook_BrowserDataManager_SetupCache(require("Managers.BrowserDataManager"))
end

function _ForgeUtilsLuaDatabase._Hook_StartScreenPopupHelper_RunCheckLocalModification(tModule)
    tModule.RunCheckLocalModification_Base = tModule._RunCheckLocalModification
    tModule._RunCheckLocalModification = function(self)
        if _ForgeUtilsLuaDatabase.hasShownPopup then
            tModule.RunCheckLocalModification_Base(self)
            return
        end

        -- Check if we actually have any out of date mods
        local moddb = require("forgeutils.moddb")
        local outOfDate = moddb.GetModsOutOfDate()
        local foundOutOfDate = false

        local lines = {
            "Some installed mods require a newer version of ForgeUtils. Consider updating if things don't work.\n",
            "ForgeUtils: " .. tostring(require("forgeutils").version)
        }

        for mod, ver in pairs(outOfDate) do
            local line = tostring(mod) .. ": " .. tostring(ver)
            table.insert(lines, line)
            foundOutOfDate = true
        end

        local stringBuilder = "[STRING_LITERAL:Value=|" .. table.concat(lines, "\n") .. "|]"

        _ForgeUtilsLuaDatabase.hasShownPopup = true

        if not foundOutOfDate then
            return
        end

        logger:Warn("Some mods are out of date.")

        local popup = require("Helpers.PopUpDialogUtils")
        popup.RunOKDialog(
            "[STRING_LITERAL:Value=|ForgeUtils version|]",
            stringBuilder
        )

        -- run base
        tModule.RunCheckLocalModification_Base(self)
    end
end

function _ForgeUtilsLuaDatabase._Hook_BrowserDataManager_SetupCache(tModule)
    logger:Info("Managers.BrowserDataManager = " .. tostring(tModule))
    tModule._SetupCache_Base = tModule._SetupCache
    tModule._SetupCache = function(self)
        logger:Info("SetupCache called, inserting DB data...")
        require("Database.Main").CallOnContent(
            "InsertToDBs"
        )
        logger:Info("Finished InsertToDBs.")

        -- Call setup cache as normal, but now all of the prefab stuff is loaded!
        tModule._SetupCache_Base(self)
    end
end

_ForgeUtilsLuaDatabase.tDefaultHooks = {
    ["StartScreen.Shared.StartScreenPopupHelper"] = _ForgeUtilsLuaDatabase
        ._Hook_StartScreenPopupHelper_RunCheckLocalModification,
}

function _ForgeUtilsLuaDatabase.AddLuaHooks(_fnAdd)
    logger:Info("Adding hooks")
    for sModuleName, tFunc in pairs(_ForgeUtilsLuaDatabase.tDefaultHooks) do
        logger:Info("Adding hook for module [" .. sModuleName .. "]")
        _fnAdd(sModuleName, tFunc)
    end
end

function _ForgeUtilsLuaDatabase.AddLuaPrefabs(_fnAdd)
    -- these are the name of the Lua files with the prefab data
    local tPrefabs = {
        "CC_Mod_Wheel_Base",
    }

    for _, sPrefab in global.ipairs(tPrefabs) do
        local root = require(sPrefab).GetRoot()
        logger:Info("Adding: " .. sPrefab)
        _fnAdd(sPrefab, root)
    end
end

return _ForgeUtilsLuaDatabase
