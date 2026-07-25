-- =============================================================================
-- COMMAND: FLY
-- Voar pelo mapa com WASD. Scroll ajusta velocidade
-- =============================================================================
return function(GH)
	local UserInputService = GH.Services.UserInputService
	local RunService = GH.Services.RunService
	local LocalPlayer = GH.LocalPlayer

	local flying = false
	local flySpeed = 50
	local boostMultiplier = 2
	local flySpeedMult = 1
	local keys = {
		W = false,
		A = false,
		S = false,
		D = false,
		Space = false,
		LeftControl = false,
		LeftShift = false,
	}

	local function stopFly()
		flying = false
		GH.Disconnect("Fly_Render")
		GH.Disconnect("Fly_InputBegan")
		GH.Disconnect("Fly_InputEnded")
		GH.Disconnect("Fly_Scroll")

		local char = LocalPlayer.Character
		if not char then return end

		local hrp = char:FindFirstChild("HumanoidRootPart")
		local hum = char:FindFirstChildOfClass("Humanoid")

		if hrp then
			hrp.Anchored = false
			hrp.AssemblyLinearVelocity = Vector3.zero
			hrp.AssemblyAngularVelocity = Vector3.zero
		end

		if hum then
			hum.PlatformStand = false
			hum.AutoRotate = true
			hum.WalkSpeed = 16
			hum.JumpPower = 50
		end

		for k in pairs(keys) do keys[k] = false end
	end

	local function startFly()
		local char = LocalPlayer.Character
		if not char then return end

		local hrp = char:FindFirstChild("HumanoidRootPart")
		local hum = char:FindFirstChildOfClass("Humanoid")
		if not hrp or not hum then return end

		flying = true
		hum.PlatformStand = true
		hum.AutoRotate = false
		hum.WalkSpeed = 0
		hum.JumpPower = 0
		hrp.Anchored = true

		local cam = workspace.CurrentCamera

		-- RenderStepped: mover o player
		GH.Connections.Fly_Render = RunService.RenderStepped:Connect(function(deltaTime)
			if not flying or not GH.States.Fly then
				stopFly()
				return
			end

			if not char.Parent or not hrp.Parent or not hum.Parent then
				stopFly()
				return
			end

			cam = workspace.CurrentCamera
			if not cam then return end

			local moveV = (keys.W and 1 or 0) + (keys.S and -1 or 0)
			local moveH = (keys.D and 1 or 0) + (keys.A and -1 or 0)
			local vert = (keys.Space and 1 or 0) + (keys.LeftControl and -1 or 0)

			local lookVec = cam.CFrame.LookVector
			local rightVec = cam.CFrame.RightVector

			local flatLook = Vector3.new(lookVec.X, 0, lookVec.Z)
			if flatLook.Magnitude > 0 then flatLook = flatLook.Unit end

			local flatRight = Vector3.new(rightVec.X, 0, rightVec.Z)
			if flatRight.Magnitude > 0 then flatRight = flatRight.Unit end

			local moveDir = (flatLook * moveV) + (flatRight * moveH) + Vector3.new(0, vert, 0)
			if moveDir.Magnitude > 0 then moveDir = moveDir.Unit end

			local currentSpeed = flySpeed * flySpeedMult * (keys.LeftShift and boostMultiplier or 1)
			local newPos = hrp.Position + (moveDir * currentSpeed * deltaTime)

			local lookAt = newPos + flatLook
			hrp.CFrame = CFrame.lookAt(newPos, lookAt)

			hrp.AssemblyLinearVelocity = Vector3.zero
			hrp.AssemblyAngularVelocity = Vector3.zero
		end)

		-- InputBegan: pressionar teclas
		GH.Connections.Fly_InputBegan = UserInputService.InputBegan:Connect(function(input, gameProcessed)
			if gameProcessed then return end
			if not GH.States.Fly then return end
			if keys[input.KeyCode.Name] ~= nil then
				keys[input.KeyCode.Name] = true
			end
		end)

		-- InputEnded: soltar teclas
		GH.Connections.Fly_InputEnded = UserInputService.InputEnded:Connect(function(input)
			if keys[input.KeyCode.Name] ~= nil then
				keys[input.KeyCode.Name] = false
			end
		end)

		-- Scroll: ajustar velocidade
		GH.Connections.Fly_Scroll = UserInputService.InputChanged:Connect(function(input)
			if not GH.States.Fly then return end
			if input.UserInputType == Enum.UserInputType.MouseWheel then
				local dir = input.Position.Z > 0 and 1 or -1
				flySpeedMult = math.clamp(flySpeedMult + dir * 0.25, 0.25, 5)
			end
		end)
	end

	function Cheats_ToggleFly(state, btn)
		stopFly()
		if state then
			flySpeedMult = 1
			startFly()
		end
	end

	-- Parar fly ao morrer/respawnar
	GH.Connections.Fly_CharAdded = LocalPlayer.CharacterAdded:Connect(function()
		if GH.States.Fly then
			task.wait(0.5)
			stopFly()
			if GH.States.Fly then
				startFly()
			end
		end
	end)

	GH.RegisterToggleButton("Fly", "toggle_fly", Cheats_ToggleFly, "Movement", "desc_fly")
end
