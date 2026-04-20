local global           = _G
---@type Api
---@diagnostic disable-next-line: undefined-field
local api              = global.api
local package          = global.package
local tostring         = global.tostring
local string           = global.string

local ForgeUtils       = {}

-- Code taken from ACSEDebug. Thank you Inaki!
local API_ReloadModule = function(sModuleName)
    api.debug.Trace("Reloading module: " .. tostring(sModuleName))
    sModuleName = string.lower(sModuleName)
    local tMod = package.loaded[sModuleName]
    if global.type(tMod) ~= "table" then
        local sErr = "Module not loaded, not reloading."
        api.debug.Trace(sErr)
        return false, sErr
    end

    local fnModLoadError = function(sStage, sErrorMessage)
        local sErr = "Module reload failed, error while attempting to " .. sStage .. " module:\n\n" .. sErrorMessage
        api.debug.Trace(sErr)
        return false, sErr
    end

    ---@diagnostic disable-next-line: undefined-field
    local fnMod, sErrorMessage = global.loadresource(sModuleName)
    if not fnMod then
        return fnModLoadError("load", sErrorMessage)
    end

    ---@diagnostic disable-next-line: undefined-field
    local module = global.tryrequire(sModuleName)
    if module ~= nil then
        module.s_tInterfaces = nil
    end
    local bOk = nil
    bOk = global.pcall(fnMod, sModuleName)
    if not bOk then
        return fnModLoadError("execute", sErrorMessage)
    end
    return true
end

---@alias ForgeUtilsRequireCallback fun(moduleName : string, requireReturned : any): nil

ForgeUtils.OnInit      = function()
    ---@class global.api.forgeutils
    api.forgeutils = {

        ---@type ForgeUtilsRequireCallback
        onRequiredCallback = function(moduleName, moduleValue)
        end,

        ---@type fun(modName: string): any
        oldRequire = global.require
    }

    --- Patch and load our required callback.
    ---@diagnostic disable-next-line: inject-field
    global.require = function(modName)
        local moduleName = string.lower(modName)
        local newLoad = not package.loaded[moduleName]

        local requiredValue = api.forgeutils.oldRequire(modName)

        if newLoad then
            api.forgeutils.onRequiredCallback(moduleName, requiredValue)
        end

        return requiredValue
    end

    -- Reload Environment module to refresh all the modified APIS of that module (specially require())
    API_ReloadModule('Environment.Environment')
    API_ReloadModule('Game.BaseGame')
    API_ReloadModule('Game.GameScript')
end

return ForgeUtils
