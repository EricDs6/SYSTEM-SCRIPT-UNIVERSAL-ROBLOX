-- =============================================================================
-- COMMAND: SPRINT
-- Correr mais segurando Shift
-- =============================================================================
return function(GH)
	local UserInputService = GH.Services.UserInputService
	local RunService = GH.Services.RunService
	local LocalPlayer = GH.LocalPlayer

	local sprintSpeed = 32
	local origSpeed = 16
	local isSprinting = false

	function Cheats_ToggleSprint(state, btn)
		GH.Disconnect("Sprint_Input")
		GH.Disconnect("Sprint_Speed")

		-- Restaurar velocidade
		local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
		if hum then
			hum.WalkSpeed = origSpeed
		end

		if not state then return end

		-- Salvar velocidade original
		if hum then
			origSpeed = hum.WalkSpeed
		end

		-- InputBegan: Shift pressionado = sprintar
		GH.Connections.Sprint_Input = UserInputService.InputBegan:Connect(function(input, gpe)
			if gpe then return end
			if not GH.States.Sprint then return end
			if input.KeyCode == Enum.KeyCode.LeftShift then
				isSprinting = true
				local h = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
				if h then
					h.WalkSpeed = sprintSpeed
				end
			end
		end)

		-- InputEnded: Shift solto = voltar ao normal
		UserInputService.InputEnded:Connect(function(input)
			if input.KeyCode == Enum.KeyCode.LeftShift then
				isSprinting = false
				local h = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
				if h and GH.States.Sprint then
					h.WalkSpeed = origSpeed
				end
			end
		end)

		-- Reconectar ao respawn
		GH.Connections.Sprint_Speed = LocalPlayer.CharacterAdded:Connect(function(char)
			if not GH.States.Sprint then return end
			task.wait(0.5)
			local h = char:FindFirstChildOfClass("Humanoid")
			if h then
				origSpeed = h.WalkSpeed
				if isSprinting then
					h.WalkSpeed = sprintSpeed
				end
			end
		end)

		GH.ShowToast("Sprint: segure Shift para correr", GH.Theme.On, 2)
	end

	GH.RegisterToggleButton("Sprint", "toggle_sprint", Cheats_ToggleSprint, "Movement", "desc_sprint")
end
