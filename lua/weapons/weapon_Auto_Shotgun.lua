-- Easy Settings part

-- SWEP Info
SWEP.Author = "yousifgaming"
SWEP.Instructions = "Primary is the same as Secondary fire automatic shotgun"
SWEP.Purpose = "To play with Dingus"
SWEP.Contact = "Don't Contact me i dont like people"

-- SWEP info in spawnmenu
SWEP.PrintName = "Auto Shotgun"
SWEP.Category = "yousifgaming's Weapons"
SWEP.Spawnable = true
SWEP.AdminOnly = false
SWEP.IconOverride = "materials/cat.jpg"

if CLIENT then
    SWEP.WepSelectIcon = surface.GetTextureID('cat')
end

-- Primary settings
SWEP.Primary.ClipSize = 30
SWEP.Primary.DefaultClip = 30
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = "Buckshot"

-- Secondary settings
SWEP.Secondary.Ammo = "None"
SWEP.Secondary.Automatic = true

-- Reload status
SWEP.ReloadSound = "weapons/shotgun/shotgun_reload" .. math.random(1, 3) .. ".wav"
SWEP.ReloadInProgress = false

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
function SWEP:Initialize()
    self:SetHoldType("shotgun")
end

-- Uses hands?
SWEP.UseHands = true

-- Shooting sound
SWEP.ShootSound = Sound("weapons/xm1014/xm1014-1.wav")

-- Hard Parts / Functions

-- Primary Attack Function
function SWEP:PrimaryAttack()
    -- Checks if you can attack with primary
    if not self:CanPrimaryAttack() then return end

    -- Shoot speed per shot
    self:SetNextPrimaryFire(CurTime() + 0.5)
    self:SetNextSecondaryFire(CurTime() + 1)

    -- Bullet DMG-Bullet count-Spread
    self:ShootBullet(math.random(10, 25), 10, 0.1)

    -- Emit sound for shooting
    self:EmitSound(self.ShootSound)

    -- Takes 1 from the primary ammo
    self:TakePrimaryAmmo(1)
end

-- Secondary attack function same as primary but takes the bullet from the primary clip instead
function SWEP:SecondaryAttack()
    if not self:CanPrimaryAttack() or self:Clip1() < 3 then return end

    self:SetNextPrimaryFire(CurTime() + 1)
    self:SetNextSecondaryFire(CurTime() + 1)

    self:ShootBullet(math.random(25, 50), 30, 0.1)
    self:EmitSound(self.ShootSound)

    self:TakePrimaryAmmo(3)
end

-- this is complex part

-- Reload Logic/Function
function SWEP:Reload()
    -- Define some variables
    local ply = self:GetOwner()
    local roundsToReload = self.Primary.ClipSize - self:Clip1()
    self.ShellModel = "models/weapons/shotgun_shell.mdl"
    self.ShellAttachment = "shell"

    -- Checks for 3 things if the gun is reloading or the gun is at max clip size and the gun over 0 then doesnt reload
    if self:GetOwner():GetAmmoCount(self:GetPrimaryAmmoType()) <= 0 or self:Clip1() >= self.Primary.ClipSize or self.ReloadInProgress == true then
        return
    end

    -- Check if a reload is already in progress or the clip is full
    if ply:GetAmmoCount(self:GetPrimaryAmmoType()) < roundsToReload then
        roundsToReload = ply:GetAmmoCount(self:GetPrimaryAmmoType())
    end

    -- Check if there are rounds to reload
    if roundsToReload <= 0 then
        return
    end

    -- turns the value for ReloadInProgress to true fo other checks a.k.a Starts the reload
    self.ReloadInProgress = true  

    -- set the animation
    self:SendWeaponAnim(ACT_SHOTGUN_RELOAD_START)
    self:SetNextPrimaryFire(CurTime() + self:SequenceDuration())

    -- removes the bullet from the clip
    timer.Simple(self:SequenceDuration(), function()
        if IsValid(self) and IsValid(self:GetOwner()) then
            self:SendWeaponAnim(ACT_SHOTGUN_RELOAD_FINISH)
            self:DefaultReload(380)
            self:EmitSound(self.ReloadSound)
            self:SetClip1(self:Clip1() + roundsToReload)
            self:GetOwner():RemoveAmmo(roundsToReload, self:GetPrimaryAmmoType())
            self.ReloadInProgress = false
        end
    end)
end