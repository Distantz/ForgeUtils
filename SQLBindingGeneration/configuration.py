# This file contains configuration
# It is not intended to be executed.

import os

#
# Generation constants
#

base_lua_namespace = "forgeutils.internal.database"
constants_lua_namespace = f"{base_lua_namespace}.constants"

base_lua_folder = os.path.join(
    "Main", 
    "forgeutils", 
    "internal", 
    "database"
)
constants_lua_folder = os.path.join(
    base_lua_folder,
    "constants"
)

#
# Configuration constants
#

generate_dbs = [
    "TrackedRides",
    "TrackedRideCars",
    "ModularScenery",
    "Audio"
]

generate_db_constants = {
    "TrackedRides": {
        "Classes": "SELECT DISTINCT Type FROM Class ORDER BY Type;",
        "BrowserTooltips": "SELECT DISTINCT Tooltip FROM BrowserTooltips ORDER BY Tooltip;",
        "ElementParams": "SELECT Param FROM ElementParams UNION SELECT Param FROM ElementUsesRideParams ORDER BY Param;",
        "MetadataTags": "SELECT DISTINCT Tag FROM MetadataTags ORDER BY Tag;",
        "FlexiColourSemanticTags": "SELECT DISTINCT SemanticTag FROM DefaultFlexiColours ORDER BY SemanticTag;",
        "ElementDisabledTexts": "SELECT DISTINCT DisabledText FROM ElementData ORDER BY DisabledText;",
        "ElementTypes": "SELECT DISTINCT Type FROM ElementTypes ORDER BY Type;",
    },
    "TrackedRideCars": {
        "WhichCars": "SELECT DISTINCT ID FROM WhichCar ORDER BY ID;",
        "LuaScoringModules": "SELECT DISTINCT LuaScoringModule FROM Trains ORDER BY LuaScoringModule;",
        "AudioChainLiftPrefixes": "SELECT DISTINCT AudioChainLiftPrefix FROM Trains ORDER BY AudioChainLiftPrefix;",
        "AudioBrakePrefixes": "SELECT DISTINCT AudioBrakePrefix FROM Trains ORDER BY AudioBrakePrefix;",
    }
}