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

-- This is needed to play sequences from the model
ENT.AutomaticFrameAdvance = true

DEFINE_BASECLASS( "base_glide_car" )

function ENT:SetupDataTables()
    BaseClass.SetupDataTables( self )

    self:NetworkVar( "Float", "HoverValue" )
    self:NetworkVar( "Float", "FlightValue" )
end

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

    local FrameTime = FrameTime
    local Clamp = math.Clamp
    local ExpDecay = Glide.ExpDecay
    local GetVolume = Glide.Config.GetVolume

    function ENT:OnUpdateSounds()
        BaseClass.OnUpdateSounds( self )

        local sounds = self.sounds
        local hover = self:GetHoverValue()

        -- Do custom sounds while in hover mode
        if hover < 0.05 then
            if sounds.hoverBass then
                sounds.hoverBass:Stop()
                sounds.hoverBass = nil
            end

            if sounds.hoverTreble then
                sounds.hoverTreble:Stop()
                sounds.hoverTreble = nil
            end

            return
        end

        local volume = GetVolume( "carVolume" ) * hover
        local throttle = self:GetEngineThrottle()

        if sounds.hoverBass then
            sounds.hoverBass:ChangePitch( 30 + throttle * 20 )
            sounds.hoverBass:ChangeVolume( volume * ( 0.3 + throttle * 0.4 ) )
        else
            local snd = self:CreateLoopingSound( "hoverBass", "glide/aircraft/thrust_b11.wav", 80, self )
            snd:PlayEx( 0.0, 100 )
        end

        local targetPitch = ( throttle * 10 ) +
            Clamp( self:GetVelocity():Length() / 45, 0, 40 )

        local hoverPitch = ExpDecay( self.hoverPitch or 0, targetPitch, 5, FrameTime() )
        self.hoverPitch = hoverPitch

        if sounds.hoverTreble then
            sounds.hoverTreble:ChangePitch( 70 + hoverPitch )
            sounds.hoverTreble:ChangeVolume( volume * ( 0.6 + throttle * 0.2 ) )
        else
            local snd = self:CreateLoopingSound( "hoverTreble", "glide_experiments/deluxo/hover_high.wav", 80, self )
            snd:PlayEx( 0.0, 100 )
        end

        if sounds.hoverEnergy then
            sounds.hoverEnergy:ChangeVolume( volume * ( 0.5 + self:GetFlightValue() * 0.5 ) )
        else
            local snd = self:CreateLoopingSound( "hoverEnergy", ")glide_experiments/deluxo/hover_energy.wav", 75, self )
            snd:PlayEx( 0.0, 80 )
        end
    end

    local Lerp = Lerp
    local pos = Vector()
    local ang = Angle()

    function ENT:OnUpdateAnimations()
        self:SetPoseParameter( "vehicle_steer", self:GetSteering() )
        self:SetPoseParameter( "extend_wings", self:GetFlightValue() )
        self:InvalidateBoneCache()

        if not self.steerLF then return end

        local hover = self:GetHoverValue()
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

        pos[1] = Lerp( hover, 3 + self:GetWheelOffset( 3 ), -1 )
        self:ManipulateBonePosition( self.suspLR, pos )

        pos[1] = Lerp( hover, 3 + self:GetWheelOffset( 4 ), -1 )
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

-- Return early if this code is not running on the server.
if not SERVER then return end

ENT.SpawnPositionOffset = Vector( 0, 0, 40 )

ENT.LightBodygroups = {
    { type = "headlight", bodyGroupId = 18, subModelId = 1 }, -- Headlights
    { type = "headlight", bodyGroupId = 19, subModelId = 1 }, -- Tail lights
    { type = "brake", bodyGroupId = 20, subModelId = 1 },
    { type = "reverse", bodyGroupId = 21, subModelId = 1 },
    { type = "signal_left", bodyGroupId = 22, subModelId = 1 },
    { type = "signal_right", bodyGroupId = 23, subModelId = 1 }
}

ENT.HoverTransitionTime = 0.9

ENT.HoverParams = {
    linearDrag = Vector( 0.2, 1.5, 2.0 ), -- (Forward, right, up)
    angularDrag = Vector( -5, -15, -5 ), -- (Roll, pitch, yaw)

    hoverForce = 10,         -- How strong is the hover force on each hover point?
    hoverDistance = 100,     -- How far from surfaces each hover point has to be for the `hoverForce` to fully apply?
    hoverZDrag = 0.03,       -- Extra upwards drag to apply on each hover point

    maxSpeed = 1700,        -- Stop applying `engineForce` once the vehicle hits this speed
    engineForce = 450,
    turnForce = 900,
    pitchForce = 700,
    uprightForce = 600
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

    self:SetMaxRPM( 600 )
    self:SetMaxRPM( 7500 )
    self:SetDifferentialRatio( 0.6 )
    self:SetMinRPMTorque( 4300 )
    self:SetMaxRPMTorque( 4600 )

    self:SetPowerDistribution( -0.6 )
    self:SetForwardTractionMax( 2000 )
    self:SetBrakePower( 2500 )

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

    -- Make holding the headlights input toggle hover mode
    self:RegisterHoldAction( "headlights", 1.0, { name = "ToggleHoverMode" } )

    -- Setup hover mode variables and states
    self.hoverState = 0
    self.contactHoverPointCount = 0

    self:SetFlightValue( 0 )
    self:SetHoverState( 0 )

    -- Calculate local positions on the vehicle where hover forces are applied
    local phys = self:GetPhysicsObject()
    if not IsValid( phys ) then return end

    local center = phys:GetMassCenter()
    local mins, maxs = phys:GetAABB()
    local size = ( maxs - mins ) * 0.5

    local spacingX = 0.8
    local spacingY = 0.7
    local offsetZ = 0

    center[3] = -size[3] * 0.5

    self.hoverPoints = {
        center + Vector( size[1] * spacingX, size[2] * spacingY, offsetZ ), -- Front left
        center + Vector( size[1] * spacingX, size[2] * -spacingY, offsetZ ), -- Front right
        center + Vector( size[1] * -spacingX, size[2] * spacingY, offsetZ ), -- Rear left
        center + Vector( size[1] * -spacingX, size[2] * -spacingY, offsetZ ) -- Rear right
    }
end

function ENT:OnHoldInputAction( _action, data )
    if data.name ~= "ToggleHoverMode" then return end
    if self:GetEngineHealth() <= 0 then return end

    if self.hoverState == 0 or self.hoverState == 3 then
        self:SetHoverState( 1 )
    else
        self:SetHoverState( 3 )
    end
end

local stateSounds = {
    [1] = { "glide_experiments/deluxo/transform_to_flight.wav", 80, 100, 0.9 },
    [3] = { "glide_experiments/deluxo/transform_to_car.wav", 80, 100, 0.9 }
}

function ENT:SetHoverState( state )
    -- Do transition sounds
    if state ~= self.hoverState then
        local soundParams = stateSounds[state]

        if soundParams then
            self:EmitSound( unpack( soundParams ) )
        end
    end

    if state == 1 then
        -- Transition to hover mode
        self.hoverState = 1
        self:TurnOff()
        self:ResetSequence( "cover_retract" )
        self:ResetSequenceInfo()

    elseif state == 2 then
        -- Set to hover mode now
        self.hoverState = 2
        self:SetHoverValue( 1 )
        self:ChangeSuspensionLengthMultiplier( 0 )
        self:ResetSequence( "cover_retracted" )
        self:SetBodygroup( 7, 1 )

    elseif state == 3 then
        -- Transition to ground mode
        self.hoverState = 3
        self:TurnOn()
        self:ResetSequence( "cover_extend" )
        self:ResetSequenceInfo()
        self:SetBodygroup( 7, 0 )

    else
        -- Set to ground mode now
        self.hoverState = 0
        self:SetHoverValue( 0 )
        self:ChangeSuspensionLengthMultiplier( 1 )
        self:ResetSequence( "cover_extended" )
        self:SetBodygroup( 7, 0 )
    end
end

function ENT:ChangeSuspensionLengthMultiplier( multiplier )
    self.wheelsEnabled = multiplier > 0.05

    for _, w in Glide.EntityPairs( self.wheels ) do
        w.state.suspensionLengthMult = multiplier

        if not self.wheelsEnabled then
            w.state.angularVelocity = 0
            w:SetForwardSlip( 0 )
            w:SetSideSlip( 0 )
        end
    end

    local phys = self:GetPhysicsObject()

    if IsValid( phys ) then
        phys:Wake()
    end
end

function ENT:TurnOn()
    -- Don't allow turning on while in hover mode
    local state = self.hoverState
    if state > 0 and state ~= 3 then return end

    BaseClass.TurnOn( self )
end

local Clamp = math.Clamp
local ExpDecay = Glide.ExpDecay

function ENT:OnPostThink( dt, selfTbl )
    BaseClass.OnPostThink( self, dt, selfTbl )

    local state = self.hoverState

    if state == 1 then -- Is it changing to hover mode?
        local value = self:GetHoverValue() + dt / selfTbl.HoverTransitionTime

        if value > 1 then
            self:SetHoverState( 2 )
        else
            self:SetHoverValue( value )
            self:ChangeSuspensionLengthMultiplier( 1 - value )
        end

    elseif state == 3 then -- Is it changing to ground mode?
        local value = self:GetHoverValue() - dt / selfTbl.HoverTransitionTime

        if value < 0 then
            self:SetHoverState( 0 )
        else
            self:SetHoverValue( value )
            self:ChangeSuspensionLengthMultiplier( 1 - value )
        end
    end

    local flight = self:GetFlightValue()

    if state == 2 then
        local pitchInput = self:GetInputFloat( 1, "lean_pitch" )

        -- If the user is trying to fly up,
        -- or none of the hover points are "touching" a surface...
        if pitchInput < -0.1 or selfTbl.contactHoverPointCount < 1 then
            -- Increase the flight strength
            self:SetFlightValue( Clamp( flight + dt, 0, 1 ) )

        elseif selfTbl.contactHoverPointCount > 1 then
            -- If no pitch up input, and we have at least one hover
            -- point trace hitting a surface, then reduce the flight strength
            self:SetFlightValue( Clamp( flight - dt * 2, 0, 1 ) )
        end

        self:SetEngineThrottle( ExpDecay( self:GetEngineThrottle(), self:GetInputFloat( 1, "accelerate" ), 8, dt ) )

        if self:GetEngineHealth() <= 0 then
            self:SetHoverState( 3 )
        end
    else
        self:SetFlightValue( Clamp( flight - dt, 0, 1 ) )
    end
end

function ENT:OnSimulatePhysics( phys, dt, outLin, outAng )
    if self:IsPlayerHolding() then return end

    local strength = self:GetHoverValue()

    if strength > 0.05 then
        self.contactHoverPointCount = self:SimulateHovercraft( strength, self:GetFlightValue(), self.hoverPoints, phys, dt, outLin, outAng )
    end
end
