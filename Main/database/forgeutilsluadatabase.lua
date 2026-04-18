-- Remove weird table issue
---@diagnostic disable: param-type-mismatch
local global = _G

---@type Api
---@diagnostic disable-next-line: undefined-field
local api = global.api
local table = global.table
local require = global.require
local tostring = global.tostring
local pairs = global.pairs

-- Setup logger
local loggerSetup = require("forgeutils.logger")
local logger = loggerSetup.Get("ForgeUtilsLuaDatabase")
local hookManager = require("forgeutils.hookmanager")
local uiHookManager = require("forgeutils.uihookmanager")

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

    -- Setup hooks.
    hookManager:AddHook(
        "Managers.BrowserDataManager",
        "_SetupCache",
        function(originalFunction, browserDataManager)
            logger:Info("SetupCache called, inserting DB data...")
            require("Database.Main").CallOnContent(
                "InsertToDBs"
            )
            logger:Info("Finished InsertToDBs.")
            originalFunction(browserDataManager)
        end
    )

    hookManager:AddHook(
        "StartScreen.Shared.StartScreenPopupHelper",
        "_RunCheckLocalModification",
        _ForgeUtilsLuaDatabase.RunCheckLocalModification
    )

    api.ui2.MapResources("ForgeUtilsUIHooks")

    -- Add UI hooks
    uiHookManager:_InitUiHookManager()
end

function _ForgeUtilsLuaDatabase.RunCheckLocalModification(originalMethod, self)
    if _ForgeUtilsLuaDatabase.hasShownPopup then
        originalMethod(self)
        return
    end

    -- Check if we actually have any out of date mods
    local moddb = require("forgeutils.moddb")
    local outOfDate = moddb.GetModsOutOfDate()
    local foundOutOfDate = false
    local lines = {
        "Warning! Some mods target a different version of ForgeUtils. Beware of crashing!",
        "Installed version is " .. require("forgeutils").version:toString()
    }

    for mod, ver in pairs(outOfDate) do
        local version = ver:toString()
        local line = tostring(mod) .. " targets " .. version
        table.insert(lines, line)
        foundOutOfDate = true
    end

    local stringBuilder = "[STRING_LITERAL:Value=|" .. table.concat(lines, "\n") .. "|]"

    _ForgeUtilsLuaDatabase.hasShownPopup = true

    if not foundOutOfDate then
        return
    end

    logger:Warn("Some mods have issues.")

    local popup = require("Helpers.PopUpDialogUtils")
    popup.RunOKDialog(
        "[STRING_LITERAL:Value=|ForgeUtils version|]",
        stringBuilder
    )

    -- run base
    originalMethod(self)
end

function _ForgeUtilsLuaDatabase.AddLuaPrefabs(_fnAdd)
    local PrefabUtility = require("forgeutils.prefabutility")

    PrefabUtility.AddAugmentedPrefab("CC_Mod_Wheel_Base", _fnAdd)
end

return _ForgeUtilsLuaDatabase
