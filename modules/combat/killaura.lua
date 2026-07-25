-- =============================================================================
-- COMMAND: KILL AURA
-- =============================================================================
return function(GH)
	local Players = GH.Services.Players
	local RunService = GH.Services.RunService
	local LocalPlayer = GH.LocalPlayer

	function Cheats_ToggleKillAura(state, btn)
		GH.UnregisterMasterLoop("KillAura")
		if state then
			GH.RegisterMasterLoop("KillAura", "Heartbeat", function()
				if GH.isClosing or not GH.States.KillAura then
					GH.UnregisterMasterLoop("KillAura"); return
				end
				local char = LocalPlayer.Character
				local hrp = char and char:FindFirstChild("HumanoidRootPart")
				local tool = char and char:FindFirstChildOfClass("Tool")
				if not hrp or not tool then return end

				local closestPlayer, closestDist = nil, 15
				for _, player in ipairs(Players:GetPlayers()) do
					if player == LocalPlayer then continue end
					if not player.Character then continue end
					local tHrp = player.Character:FindFirstChild("HumanoidRootPart")
					local tHum = player.Character:FindFirstChildOfClass("Humanoid")
					if not tHrp or not tHum or tHum.Health <= 0 then continue end
					if LocalPlayer.Team and player.Team and player.Team == LocalPlayer.Team then continue end
					local dist = (tHrp.Position - hrp.Position).Magnitude
					if dist < closestDist then closestDist = dist; closestPlayer = player end
				end

				if closestPlayer and closestPlayer.Character then
					local tHrp = closestPlayer.Character:FindFirstChild("HumanoidRootPart")
					if tHrp then
						hrp.CFrame = CFrame.new(hrp.Position, Vector3.new(tHrp.Position.X, hrp.Position.Y, tHrp.Position.Z))
						pcall(function() tool:Activate() end)
					end
				end
			end)
		end
		GH.ShowToast(state and ("Kill Aura " .. GH.T("toast_activated")) or ("Kill Aura " .. GH.T("toast_deactivated")), state and GH.Theme.On or GH.Theme.Off, 2)
	end

	GH.RegisterToggleButton("KillAura", GH.T("toggle_killaura"), Cheats_ToggleKillAura, "Combat", GH.T("desc_killaura"))
end