local Clamp = math.Clamp
local RandomFloat = math.Rand

function EFFECT:Init( data )
    local origin = data:GetOrigin()

    local emitter = ParticleEmitter( origin, false )
    if not IsValid( emitter ) then return end

    local normal = data:GetNormal()
    local scale = Clamp( data:GetScale(), 0.1, 3 )
    local color = HSVToColor( Clamp( data:GetColor() / 255, 0, 1 ) * 360, 1, 1 )

    self:Rocket( emitter, origin, normal, scale, color )
    self:Smoke( emitter, origin, normal, scale, color )

    emitter:Finish()
end

function EFFECT:Think()
    return false
end

function EFFECT:Render()
end

local RandomInt = math.random

local FLARE_MATERIAL = "effects/yellowflare"
local SMOKE_MATERIAL = "particle/smokesprites_000"

function EFFECT:Rocket( emitter, origin, normal, scale, color )
    local p = emitter:Add( FLARE_MATERIAL, origin + normal * 4 )

    if p then
        local size = RandomFloat( 30, 120 ) * scale

        p:SetDieTime( 0.03 )
        p:SetStartAlpha( 255 )
        p:SetEndAlpha( 100 )
        p:SetStartSize( size )
        p:SetEndSize( size )
        p:SetRoll( RandomFloat( -1, 1 ) )
        p:SetColor( color.r, color.g, color.b )
        p:SetLighting( false )
    end

    p = emitter:Add( FLARE_MATERIAL, origin + normal )

    if p then
        local size = RandomFloat( 5, 20 ) * scale

        p:SetDieTime( 0.03 )
        p:SetStartAlpha( 255 )
        p:SetEndAlpha( 100 )
        p:SetStartSize( size )
        p:SetEndSize( size )
        p:SetRoll( RandomFloat( -1, 1 ) )
        p:SetColor( 255, 255, 255 )
        p:SetLighting( false )
    end
end

function EFFECT:Smoke( emitter, origin, normal, scale, color )
    origin = origin + normal * 20

    local p

    for _ = 1, 5 do
        p = emitter:Add( SMOKE_MATERIAL .. RandomInt( 9 ), origin )

        if p then
            p:SetDieTime( RandomFloat( 0.1, 0.3 ) )
            p:SetStartAlpha( 100 )
            p:SetEndAlpha( 0 )
            p:SetStartSize( RandomFloat( 4, 6 ) * scale )
            p:SetEndSize( RandomFloat( 10, 13 ) * scale )
            p:SetRoll( RandomFloat( -1, 1 ) )
            p:SetLighting( false )

            p:SetAirResistance( 50 )
            p:SetVelocity( normal * RandomFloat( 100, 500 ) * scale )
            p:SetColor( color.r, color.g, color.b )
        end
    end

    origin = origin + normal * 50

    for i = 1, 5 do
        p = emitter:Add( SMOKE_MATERIAL .. RandomInt( 9 ), origin + normal * i * 5 )

        if p then
            p:SetDieTime( RandomFloat( 0.4, 1.0 ) )
            p:SetStartAlpha( 100 )
            p:SetEndAlpha( 0 )
            p:SetStartSize( RandomFloat( 3, 6 ) * scale )
            p:SetEndSize( RandomFloat( 15, 30 ) * scale )
            p:SetRoll( RandomFloat( -1, 1 ) )
            p:SetLighting( true )

            p:SetAirResistance( 150 )
            p:SetVelocity( normal * RandomFloat( 300, 700 ) * scale )
            p:SetColor( 50 + color.r * 0.8, 50 + color.g * 0.8, 50 + color.b * 0.8 )
        end
    end
end
