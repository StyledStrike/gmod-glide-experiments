AddCSLuaFile()

ENT.Type = "anim"
ENT.Base = "base_glide_car"
ENT.PrintName = "Deluxo"
ENT.GlideCategory = "StyledsExperiments"

ENT.ChassisModel = "models/gta5/vehicles/deluxo/chassis.mdl"

ENT.UneditableNWVars = {
    WheelRadius = true,
    SuspensionLength = true
}

function ENT:GetFirstPersonOffset( _, localEyePos )
    localEyePos[1] = localEyePos[1] + 15
    localEyePos[2] = localEyePos[2] - 2
    localEyePos[3] = localEyePos[3] + 7
    return localEyePos
end

if CLIENT then
    ENT.CameraOffset = Vector( -240, 0, 50 )

    ENT.ExhaustOffsets = {
        { pos = Vector( -92.5, 31, -8 ), angle = Angle( 0, 0, 0 ) },
        { pos = Vector( -92.5, -31, -8 ), angle = Angle( 0, 0, 0 ) }
    }

    ENT.EngineSmokeStrips = {
        { offset = Vector( 89, 0, 8 ), angle = Angle( 40, 0, 0 ), width = 30 }
    }

    ENT.EngineFireOffsets = {
        { offset = Vector( 60, 0, 10 ), angle = Angle( 0, 0, 0 ) }
    }

    ENT.Headlights = {
        { offset = Vector( 88, 25.5, 8 ) },
        { offset = Vector( 88, -25.5, 8 ) }
    }

    ENT.LightSprites = {
        { type = "headlight", offset = Vector( 87, 25.5, 7.5 ), dir = Vector( 1, 0, 0 ) },
        { type = "headlight", offset = Vector( 87, -25.5, 7.5 ), dir = Vector( 1, 0, 0 ) },
        { type = "taillight", offset = Vector( -92, 25, 16 ), dir = Vector( -1, 0, 0 ), size = 20 },
        { type = "taillight", offset = Vector( -92, -25, 16 ), dir = Vector( -1, 0, 0 ), size = 20 },
        { type = "brake", offset = Vector( -92, 20.5, 10.8 ), dir = Vector( -1, 0, 0 ), size = 30 },
        { type = "brake", offset = Vector( -92, -20.5, 10.8 ), dir = Vector( -1, 0, 0 ), size = 30 },
        { type = "reverse", offset = Vector( -92, 26.3, 10.8 ), dir = Vector( -1, 0, 0 ) },
        { type = "reverse", offset = Vector( -92, -26.3, 10.8 ), dir = Vector( -1, 0, 0 ) },
        { type = "signal_left", offset = Vector( -92, 31.3, 10.8 ), dir = Vector( -1, 0, 0 ), color = Glide.DEFAULT_TURN_SIGNAL_COLOR },
        { type = "signal_right", offset = Vector( -92, -31.3, 10.8 ), dir = Vector( -1, 0, 0 ), color = Glide.DEFAULT_TURN_SIGNAL_COLOR },
        { type = "signal_left", offset = Vector( 93, 29, 1 ), dir = Vector( 1, 0, 0 ), color = Glide.DEFAULT_TURN_SIGNAL_COLOR },
        { type = "signal_right", offset = Vector( 93, -29, 1 ), dir = Vector( 1, 0, 0 ), color = Glide.DEFAULT_TURN_SIGNAL_COLOR },
    }

    ENT.StartedSound = "glide_experiments/deluxo/started.wav"
    ENT.StoppedSound = "glide_experiments/deluxo/stopped.wav"
    ENT.HornSound = "glide/horns/car_horn_med_9.wav"
    ENT.ExhaustPopSound = "GlideExperiments.BlazerAqua.ExhaustPop"

    function ENT:OnCreateEngineStream( stream )
        stream.offset = Vector( 15, 0, 0 )
        stream:LoadPreset( "experiment-deluxo" )
    end

    DEFINE_BASECLASS( "base_glide_car" )

    function ENT:OnActivateMisc()
        BaseClass.OnActivateMisc( self )

        self.steerLF = self:LookupBone( "wheel_steer_pivot_lf" )
        self.steerRF = self:LookupBone( "wheel_steer_pivot_rf" )

        self.wheelLF = self:LookupBone( "wheel_lf" )
        self.wheelRF = self:LookupBone( "wheel_rf" )
        self.wheelLR = self:LookupBone( "wheel_lr" )
        self.wheelRR = self:LookupBone( "wheel_rr" )

        self.suspLF = self:LookupBone( "suspension_lf" )
        self.suspRF = self:LookupBone( "suspension_rf" )
        self.suspLR = self:LookupBone( "suspension_lr" )
        self.suspRR = self:LookupBone( "suspension_rr" )
    end

    local Lerp = Lerp
    local pos = Vector()
    local ang = Angle()

    function ENT:OnUpdateAnimations()
        BaseClass.OnUpdateAnimations( self )

        if not self.steerLF then return end

        local hover = 0.0 -- TODO
        local invHover = 1 - hover

        -- Steer the front wheels
        ang[1] = self:GetSteering() * -self:GetMaxSteerAngle() * invHover
        ang[2] = 0
        ang[3] = 0
        self:ManipulateBoneAngles( self.steerLF, ang )
        self:ManipulateBoneAngles( self.steerRF, ang )

        -- Spin the wheels
        ang[1] = 0
        ang[2] = -self:GetWheelSpin( 1 ) * invHover
        self:ManipulateBoneAngles( self.wheelLF, ang )

        ang[2] = -self:GetWheelSpin( 2 ) * invHover
        self:ManipulateBoneAngles( self.wheelRF, ang )

        ang[2] = -self:GetWheelSpin( 3 ) * invHover
        self:ManipulateBoneAngles( self.wheelLR, ang )

        ang[2] = -self:GetWheelSpin( 4 ) * invHover
        self:ManipulateBoneAngles( self.wheelRR, ang )

        -- Move the suspension, retract if we're on hover mode
        pos[1] = Lerp( hover, 5 + self:GetWheelOffset( 1 ), -1 )
        self:ManipulateBonePosition( self.suspLF, pos )

        pos[1] = Lerp( hover, 5 + self:GetWheelOffset( 2 ), -1 )
        self:ManipulateBonePosition( self.suspRF, pos )

        pos[1] = Lerp( hover, 5 + self:GetWheelOffset( 3 ), -1 )
        self:ManipulateBonePosition( self.suspLR, pos )

        pos[1] = Lerp( hover, 5 + self:GetWheelOffset( 4 ), -1 )
        self:ManipulateBonePosition( self.suspRR, pos )

        ang[1] = Lerp( hover, 0, 30 )
        ang[2] = 0
        ang[3] = 0
        self:ManipulateBoneAngles( self.suspLF, ang )
        self:ManipulateBoneAngles( self.suspLR, ang )

        ang[1] = -ang[1]
        self:ManipulateBoneAngles( self.suspRF, ang )
        self:ManipulateBoneAngles( self.suspRR, ang )
    end
end

if SERVER then
    ENT.SpawnPositionOffset = Vector( 0, 0, 40 )

    ENT.LightBodygroups = {
        { type = "headlight", bodyGroupId = 18, subModelId = 1 }, -- Headlights
        { type = "headlight", bodyGroupId = 19, subModelId = 1 }, -- Tail lights
        { type = "brake", bodyGroupId = 20, subModelId = 1 },
        { type = "reverse", bodyGroupId = 21, subModelId = 1 },
        { type = "signal_left", bodyGroupId = 22, subModelId = 1 },
        { type = "signal_right", bodyGroupId = 23, subModelId = 1 }
    }

    function ENT:GetGears()
        return {
            [-1] = 2.5, -- Reverse
            [0] = 0, -- Neutral
            [1] = 2.8,
            [2] = 1.7,
            [3] = 1.2,
            [4] = 0.9,
            [5] = 0.75
        }
    end

    function ENT:CreateFeatures()
        self:SetCounterSteer( 0.3 )
        self:SetSpringStrength( 450 )

        self:SetSideTractionMultiplier( 15 )
        self:SetSideTractionMin( 250 )
        self:SetSideTractionMaxAng( 20 )

        self:SetMaxRPM( 8000 )
        self:SetDifferentialRatio( 0.6 )
        self:SetMinRPMTorque( 4200 )
        self:SetMaxRPMTorque( 4600 )

        self:SetPowerDistribution( -0.6 )
        self:SetForwardTractionMax( 2000 )

        self:CreateSeat( Vector( -25, 20, -14 ), Angle( 0, 270, 5 ), Vector( 10, 80, 0 ), false )
        self:CreateSeat( Vector( -18, -20, -11 ), Angle( 0, 270, 5 ), Vector( 10, -80, 0 ), false )

        local params = {
            model = "models/gta5/vehicles/jb700/wheel.mdl",
            steerMultiplier = 1,
            radius = 14
        }

        self:CreateWheel( Vector( 53.4, 35, -1 ), params )
        self:CreateWheel( Vector( 53.4, -35, -1 ), params )

        params.radius = 16
        params.steerMultiplier = nil

        self:CreateWheel( Vector( -56.2, 35, -1 ), params )
        self:CreateWheel( Vector( -56.2, -35, -1 ), params )

        for _, w in ipairs( self.wheels ) do
            Glide.HideEntity( w, true )
        end
    end
end
