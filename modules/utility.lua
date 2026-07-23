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
	-- FREECAM
	-- ==========================================
	local CacheFreecam = { Camera = nil, Speed = 2 }

	function Cheats_ToggleFreecam(state, btn)
		btn.Text = state and "Desativar Freecam" or "Freecam"
		GH.Disconnect("Freecam")

		if state then
			local cam = workspace.CurrentCamera
			if not cam then return end
			CacheFreecam.Camera = cam
			CacheFreecam.OriginalCF = cam.CFrame
			CacheFreecam.OriginalType = cam.CameraType
			cam.CameraType = Enum.CameraType.Scriptable

			GH.Connections.Freecam = RunService.RenderStepped:Connect(function(dt)
				if GH.isClosing or not GH.States.Freecam then return end
				local cam = workspace.CurrentCamera
				if not cam then return end
				local speed = CacheFreecam.Speed * dt * 60 * (UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) and 3 or 1)
				local cf = cam.CFrame
				if UserInputService:IsKeyDown(Enum.KeyCode.W) then cf = cf + cf.LookVector * speed end
				if UserInputService:IsKeyDown(Enum.KeyCode.S) then cf = cf - cf.LookVector * speed end
				if UserInputService:IsKeyDown(Enum.KeyCode.A) then cf = cf - cf.RightVector * speed end
				if UserInputService:IsKeyDown(Enum.KeyCode.D) then cf = cf + cf.RightVector * speed end
				if UserInputService:IsKeyDown(Enum.KeyCode.Space) then cf = cf + Vector3.new(0, speed, 0) end
				if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then cf = cf - Vector3.new(0, speed, 0) end
				local mouseDelta = UserInputService:GetMouseDelta()
				if mouseDelta.Magnitude > 0 then
					cf = cf * CFrame.Angles(-mouseDelta.Y * 0.002, -mouseDelta.X * 0.002, 0)
				end
				cam.CFrame = cf
			end)
		else
			local cam = workspace.CurrentCamera
			if cam then
				cam.CameraType = CacheFreecam.OriginalType or Enum.CameraType.Custom
				if CacheFreecam.OriginalCF then cam.CFrame = CacheFreecam.OriginalCF end
			end
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
			saveBtn.Text = "+ Salvar Posição"
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
					GH.ShowToast("Posição salva!", GH.Theme.On, 2)
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
				GH.ShowToast("Anti-Kick: hookfunction não disponível", GH.Theme.Red, 3)
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
	-- REGISTRAR BOTÕES
	-- ==========================================
	GH.RegisterToggleButton("ClickTP", "Tool TP Click", Cheats_ToggleTPTool, "Utility")
	GH.RegisterToggleButton("Gravity", "Gravity Baixa", Cheats_ToggleGravity, "Utility")
	GH.RegisterToggleButton("CustomSpawn", "Marcar Spawn", Cheats_ToggleCustomSpawn, "Utility")
	GH.RegisterToggleButton("Freecam", "Freecam", Cheats_ToggleFreecam, "Utility")
	GH.RegisterToggleButton("Coords", "Coordenadas", Cheats_ToggleCoords, "Utility")
	GH.RegisterToggleButton("ServerRejoin", "Server Rejoin", Cheats_ToggleServerRejoin, "Utility")
	GH.RegisterToggleButton("AutoClicker", "Auto-Clicker", Cheats_ToggleAutoClicker, "Utility")
	GH.RegisterToggleButton("ProximityInstant", "Proximity Instant", Cheats_ToggleProximityInstant, "Utility")
	GH.RegisterToggleButton("AntiAFK", "Anti-AFK", Cheats_ToggleAntiAFK, "Utility")
	GH.RegisterToggleButton("AntiKick", "Anti-Kick", Cheats_ToggleAntiKick, "Utility")
	GH.RegisterToggleButton("AutoCollect", "Auto Collect", Cheats_ToggleAutoCollect, "Utility")
end
