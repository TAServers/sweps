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
SWEP.Secondary.Spread = 1.75
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
SWEP.WorldModel	= "models/weapons/w_toolgun.mdl"
SWEP.UseHands = true

SWEP.HoldType = "Pistol"

SWEP.FiresUnderwater = true
SWEP.DrawWeaponInfoBox = false
SWEP.IconOverride = "materials/entities/gmod_tool.png"

SWEP.CSMuzzleFlashes = false


function SWEP:Initialize()
    util.PrecacheSound(self.ShootSound)
    self:SetWeaponHoldType(self.HoldType)
end

function SWEP:createBullet(fire)
    local bullet = {}
    bullet.Num = fire.NumberofShots
    bullet.Src = self:GetOwner():GetShootPos()
    bullet.Dir = self:GetOwner():GetAimVector()
    bullet.Spread = Vector( fire.Spread * 0.1 , fire.Spread * 0.1, 0)
    bullet.Tracer = 1
    bullet.TracerName = "ToolTracer"
    bullet.Force = fire.Force
    bullet.Damage = fire.Damage
    bullet.AmmoType = fire.Ammo
    bullet.Distance = 1e5

    bullet.RecoilPR = fire.Recoil * -1 --Recoil for Pitch & Roll
    bullet.recoilY = fire.Recoil * math.random(-1, 1) --Recoil for Yaw
    return bullet
end

function SWEP:attack(fire)
    local bullet = self:createBullet(fire)

    self:ShootEffects()

    self:GetOwner():FireBullets(bullet)
    self:EmitSound(self.ShootSound)
    self:GetOwner():ViewPunch(Angle(bullet.RecoilPR, bullet.recoilY, bullet.RecoilPR))
end

function SWEP:PrimaryAttack()

    if (not self:CanPrimaryAttack()) then return end

    self:attack(self.Primary)

    self:SetNextPrimaryFire(CurTime() + self.Primary.Delay)
end

function SWEP:SecondaryAttack()
    if (not self:CanSecondaryAttack()) then return end

    self:attack(self.Secondary)

    self:SetNextSecondaryFire(CurTime() + self.Secondary.Delay)
end

if not SERVER then
    killicon.Add("kilos_combat_toolgun", "vgui/face/grin", Color(255, 255, 255, 255))
    SWEP.WepSelectIcon = surface.GetTextureID("vgui/gmod_tool")
end
