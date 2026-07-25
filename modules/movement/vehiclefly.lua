-- =============================================================================
-- COMMAND: VEHICLE FLY
-- Voar dirigindo veiculos. WASD+QE+Scroll
-- =============================================================================
return function(GH)
	local UserInputService = GH.Services.UserInputService
	local RunService = GH.Services.RunService
	local LocalPlayer = GH.LocalPlayer

	local keys = { W = false, A = false, S = false, D = false, E = false, Q = false }

	function Cheats_ToggleVehicleFly(state, btn)
		GH.Disconnect("VFly_Stepped")
		GH.Disconnect("VFly_InputBegan")
		GH.Disconnect("VFly_InputEnded")
		GH.Disconnect("VFly_Scroll")

		-- Limpar objetos antigos
		local char = LocalPlayer.Character
		local hrp = char and char:FindFirstChild("HumanoidRootPart")
		if hrp then
			pcall(function() hrp:FindFirstChild("GH_VFlyLV"):Destroy() end)
			pcall(function() hrp:FindFirstChild("GH_VFlyAV"):Destroy() end)
		end

		if not state then return end

		local hum = char and char:FindFirstChildOfClass("Humanoid")
		if not hum or not hrp then return end

		for k in pairs(keys) do keys[k] = false end

		hum.PlatformStand = false

		-- LinearVelocity
		local lv = Instance.new("LinearVelocity")
		lv.Name = "GH_VFlyLV"
		lv.MaxForce = math.huge
		lv.Attachment0 = hrp:FindFirstChildOfClass("Attachment") or Instance.new("Attachment", hrp)
		lv.VectorVelocity = Vector3.zero
		lv.VelocityConstraintMode = Enum.VelocityConstraintMode.Vector
		lv.Parent = hrp

		-- AngularVelocity
		local av = Instance.new("AngularVelocity")
		av.Name = "GH_VFlyAV"
		av.MaxTorque = math.huge
		av.Attachment0 = lv.Attachment0
		av.AngularVelocity = Vector3.zero
		av.Parent = hrp

		-- Input
		GH.Connections.VFly_InputBegan = UserInputService.InputBegan:Connect(function(input, gpe)
			if gpe then return end
			if not GH.States.VehicleFly then return end
			if keys[input.KeyCode.Name] ~= nil then
				keys[input.KeyCode.Name] = true
			end
		end)

		GH.Connections.VFly_InputEnded = UserInputService.InputEnded:Connect(function(input)
			if keys[input.KeyCode.Name] ~= nil then
				keys[input.KeyCode.Name] = false
			end
		end)

		-- Scroll velocidade
		GH.Connections.VFly_Scroll = UserInputService.InputChanged:Connect(function(input)
			if not GH.States.VehicleFly then return end
			if input.UserInputType == Enum.UserInputType.MouseWheel then
				local dir = input.Position.Z > 0 and 5 or -5
				GH.FlySpeed = math.clamp((GH.FlySpeed or 20) + dir, 5, 200)
				GH.ShowToast("Vehicle Fly Speed: " .. GH.FlySpeed, GH.Theme.Accent, 1)
			end
		end)

		-- Loop principal
		GH.Connections.VFly_Stepped = RunService.RenderStepped:Connect(function(dt)
			if GH.isClosing or not GH.States.VehicleFly then
				GH.Disconnect("VFly_Stepped")
				GH.Disconnect("VFly_InputBegan")
				GH.Disconnect("VFly_InputEnded")
				GH.Disconnect("VFly_Scroll")
				pcall(function()
					local r = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
					if r then
						pcall(function() r:FindFirstChild("GH_VFlyLV"):Destroy() end)
						pcall(function() r:FindFirstChild("GH_VFlyAV"):Destroy() end)
					end
				end)
				return
			end

			local c = LocalPlayer.Character
			local h = c and c:FindFirstChildOfClass("Humanoid")
			local r = c and c:FindFirstChild("HumanoidRootPart")
			local cam = workspace.CurrentCamera
			if not c or not r or not h or not cam then return end

			h.PlatformStand = false
			av.AngularVelocity = Vector3.zero

			local flySpeed = GH.FlySpeed or 20

			-- Camera vectors
			local camCF = cam.CFrame
			local lookVec = camCF.LookVector
			local rightVec = camCF.RightVector

			-- Movimento
			local moveDir = Vector3.zero
			moveDir = moveDir + lookVec * ((keys.W and 1 or 0) + (keys.S and -1 or 0))
			moveDir = moveDir + rightVec * ((keys.D and 1 or 0) + (keys.A and -1 or 0))

			local vert = 0
			if keys.E then
				vert = flySpeed
			elseif keys.Q then
				vert = -flySpeed
			end

			if moveDir.Magnitude > 0 then
				moveDir = moveDir.Unit * flySpeed
			end

			lv.VectorVelocity = Vector3.new(moveDir.X, vert, moveDir.Z)
		end)

		GH.ShowToast("Vehicle Fly: WASD+QE | Scroll=velocidade (" .. (GH.FlySpeed or 20) .. ")", GH.Theme.On, 3)
	end

	GH.RegisterToggleButton("VehicleFly", "toggle_vehiclefly", Cheats_ToggleVehicleFly, "Movement", "desc_vehiclefly")
end
