local global = _G
local setmetatable = global.setmetatable

--- @class forgeutils.builders.data.shared.ContentPack
--- @field contentPackName string
--- @field contentPackId integer
local ContentPack = {}
ContentPack.__index = ContentPack

--- Create a new ContentPack data object.
--- @return self
function ContentPack.new()
    local self = setmetatable({}, ContentPack)
    self.contentPackName = "BaseGame"
    self.contentPackId = 0
    return self
end

--- @param name string
--- @return self
function ContentPack:withName(name)
    self.contentPackName = name
    return self
end

--- @param id integer
--- @return self
function ContentPack:withId(id)
    self.contentPackId = id
    return self
end

return ContentPack
