-- =============================================================================
-- COMMAND: HITBOX
-- =============================================================================
return function(GH)
	local Players = GH.Services.Players
	local LocalPlayer = GH.LocalPlayer

	function Cheats_ToggleHitbox(state, btn)
		GH.UnregisterMasterLoop("Hitbox")
		GH.Disconnect("Hitbox_PlayerRemoving")

		for _, player in ipairs(Players:GetPlayers()) do
			if player.Character then
				local hrp = player.Character:FindFirstChild("HumanoidRootPart")
				if hrp and GH.Cache.OrigHRPSizes[player] then
					hrp.Size = GH.Cache.OrigHRPSizes[player]
					hrp.Transparency = 1
					hrp.CanCollide = false
				end
			end
		end

		local function cleanSelectionBox(obj)
			if obj and obj.Parent and obj:IsA("SelectionBox") and obj.Name:sub(1, 12) == "GH_Hitbox_SB" then
				obj.Adornee = nil
				obj:Destroy()
			end
		end

		for _, obj in ipairs(GH.TargetGui:GetChildren()) do
			cleanSelectionBox(obj)
		end

		for _, player in ipairs(Players:GetPlayers()) do
			if player.Character then
				for _, obj in ipairs(player.Character:GetChildren()) do
					cleanSelectionBox(obj)
				end
			end
		end

		table.clear(GH.Cache.OrigHRPSizes)
		table.clear(GH.Cache.HitboxAdornments)

		if not state then return end

		GH.Connections.Hitbox_PlayerRemoving = Players.PlayerRemoving:Connect(function(player)
			if GH.Cache.HitboxAdornments[player] then
				local sb = GH.Cache.HitboxAdornments[player]
				if sb and sb.Parent then
					sb.Adornee = nil
					sb:Destroy()
				end
				GH.Cache.HitboxAdornments[player] = nil
			end
			if player.Character then
				for _, obj in ipairs(player.Character:GetChildren()) do
					if obj:IsA("SelectionBox") and obj.Name:sub(1, 12) == "GH_Hitbox_SB" then
						obj.Adornee = nil
						obj:Destroy()
					end
				end
			end
			GH.Cache.OrigHRPSizes[player] = nil
		end)

		GH.RegisterMasterLoop("Hitbox", "Render", function()
			if GH.isClosing or not GH.States.Hitbox then
				GH.UnregisterMasterLoop("Hitbox")
				GH.Disconnect("Hitbox_PlayerRemoving")
				return
			end
			for _, player in ipairs(Players:GetPlayers()) do
				if player == LocalPlayer then continue end
				if LocalPlayer.Team and player.Team and player.Team == LocalPlayer.Team then continue end

				if not player.Character then
					if GH.Cache.HitboxAdornments[player] then
						local sb = GH.Cache.HitboxAdornments[player]
						if sb and sb.Parent then
							sb.Adornee = nil
							sb:Destroy()
						end
						GH.Cache.HitboxAdornments[player] = nil
					end
					GH.Cache.OrigHRPSizes[player] = nil
					continue
				end

				local hrp = player.Character:FindFirstChild("HumanoidRootPart")
				local hum = player.Character:FindFirstChildOfClass("Humanoid")
				if not hrp or not hrp.Parent or not hum or hum.Health <= 0 then
					if GH.Cache.HitboxAdornments[player] then
						local sb = GH.Cache.HitboxAdornments[player]
						if sb and sb.Parent then
							sb.Adornee = nil
							sb:Destroy()
						end
						GH.Cache.HitboxAdornments[player] = nil
					end
					if hrp and hrp.Parent and GH.Cache.OrigHRPSizes[player] then
						hrp.Size = GH.Cache.OrigHRPSizes[player]
						hrp.Transparency = 1
						hrp.CanCollide = false
					end
					GH.Cache.OrigHRPSizes[player] = nil
					continue
				end

				if not GH.Cache.OrigHRPSizes[player] then
					GH.Cache.OrigHRPSizes[player] = hrp.Size
				end
				hrp.Size = Vector3.new(GH.Settings.HitboxSize, GH.Settings.HitboxSize, GH.Settings.HitboxSize)
				hrp.Transparency = 1
				hrp.CanCollide = false

				local sb = GH.Cache.HitboxAdornments[player]
				if not sb or not sb.Parent or sb.Adornee ~= hrp then
					if sb and sb.Parent then
						sb.Adornee = nil
						sb:Destroy()
					end
					sb = Instance.new("SelectionBox")
					sb.Name = "GH_Hitbox_SB_" .. player.Name
					sb.Adornee = hrp
					sb.Color3 = Color3.fromRGB(255, 0, 0)
					sb.SurfaceTransparency = 1
					sb.Parent = GH.TargetGui
					GH.Cache.HitboxAdornments[player] = sb
				end
			end
		end)
	end

	GH.RegisterToggleButton("Hitbox", GH.T("toggle_hitbox"), Cheats_ToggleHitbox, "Combat", GH.T("desc_hitbox"))
end