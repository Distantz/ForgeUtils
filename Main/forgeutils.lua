local global = _G
---@diagnostic disable-next-line: undefined-field
local api = global.api

-- Inject references here to allow for Lua intellisense
---@class (Partial) Api
---@field forgeutils global.api.forgeutils? The forgeutils API field. Used to store singleton data.
---@diagnostic disable-next-line: undefined-field

--- The forgeutils API field. Used to store singleton data.
---@class global.api.forgeutils

---This is a simple namespace for forgeutils.
---Contains the version of the mod.
local version = require("forgeutils.modversion")

---@class forgeutils
---@field version forgeutils.Version The version of ForgeUtils.
local ForgeUtils = {}

-- Note: Do not change the indentation.
-- This is modified and read by pipelines.
-- Modify data in place.
ForgeUtils.version = version.new({
    major = 2,
    minor = 0,
    patch = 0
})

return ForgeUtils
