SWEP.Author = "el_patito_loco"
SWEP.PrintName = "Experimental Rotating Chamber Sniper"
SWEP.Category = TASWeapons.Category
SWEP.Author = TASWeapons.Authors.El_Patito
SWEP.Instructions = [[Left Click shoots a powerfull 12.7 mm sniper round that will destroy your enemies!!
At the moments our engineers are working on new features wich will provide more mass destruction!!
]]

SWEP.Spawnable = true
SWEP.AdminOnly = false

SWEP.Primary.ClipSize = 10
SWEP.Primary.DefaultClip = 10
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = "item_ammo_357_large"

SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = true
SWEP.Secondary.Ammo = "none"

SWEP.Weight = 5
SWEP.AutoSwitchTo = false
SWEP.AutoSwitchFrom = false

SWEP.Slot = 4
SWEP.SlotPos = 3
SWEP.DrawAmmo = true
SWEP.DrawCrosshair = true

SWEP.ViewModel = "models/weapons/v_357.mdl"
SWEP.WorldModel = "	models/weapons/w_357.mdl"

local ShootSound = Sound("weapons/mortar/mortar_fire1.wav")

SWEP.LoadSound = "weapons/ammopickup.wav"

SWEP.Primary.Recoil = 10
SWEP.Primary.Damage = 75
SWEP.Primary.NumShots = 1
SWEP.Primary.Spread = 0
SWEP.Primary.Cone = 0.25
SWEP.Primary.Delay = 1
SWEP.Tracer = 4
SWEP.Penetration = true
SWEP.Ricochet = true
SWEP.MaxRicochet = 100
SWEP.Scoped = false
SWEP.MouseWasDown = true

SWEP.RapidFire = false
SWEP.RapidFireTimer = 0
SWEP.RapidFireForce = 1000000

SWEP.CannonForce = 50000000

function SWEP:Initialize()
	self:SetWeaponHoldType("revolver")
end

function SWEP:PrimaryAttack()
	local ply = self:GetOwner()

	ply:LagCompensation(true)

	local Bullet = {}
	Bullet.Num = self.Primary.NumShots
	Bullet.Src = ply:GetShootPos()
	Bullet.Dir = ply:GetAimVector()
	Bullet.Spread = Vector(self.Primary.Spread, self.Primary.Spread, 0)
	Bullet.Tracer = self.Primary.Tracer
	Bullet.Damage = self.Primary.Damage
	Bullet.AmmoType = self.Primary.Ammo
	Bullet.Ricochet = self.Primary.Ricochet
	Bullet.MaxRicochet = self.Primary.MaxRicochet
	Bullet.Penetration = self.Primary.Penetration

	self:DoImpactEffect("GaussTracer")
	self:FireBullets(Bullet)
	self:ShootEffects()
	self:EmitSound(ShootSound)
	self.BaseClass.ShootEffects(self)
	--self:DrawAmmo(1)
	--self:DrawCrosshair(1)
	self:SetNextPrimaryFire(CurTime() + self.Primary.Delay)
	ply:LagCompensation(false)
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
