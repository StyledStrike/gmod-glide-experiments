include( "shared.lua" )

function ENT:Initialize()
    -- Create a RangedFeature to handle sounds
    self.fireworkSounds = Glide.CreateRangedFeature( self, 8000 )
    self.fireworkSounds:SetActivateCallback( "ActivateSound" )
    self.fireworkSounds:SetDeactivateCallback( "DeactivateSound" )

    -- Update model angle/offset right away
    self:UpdateModelRenderMultiply()
    self.doEffects = true
end

function ENT:OnRemove()
    if self.fireworkSounds then
        self.fireworkSounds:Destroy()
        self.fireworkSounds = nil
    end
end

local LOOP_SOUNDS = {
    "glide_experiments/weapons/firework_rocket_loop1.wav",
    "glide_experiments/weapons/firework_rocket_loop2.wav"
}

function ENT:ActivateSound()
    if not self.rocketLoop then
        self.rocketLoop = CreateSound( self, table.Random( LOOP_SOUNDS ) )
        self.rocketLoop:SetSoundLevel( 95 )
        self.rocketLoop:PlayEx( 1.0, math.random( 85, 130 ) )
    end
end

function ENT:DeactivateSound()
    if self.rocketLoop then
        self.rocketLoop:Stop()
        self.rocketLoop = nil
    end
end

function ENT:UpdateModelRenderMultiply()
    local model = self:GetModel()
    self.lastModel = model

    local data = list.Get( "GlideProjectileModels" )[model]

    if not data then
        self:DisableMatrix( "RenderMultiply" )
        return
    end

    local scale = data.scale or 1
    local modelScale = self:GetModelScale()
    local m = Matrix()
    m:SetScale( Vector( scale, scale, scale ) )

    if data.offset then
        m:SetTranslation( data.offset * modelScale * scale )
    end

    if data.angle then
        m:SetAngles( data.angle )
    end

    self:EnableMatrix( "RenderMultiply", m )
end

local Effect = util.Effect
local EffectData = EffectData
local CurTime = CurTime

function ENT:Think()
    if self.fireworkSounds then
        self.fireworkSounds:Think()
    end

    if self:WaterLevel() > 0 then
        self.doEffects = false

    elseif self.doEffects then
        local eff = EffectData()
        eff:SetOrigin( self:GetPos() )
        eff:SetNormal( -self:GetForward() )
        eff:SetScale( self:GetEffectiveness() )
        eff:SetColor( ( self:GetTrailHue() / 360 ) * 255 )
        Effect( "glide_firework", eff )
    end

    local model = self:GetModel()

    if model ~= self.lastModel then
        self:UpdateModelRenderMultiply()
    end

    self:SetNextClientThink( CurTime() + 0.02 )

    return true
end
