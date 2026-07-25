-- =============================================================================
-- COMMAND: THIRD PERSON
-- Forca visao em terceira pessoa
-- =============================================================================
return function(GH)
	local RunService = GH.Services.RunService
	local LocalPlayer = GH.LocalPlayer

	function Cheats_ToggleThirdPerson(state, btn)
		GH.UnregisterMasterLoop("ThirdPerson")

		if not state then
			-- Restaurar camera
			local cam = workspace.CurrentCamera
			if cam then
				cam.CameraType = Enum.CameraType.Custom
				cam.CameraSubject = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
			end
			return
		end

		-- Forcar terceira pessoa
		GH.RegisterMasterLoop("ThirdPerson", "Render", function()
			if GH.isClosing or not GH.States.ThirdPerson then
				GH.UnregisterMasterLoop("ThirdPerson")
				return
			end

			local cam = workspace.CurrentCamera
			local char = LocalPlayer.Character
			local hum = char and char:FindFirstChildOfClass("Humanoid")

			if cam and hum then
				cam.CameraType = Enum.CameraType.Custom
				cam.CameraSubject = hum

				-- Distancia da camera (terceira pessoa)
				hum.CameraOffset = Vector3.new(0, 2, 12)
			end
		end)

		GH.ShowToast("Third Person ativado!", GH.Theme.On, 2)
	end

	GH.RegisterToggleButton("ThirdPerson", "toggle_thirdperson", Cheats_ToggleThirdPerson, "Utility", "desc_thirdperson")
end
