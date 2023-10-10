if CLIENT then
	local Enabled = CreateClientConVar("cl_infohud", "0", true, false, "Enables / Disables the info hud")

	hook.Add("OnPlayerChat", "ToggleHud", function(ply, Text, bTeam, bDead)
		if string.lower(Text) == "/info" or string.lower(Text) == "!info" then
			local HudToggle = Enabled:GetBool()
			Enabled:SetBool(not HudToggle)
			return true
		end
	end)

	local function DrawWeaponInfo(x, y)
		local ply = LocalPlayer()

		if IsValid(ply) and IsValid(ply:GetActiveWeapon()) then
			local activeWeapon = ply:GetActiveWeapon()
			local weaponClass = activeWeapon:GetClass()
			local weaponName = string.gsub(weaponClass, "weapon_", "")
			weaponName = string.gsub(weaponName, "gmod_", "")

			-- Preset for default GMOD weapons
			if weaponName == "357" then
				weaponName = "revolver"
			elseif weaponName == "smg1" then
				weaponName = "smg"
			elseif weaponName == "physcannon" then
				weaponName = "gravity gun"
			elseif weaponName == "tool" then
				weaponName = "toolgun"
			end
			weaponName = string.upper(weaponName)

			local textColor = Color(255, 241, 63, 255)
			local padding = 10

			local textWidth, textHeight = surface.GetTextSize("Holding: " .. weaponName)
			local bgWidth = textWidth + 2 * padding
			local bgHeight = textHeight + 2 * padding
			local bgX = x - bgWidth / 2
			local bgY = y - bgHeight / 2

			draw.RoundedBox(8, bgX, bgY, bgWidth, bgHeight, Color(0, 0, 0, 92))
			draw.SimpleText(
				"Holding: " .. weaponName,
				"DermaLarge",
				x,
				y,
				textColor,
				TEXT_ALIGN_CENTER,
				TEXT_ALIGN_CENTER
			)
		end
	end

	local function DrawNPCInfo(x, y)
		local ply = LocalPlayer()
		local tr = util.GetPlayerTrace(ply)
		local trace = util.TraceLine(tr)

		if trace.Entity:IsValid() and trace.Entity:IsNPC() then
			local npc = trace.Entity:GetClass()
			local npcName = string.upper(string.gsub(npc, "npc_", ""))
			local npcHealth = trace.Entity:Health()
			local textColor = Color(255, 241, 63, 255)

			local textWidth, textHeight = surface.GetTextSize("NPC: " .. npcName .. " | NPC Health: " .. npcHealth)
			local padding = 10
			local bgWidth = textWidth + 2 * padding
			local bgHeight = textHeight + 2 * padding
			local bgX = x - bgWidth / 2
			local bgY = y + bgHeight / 2 + 2

			draw.RoundedBox(8, bgX, bgY, bgWidth, bgHeight, Color(0, 0, 0, 92))
			draw.SimpleText(
				"NPC: " .. npcName .. " | NPC Health: " .. npcHealth,
				"DermaLarge",
				x,
				y + 53,
				textColor,
				TEXT_ALIGN_CENTER,
				TEXT_ALIGN_CENTER
			)
		end
	end

	hook.Add("HUDPaint", "MyHUD", function()
		local HudToggle = Enabled:GetBool()
		if HudToggle then
			local x = ScrW() * 0.5
			local y = ScrH() * 0.9

			DrawWeaponInfo(x, y)
			DrawNPCInfo(x, y)
		end
	end)

	hook.Add("PopulateToolMenu", "CustomMenuSettings", function()
		spawnmenu.AddToolMenuOption("Utilities", "Hud", "HudStuff", "#Settings", "", "", function(panel)
			panel:AddControl("Label", { Text = "Turn on / off the hud info" })
			panel:AddControl("Checkbox", {
				Label = "Enable Info Hud",
				Command = "cl_infohud",
			})
		end)
	end)
end
