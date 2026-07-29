-- =============================================================================
-- COMMAND: VEHICLE TROLL (Atropelo Brutal / Caos Contínuo)
-- Entra direto na posição do alvo com velocidade e massa extrema para colisão.
-- =============================================================================
return function(GH)
	local RunService = GH.Services.RunService
	local Players = GH.Services.Players
	local LocalPlayer = GH.LocalPlayer

	local activeTarget = nil
	local cachedRoot = nil

	local function cleanupVehicleTroll()
		activeTarget = nil
		GH.Disconnect("VTroll_Stepped")

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

	local function startVehicleTroll(targetPlayer, targetName)
		cleanupVehicleTroll()
		activeTarget = targetPlayer

		GH.Connections.VTroll_Stepped = RunService.RenderStepped:Connect(function(dt)
			if GH.isClosing or not GH.States.VehicleTroll or not activeTarget or not activeTarget.Parent then
				cleanupVehicleTroll()
				return
			end

			local char = LocalPlayer.Character
			local hum = char and char:FindFirstChildOfClass("Humanoid")
			local seat = hum and hum.SeatPart

			if not hum or not seat or not seat:IsA("VehicleSeat") then
				cleanupVehicleTroll()
				if GH.ShowToast then GH.ShowToast("Saiu do veículo!", GH.Theme.Red, 2) end
				return
			end

			local targetChar = activeTarget.Character
			local targetRoot = targetChar and targetChar:FindFirstChild("HumanoidRootPart")
			local targetHum = targetChar and targetChar:FindFirstChildOfClass("Humanoid")

			if not targetRoot or not targetHum or targetHum.Health <= 0 then
				cleanupVehicleTroll()
				if GH.ShowToast then GH.ShowToast("Alvo fora de alcance ou morto!", GH.Theme.Red, 2) end
				return
			end

			local root = seat.AssemblyRootPart or seat
			if not root then return end
			cachedRoot = root

			-- Desativa o controle nativo do assento
			seat.Throttle = 0
			seat.Steer = 0

			-- Garante física pesada para o veículo passar por cima com impacto
			pcall(function()
				root.CustomPhysicalProperties = PhysicalProperties.new(100, 1, 1, 1, 1)
			end)

			-- Instâncias de força física bruta
			local bv = root:FindFirstChild("GH_VTrollBV")
			if not bv then
				bv = Instance.new("BodyVelocity")
				bv.Name = "GH_VTrollBV"
				bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
				bv.Parent = root
			end

			local bg = root:FindFirstChild("GH_VTrollBG")
			if not bg then
				bg = Instance.new("BodyGyro")
				bg.Name = "GH_VTrollBG"
				bg.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
				bg.P = 100000
				bg.D = 500
				bg.Parent = root
			end

			-- Posição do Alvo (Mira exata no torso/chão dele)
			local targetPos = targetRoot.Position
			local myPos = root.Position
			local diff = targetPos - myPos
			local dist = diff.Magnitude

			-- Modo Agressivo: Direção em velocidade cega (800 studs/s)
			local attackSpeed = 800
			local dir = (dist > 0.1) and diff.Unit or root.CFrame.LookVector

			-- Se estiver muito perto ou passando por dentro, força o veículo na exata posição e projeta a física
			if dist < 8 then
				-- Atravessa e arremessa
				bv.Velocity = dir * attackSpeed + Vector3.new(math.random(-50, 50), math.random(-20, 50), math.random(-50, 50))
				root.CFrame = CFrame.new(targetPos) * CFrame.Angles(math.rad(math.random(-180, 180)), math.rad(math.random(-180, 180)), 0)
			else
				-- Avanço direto sem curvas/flutuação na cabeça
				bv.Velocity = dir * attackSpeed
				bg.CFrame = CFrame.new(myPos, targetPos)
			end

			-- Zera forças angulares de torção física
			root.AssemblyAngularVelocity = Vector3.new(math.random(-500, 500), math.random(-500, 500), math.random(-500, 500))
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
						if GH.ShowToast then
							GH.ShowToast(string.format(GH.T("toast_vehicletroll_start") or "Atropelando %s!", name), GH.Theme.Red, 2)
						end
					else
						if GH.ShowToast then GH.ShowToast("Entre em um veículo primeiro!", GH.Theme.Red, 2) end
					end
				end
			end
		end)
		GH.Objects.VehicleTrollPicker = picker
	end

	GH.RegisterToggleButton("VehicleTroll", "toggle_vehicletroll", Cheats_ToggleVehicleTroll, "Troll", "desc_vehicletroll")
end