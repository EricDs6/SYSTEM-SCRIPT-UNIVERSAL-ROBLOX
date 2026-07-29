-- =============================================================================
-- COMMAND: VEHICLE TROLL (Atropelo Infinito)
-- Voa o veiculo repetidamente contra um jogador alvo causando bug de colisao
-- Ciclo agressivo: approach → ram contínuo → reposiciona rápido → ram de novo
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
	local cachedRoot = nil

	-- ==========================================
	-- CONFIGS AGRESSIVAS
	-- ==========================================
	local APPROACH_SPEED = 500      -- velocidade maxima para chegar no alvo
	local RAM_SPEED = 600           -- velocidade do atropelamento (brutal)
	local REPOSITION_SPEED = 350    -- velocidade do reposicionamento rapido
	local SPIN_SPEED = 12           -- rotacoes por segundo durante impacto
	local RAM_DISTANCE = 6          -- distancia para comecar o ram
	local REPOSITION_DISTANCE = 10  -- distancia minima antes de re-ram
	local RAM_DURATION = 0.35       -- duracao do empurrao
	local REPOSITION_DURATION = 0.12 -- reposicionamento super rapido
	local CHAOS_INTERVAL = 15       -- a cada N rams, ativa caos total
	local CHAOS_DURATION = 3.0      -- caos dura mais

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

		-- Limpar forcas usando o root armazenado
		if cachedRoot then
			local bv = cachedRoot:FindFirstChild("GH_VTrollBV")
			local bg = cachedRoot:FindFirstChild("GH_VTrollBG")
			if bv then bv:Destroy() end
			if bg then bg:Destroy() end
			pcall(function()
				if cachedRoot:IsA("BasePart") then
					cachedRoot.AssemblyLinearVelocity = Vector3.zero
					cachedRoot.AssemblyAngularVelocity = Vector3.zero
				end
			end)
		end
		cachedRoot = nil

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

	local function findNearestPlayer()
		local char = LocalPlayer.Character
		local myRoot = char and char:FindFirstChild("HumanoidRootPart")
		if not myRoot then return nil end

		local nearest = nil
		local minDist = 300

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

	local function applyChaosForces(root, bg, dt)
		spinAngle = spinAngle + SPIN_SPEED * dt * math.pi * 2

		local chaosX = math.cos(spinAngle * 1.3) * 150
		local chaosZ = math.sin(spinAngle * 0.7) * 150
		local chaosY = math.sin(spinAngle * 2) * 80

		return Vector3.new(chaosX, chaosY, chaosZ)
	end

	local function getAggressiveDirection(dir, dist, root, dt)
		local perturbX = (math.random() - 0.5) * 40
		local perturbZ = (math.random() - 0.5) * 40

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

			if not seat:IsA("VehicleSeat") then
				cleanupVehicleTroll()
				GH.ShowToast("Precisa ser VehicleSeat!", GH.Theme.Red, 2)
				return
			end

			local targetChar = activeTarget.Character
			local targetRoot = targetChar and targetChar:FindFirstChild("HumanoidRootPart")

			if not targetRoot then
				local newTarget = findNearestPlayer()
				if newTarget and newTarget.Character then
					activeTarget = newTarget
					targetRoot = newTarget.Character:FindFirstChild("HumanoidRootPart")
				end
				if not targetRoot then return end
			end

			local root = seat.AssemblyRootPart or seat
			if not root then return end

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
				bg.P = 50000   -- rigidez extrema
				bg.D = 2000    -- resposta instantanea
				bg.CFrame = root.CFrame
				bg.Parent = root
			end

			-- Direcao e distancia ao alvo
			local myPos = root.Position
			local targetPos = targetRoot.Position
			local diff = targetPos - myPos
			local dist = diff.Magnitude
			local dir = diff.Unit

			lastTargetPos = targetPos

			-- Zera controle angular
			pcall(function() root.AssemblyAngularVelocity = Vector3.zero end)

			-- ==========================================
			-- MODO CAOS (a cada N rams)
			-- ==========================================
			if ramCount > 0 and ramCount % CHAOS_INTERVAL == 0 and not chaosMode then
				chaosMode = true
				chaosTimer = 0
				GH.ShowToast("MODO CAOS ATIVADO!", GH.Theme.Red, 2)
			end

			if chaosMode then
				chaosTimer = chaosTimer + dt
				if chaosTimer > CHAOS_DURATION then
					chaosMode = false
				end
			end

			phaseTimer = phaseTimer + dt

			-- ==========================================
			-- MODO CAOS: girar e atacar em todas as direcoes
			-- ==========================================
			if chaosMode then
				local chaosForce = applyChaosForces(root, bg, dt)
				local targetY = targetRoot.Position.Y
				local myY = root.Position.Y
				local verticalChaos = math.clamp((targetY - myY) * 0.5, -20, 20)

				-- Manter perto do alvo mesmo no caos
				if dist > 15 then
					bv.Velocity = dir * APPROACH_SPEED * 1.8 + chaosForce * 0.4
				else
					bv.Velocity = chaosForce + Vector3.new(0, verticalChaos, 0)
				end

				-- Girar o veiculo brutalmente
				local spinCFrame = root.CFrame * CFrame.Angles(
					math.rad(SPIN_SPEED * 360 * dt),
					math.rad(SPIN_SPEED * 540 * dt),
					math.rad(SPIN_SPEED * 270 * dt)
				)
				bg.CFrame = spinCFrame

				return
			end

			-- ==========================================
			-- MAQUINA DE ESTADOS AGRESSIVA
			-- ==========================================
			if phase == "approach" then
				-- VOAR em direcao ao alvo em velocidade brutal
				local speed = math.min(APPROACH_SPEED, dist * 4 + 250)
				local lookDir, perturbX, perturbZ = getAggressiveDirection(dir, dist, root, dt)

				-- Correcao vertical - manter nivelado
				local targetY = targetRoot.Position.Y
				local myY = root.Position.Y
				local verticalVel = math.clamp((targetY - myY) * 0.6, -20, 20)

				bv.Velocity = Vector3.new(dir.X * speed + perturbX, verticalVel, dir.Z * speed + perturbZ)

				-- Orientar veiculo para o alvo
				local pitchAngle = math.clamp(dir.Y * 0.15, -0.08, 0.08)
				bg.CFrame = CFrame.new(root.Position) * CFrame.lookAt(Vector3.zero, lookDir) * CFrame.Angles(pitchAngle, 0, 0)

				-- Muito perto = BATER!
				if dist < RAM_DISTANCE + 5 then
					phase = "ram"
					phaseTimer = 0
				end

			elseif phase == "ram" then
				-- ==========================================
				-- EMPURRAR com forca MAXIMA - ATROPELAR!
				-- ==========================================
				local lookDir, perturbX, perturbZ = getAggressiveDirection(dir, dist, root, dt)

				-- Forca vertical para JOGAR o alvo pra cima
				local targetY = targetRoot.Position.Y
				local myY = root.Position.Y
				local verticalRam = math.clamp((targetY - myY) * 0.4 + 15, -5, 25)

				-- Ram com forca ABSURDA
				bv.Velocity = Vector3.new(
					dir.X * RAM_SPEED + perturbX,
					verticalRam,
					dir.Z * RAM_SPEED + perturbZ
				)

				-- Girar o veiculo VIOLENTAMENTE durante o impacto
				spinAngle = spinAngle + dt * SPIN_SPEED * math.pi * 2
				local spinX = math.sin(spinAngle) * 0.5
				local spinZ = math.cos(spinAngle * 0.7) * 0.4
				local spinY = math.sin(spinAngle * 1.5) * 0.6
				bg.CFrame = CFrame.new(root.Position) * CFrame.lookAt(Vector3.zero, lookDir) * CFrame.Angles(spinX, spinY, spinZ)

				-- Continuar empurrando por mais tempo
				if phaseTimer > RAM_DURATION then
					ramCount = ramCount + 1
					-- Em vez de recuar, reposiciona RAPIDO e bate de novo
					phase = "reposition"
					phaseTimer = 0

					if ramCount > 0 and ramCount % 3 == 0 then
						GH.ShowToast(
							string.format("%s atingido %dx!", activeTarget.Name, ramCount),
							GH.Theme.Red, 1.0
						)
					end
				end

			elseif phase == "reposition" then
				-- ==========================================
				-- REPOSICIONAR: recuar minimamente e bater de novo
				-- NAO recua longe - so o necessario para ganhar impulso
				-- ==========================================
				local lookDir, perturbX, perturbZ = getAggressiveDirection(-dir, dist, root, dt)

				-- Recuo MINIMO - so o necessario para impulso
				local repositionSpeed = math.min(REPOSITION_SPEED, REPOSITION_DISTANCE * 3)
				local targetY = targetRoot.Position.Y
				local myY = root.Position.Y
				local verticalRepo = math.clamp((targetY - myY) * 0.3, -10, 10)

				bv.Velocity = Vector3.new(
					-dir.X * repositionSpeed * 0.4 + perturbX,
					verticalRepo,
					-dir.Z * repositionSpeed * 0.4 + perturbZ
				)

				-- Manter olhando para o alvo
				local pitchAngle = math.clamp(dir.Y * 0.1, -0.05, 0.05)
				bg.CFrame = CFrame.new(root.Position) * CFrame.lookAt(Vector3.zero, lookDir) * CFrame.Angles(pitchAngle, 0, 0)

				-- Reposicionamento MUITO curto - voltar a bater rapido
				if phaseTimer > REPOSITION_DURATION or dist > REPOSITION_DISTANCE then
					phase = "approach"
					phaseTimer = 0
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
