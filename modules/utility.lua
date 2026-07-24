-- =============================================================================
-- MODULE: UTILITY
-- =============================================================================
--!nonstrict
return function(GH)
	local Players = GH.Services.Players
	local RunService = GH.Services.RunService
	local UserInputService = GH.Services.UserInputService
	local TweenService = GH.Services.TweenService
	local LocalPlayer = GH.LocalPlayer

	-- ==========================================
	-- CLICK TP (Tool)
	-- ==========================================
	local TpTool = nil

	function Cheats_ToggleTPTool(state, btn)
		btn.Text = state and "Remover Tool TP" or "Tool TP Click"
		if state then
			local bp = LocalPlayer:WaitForChild("Backpack", 5)
			if bp then
				TpTool = Instance.new("Tool")
				TpTool.Name = "Click TP"
				TpTool.RequiresHandle = false
				TpTool.Parent = bp
				TpTool.Activated:Connect(function()
					local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
					local mouse = LocalPlayer:GetMouse()
					if hrp and mouse.Hit then
						GH.TweenTeleport(hrp, CFrame.new(mouse.Hit.Position + Vector3.new(0, 4, 0)))
					end
				end)
			end
		else
			if TpTool then TpTool:Destroy(); TpTool = nil end
		end
	end

	-- ==========================================
	-- GRAVITY
	-- ==========================================
	function Cheats_ToggleGravity(state, btn)
		btn.Text = state and "Desativar Gravity" or "Gravity Baixa"
		if state then
			GH.Cache.OrigGravity = workspace.Gravity
			workspace.Gravity = 10
		else
			workspace.Gravity = GH.Cache.OrigGravity or 196.2
		end
	end

	-- ==========================================
	-- CUSTOM SPAWN
	-- ==========================================
	function Cheats_ToggleCustomSpawn(state, btn)
		GH.Disconnect("CustomSpawnMonitor")
		GH.Disconnect("CustomSpawnDied")
		GH.Cache.SpawnCFrame = nil
		GH.Cache.ShouldSpawnAtCustom = false

		if not state then
			btn.Text = "Marcar Spawn"
			return
		end

		local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
		if not hrp then
			GH.States.CustomSpawn = false
			btn.Text = "Marcar Spawn"
			return
		end

		GH.Cache.SpawnCFrame = hrp.CFrame
		btn.Text = "Desativar Spawn"

		local function connectDiedListener()
			local c = LocalPlayer.Character
			if not c then return end
			local h = c:FindFirstChildOfClass("Humanoid")
			if not h then return end
			GH.Disconnect("CustomSpawnDied")
			GH.Connections.CustomSpawnDied = h.Died:Connect(function()
				if GH.States.CustomSpawn and GH.Cache.SpawnCFrame then
					GH.Cache.ShouldSpawnAtCustom = true
				end
			end)
		end

		connectDiedListener()

		GH.Connections.CustomSpawnMonitor = LocalPlayer.CharacterAdded:Connect(function(newChar)
			if not GH.States.CustomSpawn then return end
			task.defer(connectDiedListener)
			if GH.Cache.ShouldSpawnAtCustom and GH.Cache.SpawnCFrame then
				GH.Cache.ShouldSpawnAtCustom = false
				local function forceSpawn()
					local r = newChar:FindFirstChild("HumanoidRootPart")
					if r and GH.Cache.SpawnCFrame then
						r.CFrame = GH.Cache.SpawnCFrame
						r.AssemblyLinearVelocity = Vector3.zero
						r.AssemblyAngularVelocity = Vector3.zero
					end
				end
				forceSpawn()
				task.delay(0.05, forceSpawn)
				task.delay(0.1, forceSpawn)
				task.delay(0.2, forceSpawn)
			end
		end)
	end

	-- ==========================================
	-- FREECAM (Estilo FE Cosmic — Spring-based)
	-- ==========================================
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
		btn.Text = state and "Desativar Freecam" or "Freecam"
		GH.Disconnect("Freecam")

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
		end
	end

	-- ==========================================
	-- FLASHBACK (Voltar ao local da ultima morte)
	-- ==========================================
	GH.Cache.LastDeathCFrame = nil

	function Cheats_ToggleFlashback(state, btn)
		btn.Text = state and "Desativar Flashback" or "Flashback"
		GH.Disconnect("FlashbackDied")
		GH.Disconnect("FlashbackRespawn")

		if state then
			local function connectDied()
				local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
				if hum then
					GH.Disconnect("FlashbackDied")
					GH.Connections.FlashbackDied = hum.Died:Connect(function()
						local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
						if hrp then
							GH.Cache.LastDeathCFrame = hrp.CFrame
						end
					end)
				end
			end

			connectDied()
			GH.Connections.FlashbackRespawn = LocalPlayer.CharacterAdded:Connect(function()
				if GH.States.Flashback then connectDied() end
			end)

			GH.InputManager.Bind(Enum.KeyCode.P, function()
				if not GH.States.Flashback then return end
				if GH.Cache.LastDeathCFrame then
					local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
					if hrp then
						local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
						if hum and hum.SeatPart then hum.Sit = false end
						hrp.CFrame = GH.Cache.LastDeathCFrame
						GH.ShowToast("Flashback!", GH.Theme.Accent, 2)
					end
				end
			end)
		else
			GH.InputManager.Unbind(Enum.KeyCode.P)
		end
	end

	-- ==========================================
	-- COORDS
	-- ==========================================
	local CacheCoords = { SavedPoints = {}, GUI = nil }

	function Cheats_ToggleCoords(state, btn)
		btn.Text = state and "Fechar Coords" or "Coordenadas"
		if state then
			if CacheCoords.GUI then CacheCoords.GUI:Destroy() end
			local gui = Instance.new("ScreenGui")
			gui.Name = "GH_CoordsGUI"
			gui.ResetOnSpawn = false
			gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
			gui.Parent = GH.TargetGui
			CacheCoords.GUI = gui

			local frame = Instance.new("Frame")
			frame.Size = UDim2.new(0, 180, 0, 250)
			frame.Position = UDim2.new(0, 10, 0.5, -125)
			frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
			frame.BackgroundTransparency = 0.1
			frame.BorderSizePixel = 0
			frame.Parent = gui

			local title = Instance.new("TextLabel")
			title.Size = UDim2.new(1, 0, 0, 24)
			title.BackgroundColor3 = GH.Theme.Topbar
			title.Text = "COORDENADAS"
			title.TextColor3 = GH.Theme.Accent
			title.Font = Enum.Font.GothamBold
			title.TextSize = 10
			title.BorderSizePixel = 0
			title.Parent = frame

			local scroll = Instance.new("ScrollingFrame")
			scroll.Size = UDim2.new(1, -8, 1, -60)
			scroll.Position = UDim2.new(0, 4, 0, 28)
			scroll.BackgroundTransparency = 1
			scroll.ScrollBarThickness = 2
			scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
			scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
			scroll.BorderSizePixel = 0
			scroll.Parent = frame
			Instance.new("UIListLayout", scroll).Padding = UDim.new(0, 3)

			local saveBtn = Instance.new("TextButton")
			saveBtn.Size = UDim2.new(1, 0, 0, 24)
			saveBtn.Position = UDim2.new(0, 0, 1, -28)
			saveBtn.BackgroundColor3 = GH.Theme.AccentDim
			saveBtn.Text = "+ Salvar Posicao"
			saveBtn.TextColor3 = Color3.new(1, 1, 1)
			saveBtn.Font = Enum.Font.GothamBold
			saveBtn.TextSize = 10
			saveBtn.AutoButtonColor = false
			saveBtn.Parent = frame

			saveBtn.MouseButton1Click:Connect(function()
				local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
				if hrp then
					local pos = hrp.Position
					table.insert(CacheCoords.SavedPoints, { Name = "Ponto " .. (#CacheCoords.SavedPoints + 1), Position = pos })
					GH.ShowToast("Posicao salva!", GH.Theme.On, 2)
				end
			end)
		else
			if CacheCoords.GUI then CacheCoords.GUI:Destroy(); CacheCoords.GUI = nil end
		end
	end

	-- ==========================================
	-- SERVER REJOIN
	-- ==========================================
	function Cheats_ToggleServerRejoin(state, btn)
		if not state then btn.Text = "Server Rejoin"; return end
		btn.Text = "Reconectando..."
		task.spawn(function()
			pcall(function()
				game:GetService("TeleportService"):Teleport(game.PlaceId, LocalPlayer)
			end)
		end)
		task.delay(2, function() btn.Text = "Server Rejoin"; GH.States.ServerRejoin = false end)
	end

	-- ==========================================
	-- AUTO COLLECT
	-- ==========================================
	function Cheats_ToggleAutoCollect(state, btn)
		btn.Text = state and "Desativar AutoCollect" or "Auto Collect"
		GH.UnregisterMasterLoop("AutoCollect")
		if state then
			local tick = 0
			GH.RegisterMasterLoop("AutoCollect", "Heartbeat", function()
				if GH.isClosing or not GH.States.AutoCollect then
					GH.UnregisterMasterLoop("AutoCollect"); return
				end
				tick += 1
				if tick % 30 ~= 0 then return end
				local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
				if not hrp then return end
				pcall(function()
					for _, obj in ipairs(workspace:GetChildren()) do
						if obj:IsA("Tool") and obj:FindFirstChild("Handle") then
							if (obj.Handle.Position - hrp.Position).Magnitude <= 18 then
								if typeof(firetouchinterest) == "function" then
									firetouchinterest(hrp, obj.Handle, 0)
									firetouchinterest(hrp, obj.Handle, 1)
								else
									obj.Handle.CFrame = hrp.CFrame
								end
							end
						end
					end
				end)
			end)
		end
	end

	-- ==========================================
	-- ANTI-AFK
	-- ==========================================
	function Cheats_ToggleAntiAFK(state, btn)
		btn.Text = state and "Desativar AntiAFK" or "Anti-AFK"
		GH.Disconnect("AntiAFK")
		if state then
			GH.Connections.AntiAFK = RunService.Heartbeat:Connect(function()
				if not GH.States.AntiAFK then
					GH.Disconnect("AntiAFK"); return
				end
			end)
			task.spawn(function()
				while GH.States.AntiAFK do
					task.wait(math.random(120, 300))
					if not GH.States.AntiAFK then break end
					pcall(function()
						local VirtualUser = game:GetService("VirtualUser")
						VirtualUser:CaptureController()
						VirtualUser:ClickButton2(Vector2.new())
					end)
				end
			end)
		end
	end

	-- ==========================================
	-- ANTI-KICK
	-- ==========================================
	local OldKickFunction = nil

	function Cheats_ToggleAntiKick(state, btn)
		btn.Text = state and "Desativar AntiKick" or "Anti-Kick"
		if state then
			if not hookfunction then
				GH.ShowToast("Anti-Kick: hookfunction nao disponivel", GH.Theme.Red, 3)
				btn.Text = "Anti-Kick"; GH.States.AntiKick = false; return
			end
			OldKickFunction = hookfunction(LocalPlayer.Kick, function() end)
			GH.ShowToast("Anti-Kick ativado", GH.Theme.On, 2)
		else
			if OldKickFunction then
				pcall(function() hookfunction(LocalPlayer.Kick, OldKickFunction) end)
				OldKickFunction = nil
			end
		end
	end

	-- ==========================================
	-- AUTO-CLICKER
	-- ==========================================
	function Cheats_ToggleAutoClicker(state, btn)
		btn.Text = state and "Desativar AutoClicker" or "Auto-Clicker"
		GH.Disconnect("AutoClicker")
		local acKey = GH.GetKeyCode("AutoClicker")
		if acKey then GH.InputManager.Unbind(acKey) end
		if state and acKey then
			GH.InputManager.Bind(acKey, function()
				task.spawn(function()
					local vim = game:GetService("VirtualInputManager")
					while GH.States.AutoClicker and UserInputService:IsKeyDown(acKey) do
						pcall(function()
							vim:SendMouseButtonEvent(0, 0, 0, true, game, 0)
							task.wait(0.04)
							vim:SendMouseButtonEvent(0, 0, 0, false, game, 0)
						end)
						task.wait(0.06)
					end
				end)
			end)
		end
	end

	-- ==========================================
	-- PROXIMITY INSTANT
	-- ==========================================
	local ProximityCache = {}

	function Cheats_ToggleProximityInstant(state, btn)
		btn.Text = state and "Desativar ProxInstant" or "Proximity Instant"
		GH.Disconnect("ProximityLoop")
		if state then
			for _, obj in ipairs(workspace:GetDescendants()) do
				if obj:IsA("ProximityPrompt") then
					if not ProximityCache[obj] then ProximityCache[obj] = obj.HoldDuration end
					obj.HoldDuration = 0
				end
			end
			GH.Connections.ProximityLoop = workspace.DescendantAdded:Connect(function(desc)
				if GH.States.ProximityInstant and desc:IsA("ProximityPrompt") then
					if not ProximityCache[desc] then ProximityCache[desc] = desc.HoldDuration end
					desc.HoldDuration = 0
				end
			end)
		else
			for prompt, dur in pairs(ProximityCache) do
				if prompt and prompt.Parent then pcall(function() prompt.HoldDuration = dur end) end
			end
			table.clear(ProximityCache)
		end
	end

	-- ==========================================
	-- REGISTRAR BOTOES
	-- ==========================================
	GH.RegisterToggleButton("ClickTP", "Tool TP Click", Cheats_ToggleTPTool, "Utility")
	GH.RegisterToggleButton("Gravity", "Gravity Baixa", Cheats_ToggleGravity, "Utility")
	GH.RegisterToggleButton("CustomSpawn", "Marcar Spawn", Cheats_ToggleCustomSpawn, "Utility")
	GH.RegisterToggleButton("Freecam", "Freecam", Cheats_ToggleFreecam, "Utility")
	GH.RegisterToggleButton("Flashback", "Flashback", Cheats_ToggleFlashback, "Utility")
	GH.RegisterToggleButton("Coords", "Coordenadas", Cheats_ToggleCoords, "Utility")
	GH.RegisterToggleButton("ServerRejoin", "Server Rejoin", Cheats_ToggleServerRejoin, "Utility")
	GH.RegisterToggleButton("AutoClicker", "Auto-Clicker", Cheats_ToggleAutoClicker, "Utility")
	GH.RegisterToggleButton("ProximityInstant", "Proximity Instant", Cheats_ToggleProximityInstant, "Utility")
	GH.RegisterToggleButton("AntiAFK", "Anti-AFK", Cheats_ToggleAntiAFK, "Utility")
	GH.RegisterToggleButton("AntiKick", "Anti-Kick", Cheats_ToggleAntiKick, "Utility")
	GH.RegisterToggleButton("AutoCollect", "Auto Collect", Cheats_ToggleAutoCollect, "Utility")
end
