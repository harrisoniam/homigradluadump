-- "lua\\entities\\npc_fumo.lua"
-- Retrieved by https://github.com/lewisclark/glua-steal

AddCSLuaFile()

ENT.Base 			= "base_nextbot"

ENT.PhysgunDisabled = true
ENT.AutomaticFrameAdvance = false

util.PrecacheSound("fumo/jump.mp3")
util.PrecacheSound("fumo/panic.mp3")
util.PrecacheSound("fumo/spring.mp3")
util.PrecacheSound("fumo/stepitup.mp3")
util.PrecacheSound("fumo/tooslow.mp3")
util.PrecacheSound("fumo/tooeasy.mp3")
util.PrecacheSound("fumo/pieceofcake.mp3")

local IsValid = IsValid

if SERVER then -- SERVER --

local npc_fumo_acquire_distance = CreateConVar("npc_fumo_acquire_distance", 4500, bit.bor(FCVAR_GAMEDLL, FCVAR_DEMO, FCVAR_SERVER_CAN_EXECUTE),
                                                "The maximum distance at which fumo will chase a target.")

local npc_fumo_spawn_protect = CreateConVar("npc_fumo_spawn_protect", 0, bit.bor(FCVAR_GAMEDLL, FCVAR_DEMO, FCVAR_SERVER_CAN_EXECUTE),
                                             "If set to 1, fumo will not target players or hide within 200 units of a spawn point.")

local npc_fumo_attack_distance = CreateConVar("npc_fumo_attack_distance", 80, bit.bor(FCVAR_GAMEDLL, FCVAR_DEMO, FCVAR_SERVER_CAN_EXECUTE),
                                               "The reach of fumo's attack.")

local npc_fumo_attack_interval = CreateConVar("npc_fumo_attack_interval", 0.2, bit.bor(FCVAR_GAMEDLL, FCVAR_DEMO, FCVAR_SERVER_CAN_EXECUTE),
                                               "The delay between fumo's attacks.")

local npc_fumo_attack_force = CreateConVar("npc_fumo_attack_force", 800, bit.bor(FCVAR_GAMEDLL, FCVAR_DEMO, FCVAR_SERVER_CAN_EXECUTE),
                                            "The physical force of fumo's attack. Higher values throw things farther.")

local npc_fumo_smash_props = CreateConVar("npc_fumo_smash_props", 1, bit.bor(FCVAR_GAMEDLL, FCVAR_DEMO, FCVAR_SERVER_CAN_EXECUTE),
                                           "If set to 1, fumo will punch through any props placed in their way.")

local npc_fumo_hiding_scan_interval = CreateConVar("npc_fumo_hiding_scan_interval", 3, bit.bor(FCVAR_GAMEDLL, FCVAR_DEMO, FCVAR_SERVER_CAN_EXECUTE),
                                                    "fumo will only seek out hiding places every X seconds. This can be an expensive operation, so it is not " ..
                                                    "recommended to lower this too much. However, if distant fumos are not hiding from you quickly enough, " ..
                                                    "you may consider lowering this a small amount.")

local npc_fumo_hiding_repath_interval = CreateConVar("npc_fumo_hiding_repath_interval", 1, bit.bor(FCVAR_GAMEDLL, FCVAR_DEMO, FCVAR_SERVER_CAN_EXECUTE),
                                                      "The path to fumo's hiding spot will be redetermined every X seconds.")

local npc_fumo_chase_repath_interval = CreateConVar("npc_fumo_chase_repath_interval", 0.1, bit.bor(FCVAR_GAMEDLL, FCVAR_DEMO, FCVAR_SERVER_CAN_EXECUTE),
                                                     "The path to and position of fumo's target will be redetermined every X seconds.")

local npc_fumo_expensive_scan_interval = CreateConVar("npc_fumo_expensive_scan_interval", 1, bit.bor(FCVAR_GAMEDLL, FCVAR_DEMO, FCVAR_SERVER_CAN_EXECUTE),
                                                       "Slightly expensive operations (distance calculations and entity searching) will occur every X seconds.")

local npc_fumo_force_download = CreateConVar("npc_fumo_force_download", 1, bit.bor(FCVAR_GAMEDLL, FCVAR_DEMO, FCVAR_SERVER_CAN_EXECUTE, FCVAR_ARCHIVE),
                                              "If set to 1, clients will be forced to download fumo resources (restart required after changing).\n" ..
                                              "WARNING: If this is not set to 1, clients will not be able to see or hear fumo!")

 -- So we don't spam voice TOO much.
local TAUNT_INTERVAL = 1.2
local PATH_INFRACTION_LOCKOUT_TIME = 5

if (npc_fumo_force_download:GetBool()) then
	resource.AddWorkshop("174117071")
end

util.AddNetworkString("fumo_nag")
util.AddNetworkString("fumo_nagresponse")
util.AddNetworkString("fumo_navgen")

local trace = {
	mask = MASK_SOLID_BRUSHONLY -- Pathfinding is only concerned with static geometry anyway.
}

local function isPointNearSpawn(point, distance)
	--TODO: Is this a reliable standard??
	if (not GAMEMODE.SpawnPoints) then return false end

	local distanceSqr = (distance * distance)
	for _, spawnPoint in pairs(GAMEMODE.SpawnPoints) do
		if (not IsValid(spawnPoint)) then continue end

		if point:DistToSqr(spawnPoint:GetPos()) <= distanceSqr then
			return true
		end
	end

	return false
end

local function isPositionExposed(pos)
	for _, ply in pairs(player.GetAll()) do
		if (IsValid(ply) and ply:Alive() and ply:IsLineOfSightClear(pos)) then
			-- This spot can be seen!
			return true
		end
	end

	return false
end

local VECTOR_fumo_HEIGHT = Vector(0, 0, 96)
local function isPointSuitableForHiding(point)
	trace.start = point
	trace.endpos = point + VECTOR_fumo_HEIGHT
	local tr = util.TraceLine(trace)

	return (not tr.Hit)
end

local g_hidingSpots = nil
local function buildHidingSpotCache()
	local rStart = SysTime()

	g_hidingSpots = {}

	--BUG? navmesh.Find seems to dislike searching long distances. We need to start at ground level.
	local startPoint = (GAMEMODE.SpawnPoints and GAMEMODE.SpawnPoints[1] or nil)
	local startPos = nil
	if (IsValid(startPoint)) then
		startPos = startPoint:GetPos()
	else
		-- I hope this is ground level.
		local tr = util.QuickTrace(vector_origin, -vector_up * 16384)
		startPos = tr.HitPos
	end

	-- Look in every area on the navmesh for usable hiding places.
	-- Compile them into one nice list for lookup.
	local areas = navmesh.Find(startPos, 1e9, 16384, 16384)
	local goodSpots, badSpots = 0, 0
	for _, area in pairs(areas) do
		for _, hidingSpot in pairs(area:GetHidingSpots()) do
			if (isPointSuitableForHiding(hidingSpot)) then
				g_hidingSpots[goodSpots + 1] = {
					pos = hidingSpot,
					nearSpawn = isPointNearSpawn(hidingSpot, 200),
					occupant = nil
				}
				goodSpots = goodSpots + 1
			else
				badSpots = badSpots + 1
			end
		end
	end

	print(string.format("npc_fumo: found %d suitable (%d unsuitable) hiding places in %d areas over %.2fms!", goodSpots, badSpots, #areas, (SysTime() - rStart) * 1000))
end

local ai_ignoreplayers = GetConVar("ai_ignoreplayers")
local function isValidTarget(ent)
	-- Ignore non-existant entities.
	if (not IsValid(ent)) then return false end

	-- Ignore dead players (or all players if `ai_ignoreplayers' is 1)
	if (ent:IsPlayer()) then
		if (ai_ignoreplayers:GetBool()) then return false end
		return ent:Alive()
	end

	-- Ignore dead NPCs, other fumos, and dummy NPCs.
	local class = ent:GetClass()
	return (ent:IsNPC() and
	        ent:Health() > 0 and
	        class ~= "npc_fumo" and
	        not class:find("bullseye"))
end

--HACK!!! Because this is an issue a lot of people keep asking me about.
hook.Add("PlayerSpawnedNPC", "fumoMissingNavmeshNag", function(ply, ent)
	if (not IsValid(ent)) then return end
	if (ent:GetClass() ~= "npc_fumo") then return end
	if (navmesh.GetNavAreaCount() > 0) then return end
	if (ply.fumo_HasBeenNagged) then return end
	ply.fumo_HasBeenNagged = true

	-- Try to explain why fumo isn't working.
	net.Start("fumo_nag")
	net.Send(ply)
end)

local generateStart = 0
local function navEndGenerate()
	local timeElapsedStr = string.NiceTime(SysTime() - generateStart)

	if (not navmesh.IsGenerating()) then
		print("npc_fumo: Navmesh generation completed in " .. timeElapsedStr)
	else
		print("npc_fumo: Navmesh generation aborted after " .. timeElapsedStr)
	end
end

net.Receive("fumo_nagresponse", function(len, ply)
	if (net.ReadBit() == 0) then
		ply.fumo_HasBeenNagged = false
		return
	end

	if (not game.SinglePlayer()) then return end

	local spawnPoint = (GAMEMODE.SpawnPoints and GAMEMODE.SpawnPoints[1] or nil)
	if (not IsValid(spawnPoint)) then
		net.Start("fumo_navgen")
			net.WriteBit(false)
		net.Send(ply)

		return
	end

	-- The least we can do is ensure they don't have to listen to this noise.
	for _, fumo in pairs(ents.FindByClass("npc_fumo")) do
		fumo:Remove()
	end

	print("npc_fumo: Beginning nav_generate requested by " .. ply:Name())

	navmesh.SetPlayerSpawnName(spawnPoint:GetClass())
	navmesh.BeginGeneration()

	if (navmesh.IsGenerating()) then
		generateStart = SysTime()
		hook.Add("ShutDown", "fumoNavGen", navEndGenerate)
	else
		print("npc_fumo: nav_generate failed to initialize")
	end

	net.Start("fumo_navgen")
		net.WriteBit(navmesh.IsGenerating())
	net.Send(ply)
end)

ENT.LastPathRecompute = 0
ENT.LastTargetSearch = 0
ENT.LastJumpScan = 0
ENT.LastCeilingUnstick = 0
ENT.LastAttack = 0
ENT.LastHidingPlaceScan = 0
ENT.LastTaunt = 0

ENT.CurrentTarget = nil
ENT.HidingSpot = nil

function ENT:Initialize()
	-- Spawn effect resets render override. Bug!!!
	self:SetSpawnEffect(false)

	self:SetBloodColor(DONT_BLEED)

	-- Just in case.
	self:SetHealth(1e8)

	--self:DrawShadow(false) -- Why doesn't this work???

	self:SetRenderMode(RENDERMODE_TRANSALPHA)
	self:SetColor(Color(255, 255, 255, 1)) --HACK!!! Disables shadow (for real).

	-- Human-sized collision.
	self:SetCollisionBounds(Vector(-13, -13, 0), Vector(13, 13, 72))

	-- We're a little timid on drops... Give the player a chance. :)
	self.loco:SetDeathDropHeight(600)

	-- In Sandbox, players are faster in singleplayer.
	self.loco:SetDesiredSpeed(game.SinglePlayer() and 650 or 500)

	-- Take corners a bit sharp.
	self.loco:SetAcceleration(550)
	self.loco:SetDeceleration(500)

	-- This isn't really important because we reset it all the time anyway.
	self.loco:SetJumpHeight(300)

	-- Rebuild caches.
	self:OnReloaded()
end

function ENT:OnInjured(dmg)
	-- Just in case.
	dmg:SetDamage(0)
end

function ENT:OnReloaded()
	if (g_hidingSpots == nil) then
		buildHidingSpotCache()
	end
end

function ENT:OnRemove()
	-- Give up our hiding spot when we're deleted.
	self:ClaimHidingSpot(nil)
end

function ENT:GetNearestTarget()
	--local timeRoutine = SysTime()

	-- Only target entities within the acquire distance.
	local maxAcquireDist = npc_fumo_acquire_distance:GetInt()
	local maxAcquireDistSqr = (maxAcquireDist * maxAcquireDist)
	local myPos = self:GetPos()
	local acquirableEntities = ents.FindInSphere(myPos, maxAcquireDist)
	local distToSqr = myPos.DistToSqr
	local getPos = self.GetPos
	local target = nil
	local getClass = self.GetClass

	for _, ent in pairs(acquirableEntities) do
		-- Ignore invalid targets, of course.
		if (not isValidTarget(ent)) then continue end

		-- Spawn protection! Ignore players within 200 units of a spawn point if `npc_fumo_spawn_protect' = 1.
		--TODO: Only for the first few seconds?
		if (npc_fumo_spawn_protect:GetBool() and ent:IsPlayer() and isPointNearSpawn(ent:GetPos(), 200)) then
			continue
		end

		-- Find the nearest target to chase.
		local distSqr = distToSqr(getPos(ent), myPos)
		if (distSqr < maxAcquireDistSqr) then
			target = ent
			maxAcquireDistSqr = distSqr
		end
	end

	--timeRoutine = SysTime() - timeRoutine
	--print(string.format("GetNearestTarget() took %.2fms", timeRoutine * 1000))

	return target
end

--TODO: Giant ugly monolith of a function eww eww eww.
function ENT:AttackNearbyTargets(radius)
	local hitSource = self:LocalToWorld(self:OBBCenter())
	local nearEntities = ents.FindInSphere(hitSource, radius)
	local hit = false
	for _, ent in pairs(nearEntities) do
		if (isValidTarget(ent)) then
			local health = ent:Health()

			if (ent:IsPlayer() and IsValid(ent:GetVehicle())) then
				-- Hiding in a vehicle, eh?
				local vehicle = ent:GetVehicle()

				local vehiclePos = vehicle:LocalToWorld(vehicle:OBBCenter())
				local hitDirection = (vehiclePos - hitSource):GetNormal()

				-- Give it a good whack.
				local phys = vehicle:GetPhysicsObject()
				if (IsValid(phys)) then
					phys:Wake()
					local hitOffset = vehicle:NearestPoint(hitSource)
					phys:ApplyForceOffset(hitDirection * (npc_fumo_attack_force:GetInt() * phys:GetMass()), hitOffset)
				end
				vehicle:TakeDamage(math.max(1e8, ent:Health()), self, self)

				-- Oh, and make a nice SMASH noise.
				vehicle:EmitSound(string.format("physics/metal/metal_sheet_impact_hard%d.wav", math.random(6, 8)), 350, 120)
			else
				ent:EmitSound(string.format("physics/body/body_medium_impact_hard%d.wav", math.random(1, 6)), 350, 120)
			end

			local hitDirection = (ent:GetPos() - hitSource):GetNormal()
			-- Give the player a good whack. fumo means business.
			-- This is for those with god mode enabled.
			ent:SetVelocity(hitDirection * npc_fumo_attack_force:GetInt() + vector_up * 500)

			local dmgInfo = DamageInfo()
			dmgInfo:SetAttacker(self)
			dmgInfo:SetInflictor(self)
			dmgInfo:SetDamage(1e8)
			dmgInfo:SetDamagePosition(self:GetPos())
			dmgInfo:SetDamageForce((hitDirection * npc_fumo_attack_force:GetInt() + vector_up * 500) * 100)
			ent:TakeDamageInfo(dmgInfo)
			--ent:TakeDamage(math.max(1e8, ent:Health()), self, self)

			local newHealth = ent:Health()

			-- Hits only count if we dealt some damage.
			hit = (hit or (newHealth < health))
		elseif (ent:GetMoveType() == MOVETYPE_VPHYSICS) then
			if (not npc_fumo_smash_props:GetBool()) then continue end
			if (ent:IsVehicle() and IsValid(ent:GetDriver())) then continue end

			-- Knock away any props put in our path.
			local entPos = ent:LocalToWorld(ent:OBBCenter())
			local hitDirection = (entPos - hitSource):GetNormal()
			local hitOffset = ent:NearestPoint(hitSource)

			-- Remove anything tying the entity down. We're crashing through here!
			constraint.RemoveAll(ent)

			-- Get the object's mass.
			local phys = ent:GetPhysicsObject()
			local mass = 0
			local material = "Default"
			if (IsValid(phys)) then
				mass = phys:GetMass()
				material = phys:GetMaterial()
			end

			-- Don't make a noise if the object is too light. It's probably a gib.
			if (mass >= 5) then
				ent:EmitSound(material .. ".ImpactHard", 350, 120)
			end

			-- Unfreeze all bones, and give the object a good whack.
			for id = 0, ent:GetPhysicsObjectCount() - 1 do
				local phys = ent:GetPhysicsObjectNum(id)
				if (IsValid(phys)) then
					phys:EnableMotion(true)
					phys:ApplyForceOffset(hitDirection * (npc_fumo_attack_force:GetInt() * mass), hitOffset)
				end
			end

			-- Deal some solid damage, too.
			ent:TakeDamage(25, self, self)
		end
	end

	return hit
end

function ENT:IsHidingSpotFull(hidingSpot)
	-- It's not full if there's no occupant, or we're the one in it.
	local occupant = hidingSpot.occupant
	if (not IsValid(occupant) or occupant == self) then
		return false
	end

	return true
end

--TODO: Weight spots based on how many people can see them.
function ENT:GetNearestUsableHidingSpot()
	--local timeRoutine = SysTime()

	local nearestHidingSpot = nil
	local nearestHidingDistSqr = 1e8

	local myPos = self:GetPos()
	local isHidingSpotFull = self.IsHidingSpotFull
	local distToSqr = myPos.DistToSqr
	--local scans = 0

	-- This could be a long loop. Optimize the heck out of it.
	for _, hidingSpot in pairs(g_hidingSpots) do
		-- Ignore hiding spots that are near spawn, or full.
		if (hidingSpot.nearSpawn or isHidingSpotFull(self, hidingSpot)) then
			continue
		end

		local hidingSpotDistSqr = distToSqr(hidingSpot.pos, myPos)
		if (hidingSpotDistSqr < nearestHidingDistSqr) then --TODO: Still disallow spawn hiding places?
			--scans = scans + 1
			if (not isPositionExposed(hidingSpot.pos)) then
				nearestHidingDistSqr = hidingSpotDistSqr
				nearestHidingSpot = hidingSpot
			end
		end
	end

	--timeRoutine = SysTime() - timeRoutine
	--print(string.format("GetNearestHidingSpot() took %.2fms, scanned %d times, %s", timeRoutine * 1000, scans, self.HidingSpot == nearestHidingSpot and "position did not change." or "new hiding place!"))

	return nearestHidingSpot
end

function ENT:ClaimHidingSpot(hidingSpot)
	-- Release our claim on the old spot.
	if (self.HidingSpot ~= nil) then
		self.HidingSpot.occupant = nil
	end

	-- Can't claim something that doesn't exist,
	-- or a spot that's already claimed.
	if (hidingSpot == nil or self:IsHidingSpotFull(hidingSpot)) then
		self.HidingSpot = nil
		return false
	end

	-- Yoink.
	self.HidingSpot = hidingSpot
	self.HidingSpot.occupant = self
	return true
end

function ENT:AttemptJumpAtTarget()
	if (not self:IsOnGround()) then return end

	local xyDistSqr = (self.CurrentTarget:GetPos() - self:GetPos()):Length2DSqr()
	local zDifference = self.CurrentTarget:GetPos().z - self:GetPos().z
	local maxAttackDistance = npc_fumo_attack_distance:GetInt()
	if (xyDistSqr <= math.pow(maxAttackDistance + 200, 2) and zDifference >= maxAttackDistance) then
		--TODO: Set up jump so target lands on parabola.
		local jumpHeight = zDifference + 50
		self.loco:SetJumpHeight(jumpHeight)
		self.loco:Jump()
		self.loco:SetJumpHeight(300)

		self:EmitSound((jumpHeight > 500 and "fumo/spring.mp3" or "fumo/jump.mp3"), 350, 100)
	end
end

local VECTOR_HIGH = Vector(0, 0, 16384)
ENT.LastPathingInfraction = 0
function ENT:RecomputeTargetPath()
	if (CurTime() - self.LastPathingInfraction < PATH_INFRACTION_LOCKOUT_TIME) then
		-- No calculations for you today.
		return
	end

	local targetPos = self.CurrentTarget:GetPos()

	-- Run toward the position below the entity we're targetting, since we can't fly.
	trace.start = targetPos
	trace.endpos = targetPos - VECTOR_HIGH
	trace.filter = self.CurrentTarget
	local tr = util.TraceEntity(trace, self.CurrentTarget)

	-- Of course, we sure that there IS a "below the target."
	if (tr.Hit and util.IsInWorld(tr.HitPos)) then
		targetPos = tr.HitPos
	end

	local rTime = SysTime()
	self.MovePath:Compute(self, targetPos)

	--HACK!!! Workaround for the navmesh pathing bug.
	-- If path computation takes longer than 5ms (A LONG TIME),
	-- disable computation for a little while for this bot.
	if (SysTime() - rTime > 0.005) then
		self.LastPathingInfraction = CurTime()
	end
end

function ENT:BehaveStart()
	self.MovePath = Path("Follow")
	self.MovePath:SetMinLookAheadDistance(500)
	self.MovePath:SetGoalTolerance(10)
end

local tauntSounds = {
	"fumo/tooslow.mp3",
	"fumo/stepitup.mp3",
	"fumo/tooeasy.mp3",
	"fumo/pieceofcake.mp3"
}
local ai_disabled = GetConVar("ai_disabled")
--local timeAll = 0
--local numThink = 0
function ENT:BehaveUpdate() --TODO: Split this up more. Eww.
	if (ai_disabled:GetBool()) then
		-- We may be a bot, but we're still an "NPC" at heart.
		return
	end

	local currentTime = CurTime()
	--local timeRoutine = SysTime()

	if (currentTime - self.LastTargetSearch > npc_fumo_expensive_scan_interval:GetFloat()) then
		local target = self:GetNearestTarget()

		if (target ~= self.CurrentTarget) then
			-- We have a new target! Figure out a new path immediately.
			self.LastPathRecompute = 0
		end

		self.CurrentTarget = target
		self.LastTargetSearch = currentTime
	end

	-- Do we have a target?
	if (IsValid(self.CurrentTarget)) then
		-- Be ready to repath to a hiding place as soon as we lose target.
		self.LastHidingPlaceScan = 0

		-- Attack anyone nearby while we're rampaging.
		if (currentTime - self.LastAttack > npc_fumo_attack_interval:GetFloat()) then
			if (self:AttackNearbyTargets(npc_fumo_attack_distance:GetInt())) then
				if (currentTime - self.LastTaunt > TAUNT_INTERVAL) then
					self.LastTaunt = currentTime
					self:EmitSound(table.Random(tauntSounds), 350, 100)
				end

				-- Immediately look for another target.
				self.LastTargetSearch = 0
			end

			self.LastAttack = currentTime
		end

		-- Recompute the path to the target every so often.
		if (currentTime - self.LastPathRecompute > npc_fumo_chase_repath_interval:GetFloat()) then
			self.LastPathRecompute = currentTime
			self:RecomputeTargetPath()
		end

		-- Move!
		self.MovePath:Update(self)

		-- Try to jump at a target in the air.
		if (self:IsOnGround()) then
			if (currentTime - self.LastJumpScan >= npc_fumo_expensive_scan_interval:GetFloat()) then
				self:AttemptJumpAtTarget()
				self.LastJumpScan = currentTime
			end
		end
	else
		if (currentTime - self.LastHidingPlaceScan >= npc_fumo_hiding_scan_interval:GetFloat()) then
			self.LastHidingPlaceScan = currentTime

			-- Grab a new hiding spot.
			local hidingSpot = self:GetNearestUsableHidingSpot()
			self:ClaimHidingSpot(hidingSpot)
		end

		if (self.HidingSpot ~= nil) then
			if (currentTime - self.LastPathRecompute >= npc_fumo_hiding_repath_interval:GetFloat()) then
				self.LastPathRecompute = currentTime
				self.MovePath:Compute(self, self.HidingSpot.pos)
			end
			self.MovePath:Update(self)
		else
			--TODO: Wander if we didn't find a place to hide. Preferably AWAY from spawn points.
		end
	end

	-- Don't even wait until the STUCK flag is set for this. It's much more fluid this way.
	if (currentTime - self.LastCeilingUnstick >= npc_fumo_expensive_scan_interval:GetFloat()) then
		self:UnstickFromCeiling()

		self.LastCeilingUnstick = currentTime
	end

	if (currentTime - self.LastStuck >= 5) then
		self.StuckTries = 0
	end

	--timeRoutine = SysTime() - timeRoutine
	--print(string.format("RunBehavior() took %.2fms", timeRoutine * 1000))

	--timeAll = timeAll + timeRoutine
	--numThink = numThink + 1
end

--[[local lastFrame = 0
local fumosLastFrame = 0
hook.Add("Tick", "fumoBenchmark", function()
	local now = SysTime()
	local numfumos = #ents.FindByClass("npc_fumo")

	if (timeAll ~= 0) then

		local fumoTime = timeAll * 1000
		local frameTime = (now - lastFrame) * 1000
		print(string.format("RunBehaviour() avg %.2fms total %.2fms (%.2fms frame, ratio %.2f%%) (%d exist, %d thinking (%.2f%%))",
		                    fumoTime / fumosLastFrame, fumoTime, frameTime, (fumoTime / frameTime) * 100, fumosLastFrame, numThink, (numThink / fumosLastFrame) * 100))
		timeAll = 0
		numThink = 0
	end

	lastFrame = now
	fumosLastFrame = numfumos
end)]]

ENT.LastStuck = 0
ENT.StuckTries = 0
function ENT:OnStuck()
	-- Jump forward a bit on the path.
	self.LastStuck = CurTime()
	self:SetPos(self.MovePath:GetPositionOnPath(self.MovePath:GetCursorPosition() + 40 * math.pow(2, self.StuckTries)))
	self.StuckTries = self.StuckTries + 1

	-- Hope that we're not stuck anymore.
	self.loco:ClearStuck()
end

function ENT:UnstickFromCeiling()
	if (self:IsOnGround()) then return end

	-- NextBots LOVE to get stuck. Stuck in the morning. Stuck in the evening. Stuck in the ceiling. Stuck on each other.
	-- The stuck never ends.
	local myPos = self:GetPos()
	local myHullMin, myHullMax = self:GetCollisionBounds()
	local myHull = (myHullMax - myHullMin)
	local myHullTop = myPos + vector_up * myHull.z
	trace.start = myPos
	trace.endpos = myHullTop
	trace.filter = self
	local upTrace = util.TraceLine(trace, self)

	if (upTrace.Hit and upTrace.HitNormal ~= vector_origin and upTrace.Fraction > 0.5) then
		local unstuckPos = myPos + upTrace.HitNormal * (myHull.z * (1 - upTrace.Fraction))
		self:SetPos(unstuckPos)
	end
end

else -- CLIENT --

killicon.Add("npc_fumo", "fumo/npc_fumo_killicon", color_white)
language.Add("npc_fumo", "Sanic.png ")

ENT.RenderGroup = RENDERGROUP_TRANSLUCENT

local developer = GetConVar("developer")
local function DevPrint(devLevel, msg)
	if (developer:GetInt() >= devLevel) then
		print("npc_fumo: " .. msg)
	end
end

local panicMusic = nil
local lastPanic = 0 -- The last time we were in music range of a fumo.

--TODO: Why don't these flags show up? Bug? Documentation would be lovely.
local npc_fumo_music_volume = CreateConVar("npc_fumo_music_volume", 1, bit.bor(FCVAR_CLIENTDLL, FCVAR_DEMO, FCVAR_ARCHIVE),
                                            "Maximum music volume when being chased by fumo. (0-1, where 0 is muted)")

local MUSIC_RESTART_DELAY = 2 -- If another fumo comes in range before this delay is up, the music will continue where it left off.

local MUSIC_CUTOFF_DISTANCE   = 1000 -- Beyond this distance, fumos do not count to music volume.
local MUSIC_PANIC_DISTANCE    = 1000 -- Max volume is achieved when MUSIC_fumo_PANIC_COUNT fumos are this close, or an equivalent score.
local MUSIC_fumo_PANIC_COUNT = 8 -- That's a lot of fumo.

local MUSIC_fumo_MAX_DISTANCE_SCORE = (MUSIC_CUTOFF_DISTANCE - MUSIC_PANIC_DISTANCE) * MUSIC_fumo_PANIC_COUNT

local function updatePanicMusic()
	if (#ents.FindByClass("npc_fumo") == 0) then
		-- Whoops. No need to run for now.
		DevPrint(4, "Halting music timer.")
		timer.Remove("fumoPanicMusicUpdate")

		if (panicMusic ~= nil) then
			panicMusic:Stop()
		end

		return
	end

	if (panicMusic == nil) then
		if (IsValid(LocalPlayer())) then
			panicMusic = CreateSound(LocalPlayer(), "fumo/panic.mp3")
			panicMusic:Stop()
		else
			return -- No LocalPlayer yet!
		end
	end

	if (npc_fumo_music_volume:GetFloat() <= 0 or not IsValid(LocalPlayer())) then
		panicMusic:Stop()
		return
	end

	local totalDistanceScore = 0
	local nearEntities = ents.FindInSphere(LocalPlayer():GetPos(), 1000)
	for _, ent in pairs(nearEntities) do
		if (IsValid(ent) and ent:GetClass() == "npc_fumo") then
			local distanceScore = math.max(0, MUSIC_CUTOFF_DISTANCE - LocalPlayer():GetPos():Distance(ent:GetPos()))
			totalDistanceScore = totalDistanceScore + distanceScore
		end
	end

	local musicVolume = math.min(1, totalDistanceScore / MUSIC_fumo_MAX_DISTANCE_SCORE)

	local shouldRestartMusic = (CurTime() - lastPanic >= MUSIC_RESTART_DELAY)
	if (musicVolume > 0) then
		if (shouldRestartMusic) then
			panicMusic:Play()
		end

		if (not LocalPlayer():Alive()) then
			-- Quiet down so we can hear fumo taunt us.
			musicVolume = musicVolume / 4
		end

		lastPanic = CurTime()
	elseif (shouldRestartMusic) then
		panicMusic:Stop()
		return
	else
		musicVolume = 0
	end

	musicVolume = math.max(0.01, musicVolume * math.Clamp(npc_fumo_music_volume:GetFloat(), 0, 1))

	panicMusic:Play()
	panicMusic:ChangePitch(math.Clamp(game.GetTimeScale() * 100, 50, 255), 0) -- Just for kicks.
	panicMusic:ChangeVolume(musicVolume, 0)
end

local function startTimer()
	if (not timer.Exists("fumoPanicMusicUpdate")) then
		timer.Create("fumoPanicMusicUpdate", 0.05, 0, updatePanicMusic)
		DevPrint(4, "Beginning music timer.")
	end
end

local fumoMaterial = Material("fumo/npc_fumo.png", "smooth mips")
local drawOffset = Vector(0, 0, 64)
function ENT:RenderOverride()
	render.SetMaterial(fumoMaterial)
	render.DrawSprite(self:GetPos() + drawOffset, 128, 128)
end

function ENT:OnReloaded()
	startTimer()
end

-- Here begins ugly hacky code because AIs don't have a clientside SEnt part. (WHY NOT????) ---

hook.Add("OnEntityCreated", "fumoInitialize", function(ent)
	if (not IsValid(ent)) then return end
	if (ent:GetClass() ~= "npc_fumo") then return end

	local fumoEntTable = scripted_ents.GetStored("npc_fumo")

	table.Merge(ent, fumoEntTable.t) --HACK!!! Because this isn't done for us.
	ent:CallOnRemove("fumo_removed", fumoDeregister)
end)

hook.Add("NetworkEntityCreated", "fumoNetInit", function(ent)
	if (not IsValid(ent)) then return end
	if (ent:GetClass() ~= "npc_fumo") then return end

	startTimer()
end)

surface.CreateFont("fumoHUD", {
	font = "Arial",
	size = 56
})

surface.CreateFont("fumoHUDSmall", {
	font = "Arial",
	size = 24
})

local function string_ToHMS(seconds)
	local hours = math.floor(seconds / 3600)
	local minutes = math.floor((seconds / 60) % 60)
	local seconds = math.floor(seconds % 60)

	if (hours > 0) then
		return string.format("%02d:%02d:%02d", hours, minutes, seconds)
	else
		return string.format("%02d:%02d", minutes, seconds)
	end
end

local flavourTexts = {
	{
		"Gotta learn fast!",
		"Learning this'll be a piece of cake!",
		"This is too easy."
	}, {
		"This must be a big map.",
		"This map is a bit bigger than I thought.",
	}, {
		"Just how big is this place?",
		"This place is pretty big."
	}, {
		"This place is enormous!",
		"A guy could get lost around here."
	}, {
		"Surely I'm almost done...",
		"There can't be too much more...",
		"This isn't gm_bigcity, is it?",
		"Is it over yet?",
		"You never told me the map was this big!"
	}
}
local SECONDS_PER_BRACKET = 300 -- 5 minutes
local color_yellow = Color(255, 255, 80)
local flavourText = ""
local lastBracket = 0
local generateStart = 0
local function navGenerateHUDOverlay()
	draw.SimpleTextOutlined("fumo is studying this map.", "fumoHUD", ScrW() / 2, ScrH() / 2, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP, 2, color_black)
	draw.SimpleTextOutlined("Please wait...", "fumoHUD", ScrW() / 2, ScrH() / 2, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM, 2, color_black)

	local elapsed = (SysTime() - generateStart)
	local elapsedStr = string_ToHMS(elapsed)
	draw.SimpleTextOutlined("Time Elapsed:", "fumoHUDSmall", ScrW() / 2, ScrH() * 3/4, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP, 1, color_black)
	draw.SimpleTextOutlined(elapsedStr, "fumoHUDSmall", ScrW() / 2, ScrH() * 3/4, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM, 1, color_black)

	-- It's taking a while.
	local textBracket = math.floor(elapsed / SECONDS_PER_BRACKET) + 1
	if (textBracket ~= lastBracket) then
		flavourText = table.Random(flavourTexts[math.min(5, textBracket)])
		lastBracket = textBracket
	end
	draw.SimpleTextOutlined(flavourText, "fumoHUDSmall", ScrW() / 2, ScrH() * 4/5, color_yellow, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, color_black)
end

net.Receive("fumo_navgen", function()
	if (net.ReadBit() == 1) then
		generateStart = SysTime()
		lastBracket = 0
		hook.Add("HUDPaint", "fumoNavGenOverlay", navGenerateHUDOverlay)
	else
		Derma_Message([[Oh no. fumo doesn't even know where to start with this map.
If you're not running the Sandbox gamemode, switch to that and try again.]],
		              "Error!")
	end
end)

local function navGenerate()
	net.Start("fumo_nagresponse")
		net.WriteBit(true)
	net.SendToServer()
end

local function nagAgain()
	net.Start("fumo_nagresponse")
		net.WriteBit(false)
	net.SendToServer()
end

local function navWarning()
	Derma_Query([[It will take a while for fumo to figure this map out.
While he's studying it, you won't be able to play,
and the game will run very slowly.

Also note that THE MAP WILL BE RESTARTED.
Anything you have placed will be deleted.]],
		            "Warning!",
		            "Go ahead!", navGenerate,
		            "Not right now.", nagAgain)
end

-- Lazy
net.Receive("fumo_nag", function()
	if (game.SinglePlayer()) then
		Derma_Query([[Uh oh! fumo doesn't know this map.
Would you like fumo to learn it?]],
		            "This map is currently not fumo-compatible!",
		            "Yes", navWarning,
		            "No", nagAgain,
		            "No. Do not ask again.")
	else
		Derma_Query([[Uh oh! fumo doesn't know this map. He won't be able to move!
Because you're not in a single-player game, he isn't able to learn it.

Ask the server host about teaching this map to fumo.]],
		            "This map is currently not fumo-compatible!",
		            "Ok", nagAgain,
		            "Ok. Don't say this again.")
	end
end)

end

--
-- List the NPC as spawnable.
--
list.Set("NPC", "npc_fumo", {
	Name = "Sanic.png",
	Class = "npc_fumo",
	Category = "SANIC.PNG",
	AdminOnly = true
})
