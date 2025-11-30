AddCSLuaFile( "shared.lua" )
AddCSLuaFile( "cl_init.lua" )

include( "shared.lua" )

function ENT:Initialize()
    self:SetModel( "models/glide_experiments/weapons/firework_rocket.mdl" )
    self:SetSolid( SOLID_VPHYSICS )
    self:SetMoveType( MOVETYPE_VPHYSICS )
    self:PhysicsInit( SOLID_VPHYSICS )
    self:DrawShadow( false )

    local phys = self:GetPhysicsObject()

    if IsValid( phys ) then
        phys:Wake()
        phys:SetAngleDragCoefficient( 1 )
        phys:SetDragCoefficient( 0 )
        phys:EnableGravity( false )
        phys:SetMass( 20 )
        phys:SetVelocityInstantaneous( self:GetForward() * 500 )

        self:StartMotionController()
    end

    self.radius = 500
    self.damage = 35
    self.lifeTime = CurTime() + math.Rand( 1.8, 2.2 )
    self.acceleration = 7000
    self.maxSpeed = 3000

    self.speed = 0
    self.applyThrust = true

    self:SetEffectiveness( 0 )
    self:SetTrailHue( math.floor( math.random( 0, 360 ) / 30 ) * 30 )
end

local IsValid = IsValid

function ENT:SetupMissile( attacker, parent )
    -- Set which player created this missile
    self.attacker = attacker

    -- Don't collide with our parent entity
    self:SetOwner( parent )
end

-- Override base class function.
function ENT:SetTarget( _target )
    -- Fireworks can't track targets
end

function ENT:Explode( normal )
    if self.hasExploded then return end

    -- Don't let stuff like collision events call this again
    self.hasExploded = true

    normal = normal or self:GetForward()

    local IsUnderWater = Glide.IsUnderWater

    if not IsUnderWater( self:GetPos() ) then
        local eff = EffectData()
        eff:SetOrigin( self:GetPos() )
        eff:SetNormal( normal )
        eff:SetScale( 1.0 )
        eff:SetColor( ( self:GetTrailHue() / 360 ) * 255 )
        util.Effect( "glide_firework_explosion", eff )
    end

    Glide.CreateExplosion( self, self.attacker, self:GetPos(), self.radius, self.damage, normal, Glide.EXPLOSION_TYPE.FIREWORK )

    self.attacker = nil
    self:Remove()
end

local FrameTime = FrameTime
local Approach = math.Approach
local TraceHull = util.TraceHull

local ray = {}

local traceData = {
    output = ray,
    filter = { NULL, NULL },
    mask = MASK_PLAYERSOLID,
    maxs = Vector(),
    mins = Vector()
}

function ENT:Think()
    local t = CurTime()

    if t > self.lifeTime then
        self:Explode()
        return
    end

    self:NextThink( t )

    local phys = self:GetPhysicsObject()

    if not self.applyThrust or not IsValid( phys ) then
        return true
    end

    if self:WaterLevel() > 0 then
        self.applyThrust = false
        phys:EnableGravity( true )
        return true
    end

    local dt = FrameTime()

    self:SetEffectiveness( Approach( self:GetEffectiveness(), 1, dt * 3 ) )

    local myPos = self:GetPos()

    traceData.start = myPos
    traceData.endpos = myPos + self:GetVelocity() * dt * 2
    traceData.filter[1] = self
    traceData.filter[2] = self:GetOwner()

    -- Trace result is stored on `ray`
    TraceHull( traceData )

    if not ray.HitSky and ray.Hit then
        self:Explode( ray.HitNormal )
    end

    return true
end

local ZERO_VEC = Vector()

function ENT:PhysicsSimulate( phys, dt )
    if not self.applyThrust then return end

    -- Accelerate to reach maxSpeed
    if self.speed < self.maxSpeed then
        self.speed = self.speed + self.acceleration * dt
    end

    phys:SetAngleVelocityInstantaneous( ZERO_VEC )
    phys:SetVelocityInstantaneous( self:GetForward() * self.speed )
end

-- Override base class function
function ENT:PhysicsCollide( _data )
    self:Explode( -self:GetForward() )
end
