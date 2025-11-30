SWEP.PrintName = "#glide_experiments.swep.firework_launcher"
SWEP.Instructions = ""
SWEP.Author = "StyledStrike"
SWEP.Category = "Glide"

SWEP.Slot = 4
SWEP.Spawnable = true
SWEP.AdminOnly = false

SWEP.UseHands = true
SWEP.ViewModelFOV = 50
SWEP.BobScale = 0.5
SWEP.SwayScale = 1.0

SWEP.ViewModel = "models/glide_experiments/weapons/c_firework_launcher.mdl"
SWEP.WorldModel = "models/glide_experiments/weapons/w_firework_launcher.mdl"

if CLIENT then
    SWEP.BounceWeaponIcon = false
    SWEP.WepSelectIcon = surface.GetTextureID( "glide_experiments/vgui/glide_firework_launcher_icon" )
    SWEP.IconOverride = "glide_experiments/vgui/glide_firework_launcher.png"
end

SWEP.DeployTime = 0.1
SWEP.ReloadTime = 2.0
SWEP.FireTime = 0.5
SWEP.ClipTime = 1
SWEP.HoldType = "rpg"

SWEP.Primary.ClipSize = 1
SWEP.Primary.DefaultClip = 20
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = "RPG_Round"

SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "none"

SWEP.LockOnThreshold = 0.95
SWEP.LockOnMaxDistance = 20000

local CurTime = CurTime

function SWEP:SetupDataTables()
    self:NetworkVar( "Float", "NextReload" )
    self:NetworkVar( "Bool", "Reloading" )
end

function SWEP:Initialize()
    self:SetHoldType( self.HoldType )
    self:SetDeploySpeed( 1.5 )
end

function SWEP:Deploy()
    self:SetHoldType( self.HoldType )
    self:SetDeploySpeed( 1.5 )
    self:SetReloading( false )

    self:SendWeaponAnim( self:Clip1() > 0 and ACT_VM_DRAW or ACT_VM_PICKUP )
    self:SetNextPrimaryFire( CurTime() + self.DeployTime )
    self:SetNextSecondaryFire( CurTime() + self.DeployTime )

    if SERVER then
        self.lockOnThinkCD = 0
        self.lockOnStateCD = 0
        self.traceFilter = self:GetOwner()
    end

    return true
end

function SWEP:Holster()
    self:SetReloading( false )

    return true
end

function SWEP:GetUserAmmoCount()
    local user = self:GetOwner()

    if user.GetAmmoCount then
        return user:GetAmmoCount( self:GetPrimaryAmmoType() )
    end

    return 1
end

--- We handle reloading manually to allow this weapon
--- to have it's clip be set in the middle of a reload,
--- and to avoid interrupting `SWEP:Think`.
function SWEP:Reload()
    if self:GetUserAmmoCount() == 0 then
        if SERVER and CurTime() > self:GetNextReload() then
            self:SetNextPrimaryFire( CurTime() + 0.5 )
            self:SetNextReload( CurTime() + 0.5 )
            self:GetOwner():EmitSound( "Default.ClipEmpty_Pistol" )
        end
        return
    end

    if
        not self:GetReloading() and
        CurTime() > self:GetNextReload() and
        self:Clip1() < self.Primary.ClipSize and
        self:GetUserAmmoCount() > 0
    then
        self:SetReloading( true )
        self:SendWeaponAnim( ACT_VM_RELOAD )
        self:GetOwner():SetAnimation( PLAYER_RELOAD )

        self:SetNextReload( CurTime() + self.ClipTime )
        self:SetNextPrimaryFire( CurTime() + self.ReloadTime )
        self:SetNextSecondaryFire( CurTime() + self.ReloadTime )
    end
end

function SWEP:CanAttack()
    if self:GetReloading() then
        return false
    end

    if self:Clip1() < 1 then
        return false
    end

    if self:GetNextPrimaryFire() > CurTime() then
        return false
    end

    return true
end

function SWEP:PrimaryAttack()
    if not self:CanAttack() then return end

    local fireDelay = CurTime() + self.FireTime

    self:SetNextPrimaryFire( fireDelay )
    self:SetNextSecondaryFire( fireDelay )
    self:SetNextReload( fireDelay )
    self:EmitSound( ")glide_experiments/weapons/firework_launch.wav", 80, math.random( 95, 105 ), 1, CHAN_WEAPON )

    self:TakePrimaryAmmo( 1 )
    self:SendWeaponAnim( ACT_VM_PRIMARYATTACK )

    local user = self:GetOwner()

    user:SetAnimation( PLAYER_ATTACK1 )

    if user.ViewPunch then
        user:ViewPunch( Angle( -4, util.SharedRandom( "HomingLauncherRecoil", -2, 2 ), 0 ) )
    end

    if SERVER then
        local ang = user:EyeAngles()
        local tr = user:GetEyeTrace()

        -- Spawn the missile a bit ahead of the player,
        -- except when close to walls.
        local dist = ( tr.HitPos - tr.StartPos ):Length()
        local offsetF = math.Clamp( dist - 15, 0, 30 )

        -- Make the missile look like it came out of the weapon
        local startPos = user:GetShootPos()
            + ang:Forward() * offsetF
            + ang:Right() * 9
            - ang:Up() * 3

        local dir = tr.HitPos - startPos
        dir:Normalize()

        local missile = ents.Create( "glide_experiments_firework" )
        missile:SetPos( startPos )
        missile:SetAngles( dir:Angle() )
        missile:Spawn()
        missile:SetupMissile( user, user )
    end
end

function SWEP:SecondaryAttack() end

function SWEP:Think()
    if self:GetReloading() then
        -- Check if we've finished reloading
        if CurTime() > self:GetNextReload() then
            self:SetReloading( false )
            self:SetClip1( self.Primary.ClipSize )

            -- Take the player's ammo
            self:GetOwner():SetAmmo( self:GetUserAmmoCount() - 1, self.Primary.Ammo )
        end

    elseif self:Clip1() == 0 and self:GetUserAmmoCount() > 0 and CurTime() > self:GetNextReload() then
        -- Auto-reload
        self:Reload()
    end
end

if CLIENT then
    sound.Add( {
        name = "Glide.FireworkLauncher.Insert",
        channel = CHAN_STATIC,
        volume = 0.6,
        level = 60,
        pitch = { 95, 105 },
        sound = "glide_experiments/weapons/firework_rocket_insert.wav"
    } )

    sound.Add( {
        name = "Glide.FireworkLauncher.Draw",
        channel = CHAN_STATIC,
        volume = 0.5,
        level = 60,
        pitch = { 95, 105 },
        sound = {
            "glide_experiments/weapons/firework_launcher_draw1.wav",
            "glide_experiments/weapons/firework_launcher_draw2.wav",
            "glide_experiments/weapons/firework_launcher_draw3.wav",
            "glide_experiments/weapons/firework_launcher_draw4.wav"
        }
    } )

    sound.Add( {
        name = "Glide.FireworkLauncher.Move",
        channel = CHAN_STATIC,
        volume = 1.0,
        level = 60,
        pitch = { 80, 105 },
        sound = {
            "glide_experiments/weapons/firework_launcher_move1.wav"
        }
    } )

    sound.Add( {
        name = "Glide.FireworkLauncher.Rotate",
        channel = CHAN_STATIC,
        volume = 0.3,
        level = 60,
        pitch = { 97, 103 },
        sound = "glide/weapons/homing_launcher/homing_rotate.wav"
    } )

    function SWEP:DoDrawCrosshair()
        return true
    end

    function SWEP:DrawHUD()
        if self:IsWeaponVisible() then
            Glide.DrawWeaponCrosshair( ScrW() * 0.5, ScrH() * 0.5, "glide/aim_dot.png", 0.05 )
            return true
        end

        return false
    end
end
