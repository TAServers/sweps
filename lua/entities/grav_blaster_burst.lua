if SERVER then
	AddCSLuaFile()
end

ENT.Type = "anim"
ENT.Base = "base_anim"
ENT.Spawnable = false

ENT.LifetimeSeconds = 3
ENT.SpeedHammerUnits = 4140
-- TODO: Change everything to the per-ent ones and make radius also per-ent
local BURST_EXPLOSION_RADIUS_HAMMER_UNITS = 290
local BURST_PASSIVE_RADIUS_HAMMER_UNITS = 120
ENT.ExplosionDamageHP = 70
local BURST_TOSS_IMPULSE_MAGNITUDE = 62200
local BURST_PASSIVE_IMPULSE_MAGNITUDE = BURST_TOSS_IMPULSE_MAGNITUDE / 2
local BURST_PLAYER_FORCE_MULTIPLIER = 0.07

local function calculateSpread()
	return VectorRand(-0.01, 0.01)
end

function MakeGravityBurst(pos, dir, owner, weapon)
	local ent = ents.Create("grav_blaster_burst")

	if not IsValid(ent) then
		return
	end

	ent:SetPos(pos)
	ent.dir = dir + calculateSpread()
	ent.burstOwner = owner
	ent.weapon = weapon
	ent.expireTime = CurTime() + BURST_LIFETIME_SECS
	ent:Initialize()
	ent:Spawn()

	return ent
end

if CLIENT then
	local heatwaveMaterial = Material("sprites/heatwave")
	local glowMaterial = Material("sprites/redglow1")
	function ENT:Draw()
		render.SetMaterial(heatwaveMaterial)
		render.DrawSprite(self:GetPos(), 64, 64, color_white)
		render.SetMaterial(glowMaterial)
		render.DrawSprite(self:GetPos(), 64, 64, color_white)

		local light = DynamicLight(self:EntIndex())
		if light then
			light.pos = self:GetPos()
			light.r = 255
			light.g = 80
			light.b = 0
			light.brightness = 3
			light.Decay = 1000
			light.Size = 512
			light.DieTime = CurTime() + 0.1
		end
	end

	return
end

function ENT:Initialize()
	-- We use the helicoptor bomb model cause it's a decent sphere with the right size
	self:SetModel("models/props_combine/combine_mine01.mdl")
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetCollisionGroup(COLLISION_GROUP_PROJECTILE)
	self:PhysicsInitSphere(8, "metal_bouncy")

	local phys = self:GetPhysicsObject()
	if not IsValid(phys) then
		error("Failed to initialize physics for grav_blaster_burst")
	end

	phys:Wake()
	phys:SetVelocity(self.dir * BURST_SPEED_HAMMER_UNITS)
	phys:SetMass(1)
	-- No drag
	phys:SetDamping(0, 0)
end

local function applyBurstImpulse(burstPosition, entity, magnitude)
	if not IsValid(entity) then
		return
	end

	local entityPhysics = entity:GetPhysicsObject()
	if not IsValid(entityPhysics) then
		return
	end

	local tossDirection = (entity:GetPos() - burstPosition):GetNormalized()
	local tossImpulse = tossDirection * magnitude * entityPhysics:GetMass() * engine.TickInterval()
	if entity:IsPlayer() then
		entity:SetVelocity(tossImpulse * BURST_PLAYER_FORCE_MULTIPLIER)
	else
		entityPhysics:AddAngleVelocity(VectorRand(-50, 50))
		entityPhysics:ApplyForceOffset(tossImpulse, burstPosition)
	end
end

function ENT:Explode()
	if not IsValid(self.weapon) or not IsValid(self.burstOwner) then
		return
	end

	util.BlastDamage(self.weapon, self.burstOwner, self:GetPos(), BURST_EXPLOSION_RADIUS_HAMMER_UNITS, BURST_DAMAGE_HP)

	local fx = EffectData()
	fx:SetOrigin(self:GetPos())
	util.Effect("Explosion", fx)

	for _, entity in ipairs(ents.FindInSphere(self:GetPos(), BURST_EXPLOSION_RADIUS_HAMMER_UNITS)) do
		if entity ~= self then
			applyBurstImpulse(self:GetPos(), entity, BURST_TOSS_IMPULSE_MAGNITUDE)
		end
	end

	self:Remove()
end

function ENT:HasExpired()
	return CurTime() >= self.expireTime
end

function ENT:ApplyPassiveForce()
	for _, entity in ipairs(ents.FindInSphere(self:GetPos(), BURST_PASSIVE_RADIUS_HAMMER_UNITS)) do
		if entity ~= self.burstOwner and entity ~= self then
			applyBurstImpulse(self:GetPos(), entity, BURST_PASSIVE_IMPULSE_MAGNITUDE)
		end
	end
end

function ENT:PhysicsCollide()
	self:Explode()
end

function ENT:Think()
	if self:HasExpired() then
		self:Explode()
		return
	end

	self:ApplyPassiveForce()
end
