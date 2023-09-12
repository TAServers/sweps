-- Easy Settings part

-- SWEP Info
SWEP.Author = "yousifgaming"
SWEP.Instructions = "Gotta Go Faster"
SWEP.Purpose = "For admins only"
SWEP.Contact = "Don't Contact me i dont like people"

-- SWEP info in spawnmenu
SWEP.PrintName = "Fast Shotgun"
SWEP.Category = "yousifgaming's Weapons"
SWEP.Spawnable = true
SWEP.AdminOnly = false
SWEP.IconOverride = "materials/cat.jpg"
SWEP.AdminOnly = true

if CLIENT then
SWEP.WepSelectIcon = surface.GetTextureID('cat')
end

-- Primary settings
SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = "Buckshot"

-- Secondary settings
SWEP.Secondary.Ammo = "None"
SWEP.Secondary.Automatic = true

-- Switch Pool
SWEP.Weight = 5
SWEP.AutoSwitchTo = false
SWEP.AutoSwitchFrom = false

-- Slot location and gui elements
SWEP.Slot = 1
SWEP.SlotPos = 0
SWEP.DrawAmmo = true
SWEP.DrawCrosshair = true

-- World and View Models
SWEP.ViewModel = "models/weapons/c_shotgun.mdl"
SWEP.WorldModel = "models/weapons/w_shotgun.mdl"

-- Uses hands?
SWEP.UseHands = true

-- Shooting sound
SWEP.ShootSound = Sound("weapons/xm1014/xm1014-1.wav")

-- Hard Parts / Functions

-- Primary Attack Function
function SWEP:PrimaryAttack()
    -- Shoot speed per shot
    self:SetNextPrimaryFire(CurTime() + 0.1)
    self:SetNextSecondaryFire(CurTime() + 0.1)

    -- Bullet DMG-Bullet count-Spread
    self:ShootBullet(50, 20, 0.05)

    -- Emit sound for shooting
    self:EmitSound(self.ShootSound)
end

-- Secondary attack function same as primary but takes the bullet from the primary clip instead
function SWEP:SecondaryAttack()
    self:SetNextPrimaryFire(CurTime() + 0.1)
    self:SetNextSecondaryFire(CurTime() + 0.1)

    self:ShootBullet(50, 20, 0.05)
    self:EmitSound(self.ShootSound)
end