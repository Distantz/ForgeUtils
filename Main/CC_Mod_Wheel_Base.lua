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
