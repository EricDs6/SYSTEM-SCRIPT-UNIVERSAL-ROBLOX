-- =============================================================================
-- COMMAND: BLINK (Dash)
-- =============================================================================
return function(GH)
	local UserInputService = GH.Services.UserInputService
	local LocalPlayer = GH.LocalPlayer

	function Cheats_ToggleBlink(state, btn)
		GH.Disconnect("Blink")
		local blinkKey = GH.GetKeyCode("Blink")
		if blinkKey then GH.InputManager.Unbind(blinkKey) end

		if state and blinkKey then
			GH.InputManager.Bind(blinkKey, function()
				local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
				local cam = workspace.CurrentCamera
				if hrp and cam then
					GH.TweenTeleport(hrp, hrp.CFrame + cam.CFrame.LookVector * 15)
					GH.ShowToast("Blink!", GH.Theme.Accent, 1)
				end
			end)
		end
	end

	GH.RegisterToggleButton("Blink", GH.T("toggle_blink"), Cheats_ToggleBlink, "Movement", GH.T("desc_blink"))
end