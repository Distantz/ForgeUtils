---@class forgeutils.modversion Semantic versioning type.
---@field major integer? The major (breaking change) number.
---@field minor integer? The minor (new non-breaking addition) number.
---@field patch integer? The patch (non-breaking bug fix) number.
local ModVersion = {}
ModVersion.__index = ModVersion

function ModVersion.new(args)
    local self = setmetatable({}, ModVersion)
    self.major = args.major
    self.minor = args.minor
    self.patch = args.patch
    return self
end

function ModVersion:tostring()
    return self.major .. "." .. self.minor .. "." .. self.patch
end

function ModVersion:iscompatable(v)
    if v.major <= self.major and v.minor <= self.minor and v.patch <= self.patch then
        return true
    end
    return false
end

return ModVersion
