local global = _G
local require = global.require
local string = global.string
local logger = require("forgeutils.logger").Get("HookManager")

--#region Definitions

---@alias hookId string A hook ID, in the string format of "{moduleName}:{functionName}".

--- A hook type.
---@alias HookFunction fun(originalMethod : function, ...): any

---@class HookContainer
---@field moduleName string The module name.
---@field functionName string The function name.
---@field originalFunction function? The original function on the module.
---@field hooks HookFunction[] The hooks registered to this function.

---@class forgeutils.HookManager
---@field private tHooks table<hookId, HookContainer>
local HookManager = {}
HookManager.tHooks = {}

--#endregion

--#region Functions

--- Returns an ID for a module name and function name.
--- Should be used internally.
---@param moduleName string The module name.
---@param functionName string The function name.
---@return hookId? id The hook ID.
function HookManager:GetHookId(moduleName, functionName)
    if (global.type(moduleName) ~= "string") then
        logger:Error("Failed to get hook ID. Module name was not a string.")
        return nil
    end
    if (global.type(functionName) ~= "string") then
        logger:Error("Failed to get hook ID. Function name was not a string.")
    end
    return string.lower(moduleName) .. ":" .. functionName
end

--- Ensures the nessessary hook container exists.
---@param moduleName string The module name.
---@param functionName string The function name.
---@return HookContainer? container The hook container, or nil on error.
function HookManager:EnsureHookContainer(moduleName, functionName)
    local id = self:GetHookId(moduleName, functionName)
    if id == nil then
        logger:Error("Failed to validate hook. ID was nil, look above for causes.")
        return nil
    end

    if self.tHooks[id] == nil then
        -- create new hook container
        self.tHooks[id] = {
            moduleName = moduleName,
            functionName = functionName,
            hooks = {}
        }
    end

    return self.tHooks[id]
end

--- Validates and sets up a module for hook management.
--- Should be used internally.
---@param moduleName string The module name.
---@param functionName string The function name.
---@return boolean success Whether the validation succeeded.
function HookManager:ValidateHook(moduleName, functionName)
    local id = self:GetHookId(moduleName, functionName)
    if id == nil then
        logger:Error("Failed to validate hook. ID was nil, look above for causes.")
        return false
    end

    local hookContainer = self:EnsureHookContainer(moduleName, functionName)
    if hookContainer == nil then
        logger:Error("Failed to validate hook. Hook container was nil, look above for causes.")
        return false
    end

    local moduleTable = require(moduleName)
    if moduleTable == nil then
        logger:Error("Failed to validate hook. Provided module \"" .. global.tostring(moduleName) .. "\" does not exist.")
        return false
    end

    local moduleFunc = moduleTable[functionName]
    if moduleFunc == nil or global.type(moduleFunc) ~= "function" then
        logger:Error(
            "Failed to validate hook. Provided module \"" ..
            global.tostring(moduleName) ..
            "\" does not contain an accessible function called \"" ..
            global.tostring(functionName) ..
            "\"."
        )
        return false
    end

    -- Rehook if original function is not set
    if hookContainer.originalFunction == nil then
        hookContainer.originalFunction = moduleFunc
    end

    local tHookCallbacks = {}

    -- Setup hook callbacks, in reverse order
    for i = #hookContainer.hooks, 1, -1 do
        local originalMethod = hookContainer.hooks[i + 1] or hookContainer.originalFunction
        tHookCallbacks[i] = function(...)
            return hookContainer.hooks[i](originalMethod, ...)
        end
    end

    -- Set module to use the first hook in the chain.
    if tHookCallbacks[1] ~= nil then
        logger:Info("Hooked for " .. id)
        moduleTable[functionName] = tHookCallbacks[1]
    end

    return true
end

--- Validates all present hooks in the hook manager.
--- Should be used internally only.
function HookManager:ValidateAllHooks()
    for id, container in global.pairs(self.tHooks) do
        if not self:ValidateHook(container.moduleName, container.functionName) then
            logger:Warn("Hook \"" .. id .. "\" failed to validate. This function will reset to the original value.")
            if container.originalFunction ~= nil then
                require(container.moduleName)[container.functionName] = container.originalFunction
                container.originalFunction = nil
            end
        end
    end
end

--- Registers a prefix hook for a method on a module.
--- This hook will override the original method on the module.
--- The last added hook to this function will be the first hook to be called.
--- In this case, the originalMethod passed could be another hook.
---@param moduleName string The module to add this hook to.
---@param functionName string The function name on the module.
---@param hookMethod HookFunction The hook function, to call in place of the original method.
---@return boolean success Whether the hook was registered successfully.
function HookManager:AddHook(moduleName, functionName, hookMethod)
    if global.type(hookMethod) ~= "function" then
        logger:Error("Could not add hook. Hook method was nil.")
        return false
    end

    local id = self:GetHookId(moduleName, functionName)
    if id == nil then
        logger:Error("Could not add hook. Could not get ID.")
        return false
    end

    -- Perform lookup
    local hookContainer = HookManager:EnsureHookContainer(moduleName, functionName)
    if hookContainer == nil then
        logger:Error("Could not add hook. Hook container was nil.")
        return false
    end

    hookContainer.hooks[#hookContainer.hooks + 1] = hookMethod

    if not self:ValidateHook(moduleName, functionName) then
        logger:Error("Could not add hook. Hook validation failed.")
        return false
    end

    return true
end

--#endregion

return HookManager
