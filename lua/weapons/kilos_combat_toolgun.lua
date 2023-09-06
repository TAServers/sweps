SWEP.PrintName = "Kilo's Combat Tool Gun"
SWEP.Author = "Kilo"
SWEP.Purpose = "For when circumstances exceed that of the regular tool gun."
SWEP.Category = TASWeapons.Category

SWEP.Spawnable = true
SWEP.AdminOnly = false

SWEP.Base = "weapon_base"

SWEP.ShootSound = Sound("weapons/airboat/airboat_gun_lastshot2.wav")

SWEP.Primary.Damage = 20
SWEP.Primary.ClipSize = 1
SWEP.Primary.Ammo = "none"
SWEP.Primary.DefaultClip = 1
SWEP.Primary.Spread = 0
SWEP.Primary.NumberofShots = 1
SWEP.Primary.Automatic = true
SWEP.Primary.Recoil = 0.1
SWEP.Primary.Delay = 0.2
SWEP.Primary.Force = 1000

SWEP.Secondary.Damage = 10
SWEP.Secondary.ClipSize = 1
SWEP.Secondary.Ammo = "none"
SWEP.Secondary.DefaultClip = 1
SWEP.Secondary.Spread = 0.175
SWEP.Secondary.NumberofShots = 20
SWEP.Secondary.Automatic = false
SWEP.Secondary.Recoil = 3
SWEP.Secondary.Delay = 0.5
SWEP.Secondary.Force = 1000

SWEP.Slot = 1
SWEP.SlotPos = 0
SWEP.DrawCrosshair = true
SWEP.DrawAmmo = false
SWEP.Weight = 5
SWEP.AutoSwitchTo = true
SWEP.AutoSwitchFrom = false

SWEP.ViewModelFlip = false
SWEP.ViewModelFOV = 60
SWEP.ViewModel = "models/weapons/c_toolgun.mdl"
SWEP.WorldModel = "models/weapons/w_toolgun.mdl"
SWEP.UseHands = true
SWEP.HoldType = "pistol"

SWEP.FiresUnderwater = true
SWEP.DrawWeaponInfoBox = false
SWEP.IconOverride = "materials/entities/gmod_tool.png"
SWEP.CSMuzzleFlashes = false

function SWEP:Initialize()
	util.PrecacheSound(self.ShootSound)
	self:SetWeaponHoldType(self.HoldType)
end

function SWEP:getBullet(bulletProperties)
	local bullet = {}
	bullet.Num = bulletProperties.NumberofShots
	bullet.Src = self:GetOwner():GetShootPos()
	bullet.Dir = self:GetOwner():GetAimVector()
	bullet.Spread = Vector(bulletProperties.Spread, bulletProperties.Spread, 0)
	bullet.Tracer = 1
	bullet.TracerName = "ToolTracer"
	bullet.Force = bulletProperties.Force
	bullet.Damage = bulletProperties.Damage
	bullet.AmmoType = bulletProperties.Ammo

	return bullet
end

function SWEP:attack(bulletProperties)
	local bullet = self:getBullet(bulletProperties)
	self:ShootEffects()
	self:GetOwner():FireBullets(bullet)
	self:EmitSound(self.ShootSound)

	local RecoilDirection = math.random(0, 1) --Randomly chooses either left or right for yaw recoil
	if RecoilDirection == 0 then
		RecoilDirection = -1
	end
	self:GetOwner():ViewPunch(Angle(bulletProperties.Recoil, bulletProperties.Recoil * RecoilDirection, 0)) --Apply recoil upwards and either left or right (random)
end

function SWEP:PrimaryAttack()
	if not self:CanPrimaryAttack() then
		return
	end
	self:attack(self.Primary)
	self:SetNextPrimaryFire(CurTime() + self.Primary.Delay)
end

function SWEP:SecondaryAttack()
	if not self:CanSecondaryAttack() then
		return
	end
	self:attack(self.Secondary)
	self:SetNextSecondaryFire(CurTime() + self.Secondary.Delay)
end

if CLIENT then
	killicon.Add("kilos_combat_toolgun", "vgui/face/grin", Color(255, 255, 255, 255)) --Placeholder
	SWEP.WepSelectIcon = surface.GetTextureID("vgui/gmod_tool") --Maybe Placeholder (This is the toolgun screwdriver hud icon, might use an image I created that fits with the HL2 theme)
end
