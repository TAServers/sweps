if SERVER then
	resource.AddSingleFile("materials/entities/grav_blaster.png")
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

local PUNCH_ANGLE = Angle(-3, -1.6, -0.3) -- Determines how strong the punch is on each axis

function SWEP:FireBurst(position, direction)
	if CLIENT then
		return
	end

	MakeGravityBurst(position, direction, self:GetOwner(), self)
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
		local requiredAmmoCount = self.Primary.ClipSize - self:Clip1()
		self:SetClip1(self:Clip1() + math.min(ammo, requiredAmmoCount))
		owner:RemoveAmmo(requiredAmmoCount, self.Primary.Ammo)
	end)

	-- 0.1 is arbitrary because apparently SetClip1 doesn't update in the same tick,
	-- so the user could reload in the same tick that the reload finished
	self:SetNextPrimaryFire(CurTime() + self.LoadSoundDurationSecs + 0.1)
end

function SWEP:PrimaryAttack()
	if not self:CanPrimaryAttack() then
		return
	end

	self:SetNextPrimaryFire(CurTime() + 1 / self.PrimaryRateOfFire)
	self:FireBurst(self:GetOwner():GetShootPos(), self:GetOwner():GetAimVector())
	self:EmitSound(self.ShootSound)
	self:TakePrimaryAmmo(1)
	self:GetOwner():ViewPunch(PUNCH_ANGLE)
	self:SendWeaponAnim(ACT_VM_PRIMARYATTACK)
end

function SWEP:SecondaryAttack() end

if CLIENT then
	-- "," is the gravity gun icon
	killicon.AddFont("grav_blaster", "HL2MPTypeDeath", ",", Color(255, 80, 0))
end
