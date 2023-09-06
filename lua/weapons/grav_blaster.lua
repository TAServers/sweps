if SERVER then
	resource.AddSingleFile("materials/entities/grav_blaster.png")
	AddCSLuaFile()
end

SWEP.PrintName = "Grav Blaster"
SWEP.Category = TASWeapons.Category
SWEP.Author = "yogwoggf"
SWEP.Instructions = [[Left click to shoot a burst of gravity which knocks away other players and props.
Uses combine ball ammunition.
Strat: Jump and shoot at the ground to propel yourself into the air. You will be hurt though!]]

SWEP.Spawnable = true

SWEP.Primary.ClipSize = 8
SWEP.Primary.DefaultClip = 8
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = "AR2AltFire"

SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = true
SWEP.Secondary.Ammo = "none"

SWEP.Weight = 5
SWEP.AutoSwitchTo = false
SWEP.AutoSwitchFrom = false

SWEP.Slot = 2
SWEP.SlotPos = 1

SWEP.DrawAmmo = true
SWEP.DrawCrosshair = true
SWEP.UseHands = true
SWEP.ViewModelFOV = 50

SWEP.ViewModel = Model("models/weapons/c_physcannon.mdl")
SWEP.WorldModel = Model("models/weapons/w_physics.mdl")

SWEP.ShootSound = Sound("weapons/physcannon/energy_disintegrate4.wav")
SWEP.LoadSound = Sound("weapons/physcannon/physcannon_charge.wav")
-- Sound actually ends at 1.5 seconds but has an extra second of nothing.
-- Also, SoundDuration is known to be unstable on Linux.
SWEP.LoadSoundDurationSecs = 1.5

SWEP.PrimaryRateOfFire = 1.5 -- Per second
local BURST_LIFETIME_SECS = 3
local BURST_SPEED_UNITS = 140 -- In the direction of the burst each frame
local BURST_EXPLOSION_RADIUS_UNITS = 190
local BURST_PASSIVE_RADIUS_UNITS = 120 -- Used for passively pulling objects towards the burst as it's flying
local BURST_DAMAGE_HP = 70 -- Scaled by distance from explosion center
local BURST_TOSS_IMPULSE_MAGNITUDE = 1200 -- arbitrary units
local BURST_PASSIVE_IMPULSE_MAGNITUDE = 180 -- arbitrary units, scaled down because it's passive
local BURST_PUNCH_ANGLE = Angle(-3, -0.6, -0.3) -- Determines how strong the punch is on each axis
local BURST_VIEWMODEL_ANGLE = Angle(0, 0, -15) -- Determines how much the viewmodel is rotated

local globalBursts = {}

local function calculateSpread()
	return VectorRand(-0.01, 0.01)
end

local function makeBurst(pos, dir, owner, weapon)
	return {
		pos = pos,
		dir = dir + calculateSpread(),
		owner = owner,
		weapon = weapon,
		timeCreated = CurTime(),
	}
end

local function renderBurst(burst)
	local fx = EffectData()
	fx:SetOrigin(burst.pos)
	fx:SetNormal(burst.dir)
	fx:SetRadius(15)

	util.Effect("RPGShotDown", fx)
	util.Effect("CommandPointer", fx)
end

local function applyGravityToEntity(burst, entity, magnitude)
	if not IsValid(entity) then
		return
	end

	local entityPhysics = entity:GetPhysicsObject()
	if not IsValid(entityPhysics) then
		return
	end

	local tossDirection = (entity:GetPos() - burst.pos):GetNormalized()
	local tossForce = -tossDirection * magnitude * entityPhysics:GetMass()
	if entity:IsPlayer() then
		-- Can't use physics methods on a player
		-- Arbitrary 0.03 because we're setting velocity, not force
		-- It also acts different with players, toss players away instead of inwards like for props.
		entity:SetVelocity(-tossForce * 0.03)
	else
		-- And some random angular velocity for good measure
		entityPhysics:AddAngleVelocity(VectorRand(-50, 50))
		entityPhysics:ApplyForceCenter(tossForce)
	end
end

local function explodeBurst(burst)
	if not IsValid(burst.weapon) or not IsValid(burst.owner) then
		return
	end

	util.BlastDamage(burst.weapon, burst.owner, burst.pos, BURST_EXPLOSION_RADIUS_UNITS, BURST_DAMAGE_HP)
	local fx = EffectData()
	fx:SetOrigin(burst.pos)

	util.Effect("Explosion", fx)

	-- Toss all props inwards and players away in the explosion radius
	local entities = ents.FindInSphere(burst.pos, BURST_EXPLOSION_RADIUS_UNITS)

	for _, entity in ipairs(entities) do
		applyGravityToEntity(burst, entity, BURST_TOSS_IMPULSE_MAGNITUDE)
	end
end

local function updateBurst(burst)
	local timeElapsed = CurTime() - burst.timeCreated
	if timeElapsed > BURST_LIFETIME_SECS then
		return true
	end

	-- check if the burst has collided
	local endPos = burst.pos + burst.dir * BURST_SPEED_UNITS * timeElapsed
	local trace = util.TraceLine({
		start = burst.pos,
		endpos = endPos,
		filter = {
			burst.owner,
		},
	})

	if trace and trace.Hit then
		return true
	end

	local entities = ents.FindInSphere(endPos, BURST_PASSIVE_RADIUS_UNITS)
	for _, entity in ipairs(entities) do
		if entity == burst.owner then
			continue
		end

		applyGravityToEntity(burst, entity, BURST_PASSIVE_IMPULSE_MAGNITUDE)
	end

	burst.pos = endPos

	return false
end

function SWEP:FireBurst(position, direction)
	if CLIENT then
		return
	end

	globalBursts[makeBurst(position, direction, self:GetOwner(), self)] = false
end

function SWEP:Initialize()
	self:SetHoldType("physgun")
end

function SWEP:Reload()
	local owner = self:GetOwner()
	if owner:GetAmmoCount(self.Primary.Ammo) == 0 then
		return
	end

	if self.Reloading then
		return
	end

	self:EmitSound(self.LoadSound)
	self.Reloading = true

	-- Wait until the sound has finished playing
	timer.Simple(self.LoadSoundDurationSecs, function()
		self.Reloading = false
		if not IsValid(self) or not IsValid(owner) then
			return
		end

		local ammo = owner:GetAmmoCount(self.Primary.Ammo)

		self:SetClip1(math.min(ammo, self.Primary.ClipSize))
		owner:RemoveAmmo(self.Primary.ClipSize, self.Primary.Ammo)
	end)

	-- 0.1 is arbitrary because apparently SetClip1 doesn't update in the same tick,
	-- so the user could reload in the same tick that the reload finished
	self:SetNextPrimaryFire(CurTime() + self.LoadSoundDurationSecs + 0.1)
end

function SWEP:CalcViewModelView(_, _, _, newPos, newAng)
	-- Gangsta wielding
	return newPos, BURST_VIEWMODEL_ANGLE + newAng
end

function SWEP:PrimaryAttack()
	if not self:CanPrimaryAttack() then
		return
	end

	self:SetNextPrimaryFire(CurTime() + 1 / self.PrimaryRateOfFire)
	self:FireBurst(self:GetOwner():GetShootPos(), self:GetOwner():GetAimVector())
	self:EmitSound(self.ShootSound)
	self:TakePrimaryAmmo(1)
	self:GetOwner():ViewPunch(BURST_PUNCH_ANGLE)
	self:SendWeaponAnim(ACT_VM_PRIMARYATTACK)
end

function SWEP:SecondaryAttack() end

if SERVER then
	hook.Add("Think", "tas.grav_blaster_update", function()
		for burst, _ in pairs(globalBursts) do
			renderBurst(burst)
			local burstDied = updateBurst(burst)

			if burstDied then
				explodeBurst(burst)
				globalBursts[burst] = nil
			end
		end
	end)
end
