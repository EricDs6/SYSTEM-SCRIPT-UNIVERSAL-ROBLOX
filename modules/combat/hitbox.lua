-- =============================================================================
-- COMMAND: HITBOX
-- Expande a hitbox (HumanoidRootPart) dos inimigos para acertar mais facil
-- =============================================================================
return function(GH)
	local Players = GH.Services.Players
	local LocalPlayer = GH.LocalPlayer

	function Cheats_ToggleHitbox(state, btn)
		GH.UnregisterMasterLoop("Hitbox")

		-- Restaurar hitboxes originais
		for _, player in ipairs(Players:GetPlayers()) do
			pcall(function()
				if player.Character and GH.Cache.OrigHRPSizes[player] then
					local root = player.Character:FindFirstChild("HumanoidRootPart")
					if root and root:IsA("BasePart") then
						root.Size = GH.Cache.OrigHRPSizes[player]
						root.Transparency = 1
						root.CanCollide = false
					end
				end
			end)
		end
		table.clear(GH.Cache.OrigHRPSizes)

		if state then
			GH.RegisterMasterLoop("Hitbox", "Heartbeat", function()
				if GH.isClosing or not GH.States.Hitbox then
					GH.UnregisterMasterLoop("Hitbox")
					return
				end

				for _, player in ipairs(Players:GetPlayers()) do
					if player == LocalPlayer then continue end

					if not player.Character then
						GH.Cache.OrigHRPSizes[player] = nil
						continue
					end

					local root = player.Character:FindFirstChild("HumanoidRootPart")
					if not root or not root:IsA("BasePart") then
						GH.Cache.OrigHRPSizes[player] = nil
						continue
					end

					-- Salvar tamanho original so uma vez
					if not GH.Cache.OrigHRPSizes[player] then
						GH.Cache.OrigHRPSizes[player] = root.Size
					end

					-- Aplicar hitbox gigante
					local size = GH.Settings.HitboxSize or 20
					root.Size = Vector3.new(size, size, size)
					root.Transparency = 0.4
					root.CanCollide = false
				end
			end)
		end

		GH.ShowToast(state and ("Hitbox " .. GH.T("toast_activated")) or ("Hitbox " .. GH.T("toast_deactivated")), state and GH.Theme.On or GH.Theme.Off, 2)
	end

	GH.RegisterToggleButton("Hitbox", "toggle_hitbox", Cheats_ToggleHitbox, "Combat", "desc_hitbox")
end
