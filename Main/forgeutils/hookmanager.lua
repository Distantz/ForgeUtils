local global = _G

---@type Api
---@diagnostic disable-next-line: undefined-field
local api = global.api
local package = global.package
local require = global.require
local string = global.string
local pairs = global.pairs
local type = global.type
local logger = require("forgeutils.logger").Get("HookManager")

--#region Global Definitions

---@class (Partial) global.api.forgeutils
---@field hookManagerState forgeutils.HookManager.HookManagerState

---@class (Partial) forgeutils.HookManager.HookManagerState
---@field hooks table<string, table<string, HookContainer>> A table of hooks

-- Init global API state if not already.
if not api.forgeutils.hookManagerState then
    api.forgeutils.hookManagerState = {
        hooks = {},
    }
end
local hookManagerState = api.forgeutils.hookManagerState

--#endregion

--#region Definitions

--- A hook type.
---@alias HookFunction fun(originalMethod : function, ...): any

---@class HookContainer
---@field originalFunction function? The original function on the module.
---@field hooks HookFunction[] The hooks registered to this function.

--#endregion

---@class forgeutils.HookManager
local HookManager = {}

--- Registers a prefix hook for a method on a module.
--- This hook will override the original method on the module.
--- The last added hook to this function will be the first hook to be called.
--- In this case, the originalMethod passed could be another hook.
---@param moduleName string The module to add this hook to.
---@param functionName string The function name on the module.
---@param hookMethod HookFunction The hook function, to call in place of the original method.
---@return boolean success Whether the hook was registered successfully.
function HookManager:AddHook(moduleName, functionName, hookMethod)
    local moduleName = string.lower(moduleName)
    local packageLoaded = package.loaded[moduleName]

    -- Add to hook table
    if not hookManagerState.hooks[moduleName] then
        hookManagerState.hooks[moduleName] = {}
    end

    local moduleHooks = hookManagerState.hooks[moduleName]

    -- Add to function hook table
    if not moduleHooks[functionName] then
        moduleHooks[functionName] = {
            hooks = {}
        }
    end

    local hooks = moduleHooks[functionName]
    hooks.hooks[#hooks.hooks + 1] = hookMethod

    -- if loaded, revalidate the hooks
    if packageLoaded then
        return self:SetupHookingForFunction(moduleName, functionName)
    end

    return true
end

--- Registers prefix hooks for a table of hooks on a module.
--- This method allows auto wire-up logic for functions in the hooks table
--- which have the prefix. The name without the prefix will be hooked in the module.
--- ```lua
--- -- module is:
--- local module = {
---     ["Function"] = function(a, b, c) end
--- }
--- local hooks = {
---     ["Hook_Function"] = function(originalFunction, a, b, c) end
--- }
---
--- -- default prefix is "Hook_"
--- hookManager:AddHooks("module", hooks)
--- -- which is equivalent to this:
--- hookManager:AddHooks("module", hooks, "Hook_")
--- ```
---@param moduleName string The module to add this hook to.
---@param hooks table The hooks table. Non-string keys will be ignored. Non-function values will be ignored. Prefix will be used to filter.
---@param hookFunctionsPrefix string? The hook function prefix. If not provided, defaults to `"Hook_"`.
function HookManager:AddHooks(moduleName, hooks, hookFunctionsPrefix)
    if not hookFunctionsPrefix then
        hookFunctionsPrefix = "Hook_"
    end

    local len = #hookFunctionsPrefix
    for key, value in pairs(hooks) do
        -- make sure value is a function
        if type(key) ~= "string" or type(value) ~= "function" then
            goto continue
        end

        -- check prefix
        if key:sub(1, len) ~= hookFunctionsPrefix then
            goto continue
        end
        local hookName = key:sub(len + 1)

        -- Add hook
        self:AddHook(moduleName, hookName, value)

        ::continue::
    end
end

---Chains the hooks in a HookContainer.
---The last hook in the list is called first
---The original function is called last.
---@private
---@param originalFunction function
---@param hooks HookFunction[]
---@return function chainFunction
local function buildHookChainMethod(originalFunction, hooks)
    local chain = originalFunction
    for i = 1, #hooks do
        local next = chain
        local hook = hooks[i]
        chain = function(...)
            return hook(next, ...)
        end
    end

    return chain
end

--- Sets up hooking for a tables function
--- @private
---@param moduleName string The module name in lowercase.
---@param functionName string The function name.
---@return boolean
function HookManager:SetupHookingForFunction(moduleName, functionName)
    -- Try find in tHooks
    local moduleHooks = hookManagerState.hooks[moduleName]
    if not moduleHooks then
        logger:Error(
            "No hooks registered for module: " ..
            moduleName
        )
        return false
    end

    local hooks = moduleHooks[functionName]
    if not hooks then
        logger:Error(
            "No hooks registered for: " ..
            moduleName ..
            "." ..
            functionName ..
            "()"
        )
        return false
    end

    -- Try find in loaded
    local value = package.loaded[moduleName]
    if not value then
        logger:Error(
            "Hooking non-existent function: " ..
            moduleName ..
            "." ..
            functionName ..
            "()"
        )
        return false
    end

    local funcType = global.type(value[functionName])
    if funcType ~= "function" then
        logger:Error(
            "Hooking non-existent function: " ..
            moduleName ..
            "." ..
            functionName ..
            "(), found value was: " ..
            funcType
        )
        return false
    end

    -- And cache the original function if it isn't already!
    if not hooks.originalFunction then
        hooks.originalFunction = value[functionName]
    end

    -- If found in loaded, and has hooks, generate chain
    value[functionName] = buildHookChainMethod(hooks.originalFunction, hooks.hooks)
    return true
end

function HookManager:OnRequiredCallbackListener(moduleName, requireReturned)
    -- Do we have hooks registered for this package?
    if not hookManagerState.hooks[moduleName] then
        return
    end

    for functionName, container in pairs(hookManagerState.hooks[moduleName]) do
        -- Check if the function exists
        local funcValue = requireReturned[functionName]
        local funcType = global.type(funcValue)
        if funcType ~= "function" then
            logger:Error(
                "Hooking non-existent function: " ..
                moduleName ..
                "." ..
                functionName ..
                "(), found value was: " ..
                funcType
            )
            goto continue
        end

        -- Always refresh the original function on a new require.
        -- This should fix the hooks vanishing when loading a new world.
        container.originalFunction = funcValue
        self:SetupHookingForFunction(moduleName, functionName)

        ::continue::
    end
end

-- Hook into the forgeutils require hook
---@diagnostic disable-next-line: undefined-field
api.forgeutils.onRequiredCallback = function(moduleName, requireReturned)
    HookManager:OnRequiredCallbackListener(moduleName, requireReturned)
end

return HookManager
