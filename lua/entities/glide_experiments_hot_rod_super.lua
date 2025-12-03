AddCSLuaFile()

ENT.Type = "anim"
ENT.Base = "base_glide_car"
ENT.PrintName = "Hot Rod Super"
ENT.GlideCategory = "StyledsExperiments"

ENT.ChassisModel = "models/gta5/vehicles/hot_rod_super/chassis.mdl"
ENT.MaxChassisHealth = 700
ENT.CanSwitchTurnSignals = true

function ENT:GetFirstPersonOffset( _, localEyePos )
    return localEyePos
end

function ENT:GetPlayerSitSequence( _seatIndex )
    return "drive_airboat"
end

if CLIENT then
    ENT.CameraOffset = Vector( -170, 0, 50 )

    ENT.ExhaustOffsets = {
        { pos = Vector( -43, 0, 6 ), angle = Angle( 20, 0, 0 ), scale = 0.7 }
    }

    ENT.EngineSmokeStrips = {
        { offset = Vector( 5, 0, -5 ), angle = Angle( 40, 180, 0 ), width = 15 }
    }

    ENT.EngineSmokeMaxZVel = 20

    ENT.EngineFireOffsets = {
        { offset = Vector( -3, 5, -5 ), angle = Angle( 90, 90, 0 ), scale = 0.4 },
        { offset = Vector( -3, -5, -5 ), angle = Angle( 90, 270, 0 ), scale = 0.4 }
    }

    ENT.LightSprites = {
        { type = "headlight", offset = Vector( 38, 10, 5 ), dir = Vector( 1, 0, 0 ) },
        { type = "headlight", offset = Vector( 38, -10, 5 ), dir = Vector( 1, 0, 0 ) },
        { type = "taillight", offset = Vector( -41, 7.5, -1.5 ), dir = Vector( -1, 0, 0 ), size = 15, signal = "left" },
        { type = "taillight", offset = Vector( -41, -7.5, -1.5 ), dir = Vector( -1, 0, 0 ), size = 15, signal = "right" },
        { type = "brake", offset = Vector( -41, 3.9, -1.5 ), dir = Vector( -1, 0, 0 ), lightRadius = 20, size = 18 },
        { type = "brake", offset = Vector( -41, -3.9, -1.5 ), dir = Vector( -1, 0, 0 ), lightRadius = 20, size = 18 }
    }

    ENT.Headlights = {
        { offset = Vector( 30, 0, 13 ) }
    }

    ENT.StartSound = "glide_experiments/rotary/ignition.wav"
    ENT.StartedSound = "glide_experiments/rotary/startup.wav"
    ENT.StoppedSound = "glide_experiments/rotary/shutdown.wav"

    ENT.HornSound = "glide/horns/car_horn_light_1.wav"
    ENT.ExhaustPopSound = "GlideExperiments.Rotary.ExhaustPop"

    ENT.TurboLoopSound = ""
    ENT.TurboBlowoffSound = "GlideExperiments.Rotary.DumpValve"
    ENT.TurboBlowoffVolume = 1.0
    ENT.TurboPitch = 100

    ENT.ExternalGearSwitchSound = ""
    ENT.InternalGearSwitchSound = ""

    function ENT:AllowWindSound()
        return true, 1
    end

    function ENT:AllowFirstPersonMuffledSound()
        return false
    end

    function ENT:OnCreateEngineStream( stream )
        stream.offset = Vector( -15, 0, 0 )
        stream:LoadPreset( "experiment-rotary" )
    end

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

    function ENT:GetSeatBoneManipulations()
        return POSE_DATA
    end

    DEFINE_BASECLASS( "base_glide_car" )

    function ENT:OnActivateMisc()
        BaseClass.OnActivateMisc( self )

        self.handlebarsBoneId = self:LookupBone( "handlebars" )
        self.cogBoneId = self:LookupBone( "cog" )
        self.transmissionBoneId = self:LookupBone( "transmission_r" )
        self.rearSpringBoneId = self:LookupBone( "spring_rear" )
        self.flSuspensionBoneId = self:LookupBone( "suspension_fl" )
        self.frSuspensionBoneId = self:LookupBone( "suspension_fr" )
        self.flSpringBoneId = self:LookupBone( "spring_fl" )
        self.frSpringBoneId = self:LookupBone( "spring_fr" )
    end

    local Abs = math.abs
    local Clamp = math.Clamp
    local ang = Angle()

    function ENT:OnUpdateAnimations()
        if not self.handlebarsBoneId then return end

        ang[1] = 0
        ang[2] = 0
        ang[3] = self:GetSteering() * -28
        self:ManipulateBoneAngles( self.handlebarsBoneId, ang )

        -- Spin the rear cog
        ang[2] = 0
        ang[3] = -self:GetWheelSpin( 3 )
        self:ManipulateBoneAngles( self.cogBoneId, ang )

        local offset = Clamp( Abs( self:GetWheelOffset( 3 ) + self:GetWheelOffset( 4 ) ) / 30, 0, 1 )
        local invOffset = 1 - offset

        -- Rotate the rear transmission bar
        ang[1] = 0
        ang[2] = -30 + invOffset * 40
        ang[3] = 0
        self:ManipulateBoneAngles( self.transmissionBoneId, ang )

        -- Rotate and scale the rear spring
        ang[2] = 0
        ang[3] = 10 - offset * 25
        self:ManipulateBoneAngles( self.rearSpringBoneId, ang )
        self:ManipulateBoneScale( self.rearSpringBoneId, Vector( 1, 1, 0.9 + offset * 0.7 ) )

        -- Rotate the front suspension and springs
        offset = Clamp( Abs( self:GetWheelOffset( 1 ) ) / 15, 0, 1 )
        ang[1] = 25 - offset * 75
        ang[3] = 0
        self:ManipulateBoneAngles( self.flSuspensionBoneId, ang )

        ang[1] = 20 - offset * 40
        ang[2] = 0
        ang[3] = 0
        self:ManipulateBoneAngles( self.flSpringBoneId, ang )
        self:ManipulateBoneScale( self.flSpringBoneId, Vector( 1, 1, 0.65 + offset * 0.7 ) )

        offset = Clamp( Abs( self:GetWheelOffset( 2 ) ) / 15, 0, 1 )
        ang[1] = -25 + offset * 75
        ang[3] = 0
        self:ManipulateBoneAngles( self.frSuspensionBoneId, ang )

        ang[1] = -20 + offset * 40
        ang[2] = 0
        ang[3] = 0
        self:ManipulateBoneAngles( self.frSpringBoneId, ang )
        self:ManipulateBoneScale( self.frSpringBoneId, Vector( 1, 1, 0.65 + offset * 0.7 ) )
    end
end

if SERVER then
    ENT.ChassisMass = 750
    ENT.AngularDrag = Vector( -0.8, -0.5, -5 ) -- Roll, pitch, yaw
    ENT.AirControlForce = Vector( 1.2, 0.8, 0.2 ) -- Roll, pitch, yaw
    ENT.AirMaxAngularVelocity = Vector( 400, 400, 150 ) -- Roll, pitch, yaw

    ENT.FallOnCollision = true
    ENT.FallWhileUnderWater = true
    ENT.SpawnPositionOffset = Vector( 0, 0, 40 )

    ENT.SuspensionHeavySound = "GlideExperiments.Suspension.CompressHotRod"
    ENT.StartupTime = 0.6

    ENT.UnflipForce = 20
    ENT.BurnoutForce = 30

    function ENT:GetGears()
        return {
            [-1] = 3.0,
            [0] = 0,
            [1] = 2.9,
            [2] = 1.5,
            [3] = 1.1,
            [4] = 0.85,
            [5] = 0.75
        }
    end

    ENT.LightBodygroups = {
        { type = "headlight", bodyGroupId = 3, subModelId = 1 }, -- Headlight
        { type = "headlight", bodyGroupId = 5, subModelId = 1, signal = "left" }, -- Left signal/taillight
        { type = "headlight", bodyGroupId = 6, subModelId = 1, signal = "right" }, -- Right signal/taillight
        { type = "brake", bodyGroupId = 4, subModelId = 1 }
    }

    function ENT:CreateFeatures()
        self.flywheelTorque = 30000
        self.engineBrakeTorque = 3000
        self.switchBaseDelay = 0.45

        self:SetSteerConeMaxAngle( 0.35 )
        self:SetSteerConeMaxSpeed( 800 )
        self:SetSteerConeChangeRate( 7 )
        self:SetCounterSteer( 0.2 )

        self:SetPowerDistribution( -0.7 )
        self:SetDifferentialRatio( 0.66 )
        self:SetBrakePower( 2000 )

        self:SetTurboCharged( true )
        self:SetMinRPM( 650 )
        self:SetMaxRPM( 6500 )
        self:SetMinRPMTorque( 3800 )
        self:SetMaxRPMTorque( 4000 )

        self:SetSuspensionLength( 12 )
        self:SetSpringStrength( 280 )
        self:SetSpringDamper( 1500 )

        self:SetForwardTractionMax( 3200 )
        self:SetSideTractionMultiplier( 20 )
        self:SetSideTractionMaxAng( 25 )
        self:SetSideTractionMax( 3500 )
        self:SetSideTractionMin( 500 )

        self:CreateSeat( Vector( -22, 0, 4 ), Angle( 0, 270, -16 ), Vector( 0, 60, 0 ), true )

        self:CreateWheel( Vector( 25, 18, -4 ), {
            model = "models/gta5/vehicles/blazer/wheel.mdl",
            modelScale = Vector( 0.5, 1, 1 ),
            modelAngle = Angle( 0, 90, 0 ),
            steerMultiplier = 1,
            enableAxleForces = true
        } )

        self:CreateWheel( Vector( 25, -18, -4 ), {
            model = "models/gta5/vehicles/blazer/wheel.mdl",
            modelAngle = Angle( 0, -90, 0 ),
            modelScale = Vector( 0.5, 1, 1 ),
            steerMultiplier = 1,
            enableAxleForces = true
        } )

        self:CreateWheel( Vector( -27, 18, -4 ), {
            model = "models/gta5/vehicles/blazer/wheel.mdl",
            modelScale = Vector( 0.5, 1, 1 ),
            modelAngle = Angle( 0, 90, 0 ),
            enableAxleForces = true
        } )

        self:CreateWheel( Vector( -27, -18, -4 ), {
            model = "models/gta5/vehicles/blazer/wheel.mdl",
            modelAngle = Angle( 0, -90, 0 ),
            modelScale = Vector( 0.5, 1, 1 ),
            enableAxleForces = true
        } )

        self:ChangeWheelRadius( 16 )
    end
end
