---This is a simple namespace for forgeutils.
---Contains the version of the mod.
local version = require("forgeutils.modversion")

---@class forgeutils.Version Semantic versioning type.
---@field major integer? The major (breaking change) number.
---@field minor integer? The minor (new non-breaking addition) number.
---@field patch integer? The patch (non-breaking bug fix) number.

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
