-----------------------------------------------------------------------
--/  @file    CC_HotRacerBogC_Art.lua
--/  @author  Distantz
--/  @version 1.0
--/
--/  @brief  Defines an ACSE prefab
--/
--/  @see    https://github.com/OpenNaja/ACSE
-----------------------------------------------------------------------
local global            = _G
local api               = global.api
local require           = global.require
local pairs             = global.pairs
local ipairs            = global.ipairs
local Vector3           = require('Vector3')

local trainLib          = require("ForgeUtils.Prefabs.Train")

local CC_Mod_Wheel_Base = {}

-- PropTool uses GetRoot to build the inject the prefabs in ACSE
function CC_Mod_Wheel_Base.GetRoot()
    -- Your prefab information goes in here
    return {
        Components = {
            ViewFilter = {
                ShadowCascade4to7 = false,
                ShadowCascade3 = false,
                GlobalIllumination = false,
                EnvironmentMap = false
            },
            MotionDrivenWheel = {
                WheelAxis = {
                    __property = 'WheelAxis'
                },
                ReverseRotation = {
                    __property = 'ReverseWheelRotation'
                },
                WheelRadius = {
                    __property = 'WheelRadius'
                },
                AnimatedEntity = {
                    __property = 'AnimatedEntity'
                },
                BoneName = {
                    __property = 'WheelBoneName'
                }
            },
            AssetPackageLoader = {
                ManualPackageNames = {
                    "CC_Wheels",
                },
                PackageNames = {
                    __inheritance = 'Append'
                }
            },
            AssetPackageProvider = {

            },
            Transform = {

            },
            Model = {
                ModelName = {
                    __property = 'ModelName'
                }
            },
            RenderMaterialEffects = {
                InstanceData = {
                    MaterialCustomisationProviderEntity = '..',
                    IsDynamic = true
                }
            },
            BoneTransform = {
                BoneName = {
                    __property = 'WheelBoneName'
                },
                AnimEntity = {
                    __property = 'AnimatedEntity'
                }
            }
        },
        Properties = {
            WheelAxis = {
                Type = 'uint8',
                Enum = 'SpinnyWheelAxis',
                Default = 'Pitch'
            },
            ReverseWheelRotation = {
                Type = 'bool',
                Default = false
            },
            WheelRadius = {
                Type = 'float',
                Default = 0.115
            },
            AnimatedEntity = {
                Type = 'entity',
                Default = '..'
            },
            WheelBoneName = {
                Type = 'string',
                Default = ''
            },
            ModelName = {
                Type = 'string',
                Default = 'CC_Wheel_Large_Slim_02'
            }
        }
    }
end

-- Relay on the current entity API to generate the complete prefab
function CC_Mod_Wheel_Base.GetFlattenedRoot()
    local tPrefab = api.entity.FindPrefab("CC_Mod_Wheel_Base")
    if not tPrefab then
        if api.entity.CompilePrefab(CC_Mod_Wheel_Base.GetRoot(), "CC_Mod_Wheel_Base") then
            tPrefab = api.entity.FindPrefab("CC_Mod_Wheel_Base")
        else
        end
    end
    return tPrefab
end

return CC_Mod_Wheel_Base
