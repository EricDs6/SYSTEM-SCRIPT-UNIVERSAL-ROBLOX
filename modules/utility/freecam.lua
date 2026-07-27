-- =============================================================================
-- COMMAND: FREECAM (Estilo FE Cosmic — Spring-based)
-- Camera livre + interacao (F = teleportar personagem)
-- =============================================================================
return function(GH)
	local Players = GH.Services.Players
	local RunService = GH.Services.RunService
	local UserInputService = GH.Services.UserInputService
	local TweenService = GH.Services.TweenService
	local LocalPlayer = GH.LocalPlayer

	local Spring = {}
	Spring.__index = Spring

	function Spring.new(freq, pos)
		local self = setmetatable({}, Spring)
		self.f = freq
		self.p = pos
		self.v = pos * 0
		return self
	end

	function Spring:Update(dt, goal)
		local f = self.f * 2 * math.pi
		local p0 = self.p
		local v0 = self.v
		local offset = goal - p0
		local decay = math.exp(-f * dt)
		local p1 = goal + (v0 * dt - offset * (f * dt + 1)) * decay
		local v1 = (f * dt * (offset * f - v0) + v0) * decay
		self.p = p1
		self.v = v1
		return p1
	end

	function Spring:Reset(pos)
		self.p = pos
		self.v = pos * 0
	end

	local FCState = {
		running = false,
		cameraPos = Vector3.new(),
		cameraRot = Vector2.new(),
		cameraFov = 70,
		origType = nil,
		origCF = nil,
		velSpring = Spring.new(5, Vector3.new()),
		panSpring = Spring.new(5, Vector2.new()),
		keys = { W = 0, A = 0, S = 0, D = 0, E = 0, Q = 0, Up = 0, Down = 0 },
		mouse = { Delta = Vector2.new() },
		navSpeed = 1,
	}

	local function FCKeypress(action, state, input)
		FCState.keys[input.KeyCode.Name] = state == Enum.UserInputState.Begin and 1 or 0
		return Enum.ContextActionResult.Sink
	end

	local function FCMousePan(action, state, input)
		FCState.mouse.Delta = Vector2.new(-input.Delta.Y, -input.Delta.X)
		return Enum.ContextActionResult.Sink
	end

	local function FCStartCapture()
		pcall(function()
			local CAS = game:GetService("ContextActionService")
			CAS:BindActionAtPriority("GH_FCKeys", FCKeypress, false, Enum.ContextActionPriority.High.Value,
				Enum.KeyCode.W, Enum.KeyCode.A, Enum.KeyCode.S, Enum.KeyCode.D,
				Enum.KeyCode.E, Enum.KeyCode.Q, Enum.KeyCode.Up, Enum.KeyCode.Down)
			CAS:BindActionAtPriority("GH_FCMouse", FCMousePan, false, Enum.ContextActionPriority.High.Value,
				Enum.UserInputType.MouseMovement)
		end)
	end

	local function FCStopCapture()
		FCState.navSpeed = 1
		for k, _ in pairs(FCState.keys) do FCState.keys[k] = 0 end
		FCState.mouse.Delta = Vector2.new()
		pcall(function()
			local CAS = game:GetService("ContextActionService")
			CAS:UnbindAction("GH_FCKeys")
			CAS:UnbindAction("GH_FCMouse")
		end)
	end

	local function FCGetFocusDistance(cameraFrame)
		local znear = 0.1
		local viewport = workspace.CurrentCamera.ViewportSize
		local projy = 2 * math.tan(math.rad(FCState.cameraFov / 2))
		local projx = viewport.X / viewport.Y * projy
		local fx = cameraFrame.RightVector
		local fy = cameraFrame.UpVector
		local fz = cameraFrame.LookVector
		local minVect = Vector3.new()
		local minDist = 512
		for x = 0, 1, 0.5 do
			for y = 0, 1, 0.5 do
				local cx = (x - 0.5) * projx
				local cy = (y - 0.5) * projy
				local offset = fx * cx - fy * cy + fz
				local origin = cameraFrame.Position + offset * znear
				local rayResult = workspace:Raycast(origin, offset.Unit * minDist)
				if rayResult then
					local dist = (rayResult.Position - origin).Magnitude
					if minDist > dist then
						minDist = dist
						minVect = offset.Unit
					end
				end
			end
		end
		return fz:Dot(minVect) * minDist
	end

	local function FCVel()
		local shift = UserInputService:IsKeyDown(Enum.KeyCode.LeftShift)
		FCState.navSpeed = math.clamp(FCState.navSpeed + (FCState.keys.Up - FCState.keys.Down) * 0.75, 0.01, 4)
		local k = Vector3.new(FCState.keys.D - FCState.keys.A, FCState.keys.E - FCState.keys.Q, FCState.keys.S - FCState.keys.W)
		return k * (FCState.navSpeed * (shift and 0.25 or 1))
	end

	local function FCPan()
		local kMouse = FCState.mouse.Delta * (math.pi / 64)
		FCState.mouse.Delta = Vector2.new()
		return kMouse
	end

	-- Teleportar personagem pra posicao da camera
	local function FCTeleportToCamera()
		local cam = workspace.CurrentCamera
		local char = LocalPlayer.Character
		local hrp = char and char:FindFirstChild("HumanoidRootPart")
		local hum = char and char:FindFirstChildOfClass("Humanoid")
		if cam and hrp and hum then
			-- Raycast pra encontrar o chao abaixo da camera
			local rayParams = RaycastParams.new()
			rayParams.FilterDescendantsInstances = { char }
			rayParams.FilterType = Enum.RaycastFilterType.Exclude
			local ray = workspace:Raycast(cam.CFrame.Position, Vector3.new(0, -50, 0), rayParams)

			local targetPos
			if ray then
				targetPos = ray.Position + Vector3.new(0, 3, 0)
			else
				targetPos = cam.CFrame.Position + Vector3.new(0, 3, 0)
			end

		GH.TweenTeleport(hrp, CFrame.new(targetPos, targetPos + cam.CFrame.LookVector))
		hum.PlatformStand = false
		hum:ChangeState(Enum.HumanoidStateType.GettingUp)
		GH.ShowToast("Teleportado!", GH.Theme.On, 1)
		end
	end

	-- Interagir com ClickDetector/ProximityPrompt mais proximo
	local function FCInteract()
		local cam = workspace.CurrentCamera
		if not cam then return end

		-- Raycast na direcao da camera
		local rayParams = RaycastParams.new()
		rayParams.FilterDescendantsInstances = { LocalPlayer.Character }
		rayParams.FilterType = Enum.RaycastFilterType.Exclude

		local ray = workspace:Raycast(cam.CFrame.Position, cam.CFrame.LookVector * 50, rayParams)
		if not ray then return end

		local hit = ray.Instance
		if not hit then return end

		-- Procurar ClickDetector ou ProximityPrompt
		local detector = hit:FindFirstChildWhichIsA("ClickDetector")
			or hit.Parent:FindFirstChildWhichIsA("ClickDetector")
			or hit:FindFirstChildWhichIsA("ProximityPrompt")
			or hit.Parent:FindFirstChildWhichIsA("ProximityPrompt")

		if detector then
			if detector:IsA("ClickDetector") then
				detector:FireClick()
				GH.ShowToast("ClickDetector ativado!", GH.Theme.On, 1)
			elseif detector:IsA("ProximityPrompt") then
				pcall(function() detector:InputBegin(LocalPlayer) end)
				task.delay(0.1, function()
					pcall(function() detector:InputEnd(LocalPlayer) end)
				end)
				GH.ShowToast("ProximityPrompt ativado!", GH.Theme.On, 1)
			end
		else
			-- Sem detector, teleportar pro objeto
			FCTeleportToCamera()
		end
	end

	local function FCStep(dt)
		if not FCState.running then return end
		local vel = FCState.velSpring:Update(dt, FCVel())
		local pan = FCState.panSpring:Update(dt, FCPan())
		local zoomFactor = math.sqrt(math.tan(math.rad(70 / 2)) / math.tan(math.rad(FCState.cameraFov / 2)))
		FCState.cameraRot = FCState.cameraRot + pan * Vector2.new(0.75, 1) * 8 * (dt / zoomFactor)
		FCState.cameraRot = Vector2.new(
			math.clamp(FCState.cameraRot.X, -math.rad(90), math.rad(90)),
			FCState.cameraRot.Y % (2 * math.pi))
		local camCFrame = CFrame.new(FCState.cameraPos) * CFrame.fromOrientation(FCState.cameraRot.X, FCState.cameraRot.Y, 0) * CFrame.new(vel * 64 * dt)
		FCState.cameraPos = camCFrame.Position
		workspace.CurrentCamera.CFrame = camCFrame
		workspace.CurrentCamera.Focus = camCFrame * CFrame.new(0, 0, -FCGetFocusDistance(camCFrame))
		workspace.CurrentCamera.FieldOfView = FCState.cameraFov
	end

	function Cheats_ToggleFreecam(state, btn)
		GH.Disconnect("Freecam")
		GH.Disconnect("Freecam_Input")

		if FCState.running then
			FCStopCapture()
			RunService:UnbindFromRenderStep("GH_Freecam")
			local cam = workspace.CurrentCamera
			if cam then
				cam.CameraType = FCState.origType or Enum.CameraType.Custom
				if FCState.origCF then cam.CFrame = FCState.origCF end
				cam.FieldOfView = 70
			end
			UserInputService.MouseIconEnabled = true
			FCState.running = false
		end

		if state then
			local cam = workspace.CurrentCamera
			if not cam then return end
			FCState.origType = cam.CameraType
			FCState.origCF = cam.CFrame
			FCState.cameraPos = cam.CFrame.Position
			FCState.cameraRot = Vector2.new()
			FCState.cameraFov = cam.FieldOfView

			FCState.velSpring:Reset(Vector3.new())
			FCState.panSpring:Reset(Vector2.new())

			cam.CameraType = Enum.CameraType.Custom
			UserInputService.MouseIconEnabled = true
			UserInputService.MouseBehavior = Enum.MouseBehavior.Default

			FCStartCapture()
			FCState.running = true
			RunService:BindToRenderStep("GH_Freecam", Enum.RenderPriority.Camera.Value, FCStep)

			-- Teclas de interacao
			GH.Connections.Freecam_Input = UserInputService.InputBegan:Connect(function(input, gpe)
				if gpe then return end
				if not GH.States.Freecam then return end
				-- F = teleportar personagem
				if input.KeyCode == Enum.KeyCode.F then
					FCTeleportToCamera()
				end
				-- G = interagir com ClickDetector/ProximityPrompt
				if input.KeyCode == Enum.KeyCode.G then
					FCInteract()
				end
			end)

			GH.ShowToast("Freecam: WASD+QE+Mouse | F=TP | G=Interagir", GH.Theme.On, 3)
		end
	end

	GH.RegisterToggleButton("Freecam", "toggle_freecam", Cheats_ToggleFreecam, "Utility", "desc_freecam")
end
