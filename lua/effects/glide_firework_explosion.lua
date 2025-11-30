local CurTime = CurTime
local Clamp = math.Clamp
local RandomFloat = math.Rand

function EFFECT:Init( data )
    local origin = data:GetOrigin()
    local normal = data:GetNormal()
    local scale = Clamp( data:GetScale(), 0.1, 1.5 )

    self.origin = origin
    self.normal = normal
    self.scale = scale
    self.startTime = CurTime()
    self.emitter = ParticleEmitter( origin, false )

    self.color = HSVToColor( Clamp( data:GetColor() / 255, 0, 1 ) * 360, 1, 1 )
    self.emitCooldown = 0
    self:Explosion()
end

function EFFECT:Think()
    local curTime = CurTime()
    local t = curTime - self.startTime

    if t > self.emitCooldown then
        self.emitCooldown = t + 0.02 + ( t - 0.2 ) * 0.5

        if t > 0.18 then
            self:EmitSparks()
        end
    end

    local isAlive = t < 0.8

    if not isAlive and IsValid( self.emitter ) then
        self.emitter:Finish()
    end

    return isAlive
end

local GLOW_MAT = Material( "sprites/light_glow02_add" )

function EFFECT:Render()
    if CurTime() - self.startTime < 0.05 then
        local size = self.scale * 2500
        render.SetMaterial( GLOW_MAT )
        render.DrawSprite( self.origin, size, size, self.color )
    end
end

local RandomVec = VectorRand
local FLARE_MATERIAL = "effects/yellowflare"

function EFFECT:EmitSparks()
    local emitter = self.emitter
    if not IsValid( emitter ) then return end

    local scale = self.scale
    local area = 220 * scale
    local origin = self.origin + self.normal * ( area * 0.5 )

    local count = math.floor( scale * 3 )
    local p, size

    for _ = 0, count do
        p = emitter:Add( FLARE_MATERIAL, origin + VectorRand() * area )

        if p then
            size = RandomFloat( 40, 50 ) * scale

            p:SetDieTime( 0.05 )
            p:SetVelocity( RandomVec() )

            p:SetStartAlpha( 255 )
            p:SetEndAlpha( 100 )
            p:SetStartSize( size )
            p:SetEndSize( size )
            p:SetRoll( RandomFloat( -1, 1 ) )
            p:SetColor( 255, 255, 255 )
            p:SetLighting( false )
        end
    end
end

local GRAVITY = Vector( 0, 0, -800 )

local function SpreadDirection( dir, spread )
    local ang = dir:Angle()
    local up = ang:Up()
    local rt = ang:Right()

    ang:RotateAroundAxis( up, RandomFloat( -spread, spread ) )
    ang:RotateAroundAxis( rt, RandomFloat( -spread, spread ) )

    return ang:Forward()
end

function EFFECT:Explosion()
    local emitter = self.emitter
    if not IsValid( emitter ) then return end

    local origin = self.origin
    local normal = self.normal
    local scale = self.scale
    local color = self.color
    local dlight = DynamicLight( self:EntIndex() )

    if dlight then
        dlight.pos = origin + normal * 100
        dlight.r = color.r
        dlight.g = color.g
        dlight.b = color.b
        dlight.brightness = 4
        dlight.decay = 2000
        dlight.size = 4000 * scale
        dlight.dietime = CurTime() + 1
    end

    local count = math.floor( scale * 100 )
    local p1, p2, size, vel, life

    for _ = 0, count do
        size = RandomFloat( 40, 50 ) * scale
        vel = SpreadDirection( normal, 80 ) * 2500 * scale
        life = RandomFloat( 1.0, 1.5 )

        p1 = emitter:Add( FLARE_MATERIAL, origin )

        if p1 then
            p1:SetDieTime( life )
            p1:SetVelocity( vel )
            p1:SetGravity( GRAVITY )
            p1:SetAirResistance( 280 )

            p1:SetStartAlpha( 255 )
            p1:SetEndAlpha( 0 )
            p1:SetStartSize( size )
            p1:SetEndSize( size * 0.5 )
            p1:SetRoll( RandomFloat( -1, 1 ) )
            p1:SetColor( color.r, color.g, color.b )
            p1:SetLighting( false )
            p1:SetCollide( true )
        end

        p2 = emitter:Add( FLARE_MATERIAL, origin )

        if p2 then
            p2:SetDieTime( life * 1.5 )
            p2:SetVelocity( vel )
            p2:SetGravity( GRAVITY )
            p2:SetAirResistance( 280 )

            p2:SetStartAlpha( 255 )
            p2:SetEndAlpha( 0 )
            p2:SetStartSize( size * 0.5 )
            p2:SetEndSize( size * 0.3 )
            p2:SetRoll( RandomFloat( -1, 1 ) )
            p2:SetColor( 255, 180, 180 )
            p2:SetLighting( false )
            p2:SetCollide( true )
        end
    end
end
