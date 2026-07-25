-- =============================================================================
-- COMMAND: HITBOX
-- Expande a hitbox (HumanoidRootPart) dos inimigos para acertar mais facil
-- Abordagem: direto no Root.Size (estilo FE Cosmic)
-- =============================================================================
return function(GH)
	local Players = GH.Services.Players
	local LocalPlayer = GH.LocalPlayer

	function Cheats_ToggleHitbox(state, btn)
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
			local size = GH.Settings.HitboxSize or 20
			for _, player in ipairs(Players:GetPlayers()) do
				if player ~= LocalPlayer and player.Character then
					pcall(function()
						local root = player.Character:FindFirstChild("HumanoidRootPart")
						if root and root:IsA("BasePart") then
							if not GH.Cache.OrigHRPSizes[player] then
								GH.Cache.OrigHRPSizes[player] = root.Size
							end
							root.Size = Vector3.new(size, size, size)
							root.Transparency = 0.4
							root.CanCollide = false
						end
					end)
				end
			end

			-- Manter hitbox com loop simples (para novos players e respawns)
			GH.RegisterMasterLoop("Hitbox", "Heartbeat", function()
				if GH.isClosing or not GH.States.Hitbox then
					GH.UnregisterMasterLoop("Hitbox")
					return
				end
				local sz = GH.Settings.HitboxSize or 20
				for _, player in ipairs(Players:GetPlayers()) do
					if player ~= LocalPlayer and player.Character then
						pcall(function()
							local root = player.Character:FindFirstChild("HumanoidRootPart")
							if root and root:IsA("BasePart") then
								if not GH.Cache.OrigHRPSizes[player] then
									GH.Cache.OrigHRPSizes[player] = root.Size
								end
								if root.Size ~= Vector3.new(sz, sz, sz) then
									root.Size = Vector3.new(sz, sz, sz)
									root.Transparency = 0.4
									root.CanCollide = false
								end
							end
						end)
					end
				end
			end)
		end

		GH.ShowToast(state and ("Hitbox " .. GH.T("toast_activated")) or ("Hitbox " .. GH.T("toast_deactivated")), state and GH.Theme.On or GH.Theme.Off, 2)
	end

	GH.RegisterToggleButton("Hitbox", "toggle_hitbox", Cheats_ToggleHitbox, "Combat", "desc_hitbox")
end
