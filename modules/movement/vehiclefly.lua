-- =============================================================================
-- COMMAND: VEHICLE FLY
-- =============================================================================
return function(GH)
	local Players = GH.Services.Players
	local UserInputService = GH.Services.UserInputService
	local RunService = GH.Services.RunService
	local LocalPlayer = GH.LocalPlayer

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

		GH.Connections.VFLKeyUp = UserInputService.InputEnded:Connect(function(input)
			if input.KeyCode == Enum.KeyCode.W then CONTROL.F = 0
			elseif input.KeyCode == Enum.KeyCode.S then CONTROL.B = 0
			elseif input.KeyCode == Enum.KeyCode.A then CONTROL.L = 0
			elseif input.KeyCode == Enum.KeyCode.D then CONTROL.R = 0
			elseif input.KeyCode == Enum.KeyCode.E then CONTROL.Q = 0
			elseif input.KeyCode == Enum.KeyCode.Q then CONTROL.E = 0
			end
		end)

		GH.Connections.VFLScroll = UserInputService.InputChanged:Connect(function(input)
			if not GH.States.VehicleFly then return end
			if input.UserInputType == Enum.UserInputType.MouseWheel then
				GH.FlySpeed = math.clamp(GH.FlySpeed + (input.Position.Z > 0 and 1 or -1), 1, 100)
			end
		end)

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

	GH.RegisterToggleButton("VehicleFly", "toggle_vehiclefly", Cheats_ToggleVehicleFly, "Movement", "desc_vehiclefly")
end