-- =============================================================================
-- COMMAND: THIRD PERSON
-- Forca visao em terceira pessoa
-- =============================================================================
return function(GH)
	local UserInputService = GH.Services.UserInputService
	local RunService = GH.Services.RunService
	local Players = GH.Services.Players
	local LocalPlayer = GH.LocalPlayer

	local origCameraType = nil
	local origCameraOffset = nil

	function Cheats_ToggleThirdPerson(state, btn)
		GH.UnregisterMasterLoop("ThirdPerson")

		if not state then
			-- Restaurar camera original
			local cam = workspace.CurrentCamera
			local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
			if cam then
				if origCameraType then cam.CameraType = origCameraType end
				if hum and origCameraOffset then hum.CameraOffset = origCameraOffset end
			end
			return
		end

		-- Salvar estado original
		local cam = workspace.CurrentCamera
		local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
		if cam then origCameraType = cam.CameraType end
		if hum then origCameraOffset = hum.CameraOffset end

		-- Forcar terceira pessoa
		GH.RegisterMasterLoop("ThirdPerson", "Render", function()
			if GH.isClosing or not GH.States.ThirdPerson then
				GH.UnregisterMasterLoop("ThirdPerson")
				return
			end

			local c = workspace.CurrentCamera
			local ch = LocalPlayer.Character
			local h = ch and ch:FindFirstChildOfClass("Humanoid")
			local root = ch and ch:FindFirstChild("HumanoidRootPart")

			if c and h and root then
				-- Forcar CameraType Custom
				c.CameraType = Enum.CameraType.Custom
				c.CameraSubject = h

				-- Offset pra tras e cima (terceira pessoa)
				h.CameraOffset = Vector3.new(0, 1.5, 8)

				-- Usar UserInputService pra forcar distance se disponivel
				pcall(function()
					UserInputService.MouseBehavior = Enum.MouseBehavior.Default
				end)
			end
		end)

		GH.ShowToast("Third Person ativado!", GH.Theme.On, 2)
	end

	GH.RegisterToggleButton("ThirdPerson", "toggle_thirdperson", Cheats_ToggleThirdPerson, "Utility", "desc_thirdperson")
end
