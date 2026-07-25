-- =============================================================================
-- COMMAND: PUSH ALL
-- Empurra todos os jogadores proximos com LinearVelocity
-- =============================================================================
return function(GH)
	local Players = GH.Services.Players
	local RunService = GH.Services.RunService
	local LocalPlayer = GH.LocalPlayer

	function Cheats_TogglePushAll(state, btn)
		GH.UnregisterMasterLoop("PushAll")

		if not state then return end

		GH.RegisterMasterLoop("PushAll", "Heartbeat", function()
			if GH.isClosing or not GH.States.PushAll then
				GH.UnregisterMasterLoop("PushAll")
				return
			end

			local myChar = LocalPlayer.Character
			local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
			if not myRoot then return end

			for _, player in ipairs(Players:GetPlayers()) do
				if player ~= LocalPlayer and player.Character then
					local targetRoot = player.Character:FindFirstChild("HumanoidRootPart")
					local targetHum = player.Character:FindFirstChildOfClass("Humanoid")
					if targetRoot and targetHum and targetHum.Health > 0 then
						local dist = (targetRoot.Position - myRoot.Position).Magnitude
						if dist < 20 then
							-- Direcao do empurao (longe de voce)
							local pushDir = (targetRoot.Position - myRoot.Position).Unit
							local pushForce = 80 / math.max(dist, 1)

							-- Aplicar velocity direto no servidor
							targetRoot.AssemblyLinearVelocity = pushDir * pushForce + Vector3.new(0, 20, 0)

							-- Adicionar AngularVelocity pra girar
							local spin = targetRoot:FindFirstChild("GH_PushSpin")
							if not spin then
								spin = Instance.new("AngularVelocity")
								spin.Name = "GH_PushSpin"
								spin.MaxTorque = math.huge
								spin.AngularVelocity = Vector3.new(0, 50, 0)
								spin.Parent = targetRoot
							end

							-- Remover spin apos 0.5s
							task.delay(0.5, function()
								if spin and spin.Parent then spin:Destroy() end
							end)
						end
					end
				end
			end
		end)

		GH.ShowToast("Push All: empurrando jogadores proximos!", GH.Theme.Red, 2)
	end

	GH.RegisterToggleButton("PushAll", "toggle_pushall", Cheats_TogglePushAll, "Troll", "desc_pushall")
end
