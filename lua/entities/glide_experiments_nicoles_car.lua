AddCSLuaFile()

ENT.Type = "anim"
ENT.Base = "base_glide_car"
ENT.PrintName = "Nicole's Honda Civic"
ENT.Author = "Model ported by aegis1994"
ENT.GlideCategory = "StyledsExperiments"

ENT.ChassisModel = "models/zzz/vehicles/nicoles_car/chassis.mdl"
ENT.MaxChassisHealth = 1200
ENT.CanSwitchTurnSignals = true

function ENT:GetFirstPersonOffset( _, localEyePos )
    localEyePos[1] = localEyePos[1] + 10
    localEyePos[3] = localEyePos[3] + 8
    return localEyePos
end

if CLIENT then
    ENT.CameraOffset = Vector( -240, 0, 55 )

    ENT.ExhaustOffsets = {
        { pos = Vector( -69.2, 23.9, -9 ) },
        { pos = Vector( -69.2, 20.3, -9 ) },
        { pos = Vector( -69.2, -23.9, -9 ) },
        { pos = Vector( -69.2, -20.3, -9 ) },
    }

    ENT.EngineSmokeStrips = {
        { offset = Vector( 79, 0, 8 ), angle = Angle( 40, 0, 0 ), width = 30 }
    }

    ENT.EngineFireOffsets = {
        { offset = Vector( 58, 0, 22 ), angle = Angle( 0, 0, 0 ) }
    }

    ENT.Headlights = {
        { offset = Vector( 78, 27, 13 ), texture = "glide/effects/headlight_circle2" },
        { offset = Vector( 78, -27, 13 ), texture = "glide/effects/headlight_circle2" }
    }

    ENT.LightSprites = {
        { type = "headlight", offset = Vector( 78, 27, 7.5 ), dir = Vector( 1, 0, 0 ) },
        { type = "headlight", offset = Vector( 78, -27, 7.5 ), dir = Vector( 1, 0, 0 ) },
        { type = "taillight", offset = Vector( -69, 31, 13 ), dir = Vector( -1, 0, 0 ) },
        { type = "taillight", offset = Vector( -69, -31, 13 ), dir = Vector( -1, 0, 0 ) },
        { type = "brake", offset = Vector( -70, 31, 13 ), dir = Vector( -1, 0, 0 ), size = 25 },
        { type = "brake", offset = Vector( -70, -31, 13 ), dir = Vector( -1, 0, 0 ), size = 25 },
        { type = "reverse", offset = Vector( -70, 31, 10 ), dir = Vector( -1, 0, 0 ) },
        { type = "reverse", offset = Vector( -70, -31, 10 ), dir = Vector( -1, 0, 0 ) },
        { type = "signal_left", offset = Vector( -66, 36, 13 ), dir = Vector( -0.6, 0.4, 0 ), color = Glide.DEFAULT_TURN_SIGNAL_COLOR },
        { type = "signal_right", offset = Vector( -66, -36, 13 ), dir = Vector( -0.6, -0.4, 0 ), color = Glide.DEFAULT_TURN_SIGNAL_COLOR },
    }

    ENT.ExhaustPopSound = "GlideExperiments.Rotary.ExhaustPop"

    ENT.TurboBlowoffSound = "GlideExperiments.Rotary.DumpValve"
    ENT.TurboBlowoffVolume = 1.0
    ENT.TurboPitch = 100

    function ENT:OnCreateEngineStream( stream )
        stream.offset = Vector( 10, 0, 0 )
        stream:LoadPreset( "experiment-monstrociti" )
    end
end

-- Return early if this code is not running on the server.
if not SERVER then return end

ENT.ChassisMass = 750
ENT.SpawnPositionOffset = Vector( 0, 0, 40 )

ENT.StartupTime = 0.9
ENT.UnflipForce = 20
ENT.BurnoutForce = 30

ENT.LightBodygroups = {
    { type = "headlight", bodyGroupId = 2, subModelId = 1 }, -- Headlights
    { type = "headlight", bodyGroupId = 3, subModelId = 1 }, -- Taillights
    { type = "reverse", bodyGroupId = 4, subModelId = 1 },
    { type = "signal_left", bodyGroupId = 5, subModelId = 1 },
    { type = "signal_right", bodyGroupId = 6, subModelId = 1 }
}

function ENT:GetSpawnColor()
    return math.random() > 0.5 and Color( 255, 192, 217 ) or Color( 255, 255, 255 )
end

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
    self.switchBaseDelay = 0.3
    self:SetHeadlightColor( Vector( 1, 0.8, 0.45 ) )

    self:SetCounterSteer( 0.4 )
    self:SetMaxSteerAngle( 35 )
    self:SetSpringStrength( 450 )
    self:SetSuspensionLength( 8 )
    self:SetBrakePower( 2000 )

    self:SetForwardTractionMax( 3000 )
    self:SetSideTractionMultiplier( 15 )
    self:SetSideTractionMin( 150 )
    self:SetSideTractionMaxAng( 10 )

    self:SetDifferentialRatio( 0.57 )
    self:SetPowerDistribution( -0.7 )

    self:SetMaxRPM( 600 )
    self:SetMaxRPM( 7500 )
    self:SetMinRPMTorque( 3500 )
    self:SetMaxRPMTorque( 4000 )

    self:CreateSeat( Vector( -10, 18, -10 ), Angle( 0, 270, 5 ), Vector( 10, 80, 0 ), true )
    self:CreateSeat( Vector( -32, 18, -7 ), Angle( 0, 270, 15 ), Vector( -40, -80, 0 ), true )
    self:CreateSeat( Vector( -32, -18, -7 ), Angle( 0, 270, 15 ), Vector( -40, -80, 0 ), true )

    local params = {
        model = "models/zzz/vehicles/nicoles_car/wheel.mdl",
        modelScale = Vector( 0.45, 1, 1 ),
        modelAngle = Angle( 0, 90, 0 ),
        steerMultiplier = 1,
    }

    self:CreateWheel( Vector( 56, 33.3, -6 ), params )

    params.modelAngle = Angle( 0, 270, 0 )
    self:CreateWheel( Vector( 56, -33.3, -6 ), params )

    params.steerMultiplier = nil

    params.modelAngle = Angle( 0, 90, 0 )
    self:CreateWheel( Vector( -47.8, 33.3, -6 ), params )

    params.modelAngle = Angle( 0, 270, 0 )
    self:CreateWheel( Vector( -47.8, -33.3, -6 ), params )

    self:ChangeWheelRadius( 13 )
end
