-- "lua\\weapons\\gmod_tool\\stools\\drgbase_tool_godmode.lua"
-- Retrieved by https://github.com/lewisclark/glua-steal
TOOL.Tab = "DrGBase"
TOOL.Category = "Tools"
TOOL.Name = "#tool.drgbase_tool_godmode.name"
TOOL.BuildCPanel = function(panel)
	panel:Help("#tool.drgbase_tool_godmode.desc")
	panel:Help("#tool.drgbase_tool_godmode.0")
end

function TOOL:LeftClick(tr)
	if not IsValid(tr.Entity) then return false end
	if not tr.Entity.IsDrGNextbot then return false end
	if SERVER then tr.Entity:SetGodMode(not tr.Entity:GetGodMode()) end
	return true
end

if CLIENT then
	language.Add("tool.drgbase_tool_godmode.name", "Toggle Godmode")
	language.Add("tool.drgbase_tool_godmode.desc", "Disable/enable godmode for a nextbot.")
	language.Add("tool.drgbase_tool_godmode.0", "Left click to toggle godmode. (Green => Enabled / Red => Disabled)")

	hook.Add("PreDrawHalos", "DrGBaseToolGodModeHalos", function()
		local wep = LocalPlayer():GetActiveWeapon()
		if not IsValid(wep) or wep:GetClass() ~= "gmod_tool" then return end
		local tool = LocalPlayer():GetTool()
		if tool == nil or tool.Mode ~= "drgbase_tool_godmode" then return end
		local enabled = {}
		local disabled = {}
		for i, nextbot in ipairs(DrGBase.GetNextbots()) do
			if not IsValid(nextbot) then continue end
			if nextbot:GetGodMode() then table.insert(enabled, nextbot)
			else table.insert(disabled, nextbot) end
		end
		halo.Add(enabled, DrGBase.CLR_GREEN)
		halo.Add(disabled, DrGBase.CLR_RED)
	end)
end