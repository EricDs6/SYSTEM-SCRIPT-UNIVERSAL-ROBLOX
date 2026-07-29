-- =============================================================================
-- COMMAND: BRING (Metodo Seat - funciona no FE)
-- Metodo: cria um Seat perto do alvo, faz ele sentar, e move o Seat ate voce
-- Network Ownership do Seat e transferido para voce quando o alvo senta
-- =============================================================================
return function(GH)
	local Players = GH.Services.Players
	local RunService = GH.Services.RunService
	local LocalPlayer = GH.LocalPlayer

	local bringActive = false
	local bringTarget = nil
	local bringConn = nil
	local bringDied = nil
	local bringSeat = nil

	local BRING_SPEED = 200
	local ARRIVAL_DIST = 8

	local function cleanupBring()
		bringActive = false
		bringTarget = nil
		if bringConn then bringConn:Disconnect() bringConn = nil end
		if bringDied then bringDied:Disconnect() bringDied = nil end
		if bringSeat and bringSeat.Parent then
			-- Se o alvo ainda esta sentado, desenterrar
			local targetChar = bringTarget and bringTarget.Character
			if targetChar then
				local targetHum = targetChar:FindFirstChildOfClass("Humanoid")
				if targetHum and targetHum.Sit then
					targetHum.Sit = false
				end
			end
			bringSeat:Destroy()
			bringSeat = nil
		end
	end

	local function createSeat(targetChar)
		-- Criar Seat fisico
		local seat = Instance.new("Seat")
		seat.Name = "GH_BringSeat"
		seat.Size = Vector3.new(4, 1, 4)
		seat.Material = Enum.Material.ForceField
		seat.BrickColor = BrickColor.new("Bright blue")
		seat.Transparency = 0.5
		seat.Anchored = false
		seat.CanCollide = false
		seat.Massless = true

		-- Posicionar no alvo
		local targetRoot = targetChar:FindFirstChild("HumanoidRootPart")
		if targetRoot then
			seat.CFrame = targetRoot.CFrame * CFrame.new(0, -3, 0)
		end

		seat.Parent = workspace
		return seat
	end

	local function startBring(targetPlayer, targetName)
		cleanupBring()
		bringActive = true
		bringTarget = targetPlayer

		local targetChar = targetPlayer.Character
		if not targetChar then
			GH.ShowToast("Alvo nao encontrado!", GH.Theme.Red, 2)
			cleanupBring()
			return
		end

		-- Criar Seat perto do alvo
		bringSeat = createSeat(targetChar)

		-- Forcar o alvo a sentar no Seat
		local targetHum = targetChar:FindFirstChildOfClass("Humanoid")
		if targetHum then
			bringSeat:Sit(targetHum)
		end

		bringConn = RunService.Heartbeat:Connect(function()
			if not bringActive or not GH.States.Bring then
				cleanupBring()
				return
			end

			local myChar = LocalPlayer.Character
			local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
			local myHum = myChar and myChar:FindFirstChildOfClass("Humanoid")
			if not myRoot or not myHum or myHum.Health <= 0 then
				cleanupBring()
				return
			end

			-- Verificar se o alvo ainda existe e esta sentado
			local targetChar = bringTarget and bringTarget.Character
			local targetRoot = targetChar and targetChar:FindFirstChild("HumanoidRootPart")
			local targetHum = targetChar and targetChar:FindFirstChildOfClass("Humanoid")
			if not targetRoot or not targetHum or targetHum.Health <= 0 then
				GH.ShowToast("Alvo morto!", GH.Theme.Red, 2)
				cleanupBring()
				return
			end

			-- Verificar se o Seat ainda existe
			if not bringSeat or not bringSeat.Parent then
				GH.ShowToast("Seat destruido!", GH.Theme.Red, 2)
				cleanupBring()
				return
			end

			-- Se o alvo saiu do Seat, sentar de novo
			if not targetHum.Sit then
				bringSeat:Sit(targetHum)
			end

			-- Mover o Seat ate voce
			local seatPos = bringSeat.Position
			local myPos = myRoot.Position
			local diff = myPos - seatPos
			local dist = diff.Magnitude

			if dist > ARRIVAL_DIST then
				-- Mover Seat ate perto de voce
				local dir = diff.Unit
				local speed = math.min(BRING_SPEED, dist * 3 + 80)

				-- Usar BodyVelocity para movimento suave
				local bv = bringSeat:FindFirstChild("GH_BringBV")
				if not bv then
					bv = Instance.new("BodyVelocity")
					bv.Name = "GH_BringBV"
					bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
					bv.Velocity = Vector3.zero
					bv.Parent = bringSeat
				end
				bv.Velocity = dir * speed + Vector3.new(0, 20, 0)

				-- BodyGyro para orientacao
				local bg = bringSeat:FindFirstChild("GH_BringBG")
				if not bg then
					bg = Instance.new("BodyGyro")
					bg.Name = "GH_BringBG"
					bg.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
					bg.P = 8000
					bg.D = 500
					bg.CFrame = bringSeat.CFrame
					bg.Parent = bringSeat
				end

				-- Olhar na direcao do alvo
				local lookDir = Vector3.new(dir.X, 0, dir.Z)
				if lookDir.Magnitude > 0.01 then
					bg.CFrame = CFrame.new(seatPos) * CFrame.lookAt(Vector3.zero, lookDir.Unit)
				end
			else
				-- Chegou perto - parar e desenterrar o alvo
				local bv = bringSeat:FindFirstChild("GH_BringBV")
				if bv then bv:Destroy() end
				local bg = bringSeat:FindFirstChild("GH_BringBG")
				if bg then bg:Destroy() end

				-- Desenterrar o alvo
				targetHum.Sit = false

				-- Destruir o Seat
				bringSeat:Destroy()
				bringSeat = nil

				-- Toast de sucesso
				GH.ShowToast(string.format(GH.T("toast_bring_to") or "Puxando %s!", targetName), GH.Theme.On, 2)

				-- Parar o bring
				bringActive = false
				if bringConn then bringConn:Disconnect() bringConn = nil end
			end
		end)
	end

	function Cheats_ToggleBring(state, btn)
		if not state then
			cleanupBring()
			if GH.Objects.BringPicker then
				GH.Objects.BringPicker.Close()
				GH.Objects.BringPicker = nil
			end
			return
		end

		local picker = GH.ShowPlayerPicker(GH.T("dropdown_bring_title"), function(name)
			local player = Players:FindFirstChild(name)
			if player and player.Character then
				local targetRoot = player.Character:FindFirstChild("HumanoidRootPart")
				local myChar = LocalPlayer.Character
				local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
				if targetRoot and myRoot then
					startBring(player, name)
				end
			end
		end)
		GH.Objects.BringPicker = picker
	end

	GH.RegisterToggleButton("Bring", "toggle_bring", Cheats_ToggleBring, "Troll", "desc_bring")
end
