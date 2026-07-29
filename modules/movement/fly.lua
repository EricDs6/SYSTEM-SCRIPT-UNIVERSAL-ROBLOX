-- =============================================================================
-- COMMAND: FLY (Profissional - Orientado à Câmera com Trava de Altura)
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

		local char = LocalPlayer.Character
		local hrp = char and char:FindFirstChild("HumanoidRootPart")
		local hum = char and char:FindFirstChildOfClass("Humanoid")

		-- Limpa instâncias de força de voo anteriores
		if hrp then
			local oldBv = hrp:FindFirstChild("GH_FlyBV")
			if oldBv then oldBv:Destroy() end
		end

		if not state then
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

		if not hum or not hrp then return end

		for k in pairs(keys) do keys[k] = false end

		hum.AutoRotate = false
		hum.PlatformStand = true

		-- Cria um BodyVelocity para travar a gravidade e flutuar com estabilidade total
		local bv = Instance.new("BodyVelocity")
		bv.Name = "GH_FlyBV"
		bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
		bv.Velocity = Vector3.zero
		bv.Parent = hrp

		-- Captura de entradas (Began)
		GH.Connections.Fly_InputBegan = UserInputService.InputBegan:Connect(function(input, gpe)
			if gpe then return end
			if not GH.States.Fly then return end
			local name = input.KeyCode.Name
			if keys[name] ~= nil then
				keys[name] = true
			end
		end)

		-- Captura de entradas (Ended)
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

		-- Loop Principal (RenderStepped)
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

			-- Garante que o BodyVelocity ainda está ativo na HRP
			local currentBv = myHrp:FindFirstChild("GH_FlyBV")
			if not currentBv then
				currentBv = Instance.new("BodyVelocity")
				currentBv.Name = "GH_FlyBV"
				currentBv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
				currentBv.Velocity = Vector3.zero
				currentBv.Parent = myHrp
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

			-- Aplica velocidade ou congela a posição no ar
			if moveDir.Magnitude > 0 then
				moveDir = moveDir.Unit * currentSpeed
				currentBv.Velocity = moveDir
			else
				-- Quando nenhuma tecla está apertada, anula a velocidade para flutuar sem afundar
				currentBv.Velocity = Vector3.zero
			end

			-- Zera velocidades da física nativa
			myHrp.AssemblyLinearVelocity = Vector3.zero
			myHrp.AssemblyAngularVelocity = Vector3.zero

			-- Atualiza a orientação do avatar para olhar diretamente para onde a câmera aponta
			myHrp.CFrame = CFrame.new(myHrp.Position, myHrp.Position + camCF.LookVector)

			-- Sistema de Noclip durante o voo
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