-- =============================================================================
-- COMMAND: HITBOX
-- =============================================================================
return function(GH)
	local Players = GH.Services.Players
	local LocalPlayer = GH.LocalPlayer

	local function cleanHitboxAdornments()
		-- Limpar SelectionBoxes do TargetGui
		pcall(function()
			for _, obj in ipairs(GH.TargetGui:GetChildren()) do
				if obj:IsA("SelectionBox") and obj.Name:sub(1, 12) == "GH_Hitbox_SB" then
					obj.Adornee = nil
					obj:Destroy()
				end
			end
		end)
		-- Limpar SelectionBoxes dos characters
		for _, player in ipairs(Players:GetPlayers()) do
			pcall(function()
				if player.Character then
					for _, obj in ipairs(player.Character:GetChildren()) do
						if obj:IsA("SelectionBox") and obj.Name:sub(1, 12) == "GH_Hitbox_SB" then
							obj.Adornee = nil
							obj:Destroy()
						end
					end
				end
			end)
		end
	end

	local function restoreAllHitboxes()
		for _, player in ipairs(Players:GetPlayers()) do
			pcall(function()
				if player.Character and GH.Cache.OrigHRPSizes[player] then
					local hrp = player.Character:FindFirstChild("HumanoidRootPart")
					if hrp then
						hrp.Size = GH.Cache.OrigHRPSizes[player]
						hrp.Transparency = 1
						hrp.CanCollide = false
					end
				end
			end)
		end
		table.clear(GH.Cache.OrigHRPSizes)
		table.clear(GH.Cache.HitboxAdornments)
	end

	function Cheats_ToggleHitbox(state, btn)
		-- Sempre limpar estado anterior
		GH.UnregisterMasterLoop("Hitbox")
		GH.Disconnect("Hitbox_PlayerRemoving")
		restoreAllHitboxes()
		cleanHitboxAdornments()

		if not state then return end

		-- PlayerRemoving: limpar quando player sai
		GH.Connections.Hitbox_PlayerRemoving = Players.PlayerRemoving:Connect(function(player)
			pcall(function()
				if GH.Cache.HitboxAdornments[player] then
					local sb = GH.Cache.HitboxAdornments[player]
					if sb and sb.Parent then
						sb.Adornee = nil
						sb:Destroy()
					end
					GH.Cache.HitboxAdornments[player] = nil
				end
			end)
			GH.Cache.OrigHRPSizes[player] = nil
		end)

		-- Master loop: aplicar hitbox todo frame
		GH.RegisterMasterLoop("Hitbox", "Render", function()
			if GH.isClosing or not GH.States.Hitbox then
				GH.UnregisterMasterLoop("Hitbox")
				GH.Disconnect("Hitbox_PlayerRemoving")
				return
			end

			for _, player in ipairs(Players:GetPlayers()) do
				if player == LocalPlayer then continue end
				if LocalPlayer.Team and player.Team and player.Team == LocalPlayer.Team then continue end

				-- Player sem character: limpar
				if not player.Character then
					GH.Cache.OrigHRPSizes[player] = nil
					GH.Cache.HitboxAdornments[player] = nil
					continue
				end

				local hrp = player.Character:FindFirstChild("HumanoidRootPart")
				local hum = player.Character:FindFirstChildOfClass("Humanoid")

				-- Sem HRP ou morto: restaurar e limpar
				if not hrp or not hrp.Parent or not hum or hum.Health <= 0 then
					if GH.Cache.OrigHRPSizes[player] and hrp and hrp.Parent then
						pcall(function()
							hrp.Size = GH.Cache.OrigHRPSizes[player]
							hrp.Transparency = 1
							hrp.CanCollide = false
						end)
					end
					GH.Cache.OrigHRPSizes[player] = nil
					GH.Cache.HitboxAdornments[player] = nil
					continue
				end

				-- Salvar tamanho original so uma vez
				if not GH.Cache.OrigHRPSizes[player] then
					GH.Cache.OrigHRPSizes[player] = hrp.Size
				end

				-- Aplicar hitbox gigante
				hrp.Size = Vector3.new(GH.Settings.HitboxSize, GH.Settings.HitboxSize, GH.Settings.HitboxSize)
				hrp.Transparency = 1
				hrp.CanCollide = false

				-- SelectionBox: criar ou atualizar
				local sb = GH.Cache.HitboxAdornments[player]
				if not sb or not sb.Parent or sb.Adornee ~= hrp then
					if sb and sb.Parent then
						pcall(function() sb:Destroy() end)
					end
					pcall(function()
						sb = Instance.new("SelectionBox")
						sb.Name = "GH_Hitbox_SB_" .. player.Name
						sb.Adornee = hrp
						sb.Color3 = Color3.fromRGB(255, 0, 0)
						sb.SurfaceTransparency = 1
						sb.Parent = GH.TargetGui
						GH.Cache.HitboxAdornments[player] = sb
					end)
				end
			end
		end)
	end

	GH.RegisterToggleButton("Hitbox", "toggle_hitbox", Cheats_ToggleHitbox, "Combat", "desc_hitbox")
end
