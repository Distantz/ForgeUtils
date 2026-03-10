local global = _G
local logger = require("forgeutils.logger").Get("HexCodeUtils")

---@class forgeutils.utils.HexCodeUtils
local HexCodeUtils = {}

--- Returns R, G, B, A integers between 0 and 255.
--- Format is the standard #AARRGGBB or #RRGGBB. This matches VSCode integration.
--- You do not need to provide the alpha channel.
--- Supports leading #.
---@param hexCode string The hex code. Example: #FF00FF.
---@return integer r The red channel.
---@return integer g The green channel.
---@return integer b The blue channel.
---@return integer a The alpha channel.
function HexCodeUtils.HexCodeToRGBA(hexCode)
    -- Remove leading '#' if present
    hexCode = hexCode:gsub("^#", "")

    local len = hexCode:len()
    local isSixDigit = len == 6
    local isEightDigit = len == 8

    if not isSixDigit and not isEightDigit then
        logger:Error(
            "Hex code: " ..
            hexCode ..
            " is " ..
            global.tostring(len) ..
            " characters long. Needs to be either 6 or 8!"
        )
        return 0, 0, 0, 0
    end

    local function getAtOffset(_offset)
        return global.tonumber(hexCode:sub(_offset + 1, _offset + 2), 16)
    end

    local alphaOffset = 0
    if isEightDigit then
        alphaOffset = 2
    end

    local a = 255
    if isEightDigit then
        a = getAtOffset(0)
    end

    -- Extract RGB components
    local r = getAtOffset(alphaOffset)
    local g = getAtOffset(alphaOffset + 2)
    local b = getAtOffset(alphaOffset + 4)

    return r, g, b, a
end

return HexCodeUtils
