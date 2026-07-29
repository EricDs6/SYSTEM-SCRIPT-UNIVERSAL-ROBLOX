-- =============================================================================
-- COMMAND: FLY (Profissional - Orientado à Câmera)
-- Voar livremente com WASD + Space/Ctrl. Shift = Boost | +/- = Velocidade
-- =============================================================================
return function(GH)
	local UserInputService = GH.Services.UserInputService
	local RunService = GH.Services.RunService
	local LocalPlayer = GH.LocalPlayer

	local noclipParts = {}
	local keys = { W = false, A = false, S = false, D = false, Space = false, LeftShift = false, LeftControl = false }

	local function clearNoclip()
		for p, _ in pairs(noclipParts) do
			if p and p.Parent then
				pcall(function() p.CanCollide = true end)
			end
		end
		table.clear(noclipParts)
	end

	function Cheats_ToggleFly(state, btn)
		GH.Disconnect("Fly_Stepped")
		GH.Disconnect("Fly_InputBegan")
		GH.Disconnect("Fly_InputEnded")
		GH.Disconnect("Fly_Scroll")
		clearNoclip()

		if not state then
			local char = LocalPlayer.Character
			local hrp = char and char:FindFirstChild("HumanoidRootPart")
			local hum = char and char:FindFirstChildOfClass("Humanoid")

			if hrp then
				hrp.AssemblyLinearVelocity = Vector3.zero
				hrp.AssemblyAngularVelocity = Vector3.zero
			end

			if hum then
				hum.AutoRotate = true
				hum.PlatformStand = false
				hum:SetStateEnabled(Enum.HumanoidStateType.Freefall, true)
				hum:ChangeState(Enum.HumanoidStateType.GettingUp)
			end

			for k in pairs(keys) do keys[k] = false end
			return
		end

		local char = LocalPlayer.Character
		local hum = char and char:FindFirstChildOfClass("Humanoid")
		local hrp = char and char:FindFirstChild("HumanoidRootPart")
		if not hum or not hrp then return end

		for k in pairs(keys) do keys[k] = false end

		hum.AutoRotate = false
		hum.PlatformStand = true -- Libera a rotação do corpo nos 3 eixos sem o Roblox forçar ficar de pé

		-- Captura de entradas
		GH.Connections.Fly_InputBegan = UserInputService.InputBegan:Connect(function(input, gpe)
			if gpe then return end
			if not GH.States.Fly then return end
			local name = input.KeyCode.Name
			if keys[name] ~= nil then
				keys[name] = true
			end
		end)

		GH.Connections.Fly_InputEnded = UserInputService.InputEnded:Connect(function(input)
			local name = input.KeyCode.Name
			if keys[name] ~= nil then
				keys[name] = false
			end
		end)

		-- Ajuste de velocidade pelas teclas + / -
		GH.Connections.Fly_Scroll = UserInputService.InputBegan:Connect(function(input, gpe)
			if gpe then return end
			if not GH.States.Fly then return end
			if input.KeyCode == Enum.KeyCode.Equals or input.KeyCode == Enum.KeyCode.KeypadPlus then
				GH.FlySpeed = math.clamp((GH.FlySpeed or 50) + 10, 10, 300)
				if GH.ShowToast then GH.ShowToast("Fly Speed: " .. GH.FlySpeed, GH.Theme.Accent, 1) end
			elseif input.KeyCode == Enum.KeyCode.Minus or input.KeyCode == Enum.KeyCode.KeypadMinus then
				GH.FlySpeed = math.clamp((GH.FlySpeed or 50) - 10, 10, 300)
				if GH.ShowToast then GH.ShowToast("Fly Speed: " .. GH.FlySpeed, GH.Theme.Accent, 1) end
			end
		end)

		-- Loop Principal (Orientação de Câmera e Teclado)
		GH.Connections.Fly_Stepped = RunService.RenderStepped:Connect(function(dt)
			if GH.isClosing then return end

			local myChar = LocalPlayer.Character
			local myHrp = myChar and myChar:FindFirstChild("HumanoidRootPart")
			local myHum = myChar and myChar:FindFirstChildOfClass("Humanoid")

			if not myChar or not myHrp or not myHum or myHum.Health <= 0 then
				GH.Disconnect("Fly_Stepped")
				GH.Disconnect("Fly_InputBegan")
				GH.Disconnect("Fly_InputEnded")
				GH.Disconnect("Fly_Scroll")
				clearNoclip()
				return
			end

			myHum.PlatformStand = true

			local cam = workspace.CurrentCamera
			if not cam then return end
			local camCF = cam.CFrame

			-- Calcula a velocidade atual
			local currentSpeed = GH.FlySpeed or 50
			if keys.LeftShift then
				currentSpeed = currentSpeed * 2
			end

			-- Vetores direcionais baseados no olhar da Câmera
			local moveDir = Vector3.zero

			if keys.W then moveDir = moveDir + camCF.LookVector end
			if keys.S then moveDir = moveDir - camCF.LookVector end
			if keys.D then moveDir = moveDir + camCF.RightVector end
			if keys.A then moveDir = moveDir - camCF.RightVector end
			if keys.Space then moveDir = moveDir + Vector3.new(0, 1, 0) end
			if keys.LeftControl then moveDir = moveDir - Vector3.new(0, 1, 0) end

			-- Normalização do vetor para movimento uniforme
			if moveDir.Magnitude > 0 then
				moveDir = moveDir.Unit * currentSpeed
			end

			-- Aplica velocidade e ZERA forças angulares para não derivar
			myHrp.AssemblyLinearVelocity = moveDir
			myHrp.AssemblyAngularVelocity = Vector3.zero

			-- GIRA O CORPO PARA SEGUIR A CÂMERA EM TEMPO REAL
			myHrp.CFrame = CFrame.new(myHrp.Position, myHrp.Position + camCF.LookVector)

			-- Sistema de Noclip dinâmico durante o voo
			for p, _ in pairs(noclipParts) do
				if not p or not p.Parent then
					noclipParts[p] = nil
				else
					local dist = (p.Position - myHrp.Position).Magnitude
					if dist > 6 then
						pcall(function() p.CanCollide = true end)
						noclipParts[p] = nil
					end
				end
			end

			for _, part in ipairs(myChar:GetDescendants()) do
				if part:IsA("BasePart") then
					part.CanCollide = false
				end
			end

			local overlapParams = OverlapParams.new()
			overlapParams.FilterDescendantsInstances = { myChar }
			overlapParams.FilterType = Enum.RaycastFilterType.Exclude
			local parts = workspace:GetPartBoundsInBox(myHrp.CFrame, Vector3.new(4, 4, 4), overlapParams)
			for _, p in ipairs(parts) do
				if p:IsA("BasePart") and p.CanCollide then
					p.CanCollide = false
					noclipParts[p] = true
				end
			end
		end)

		if GH.ShowToast then
			GH.ShowToast("Fly: WASD+Space/Ctrl | Shift=Boost | +/- Speed (" .. (GH.FlySpeed or 50) .. ")", GH.Theme.On, 3)
		end
	end

	-- Reconectar ao respawn do jogador
	GH.Connections.Fly_CharAdded = LocalPlayer.CharacterAdded:Connect(function()
		if GH.States and GH.States.Fly then
			task.wait(0.5)
			GH.States.Fly = false
			Cheats_ToggleFly(false, nil)
			task.wait(0.2)
			GH.States.Fly = true
			Cheats_ToggleFly(true, nil)
		end
	end)

	GH.RegisterToggleButton("Fly", "toggle_fly", Cheats_ToggleFly, "Movement", "desc_fly")
end