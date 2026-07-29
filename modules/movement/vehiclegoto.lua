-- =============================================================================
-- COMMAND: VEHICLE GOTO (Voo rápido até o player marcado)
-- Voa o veículo automaticamente até o jogador selecionado usando BodyVelocity
-- =============================================================================
return function(GH)
	local RunService = GH.Services.RunService
	local Players = GH.Services.Players
	local LocalPlayer = GH.LocalPlayer

	local activeTarget = nil

	local function cleanupGoto()
		activeTarget = nil
		GH.Disconnect("VGoto_Stepped")
		-- Limpa instâncias de força no veículo
		local char = LocalPlayer.Character
		if char then
			local hum = char:FindFirstChildOfClass("Humanoid")
			if hum and hum.SeatPart then
				local root = hum.SeatPart.AssemblyRootPart or hum.SeatPart
				if root then
					local bv = root:FindFirstChild("GH_VGotoBV")
					local bg = root:FindFirstChild("GH_VGotoBG")
					if bv then bv:Destroy() end
					if bg then bg:Destroy() end
				end
				if hum.SeatPart:IsA("VehicleSeat") then
					hum.SeatPart.Throttle = 0
					hum.SeatPart.Steer = 0
				end
			end
		end
	end

	local function startGoto(targetPlayer, targetName)
		cleanupGoto()
		activeTarget = targetPlayer
		local flySpeed = 200
		local arrivalDist = 15

		GH.Connections.VGoto_Stepped = RunService.RenderStepped:Connect(function(dt)
			if GH.isClosing or not GH.States.VehicleGoto or not activeTarget or not activeTarget.Parent then
				cleanupGoto()
				return
			end

			local char = LocalPlayer.Character
			local hum = char and char:FindFirstChildOfClass("Humanoid")
			local seat = hum and hum.SeatPart

			if not hum or not seat then
				cleanupGoto()
				return
			end

			local targetChar = activeTarget.Character
			local targetRoot = targetChar and targetChar:FindFirstChild("HumanoidRootPart")
			if not targetRoot then
				GH.ShowToast("Alvo não encontrado!", GH.Theme.Red, 2)
				cleanupGoto()
				return
			end

			local root = seat.AssemblyRootPart or seat
			if not root then return end

			-- Desativa controle padrão das rodas
			if seat:IsA("VehicleSeat") then
				seat.Throttle = 0
				seat.Steer = 0
			end

			-- BodyVelocity (movimento)
			local bv = root:FindFirstChild("GH_VGotoBV")
			if not bv then
				bv = Instance.new("BodyVelocity")
				bv.Name = "GH_VGotoBV"
				bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
				bv.Velocity = Vector3.zero
				bv.Parent = root
			end

			-- BodyGyro (orientação)
			local bg = root:FindFirstChild("GH_VGotoBG")
			if not bg then
				bg = Instance.new("BodyGyro")
				bg.Name = "GH_VGotoBG"
				bg.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
				bg.P = 8000
				bg.D = 500
				bg.CFrame = root.CFrame
				bg.Parent = root
			end

			-- Direção até o alvo
			local myPos = root.Position
			local targetPos = targetRoot.Position
			local diff = targetPos - myPos
			local dist = diff.Magnitude

			-- Se chegou perto, para
			if dist < arrivalDist then
				bv.Velocity = Vector3.zero
				root.AssemblyLinearVelocity = Vector3.zero
				root.AssemblyAngularVelocity = Vector3.zero
				cleanupGoto()
				GH.ShowToast(string.format(GH.T("toast_vehicle_to") or "Chegou em %s!", targetName), GH.Theme.On, 2)
				return
			end

			-- Velocidade proporcional à distância (desacelera suavemente)
			local speed = math.min(flySpeed, dist * 3 + 50)
			local dir = diff.Unit
			bv.Velocity = dir * speed

			-- Zera rotação natural
			root.AssemblyAngularVelocity = Vector3.zero

			-- Orienta o veículo na direção do alvo
			local lookDir = Vector3.new(dir.X, 0, dir.Z)
			if lookDir.Magnitude > 0.01 then
				lookDir = lookDir.Unit
			else
				lookDir = root.CFrame.LookVector
			end

			-- Inclina o nariz pra cima/baixo proporcional à diferença de altura
			local pitchAngle = math.asin(math.clamp(dir.Y, -1, 1))
			local targetCFrame = CFrame.new(root.Position)
				* CFrame.lookAt(Vector3.zero, lookDir)
				* CFrame.Angles(pitchAngle, 0, 0)

			bg.CFrame = targetCFrame
		end)
	end

	function Cheats_ToggleVehicleGoto(state, btn)
		if not state then
			cleanupGoto()
			if GH.Objects.VehicleGotoPicker then
				GH.Objects.VehicleGotoPicker.Close()
				GH.Objects.VehicleGotoPicker = nil
			end
			return
		end

		local picker = GH.ShowPlayerPicker(GH.T("dropdown_vehiclegoto_title"), function(name)
			local player = Players:FindFirstChild(name)
			if player and player.Character then
				local targetRoot = player.Character:FindFirstChild("HumanoidRootPart")
				local myChar = LocalPlayer.Character
				local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
				if targetRoot and myRoot then
					-- Check if seated in vehicle
					local seat = myRoot.Parent:FindFirstChildWhichIsA("VehicleSeat") or myRoot.Parent:FindFirstChildWhichIsA("Seat")
					if seat then
						startGoto(player, name)
						GH.ShowToast(string.format(GH.T("toast_vehicle_to") or "Indo até %s!", name), GH.Theme.On, 2)
					else
						GH.ShowToast("Not in a vehicle!", GH.Theme.Red, 2)
					end
				end
			end
		end)
		GH.Objects.VehicleGotoPicker = picker
	end

	GH.RegisterToggleButton("VehicleGoto", "toggle_vehiclegoto", Cheats_ToggleVehicleGoto, "Movement", "desc_vehiclegoto")
end
