-- =============================================================================
-- COMMAND: FORCE PUSH
-- Empurra jogadores proximos automaticamente (defesa contra flingers)
-- =============================================================================
return function(GH)
	local Players = GH.Services.Players
	local RunService = GH.Services.RunService
	local LocalPlayer = GH.LocalPlayer

	GH.Cache.ForcePushRadius = GH.Cache.ForcePushRadius or 15

	function Cheats_ToggleForcePush(state, btn)
		GH.UnregisterMasterLoop("ForcePush")

		if not state then return end

		GH.RegisterMasterLoop("ForcePush", "PreSim", function()
			if GH.isClosing or not GH.States.ForcePush then
				GH.UnregisterMasterLoop("ForcePush")
				return
			end

			local myChar = LocalPlayer.Character
			local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
			if not myRoot then return end

			local radius = GH.Cache.ForcePushRadius

			for _, player in ipairs(Players:GetPlayers()) do
				if player ~= LocalPlayer and player.Character then
					local targetRoot = player.Character:FindFirstChild("HumanoidRootPart")
					if targetRoot then
						local dist = (myRoot.Position - targetRoot.Position).Magnitude
						if dist < radius and dist > 1 then
							-- Calcular direcao de empurrao (para longe de voce)
							local dir = (targetRoot.Position - myRoot.Position).Unit
							-- Forca inversamente proporcional a distancia (mais forte mais perto)
							local force = 80 * (1 - dist / radius)
							targetRoot.AssemblyLinearVelocity = dir * force + Vector3.new(0, 30, 0)
						end
					end
				end
			end
		end)
	end

	GH.RegisterToggleButton("ForcePush", "toggle_forcepush", Cheats_ToggleForcePush, "Utility", "desc_forcepush")
end
