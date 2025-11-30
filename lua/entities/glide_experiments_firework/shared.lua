AddCSLuaFile()

ENT.Type = "anim"
ENT.Base = "glide_missile"
ENT.PrintName = "Firework"

ENT.Spawnable = false
ENT.AdminOnly = false
ENT.VJ_ID_Danger = true

ENT.PhysgunDisabled = true
ENT.DoNotDuplicate = true
ENT.DisableDuplicator = true

function ENT:SetupDataTables()
    self:NetworkVar( "Int", "TrailHue" )
    self:NetworkVar( "Float", "Effectiveness" )
end
