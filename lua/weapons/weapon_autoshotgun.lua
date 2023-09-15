SWEP.Author = TASWeapons.Authors.yousifgaming
SWEP.Instructions = "Primary is the same as Secondary fire automatic shotgun"
SWEP.Purpose = "To play with Dingus"
SWEP.Contact = "Don't Contact me i dont like people"

SWEP.PrintName = "Auto Shotgun"
SWEP.Category = TASWeapons.Category
SWEP.Spawnable = true
SWEP.AdminOnly = false
SWEP.BounceWeaponIcon = false
SWEP.IconOverride = "materials/autoshotgun/cat.jpg"

SWEP.Primary.ClipSize = 30
SWEP.Primary.DefaultClip = 30
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = "Buckshot"

SWEP.Secondary.Ammo = "None"
SWEP.Secondary.Automatic = true

SWEP.ReloadInProgress = false

SWEP.Weight = 5
SWEP.AutoSwitchTo = false
SWEP.AutoSwitchFrom = false

SWEP.Slot = 1
SWEP.SlotPos = 0
SWEP.DrawAmmo = true
SWEP.DrawCrosshair = true

SWEP.ViewModel = "models/weapons/c_shotgun.mdl"
SWEP.WorldModel = "models/weapons/w_shotgun.mdl"
SWEP.ShellModel = "models/weapons/shotgun_shell.mdl"
SWEP.ShellAttachment = "shell"

SWEP.UseHands = true

SWEP.ShootSound = Sound("weapons/xm1014/xm1014-1.wav")

if CLIENT then
	SWEP.WepSelectIcon = surface.GetTextureID("autoshotgun/cat")
end

function SWEP:Initialize()
	self:SetHoldType("shotgun")
end

function SWEP:PrimaryAttack()
	if not self:CanPrimaryAttack() then
		return
	end

	self:SetNextPrimaryFire(CurTime() + 0.5)
	self:SetNextSecondaryFire(CurTime() + 1)

	self:ShootBullet(10, 10, 0.1)

	self:EmitSound(self.ShootSound)

	self:TakePrimaryAmmo(1)
end

function SWEP:SecondaryAttack()
	if not self:CanPrimaryAttack() or self:Clip1() < 3 then
		return
	end

	self:SetNextPrimaryFire(CurTime() + 1)
	self:SetNextSecondaryFire(CurTime() + 1)

	self:ShootBullet(10, 30, 0.1)
	self:EmitSound(self.ShootSound)

	self:TakePrimaryAmmo(3)
end

function SWEP:Reload()
	local ply = self:GetOwner()
	local roundsToReload = self.Primary.ClipSize - self:Clip1()

	if
		self:GetOwner():GetAmmoCount(self:GetPrimaryAmmoType()) <= 0
		or self:Clip1() >= self.Primary.ClipSize
		or self.ReloadInProgress
	then
		return
	end

	if ply:GetAmmoCount(self:GetPrimaryAmmoType()) < roundsToReload then
		roundsToReload = ply:GetAmmoCount(self:GetPrimaryAmmoType())
	end

	if roundsToReload <= 0 then
		return
	end

	self.ReloadInProgress = true

	self:SendWeaponAnim(ACT_SHOTGUN_RELOAD_START)
	self:SetNextPrimaryFire(CurTime() + self:SequenceDuration())

	timer.Simple(self:SequenceDuration(), function()
		if IsValid(self) and IsValid(self:GetOwner()) then
			self:SendWeaponAnim(ACT_SHOTGUN_RELOAD_FINISH)
			self:DefaultReload(380)
			self:EmitSound("weapons/shotgun/shotgun_reload" .. math.random(1, 3) .. ".wav")
			self:SetClip1(self:Clip1() + roundsToReload)
			self:GetOwner():RemoveAmmo(roundsToReload, self:GetPrimaryAmmoType())
			self.ReloadInProgress = false
		end
	end)
end
