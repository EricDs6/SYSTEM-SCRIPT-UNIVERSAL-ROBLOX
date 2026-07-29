-- =============================================================================
-- COMMAND: BRING
-- Puxa um jogador ate voce usando colisao fisica direcional (funciona no FE)
-- Metodo: voa ATRAS do alvo e colide com ele usando SUA velocidade
-- Voce so controla o SEU personagem (Network Ownership) - o servidor processa a colisao
-- =============================================================================
return function(GH)
	local Players = GH.Services.Players
	local RunService = GH.Services.RunService
	local LocalPlayer = GH.LocalPlayer

	local bringActive = false
	local bringTarget = nil
	local bringConn = nil
	local bringDied = nil

	local FLY_SPEED = 250
	local BEHIND_DIST = 5  -- distancia "atras" do alvo para empurrar

	local function cleanupBring()
		bringActive = false
		bringTarget = nil
		if bringConn then bringConn:Disconnect() bringConn = nil end
		if bringDied then bringDied:Disconnect() bringDied = nil end

		local char = LocalPlayer.Character
		if char then
			local hrp = char:FindFirstChild("HumanoidRootPart")
			local hum = char:FindFirstChildOfClass("Humanoid")
			if hrp then
				hrp:SetAttribute("BringSetup", nil)
				hrp.AssemblyAngularVelocity = Vector3.zero
				hrp.AssemblyLinearVelocity = Vector3.zero
			end
			if hum then hum.AutoRotate = true end
			-- Restaurar fisica normal
			for _, child in pairs(char:GetDescendants()) do
				if child:IsA("BasePart") then
					child.CustomPhysicalProperties = PhysicalProperties.new(0.7, 0.3, 0.5)
					child.Massless = false
					child.CanCollide = true
				end
			end
		end
	end

	local function startBring(targetPlayer, targetName)
		cleanupBring()
		bringActive = true
		bringTarget = targetPlayer

		bringConn = RunService.Heartbeat:Connect(function()
			if not bringActive or not GH.States.Bring then
				cleanupBring()
				return
			end

			local myChar = LocalPlayer.Character
			local myHum = myChar and myChar:FindFirstChildOfClass("Humanoid")
			local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
			if not myRoot or not myHum or myHum.Health <= 0 then
				cleanupBring()
				return
			end

			local targetChar = bringTarget and bringTarget.Character
			local targetRoot = targetChar and targetChar:FindFirstChild("HumanoidRootPart")
			local targetHum = targetChar and targetChar:FindFirstChildOfClass("Humanoid")
			if not targetRoot or not targetHum or targetHum.Health <= 0 then
				GH.ShowToast("Alvo morto!", GH.Theme.Red, 2)
				cleanupBring()
				return
			end

			-- Setup fisica: massa alta + CanCollide = true para colisao eficiente
			if not myRoot:GetAttribute("BringSetup") then
				for _, child in pairs(myChar:GetDescendants()) do
					if child:IsA("BasePart") then
						child.CustomPhysicalProperties = PhysicalProperties.new(80, 0.3, 0.5)
						child.Massless = false
						child.CanCollide = true  -- COLISAO ativa para empurrar
					end
				end
				myRoot:SetAttribute("BringSetup", true)
				myHum.AutoRotate = false

				bringDied = myHum.Died:Connect(function()
					if bringActive then cleanupBring() end
				end)
			end

			-- Distancia ao alvo
			local diff = targetRoot.Position - myRoot.Position
			local dist = diff.Magnitude
			local dir = diff.Unit

			-- Posicao "atras" do alvo (onde eu quero ficar para empurra-lo pra tras)
			-- "Atras" = mesma direcao que ele olha pra mim, mas do outro lado
			local behindPos = targetRoot.Position + dir * BEHIND_DIST + Vector3.new(0, 3, 0)
			local toBehind = behindPos - myRoot.Position
			local distBehind = toBehind.Magnitude

			if dist > BEHIND_DIST + 5 then
				-- LONGE: Voar rapido ate ficar atras do alvo
				local speed = math.min(FLY_SPEED, dist * 2 + 100)
				myRoot.AssemblyLinearVelocity = toBehind.Unit * speed + Vector3.new(0, 20, 0)

			elseif distBehind > 2 then
				-- PERTO MAS NAO ATRAS: Posicionar rapidamente atras
				myRoot.AssemblyLinearVelocity = toBehind.Unit * FLY_SPEED * 0.8 + Vector3.new(0, 15, 0)

			else
				-- ATRAS DO ALVO: Voar RAPIDO NA DIRECAO DELE (colisao continua!)
				-- Isso e o que empurra - SUA velocidade colidindo com ele
				local pushTarget = targetRoot.Position
				local toTarget = pushTarget - myRoot.Position

				-- Voar com forca maxima ENTRANDO no alvo
				-- A colisao fisica entre SEU personagem (que voce controla) e o dele empurra ele
				myRoot.AssemblyLinearVelocity = toTarget.Unit * FLY_SPEED + Vector3.new(0, 25, 0)

				-- Manter massa alta e colisao ativa
				myRoot.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
			end

			-- Olhar na direcao do alvo
			local flatDir = Vector3.new(dir.X, 0, dir.Z)
			if flatDir.Magnitude > 0.01 then
				myRoot.CFrame = myRoot.CFrame:Lerp(
					CFrame.new(myRoot.Position) * CFrame.lookAt(Vector3.zero, flatDir.Unit),
					0.2
				)
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
					GH.ShowToast(string.format(GH.T("toast_bring_to") or "Puxando %s!", name), GH.Theme.On, 2)
				end
			end
		end)
		GH.Objects.BringPicker = picker
	end

	GH.RegisterToggleButton("Bring", "toggle_bring", Cheats_ToggleBring, "Troll", "desc_bring")
end
