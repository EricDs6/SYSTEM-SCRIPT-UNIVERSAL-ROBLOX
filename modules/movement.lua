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
		end)
	end

	-- ==========================================
	-- NOCLIP
	-- ==========================================
	local NoClipDisabledParts = {}

	function Cheats_ToggleNoClip(state, btn)
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
	function Cheats_ToggleTeleportPlayer(state, btn)
		GH.Disconnect("TeleportPlayerAdded")
		GH.Disconnect("TeleportPlayerRemoving")
		if GH.Objects.TeleportPlayerDropdown then
			GH.Objects.TeleportPlayerDropdown:Destroy()
			GH.Objects.TeleportPlayerDropdown = nil
		end
		if not state then return end

		local function refreshList()
			local names = {}
			for _, player in ipairs(Players:GetPlayers()) do
				if player ~= LocalPlayer then
					table.insert(names, player.Name)
				end
			end
			if GH.Objects.TeleportPlayerDropdown then
				GH.Objects.TeleportPlayerDropdown:SetValues(names)
			end
		end

		local dropdown = GH.Tabs["Movement"]:AddDropdown("TPPlayer_Select", {
			Title = "TP para Player - Selecionar",
			Values = {},
			AllowNull = true,
		})
		GH.Objects.TeleportPlayerDropdown = dropdown

		dropdown:OnChanged(function(name)
			if name then
				local player = Players:FindFirstChild(name)
				local targetHrp = player and player.Character and player.Character:FindFirstChild("HumanoidRootPart")
				local myHrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
				if targetHrp and myHrp then
					GH.TweenTeleport(myHrp, targetHrp.CFrame + Vector3.new(0, 3, 2))
					GH.ShowToast("TP para " .. name, GH.Theme.On, 2)
				end
			end
		end)

		refreshList()
		GH.Connections.TeleportPlayerAdded = Players.PlayerAdded:Connect(function()
			if GH.States.TeleportPlayer then refreshList() end
		end)
		GH.Connections.TeleportPlayerRemoving = Players.PlayerRemoving:Connect(function()
			if GH.States.TeleportPlayer then refreshList() end
		end)
	end

	-- ==========================================
	-- NO JUMP COOLDOWN
	-- ==========================================
	function Cheats_ToggleNoJumpCooldown(state, btn)
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
	-- FLOAT (Plataforma voadora — igual FE Cosmic)
	-- ==========================================
	function Cheats_ToggleFloat(state, btn)
		GH.UnregisterMasterLoop("Float")
		GH.Disconnect("FloatKeyQ")
		GH.Disconnect("FloatKeyE")
		GH.Disconnect("FloatLoop")

		local char = LocalPlayer.Character
		if char then
			local old = char:FindFirstChild("GH_FloatPad")
			if old then old:Destroy() end
		end

		if state then
			local char = LocalPlayer.Character
			local hrp = char and char:FindFirstChild("HumanoidRootPart")
			if not char or not hrp then return end

			local FloatValue = -3.1

			local pad = Instance.new("Part")
			pad.Name = "GH_FloatPad"
			pad.Size = Vector3.new(2, 0.2, 1.5)
			pad.Transparency = 1
			pad.Anchored = true
			pad.CFrame = hrp.CFrame * CFrame.new(0, FloatValue, 0)
			pad.Parent = char

			-- Q = descer segurando, E = subir segurando
			GH.Connections.FloatKeyQ = UserInputService.InputBegan:Connect(function(input, gpe)
				if gpe or not GH.States.Float then return end
				if input.KeyCode == Enum.KeyCode.Q then
					FloatValue = FloatValue - 0.5
				end
			end)
			GH.Connections.FloatKeyE = UserInputService.InputBegan:Connect(function(input, gpe)
				if gpe or not GH.States.Float then return end
				if input.KeyCode == Enum.KeyCode.E then
					FloatValue = FloatValue + 1.5
				end
			end)

			-- Resetar posicao ao soltar
			UserInputService.InputEnded:Connect(function(input)
				if not GH.States.Float then return end
				if input.KeyCode == Enum.KeyCode.Q then
					FloatValue = FloatValue + 0.5
				elseif input.KeyCode == Enum.KeyCode.E then
					FloatValue = FloatValue - 1.5
				end
			end)

			-- Loop de posicao
			GH.Connections.FloatLoop = RunService.Heartbeat:Connect(function()
				if not GH.States.Float or not char or not char.Parent then
					GH.Disconnect("FloatLoop")
					return
				end
				local r = char:FindFirstChild("HumanoidRootPart")
				local p = char:FindFirstChild("GH_FloatPad")
				if r and p then
					p.CFrame = r.CFrame * CFrame.new(0, FloatValue, 0)
				end
			end)
		else
			local p = char and char:FindFirstChild("GH_FloatPad")
			if p then p:Destroy() end
		end
	end

	-- ==========================================
	-- SWIM (Natacao no ar)
	-- ==========================================
	function Cheats_ToggleSwim(state, btn)
		GH.UnregisterMasterLoop("Swim")
		GH.Disconnect("SwimDied")

		if state then
			local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
			if not hum then return end

			GH.Cache.SwimOldGravity = workspace.Gravity
			workspace.Gravity = 0

			local enums = Enum.HumanoidStateType:GetEnumItems()
			table.remove(enums, table.find(enums, Enum.HumanoidStateType.None))
			for _, v in ipairs(enums) do hum:SetStateEnabled(v, false) end
			hum:ChangeState(Enum.HumanoidStateType.Swimming)

			GH.Connections.SwimDied = hum.Died:Connect(function()
				workspace.Gravity = GH.Cache.SwimOldGravity or 196.2
				GH.States.Swim = false
			end)

			GH.RegisterMasterLoop("Swim", "Heartbeat", function()
				if GH.isClosing or not GH.States.Swim then
					workspace.Gravity = GH.Cache.SwimOldGravity or 196.2
					GH.UnregisterMasterLoop("Swim")
					local h = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
					if h then
						local e2 = Enum.HumanoidStateType:GetEnumItems()
						table.remove(e2, table.find(e2, Enum.HumanoidStateType.None))
						for _, v in ipairs(e2) do h:SetStateEnabled(v, true) end
					end
					return
				end
				-- Manter estado Swimming e controlar velocidade
				pcall(function()
					local c = LocalPlayer.Character
					local h = c and c:FindFirstChildOfClass("Humanoid")
					local r = c and c:FindFirstChild("HumanoidRootPart")
					if h and r then
						h:ChangeState(Enum.HumanoidStateType.Swimming)
						local moveDir = h.MoveDirection
						local isMoving = moveDir.Magnitude > 0
						local isJumping = UserInputService:IsKeyDown(Enum.KeyCode.Space)
						if not isMoving and not isJumping then
							r.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
						end
					end
				end)
			end)
		else
			workspace.Gravity = GH.Cache.SwimOldGravity or 196.2
			local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
			if hum then
				local enums = Enum.HumanoidStateType:GetEnumItems()
				table.remove(enums, table.find(enums, Enum.HumanoidStateType.None))
				for _, v in ipairs(enums) do hum:SetStateEnabled(v, true) end
			end
		end
	end

	-- ==========================================
	-- VEHICLE GOTO
	-- ==========================================
	function Cheats_ToggleVehicleGoto(state, btn)
		GH.Disconnect("VehicleGotoPlayerAdded")
		GH.Disconnect("VehicleGotoPlayerRemoving")
		if GH.Objects.VehicleGotoDropdown then
			GH.Objects.VehicleGotoDropdown:Destroy()
			GH.Objects.VehicleGotoDropdown = nil
		end
		if not state then return end

		local function refreshList()
			local names = {}
			for _, player in ipairs(Players:GetPlayers()) do
				if player ~= LocalPlayer then
					table.insert(names, player.Name)
				end
			end
			if GH.Objects.VehicleGotoDropdown then
				GH.Objects.VehicleGotoDropdown:SetValues(names)
			end
		end

		local dropdown = GH.Tabs["Movement"]:AddDropdown("VehicleGoto_Select", {
			Title = "Vehicle Goto - Selecionar Player",
			Values = {},
			AllowNull = true,
		})
		GH.Objects.VehicleGotoDropdown = dropdown

		dropdown:OnChanged(function(name)
			if name then
				local player = Players:FindFirstChild(name)
				local char = LocalPlayer.Character
				local hum = char and char:FindFirstChildOfClass("Humanoid")
				if hum and hum.SeatPart then
					local vehicle = hum.SeatPart:FindFirstAncestorWhichIsA("Model")
					local target = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
					if vehicle and target then
						vehicle:MoveTo(target.Position)
						GH.ShowToast("Vehicle -> " .. name, GH.Theme.On, 2)
					end
				end
			end
		end)

		refreshList()
		GH.Connections.VehicleGotoPlayerAdded = Players.PlayerAdded:Connect(function()
			if GH.States.VehicleGoto then refreshList() end
		end)
		GH.Connections.VehicleGotoPlayerRemoving = Players.PlayerRemoving:Connect(function()
			if GH.States.VehicleGoto then refreshList() end
		end)
	end

	-- ==========================================
	-- WALK TO (Seguir player)
	-- ==========================================
	function Cheats_ToggleWalkTo(state, btn)
		GH.UnregisterMasterLoop("WalkTo")
		GH.Disconnect("WalkToDied")
		GH.Disconnect("WalkToPlayerAdded")
		GH.Disconnect("WalkToPlayerRemoving")
		if GH.Objects.WalkToDropdown then
			GH.Objects.WalkToDropdown:Destroy()
			GH.Objects.WalkToDropdown = nil
		end
		if not state then return end

		local function refreshList()
			local names = {}
			for _, player in ipairs(Players:GetPlayers()) do
				if player ~= LocalPlayer then
					table.insert(names, player.Name)
				end
			end
			if GH.Objects.WalkToDropdown then
				GH.Objects.WalkToDropdown:SetValues(names)
			end
		end

		local dropdown = GH.Tabs["Movement"]:AddDropdown("WalkTo_Select", {
			Title = "Walk To - Selecionar Player",
			Values = {},
			AllowNull = true,
		})
		GH.Objects.WalkToDropdown = dropdown

		dropdown:OnChanged(function(name)
			if name then
				local targetName = name
				GH.RegisterMasterLoop("WalkTo", "Heartbeat", function()
					if GH.isClosing or not GH.States.WalkTo then
						GH.UnregisterMasterLoop("WalkTo")
						return
					end
					local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
					local target = Players:FindFirstChild(targetName)
					local targetRoot = target and target.Character and target.Character:FindFirstChild("HumanoidRootPart")
					if hum and targetRoot then
						if hum.SeatPart then hum.Sit = false end
						hum:MoveTo(targetRoot.Position)
					else
						GH.UnregisterMasterLoop("WalkTo")
						GH.States.WalkTo = false
					end
				end)
			end
		end)

		refreshList()
		GH.Connections.WalkToPlayerAdded = Players.PlayerAdded:Connect(function()
			if GH.States.WalkTo then refreshList() end
		end)
		GH.Connections.WalkToPlayerRemoving = Players.PlayerRemoving:Connect(function()
			if GH.States.WalkTo then refreshList() end
		end)
	end

	-- ==========================================
	-- ORBIT (Girar ao redor de player)
	-- ==========================================
	function Cheats_ToggleOrbit(state, btn)
		GH.UnregisterMasterLoop("Orbit")
		GH.UnregisterMasterLoop("OrbitLook")
		GH.Disconnect("OrbitPlayerAdded")
		GH.Disconnect("OrbitPlayerRemoving")
		if GH.Objects.OrbitDropdown then
			GH.Objects.OrbitDropdown:Destroy()
			GH.Objects.OrbitDropdown = nil
		end
		if not state then return end

		local function refreshList()
			local names = {}
			for _, player in ipairs(Players:GetPlayers()) do
				if player ~= LocalPlayer then
					table.insert(names, player.Name)
				end
			end
			if GH.Objects.OrbitDropdown then
				GH.Objects.OrbitDropdown:SetValues(names)
			end
		end

		local dropdown = GH.Tabs["Movement"]:AddDropdown("Orbit_Select", {
			Title = "Orbit - Selecionar Player",
			Values = {},
			AllowNull = true,
		})
		GH.Objects.OrbitDropdown = dropdown

		dropdown:OnChanged(function(name)
			if name then
				local targetName = name
				local rotation = 0

				GH.RegisterMasterLoop("Orbit", "Heartbeat", function()
					if GH.isClosing or not GH.States.Orbit then
						GH.UnregisterMasterLoop("Orbit")
						GH.UnregisterMasterLoop("OrbitLook")
						return
					end
					local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
					local target = Players:FindFirstChild(targetName)
					local targetRoot = target and target.Character and target.Character:FindFirstChild("HumanoidRootPart")
					if root and targetRoot then
						rotation = rotation + 0.2
						root.CFrame = CFrame.new(targetRoot.Position) * CFrame.Angles(0, math.rad(rotation), 0) * CFrame.new(6, 0, 0)
					end
				end)

				GH.RegisterMasterLoop("OrbitLook", "Render", function()
					if GH.isClosing or not GH.States.Orbit then return end
					local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
					local target = Players:FindFirstChild(targetName)
					local targetRoot = target and target.Character and target.Character:FindFirstChild("HumanoidRootPart")
					if root and targetRoot then
						root.CFrame = CFrame.new(root.Position, targetRoot.Position)
					end
				end)
			end
		end)

		refreshList()
		GH.Connections.OrbitPlayerAdded = Players.PlayerAdded:Connect(function()
			if GH.States.Orbit then refreshList() end
		end)
		GH.Connections.OrbitPlayerRemoving = Players.PlayerRemoving:Connect(function()
			if GH.States.Orbit then refreshList() end
		end)
	end

	-- ==========================================
	-- HEADSIT (Sentar na cabeça de player)
	-- ==========================================
	function Cheats_ToggleHeadSit(state, btn)
		GH.UnregisterMasterLoop("HeadSit")
		GH.Disconnect("HeadSitPlayerAdded")
		GH.Disconnect("HeadSitPlayerRemoving")
		if GH.Objects.HeadSitDropdown then
			GH.Objects.HeadSitDropdown:Destroy()
			GH.Objects.HeadSitDropdown = nil
		end
		if not state then return end

		local function refreshList()
			local names = {}
			for _, player in ipairs(Players:GetPlayers()) do
				if player ~= LocalPlayer then
					table.insert(names, player.Name)
				end
			end
			if GH.Objects.HeadSitDropdown then
				GH.Objects.HeadSitDropdown:SetValues(names)
			end
		end

		local dropdown = GH.Tabs["Movement"]:AddDropdown("HeadSit_Select", {
			Title = "HeadSit - Selecionar Player",
			Values = {},
			AllowNull = true,
		})
		GH.Objects.HeadSitDropdown = dropdown

		dropdown:OnChanged(function(name)
			if name then
				local targetName = name
				local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
				if hum then hum.Sit = true end

				GH.RegisterMasterLoop("HeadSit", "Heartbeat", function()
					if GH.isClosing or not GH.States.HeadSit then
						GH.UnregisterMasterLoop("HeadSit")
						return
					end
					local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
					local myHum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
					local target = Players:FindFirstChild(targetName)
					local targetRoot = target and target.Character and target.Character:FindFirstChild("HumanoidRootPart")
					if root and targetRoot and myHum and myHum.Sit then
						root.CFrame = targetRoot.CFrame * CFrame.Angles(0, math.rad(0), 0) * CFrame.new(0, 1.6, 0.4)
					else
						GH.UnregisterMasterLoop("HeadSit")
						GH.States.HeadSit = false
					end
				end)
			end
		end)

		refreshList()
		GH.Connections.HeadSitPlayerAdded = Players.PlayerAdded:Connect(function()
			if GH.States.HeadSit then refreshList() end
		end)
		GH.Connections.HeadSitPlayerRemoving = Players.PlayerRemoving:Connect(function()
			if GH.States.HeadSit then refreshList() end
		end)
	end

	-- ==========================================
	-- VEHICLE FLY (Fly em veiculos — estilo FE Cosmic)
	-- ==========================================
	function Cheats_ToggleVehicleFly(state, btn)
		GH.Disconnect("VFLKey")
		GH.Disconnect("VFLKeyUp")
		GH.Disconnect("VFLScroll")
		GH.Disconnect("VFLLoop")

		local oldChar = LocalPlayer.Character
		if oldChar then
			local r = oldChar:FindFirstChild("HumanoidRootPart")
			if r then
				pcall(function() r:FindFirstChild("GH_VFlyBV"):Destroy() end)
				pcall(function() r:FindFirstChild("GH_VFlyBG"):Destroy() end)
			end
			local h = oldChar:FindFirstChildOfClass("Humanoid")
			if h then h.PlatformStand = false end
		end

		if not state then return end

		local char = LocalPlayer.Character
		local hum = char and char:FindFirstChildOfClass("Humanoid")
		local hrp = char and char:FindFirstChild("HumanoidRootPart")
		if not hum or not hrp or hum.Health <= 0 then return end

		local CONTROL = { F = 0, B = 0, L = 0, R = 0, Q = 0, E = 0 }

		local bv = Instance.new("BodyVelocity")
		bv.Name = "GH_VFlyBV"
		bv.MaxForce = Vector3.new(9e9, 9e9, 9e9)
		bv.Velocity = Vector3.new(0, 0, 0)
		bv.Parent = hrp

		local bg = Instance.new("BodyGyro")
		bg.Name = "GH_VFlyBG"
		bg.P = 9e4
		bg.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
		bg.CFrame = hrp.CFrame
		bg.Parent = hrp

		-- KeyDown
		GH.Connections.VFLKey = UserInputService.InputBegan:Connect(function(input, processed)
			if processed then return end
			if not GH.States.VehicleFly then return end
			local k = GH.FlySpeed
			if input.KeyCode == Enum.KeyCode.W then CONTROL.F = k
			elseif input.KeyCode == Enum.KeyCode.S then CONTROL.B = -k
			elseif input.KeyCode == Enum.KeyCode.A then CONTROL.L = -k
			elseif input.KeyCode == Enum.KeyCode.D then CONTROL.R = k
			elseif input.KeyCode == Enum.KeyCode.E then CONTROL.Q = k * 2
			elseif input.KeyCode == Enum.KeyCode.Q then CONTROL.E = -k * 2
			end
		end)

		-- KeyUp
		GH.Connections.VFLKeyUp = UserInputService.InputEnded:Connect(function(input)
			if input.KeyCode == Enum.KeyCode.W then CONTROL.F = 0
			elseif input.KeyCode == Enum.KeyCode.S then CONTROL.B = 0
			elseif input.KeyCode == Enum.KeyCode.A then CONTROL.L = 0
			elseif input.KeyCode == Enum.KeyCode.D then CONTROL.R = 0
			elseif input.KeyCode == Enum.KeyCode.E then CONTROL.Q = 0
			elseif input.KeyCode == Enum.KeyCode.Q then CONTROL.E = 0
			end
		end)

		-- Scroll velocidade
		GH.Connections.VFLScroll = UserInputService.InputChanged:Connect(function(input)
			if not GH.States.VehicleFly then return end
			if input.UserInputType == Enum.UserInputType.MouseWheel then
				GH.FlySpeed = math.clamp(GH.FlySpeed + (input.Position.Z > 0 and 1 or -1), 1, 100)
			end
		end)

		-- Loop de voo
		GH.Connections.VFLLoop = RunService.RenderStepped:Connect(function()
			if GH.isClosing or not GH.States.VehicleFly then
				GH.Disconnect("VFLKey")
				GH.Disconnect("VFLKeyUp")
				GH.Disconnect("VFLScroll")
				GH.Disconnect("VFLLoop")
				pcall(function()
					local r = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
					if r then
						pcall(function() r:FindFirstChild("GH_VFlyBV"):Destroy() end)
						pcall(function() r:FindFirstChild("GH_VFlyBG"):Destroy() end)
					end
					local h = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
					if h then h.PlatformStand = false end
				end)
				return
			end

			local c = LocalPlayer.Character
			local h = c and c:FindFirstChildOfClass("Humanoid")
			local r = c and c:FindFirstChild("HumanoidRootPart")
			local cam = workspace.CurrentCamera
			if not c or not r or not h or not cam then return end

			if CONTROL.F + CONTROL.B ~= 0 or CONTROL.L + CONTROL.R ~= 0 or CONTROL.Q + CONTROL.E ~= 0 then
				bv.Velocity = ((cam.CFrame.LookVector * (CONTROL.F + CONTROL.B))
					+ ((cam.CFrame * CFrame.new(CONTROL.L + CONTROL.R, (CONTROL.F + CONTROL.B + CONTROL.Q + CONTROL.E) * 0.2, 0).Position) - cam.CFrame.Position))
					* 50
			else
				bv.Velocity = Vector3.new(0, 0, 0)
			end
			bg.CFrame = cam.CFrame
		end)
	end

	-- ==========================================
	-- SPECTATE (Camera segue jogador)
	-- ==========================================
	function Cheats_ToggleSpectate(state, btn)
		GH.Disconnect("SpectateDied")
		GH.Disconnect("SpectateChanged")
		GH.Disconnect("SpectatePlayerAdded")
		GH.Disconnect("SpectatePlayerRemoving")
		if GH.Objects.SpectateDropdown then
			GH.Objects.SpectateDropdown:Destroy()
			GH.Objects.SpectateDropdown = nil
		end

		if not state then
			workspace.CurrentCamera.CameraSubject = LocalPlayer.Character
			return
		end

		local function refreshList()
			local names = {}
			for _, player in ipairs(Players:GetPlayers()) do
				if player ~= LocalPlayer then
					table.insert(names, player.Name)
				end
			end
			if GH.Objects.SpectateDropdown then
				GH.Objects.SpectateDropdown:SetValues(names)
			end
		end

		local dropdown = GH.Tabs["Movement"]:AddDropdown("Spectate_Select", {
			Title = "Spectate - Selecionar Player",
			Values = {},
			AllowNull = true,
		})
		GH.Objects.SpectateDropdown = dropdown

		dropdown:OnChanged(function(name)
			if name then
				local player = Players:FindFirstChild(name)
				if player then
					workspace.CurrentCamera.CameraSubject = player.Character
					GH.Connections.SpectateDied = player.CharacterAdded:Connect(function(char)
						workspace.CurrentCamera.CameraSubject = char
					end)
				end
			end
		end)

		refreshList()
		GH.Connections.SpectatePlayerAdded = Players.PlayerAdded:Connect(function()
			if GH.States.Spectate then refreshList() end
		end)
		GH.Connections.SpectatePlayerRemoving = Players.PlayerRemoving:Connect(function()
			if GH.States.Spectate then refreshList() end
		end)
	end

	-- ==========================================
	-- GOTO PART (Teleporta para parte pelo nome)
	-- ==========================================
	function Cheats_ToggleGotoPart(state, btn)
		if GH.Objects.GotoPartInput then
			GH.Objects.GotoPartInput:Destroy()
			GH.Objects.GotoPartInput = nil
		end
		if not state then return end

		local function teleportToPart(partName)
			for _, v in ipairs(workspace:GetDescendants()) do
				if v:IsA("BasePart") and v.Name:lower() == partName:lower() then
					local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
					if hrp then
						hrp.CFrame = v.CFrame + Vector3.new(0, 3, 0)
						GH.ShowToast("TP para " .. v.Name, GH.Theme.On, 2)
					end
					break
				end
			end
		end

		local input = GH.Tabs["Movement"]:AddInput("GotoPartInput", {
			Title = "Goto Part - Nome da Parte",
			Placeholder = "Digite o nome...",
			Finished = true,
			Callback = function(value)
				if value and value ~= "" then
					teleportToPart(value)
				end
			end,
		})
		GH.Objects.GotoPartInput = input
	end

	-- ==========================================
	-- REGISTRAR BOTÕES
	-- ==========================================
	GH.RegisterToggleButton("Fly", "Ativar Fly", Cheats_ToggleFly, "Movement", "Voar pelo mapa com WASD. Scroll ajusta velocidade")
	GH.RegisterToggleButton("NoClip", "Ativar NoClip", Cheats_ToggleNoClip, "Movement", "Atravessar paredes e objeitos solidos")
	GH.RegisterToggleButton("Sprint", "Sprint (Shift)", Cheats_ToggleSprint, "Movement", "Correr mais segurando a tecla Shift")
	GH.RegisterToggleButton("Speed", "Speed Hack", Cheats_ToggleSpeed, "Movement", "Aumenta a velocidade de caminhada")
	GH.RegisterToggleButton("InfiniteJump", "Infinite Jump", Cheats_ToggleInfiniteJump, "Movement", "Pular infinitas vezes no ar")
	GH.RegisterToggleButton("BunnyHop", "Bunny Hop", Cheats_ToggleBunnyHop, "Movement", "Pular continuamente ao correr")
	GH.RegisterToggleButton("TeleportPlayer", "TP para Player", Cheats_ToggleTeleportPlayer, "Movement", "Seleciona um player para teleportar ate ele")
	GH.RegisterToggleButton("Blink", "Blink (Q)", Cheats_ToggleBlink, "Movement", "Dash rapido na direcao que olha. Tecla Q")
	GH.RegisterToggleButton("VehicleSpeed", "Vehicle Speed", Cheats_ToggleVehicleSpeed, "Movement", "Aumenta velocidade e torqu de veiculos")
	GH.RegisterToggleButton("NoJumpCooldown", "No Jump Cooldown", Cheats_ToggleNoJumpCooldown, "Movement", "Remove cooldown de pulo, pula sem parar")
	GH.RegisterToggleButton("Float", "Float", Cheats_ToggleFloat, "Movement", "Plataforma voadora. Q desce, E sobe")
	GH.RegisterToggleButton("Swim", "Swim", Cheats_ToggleSwim, "Movement", "Natacao no ar, gravedade zero")
	GH.RegisterToggleButton("VehicleGoto", "Vehicle Goto", Cheats_ToggleVehicleGoto, "Movement", "Teleporta seu veiculo para um jogador")
	GH.RegisterToggleButton("WalkTo", "Walk To", Cheats_ToggleWalkTo, "Movement", "Segue um jogador automaticamente")
	GH.RegisterToggleButton("Orbit", "Orbit", Cheats_ToggleOrbit, "Movement", "Gira ao redor de um jogador")
	GH.RegisterToggleButton("HeadSit", "HeadSit", Cheats_ToggleHeadSit, "Movement", "Senta na cabeca de um jogador")
	GH.RegisterToggleButton("VehicleFly", "Vehicle Fly", Cheats_ToggleVehicleFly, "Movement", "Voar dirigindo veiculos. WASD+QE")
	GH.RegisterToggleButton("Spectate", "Spectate", Cheats_ToggleSpectate, "Movement", "Camera segue um jogador selecionado")
	GH.RegisterToggleButton("GotoPart", "Goto Part", Cheats_ToggleGotoPart, "Movement", "Teleporta para uma parte pelo nome")
end
