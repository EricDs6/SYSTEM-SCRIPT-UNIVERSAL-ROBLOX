-- =============================================================================
-- COMMAND: BRING (Metodo Tool - funciona no FE)
-- Metodo: equipa uma Tool, voa SEU personagem ate o alvo em alta velocidade
-- A Tool fica na sua mao via Grip - a colisao entre Handle e alvo empurra ele
-- Voce tem Network Ownership da sua Tool = servidor aceita a colisao
-- =============================================================================
return function(GH)
	local Players = GH.Services.Players
	local RunService = GH.Services.RunService
	local LocalPlayer = GH.LocalPlayer

	local bringActive = false
	local bringTarget = nil
	local bringConn = nil
	local bringDied = nil
	local bringTool = nil

	local FLY_SPEED = 220
	local HANDLE_SIZE = Vector3.new(3, 2, 2)

	local function cleanupBring()
		bringActive = false
		bringTarget = nil
		if bringConn then bringConn:Disconnect() bringConn = nil end
		if bringDied then bringDied:Disconnect() bringDied = nil end

		-- Remover Tool
		if bringTool then
			bringTool:Destroy()
			bringTool = nil
		end

		-- Restaurar personagem
		local char = LocalPlayer.Character
		if char then
			local hrp = char:FindFirstChild("HumanoidRootPart")
			local hum = char:FindFirstChildOfClass("Humanoid")
			if hrp then
				hrp:SetAttribute("BringSetup", nil)
				hrp.AssemblyLinearVelocity = Vector3.zero
				hrp.AssemblyAngularVelocity = Vector3.zero
			end
			if hum then hum.AutoRotate = true end
		end
	end

	local function createBringTool()
		-- Criar Tool simples
		local tool = Instance.new("Tool")
		tool.Name = "GH_BringTool"
		tool.RequiresHandle = true
		tool.CanBeDropped = false
		tool.ToolTip = "Bring"

		-- Handle grande para colisao eficiente
		local handle = Instance.new("Part")
		handle.Name = "Handle"
		handle.Size = HANDLE_SIZE
		handle.Material = Enum.Material.Neon
		handle.BrickColor = BrickColor.new("Bright blue")
		handle.Transparency = 0.3
		handle.Anchored = false
		handle.CanCollide = true
		handle.Massless = false  -- Massa real para colisao ter efeito
		handle.Parent = tool

		-- Grip: Handle na frente do personagem (mais area de colisao)
		tool.GripPos = Vector3.new(0, 0, -3)
		tool.GripForward = Vector3.new(0, 0, -1)
		tool.GripRight = Vector3.new(1, 0, 0)
		tool.GripUp = Vector3.new(0, 1, 0)

		return tool
	end

	local function startBring(targetPlayer, targetName)
		cleanupBring()
		bringActive = true
		bringTarget = targetPlayer

		-- Criar Tool
		bringTool = createBringTool()

		-- Colocar no Backpack primeiro
		local backpack = LocalPlayer:FindFirstChild("Backpack")
		if backpack then
			bringTool.Parent = backpack
		end

		-- Equipar a Tool
		local char = LocalPlayer.Character
		local hum = char and char:FindFirstChildOfClass("Humanoid")
		if hum then
			hum:EquipTool(bringTool)
		end

		-- Setup fisica do personagem (massa alta para colisao ser eficiente)
		if char then
			for _, child in pairs(char:GetDescendants()) do
				if child:IsA("BasePart") then
					child.CustomPhysicalProperties = PhysicalProperties.new(30, 0.3, 0.5)
				end
			end
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

			-- Verificar se a Tool ainda existe
			if not bringTool or not bringTool.Parent then
				-- Re-criar e re-equipar
				bringTool = createBringTool()
				local bp = LocalPlayer:FindFirstChild("Backpack")
				if bp then bringTool.Parent = bp end
				if myHum then myHum:EquipTool(bringTool) end
			end

			-- Verificar se o alvo ainda existe
			local targetChar = bringTarget and bringTarget.Character
			local targetRoot = targetChar and targetChar:FindFirstChild("HumanoidRootPart")
			local targetHum = targetChar and targetChar:FindFirstChildOfClass("Humanoid")
			if not targetRoot or not targetHum or targetHum.Health <= 0 then
				GH.ShowToast("Alvo morto!", GH.Theme.Red, 2)
				cleanupBring()
				return
			end

			-- Distancia ao alvo
			local diff = targetRoot.Position - myRoot.Position
			local dist = diff.Magnitude
			local dir = diff.Unit

			-- VOAR MEU PERSONAGEM em alta velocidade na direcao do alvo
			-- A Handle fica na minha mao via Grip
			-- A colisao entre Handle e alvo empurra ele
			local speed = math.min(FLY_SPEED, dist * 2 + 100)
			myRoot.AssemblyLinearVelocity = dir * speed + Vector3.new(0, 20, 0)
			myRoot.AssemblyAngularVelocity = Vector3.zero

			-- AutoRotate desativado para manter direcao
			myHum.AutoRotate = false

			-- Olhar na direcao do alvo
			local flatDir = Vector3.new(dir.X, 0, dir.Z)
			if flatDir.Magnitude > 0.01 then
				myRoot.CFrame = myRoot.CFrame:Lerp(
					CFrame.new(myRoot.Position) * CFrame.lookAt(Vector3.zero, flatDir.Unit),
					0.2
				)
			end

			-- Detectar morte
			if not bringDied and myHum then
				bringDied = myHum.Died:Connect(function()
					if bringActive then cleanupBring() end
				end)
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
