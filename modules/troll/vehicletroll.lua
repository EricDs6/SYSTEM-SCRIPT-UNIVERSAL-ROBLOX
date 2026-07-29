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
	local phase = "approach"
	local phaseTimer = 0
	local ramCount = 0
	local lastTargetPos = nil
	local spinAngle = 0
	local chaosMode = false
	local chaosTimer = 0
	local cachedRoot = nil -- armazena o root do veiculo para cleanup mesmo apos sair do seat

	-- Configuracoes agressivas
	local APPROACH_SPEED = 350
	local RAM_SPEED = 450
	local RETREAT_SPEED = 200
	local SPIN_SPEED = 8 -- rotacoes por segundo
	local RAM_DISTANCE = 5
	local RETREAT_DISTANCE = 18
	local RAM_DURATION = 0.2 -- mais rapido
	local RETREAT_DURATION = 0.3 -- mais rapido
	local CHAOS_INTERVAL = 30 -- a cada 30 rams, ativa caos total
	local CHAOS_DURATION = 2.0

	local function cleanupVehicleTroll()
		activeTarget = nil
		phase = "approach"
		phaseTimer = 0
		ramCount = 0
		lastTargetPos = nil
		spinAngle = 0
		chaosMode = false
		chaosTimer = 0
		GH.Disconnect("VTroll_Stepped")

		-- Limpar forcas usando o root armazenado (funciona mesmo apos sair do seat)
		if cachedRoot then
			local bv = cachedRoot:FindFirstChild("GH_VTrollBV")
			local bg = cachedRoot:FindFirstChild("GH_VTrollBG")
			if bv then bv:Destroy() end
			if bg then bg:Destroy() end
			-- Resetar velocity do root para evitar que o veiculo voe
			pcall(function()
				if cachedRoot:IsA("BasePart") then
					cachedRoot.AssemblyLinearVelocity = Vector3.zero
					cachedRoot.AssemblyAngularVelocity = Vector3.zero
				end
			end)
		end
		cachedRoot = nil

		-- Tentar limpar seat tambem (caso ainda esteja sentado)
		local char = LocalPlayer.Character
		if char then
			local hum = char:FindFirstChildOfClass("Humanoid")
			if hum and hum.SeatPart then
				if hum.SeatPart:IsA("VehicleSeat") then
					hum.SeatPart.Throttle = 0
					hum.SeatPart.Steer = 0
				end
			end
		end
	end

	-- Funcao para encontrar o alvo mais proximo se o alvo atual sumiu
	local function findNearestPlayer()
		local char = LocalPlayer.Character
		local myRoot = char and char:FindFirstChild("HumanoidRootPart")
		if not myRoot then return nil end

		local nearest = nil
		local minDist = 200

		for _, player in ipairs(Players:GetPlayers()) do
			if player ~= LocalPlayer and player.Character then
				local root = player.Character:FindFirstChild("HumanoidRootPart")
				if root then
					local dist = (root.Position - myRoot.Position).Magnitude
					if dist < minDist then
						minDist = dist
						nearest = player
					end
				end
			end
		end

		return nearest
	end

	-- Funcao para aplicar forca caotica ao veiculo
	local function applyChaosForces(root, bg, dt)
		spinAngle = spinAngle + SPIN_SPEED * dt * math.pi * 2

		-- Movimento circular caotico
		local chaosX = math.cos(spinAngle * 1.3) * 100
		local chaosZ = math.sin(spinAngle * 0.7) * 100
		local chaosY = math.sin(spinAngle * 2) * 50

		return Vector3.new(chaosX, chaosY, chaosZ)
	end

	-- Funcao para pegar direcao agressiva (horizontal para atropelar)
	local function getAggressiveDirection(dir, dist, root, dt)
		-- Adicionar perturbacao para ser imprevisivel
		local perturbX = (math.random() - 0.5) * 30
		local perturbZ = (math.random() - 0.5) * 30

		local lookDir = Vector3.new(dir.X, 0, dir.Z)
		if lookDir.Magnitude > 0.01 then
			lookDir = lookDir.Unit
		else
			lookDir = root.CFrame.LookVector
		end

		return lookDir, perturbX, perturbZ
	end

	local function startVehicleTroll(targetPlayer, targetName)
		cleanupVehicleTroll()
		activeTarget = targetPlayer
		phase = "approach"
		phaseTimer = 0
		ramCount = 0
		lastTargetPos = nil
		spinAngle = 0
		chaosMode = false
		chaosTimer = 0

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

			-- Verificar se ainda esta no mesmo veiculo
			if not seat:IsA("VehicleSeat") then
				cleanupVehicleTroll()
				GH.ShowToast("Precisa ser VehicleSeat!", GH.Theme.Red, 2)
				return
			end

			local targetChar = activeTarget.Character
			local targetRoot = targetChar and targetChar:FindFirstChild("HumanoidRootPart")

			-- Se o alvo morreu/respawnou, procurar novo alvo ou limpar
			if not targetRoot then
				local newTarget = findNearestPlayer()
				if newTarget and newTarget.Character then
					activeTarget = newTarget
					targetRoot = newTarget.Character:FindFirstChild("HumanoidRootPart")
				end
				if not targetRoot then
					return
				end
			end

			local root = seat.AssemblyRootPart or seat
			if not root then return end

			-- Armazenar root para cleanup posterior
			cachedRoot = root

			-- Desativar controle padrao
			seat.Throttle = 0
			seat.Steer = 0

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
				bg.P = 10000 -- mais rigido
				bg.D = 800 -- mais responsivo
				bg.CFrame = root.CFrame
				bg.Parent = root
			end

			-- Direcao e distancia ao alvo
			local myPos = root.Position
			local targetPos = targetRoot.Position
			local diff = targetPos - myPos
			local dist = diff.Magnitude
			local dir = diff.Unit

			-- Atualizar posicao do alvo
			lastTargetPos = targetPos

			-- Zera controle angular
			pcall(function() root.AssemblyAngularVelocity = Vector3.zero end)

			-- Ativar modo caos a cada N rams
			if ramCount > 0 and ramCount % CHAOS_INTERVAL == 0 and not chaosMode then
				chaosMode = true
				chaosTimer = 0
				GH.ShowToast("MODO CAOS ATIVADO!", GH.Theme.Red, 2)
			end

			-- Timer do caos
			if chaosMode then
				chaosTimer = chaosTimer + dt
				if chaosTimer > CHAOS_DURATION then
					chaosMode = false
				end
			end

			phaseTimer = phaseTimer + dt

			-- Modo caos: girar e atacar em todas as direcoes
			if chaosMode then
				local chaosForce = applyChaosForces(root, bg, dt)
				local targetY = targetRoot.Position.Y
				local myY = root.Position.Y
				local verticalChaos = math.clamp((targetY - myY) * 0.3, -10, 10)
				bv.Velocity = Vector3.new(chaosForce.X, verticalChaos, chaosForce.Z)

				-- Girar o veiculo rapidamente
				local spinCFrame = root.CFrame * CFrame.Angles(0, math.rad(SPIN_SPEED * 360 * dt), 0)
				bg.CFrame = spinCFrame

				-- Mesmo no caos, manter perto do alvo
				if dist > 30 then
					bv.Velocity = dir * APPROACH_SPEED * 1.5 + chaosForce * 0.3
				end

				return
			end

			-- Maquina de estados mais agressiva
			if phase == "approach" then
				-- VOAR em direcao ao alvo em velocidade absurda
				local speed = math.min(APPROACH_SPEED, dist * 3 + 150)
				local lookDir, perturbX, perturbZ = getAggressiveDirection(dir, dist, root, dt)
				-- Correcao vertical SUAVE e LIMITADA - evita sobrevoar
				local targetY = targetRoot.Position.Y
				local myY = root.Position.Y
				local verticalVel = math.clamp((targetY - myY) * 0.5, -15, 15)
				bv.Velocity = Vector3.new(dir.X * speed + perturbX, verticalVel, dir.Z * speed + perturbZ)

				-- Orientar veiculo HORIZONTALMENTE - sem inclinacao para cima
				local pitchAngle = math.clamp(dir.Y * 0.1, -0.05, 0.05)
				bg.CFrame = CFrame.new(root.Position) * CFrame.lookAt(Vector3.zero, lookDir) * CFrame.Angles(pitchAngle, 0, 0)

				-- Atacar mais rapidamente
				if dist < RAM_DISTANCE + 3 then
					phase = "ram"
					phaseTimer = 0
				end

			elseif phase == "ram" then
				-- EMPURRAR com forca MAXIMA! Atropelar de verdade!
				local lookDir, perturbX, perturbZ = getAggressiveDirection(dir, dist, root, dt)
				-- Ram HORIZONTAL puro - manter nivel para bater de frente
				local targetY = targetRoot.Position.Y
				local myY = root.Position.Y
				local verticalRam = math.clamp((targetY - myY) * 0.3, -5, 5)
				bv.Velocity = Vector3.new(dir.X * RAM_SPEED + perturbX, verticalRam, dir.Z * RAM_SPEED + perturbZ)

				-- Adicionar girada durante o impacto para mais caos
				spinAngle = spinAngle + dt * 4
				local spinOffset = math.sin(spinAngle) * 0.3
				bg.CFrame = CFrame.new(root.Position) * CFrame.lookAt(Vector3.zero, lookDir) * CFrame.Angles(spinOffset, 0, 0)

				-- Impacto mais curto e mais violento
				if phaseTimer > RAM_DURATION then
					ramCount = ramCount + 1
					phase = "retreat"
					phaseTimer = 0
				end

			elseif phase == "retreat" then
				-- Recuar muito rapido para ganhar espaco
				local retreatDir = -dir
				local speed = math.min(RETREAT_SPEED * 1.5, RETREAT_DISTANCE * 2)
				local lookDir, perturbX, perturbZ = getAggressiveDirection(-dir, dist, root, dt)
				local targetY = targetRoot.Position.Y
				local myY = root.Position.Y
				local verticalRetreat = math.clamp((targetY - myY) * 0.3, -10, 10)
				bv.Velocity = Vector3.new(retreatDir.X * speed + perturbX * 2, verticalRetreat, retreatDir.Z * speed + perturbZ * 2)

				-- Sempre olhar para o alvo - NAO inclinar o veiculo
				local pitchAngle = math.clamp(dir.Y * 0.1, -0.05, 0.05)
				bg.CFrame = CFrame.new(root.Position) * CFrame.lookAt(Vector3.zero, lookDir) * CFrame.Angles(pitchAngle, 0, 0)

				-- Voltar a atacar mais rapidamente
				if phaseTimer > RETREAT_DURATION or dist > RETREAT_DISTANCE then
					phase = "approach"
					phaseTimer = 0

					-- Feedback visual mais frequente
					if ramCount > 0 and ramCount % 3 == 0 then
						GH.ShowToast(
							string.format("%s atingido %dx!", activeTarget.Name, ramCount),
							GH.Theme.Red, 1.0
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
