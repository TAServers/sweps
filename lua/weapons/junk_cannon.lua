if SERVER then
	AddCSLuaFile()
	util.AddNetworkString("JunkCannon.TriggerAudio")
	util.AddNetworkString("JunkCannon.RegisterHopperSize")
else
	net.Receive("JunkCannon.TriggerAudio", function()
		local ent = net.ReadEntity()
		if ent:IsValid() then
			ent:EmitSound(net.ReadString())
		end
	end)
	net.Receive("JunkCannon.RegisterHopperSize", function()
		local ent = net.ReadEntity()
		if ent:IsValid() then
			ent.Hopper = string.rep(" ", net.ReadUInt(32))
		end
	end)
end

SWEP.PrintName = "Junk Cannon"
SWEP.Category = TASWeapons.Category
SWEP.Author = "Derpius"
SWEP.Instructions = [[Right click to add small props to your prop hopper
Left click to fire the oldest one you picked up

Press reload to fire your entire hopper at once
Press middle mouse button to toggle the scope
]]

SWEP.Spawnable = true
SWEP.AdminOnly = false

SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = "none"

SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = true
SWEP.Secondary.Ammo = "none"

SWEP.Weight = 5
SWEP.AutoSwitchTo = false
SWEP.AutoSwitchFrom = false

SWEP.Slot = 1
SWEP.SlotPos = 2
SWEP.DrawAmmo = true
SWEP.DrawCrosshair = true

SWEP.ViewModel = "models/weapons/v_rpg.mdl"
SWEP.WorldModel = "models/weapons/w_rocket_launcher.mdl"

SWEP.ShootSound = "weapons/shotgun/shotgun_dbl_fire.wav"
SWEP.LoadSound = "weapons/ammopickup.wav"
SWEP.FailSound = "ui/buttonrollover.wav"
SWEP.RapidFireSound = "weapons/ar2/npc_ar2_altfire.wav"

SWEP.Hopper = {}
SWEP.HopperSize = 30

SWEP.Scoped = false
SWEP.MouseWasDown = true

SWEP.RapidFire = false
SWEP.RapidFireTimer = 0
SWEP.RapidFireForce = 1000000

SWEP.CannonForce = 50000000

function SWEP:PrimaryAttack()
	self:SetNextPrimaryFire(CurTime() + 0.5)

	if CLIENT or self.RapidFire then
		return
	end

	if #self.Hopper > 0 then
		net.Start("JunkCannon.TriggerAudio")
		net.WriteEntity(self)
		net.WriteString(self.ShootSound)
		net.Broadcast()

		local item = table.remove(self.Hopper, 1)
		self:ThrowProp(self.CannonForce, unpack(item))
	else
		net.Start("JunkCannon.TriggerAudio")
		net.WriteEntity(self)
		net.WriteString(self.FailSound)
		net.Broadcast()
	end
end

function SWEP:SecondaryAttack()
	self:SetNextSecondaryFire(CurTime() + 0.2)

	if CLIENT or self.RapidFire then
		return
	end

	local ray = self:GetOwner():GetEyeTrace()
	local hasPerms = not CPPI or ray.Entity:CPPICanPhysgun(self:GetOwner())

	if
		hasPerms
		and #self.Hopper < self.HopperSize
		and ray.Hit
		and ray.StartPos:Distance(ray.HitPos) < 300
		and ray.Entity:IsValid()
		and ray.Entity:GetPhysicsObject():IsValid()
		and ray.Entity:GetModelRadius() < 64
		and ray.Entity:GetClass() == "prop_physics"
	then
		net.Start("JunkCannon.TriggerAudio")
		net.WriteEntity(self)
		net.WriteString(self.LoadSound)
		net.Send(self:GetOwner())

		self:LoadProp(ray.Entity)
	else
		net.Start("JunkCannon.TriggerAudio")
		net.WriteEntity(self)
		net.WriteString(self.FailSound)
		net.Broadcast()
	end
end

function SWEP:Reload()
	if CLIENT or self.RapidFire or #self.Hopper == 0 then
		return
	end

	self.RapidFire = true
end

function SWEP:ThrowProp(force, model, mass, colour)
	local owner = self:GetOwner()
	if not owner:IsValid() then
		return
	end

	local ent = ents.Create("prop_physics")
	if not ent:IsValid() then
		return
	end

	ent:SetModel(model)

	local aimVector = owner:GetAimVector()
	local pos = aimVector * (5 + ent:GetModelRadius())
	pos:Add(owner:EyePos())

	ent:SetPos(pos)
	ent:SetAngles(owner:EyeAngles())
	ent:Spawn()
	ent:SetColor(colour)

	local phys = ent:GetPhysicsObject()
	if not phys:IsValid() then
		ent:Remove()
		return
	end

	phys:SetMass(mass)

	aimVector:Mul(force / mass)
	phys:ApplyForceCenter(aimVector)

	if CPPI then
		ent:CPPISetOwner(owner)
	end
	cleanup.Add(owner, "props", ent)
	undo.Create("Junk Cannon Projectile")
	undo.AddEntity(ent)
	undo.SetPlayer(owner)
	undo.Finish()

	net.Start("JunkCannon.RegisterHopperSize")
	net.WriteEntity(self)
	net.WriteUInt(#self.Hopper, 32)
	net.Send(self:GetOwner())
end

function SWEP:LoadProp(ent)
	self.Hopper[#self.Hopper + 1] = { ent:GetModel(), ent:GetPhysicsObject():GetMass(), ent:GetColor() }
	ent:Remove()

	net.Start("JunkCannon.RegisterHopperSize")
	net.WriteEntity(self)
	net.WriteUInt(#self.Hopper, 32)
	net.Send(self:GetOwner())
end

function SWEP:CustomAmmoDisplay()
	return {
		Draw = true,
		PrimaryClip = #self.Hopper,
		PrimaryAmmo = self.HopperSize,
	}
end

function SWEP:Think()
	if not SERVER or not self.RapidFire then
		return
	end

	if self.RapidFireTimer > 30 then
		net.Start("JunkCannon.TriggerAudio")
		net.WriteEntity(self)
		net.WriteString(self.RapidFireSound)
		net.Broadcast()

		local item = table.remove(self.Hopper, 1)
		self:ThrowProp(self.RapidFireForce, unpack(item))

		self.RapidFireTimer = 0
	else
		self.RapidFireTimer = self.RapidFireTimer + 1
	end

	if #self.Hopper == 0 then
		self.RapidFire = false
	end
end

function SWEP:TranslateFOV(original)
	if SERVER then
		return
	end -- Apparently this gets called server-side for area portals

	if input.IsMouseDown(MOUSE_MIDDLE) then
		if self.MouseWasDown then
			self.Scoped = not self.Scoped
			self.MouseWasDown = false
		end
	else
		self.MouseWasDown = true
	end

	if self.Scoped then
		return original * 0.2
	end
end

function SWEP:AdjustMouseSensitivity()
	if self.Scoped then
		return 0.2
	end
end
