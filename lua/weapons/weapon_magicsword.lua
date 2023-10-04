SWEP.PrintName = "Shitty Magic Sword"
SWEP.Author = TASWeapons.Authors.yousifgaming
SWEP.Instructions = "Left click to attack Right click to leap Reload to heal"
SWEP.Purpose = "To have fun"
SWEP.Contact = "Don't Contact me i dont like people"

SWEP.Category = TASWeapons.Category
SWEP.Spawnable = true
SWEP.AdminOnly = false
SWEP.BounceWeaponIcon = false

SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "none"

SWEP.Secondary.Ammo = "None"
SWEP.Secondary.Automatic = false

SWEP.ViewModel = "models/weapons/v_dmascus.mdl"
SWEP.WorldModel = "models/weapons/w_damascus_sword.mdl"
SWEP.UseHands = true
SWEP.HoldType = "melee2"

SWEP.HitAnim = ACT_VM_HITCENTER
SWEP.MissAnim = ACT_VM_MISSCENTER

SWEP.Weight = 5
SWEP.AutoSwitchTo = false
SWEP.AutoSwitchFrom = false

SWEP.Slot = 0
SWEP.SlotPos = 1
SWEP.DrawAmmo = false
SWEP.DrawCrosshair = true

SWEP.PrimaryDamage = 50
SWEP.PrimaryDelay = 0.4
SWEP.PrimaryRange = 48

SWEP.HitSound = Sound("weapons/blades/swordchop.mp3")
SWEP.SwingSound = Sound("weapons/blades/woosh.mp3")
SWEP.HitWallSound = Sound("weapons/blades/hitwall.mp3")

function SWEP:Initialize()
	self:SetWeaponHoldType(self.HoldType)
end

function SWEP:Think()
	if self.Idle and CurTime() >= self.Idle then
		self.Idle = nil
		self.Weapon:SendWeaponAnim(ACT_VM_IDLE)
	end
end

function SWEP:PrimaryAttack()
	local tr = {}
	tr.start = self.Owner:GetShootPos()
	tr.endpos = self.Owner:GetShootPos() + (self.Owner:GetAimVector() * self.PrimaryRange)
	tr.filter = self.Owner
	tr.mask = MASK_SHOT_HULL
	local trace = util.TraceLine(tr)

	self.Weapon:SetNextPrimaryFire(CurTime() + self.PrimaryDelay)
	self.Owner:SetAnimation(PLAYER_ATTACK1)

	if trace.Hit then
		if trace.Entity:IsPlayer() or trace.Entity:IsNPC() then
			self.Weapon:SetNextPrimaryFire(CurTime() + self.PrimaryDelay)
			self.Weapon:SendWeaponAnim(self.HitAnim)
			self.Idle = CurTime() + self.Owner:GetViewModel():SequenceDuration()
			bullet = {}
			bullet.Num = 1
			bullet.Src = self.Owner:GetShootPos()
			bullet.Dir = self.Owner:GetAimVector()
			bullet.Spread = Vector(0, 0, 0)
			bullet.Tracer = 0
			bullet.Damage = self.PrimaryDamage
			self.Owner:FireBullets(bullet)
			self:EmitSound(self.HitSound)
		else
			bullet = {}
			bullet.Num = 1
			bullet.Src = self.Owner:GetShootPos()
			bullet.Dir = self.Owner:GetAimVector()
			bullet.Spread = Vector(0, 0, 0)
			bullet.Tracer = 0
			bullet.Damage = self.PrimaryDamage
			self.Owner:FireBullets(bullet)
			self.Weapon:SetNextPrimaryFire(CurTime() + self.PrimaryDelay)
			self.Weapon:SendWeaponAnim(self.HitAnim)
			self.Idle = CurTime() + self.Owner:GetViewModel():SequenceDuration()
			self:EmitSound(self.HitWallSound)
		end
	else
		self:EmitSound(self.SwingSound)
		self.Weapon:SendWeaponAnim(self.MissAnim)
		self.Idle = CurTime() + self.Owner:GetViewModel():SequenceDuration()
	end
end

function SWEP:SecondaryAttack()
	self:SetNextSecondaryFire(CurTime() + 1)
	local owner = self:GetOwner()
	if IsValid(owner) and owner:IsOnGround() then
		local looking = owner:GetAimVector()
		local velocity = looking * 1000
		owner:SetVelocity(velocity)
		owner:EmitSound("npc/strider/strider_step" .. math.random(1, 6) .. ".wav")
	end
end

function SWEP:Reload()
	local owner = self:GetOwner()
	if CurTime() - (self.LastHealTime or 0) >= 2 then
		if owner:Health() < 100 then
			local currentHealth = owner:Health()
			local maxHealth = owner:GetMaxHealth()
			local healAmount = math.min(maxHealth - currentHealth, 10)
			owner:SetHealth(currentHealth + healAmount)
			self.LastHealTime = CurTime()
			owner:EmitSound("items/smallmedkit1.wav")
		end
	end
end

hook.Add("EntityTakeDamage", "PreventFallDamage", function(target, dmginfo)
	if
		IsValid(target)
		and target:IsPlayer()
		and IsValid(target:GetActiveWeapon())
		and target:GetActiveWeapon():GetClass() == "weapon_magicsword"
	then
		if dmginfo:IsFallDamage() then
			dmginfo:SetDamage(0)
		end
	end
end)
