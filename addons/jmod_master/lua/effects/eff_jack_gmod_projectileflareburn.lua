-- "addons\\jmod_master\\lua\\effects\\eff_jack_gmod_projectileflareburn.lua"
-- Retrieved by https://github.com/lewisclark/glua-steal
﻿function EFFECT:Init(data)
	local vOffset = data:GetOrigin()
	local Scayul = data:GetScale()
	local Dir = data:GetNormal()
	local Vel = data:GetStart()
	local Scl = Scayul
	local Pos = vOffset
	if self:WaterLevel() == 3 then return end -- todo: bubbles
	local emitter = ParticleEmitter(vOffset)

	if emitter then
		for i = 0, 10 * Scayul ^ 0.5 do
			local Pos = data:GetOrigin()
			local particle = emitter:Add("sprites/mat_jack_nicespark", Pos)

			if particle then
				particle:SetVelocity((Dir + VectorRand() * .2) * math.random(10, 500) * Scayul + Vel)
				particle:SetLifeTime(0)
				particle:SetDieTime(math.Rand(0.1, 1.5))
				local herpdemutterfickendenderp = math.Rand(200, 255)
				particle:SetColor(255, herpdemutterfickendenderp - 10, herpdemutterfickendenderp - 20)
				particle:SetStartAlpha(255)
				particle:SetEndAlpha(0)
				particle:SetStartSize(1)
				particle:SetEndSize(0)
				particle:SetRoll(math.Rand(-360, 360))
				particle:SetRollDelta(math.Rand(-0.21, 0.21))
				particle:SetAirResistance(200)
				particle:SetGravity(Vector(0, 0, -600))
				particle:SetLighting(false)
				particle:SetCollide(true)
				particle:SetBounce(0.95)
			end
		end

		for i = 1, 4 * Scl do
			local ParticlePos = Pos + Dir
			local particle = emitter:Add("particle/smokestack", ParticlePos)
			particle:SetVelocity(Dir * math.random(50, 100) + VectorRand() * 10 + Vel / 2)
			particle:SetAirResistance(100)
			particle:SetGravity(Vector(0, 0, 100) + JMod.Wind * 300 + VectorRand() * 20)
			particle:SetDieTime(math.Rand(1, 10))
			particle:SetStartAlpha(math.random(50, 150))
			particle:SetEndAlpha(0)
			local Size = math.Rand(10, 50) * Scl
			particle:SetStartSize(Size / 4)
			particle:SetEndSize(Size)
			particle:SetRoll(math.Rand(-2, 2))
			particle:SetRollDelta(math.Rand(-2, 2))
			local Col = math.Rand(.8, 1.2)
			particle:SetColor(255, 100, 80)
			particle:SetLighting(math.random(1, 2) == 1)
			particle:SetCollide(false)
		end

		emitter:Finish()
	end
end

function EFFECT:Think()
	return false
end

function EFFECT:Render()
end
