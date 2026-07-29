-- =============================================================================
-- COMMAND: VEHICLE TROLL (Atropelo Infinito)
-- Voa o veiculo repetidamente contra um jogador alvo causando bug de colisao
-- O choque repetido joga/engata o jogador de forma imprevisivel
-- =============================================================================
return function(GH)
	local RunService = GH.Services.RunService
	local Players = GH.Services.Players
	local LocalPlayer = GH.LocalPlayer

	local activeTarget = nil
	local phase = "approach" -- "approach" | "ram" | "retreat"
	local phaseTimer = 0
	local ramCount = 0
	local lastTargetPos = nil

	local APPROACH_SPEED = 180
	local RAM_SPEED = 280
	local RETREAT_SPEED = 120
	local RAM_DISTANCE = 6
	local RETREAT_DISTANCE = 25
	local RAM_DURATION = 0.4
	local RETREAT_DURATION = 0.6

	local function cleanupVehicleTroll()
		activeTarget = nil
		phase = "approach"
		phaseTimer = 0
		ramCount = 0
		lastTargetPos = nil
		GH.Disconnect("VTroll_Stepped")

		-- Limpar forcas do veiculo
		local char = LocalPlayer.Character
		if char then
			local hum = char:FindFirstChildOfClass("Humanoid")
			if hum and hum.SeatPart then
				local root = hum.SeatPart.AssemblyRootPart or hum.SeatPart
				if root then
					local bv = root:FindFirstChild("GH_VTrollBV")
					local bg = root:FindFirstChild("GH_VTrollBG")
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

	local function startVehicleTroll(targetPlayer, targetName)
		cleanupVehicleTroll()
		activeTarget = targetPlayer
		phase = "approach"
		phaseTimer = 0
		ramCount = 0
		lastTargetPos = nil

		GH.Connections.VTroll_Stepped = RunService.RenderStepped:Connect(function(dt)
			if GH.isClosing or not GH.States.VehicleTroll or not activeTarget or not activeTarget.Parent then
				cleanupVehicleTroll()
				return
			end

			local char = LocalPlayer.Character
			local hum = char and char:FindFirstChildOfClass("Humanoid")
			local seat = hum and hum.SeatPart

			if not hum or not seat then
				cleanupVehicleTroll()
				GH.ShowToast("Saiu do veiculo!", GH.Theme.Red, 2)
				return
			end

			local targetChar = activeTarget.Character
			local targetRoot = targetChar and targetChar:FindFirstChild("HumanoidRootPart")
			if not targetRoot then
				-- Alvo pode ter morrido/respawnou, tentar pegar novo character
				return
			end

			local root = seat.AssemblyRootPart or seat
			if not root then return end

			-- Desativa controle padrao
			if seat:IsA("VehicleSeat") then
				seat.Throttle = 0
				seat.Steer = 0
			end

			-- BodyVelocity
			local bv = root:FindFirstChild("GH_VTrollBV")
			if not bv then
				bv = Instance.new("BodyVelocity")
				bv.Name = "GH_VTrollBV"
				bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
				bv.Velocity = Vector3.zero
				bv.Parent = root
			end

			-- BodyGyro
			local bg = root:FindFirstChild("GH_VTrollBG")
			if not bg then
				bg = Instance.new("BodyGyro")
				bg.Name = "GH_VTrollBG"
				bg.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
				bg.P = 8000
				bg.D = 500
				bg.CFrame = root.CFrame
				bg.Parent = root
			end

			-- Direcao e distancia ao alvo
			local myPos = root.Position
			local targetPos = targetRoot.Position
			local diff = targetPos - myPos
			local dist = diff.Magnitude
			local dir = diff.Unit

			-- Atualizar posicao do alvo para calculo de retreat
			lastTargetPos = targetPos

			-- Zera controle angular
			root.AssemblyAngularVelocity = Vector3.zero

			-- Maquina de estados: approach -> ram -> retreat -> approach...
			phaseTimer = phaseTimer + dt

			if phase == "approach" then
				-- VOAR em direcao ao alvo em alta velocidade
				local speed = math.min(APPROACH_SPEED, dist * 2 + 80)
				bv.Velocity = dir * speed + Vector3.new(0, 5, 0)

				-- Orientar veiculo na direcao do alvo
				local lookDir = Vector3.new(dir.X, 0, dir.Z)
				if lookDir.Magnitude > 0.01 then
					lookDir = lookDir.Unit
				else
					lookDir = root.CFrame.LookVector
				end
				local pitchAngle = math.asin(math.clamp(dir.Y, -1, 1))
				bg.CFrame = CFrame.new(root.Position) * CFrame.lookAt(Vector3.zero, lookDir) * CFrame.Angles(pitchAngle, 0, 0)

				-- Se chegou perto o suficiente, atacar!
				if dist < RAM_DISTANCE + 5 then
					phase = "ram"
					phaseTimer = 0
				end

			elseif phase == "ram" then
				-- EMPURRAR com forca maxima! Velocidade absurda para causar o bug
				bv.Velocity = dir * RAM_SPEED + Vector3.new(0, -10, 0)

				-- Manter orientacao no alvo
				local lookDir = Vector3.new(dir.X, 0, dir.Z)
				if lookDir.Magnitude > 0.01 then
					lookDir = lookDir.Unit
				else
					lookDir = root.CFrame.LookVector
				end
				bg.CFrame = CFrame.new(root.Position) * CFrame.lookAt(Vector3.zero, lookDir)

				-- Depois de um tempo curto, recuar para bater de novo
				if phaseTimer > RAM_DURATION then
					ramCount = ramCount + 1
					phase = "retreat"
					phaseTimer = 0
				end

			elseif phase == "retreat" then
				-- Recuar um pouco para ganhar espaco
				local retreatDir = -dir
				local speed = math.min(RETREAT_SPEED, RETREAT_DISTANCE)
				bv.Velocity = retreatDir * speed + Vector3.new(0, 15, 0)

				-- Olhar na direcao do alvo mesmo recuando
				local lookDir = Vector3.new(dir.X, 0, dir.Z)
				if lookDir.Magnitude > 0.01 then
					lookDir = lookDir.Unit
				else
					lookDir = root.CFrame.LookVector
				end
				bg.CFrame = CFrame.new(root.Position) * CFrame.lookAt(Vector3.zero, lookDir)

				-- Depois de recuar o suficiente, atacar de novo
				if phaseTimer > RETREAT_DURATION or dist > RETREAT_DISTANCE then
					phase = "approach"
					phaseTimer = 0

					-- Feedback visual a cada 5 colisoes
					if ramCount > 0 and ramCount % 5 == 0 then
						GH.ShowToast(
							string.format("%s atingido %dx!", activeTarget.Name, ramCount),
							GH.Theme.Red, 1.5
						)
					end
				end
			end
		end)
	end

	function Cheats_ToggleVehicleTroll(state, btn)
		if not state then
			cleanupVehicleTroll()
			if GH.Objects.VehicleTrollPicker then
				GH.Objects.VehicleTrollPicker.Close()
				GH.Objects.VehicleTrollPicker = nil
			end
			return
		end

		local picker = GH.ShowPlayerPicker(GH.T("dropdown_vehicletroll_title"), function(name)
			local player = Players:FindFirstChild(name)
			if player and player.Character then
				local targetRoot = player.Character:FindFirstChild("HumanoidRootPart")
				local myChar = LocalPlayer.Character
				local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
				if targetRoot and myRoot then
					-- Verificar se esta em um veiculo
					local myHum = myChar:FindFirstChildOfClass("Humanoid")
					local seat = myHum and myHum.SeatPart
					if seat then
						startVehicleTroll(player, name)
						GH.ShowToast(
							string.format(GH.T("toast_vehicletroll_start") or "Atropelando %s!", name),
							GH.Theme.Red, 2
						)
					else
						GH.ShowToast("Entre em um veiculo primeiro!", GH.Theme.Red, 2)
					end
				end
			end
		end)
		GH.Objects.VehicleTrollPicker = picker
	end

	GH.RegisterToggleButton("VehicleTroll", "toggle_vehicletroll", Cheats_ToggleVehicleTroll, "Troll", "desc_vehicletroll")
end
