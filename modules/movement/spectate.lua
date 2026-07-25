-- =============================================================================
-- COMMAND: SPECTATE
-- =============================================================================
return function(GH)
	local Players = GH.Services.Players
	local LocalPlayer = GH.LocalPlayer

	function Cheats_ToggleSpectate(state, btn)
		GH.Disconnect("SpectateDied")

		if not state then
			if GH.Objects.SpectatePicker then
				GH.Objects.SpectatePicker.Close()
				GH.Objects.SpectatePicker = nil
			end
			workspace.CurrentCamera.CameraSubject = LocalPlayer.Character
			return
		end

		local picker = GH.ShowPlayerPicker(GH.T("dropdown_spectate_title"), function(name)
			local player = Players:FindFirstChild(name)
			if player then
				GH.Disconnect("SpectateDied")
				if player.Character then
					workspace.CurrentCamera.CameraSubject = player.Character
				end
				GH.Connections.SpectateDied = player.CharacterAdded:Connect(function(char)
					workspace.CurrentCamera.CameraSubject = char
				end)
			end
		end)
		GH.Objects.SpectatePicker = picker
	end

	GH.RegisterToggleButton("Spectate", "toggle_spectate", Cheats_ToggleSpectate, "Movement", "desc_spectate")
end
