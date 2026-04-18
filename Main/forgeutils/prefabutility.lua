local global = _G
---@type Api
---@diagnostic disable-next-line: undefined-field
local api = global.api

local logger = require("forgeutils.logger").Get("PrefabUtility", "INFO")

--- Enables prefab boilerplate to automatically be added when the prefab is compiled.
--- The prefab, when added with this utility, will have its package mutated such that
--- the GetRoot and GetFlattenedRoot method are populated automatically.
---
--- This class should be used statically within the AddLuaPrefabs ACSE database method.
--- Example:
--- ```lua
--- local PrefabUtility = require("forgeutils.PrefabUtility")
--- PrefabUtility.AddAugmentedPrefabs(
---     {
---         "PC_ExamplePrefabOne",
---         "PC_ExamplePrefabTwo"
---     },
---     _fnAdd
--- )
--- ```
--- Where a prefab file has the contents:
--- ```lua
--- return {
---     Prefab = "ExampleBasePrefab",
--- }
--- ```
--- Look at how ForgeUtils loads `CC_Mod_Wheel_Base.lua` for an example of how this is used.
---@class forgeutils.PrefabUtility
local PrefabUtility = {}

--- Augments a prefab into a table with GetRoot and GetFlattenedRoot methods.
---@param prefabName string The name of the prefab file.
---@return table
---@private
function PrefabUtility.GetAugmentedPrefab(prefabName)
    prefabName = global.string.lower(prefabName)

    -- Return already-augmented prefab if cached
    local cached = global.package.loaded[prefabName]
    if cached and global.type(cached) == "table" and cached.GetRoot then
        return cached
    end

    -- Clear cache so require re-runs the file and gives us the raw function
    global.package.loaded[prefabName] = nil

    local prefabFile = global.require(prefabName)

    local newPrefab = {}
    newPrefab.GetRoot = function()
        return prefabFile
    end
    newPrefab.GetFlattenedRoot = function()
        ---@diagnostic disable-next-line: undefined-field
        local tPrefab = api.entity.FindPrefab(prefabName)
        if not tPrefab then
            ---@diagnostic disable-next-line: undefined-field
            if api.entity.CompilePrefab(newPrefab.GetRoot(), prefabName) then
                ---@diagnostic disable-next-line: undefined-field
                tPrefab = api.entity.FindPrefab(prefabName)
            end
        end
        return tPrefab
    end

    -- Set loaded packages to include the augmented prefab
    global.package.loaded[prefabName] = newPrefab
    return newPrefab
end

--- Loads and adds a prefab file to the game.
--- This method automatically sets up the boilerplate for the prefab.
--- This includes the GetRoot and GetFlattenedRoot methods.
--- A prefab file should only contain the prefab table returned, like below:
--- ```lua
--- return {
---     Prefab = "ExampleBasePrefab",
--- }
--- ```
---@param prefabName string
---@param _fnAdd function
function PrefabUtility.AddAugmentedPrefab(prefabName, _fnAdd)
    logger:Info("Trying to add: " .. prefabName)
    local prefab = PrefabUtility.GetAugmentedPrefab(prefabName)
    if prefab == nil then
        logger:Error("Could not add prefab, was nil.")
        return
    end
    local root = prefab.GetRoot()
    _fnAdd(prefabName, root)
end

--- Loads and adds prefabs files to the game.
--- This method automatically sets up the boilerplate for the prefabs.
--- This includes the GetRoot and GetFlattenedRoot methods.
--- A prefab file should only contain the prefab table returned, like below:
--- ```lua
--- return {
---     Prefab = "ExampleBasePrefab",
--- }
--- ```
---@param prefabNames string[]
---@param _fnAdd function
function PrefabUtility.AddAugmentedPrefabs(prefabNames, _fnAdd)
    for _, name in global.ipairs(prefabNames) do
        PrefabUtility.AddAugmentedPrefab(name, _fnAdd)
    end
end

return PrefabUtility
