-- =============================================================================
-- COMMAND: FLASHBACK (Voltar ao local da ultima morte)
-- =============================================================================
return function(GH)
	local Players = GH.Services.Players
	local RunService = GH.Services.RunService
	local UserInputService = GH.Services.UserInputService
	local TweenService = GH.Services.TweenService
	local LocalPlayer = GH.LocalPlayer

	GH.Cache.LastDeathCFrame = nil

	function Cheats_ToggleFlashback(state, btn)
		GH.Disconnect("FlashbackDied")
		GH.Disconnect("FlashbackRespawn")

		if state then
			local function connectDied()
				local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
				if hum then
					GH.Disconnect("FlashbackDied")
					GH.Connections.FlashbackDied = hum.Died:Connect(function()
						local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
						if hrp then
							GH.Cache.LastDeathCFrame = hrp.CFrame
						end
					end)
				end
			end

			connectDied()
			GH.Connections.FlashbackRespawn = LocalPlayer.CharacterAdded:Connect(function()
				if GH.States.Flashback then connectDied() end
			end)

			GH.InputManager.Bind(Enum.KeyCode.P, function()
				if not GH.States.Flashback then return end
				if GH.Cache.LastDeathCFrame then
					local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
					if hrp then
						local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
						if hum and hum.SeatPart then hum.Sit = false end
						GH.TweenTeleport(hrp, GH.Cache.LastDeathCFrame)
						GH.ShowToast(GH.T("toast_flashback"), GH.Theme.Accent, 2)
					end
				end
			end)
		else
			GH.InputManager.Unbind(Enum.KeyCode.P)
		end
	end

	GH.RegisterToggleButton("Flashback", "toggle_flashback", Cheats_ToggleFlashback, "Utility", "desc_flashback")
end
