SWEP.Author = "el_patito_loco"
SWEP.PrintName = "E.R.C.S" --"Experimental Rotating Chamber Sniper"
SWEP.Category = TASWeapons.Category
SWEP.Author = TASWeapons.Authors.El_Patito
SWEP.Instructions = [[Left Click shoots a powerful 12.7 mm sniper round that will destroy your enemies!!
At the moment our engineers are working on new features which will provide more mass destruction!!
]]

SWEP.Spawnable = true
SWEP.AdminOnly = false

SWEP.FiresUnderwater = true
SWEP.DrawWeaponInfoBox = true
SWEP.IconOverride = "materials/entities/weapon_357.png"

SWEP.Primary.ClipSize = 10
SWEP.Primary.DefaultClip = 10
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = "357"

SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = true
SWEP.Secondary.Ammo = "none"

SWEP.Weight = 5
SWEP.AutoSwitchTo = false
SWEP.AutoSwitchFrom = false

SWEP.Slot = 4
SWEP.SlotPos = 3
SWEP.DrawAmmo = false
SWEP.DrawCrosshair = true

SWEP.ViewModel = "models/weapons/v_357.mdl"
SWEP.WorldModel = "models/weapons/w_357.mdl"

local ShootSound = Sound("weapons/mortar/mortar_fire1.wav")

--SWEP.LoadSound = "weapons/ammopickup.wav" FOR SECONDARY FIRE

SWEP.Primary.Recoil = 1
SWEP.Primary.Damage = 75
SWEP.Primary.NumShots = 1
SWEP.Primary.Spread = 0
--SWEP.Primary.Cone = 0.25 THIS IS FOR FUTURE SCOPE
SWEP.Primary.Delay = 1
SWEP.Tracer = 4
--SWEP.Penetration = true
--SWEP.Ricochet = true
--SWEP.MaxRicochet = 100
--SWEP.Scoped = false
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
	--self:DrawAmmo(1)
	--self:DrawCrosshair(1)
	self:SetNextPrimaryFire(CurTime() + self.Primary.Delay)
end

if CLIENT then --I got thjis from kilo swep hope you don't mind
	killicon.Add("E_R_C_S", "vgui/face/grin", Color(255, 255, 255, 255))
	--SWEP.WepSelectIcon = surface.GetTextureID("vgui/gmod_tool")
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
