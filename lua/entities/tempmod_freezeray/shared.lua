-- "lua\\entities\\tempmod_freezeray\\shared.lua"
-- Retrieved by https://github.com/lewisclark/glua-steal
ENT.Type = "anim"
ENT.Base = "base_gmodentity"

ENT.PrintName = "#tempmod.tempmod_freezeray"
ENT.Author = "Ty4a"
ENT.Category = "Temperature Mod"
ENT.Spawnable = true
ENT.AdminOnly = true

function ENT:SetupDataTables()
    self:NetworkVar("Bool", 0, "Effect")
end