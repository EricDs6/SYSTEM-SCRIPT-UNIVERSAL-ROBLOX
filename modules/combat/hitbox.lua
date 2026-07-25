-- =============================================================================
-- COMMAND: HITBOX
-- Expande a hitbox (HumanoidRootPart) dos inimigos para acertar mais facil
-- Abordagem: RenderStepped direto (sem master loop)
-- =============================================================================
return function(GH)
	local Players = GH.Services.Players
	local RunService = GH.Services.RunService
	local LocalPlayer = GH.LocalPlayer

	function Cheats_ToggleHitbox(state, btn)
		-- Desconectar loop anterior
		GH.UnregisterMasterLoop("Hitbox")
		GH.Disconnect("Hitbox_Render")
		GH.Disconnect("Hitbox_PlayerRemoving")

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

		if not state then return end

		-- PlayerRemoving: limpar cache
		GH.Connections.Hitbox_PlayerRemoving = Players.PlayerRemoving:Connect(function(player)
			GH.Cache.OrigHRPSizes[player] = nil
		end)

		-- RenderStepped direto (sem master loop)
		GH.Connections.Hitbox_Render = RunService.RenderStepped:Connect(function()
			if GH.isClosing or not GH.States.Hitbox then
				GH.Disconnect("Hitbox_Render")
				GH.Disconnect("Hitbox_PlayerRemoving")
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

				-- Aplicar hitbox gigante (estilo FE Cosmic)
				local size = GH.Settings.HitboxSize or 20
				root.Size = Vector3.new(size, size, size)
				root.Transparency = 0.4
				root.CanCollide = false
			end
		end)
	end

	GH.RegisterToggleButton("Hitbox", "toggle_hitbox", Cheats_ToggleHitbox, "Combat", "desc_hitbox")
end
