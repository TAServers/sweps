ENT.Type = "point"
ENT.Base = "base_point"
ENT.Spawnable = false

local BURST_LIFETIME_SECS = 3
local BURST_SPEED_UNITS = 4140 -- In the direction of the burst each frame
local BURST_EXPLOSION_RADIUS_UNITS = 290
local BURST_PASSIVE_RADIUS_UNITS = 120 -- Used for passively pulling objects towards the burst as it's flying
local BURST_DAMAGE_HP = 70 -- Scaled by distance from explosion center
local BURST_TOSS_IMPULSE_MAGNITUDE = 62200 -- Hammer units
local BURST_PASSIVE_IMPULSE_MAGNITUDE = BURST_TOSS_IMPULSE_MAGNITUDE / 2 -- Hammer units, scaled down because it's passive (during flight)
local BURST_PLAYER_FORCE_MULTIPLIER = 0.4 -- Players weigh ~170lb, 85 kg and this is as about as heavy as a small desk in hl2 which can easily be tossed around. Basically the weight scale in HL2 is weird.

AccessorFunc(ENT, "weapon", "Weapon")
AccessorFunc(ENT, "timeCreated", "TimeCreated", FORCE_NUMBER)
AccessorFunc(ENT, "burstOwner", "BurstOwner")
AccessorFunc(ENT, "dir", "Dir")

local function calculateSpread()
	return VectorRand(-0.01, 0.01)
end

function MakeGravityBurst(pos, dir, owner, weapon)
	local ent = ents.Create("grav_blaster_burst")

	if not IsValid(ent) then
		return
	end

	ent:SetPos(pos)
	ent:SetDir(dir + calculateSpread())
	ent:SetBurstOwner(owner)
	ent:SetWeapon(weapon)
	ent:SetTimeCreated(CurTime())
	ent:Spawn()

	return ent
end

function ENT:Render()
	local fx = EffectData()
	fx:SetOrigin(self:GetPos())
	fx:SetNormal(self:GetDir())
	fx:SetRadius(8)

	util.Effect("RPGShotDown", fx)
	util.Effect("CommandPointer", fx)
end

function ENT:ApplyGravity(entity, magnitude)
	if not IsValid(entity) then
		return
	end

	local entityPhysics = entity:GetPhysicsObject()
	if not IsValid(entityPhysics) then
		return
	end

	local tossDirection = (entity:GetPos() - self:GetPos()):GetNormalized()
	local tossForce = tossDirection * magnitude * entityPhysics:GetMass() * engine.TickInterval()
	if entity:IsPlayer() then
		-- Can't use physics methods on a player, this actually adds velocity to the player
		entity:SetVelocity(tossForce * BURST_PLAYER_FORCE_MULTIPLIER)
	else
		-- And some random angular velocity for good measure
		entityPhysics:AddAngleVelocity(VectorRand(-50, 50))
		entityPhysics:ApplyForceOffset(tossForce, self:GetPos())
	end
end

function ENT:Explode()
	if not IsValid(self:GetWeapon()) or not IsValid(self:GetBurstOwner()) then
		return
	end

	util.BlastDamage(
		self:GetWeapon(),
		self:GetBurstOwner(),
		self:GetPos(),
		BURST_EXPLOSION_RADIUS_UNITS,
		BURST_DAMAGE_HP
	)

	local fx = EffectData()
	fx:SetOrigin(self:GetPos())

	util.Effect("Explosion", fx)

	-- Toss all props inwards and players away in the explosion radius
	local entities = ents.FindInSphere(self:GetPos(), BURST_EXPLOSION_RADIUS_UNITS)

	for _, entity in ipairs(entities) do
		self:ApplyGravity(entity, BURST_TOSS_IMPULSE_MAGNITUDE)
	end
end

function ENT:Update(dt)
	local timeElapsed = CurTime() - self:GetTimeCreated()
	if timeElapsed > BURST_LIFETIME_SECS then
		return true
	end

	-- check if the burst has collided
	local endPos = self:GetPos() + (self:GetDir() * BURST_SPEED_UNITS * dt)
	local trace = util.TraceLine({
		start = self:GetPos(),
		endpos = endPos,
		filter = {
			self:GetBurstOwner(),
		},
	})

	if trace and trace.Hit then
		return true
	end

	local entities = ents.FindInSphere(endPos, BURST_PASSIVE_RADIUS_UNITS)
	for _, entity in ipairs(entities) do
		if entity == self:GetBurstOwner() then
			continue
		end

		self:ApplyGravity(entity, BURST_PASSIVE_IMPULSE_MAGNITUDE)
	end

	self:SetPos(endPos)

	return false
end

function ENT:Think()
	self:Render()
	local collided = self:Update(FrameTime())
	if collided then
		self:Explode()
		self:Remove()
	end
	self:NextThink(CurTime())

	return true
end
