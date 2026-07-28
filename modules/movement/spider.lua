-- =============================================================================
-- COMMAND: SPIDER / WALL CLIMB
-- Escalar paredes ao andar na direcao delas
-- =============================================================================
return function(GH)
	local RunService = GH.Services.RunService
	local Workspace = GH.Services.Workspace
	local LocalPlayer = GH.LocalPlayer

	local climbSpeed = 25
	local rayDistance = 2.5

	-- Funcao de verificacao de parede via Raycast
	local function IsFacingWall(character)
		local rootPart = character:FindFirstChild("HumanoidRootPart")
		if not rootPart then return false end

		local raycastParams = RaycastParams.new()
		raycastParams.FilterDescendantsInstances = { character }
		raycastParams.FilterType = Enum.RaycastFilterType.Exclude

		-- Dispara um raio para a frente do jogador
		local rayResult = Workspace:Raycast(
			rootPart.Position,
			rootPart.CFrame.LookVector * rayDistance,
			raycastParams
		)

		return rayResult ~= nil
	end

	function Cheats_ToggleSpider(state, btn)
		GH.Disconnect("Spider_Stepped")

		if not state then
			return
		end

		-- Ativa a verificacao a cada frame
		GH.Connections.Spider_Stepped = RunService.Heartbeat:Connect(function()
			if GH.isClosing then return end
			if not GH.States.Spider then
				GH.Disconnect("Spider_Stepped")
				return
			end

			local character = LocalPlayer.Character
			if not character then return end

			local rootPart = character:FindFirstChild("HumanoidRootPart")
			local humanoid = character:FindFirstChildWhichIsA("Humanoid")

			if rootPart and humanoid then
				-- Se estiver andando em direcao a uma parede e pressionando W
				if IsFacingWall(character) and humanoid.MoveDirection.Magnitude > 0 then
					-- Aplica velocidade para cima mantendo a velocidade horizontal
					rootPart.AssemblyLinearVelocity = Vector3.new(
						rootPart.AssemblyLinearVelocity.X,
						climbSpeed,
						rootPart.AssemblyLinearVelocity.Z
					)
				end
			end
		end)

		GH.ShowToast(GH.T("toast_spider_active"), GH.Theme.On, 2)
	end

	-- Reconectar ao respawn
	GH.Connections.Spider_CharAdded = LocalPlayer.CharacterAdded:Connect(function()
		if GH.States.Spider then
			task.wait(0.5)
			GH.States.Spider = false
			Cheats_ToggleSpider(false, nil)
			task.wait(0.5)
			if GH.States.Spider == false then
				GH.States.Spider = true
				Cheats_ToggleSpider(true, nil)
			end
		end
	end)

	GH.RegisterToggleButton("Spider", "toggle_spider", Cheats_ToggleSpider, "Movement", "desc_spider")
end
