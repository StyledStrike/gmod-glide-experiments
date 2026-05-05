AddCSLuaFile()

ENT.Type = "anim"
ENT.Base = "base_glide_car"
ENT.PrintName = "Tubile"

ENT.GlideCategory = "StyledsExperiments"
ENT.ChassisModel = "models/glide_experiments/tubile/chassis.mdl"
ENT.MaxChassisHealth = 700
ENT.CanSwitchTurnSignals = true
ENT.IsAmphibious = true

DEFINE_BASECLASS( "base_glide_car" )

-- Override the default first person offset
function ENT:GetFirstPersonOffset( _, localEyePos )
    return localEyePos
end

if CLIENT then
    ENT.CameraOffset = Vector( -170, 0, 43 )

    ENT.PropellerPositions = {
        Vector( -48, 0, -20 )
    }

    ENT.ExhaustOffsets = {
        { pos = Vector( -43.2, 11, 18.5 ), angle = Angle( 0, 280, 0 ), scale = 0.7 }
    }

    ENT.EngineSmokeStrips = {
        { offset = Vector( -25, 0, 15 ), angle = Angle( 0, 180, 0 ), width = 25 }
    }

    ENT.EngineFireOffsets = {
        { offset = Vector( -25, 0, 15 ), angle = Angle( 0, 90, 0 ), scale = 0.4 },
    }

    ENT.LightSprites = {
        { type = "headlight", offset = Vector( 45, 0, 9 ), dir = Vector( 1, 0, 0 ) },
        { type = "taillight", offset = Vector( -45, 9.5, 11.2 ), dir = Vector( -1, 0, 0 ), size = 15 },
        { type = "taillight", offset = Vector( -45, -9.5, 11.2 ), dir = Vector( -1, 0, 0 ), size = 15 },
        { type = "brake", offset = Vector( -45, 9.5, 11.2 ), dir = Vector( -1, 0, 0 ), lightRadius = 50 },
        { type = "brake", offset = Vector( -45, -9.5, 11.2 ), dir = Vector( -1, 0, 0 ), lightRadius = 50 },
        { type = "signal_left", offset = Vector( -45, 9, 8 ), dir = Vector( -1, 0, 0 ), color = Glide.DEFAULT_TURN_SIGNAL_COLOR },
        { type = "signal_right", offset = Vector( -45, -9, 8 ), dir = Vector( -1, 0, 0 ), color = Glide.DEFAULT_TURN_SIGNAL_COLOR },
    }

    ENT.Headlights = {
        { offset = Vector( 45, 0, 11 ), texture = "glide/effects/headlight_circle2" }
    }

    ENT.EngineSmokeMaxZVel = 20
    ENT.ExternalGearSwitchSound = ""
    ENT.InternalGearSwitchSound = ""

    ENT.StartSound = "glide/engines/start_bike_2.wav"
    ENT.StartedSound = "glide/streams/gauntlet_classic/start.wav"
    --ENT.StoppedSound = "glide_experiments/blazer_aqua/shutdown.wav"

    ENT.HornSound = "glide/horns/car_horn_light_1.wav"
    ENT.ExhaustPopSound = "GlideExperiments.Sports2.ExhaustPop"

    ENT.TurboBlowoffSound = "GlideExperiments.DumpValve"
    ENT.TurboBlowoffVolume = 0.7
    ENT.TurboPitch = 100

    -- Enable the wind sound at full volume
    function ENT:AllowWindSound()
        return true, 1
    end

    -- Do not muffle first person sounds
    function ENT:AllowFirstPersonMuffledSound()
        return false
    end

    function ENT:OnCreateEngineStream( stream )
        stream.offset = Vector( -10, 0, 0 )
        stream:LoadPreset( "experiment-predator_v8" )
    end

    local POSE_DATA = {
        ["ValveBiped.Bip01_L_Thigh"] = Angle( 1, -8, 0 ),
        ["ValveBiped.Bip01_R_Thigh"] = Angle( -2, -8, 0 ),
        ["ValveBiped.Bip01_L_Calf"] = Angle( 5, 0, 0 ),
        ["ValveBiped.Bip01_R_Calf"] = Angle( -5, 0, 0 )
    }

    function ENT:GetSeatBoneManipulations()
        return POSE_DATA
    end

    function ENT:OnActivateMisc()
        BaseClass.OnActivateMisc( self )

        self.flSpringBoneId = self:LookupBone( "spring_fl" )
        self.frSpringBoneId = self:LookupBone( "spring_fr" )
        self.rlSpringBoneId = self:LookupBone( "spring_rl" )
        self.rrSpringBoneId = self:LookupBone( "spring_rr" )
    end

    local pos = Vector()

    function ENT:OnUpdateAnimations()
        BaseClass.OnUpdateAnimations( self )

        if not self.flSpringBoneId then return end

        pos[2] = self:GetWheelOffset( 1 ) + 9
        self:ManipulateBonePosition( self.flSpringBoneId, pos )

        pos[2] = self:GetWheelOffset( 2 ) + 9
        self:ManipulateBonePosition( self.rlSpringBoneId, pos )

        pos[2] = self:GetWheelOffset( 3 ) + 9
        self:ManipulateBonePosition( self.frSpringBoneId, pos )

        pos[2] = self:GetWheelOffset( 4 ) + 9
        self:ManipulateBonePosition( self.rrSpringBoneId, pos )
    end
end

if SERVER then
    ENT.ChassisMass = 400

    ENT.FallOnCollision = true
    ENT.FallWhileUnderWater = true
    ENT.SpawnPositionOffset = Vector( 0, 0, 30 )

    ENT.SuspensionHeavySound = "GlideExperiments.Suspension.CompressHotRod"
    ENT.StartupTime = 0.8

    ENT.UnflipForce = 20
    ENT.BurnoutForce = 30

    ENT.AirControlForce = Vector( 3, 1, 0.2 ) -- Roll, pitch, yaw
    ENT.AirMaxAngularVelocity = Vector( 500, 400, 150 ) -- Roll, pitch, yaw

    ENT.BuoyancyPointsZOffset = -5
    ENT.BuoyancyPointsXSpacing = 0.8
    ENT.BuoyancyPointsYSpacing = 0.9

    ENT.BoatParams = {
        waterLinearDrag = Vector( 0.2, 1.5, 0.02 ), -- (Forward, right, up)
        waterAngularDrag = Vector( -5, -4, -15 ), -- (Roll, pitch, yaw)

        buoyancy = 4,
        buoyancyDepth = 25,

        turbulanceForce = 50,
        alignForce = 800,
        maxSpeed = 1300,

        engineForce = 500,
        engineLiftForce = 400,
        turnForce = 1200,
        rollForce = 150
    }

    function ENT:InitializePhysics()
        self:SetSolid( SOLID_VPHYSICS )
        self:SetMoveType( MOVETYPE_VPHYSICS )
        self:PhysicsInit( SOLID_VPHYSICS, Vector( -10, 0, -18 ) )
    end

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
        { type = "headlight", bodyGroupId = 7, subModelId = 1 }, -- Tail lights
        { type = "signal_left", bodyGroupId = 8, subModelId = 1 },
        { type = "signal_right", bodyGroupId = 9, subModelId = 1 }
    }

    function ENT:CreateFeatures()
        self.flywheelMass = 50

        self:SetSteerConeMaxAngle( 0.25 )
        self:SetSteerConeMaxSpeed( 800 )

        self:SetPowerDistribution( -0.7 )
        self:SetDifferentialRatio( 0.42 )
        self:SetBrakePower( 1200 )

        self:SetMinRPM( 650 )
        self:SetMaxRPM( 5500 )
        self:SetMinRPMTorque( 2500 )
        self:SetMaxRPMTorque( 3500 )

        self:SetSuspensionLength( 12 )
        self:SetSpringStrength( 150 )
        self:SetSpringDamper( 250 )

        self:SetSideTractionMultiplier( 10 )
        self:SetSideTractionMax( 1300 )
        self:SetSideTractionMin( 300 )

        self:CreateSeat( Vector( -14, 0, 2 ), Angle( 0, 270, -16 ), Vector( 0, 60, 0 ), true )

        local wheelParams = {
            model = "models/props_phx/smallwheel.mdl",
            modelScale = Vector( 1, 1, 0.35 ),
            modelAngle = Angle( 90, 90, 0 ),
            modelOffset = Vector( 0, 2, 0 ),
        }

        -- Front left
        wheelParams.steerMultiplier = 1
        wheelParams.modelOffset[2] = 0.5
        self:CreateWheel( Vector( 15, 18, -5 ), wheelParams )

        -- Rear left
        wheelParams.steerMultiplier = nil
        wheelParams.modelOffset[2] = 2
        self:CreateWheel( Vector( -34, 18, -5 ), wheelParams )

        -- Front right
        wheelParams.steerMultiplier = 1
        wheelParams.modelAngle[2] = -90
        wheelParams.modelOffset[2] = -0.5
        self:CreateWheel( Vector( 15, -18, -5 ), wheelParams )

        -- Rear right
        wheelParams.steerMultiplier = nil
        wheelParams.modelOffset[2] = -2
        self:CreateWheel( Vector( -34, -18, -5 ), wheelParams )

        self:ChangeWheelRadius( 10 )
    end
end
