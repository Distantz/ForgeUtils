local global = _G
local setmetatable = global.setmetatable

local constants = require("forgeutils.internal.database.constants.TrackedRides")
local hexCodeUtils = require("forgeutils.utils.hexcodeutils")

---@class forgeutils.builders.data.trackedride.Flexicolour
---@field semanticTag string
---@field materialCustomizationProviderSlot integer
---@field red integer
---@field green integer
---@field blue integer
local Flexicolour = {}
Flexicolour.__index = Flexicolour

--- Create a new BrowserEntries data object.
--- @return self
function Flexicolour.new()
    local self = setmetatable({}, Flexicolour)
    -- Sane defaults
    self.semanticTag = nil
    self.materialCustomizationProviderSlot = nil
    self.red = 255 -- default is white
    self.green = 255
    self.blue = 255
    return self
end

--- @param semanticTag string
--- @return self
function Flexicolour:withSemanticTag(semanticTag)
    self.semanticTag = semanticTag
    return self
end

--- @param materialCustomizationProviderSlot integer Starting at 0.
--- @return self
function Flexicolour:withMaterialCustomizationProviderSlot(materialCustomizationProviderSlot)
    self.materialCustomizationProviderSlot = materialCustomizationProviderSlot
    return self
end

--- @param red integer Between 0 and 255.
--- @return self
function Flexicolour:withRed(red)
    self.red = red
    return self
end

--- @param green integer Between 0 and 255.
--- @return self
function Flexicolour:withGreen(green)
    self.green = green
    return self
end

--- @param blue integer Between 0 and 255.
--- @return self
function Flexicolour:withBlue(blue)
    self.blue = blue
    return self
end

--- Helper method, which sets up the colours to match a hex code.
--- @param hexCode string
--- @return self
function Flexicolour:withHexCode(hexCode)
    local r, g, b, _ = hexCodeUtils.HexCodeToRGBA(hexCode)
    return self
        :withRed(r)
        :withBlue(b)
        :withGreen(g)
end

--- Helper method, which sets up a flexicolour for track slot 1.
--- @param hexCode string
--- @return self
function Flexicolour:withTrackSlot1(hexCode)
    return self
        :withSemanticTag(constants.FlexiColourSemanticTags_Track1)
        :withMaterialCustomizationProviderSlot(0)
        :withHexCode(hexCode)
end

--- Helper method, which sets up a flexicolour for track slot 2.
--- @param hexCode string
--- @return self
function Flexicolour:withTrackSlot2(hexCode)
    return self
        :withSemanticTag(constants.FlexiColourSemanticTags_Track2)
        :withMaterialCustomizationProviderSlot(1)
        :withHexCode(hexCode)
end

--- Helper method, which sets up a flexicolour for track slot 3.
--- @param hexCode string
--- @return self
function Flexicolour:withTrackSlot3(hexCode)
    return self
        :withSemanticTag(constants.FlexiColourSemanticTags_Track3)
        :withMaterialCustomizationProviderSlot(2)
        :withHexCode(hexCode)
end

--- Helper method, which sets up a flexicolour for track slot 4.
--- @param hexCode string
--- @return self
function Flexicolour:withTrackSlot4(hexCode)
    return self
        :withSemanticTag(constants.FlexiColourSemanticTags_Track4)
        :withMaterialCustomizationProviderSlot(3)
        :withHexCode(hexCode)
end

--- Helper method, which sets up a flexicolour for flume slot 1.
--- @param hexCode string
--- @return self
function Flexicolour:withFlumeSlot1(hexCode)
    return self
        :withSemanticTag(constants.FlexiColourSemanticTags_Flume001)
        :withMaterialCustomizationProviderSlot(0)
        :withHexCode(hexCode)
end

--- Helper method, which sets up a flexicolour for flume slot 2.
--- @param hexCode string
--- @return self
function Flexicolour:withFlumeSlot2(hexCode)
    return self
        :withSemanticTag(constants.FlexiColourSemanticTags_Flume002)
        :withMaterialCustomizationProviderSlot(1)
        :withHexCode(hexCode)
end

--- Helper method, which sets up a flexicolour for the support flume slot.
--- @param hexCode string
--- @return self
function Flexicolour:withFlumeSlotSupports(hexCode)
    return self
        :withSemanticTag(constants.FlexiColourSemanticTags_Supports)
        :withMaterialCustomizationProviderSlot(2)
        :withHexCode(hexCode)
end

--- Helper method, which sets up a flexicolour for flume slot 3.
--- @param hexCode string
--- @return self
function Flexicolour:withFlumeSlot3(hexCode)
    return self
        :withSemanticTag(constants.FlexiColourSemanticTags_Flume003)
        :withMaterialCustomizationProviderSlot(3)
        :withHexCode(hexCode)
end

--- Helper method, which sets up a flexicolour for flume slot 4.
--- @param hexCode string
--- @return self
function Flexicolour:withFlumeSlot4(hexCode)
    return self
        :withSemanticTag(constants.FlexiColourSemanticTags_Flume004)
        :withMaterialCustomizationProviderSlot(4)
        :withHexCode(hexCode)
end

return Flexicolour
