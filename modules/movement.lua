-- =============================================================================
-- MODULE: MOVEMENT
-- =============================================================================
--!nonstrict
return function(GH)
	local Players = GH.Services.Players
	local RunService = GH.Services.RunService
	local UserInputService = GH.Services.UserInputService
	local TweenService = GH.Services.TweenService
	local LocalPlayer = GH.LocalPlayer

	-- ==========================================
	-- FLY (BodyVelocity + BodyGyro — Infinite Yield model)
	-- ==========================================
	local FlyNoclipParts = {}
	local FlySpeedMult = 1

	local function FlySetNoclip(char, enable)
		for _, part in ipairs(char:GetDescendants()) do
			if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
				if enable then
					FlyNoclipParts[part] = part.CanCollide
					part.CanCollide = false
				elseif FlyNoclipParts[part] ~= nil then
					part.CanCollide = FlyNoclipParts[part]
					FlyNoclipParts[part] = nil
				end
			end
		end
		if not enable then table.clear(FlyNoclipParts) end
	end

	local function FlySetFrozen(char, frozen)
		if not char then return end
		for _, desc in ipairs(char:GetDescendants()) do
			if desc:IsA("Motor6D") then
				pcall(function() desc:SetJointFrozen(Enum.JointType.Motor, frozen) end)
			end
		end
	end

	local function FlyCleanup(char, hum, hrp)
		if hrp then
			local bv = hrp:FindFirstChild("GH_FlyBV")
			if bv then bv:Destroy() end
			local bg = hrp:FindFirstChild("GH_FlyBG")
			if bg then bg:Destroy() end
			hrp.AssemblyLinearVelocity = Vector3.zero
			hrp.AssemblyAngularVelocity = Vector3.zero
		end
		if hum then
			hum.PlatformStand = false
			hum.AutoRotate = true
			hum:SetStateEnabled(Enum.HumanoidStateType.Freefall, true)
			hum:ChangeState(Enum.HumanoidStateType.GettingUp)
		end
		if char then FlySetNoclip(char, false); FlySetFrozen(char, false) end
		FlySpeedMult = 1
	end

	function Cheats_ToggleFly(state, btn)
		btn.Text = state and "Desativar Fly" or "Ativar Fly"
		GH.Disconnect("Fly")
		GH.Disconnect("FlyScroll")

		local oldChar = LocalPlayer.Character
		local oldHum = oldChar and oldChar:FindFirstChildOfClass("Humanoid")
		local oldHrp = oldChar and oldChar:FindFirstChild("HumanoidRootPart")
		FlyCleanup(oldChar, oldHum, oldHrp)

		if not state then return end

		local char = LocalPlayer.Character
		local hum = char and char:FindFirstChildOfClass("Humanoid")
		local hrp = char and char:FindFirstChild("HumanoidRootPart")
		if not hum or not hrp or hum.Health <= 0 then return end

		hum.AutoRotate = false
		hum:SetStateEnabled(Enum.HumanoidStateType.Freefall, false)
		hum:ChangeState(Enum.HumanoidStateType.Running)
		FlySetFrozen(char, true)

		GH.Connections.FlyScroll = UserInputService.InputChanged:Connect(function(input)
			if not GH.States.Fly then return end
			if input.UserInputType == Enum.UserInputType.MouseWheel then
				local dir = input.Position.Z > 0 and 1 or -1
				FlySpeedMult = math.clamp(FlySpeedMult + dir * 0.25, 0.25, 5)
			end
		end)

		GH.Connections.Fly = RunService.Stepped:Connect(function()
			if GH.isClosing then
				GH.Disconnect("Fly")
				GH.Disconnect("FlyScroll")
				FlyCleanup(LocalPlayer.Character, LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid"), LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart"))
				return
			end

			local c = LocalPlayer.Character
			local h = c and c:FindFirstChildOfClass("Humanoid")
			local r = c and c:FindFirstChild("HumanoidRootPart")
			if not c or not r or not h or h.Health <= 0 then
				GH.Disconnect("Fly")
				GH.Disconnect("FlyScroll")
				FlyCleanup(c, h, r)
				return
			end

			h.PlatformStand = true

			local bv = r:FindFirstChild("GH_FlyBV")
			if not bv then
				bv = Instance.new("BodyVelocity")
				bv.Name = "GH_FlyBV"
				bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
				bv.Parent = r
			end

			local bg = r:FindFirstChild("GH_FlyBG")
			if not bg then
				bg = Instance.new("BodyGyro")
				bg.Name = "GH_FlyBG"
				bg.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
				bg.P = 9e4
				bg.Parent = r
			end

			FlySetNoclip(c, true)

			local cam = workspace.CurrentCamera
			if not cam then return end

			local speed = GH.FlySpeed * FlySpeedMult

			local camLook = cam.CFrame.LookVector
			bg.CFrame = CFrame.new(r.Position, r.Position + Vector3.new(camLook.X, 0, camLook.Z))

			local vel = Vector3.zero
			if h.MoveDirection.Magnitude > 0 then
				vel = h.MoveDirection * speed
			end

			local vert = 0
			if UserInputService:IsKeyDown(Enum.KeyCode.Space) then vert = speed
			elseif UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then vert = -speed end

			bv.Velocity = Vector3.new(vel.X, vert, vel.Z)
			r.AssemblyLinearVelocity = bv.Velocity
		end)
	end

	-- ==========================================
	-- NOCLIP
	-- ==========================================
	local NoClipDisabledParts = {}

	function Cheats_ToggleNoClip(state, btn)
		btn.Text = state and "Desativar NoClip" or "Ativar NoClip"
		GH.Disconnect("NoClip")
		GH.UnregisterMasterLoop("NoClip")

		for p, _ in pairs(NoClipDisabledParts) do
			if p and p.Parent then GH.SafeCall("NoClip:restore", function() p.CanCollide = true end) end
		end
		table.clear(NoClipDisabledParts)

		if state then
			local cachedRayParams = RaycastParams.new()
			cachedRayParams.FilterType = Enum.RaycastFilterType.Exclude
			local cachedOverlapParams = OverlapParams.new()
			cachedOverlapParams.FilterType = Enum.RaycastFilterType.Exclude

			GH.RegisterMasterLoop("NoClip", "PreSim", function()
				if GH.isClosing or not GH.States.NoClip then
					GH.UnregisterMasterLoop("NoClip")
					for p, _ in pairs(NoClipDisabledParts) do
						if p and p.Parent then pcall(function() p.CanCollide = true end) end
					end
					table.clear(NoClipDisabledParts)
					return
				end
				local char = LocalPlayer.Character
				local hrp = char and char:FindFirstChild("HumanoidRootPart")
				if not char or not hrp then return end

				cachedRayParams.FilterDescendantsInstances = { char }
				cachedOverlapParams.FilterDescendantsInstances = { char }

				local r = GH.Settings.NoClipRadius
				local parts = workspace:GetPartBoundsInBox(hrp.CFrame, Vector3.new(r, r * 1.4, r), cachedOverlapParams)
				local currentParts = {}

				for _, p in ipairs(parts) do
					if p:IsA("BasePart") and p.Name ~= "Terrain" and not p:HasTag("GH_NoClipIgnore") then
						local parent = p.Parent
						if parent and not parent:FindFirstChildOfClass("Humanoid") then
							currentParts[p] = true
							if p.CanCollide then
								p.CanCollide = false
								NoClipDisabledParts[p] = true
							end
						end
					end
				end

				for p, _ in pairs(NoClipDisabledParts) do
					if not currentParts[p] then
						if p and p.Parent then pcall(function() p.CanCollide = true end) end
						NoClipDisabledParts[p] = nil
					end
				end
			end)
		end
	end

	-- ==========================================
	-- SPRINT
	-- ==========================================
	function Cheats_ToggleSprint(state, btn)
		btn.Text = state and "Desativar Sprint" or "Sprint (" .. (GH.Keybinds.Sprint or "Shift") .. ")"
		GH.Disconnect("Sprint")
		local sprintKey = GH.GetKeyCode("Sprint")
		if sprintKey then GH.InputManager.Unbind(sprintKey) end

		local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")

		if state and hum and sprintKey then
			GH.Cache.OrigWalkSpeed = hum.WalkSpeed
			GH.InputManager.Bind(sprintKey, function()
				if not GH.States.Sprint then return end
				local h = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
				if h then h.WalkSpeed = GH.FlySpeed * 2 end
			end, function()
				local h = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
				if h then h.WalkSpeed = GH.Cache.OrigWalkSpeed end
			end)
		else
			if hum then hum.WalkSpeed = GH.Cache.OrigWalkSpeed end
		end
	end

	-- ==========================================
	-- SPEED HACK
	-- ==========================================
	function Cheats_ToggleSpeed(state, btn)
		btn.Text = state and "Desativar Speed" or "Speed Hack"
		local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
		if state and hum then
			GH.Cache.OrigWalkSpeed = hum.WalkSpeed
			hum.WalkSpeed = GH.FlySpeed
		else
			if hum then hum.WalkSpeed = GH.Cache.OrigWalkSpeed or 16 end
		end
	end

	-- ==========================================
	-- INFINITE JUMP
	-- ==========================================
	function Cheats_ToggleInfiniteJump(state, btn)
		btn.Text = state and "Desativar InfJump" or "Infinite Jump"
		GH.Disconnect("InfJump")
		if state then
			GH.Connections.InfJump = UserInputService.JumpRequest:Connect(function()
				if not GH.States.InfiniteJump then return end
				local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
				if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
			end)
		end
	end

	-- ==========================================
	-- BUNNY HOP
	-- ==========================================
	function Cheats_ToggleBunnyHop(state, btn)
		btn.Text = state and "Desativar BunnyHop" or "Bunny Hop"
		GH.UnregisterMasterLoop("BunnyHop")
		if state then
			GH.RegisterMasterLoop("BunnyHop", "Heartbeat", function()
				if GH.isClosing or not GH.States.BunnyHop then
					GH.UnregisterMasterLoop("BunnyHop"); return
				end
				local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
				if hum and hum.Health > 0 and hum.FloorMaterial ~= Enum.Material.Air then
					hum:ChangeState(Enum.HumanoidStateType.Jumping)
				end
			end)
		end
	end

	-- ==========================================
	-- BLINK (Dash)
	-- ==========================================
	function Cheats_ToggleBlink(state, btn)
		btn.Text = state and "Desativar Blink" or "Blink (" .. (GH.Keybinds.Blink or "Q") .. ")"
		GH.Disconnect("Blink")
		local blinkKey = GH.GetKeyCode("Blink")
		if blinkKey then GH.InputManager.Unbind(blinkKey) end

		if state and blinkKey then
			GH.InputManager.Bind(blinkKey, function()
				local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
				local cam = workspace.CurrentCamera
				if hrp and cam then
					GH.TweenTeleport(hrp, hrp.CFrame + cam.CFrame.LookVector * 15)
					GH.ShowToast("Blink!", GH.Theme.Accent, 1)
				end
			end)
		end
	end

	-- ==========================================
	-- TELEPORT PLAYER
	-- ==========================================
	local TeleportGUI = nil

	function Cheats_ToggleTeleportPlayer(state, btn)
		btn.Text = state and "Desativar TP Player" or "TP para Player"
		GH.Disconnect("TeleportPlayerAdded")
		GH.Disconnect("TeleportPlayerRemoving")
		if TeleportGUI then TeleportGUI:Destroy(); TeleportGUI = nil end
		if not state then return end

		local gui = Instance.new("ScreenGui")
		gui.Name = "GH_TeleportList"
		gui.ResetOnSpawn = false
		gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
		gui.Parent = GH.TargetGui
		TeleportGUI = gui

		local frame = Instance.new("Frame")
		frame.Size = UDim2.new(0, 160, 0, 220)
		frame.Position = UDim2.new(0, 10, 0.5, -110)
		frame.BackgroundColor3 = GH.Theme.BG
		frame.BorderSizePixel = 0
		frame.Parent = gui
		Instance.new("UIStroke", frame).Color = GH.Theme.Border
		Instance.new("UIStroke", frame).Thickness = 1
		Instance.new("UIStroke", frame).Transparency = 0.5

		local title = Instance.new("TextLabel")
		title.Size = UDim2.new(1, 0, 0, 26)
		title.BackgroundColor3 = GH.Theme.Topbar
		title.Text = "JOGADORES"
		title.TextColor3 = GH.Theme.Accent
		title.Font = Enum.Font.GothamBold
		title.TextSize = 11
		title.BorderSizePixel = 0
		title.Parent = frame

		local scroll = Instance.new("ScrollingFrame")
		scroll.Size = UDim2.new(1, -8, 1, -32)
		scroll.Position = UDim2.new(0, 4, 0, 30)
		scroll.BackgroundTransparency = 1
		scroll.ScrollBarThickness = 2
		scroll.ScrollBarImageColor3 = GH.Theme.Accent
		scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
		scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
		scroll.BorderSizePixel = 0
		scroll.Parent = frame
		Instance.new("UIListLayout", scroll).Padding = UDim.new(0, 2)

		local function refreshList()
			for _, child in ipairs(scroll:GetChildren()) do
				if child:IsA("TextButton") then child:Destroy() end
			end
			local order = 0
			for _, player in ipairs(Players:GetPlayers()) do
				if player ~= LocalPlayer then
					order += 1
					local plrBtn = Instance.new("TextButton")
					plrBtn.Size = UDim2.new(1, 0, 0, 28)
					plrBtn.BackgroundColor3 = GH.Theme.Card
					plrBtn.Text = ""
					plrBtn.AutoButtonColor = false
					plrBtn.BorderSizePixel = 0
					plrBtn.LayoutOrder = order
					plrBtn.Parent = scroll

					local nameLbl = Instance.new("TextLabel")
					nameLbl.Size = UDim2.new(0.8, 0, 1, 0)
					nameLbl.Position = UDim2.new(0, 8, 0, 0)
					nameLbl.BackgroundTransparency = 1
					nameLbl.Text = player.Name
					nameLbl.TextColor3 = GH.Theme.Text
					nameLbl.Font = Enum.Font.GothamMedium
					nameLbl.TextSize = 11
					nameLbl.TextXAlignment = Enum.TextXAlignment.Left
					nameLbl.TextTruncate = Enum.TextTruncate.AtEnd
					nameLbl.Parent = plrBtn

					plrBtn.MouseButton1Click:Connect(function()
						local targetHrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
						local myHrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
						if targetHrp and myHrp then
							GH.TweenTeleport(myHrp, targetHrp.CFrame + Vector3.new(0, 3, 2))
						end
					end)
				end
			end
		end

		refreshList()
		GH.Connections.TeleportPlayerAdded = Players.PlayerAdded:Connect(function()
			if GH.States.TeleportPlayer then refreshList() end
		end)
		GH.Connections.TeleportPlayerRemoving = Players.PlayerRemoving:Connect(function()
			if GH.States.TeleportPlayer then refreshList() end
		end)
	end

	-- ==========================================
	-- NO FALL DAMAGE (State-based loop)
	-- ==========================================
	function Cheats_ToggleNoFallDamageLoop(state, btn)
		btn.Text = state and "Desativar NoFallDmg" or "No Fall Damage"
		-- Master Namecall hook handles TakeDamage blocking
	end

	-- ==========================================
	-- NO JUMP COOLDOWN
	-- ==========================================
	function Cheats_ToggleNoJumpCooldown(state, btn)
		btn.Text = state and "Desativar NoJumpCD" or "No Jump Cooldown"
		GH.UnregisterMasterLoop("NoJumpCooldown")
		if state then
			GH.RegisterMasterLoop("NoJumpCooldown", "Heartbeat", function()
				if GH.isClosing or not GH.States.NoJumpCooldown then
					GH.UnregisterMasterLoop("NoJumpCooldown")
					local h = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
					if h then h.JumpHeight = 7.2; h.JumpPower = 50 end
					return
				end
				local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
				if hum then
					hum.JumpHeight = 50
					hum.JumpPower = 100
					if hum.FloorMaterial == Enum.Material.Air then
						hum:ChangeState(Enum.HumanoidStateType.Jumping)
					end
				end
			end)
		else
			local h = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
			if h then h.JumpHeight = 7.2; h.JumpPower = 50 end
		end
	end

	-- ==========================================
	-- VEHICLE SPEED
	-- ==========================================
	function Cheats_ToggleVehicleSpeed(state, btn)
		btn.Text = state and "Desativar VehicleSpeed" or "Vehicle Speed"
		GH.Disconnect("VehicleSpeed")
		if state then
			GH.Connections.VehicleSpeed = RunService.Heartbeat:Connect(function()
				if GH.isClosing or not GH.States.VehicleSpeed then return end
				pcall(function()
					local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
					if hum and hum.SeatPart and hum.SeatPart:IsA("VehicleSeat") then
						hum.SeatPart.MaxSpeed = 100
						hum.SeatPart.Torque = 200
					end
				end)
			end)
		end
	end

	-- ==========================================
	-- REGISTRAR BOTÕES
	-- ==========================================
	GH.RegisterToggleButton("Fly", "Ativar Fly", Cheats_ToggleFly, "Movement")
	GH.RegisterToggleButton("NoClip", "Ativar NoClip", Cheats_ToggleNoClip, "Movement")
	GH.RegisterToggleButton("Sprint", "Sprint (Shift)", Cheats_ToggleSprint, "Movement")
	GH.RegisterToggleButton("Speed", "Speed Hack", Cheats_ToggleSpeed, "Movement")
	GH.RegisterToggleButton("InfiniteJump", "Infinite Jump", Cheats_ToggleInfiniteJump, "Movement")
	GH.RegisterToggleButton("BunnyHop", "Bunny Hop", Cheats_ToggleBunnyHop, "Movement")
	GH.RegisterToggleButton("TeleportPlayer", "TP para Player", Cheats_ToggleTeleportPlayer, "Movement")
	GH.RegisterToggleButton("Blink", "Blink (Q)", Cheats_ToggleBlink, "Movement")
	GH.RegisterToggleButton("VehicleSpeed", "Vehicle Speed", Cheats_ToggleVehicleSpeed, "Movement")
	GH.RegisterToggleButton("NoJumpCooldown", "No Jump Cooldown", Cheats_ToggleNoJumpCooldown, "Movement")
end
