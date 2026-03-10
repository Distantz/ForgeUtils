---@class forgeutils.Version Semantic versioning type.
---@field major integer? The major (breaking change) number.
---@field minor integer? The minor (new non-breaking addition) number.
---@field patch integer? The patch (non-breaking bug fix) number.
local Version = {}
Version.__index = Version

function Version.new(args)
    local self = setmetatable({}, Version)
    self.major = args.major
    self.minor = args.minor
    self.patch = args.patch
    return self
end

function Version:toString()
    return self.major .. "." .. self.minor .. "." .. self.patch
end

function Version:isCompatible(v)
    -- Major types are locked. Minor and patch can be smaller or equal.
    if v.major == self.major and v.minor <= self.minor and v.patch <= self.patch then
        return true
    end
    return false
end

return Version
