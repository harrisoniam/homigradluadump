-- "addons\\tools\\lua\\weapons\\gmod_tool\\stools\\axiscentre.lua"
-- Retrieved by https://github.com/lewisclark/glua-steal
// Axis Centre tool - by Wenli

TOOL.Category = "Constraints"
TOOL.Name = "#tool.axiscentre.listname"
TOOL.Command = nil
TOOL.ConfigName = nil

TOOL.ClientConVar[ "forcelimit" ] = 0
TOOL.ClientConVar[ "torquelimit" ] = 0
TOOL.ClientConVar[ "hingefriction" ] = 0
TOOL.ClientConVar[ "nocollide" ] = 0
TOOL.ClientConVar[ "moveprop" ] = 0
TOOL.ClientConVar[ "rot2nd" ] = 0

if CLIENT then
	language.Add("tool.axiscentre.name","Centre Axis Constraint")
	language.Add("tool.axiscentre.listname", "Axis - Centre")
	language.Add("tool.axiscentre.desc", "Axis props by centre of mass" )
	language.Add("tool.axiscentre.0", "Left Click: Select first prop." )
	language.Add("tool.axiscentre.1", "Left Click: Select second prop." )
	language.Add("tool.axiscentre.nocollide", "Nocollide" )
	language.Add("tool.axiscentre.rot2nd", "Rotation direction by second prop" )
	language.Add("tool.axiscentre.moveprop", "Move first prop (remember to nocollide!)" )
	language.Add("Undone_Axis Centre","Undone Axis Centre")
end

function TOOL:LeftClick( trace )
	if trace.Entity:IsPlayer() then return false end
	if SERVER and !util.IsValidPhysicsObject( trace.Entity, trace.PhysicsBone ) then return false end
	
	local iNum = self:NumObjects()
	local Phys = trace.Entity:GetPhysicsObjectNum( trace.PhysicsBone )
	self:SetObject( iNum + 1, trace.Entity, trace.HitPos, Phys, trace.PhysicsBone, trace.HitNormal )

	if iNum > 0 then
		if CLIENT then
			self:ClearObjects()
			return true
		end
		
		local ply = self:GetOwner()
		
		local forcelimit 	= self:GetClientNumber( "forcelimit", 0 )
		local torquelimit 	= self:GetClientNumber( "torquelimit", 0 )
		local nocollide 	= self:GetClientNumber( "nocollide", 0 )
		local friction 		= self:GetClientNumber( "hingefriction", 0 )
		local moveprop 		= self:GetClientNumber( "moveprop", 0 )
		local rot2nd		= self:GetClientNumber( "rot2nd", 0 )
		
		local Ent1,  Ent2  = self:GetEnt(1),	self:GetEnt(2)
		local Bone1, Bone2 = self:GetBone(1),	self:GetBone(2)
		local LPos1, LPos2 = self:GetLocalPos(1),self:GetLocalPos(2)
		local WPos1, WPos2 = self:GetPos(1),	self:GetPos(2)
		local Norm1, Norm2 = self:GetNormal(1),	self:GetNormal(2)
		local Phys1, Phys2 = self:GetPhys(1), self:GetPhys(2)
		
		if Ent1 == Ent2 then
			self:ClearObjects()
			ply:SendLua( "GAMEMODE:AddNotify('Error: Selected the same prop!',NOTIFY_GENERIC,7);" )
			return true
		end
		
		if moveprop == 1 and !Ent1:IsWorld() then			
			// Move the object so that the hitpos on our object is at the second hitpos
			local TargetPos = WPos2 + Phys1:GetPos() - WPos1
			
			print(tostring(TargetPos))
			
			Phys1:SetPos( TargetPos )
			Phys1:EnableMotion( false )
			
			// Wake up the physics object so that the entity updates its position
			Phys1:Wake()
		end
		
		LPos1 = Phys1:GetMassCenter()
		
		if rot2nd == 0 then
			LPos2 = Phys2:WorldToLocal( Phys1:LocalToWorld(LPos1) + Norm1 )
		else
			LPos2 = Phys2:WorldToLocal( Phys1:LocalToWorld(LPos1) + Norm2 )
		end

		local constraint = constraint.Axis( Ent1, Ent2, Bone1, Bone2, LPos1, LPos2, forcelimit, torquelimit, friction, nocollide )
		
		undo.Create("Axis Centre")
			undo.AddEntity( constraint )
			undo.SetPlayer( self:GetOwner() )
		undo.Finish()
		
		ply:AddCleanup( "constraints", constraint )
		ply:SendLua( "GAMEMODE:AddNotify('Axis created',NOTIFY_GENERIC,7);" )
		
		Phys1:EnableMotion( false )
		
		self:ClearObjects()
	else
		self:SetStage( iNum + 1 )
	end

	return true
end

function TOOL:Reload( trace )
	if !trace.Entity:IsValid() or trace.Entity:IsPlayer() then return false end
	if CLIENT then return true end
	
	self:SetStage(0)
	return constraint.RemoveConstraints( trace.Entity, "Axis" )
end

function TOOL:Holster( trace )
	self:ClearObjects()	
end
		
function TOOL:RightClick( trace )
end

function TOOL.BuildCPanel( Panel )
	Panel:AddControl("ComboBox",
	{
		Label = "#Presets",
		MenuButton = 1,
		Folder = "axiscentre",
		Options = {},
		CVars =
		{
			[0] = "axiscentre_forcelimit",
			[1] = "axiscentre_torquelimit",
			[2] = "axiscentre_hingefriction",
			[3] = "axiscentre_nocollide",
			[4] = "axiscentre_rot2nd"
			}
	})
	
	Panel:AddControl( "Slider",  {
			Label	= "Force Limit",
			Type	= "Float",
			Min		= 0,
			Max		= 50000,
			Command = "axiscentre_forcelimit",
			Description = "The amount of force it takes for the constraint to break. 0 means never break."}	 )
	
	Panel:AddControl( "Slider",  {
			Label	= "Torque Limit",
			Type	= "Float",
			Min		= 0,
			Max		= 50000,
			Command = "axiscentre_torquelimit",
			Description = "The amount of torque it takes for the constraint to break. 0 means never break."}	 )
	
	Panel:AddControl( "Slider",  {
			Label	= "Rotation Friction",
			Type	= "Float",
			Min		= 0,
			Max		= 100,
			Command = "axiscentre_hingefriction",
			Description = "Rotation friction of advanced axis in Z axis"}	 )
	
	Panel:AddControl("Header",{Text = "#tool.axiscentre.name", Description	= "#tool.axiscentre.desc"})	
	Panel:AddControl("CheckBox",{Label = "#tool.axiscentre.nocollide", Description = "", Command = "axiscentre_nocollide"})
	Panel:AddControl("CheckBox",{Label = "#tool.axiscentre.moveprop", Description = "", Command = "axiscentre_moveprop"})
	Panel:AddControl("CheckBox",{Label = "#tool.axiscentre.rot2nd", Description = "", Command = "axiscentre_rot2nd"})
	
	Panel:AddControl("Label", {
		Text = ""
	})
	
	
	local button_help = vgui.Create( "DButton", Panel )
	
	button_help:SetText( "Help" )
	button_help:SetToolTip( "Open online help using the Steam in-game browser" )
	button_help.DoClick = function()
		return gui.OpenURL( "http://sourceforge.net/userapps/mediawiki/wenli/index.php?title=Axis_Centre" )
	end
	
	button_help.PerformLayout = function()
		button_help:SetSize(60, 20)
		button_help:AlignRight(10)
		button_help:AlignBottom(10)
	end
end