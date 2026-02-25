local global = _G
local require = global.require
local logger = require("forgeutils.logger").Get("UiHookManager", "INFO")
local hookManager = require("forgeutils.hookmanager")

--#region Definitions

---@class forgeutils.UiHook A type representing a UI hook.
---@field element string The element to apply the hook to. This is the token name of the type in JS. `"div"` is an example, `"Button"` is another.
---@field file string The file that contains the JavaScript UI hook. An example is `"/js/hooks/forgeutils/hudBottomBarHook.js"`.

---@class forgeutils.UiHookManager
---@field private hooks table<string, forgeutils.UiHook[]> Keys are view names and value is list of hooks to apply to wrappers on ready.
---@field private wrappers table<GamefaceUIWrapper, string> Keys are gameface UI wrappers and values are view names.
local UiHookManager = {}
UiHookManager.hooks = {}
UiHookManager.wrappers = {}
UiHookManager.FORGEUTILS_HOOK_EVENT = "ForgeUtils_AddModuleHook"

--- Initializes the UI hook manager by adding necessary lua injections.
--- Note: this function should only be used internally.
function UiHookManager:_InitUiHookManager()
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
end

--- A callback on the UI hook manager init.
--- This performs setup for logging.
--- Note: this function should only be used internally.
--- Note: This registers event listeners. It should thus only be called on ready gameface ui instances.
--- @param gamefaceUiInstance GamefaceUIWrapper The gameface instance.
--- @param initSettings table The init settings
--- @private
function UiHookManager:_OnInitCallback(gamefaceUiInstance, initSettings)
    ---@diagnostic disable-next-line: inject-field
    gamefaceUiInstance.logger = logger.Get("UI[" .. initSettings.sViewName .. "]", "DEBUG_QUERY")
    logger:Info("Init")
end

--- A callback on the UI hook manager ready.
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
    self.wrappers[gamefaceUiInstance] = viewName

    if self.hooks[viewName] == nil then
        logger:Debug("No hooks registered for view: " .. viewName)
        return
    end

    local count = #self.hooks[viewName]

    logger:Info("Found " .. global.tostring(count) .. " hooks for view: " .. viewName)

    for _, hook in global.ipairs(self.hooks[viewName]) do
        self:_AddHookToInstance(gamefaceUiInstance, hook)
    end
end

--- Adds a hook to a gameface UI instance.
--- Note: this function should only be used internally.
--- Note: This registers event listeners. It should thus only be called on ready gameface ui instances.
---@param gamefaceUiInstance GamefaceUIWrapper The gameface instance.
---@param uiHook forgeutils.UiHook The hook.
---@private
function UiHookManager:_AddHookToInstance(gamefaceUiInstance, uiHook)
    logger:Info(
        "Applying hook for element \"" ..
        uiHook.element ..
        "\": " ..
        uiHook.file
    )
    gamefaceUiInstance:TriggerEventAtNextAdvance(
        UiHookManager.FORGEUTILS_HOOK_EVENT,
        uiHook.element,
        uiHook.file
    )
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

--- Adds a UI hook to any gameface view matching a name.
--- This method should only be called once in the games
--- lifetime for each hook.
---@param viewName string The view name. Examples include `"FrontEnd"` and `"HUD"`.
---@param element string The javascript element to target for the hook. Examples include "div".
---@param jsHookFile string The javascript module with the hook. An example is `"/js/example/hudhook.js"`.
function UiHookManager:AddHook(viewName, element, jsHookFile)
    if self.hooks[viewName] == nil then
        self.hooks[viewName] = {}
    end

    local viewHooks = self.hooks[viewName]

    local hook = {
        element = element,
        file = jsHookFile
    }

    viewHooks[#viewHooks + 1] = hook

    for gamefaceUiWrapper, wrapperViewName in global.pairs(self.wrappers) do
        -- Early exit
        if (wrapperViewName ~= viewName) then
            goto continue
        end

        self:_AddHookToInstance(gamefaceUiWrapper, hook)

        ::continue::
    end
end

return UiHookManager
