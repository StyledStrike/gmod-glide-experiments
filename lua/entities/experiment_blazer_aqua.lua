AddCSLuaFile()

ENT.Type = "anim"
ENT.Base = "base_glide_car"
ENT.PrintName = "Blazer Aqua"
ENT.GlideCategory = "RandomExperiments"

ENT.ChassisModel = "models/gta5/vehicles/blazer_aqua/chassis.mdl"
ENT.MaxChassisHealth = 700
ENT.CanSwitchTurnSignals = true
ENT.IsAmphibious = true

ENT.UneditableNWVars = {
    WheelRadius = true,
    SuspensionLength = true
}

function ENT:GetFirstPersonOffset( _, localEyePos )
    return localEyePos
end

function ENT:GetPlayerSitSequence( _seatIndex )
    return "drive_airboat"
end

DEFINE_BASECLASS( "base_glide_car" )

function ENT:SetupDataTables()
    BaseClass.SetupDataTables( self )

    self:NetworkVar( "Float", "DeployWheels" )
end

if CLIENT then
    ENT.CameraOffset = Vector( -170, 0, 65 )

    ENT.PropellerPositions = {
        Vector( -45, 0, -15 )
    }

    ENT.Headlights = {
        { offset = Vector( 42, 14, 21.2 ), texture = "glide/effects/headlight_circle2" },
        { offset = Vector( 42, -14, 21.2 ), texture = "glide/effects/headlight_circle2" }
    }

    ENT.LightSprites = {
        { type = "headlight", offset = Vector( 41, 14, 21.2 ), dir = Vector( 1, 0, 0 ) },
        { type = "headlight", offset = Vector( 41, -14, 21.2 ), dir = Vector( 1, 0, 0 ) },
        { type = "taillight", offset = Vector( -44, 13, 16.5 ), dir = Vector( -1, 0, 0 ), size = 15, signal = "left"  },
        { type = "taillight", offset = Vector( -44, -13, 16.5 ), dir = Vector( -1, 0, 0 ), size = 15, signal = "right" },
        { type = "brake", offset = Vector( -44, 13, 16.5 ), dir = Vector( -1, 0, 0 ), lightRadius = 25, size = 25, signal = "left"  },
        { type = "brake", offset = Vector( -44, -13, 16.5 ), dir = Vector( -1, 0, 0 ), lightRadius = 25, size = 25, signal = "right" }
    }

    ENT.ExhaustOffsets = {
        { pos = Vector( -45, 2, 11 ), angle = Angle( 20, 0, 0 ), scale = 0.7 },
        { pos = Vector( -45, -2, 11 ), angle = Angle( 20, 0, 0 ), scale = 0.7 }
    }

    ENT.EngineSmokeStrips = {
        { offset = Vector( 48, 0, 16 ), angle = Angle(), width = 8 }
    }

    ENT.EngineFireOffsets = {
        { offset = Vector( 22, 15, 7 ), angle = Angle( 90, 90, 0 ), scale = 0.4 },
        { offset = Vector( 22, -15, 7 ), angle = Angle( 90, 270, 0 ), scale = 0.4 }
    }

    ENT.EngineSmokeMaxZVel = 20
    ENT.ExternalGearSwitchSound = ""
    ENT.InternalGearSwitchSound = ""

    ENT.StartSound = "glide/engines/start_bike_2.wav"
    ENT.StartedSound = "glide_experiments/blazer_aqua/startup.wav"
    ENT.StoppedSound = "glide_experiments/blazer_aqua/shutdown.wav"

    ENT.HornSound = "glide/horns/car_horn_light_1.wav"
    ENT.ExhaustPopSound = "GlideExperiments.BlazerAqua.ExhaustPop"

    ENT.TurboBlowoffSound = "GlideExperiments.DumpValve"
    ENT.TurboBlowoffVolume = 0.8
    ENT.TurboPitch = 100

    function ENT:AllowWindSound()
        return true, 1
    end

    function ENT:AllowFirstPersonMuffledSound()
        return false
    end

    function ENT:OnCreateEngineStream( stream )
        stream.offset = Vector( -10, 0, 0 )
        stream:LoadPreset( "experiment-blazer_aqua" )
    end

    local POSE_DATA = {
        ["ValveBiped.Bip01_L_UpperArm"] = Angle( -3, 5, 0 ),
        ["ValveBiped.Bip01_R_UpperArm"] = Angle( 6, 8, -5 ),
        ["ValveBiped.Bip01_L_Thigh"] = Angle( 0, -15, 5 ),
        ["ValveBiped.Bip01_L_Calf"] = Angle( -20, 75, 0 ),
        ["ValveBiped.Bip01_R_Thigh"] = Angle( 0, -15, -5 ),
        ["ValveBiped.Bip01_R_Calf"] = Angle( 20, 75, 0 ),
        ["ValveBiped.Bip01_L_Foot"] = Angle( -20, -40, 0 ),
        ["ValveBiped.Bip01_R_Foot"] = Angle( 20, -40, 0 )
    }

    function ENT:GetSeatBoneManipulations()
        return POSE_DATA
    end

    function ENT:OnActivateMisc()
        BaseClass.OnActivateMisc( self )

        self.handlebarsId = self:LookupBone( "handlebars" )
        self.suspLF = self:LookupBone( "suspension_lf" )
        self.suspRF = self:LookupBone( "suspension_rf" )
        self.suspLR = self:LookupBone( "suspension_lr" )
        self.suspRR = self:LookupBone( "suspension_rr" )
        self.wheelLF = self:LookupBone( "wheel_lf" )
        self.wheelRF = self:LookupBone( "wheel_rf" )
        self.wheelLR = self:LookupBone( "wheel_lr" )
        self.wheelRR = self:LookupBone( "wheel_rr" )
    end

    local Lerp = Lerp
    local Clamp = math.Clamp
    local ang = Angle()

    function ENT:OnUpdateAnimations()
        if not self.handlebarsId then return end

        local steer = self:GetSteering()
        local deploy = self:GetDeployWheels()

        ang[1] = 0
        ang[2] = steer * -30
        ang[3] = 0
        self:ManipulateBoneAngles( self.handlebarsId, ang )

        -- Spin the wheels
        ang[2] = steer * -30
        ang[3] = self:GetWheelSpin( 1 )
        self:ManipulateBoneAngles( self.wheelLF, ang )

        ang[3] = self:GetWheelSpin( 2 )
        self:ManipulateBoneAngles( self.wheelRF, ang )

        ang[2] = 0
        ang[3] = self:GetWheelSpin( 3 )
        self:ManipulateBoneAngles( self.wheelLR, ang )

        ang[3] = self:GetWheelSpin( 4 )
        self:ManipulateBoneAngles( self.wheelRR, ang )

        -- Rotate the suspension bones depending on the wheel offset
        ang[1] = Lerp( deploy, 50, 10 - Clamp( self:GetWheelOffset( 1 ) / -10, 0, 1 ) * 30 )
        ang[2] = 0
        ang[3] = 0
        self:ManipulateBoneAngles( self.suspLF, ang )

        ang[1] = Lerp( deploy, -50, -10 + Clamp( self:GetWheelOffset( 2 ) / -10, 0, 1 ) * 30 )
        self:ManipulateBoneAngles( self.suspRF, ang )

        ang[1] = Lerp( deploy, 50, 10 - Clamp( self:GetWheelOffset( 3 ) / -10, 0, 1 ) * 30 )
        self:ManipulateBoneAngles( self.suspLR, ang )

        ang[1] = Lerp( deploy, -50, -10 + Clamp( self:GetWheelOffset( 4 ) / -10, 0, 1 ) * 30 )
        self:ManipulateBoneAngles( self.suspRR, ang )
    end
end

if SERVER then
    ENT.ChassisMass = 750
    ENT.AngularDrag = Vector( -0.1, -0.2, -5 ) -- Roll, pitch, yaw
    ENT.AirControlForce = Vector( 0.9, 0.4, 0.2 ) -- Roll, pitch, yaw

    ENT.FallOnCollision = true
    ENT.FallWhileUnderWater = true
    ENT.SpawnPositionOffset = Vector( 0, 0, 40 )

    ENT.SuspensionHeavySound = "Glide.Suspension.CompressBike"
    ENT.StartupTime = 0.5

    ENT.BuoyancyPointsZOffset = -5
    ENT.BuoyancyPointsXSpacing = 0.8
    ENT.BuoyancyPointsYSpacing = 0.9

    ENT.BoatParams = {
        buoyancy = 5,
        buoyancyDepth = 25,
        turbulanceForce = 70,
        engineLiftForce = 400,
        rollForce = 80,
        turnForce = 700,
        maxSpeed = 1300,
        waterLinearDrag = Vector( 0.4, 1.5, 0.02 ), -- (Forward, right, up)
        waterAngularDrag = Vector( -5, -20, -5 ), -- (Roll, pitch, yaw)
    }

    ENT.LightBodygroups = {
        { type = "headlight", bodyGroupId = 5, subModelId = 1 }, -- Headlight
        { type = "headlight", bodyGroupId = 6, subModelId = 1, signal = "left" }, -- Left signal/taillight
        { type = "headlight", bodyGroupId = 7, subModelId = 1, signal = "right" } -- Right signal/taillight
    }

    ENT.WheelDeployTime = 1.1

    function ENT:CreateFeatures()
        self:RegisterHoldAction( "headlights", 1.0, { name = "ToggleAmphibiousMode" } )

        self.wheelDeployState = 0
        self:SetWheelDeployState( 0 )

        self.flywheelTorque = 30000
        self.engineBrakeTorque = 3000
        self.switchBaseDelay = 0.45

        self:SetSuspensionLength( 8 )
        self:SetSpringStrength( 320 )
        self:SetSpringDamper( 2000 )

        self:SetSteerConeMaxAngle( 0.35 )
        self:SetSteerConeMaxSpeed( 800 )
        self:SetSteerConeChangeRate( 7 )
        self:SetCounterSteer( 0.4 )

        self:SetPowerDistribution( -0.7 )
        self:SetDifferentialRatio( 0.6 )
        self:SetBrakePower( 2000 )

        self:SetMinRPM( 650 )
        self:SetMaxRPM( 6500 )
        self:SetMinRPMTorque( 4000 )
        self:SetMaxRPMTorque( 4200 )

        self:SetForwardTractionMax( 2400 )
        self:SetSideTractionMultiplier( 18 )
        self:SetSideTractionMaxAng( 20 )
        self:SetSideTractionMax( 3500 )
        self:SetSideTractionMin( 500 )

        self:CreateSeat( Vector( -16, 0, 13 ), Angle( 0, 270, -16 ), Vector( 0, 60, 0 ), true )

        self:CreateWheel( Vector( 30.9, 19, 2 ), {
            steerMultiplier = 1
        } )

        self:CreateWheel( Vector( 30.9, -19, 2 ), {
            steerMultiplier = 1
        } )

        self:CreateWheel( Vector( -30, 19, 2 )  )
        self:CreateWheel( Vector( -30, -19, 2 ) )

        self:ChangeWheelRadius( 12 )

        for _, w in ipairs( self.wheels ) do
            Glide.HideEntity( w, true )
        end
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

    local stateSounds = {
        [1] = { "glide/aircraft/gear_down.wav", 80, 150, 0.6 },
        [2] = { "buttons/latchunlocked2.wav", 80, 110, 1.0 },
        [3] = { "glide/aircraft/gear_down.wav", 80, 145, 0.6 }
    }

    function ENT:SetWheelDeployState( state )
        -- Do transition sounds
        if state ~= self.wheelDeployState then
            local soundParams = stateSounds[state]

            if soundParams then
                self:EmitSound( unpack( soundParams ) )
            end
        end

        if state == 1 then
            -- Transition to retracted wheels
            self.wheelDeployState = 1

        elseif state == 2 then
            -- Set to retracted wheels now
            self.wheelDeployState = 2
            self:SetDeployWheels( 0 )
            self:ChangeSuspensionLengthMultiplier( 0 )

        elseif state == 3 then
            -- Transition to deployed wheels
            self.wheelDeployState = 3

        else
            -- Set to deployed wheels now
            self.wheelDeployState = 0
            self:SetDeployWheels( 1 )
            self:ChangeSuspensionLengthMultiplier( 1 )
        end
    end

    local EntityPairs = Glide.EntityPairs

    function ENT:ChangeSuspensionLengthMultiplier( multiplier )
        self.wheelsEnabled = multiplier > 0.05
        self.BoatParams.waterLinearDrag[1] = 0.4 + multiplier * 0.5

        for _, w in EntityPairs( self.wheels ) do
            w.state.suspensionLengthMult = multiplier
        end

        local phys = self:GetPhysicsObject()

        if IsValid( phys ) then
            phys:Wake()
        end
    end

    function ENT:OnHoldInputAction( _action, data )
        if data.name ~= "ToggleAmphibiousMode" then return end

        local state = self.wheelDeployState

        if state == 0 or state == 3 then
            self:SetWheelDeployState( 1 )
        else
            self:SetWheelDeployState( 3 )
        end
    end

    function ENT:OnPostThink( dt, selfTbl )
        BaseClass.OnPostThink( self, dt, selfTbl )

        local state = self.wheelDeployState

        if state == 1 then -- Is it changing to retracted wheels?
            local value = self:GetDeployWheels() - dt / selfTbl.WheelDeployTime

            if value < 0 then
                self:SetWheelDeployState( 2 )
            else
                self:SetDeployWheels( value )
                self:ChangeSuspensionLengthMultiplier( value )
            end

        elseif state == 3 then -- Is it changing to deployed wheels?
            local value = self:GetDeployWheels() + dt / selfTbl.WheelDeployTime

            if value > 1 then
                self:SetWheelDeployState( 0 )
            else
                self:SetDeployWheels( value )
                self:ChangeSuspensionLengthMultiplier( value )
            end
        end
    end
end
