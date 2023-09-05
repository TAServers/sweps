SWEP.PrintName = "Kilo's Combat Tool Gun" -- The name of the weapon
    
SWEP.Author = "Kilo"
SWEP.Purpose = "For when circumstances exceed that of the regular tool gun."
SWEP.Category = TASWeapons.Category

SWEP.Spawnable = true
SWEP.AdminOnly = false


SWEP.Base = "weapon_base"

local ShootSound = Sound("weapons/airboat/airboat_gun_lastshot2.wav")
SWEP.Primary.Damage = 20
SWEP.Primary.TakeAmmo = 0
SWEP.Primary.ClipSize = 1
SWEP.Primary.Ammo = "none"
SWEP.Primary.DefaultClip = 1
SWEP.Primary.Spread = 0
SWEP.Primary.NumberofShots = 1
SWEP.Primary.Automatic = true
SWEP.Primary.Recoil = .1
SWEP.Primary.Delay = 0.2
SWEP.Primary.Force = 1000

SWEP.Secondary.Damage = 10
SWEP.Secondary.TakeAmmo = 0
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
SWEP.DrawCrosshair = true --Does it draw the crosshair
SWEP.DrawAmmo = false
SWEP.Weight = 5 --Priority when the weapon your currently holding drops
SWEP.AutoSwitchTo = true
SWEP.AutoSwitchFrom = false

SWEP.ViewModelFlip		= false
SWEP.ViewModelFOV		= 60
SWEP.ViewModel			= "models/weapons/c_toolgun.mdl"
SWEP.WorldModel			= "models/weapons/w_toolgun.mdl"
SWEP.UseHands           = true

SWEP.HoldType = "Pistol" 

SWEP.FiresUnderwater = true
SWEP.DrawWeaponInfoBox = false
SWEP.ReloadSound = "weapons/airboat/airboat_gun_lastshot2.wav"
SWEP.IconOverride = "materials/entities/gmod_tool.png"

SWEP.CSMuzzleFlashes = false


function SWEP:Initialize()
    util.PrecacheSound(ShootSound) 
    util.PrecacheSound(self.ReloadSound) 
    self:SetWeaponHoldType( self.HoldType )
end 


function SWEP:PrimaryAttack()

    if ( !self:CanPrimaryAttack() ) then return end
        
    local bullet = {}
    bullet.Num = self.Primary.NumberofShots
    bullet.Src = self.Owner:GetShootPos()
    bullet.Dir = self.Owner:GetAimVector()
    bullet.Spread = Vector( self.Primary.Spread * 0.1 , self.Primary.Spread * 0.1, 0)
    bullet.Tracer = 1
    bullet.TracerName = "ToolTracer"
    bullet.Force = self.Primary.Force
    bullet.Damage = self.Primary.Damage
    bullet.AmmoType = self.Primary.Ammo
    bullet.Distance = 100000
        
    local rnda = self.Primary.Recoil * -1
    local rndb = self.Primary.Recoil * math.random(-1, 1)
        
    self:ShootEffects()
        
    self.Owner:FireBullets( bullet )
    self:EmitSound(ShootSound)
    self.Owner:ViewPunch( Angle( rnda,rndb,rnda ) )
    self:TakePrimaryAmmo(self.Primary.TakeAmmo)

    self:SetNextPrimaryFire( CurTime() + self.Primary.Delay )
end

function SWEP:SecondaryAttack()
    if ( !self:CanSecondaryAttack() ) then return end
        
    local bullet = {}
    bullet.Num = self.Secondary.NumberofShots
    bullet.Src = self.Owner:GetShootPos()
    bullet.Dir = self.Owner:GetAimVector()
    bullet.Spread = Vector( self.Secondary.Spread * 0.1 , self.Secondary.Spread * 0.1, 0)
    bullet.Tracer = 1
    bullet.TracerName = "ToolTracer"
    bullet.Force = self.Secondary.Force
    bullet.Damage = self.Secondary.Damage
    bullet.AmmoType = self.Secondary.Ammo
    bullet.Distance = 100000
        
    local rnda = self.Secondary.Recoil * -1
    local rndb = self.Secondary.Recoil * math.random(-1, 1)
        
    self:ShootEffects()
        
    self.Owner:FireBullets( bullet )
    self:EmitSound(ShootSound)
    self.Owner:ViewPunch( Angle( rnda,rndb,rnda ) )
    self:TakeSecondaryAmmo(self.Secondary.TakeAmmo)

    self:SetNextSecondaryFire( CurTime() + self.Secondary.Delay )
end

function SWEP:Reload()
    self.Weapon:DefaultReload( ACT_VM_RELOAD );
end

if !SERVER then
    killicon.Add( "kilos_combat_toolgun", "vgui/face/grin", Color( 255, 255, 255, 255 ) )
    SWEP.WepSelectIcon = surface.GetTextureID( 'vgui/gmod_tool' )
end
