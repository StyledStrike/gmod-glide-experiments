AddCSLuaFile()

ENT.Type = "anim"
ENT.Base = "base_glide_car"
ENT.PrintName = "Caddy"
ENT.GlideCategory = "StyledsExperiments"

ENT.ChassisModel = "models/gta5/vehicles/caddy2/chassis.mdl"
ENT.MaxChassisHealth = 600
ENT.CanSwitchTurnSignals = false

if CLIENT then
    ENT.CameraOffset = Vector( -170, 0, 55 )
    ENT.EngineSmokeMaxZVel = 60

    ENT.EngineSmokeStrips = {
        { offset = Vector( 45, 0, -5 ), angle = Angle( 40, 0, 0 ), width = 15 }
    }

    ENT.EngineFireOffsets = {
        { offset = Vector( 45, 0, -5 ), angle = Angle( 90, 0, 0 ), scale = 0.4 }
    }

    ENT.Headlights = {
        { offset = Vector( 45, 12.5, 1 ), texture = "glide/effects/headlight_circle2" },
        { offset = Vector( 45, -12.5, 1 ), texture = "glide/effects/headlight_circle2" }
    }

    ENT.LightSprites = {
        { type = "headlight", offset = Vector( 48, 12.5, 1 ), dir = Vector( 1, 0, 0 ) },
        { type = "headlight", offset = Vector( 48, -12.5, 1 ), dir = Vector( 1, 0, 0 ) },
    }

    ENT.StartSound = ""
    ENT.StartedSound = ""
    ENT.StoppedSound = ""

    ENT.HornSound = "glide/horns/car_horn_light_1.wav"
    ENT.ExhaustPopSound = ""
    ENT.ExternalGearSwitchSound = ""
    ENT.InternalGearSwitchSound = ""

    function ENT:AllowWindSound()
        return true, 1
    end

    function ENT:AllowFirstPersonMuffledSound()
        return false
    end

    function ENT:OnCreateEngineStream( stream )
        stream.offset = Vector( 15, 0, 0 )
        stream:LoadPreset( "experiment-caddy" )
    end

    DEFINE_BASECLASS( "base_glide_car" )

    --[[
    local POSE_DATA = {
        ["ValveBiped.Bip01_L_UpperArm"] = Angle( -3, 5, 0 ),
        ["ValveBiped.Bip01_R_UpperArm"] = Angle( 6, 8, -5 ),
        ["ValveBiped.Bip01_L_Thigh"] = Angle( 0, -15, 0 ),
        ["ValveBiped.Bip01_L_Calf"] = Angle( -20, 75, 0 ),
        ["ValveBiped.Bip01_R_Thigh"] = Angle( 0, -15, 0 ),
        ["ValveBiped.Bip01_R_Calf"] = Angle( 20, 75, 0 ),
        ["ValveBiped.Bip01_L_Foot"] = Angle( -10, -40, 0 ),
        ["ValveBiped.Bip01_R_Foot"] = Angle( 10, -40, 0 )
    }

    function ENT:GetSeatBoneManipulations( seatIndex )
        if seatIndex > 1 then
            return BaseClass.GetSeatBoneManipulations( self, seatIndex )
        end

        return POSE_DATA
    end]]

    function ENT:OnActivateMisc()
        BaseClass.OnActivateMisc( self )

        self.suspensionLRBone = self:LookupBone( "suspension_lr" )
        self.suspensionRRBone = self:LookupBone( "suspension_rr" )
    end

    local pos = Vector()

    function ENT:OnUpdateAnimations()
        BaseClass.OnUpdateAnimations( self )

        if not self.suspensionLRBone then return end

        pos[1] = self:GetWheelOffset( 3 ) + 2.8
        self:ManipulateBonePosition( self.suspensionLRBone, pos )

        pos[1] = self:GetWheelOffset( 4 ) + 2.8
        self:ManipulateBonePosition( self.suspensionRRBone, pos )
    end
end

if SERVER then
    ENT.SpawnPositionOffset = Vector( 0, 0, 40 )
    ENT.ChassisMass = 400
    ENT.AirControlForce = Vector( 1, 0.5, 0.2 )

    function ENT:GetGears()
        return {
            [-1] = 1,
            [0] = 0,
            [1] = 0.75
        }
    end

    ENT.LightBodygroups = {
        { type = "headlight", bodyGroupId = 4, subModelId = 1 }
    }

    function ENT:CreateFeatures()
        self:SetMinRPM( 100 )
        self:SetMaxRPM( 2000 )
        self:SetMinRPMTorque( 4000 )
        self:SetMaxRPMTorque( 4000 )

        self:SetDifferentialRatio( 0.35 )
        self:SetPowerDistribution( -0.8 )
        self:SetBrakePower( 600 )

        self:SetSteerConeChangeRate( 7 )
        self:SetCounterSteer( 0.2 )
        self:SetSteerConeMaxSpeed( 800 )

        self:SetForwardTractionMax( 1500 )
        self:SetSideTractionMultiplier( 10 )
        self:SetSideTractionMax( 1000 )
        self:SetSideTractionMin( 500 )

        self:SetSuspensionLength( 6 )
        self:SetSpringStrength( 300 )
        self:SetSpringDamper( 1200 )

        self:CreateSeat( Vector( -25, 12, 3 ), Angle( 0, 270, -10 ), Vector( 10, 60, 0 ), true )
        self:CreateSeat( Vector( -18, -12, 3 ), Angle( 0, 270, -5 ), Vector( 10, 60, 0 ), true )

        self:CreateWheel( Vector( 37, 19, -5 ), {
            model = "models/gta5/vehicles/caddy2/wheel.mdl",
            modelAngle = Angle( 0, 90, 0 ),
            modelScale = Vector( 0.38, 1, 1 ),
            steerMultiplier = 1
        } )

        self:CreateWheel( Vector( 37, -19, -5 ), {
            model = "models/gta5/vehicles/caddy2/wheel.mdl",
            modelAngle = Angle( 0, -90, 0 ),
            modelScale = Vector( 0.38, 1, 1 ),
            steerMultiplier = 1
        } )

        self:CreateWheel( Vector( -34, 20, -5 ), {
            model = "models/gta5/vehicles/caddy2/wheel.mdl",
            modelAngle = Angle( 0, 90, 0 ),
            modelScale = Vector( 0.38, 1, 1 )
        } )

        self:CreateWheel( Vector( -34, -20, -5 ), {
            model = "models/gta5/vehicles/caddy2/wheel.mdl",
            modelAngle = Angle( 0, -90, 0 ),
            modelScale = Vector( 0.38, 1, 1 )
        } )

        self:ChangeWheelRadius( 10 )
    end
end
