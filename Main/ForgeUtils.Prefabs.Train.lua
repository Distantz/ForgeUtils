-----------------------------------------------------------------------
--/  @file    Utils.Train.lua
--/  @author  Distantz
--/  @version 1.0
--/
--/  @brief  Easy to use library to make train creation easier
--/
--/  @see    https://github.com/OpenNaja/ACSE
-----------------------------------------------------------------------
local global  = _G
local api     = global.api
local Vector3 = require('Vector3')
local Vector2 = require('Vector2')
local require = global.require
local pairs   = global.pairs
local ipairs  = global.ipairs
local string = global.string
local tostring = global.tostring
local type = global.type
local table = global.table
local math = global.math
local tonumber = global.tonumber

---@class TrainLibrary
local TrainLibrary = {}

-- #region Constants

TrainLibrary.BogC_Platform = "BogCar"
TrainLibrary.CarF_Platform = "CarF"
-- Note the use of the index in this string. It's used to separate each mid-car into its own platform.
TrainLibrary.CarM_Platform = "CarM{1}"
TrainLibrary.CarR_Platform = "CarR"

TrainLibrary.BaseCarPrefab = "CoasterCarBase"
TrainLibrary.BaseWheelAssemblyPrefab = "CoasterCarAnimatedWheelBase"

--#endregion

--#region Simple utils

function TrainLibrary.PrintPrefab(tbl, indent)
  if not indent then indent = 0 end
  for k, v in pairs(tbl) do
    local formatting = string.rep("  ", indent) .. k .. ": "
    if type(v) == "table" then
      api.debug.Trace(formatting)
      TrainLibrary.PrintPrefab(v, indent+1)
    else
      api.debug.Trace(formatting .. tostring(v))
    end
  end
end


function TrainLibrary.HexCodeToFlexiColour(hex)

    -- Remove leading '#' if present
    hex = hex:gsub("^#", "")

    -- Extract RGB components
    local r = tonumber(hex:sub(1, 2), 16)
    local g = tonumber(hex:sub(3, 4), 16)
    local b = tonumber(hex:sub(5, 6), 16)

    -- Normalize to 0-1 range
    return Vector3:new(
        r / 255,
        g / 255,
        b / 255
    )
end

---Returns a simple bone attachment, components with a bone transform and a zero'd transform.
---@param boneName string The name of the bone to attach to.
---@return table
function TrainLibrary.GetSimpleBoneAttachment(boneName)
    return {
        Components = {
            BoneTransform = {
                AnimEntity = "..",
                BoneName = boneName
            },
            Transform = TrainLibrary.GetTransformComponent(
                Vector3:new(0.0, 0.0, 0.0), 
                Vector3:new(0.0, 0.0, 0.0), 
                1.0
            )
        }
    }
end

---Returns a simple bone attachment with children.
---@param boneName string The name of the bone to attach to.
---@param children table The children of this attachment.
---@return table
function TrainLibrary.GetBoneAttachmentParent(boneName, children)
    local sba = TrainLibrary.GetSimpleBoneAttachment(boneName)
    sba["Children"] = children
    return sba
end

---Returns a simple attachment child, usually used for catch cars.
---@param boneName any
---@return table
function TrainLibrary.GetSimpleAttachPoint(boneName)
    return {
        Components = {Transform = {}},
        Prefab = 'AttachPoint',
        Properties = {
            AttachBone = {
                Default = boneName
            }
        }
    }
end

---Returns a parent provider path. For example, 3 will return '../../..'.
---@param numberLevelsUp integer The number of levels to move up in the prefab chain.
---@return string
function TrainLibrary.GetParentProviderPath(numberLevelsUp)
    if numberLevelsUp == 0 then
        return "."
    end
    return string.rep("../", numberLevelsUp):sub(1, -2)
end

---Returns a simple RenderMaterialEffects with the correct parent provider path.
---@param numberLevelsUp integer The number of levels to move up in the prefab chain.
---@return table
function TrainLibrary.GetRenderMaterialEffects(numberLevelsUp)
    return {
        InstanceData = {
            MaterialCustomisationProviderEntity = TrainLibrary.GetParentProviderPath(numberLevelsUp)
        }
    }
end


---Returns a transfom component with these values
---@param position any A Vector3 noting the position
---@param rotation any A Vector3 noting the rotation in euler angles, radians unit
---@param scale number A float representing the scale.
function TrainLibrary.GetTransformComponent(position, rotation, scale)
    return {
        Position = position,
        Rotation = rotation,
        Scale = scale
    }
end

--#endregion

--#region Wheel Assembly Utils

--- Returns a wheel bogie prefab with wheel flexicolours set to reference the parent.
---@param wheelAssemblyPrefabName string The name of the Wheel Assembly prefab to spawn.
---@param numberOfWheels integer The number of wheels present on this prefab.
---@return table 
function TrainLibrary.GetSimpleWheelAssemblyPrefab(wheelAssemblyPrefabName, numberOfWheels)
    local children = {}
    for i=1, numberOfWheels do
        local wheelName = "Wheel" .. i
        children[wheelName] = {
            Components = {
                RenderMaterialEffects = TrainLibrary.GetRenderMaterialEffects(3)
            }
        }
    end
    return {
        Components = {
            RenderMaterialEffects = TrainLibrary.GetRenderMaterialEffects(2),
            Transform = {}
        },
        Children = children,
        Prefab = wheelAssemblyPrefabName
    }
end

---Returns a wheel prefab, with needed fields.
---@param attachToBoneName string The bone on the outer wheel assembly to attach to.
---@param wheelModelName string The name of the Wheel model to use.
function TrainLibrary.GetSimpleWheelChildPrefab(attachToBoneName, wheelModelName)

    return {
        Properties = {
            WheelBoneName = {
                Default = attachToBoneName
            },
            ModelName = {
                Default = wheelModelName
            }
        },
        Prefab = "CC_Mod_Wheel_Base"
    }
end


--- Returns a simple set of components for a train prefab with needed fields.
--- Note, packages requires the same syntax as passed into regular prefabs.
---@param carModelName string The name of the car model. This will also be used as it's model skeleton.
---@param assetPackageLoader table The assetPackageLoader to use.
---@param numFlexiChannels integer The number of flexi channels. Ranges from 0 to 4.
---@param mass number The mass, in kilograms, of the trian car. Used in physics. Usually around 1000.0
---@return table
function TrainLibrary.GetSimpleTrainComponents(carModelName, assetPackageLoader, numFlexiChannels, mass)

    local semantics = {}
    local numChannels = math.max(0, math.min(4, numFlexiChannels))

    for i=1, numChannels do
        local semantic = {
            SemanticTag = "CoasterCar" .. i
        }

        if (i ~= 1) then
           semantic["MaterialCustomisationProviderSlot"] = i-1
        end

        semantics[i] = semantic
    end

    return {
        Model = {
			UpdateCullingVolume = false,
			ModelName = carModelName
		},
		ModelSkeleton = {ModelName = carModelName},
        TrackedRideCar = {
			Mass = mass
		},
        AssetPackageProvider = {
			LoaderPath = '.'
		},
		AssetPackageLoader = assetPackageLoader,
        SemanticTag = {
			SemanticTagMap = semantics
		},
		Transform = {},
	}
end

--- Returns a simple set of components with needed fields for a Bogie (WAS, or Wheel Assembly) prefab with needed fields.
--- Note, packages requires the same syntax as passed into regular prefabs.
---@param assetPackageLoader table The assetPackageLoader to use.
---@return table
function TrainLibrary.GetBogieComponents(assetPackageLoader)
    return {
        Transform = {},
        TrackedRideWheel = {},
        AssetPackageLoader = assetPackageLoader,
        AssetPackageProvider = {
            LoaderPath = '.'
        }
    }
end

---Returns a SceneryPlatform child filled out with the basic information. 
--- Note, does not use RotationalSymmetryAxis.
---@see TrainLibrary.GetRotationalSymmetryAxisSceneryPlatform
---@param sceneryPlatformMeshName string The scenery platform mesh name.
---@param platformNameSuffix string The suffix to add to the PlatformNameFormat and used within twinning.
---@return table
function TrainLibrary.GetSimpleSceneryPlatform(sceneryPlatformMeshName, platformNameSuffix)
    return {
        Components = {
            SceneryPlatformFinder = {
                ModelAssetPackageLoader = '..',
                ModelName = sceneryPlatformMeshName,
                DisplayShapeLocalPlaneDistance = -0.2
            },
            SceneryPlatformDynamic = {
                InputValues = {
                    __property = 'InputValues'
                },
                TwinningSetGroupFormats = {
                    {
                        GroupNameFormat = 'Train{0}_AllCars'
                    },
                    {
                        SetIndex = 1,
                        GroupNameFormat = 'AllTrains_' .. platformNameSuffix
                    },
                    {
                        SetIndex = 2,
                        GroupNameFormat = 'AllTrains_AllCars'
                    }
                },
                PlatformNameFormat = 'Train{0}_' .. platformNameSuffix
            },
            TriggerTargetContext = {
                TrackedRideCarEntity = '..'
            },
            Transform = TrainLibrary.GetTransformComponent(
                Vector3:new(0.0, 0.0, 0.0), 
                Vector3:new(0.0, 0.0, 0.0), 
                1.0
            ),
            AssetPackageProvider = {
                LoaderPath = '..'
            },
            SceneryPlatform = {
                PlatformIDProvider = TrainLibrary.GetParentProviderPath(4)
            }
        },
        Properties = {
            InputValues = {
                Type = 'array',
                Contents = {
                    Type = 'uint64'
                },
                Default = {
                    __inheritance = 'Append'
                }
            }
        }
    }
end

---Returns a SceneryPlatform child filled out with the basic information. Includes a rotational symmetry axis.
---@see TrainLibrary.GetSimpleSceneryPlatform
---@param sceneryPlatformMeshName string The scenery platform mesh name.
---@param platformNameSuffix string The suffix to add to the PlatformNameFormat and used within twinning.
---@param symmetryAxisTransform any The transfom of the rotational symmetry axis. It will use the Y (up) axis of this transform.
---@return table
function TrainLibrary.GetRotationalSymmetryAxisSceneryPlatform(sceneryPlatformMeshName, platformNameSuffix, symmetryAxisTransform)

    local basePlatform = TrainLibrary.GetSimpleSceneryPlatform(sceneryPlatformMeshName, platformNameSuffix)

    -- Point to our child that we will add
    basePlatform["Components"]["SceneryDuplicationContext"] = {
        RotationalSymmetryAxisEntity = './RotationalSymmetryAxis'
    }

    -- Add the child
    basePlatform["Children"] = {
        RotationalSymmetryAxis = {
            Components = {
                Transform = symmetryAxisTransform
            }
        }
    }

    return basePlatform

end

--#region Camera utils

---Returns a simple camera child
---@param cameraPrefabName string The name of the camera prefab
---@param position any Vector3 of the position of the camera, relative to origin of the parent
---@param rotation any Vector3 of the rotation of the camera, in RADIANS, relative to origin of the parent
---@return table
function TrainLibrary.GetSimpleCameraChild(cameraPrefabName, position, rotation)
    return {
        Prefab = cameraPrefabName,
        Properties = {
            FOV = {
                Default = 1.0
            },
            Position = {
                Default = position
            },
            Rotation = {
                Default = rotation
            }
        }
    }
end