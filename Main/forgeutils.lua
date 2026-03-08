---This is a simple namespace for forgeutils.
---Contains the version of the mod.
local version = require("forgeutils.modversion")

---@class forgeutils
---@field version forgeutils.ModVersion The version of ForgeUtils.
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
