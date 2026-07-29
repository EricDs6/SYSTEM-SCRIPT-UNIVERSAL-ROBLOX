-- =============================================================================
-- COMMAND: VEHICLE FLY (Orientado à Câmera e Sem Travar)
-- Voar dirigindo veículos. WASD + E/Q (Subir/Descer) + +/- Velocidade
-- =============================================================================
return function(GH)
	local UserInputService = GH.Services.UserInputService
	local RunService = GH.Services.RunService
	local LocalPlayer = GH.LocalPlayer

	local keys = { W = false, A = false, S = false, D = false, E = false, Q = false, LeftShift = false }

	function Cheats_ToggleVehicleFly(state, btn)
		GH.Disconnect("VFly_Stepped")
		GH.Disconnect("VFly_InputBegan")
		GH.Disconnect("VFly_InputEnded")
		GH.Disconnect("VFly_Scroll")

		local function clearVehiclePhysics()
			local char = LocalPlayer.Character
			if char then
				local hum = char:FindFirstChildOfClass("Humanoid")
				if hum and hum.SeatPart then
					local vehicleModel = hum.SeatPart.Parent
					if vehicleModel:IsA("Model") then
						local primary = vehicleModel.PrimaryPart or hum.SeatPart
						local bv = primary:FindFirstChild("GH_VFlyBV")
						if bv then bv:Destroy() end
					end
				end
			end
		end

		if not state then
			clearVehiclePhysics()
			for k in pairs(keys) do keys[k] = false end
			return
		end

		for k in pairs(keys) do keys[k] = false end

		-- InputBegan
		GH.Connections.VFly_InputBegan = UserInputService.InputBegan:Connect(function(input, gpe)
			if gpe then return end
			if not GH.States.VehicleFly then return end
			local name = input.KeyCode.Name
			if keys[name] ~= nil then
				keys[name] = true
			end
		end)

		-- InputEnded
		GH.Connections.VFly_InputEnded = UserInputService.InputEnded:Connect(function(input)
			local name = input.KeyCode.Name
			if keys[name] ~= nil then
				keys[name] = false
			end
		end)

		-- Teclas +/-: ajustar velocidade
		GH.Connections.VFly_Scroll = UserInputService.InputBegan:Connect(function(input, gpe)
			if gpe then return end
			if not GH.States.VehicleFly then return end
			if input.KeyCode == Enum.KeyCode.Equals or input.KeyCode == Enum.KeyCode.KeypadPlus then
				GH.FlySpeed = math.clamp((GH.FlySpeed or 50) + 10, 10, 300)
				if GH.ShowToast then GH.ShowToast("Vehicle Fly Speed: " .. GH.FlySpeed, GH.Theme.Accent, 1) end
			elseif input.KeyCode == Enum.KeyCode.Minus or input.KeyCode == Enum.KeyCode.KeypadMinus then
				GH.FlySpeed = math.clamp((GH.FlySpeed or 50) - 10, 10, 300)
				if GH.ShowToast then GH.ShowToast("Vehicle Fly Speed: " .. GH.FlySpeed, GH.Theme.Accent, 1) end
			end
		end)

		-- Loop principal (RenderStepped)
		GH.Connections.VFly_Stepped = RunService.RenderStepped:Connect(function(dt)
			if GH.isClosing or not GH.States.VehicleFly then
				clearVehiclePhysics()
				GH.Disconnect("VFly_Stepped")
				GH.Disconnect("VFly_InputBegan")
				GH.Disconnect("VFly_InputEnded")
				GH.Disconnect("VFly_Scroll")
				return
			end

			local char = LocalPlayer.Character
			local hum = char and char:FindFirstChildOfClass("Humanoid")
			local seat = hum and hum.SeatPart

			-- Se o jogador não estiver sentado em um veículo
			if not hum or not seat then return end

			-- Localiza a parte principal da física do veículo
			local targetPart = seat.AssemblyRootPart or seat
			if not targetPart then return end

			local cam = workspace.CurrentCamera
			if not cam then return end
			local camCF = cam.CFrame

			-- Garante que o BodyVelocity exista na parte raiz do veículo
			local bv = targetPart:FindFirstChild("GH_VFlyBV")
			if not bv then
				bv = Instance.new("BodyVelocity")
				bv.Name = "GH_VFlyBV"
				bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
				bv.Velocity = Vector3.zero
				bv.Parent = targetPart
			end

			-- Velocidade base + Boost
			local speed = GH.FlySpeed or 50
			if keys.LeftShift then
				speed = speed * 2
			end

			-- Vetores de direção tridimensional baseados na Câmera
			local moveDir = Vector3.zero

			if keys.W then moveDir = moveDir + camCF.LookVector end
			if keys.S then moveDir = moveDir - camCF.LookVector end
			if keys.D then moveDir = moveDir + camCF.RightVector end
			if keys.A then moveDir = moveDir - camCF.RightVector end
			if keys.E then moveDir = moveDir + Vector3.new(0, 1, 0) end
			if keys.Q then moveDir = moveDir - Vector3.new(0, 1, 0) end

			-- Aplica movimento ou trava o veículo no ar sem perder altura
			if moveDir.Magnitude > 0 then
				bv.Velocity = moveDir.Unit * speed
			else
				bv.Velocity = Vector3.zero
			end

			-- Zera desaceleração natural para não afundar
			targetPart.AssemblyLinearVelocity = Vector3.zero
			targetPart.AssemblyAngularVelocity = Vector3.zero

			-- GIRA O VEÍCULO PARA ACOMPANHAR A DIREÇÃO DA CÂMERA
			targetPart.CFrame = CFrame.new(targetPart.Position, targetPart.Position + camCF.LookVector)
		end)

		if GH.ShowToast then
			GH.ShowToast("Vehicle Fly: WASD+EQ | Shift=Boost | +/- Speed (" .. (GH.FlySpeed or 50) .. ")", GH.Theme.On, 3)
		end
	end

	GH.RegisterToggleButton("VehicleFly", "toggle_vehiclefly", Cheats_ToggleVehicleFly, "Movement", "desc_vehiclefly")
end