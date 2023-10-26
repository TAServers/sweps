SWEP.Author = "el_patito_loco"
SWEP.PrintName = "E.R.C.S" --"Experimental Rotating Chamber Sniper"
SWEP.Category = TASWeapons.Category
SWEP.Author = TASWeapons.Authors.El_Patito
SWEP.Instructions = [[Left Click shoots a powerful 12.7 mm sniper round that will destroy your enemies!!
At the moment our engineers are working on new features which will provide more mass destruction!!
]]

SWEP.Spawnable = true
SWEP.AdminOnly = false

SWEP.ViewModel = "models/weapons/v_357.mdl"
SWEP.WorldModel = "models/weapons/w_357.mdl"

local ShootSound = Sound("weapons/mortar/mortar_fire1.wav")

SWEP.FiresUnderwater = true
SWEP.DrawWeaponInfoBox = true
SWEP.IconOverride = "materials/entities/weapon_357.png"

--ammo

SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = "none"

SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = true
SWEP.Secondary.Ammo = "none"

--Inventory related

SWEP.Weight = 5
SWEP.AutoSwitchTo = false
SWEP.AutoSwitchFrom = false

SWEP.Slot = 4
SWEP.SlotPos = 3
SWEP.DrawAmmo = false
SWEP.DrawCrosshair = true

--weapon properties

SWEP.Primary.Recoil = 1
SWEP.Primary.Damage = 75
SWEP.Primary.NumShots = 10
SWEP.Primary.Spread = 0
SWEP.Primary.Delay = 1
SWEP.MouseWasDown = true

function SWEP:Initialize()
	self:SetHoldType("revolver")
end

function SWEP:PrimaryAttack()
	local ply = self:GetOwner()

	local Bullet = {}
	Bullet.Num = self.Primary.NumShots
	Bullet.Src = ply:GetShootPos()
	Bullet.Dir = ply:GetAimVector()
	Bullet.Spread = Vector(self.Primary.Spread, self.Primary.Spread, 0)
	Bullet.Tracer = 1
	Bullet.TracerName = "AirboatGunTracer"
	Bullet.Damage = self.Primary.Damage
	Bullet.AmmoType = self.Primary.Ammo

	local RecoilMultiplier = self.Primary.Recoil * -1
	local RecoilRandomMultiplier = self.Primary.Recoil * math.random(-1, 1)

	ply:ViewPunch(Angle(RecoilMultiplier, RecoilRandomMultiplier, RecoilMultiplier))

	self:DoImpactEffect("GaussTracer")
	self:FireBullets(Bullet)
	self:ShootEffects()
	self:EmitSound(ShootSound)
	self.BaseClass.ShootEffects(self)
	self:SetNextPrimaryFire(CurTime() + self.Primary.Delay)
end

if CLIENT then
	killicon.AddFont("blue_shotgun", "HL2MPTypeDeath", "0", Color(0, 0, 255, 255))
end

function SWEP:SecondaryAttack() end
--[[ All of this is seized until further improvment of my lua skills
function SWEP:DoImpactEffect(GaussTracer,2)
end
function SWEP:Reload() end
function SWEP:scope()
	self:scope(1)
end
--]]
