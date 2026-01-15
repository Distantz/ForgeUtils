local global = _G
local setmetatable = global.setmetatable

---@class forgeutils.builders.data.trackedride.BrowserEntry
---@field label string
---@field icon string?
---@field description string
---@field releaseGroup number?
---@field manufacturer string?
local BrowserEntry = {}
BrowserEntry.__index = BrowserEntry

--- Create a new BrowserEntries data object.
--- @return self
function BrowserEntry.new()
    local self = setmetatable({}, BrowserEntry)
    -- Sane defaults
    self.label = "ForgeUtilsDefaultRideName"
    self.description = "ForgeUtilsDefaultRideDescription"
    -- DB defaults
    self.icon = nil
    self.releaseGroup = 0
    self.manufacturer = "ForgeUtilsDefaultManufacturer"
    return self
end

--- @param label string
--- @return self
function BrowserEntry:withLabel(label)
    self.label = label
    return self
end

--- @param icon string?
--- @return self
function BrowserEntry:withIcon(icon)
    self.icon = icon
    return self
end

--- @param description string
--- @return self
function BrowserEntry:withDescription(description)
    self.description = description
    return self
end

--- @param releaseGroup number
--- @return self
function BrowserEntry:withReleaseGroup(releaseGroup)
    self.releaseGroup = releaseGroup
    return self
end

--- @param manufacturer string?
--- @return self
function BrowserEntry:withManufacturer(manufacturer)
    self.manufacturer = manufacturer
    return self
end

return BrowserEntry
