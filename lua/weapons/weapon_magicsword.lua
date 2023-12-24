SWEP.PrintName = "Magic Sword"
SWEP.Author = TASWeapons.Authors.yousifgaming
SWEP.Instructions =
	"Left click to attack | Right click to leap | Reload to heal | While holding the sword you don't take fall damage"
SWEP.Purpose = "To Become a cool swordsman that can fly"
SWEP.Contact = "Don't Contact me i dont like people"

SWEP.Category = TASWeapons.Category
SWEP.Spawnable = true
SWEP.AdminOnly = false
SWEP.BounceWeaponIcon = false
if CLIENT then
	local TextureName = "magicsword/sword"
	SWEP.IconOverride = TextureName
	SWEP.WepSelectIcon = surface.GetTextureID(TextureName)
	killicon.Add("weapon_magicsword", TextureName, Color(255, 255, 255))
end

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
SWEP.AutoSwitchTo = true
SWEP.AutoSwitchFrom = true

SWEP.Slot = 0
SWEP.SlotPos = 1
SWEP.DrawAmmo = false
SWEP.DrawCrosshair = true

SWEP.PrimaryDamage = 50
SWEP.PrimaryDelay = 0.38
SWEP.PrimaryRange = 70

SWEP.HitSound = Sound("weapons/blades/swordchop.mp3")
SWEP.SwingSound = Sound("weapons/blades/woosh.mp3")
SWEP.HitWallSound = Sound("weapons/blades/hitwall.mp3")

if SERVER then
	resource.AddFile("materials/magicsword/sword.vmt")
end

function SWEP:Initialize()
	self:SetWeaponHoldType(self.HoldType)
	self.ViewModelFOV = 75
end

function SWEP:Think()
	if self.Idle and CurTime() >= self.Idle then
		self.Idle = nil
		self:SendWeaponAnim(ACT_VM_IDLE)
	end
end

function SWEP:PrimaryAttack()
	local tr = {}
	tr.start = self:GetOwner():GetShootPos()
	tr.endpos = self:GetOwner():GetShootPos() + (self:GetOwner():GetAimVector() * self.PrimaryRange)
	tr.filter = self:GetOwner()
	tr.mask = MASK_SHOT_HULL
	local trace = util.TraceLine(tr)

	self:SetNextPrimaryFire(CurTime() + self.PrimaryDelay)
	self:GetOwner():SetAnimation(PLAYER_ATTACK1)

	if trace.Hit then
		if trace.Entity:IsPlayer() or trace.Entity:IsNPC() then
			self:SetNextPrimaryFire(CurTime() + self.PrimaryDelay)
			self:SendWeaponAnim(self.HitAnim)
			self.Idle = CurTime() + self:GetOwner():GetViewModel():SequenceDuration()
			bullet = {}
			bullet.Num = 1
			bullet.Src = self:GetOwner():GetShootPos()
			bullet.Dir = self:GetOwner():GetAimVector()
			bullet.Spread = Vector(0, 0, 0)
			bullet.Tracer = 0
			bullet.Damage = self.PrimaryDamage
			self:GetOwner():FireBullets(bullet)
			self:EmitSound(self.HitSound)
		else
			bullet = {}
			bullet.Num = 1
			bullet.Src = self:GetOwner():GetShootPos()
			bullet.Dir = self:GetOwner():GetAimVector()
			bullet.Spread = Vector(0, 0, 0)
			bullet.Tracer = 0
			bullet.Damage = self.PrimaryDamage
			self:GetOwner():FireBullets(bullet)
			self:SetNextPrimaryFire(CurTime() + self.PrimaryDelay)
			self:SendWeaponAnim(self.HitAnim)
			self.Idle = CurTime() + self:GetOwner():GetViewModel():SequenceDuration()
			self:EmitSound(self.HitWallSound)
		end
	else
		self:EmitSound(self.SwingSound)
		self:SendWeaponAnim(self.MissAnim)
		self.Idle = CurTime() + self:GetOwner():GetViewModel():SequenceDuration()
	end
end

function SWEP:SecondaryAttack()
	self:SetNextSecondaryFire(CurTime() + 2)
	local owner = self:GetOwner()
	if IsValid(owner) and owner:IsOnGround() then
		local looking = owner:GetAimVector()
		local velocity = looking * 1000

		owner:SetVelocity(velocity)
		owner:EmitSound("ambient/levels/labs/electric_explosion1.wav")
	end
end

function SWEP:Reload()
	local owner = self:GetOwner()
	if CurTime() - (self.LastHealTime or 0) >= 2 and owner:Health() < 100 then
		local currentHealth = owner:Health()
		local maxHealth = owner:GetMaxHealth()
		local healAmount = math.min(maxHealth - currentHealth, 20)

		owner:SetHealth(currentHealth + healAmount)
		self.LastHealTime = CurTime()
		owner:EmitSound("items/smallmedkit1.wav")
	end
end

hook.Add("EntityTakeDamage", "PreventFallDamage", function(target, dmginfo)
	if
		IsValid(target)
		and target:IsPlayer()
		and IsValid(target:GetActiveWeapon())
		and target:GetActiveWeapon():GetClass() == "weapon_magicsword"
		and dmginfo:IsFallDamage()
	then
		dmginfo:SetDamage(0)
	end
end)
