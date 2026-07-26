-- =============================================================================
-- COMMAND: NO PLAYER COLLIDE
-- Remove colisao com outros jogadores (passar atraves de players)
-- =============================================================================
return function(GH)
	local Players = GH.Services.Players
	local RunService = GH.Services.RunService
	local LocalPlayer = GH.LocalPlayer

	GH.Cache.OrigPlayerCollides = GH.Cache.OrigPlayerCollides or {}

	function Cheats_ToggleNoPlayerCollide(state, btn)
		GH.UnregisterMasterLoop("NoPlayerCollide")

		-- Restaurar CanCollide de todas as partes salvas
		if not state then
			for part, origCanCollide in pairs(GH.Cache.OrigPlayerCollides) do
				if part and part.Parent then
					pcall(function() part.CanCollide = origCanCollide end)
				end
			end
			table.clear(GH.Cache.OrigPlayerCollides)
			return
		end

		-- Ativar: desativar colisao de todos os outros jogadores
		GH.RegisterMasterLoop("NoPlayerCollide", "PreSim", function()
			if GH.isClosing then return end
			if not GH.States.NoPlayerCollide then
				GH.UnregisterMasterLoop("NoPlayerCollide")
				return
			end

			local myChar = LocalPlayer.Character
			if not myChar then return end

			for _, player in ipairs(Players:GetPlayers()) do
				if player ~= LocalPlayer and player.Character then
					for _, part in ipairs(player.Character:GetDescendants()) do
						if part:IsA("BasePart") then
							if part.CanCollide then
								-- Salvar valor original so na primeira vez
								if GH.Cache.OrigPlayerCollides[part] == nil then
									GH.Cache.OrigPlayerCollides[part] = true
								end
								part.CanCollide = false
							end
						end
					end
				end
			end

			-- Limpar referencia de partes que foram destruidas
			for part, _ in pairs(GH.Cache.OrigPlayerCollides) do
				if not part or not part.Parent then
					GH.Cache.OrigPlayerCollides[part] = nil
				end
			end
		end)
	end

	GH.RegisterToggleButton("NoPlayerCollide", "toggle_noplayercollide", Cheats_ToggleNoPlayerCollide, "Utility", "desc_noplayercollide")
end
