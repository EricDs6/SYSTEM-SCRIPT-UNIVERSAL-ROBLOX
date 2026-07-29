-- =============================================================================
-- COMMAND: VEHICLE FLY (Modo Avião - Pitch livre + Roll nas curvas)
-- Voar dirigindo veículos com travamento anti-giro. WASD + E/Q + +/- Velocidade
-- =============================================================================
return function(GH)
	local UserInputService = GH.Services.UserInputService
	local RunService = GH.Services.RunService
	local LocalPlayer = GH.LocalPlayer

	local keys = { W = false, A = false, S = false, D = false, E = false, Q = false, LeftShift = false }
	local originalCameraType = nil

	-- ===== CONFIG DO MODO AVIÃO =====
	local maxPitchDeg = 45      -- inclinação máxima do nariz pra cima/baixo
	local maxRollDeg = 30       -- inclinação lateral máxima nas curvas
	local turnRollFactor = 25   -- quanto de roll por unidade de giro horizontal
	local orientLerpAlpha = 0.12 -- suavização da rotação (menor = mais suave/avião pesado)

	local currentYaw = 0   -- ângulo horizontal acumulado do veículo
	local lastYaw = 0      -- yaw do frame anterior, pra medir a taxa de giro (-> roll)

	function Cheats_ToggleVehicleFly(state, btn)
		GH.Disconnect("VFly_Stepped")
		GH.Disconnect("VFly_InputBegan")
		GH.Disconnect("VFly_InputEnded")
		GH.Disconnect("VFly_Scroll")

		local function restoreCamera()
			local cam = workspace.CurrentCamera
			if cam and originalCameraType then
				cam.CameraType = originalCameraType
				originalCameraType = nil
			end
		end

		local function clearVehiclePhysics()
			local char = LocalPlayer.Character
			if char then
				local hum = char:FindFirstChildOfClass("Humanoid")
				if hum and hum.SeatPart then
					local vehicleModel = hum.SeatPart.Parent
					if vehicleModel and vehicleModel:IsA("Model") then
						local primary = vehicleModel.PrimaryPart or hum.SeatPart
						local bv = primary:FindFirstChild("GH_VFlyBV")
						local bg = primary:FindFirstChild("GH_VFlyBG")
						if bv then bv:Destroy() end
						if bg then bg:Destroy() end
					end
					if hum.SeatPart:IsA("VehicleSeat") then
						hum.SeatPart.Throttle = 0
						hum.SeatPart.Steer = 0
					end
				end
			end
			restoreCamera()
		end

		if not state then
			clearVehiclePhysics()
			for k in pairs(keys) do keys[k] = false end
			return
		end

		for k in pairs(keys) do keys[k] = false end
		currentYaw = 0
		lastYaw = 0

		GH.Connections.VFly_InputBegan = UserInputService.InputBegan:Connect(function(input, gpe)
			if gpe then return end
			if not GH.States.VehicleFly then return end
			local name = input.KeyCode.Name
			if keys[name] ~= nil then
				keys[name] = true
			end
		end)

		GH.Connections.VFly_InputEnded = UserInputService.InputEnded:Connect(function(input)
			local name = input.KeyCode.Name
			if keys[name] ~= nil then
				keys[name] = false
			end
		end)

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

			if not hum or not seat then return end

			local targetPart = seat.AssemblyRootPart or seat
			if not targetPart then return end

			local cam = workspace.CurrentCamera
			if not cam then return end

			if cam.CameraType ~= Enum.CameraType.Scriptable then
				if not originalCameraType then
					originalCameraType = cam.CameraType
				end
				cam.CameraType = Enum.CameraType.Scriptable
			end

			local camCF = cam.CFrame

			if seat:IsA("VehicleSeat") then
				seat.Throttle = 0
				seat.Steer = 0
			end

			local bv = targetPart:FindFirstChild("GH_VFlyBV")
			if not bv then
				bv = Instance.new("BodyVelocity")
				bv.Name = "GH_VFlyBV"
				bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
				bv.Velocity = Vector3.zero
				bv.Parent = targetPart
			end

			local bg = targetPart:FindFirstChild("GH_VFlyBG")
			if not bg then
				bg = Instance.new("BodyGyro")
				bg.Name = "GH_VFlyBG"
				bg.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
				bg.P = 6000
				bg.D = 400
				bg.CFrame = targetPart.CFrame
				bg.Parent = targetPart
			end

			local speed = GH.FlySpeed or 50
			if keys.LeftShift then
				speed = speed * 2
			end

			local moveDir = Vector3.zero
			if keys.W then moveDir = moveDir + camCF.LookVector end
			if keys.S then moveDir = moveDir - camCF.LookVector end
			if keys.D then moveDir = moveDir + camCF.RightVector end
			if keys.A then moveDir = moveDir - camCF.RightVector end
			if keys.E then moveDir = moveDir + Vector3.new(0, 1, 0) end
			if keys.Q then moveDir = moveDir - Vector3.new(0, 1, 0) end

			if moveDir.Magnitude > 0 then
				bv.Velocity = moveDir.Unit * speed
			else
				bv.Velocity = Vector3.zero
			end

			targetPart.AssemblyAngularVelocity = Vector3.zero

			-- ===== MODO AVIÃO: pitch livre (limitado) + roll nas curvas =====

			-- Yaw: direção horizontal da câmera (sempre nivelada no eixo horizontal)
			local flatLook = Vector3.new(camCF.LookVector.X, 0, camCF.LookVector.Z)
			if flatLook.Magnitude > 0.01 then
				flatLook = flatLook.Unit
			else
				flatLook = targetPart.CFrame.LookVector
			end
			local yaw = math.atan2(-flatLook.X, -flatLook.Z)

			-- Pitch: inclinação vertical da câmera, limitada pra não perder controle
			local pitch = math.asin(math.clamp(camCF.LookVector.Y, -1, 1))
			local maxPitchRad = math.rad(maxPitchDeg)
			pitch = math.clamp(pitch, -maxPitchRad, maxPitchRad)

			-- Roll: baseado na taxa de giro horizontal (yaw), simula inclinar nas curvas
			local yawDelta = yaw - lastYaw
			-- normaliza pra evitar salto ao cruzar +-180°
			if yawDelta > math.pi then yawDelta -= 2 * math.pi end
			if yawDelta < -math.pi then yawDelta += 2 * math.pi end
			local yawRate = (dt > 0) and (yawDelta / dt) or 0
			lastYaw = yaw

			local rollRad = math.clamp(-yawRate * math.rad(turnRollFactor) * 0.1, -math.rad(maxRollDeg), math.rad(maxRollDeg))

			-- Monta a CFrame final: yaw (Y) -> pitch (X) -> roll (Z), na ordem certa pra
			-- parecer avião (rotação intrínseca)
			local targetCFrame = CFrame.new(targetPart.Position)
				* CFrame.Angles(0, yaw, 0)
				* CFrame.Angles(pitch, 0, 0)
				* CFrame.Angles(0, 0, rollRad)

			-- Suaviza a orientação pra não ficar travada/robótica (efeito "avião pesado")
			bg.CFrame = bg.CFrame:Lerp(targetCFrame, orientLerpAlpha)
		end)

		if GH.ShowToast then
			GH.ShowToast("Vehicle Fly (Avião): WASD+EQ | Shift=Boost | +/- Speed (" .. (GH.FlySpeed or 50) .. ")", GH.Theme.On, 3)
		end
	end

	GH.RegisterToggleButton("VehicleFly", "toggle_vehiclefly", Cheats_ToggleVehicleFly, "Movement", "desc_vehiclefly")
end