local global = _G
---@class Api
---@diagnostic disable-next-line: undefined-field
local api = global.api
local require = global.require
local logger = require("forgeutils.logger").Get("UiHookManager")
local hookManager = require("forgeutils.hookmanager")

--#region Global Definitions

---@class (Partial) global.api.forgeutils
---@field uiHookManagerState forgeutils.UiHookManager.UiHookManagerState

---@class (Partial) forgeutils.UiHookManager.UiHookManagerState
---@field hooks table<string, forgeutils.UiHookManager.UiHook[]> Keys are view names and value is list of hooks to apply to wrappers on ready.
---@field wrappers table<GamefaceUIWrapper, string> Keys are gameface UI wrappers and values are view names.
---@field initialized boolean Whether gameface UI hooks have been created.

-- Init global API state if not already.
if not api.forgeutils.uiHookManagerState then
    api.forgeutils.uiHookManagerState = {
        hooks = {},
        wrappers = {},
        initialized = false
    }
end
local UiHookManagerState = api.forgeutils.uiHookManagerState

--#endregion

--#region Definitions

---@enum (key) forgeutils.UiHookManager.UiHook.Type
local hookTypes = {
    Element = 1,
    Import = 2
}

---@class forgeutils.UiHookManager.UiHook A type representing a UI hook.
---@field type forgeutils.UiHookManager.UiHook.Type
---@field element string? The element to apply the hook to. This is the token name of the type in JS. `"div"` is an example, `"Button"` is another. Only required for certain hook types.
---@field file string The file that contains the JavaScript UI hook. An example is `"/js/hooks/forgeutils/hudBottomBarHook.js"`.

---@class forgeutils.UiHookManager
local UiHookManager = {}

--- Initializes the UI hook manager by adding necessary lua injections.
--- Note: this function should only be used internally.
function UiHookManager:_InitUiHookManager()
    if UiHookManagerState.initialized then
        return
    end

    UiHookManagerState.initialized = true
    logger:Info("Starting UI hook manager")
    hookManager:AddHook(
        "UI.GamefaceUIWrapper",
        "Init",
        function(originalMethod, slf, init)
            self:_OnInitCallback(slf, init)
            return originalMethod(slf, init)
        end
    )

    hookManager:AddHook(
        "UI.GamefaceUIWrapper",
        "_OnReadyCallback",
        function(originalMethod, slf)
            local res = originalMethod(slf)
            self:_OnReadyCallback(slf)
            return res
        end
    )

    hookManager:AddHook(
        "UI.GamefaceUIWrapper",
        "Shutdown",
        function(originalMethod, slf)
            self:_ShutdownCallback(slf)
            return originalMethod(slf)
        end
    )
end

--- A callback on the UI gameface init.
--- This performs setup for logging.
--- Note: this function should only be used internally.
--- Note: This registers event listeners. It should thus only be called on ready gameface ui instances.
--- @param gamefaceUiInstance GamefaceUIWrapper The gameface instance.
--- @param initSettings table The init settings
--- @private
function UiHookManager:_OnInitCallback(gamefaceUiInstance, initSettings)
    ---@diagnostic disable-next-line: inject-field
    gamefaceUiInstance.logger = logger.Get("UI[" .. initSettings.sViewName .. "]", "INFO")
end

--- A callback on the UI gameface ready.
--- This performs setup for logging and also calls hook events.
--- Note: this function should only be used internally.
--- Note: This registers event listeners. It should thus only be called on ready gameface ui instances.
--- @param gamefaceUiInstance GamefaceUIWrapper The gameface instance.
--- @private
function UiHookManager:_OnReadyCallback(gamefaceUiInstance)
    -- Add logging
    self:_RegisterLoggingEventsFor(gamefaceUiInstance)

    -- Trigger ForgeUtils hooks
    local viewName = global.tostring(gamefaceUiInstance.tInitSettings.sViewName)
    UiHookManagerState.wrappers[gamefaceUiInstance] = viewName
    if UiHookManagerState.hooks[viewName] == nil then
        logger:Debug("No hooks registered for view: " .. viewName)
        return
    end

    local count = #UiHookManagerState.hooks[viewName]
    logger:Info("Found " .. global.tostring(count) .. " hooks for view: " .. viewName)
    for _, hook in global.ipairs(UiHookManagerState.hooks[viewName]) do
        self:_AddHookToInstance(gamefaceUiInstance, hook)
    end
end

--- A callback on the UI gameface shutdown.
--- This cleans up internal references when wrappers are destroyed.
--- Note: this function should only be used internally.
--- @param gamefaceUiInstance GamefaceUIWrapper The gameface instance.
--- @private
function UiHookManager:_ShutdownCallback(gamefaceUiInstance)
    if UiHookManagerState.wrappers[gamefaceUiInstance] then
        UiHookManagerState.wrappers[gamefaceUiInstance] = nil
    end
end

--- Adds a hook to a gameface UI instance.
--- Note: this function should only be used internally.
--- Note: This registers event listeners. It should thus only be called on ready gameface ui instances.
---@param gamefaceUiInstance GamefaceUIWrapper The gameface instance.
---@param uiHook forgeutils.UiHookManager.UiHook The hook.
---@private
function UiHookManager:_AddHookToInstance(gamefaceUiInstance, uiHook)
    logger:Info(
        "Applying hook: " ..
        uiHook.file
    )

    if uiHook.type == "Element" then
        gamefaceUiInstance:TriggerEventAtNextAdvance(
            "ForgeUtils_AddElementHook",
            uiHook.element,
            uiHook.file
        )
    elseif uiHook.type == "Import" then
        gamefaceUiInstance:TriggerEventAtNextAdvance(
            "ForgeUtils_AddImportHook",
            uiHook.file
        )
    else
        logger:Error("Unknown type! Hook was not added.")
    end
end

--- Adds lua hooks related to logging events to the GamefaceUIWrapper.
--- Note: this function should only be used internally.
--- Note: This registers event listeners. It should thus only be called on ready gameface ui instances.
--- @param gamefaceUiInstance GamefaceUIWrapper The gameface instance
--- @private
function UiHookManager:_RegisterLoggingEventsFor(gamefaceUiInstance)
    ---@diagnostic disable-next-line: undefined-field
    gamefaceUiInstance.logger:Info("Hooking logging ForgeUtils UI callbacks")

    --#region Logging callbacks

    gamefaceUiInstance:AddEventListener(
        "ForgeUtils_LogInfo",
        1,
        function(str)
            ---@diagnostic disable-next-line: undefined-field
            gamefaceUiInstance.logger:Info(str)
        end,
        nil
    )
    gamefaceUiInstance:AddEventListener(
        "ForgeUtils_LogDebug",
        1,
        function(str)
            ---@diagnostic disable-next-line: undefined-field
            gamefaceUiInstance.logger:Debug(str)
        end,
        nil
    )
    gamefaceUiInstance:AddEventListener(
        "ForgeUtils_LogWarn",
        1,
        function(str)
            ---@diagnostic disable-next-line: undefined-field
            gamefaceUiInstance.logger:Warn(str)
        end,
        nil
    )
    gamefaceUiInstance:AddEventListener(
        "ForgeUtils_LogError",
        1,
        function(str)
            ---@diagnostic disable-next-line: undefined-field
            gamefaceUiInstance.logger:Error(str)
        end,
        nil
    )

    ---@diagnostic disable-next-line: undefined-field
    gamefaceUiInstance.logger:Info("Finished adding Event Listeners")
end

--- Adds a UI hook to a gameface view matching a name.
--- Handles common logic common to all hook types.
--- Note: this function should only be used internally.
--- @private
--- @param viewName string
--- @param hook forgeutils.UiHookManager.UiHook
--- @private
function UiHookManager:_AddHookCommon(viewName, hook)
    if UiHookManagerState.hooks[viewName] == nil then
        UiHookManagerState.hooks[viewName] = {}
    end

    local viewHooks = UiHookManagerState.hooks[viewName]
    viewHooks[#viewHooks + 1] = hook
    for gamefaceUiWrapper, wrapperViewName in global.pairs(UiHookManagerState.wrappers) do
        -- Early exit
        if (wrapperViewName ~= viewName) then
            goto continue
        end

        self:_AddHookToInstance(gamefaceUiWrapper, hook)

        ::continue::
    end
end

--- Adds a UI hook to any gameface view matching a name.
--- This method should only be called once in the games
--- lifetime for each hook.
---@param viewName string The view name. Examples include `"FrontEnd"` and `"HUD"`.
---@param element string The javascript element to target for the hook. Examples include "div".
---@param jsHookFile string The javascript module with the hook. An example is `"/js/example/hudhook.js"`.
function UiHookManager:AddElementHook(viewName, element, jsHookFile)
    self:_AddHookCommon(
        viewName,
        {
            type = "Element",
            element = element,
            file = jsHookFile
        }
    )
end

--- Adds a UI import hook to any gameface view matching a name.
--- This method should only be called once in the games
--- lifetime for each hook.
---@param viewName string The view name. Examples include `"FrontEnd"` and `"HUD"`.
---@param jsImportFile string The javascript module to import. An example is `"/js/example/import.js"`.
function UiHookManager:AddImportHook(viewName, jsImportFile)
    self:_AddHookCommon(
        viewName,
        {
            type = "Import",
            file = jsImportFile
        }
    )
end

-- Based on state, init if needed.
if not UiHookManagerState.initialized then
    UiHookManager:_InitUiHookManager()
end

return UiHookManager
