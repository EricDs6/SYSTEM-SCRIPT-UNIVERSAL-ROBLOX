-- =============================================================================
-- COMMAND: FLY
-- =============================================================================
return function(GH)
	local UserInputService = GH.Services.UserInputService
	local RunService = GH.Services.RunService
	local LocalPlayer = GH.LocalPlayer

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

	GH.RegisterToggleButton("Fly", "toggle_fly", Cheats_ToggleFly, "Movement", "desc_fly")
end