-- "lua\\lvs_framework\\autorun\\sh_car_keybinding.lua"
-- Retrieved by https://github.com/lewisclark/glua-steal

hook.Add( "LVS:Initialize", "[LVS] - Cars - Keys", function()
	local KEYS = {
		{
			name = "CAR_THROTTLE",
			category = "LVS-Car",
			name_menu = "Throttle",
			default = "+forward",
			cmd = "lvs_car_throttle"
		},
		{
			name = "CAR_THROTTLE_MOD",
			category = "LVS-Car",
			name_menu = "Throttle Modifier",
			default = "+speed",
			cmd = "lvs_car_speed"
		},
		{
			name = "CAR_BRAKE",
			category = "LVS-Car",
			name_menu = "Brake",
			default = "+back",
			cmd = "lvs_car_brake"
		},
		{
			name = "CAR_HANDBRAKE",
			category = "LVS-Car",
			name_menu = "Handbrake",
			default = "+jump",
			cmd = "lvs_car_handbrake"
		},
		{
			name = "CAR_STEER_LEFT",
			category = "LVS-Car",
			name_menu = "Steer Left",
			default = "+moveleft",
			cmd = "lvs_car_turnleft"
		},
		{
			name = "CAR_STEER_RIGHT",
			category = "LVS-Car",
			name_menu = "Steer Right",
			default = "+moveright",
			cmd = "lvs_car_turnright"
		},
		{
			name = "CAR_LIGHTS_TOGGLE",
			category = "LVS-Car",
			name_menu = "Toggle Lights",
			default = "phys_swap",
			cmd = "lvs_car_toggle_lights"
		},
		{
			name = "CAR_MENU",
			category = "LVS-Car",
			name_menu = "Open Signal Menu",
			default = "+zoom",
			cmd = "lvs_car_menu"
		},
		{
			name = "CAR_SIREN",
			category = "LVS-Car",
			name_menu = "Open Siren Menu",
			default = "phys_swap",
			cmd = "lvs_car_siren"
		},
		{
			name = "CAR_SWAP_AMMO",
			category = "LVS-Car",
			name_menu = "Change Ammo Type",
			default = "+walk",
			cmd = "lvs_car_swap_ammo"
		},
		{
			name = "CAR_SHIFT_UP",
			category = "LVS-Car",
			name_menu = "Shift Up",
			cmd = "lvs_car_shift_up"
		},
		{
			name = "CAR_SHIFT_DN",
			category = "LVS-Car",
			name_menu = "Shift Down",
			cmd = "lvs_car_shift_dn"
		},
	}

	for _, v in pairs( KEYS ) do
		LVS:AddKey( v.name, v.category, v.name_menu, v.cmd, v.default )
	end

	LVS.WHEELTYPE_NONE = 0
	LVS.WHEELTYPE_LEFT = 1
	LVS.WHEELTYPE_RIGHT = -1

	LVS.HITCHTYPE_NONE = -1
	LVS.HITCHTYPE_MALE = 0
	LVS.HITCHTYPE_FEMALE = 1

	LVS.SOUNDTYPE_NONE = 0
	LVS.SOUNDTYPE_IDLE_ONLY = 1
	LVS.SOUNDTYPE_REV_UP = 2
	LVS.SOUNDTYPE_REV_DOWN = 3
	LVS.SOUNDTYPE_REV_DN = 3
	LVS.SOUNDTYPE_ALL = 4

	LVS.FUELTYPE_PETROL = 0
	LVS.FUELTYPE_DIESEL = 1
	LVS.FUELTYPE_ELECTRIC = 2
	LVS.FUELTYPES = {
		[LVS.FUELTYPE_PETROL] = {
			name = "Petrol",
			color = Vector(240,200,0),
		},
		[LVS.FUELTYPE_DIESEL] = {
			name = "Diesel",
			color = Vector(255,60,0),
		},
		[LVS.FUELTYPE_ELECTRIC] = {
			name = "Electric",
			color = Vector(0,127,255),
		},
	}
end )

if SERVER then
	resource.AddWorkshop("3027255911")

	util.AddNetworkString( "lvs_car_turnsignal" )
	util.AddNetworkString( "lvs_car_break" )

	net.Receive( "lvs_car_turnsignal", function( len, ply )
		if not IsValid( ply ) then return end

		local veh = ply:lvsGetVehicle()

		if not IsValid( veh ) or veh:GetDriver() ~= ply then return end

		veh:SetTurnMode( net.ReadInt( 4 ) )
	end )

else
	net.Receive("lvs_car_break", function( len )
		local ent = net.ReadEntity()

		if not IsValid( ent ) or not isfunction( ent.OnEngineStallBroken ) then return end

		ent:OnEngineStallBroken()
	end)
end
