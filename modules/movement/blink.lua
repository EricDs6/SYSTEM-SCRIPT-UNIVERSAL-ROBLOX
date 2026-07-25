-- =============================================================================
-- COMMAND: BLINK (Dash)
-- Dash rapido na direcao que olha. Tecla Q
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
					-- Dash instantaneo na direcao da camera (igual Op.txt)
					local direction = cam.CFrame.LookVector
					hrp.CFrame = hrp.CFrame + direction * 15
					GH.ShowToast("Blink! 15 studs a frente", GH.Theme.Accent, 1)
				end
			end)
			GH.ShowToast("Blink: pressione Q para dash", GH.Theme.Accent, 2)
		end
	end

	GH.RegisterToggleButton("Blink", "toggle_blink", Cheats_ToggleBlink, "Movement", "desc_blink")
end
