local global = _G
local setmetatable = global.setmetatable
local constants = require("forgeutils.internal.database.constants.TrackedRides")

--- @class forgeutils.builders.data.element.ElementData
--- @field type string
--- @field label string?
--- @field icon string?
--- @field cost integer
--- @field requiredPower number?
--- @field leadsInto string?
--- @field trackWearMultiplier number?
--- @field disabledText string
--- @field ordering number?
--- @field leadsOutOf string?
--- @field canGoUnderwater boolean?
--- @field descriptionText string?
--- @field description2Text string?
--- @field description3Text string?
local ElementData = {}
ElementData.__index = ElementData

--- Create a new ElementData data object.
--- @return self
function ElementData.new()
    local self = setmetatable({}, ElementData)
    -- Sane defaults
    self.type = constants.ElementTypes_Utilities
    self.cost = 1200 -- matches default_spline
    self.disabledText = constants.ElementDisabledTexts_TrackElementDisabled_CannotPlace
    self.ordering = nil
    -- DB defaults
    self.label = "NormalTrack"           -- matches default_spline
    self.icon = "CoasterEditorIconTrack" -- matches default_spline
    self.requiredPower = nil
    self.leadsInto = nil
    self.trackWearMultiplier = 1 -- matches default_spline
    self.leadsOutOf = nil
    self.canGoUnderwater = nil
    self.descriptionText = "TrackElementName_NormalTrack"
    self.description2Text = nil
    self.description3Text = nil
    return self
end

--- @param type string
--- @return self
function ElementData:withType(type)
    self.type = type
    return self
end

--- @param label string?
--- @return self
function ElementData:withLabel(label)
    self.label = label
    return self
end

--- @param icon string?
--- @return self
function ElementData:withIcon(icon)
    self.icon = icon
    return self
end

--- @param cost integer
--- @return self
function ElementData:withCost(cost)
    self.cost = cost
    return self
end

--- @param requiredPower number?
--- @return self
function ElementData:withRequiredPower(requiredPower)
    self.requiredPower = requiredPower
    return self
end

--- @param leadsInto string?
--- @return self
function ElementData:withLeadsInto(leadsInto)
    self.leadsInto = leadsInto
    return self
end

--- @param trackWearMultiplier number?
--- @return self
function ElementData:withTrackWearMultiplier(trackWearMultiplier)
    self.trackWearMultiplier = trackWearMultiplier
    return self
end

--- @param disabledText string
--- @return self
function ElementData:withDisabledText(disabledText)
    self.disabledText = disabledText
    return self
end

--- @param ordering number
--- @return self
function ElementData:withOrdering(ordering)
    self.ordering = ordering
    return self
end

--- @param leadsOutOf string?
--- @return self
function ElementData:withLeadsOutOf(leadsOutOf)
    self.leadsOutOf = leadsOutOf
    return self
end

--- @param canGoUnderwater boolean?
--- @return self
function ElementData:withCanGoUnderwater(canGoUnderwater)
    self.canGoUnderwater = canGoUnderwater
    return self
end

--- @param descriptionText string?
--- @return self
function ElementData:withDescriptionText(descriptionText)
    self.descriptionText = descriptionText
    return self
end

--- @param description2Text string?
--- @return self
function ElementData:withDescription2Text(description2Text)
    self.description2Text = description2Text
    return self
end

--- @param description3Text string?
--- @return self
function ElementData:withDescription3Text(description3Text)
    self.description3Text = description3Text
    return self
end

return ElementData
