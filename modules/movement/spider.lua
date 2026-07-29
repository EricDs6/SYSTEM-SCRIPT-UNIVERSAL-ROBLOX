-- =============================================================================
-- COMMAND: SPIDER / WALL CLIMB (VERSÃO LISA E ESTÁVEL)
-- Detecta parede à frente e sobe ao segurar W
-- =============================================================================
return function(GH)
	local RunService = GH.Services.RunService
	local LocalPlayer = GH.LocalPlayer

	local climbSpeed = 20
	local rayDistance = 3.5

	-- Função para detectar parede e retornar o resultado do raycast
	local function GetWallHit(character)
		local rootPart = character:FindFirstChild("HumanoidRootPart")
		if not rootPart then return nil end

		local raycastParams = RaycastParams.new()
		raycastParams.FilterDescendantsInstances = { character }
		raycastParams.FilterType = Enum.RaycastFilterType.Exclude

		-- Checa à frente e para os lados levemente
		local directions = {
			rootPart.CFrame.LookVector,
			rootPart.CFrame.LookVector + rootPart.CFrame.RightVector * 0.5,
			rootPart.CFrame.LookVector - rootPart.CFrame.RightVector * 0.5,
		}

		for _, dir in ipairs(directions) do
			local rayResult = workspace:Raycast(rootPart.Position, dir.Unit * rayDistance, raycastParams)
			if rayResult and rayResult.Instance then
				local normalUpDot = math.abs(rayResult.Normal:Dot(Vector3.yAxis))
				if normalUpDot < 0.7 then -- Apenas superfícies verticais
					return rayResult
				end
			end
		end
		return nil
	end

	function Cheats_ToggleSpider(state, btn)
		GH.Disconnect("Spider_Stepped")

		local char = LocalPlayer.Character
		if not char then return end
		local hrp = char:FindFirstChild("HumanoidRootPart")
		local hum = char:FindFirstChildWhichIsA("Humanoid")

		if not state then
			if hrp then
				hrp.AssemblyLinearVelocity = Vector3.zero
			end
			if hum then
				hum:SetStateEnabled(Enum.HumanoidStateType.Freefall, true)
				pcall(function() hum:ChangeState(Enum.HumanoidStateType.GettingUp) end)
			end
			return
		end

		if not hrp or not hum then return end

		local isClimbing = false

		GH.Connections.Spider_Stepped = RunService.Heartbeat:Connect(function()
			if GH.isClosing or not GH.States.Spider then
				GH.Disconnect("Spider_Stepped")
				return
			end

			local currentCharacter = LocalPlayer.Character
			if not currentCharacter then return end
			local root = currentCharacter:FindFirstChild("HumanoidRootPart")
			local humanoid = currentCharacter:FindFirstChildWhichIsA("Humanoid")

			if not root or not humanoid then return end

			local wallHit = GetWallHit(currentCharacter)

			-- Se detectou parede e o player está tentando se mover para a frente (segurando W)
			if wallHit and humanoid.MoveDirection.Magnitude > 0 then
				if not isClimbing then
					isClimbing = true
				end

				-- Zera a velocidade de queda da gravidade
				local currentVel = root.AssemblyLinearVelocity

				-- Aplica a velocidade exata no eixo Y sem alterar a velocidade horizontal das teclas
				root.AssemblyLinearVelocity = Vector3.new(currentVel.X, climbSpeed, currentVel.Z)

				-- Altera o estado do humanoide para Climbing para desativar a gravidade nativa
				if humanoid:GetState() ~= Enum.HumanoidStateType.Climbing then
					humanoid:ChangeState(Enum.HumanoidStateType.Climbing)
				end
			else
				if isClimbing then
					isClimbing = false
				end
			end
		end)			if GH.ShowToast then
				GH.ShowToast(GH.T("toast_spider_active"), GH.Theme.On, 2)
			end
	end

	-- Auto-Reconectar ao Respawn
	GH.Connections.Spider_CharAdded = LocalPlayer.CharacterAdded:Connect(function()
		if GH.States.Spider then
			task.wait(0.5)
			GH.States.Spider = false
			Cheats_ToggleSpider(false, nil)
			task.wait(0.5)
			GH.States.Spider = true
			Cheats_ToggleSpider(true, nil)
		end
	end)

	GH.RegisterToggleButton("Spider", "toggle_spider", Cheats_ToggleSpider, "Movement", "desc_spider")
end
