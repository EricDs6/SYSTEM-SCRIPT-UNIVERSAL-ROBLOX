-- =============================================================================
-- COMMAND: ESP
-- Box outline + Tag + Nome + Distancia + Barra de vida horizontal
-- Estilo: Team (verde) / Enemy (vermelho) / Neutral (amarelo)
-- =============================================================================
return function(GH)
	local Players = GH.Services.Players
	local RunService = GH.Services.RunService
	local LocalPlayer = GH.LocalPlayer

	local ESPColors = {
		Enemy = {
			Main = Color3.fromRGB(255, 40, 40),
			Dark = Color3.fromRGB(180, 20, 20),
			Tag = "Enemy",
		},
		Ally = {
			Main = Color3.fromRGB(40, 255, 40),
			Dark = Color3.fromRGB(20, 160, 20),
			Tag = "Team",
		},
		Neutral = {
			Main = Color3.fromRGB(255, 200, 40),
			Dark = Color3.fromRGB(180, 140, 20),
			Tag = "Player",
		},
	}

	local function GetPlayerRelation(player)
		if player == LocalPlayer then return nil end
		if LocalPlayer.Team and player.Team then
			if LocalPlayer.Team == player.Team then return "Ally"
			else return "Enemy" end
		end
		return "Neutral"
	end

	local espFolder = nil
	local espData = {}

	local function removerESP()
		-- Restaurar nome padrao do Roblox
		for jogador, _ in pairs(espData) do
			pcall(function()
				if jogador and jogador.Character then
					local hum = jogador.Character:FindFirstChildOfClass("Humanoid")
					if hum then
						hum.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.Viewer
					end
				end
			end)
		end

		if espFolder then
			pcall(function() espFolder:Destroy() end)
			espFolder = nil
		end
		GH.Disconnect("ESP_Render")
		GH.Disconnect("ESP_Added")
		GH.Disconnect("ESP_Removing")
		espData = {}
	end

	local function criarESP(jogador)
		if jogador == LocalPlayer then return end
		if not espFolder then return end

		local char = jogador.Character
		if not char then return end
		local head = char:FindFirstChild("Head")
		if not head then return end

		-- Esconder nome padrao do Roblox (remover BillboardGuis que nao sao do ESP)
		local hum = char:FindFirstChildOfClass("Humanoid")
		if hum then
			hum.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
		end
		for _, obj in ipairs(char:GetDescendants()) do
			if obj:IsA("BillboardGui") and not obj.Name:find("GH_ESP") then
				pcall(function() obj.Enabled = false end)
			end
			if obj:IsA("TextLabel") and not obj.Name:find("GH_ESP") then
				if obj.Text == jogador.Name or obj.Text == jogador.DisplayName then
					pcall(function() obj.Visible = false end)
				end
			end
		end
		-- Also check for SurfaceGui name tags
		for _, obj in ipairs(head:GetChildren()) do
			if obj:IsA("BillboardGui") and not obj.Name:find("GH_ESP") then
				pcall(function() obj:Destroy() end)
			end
		end

		local relation = GetPlayerRelation(jogador)
		if not relation then return end
		local colors = ESPColors[relation]

		-- === HIGHLIGHT (box outline) ===
		local hl = Instance.new("Highlight")
		hl.Name = "GH_ESP_HL"
		hl.FillColor = colors.Main
		hl.FillTransparency = 1
		hl.OutlineColor = colors.Main
		hl.OutlineTransparency = 0
		hl.Adornee = char
		hl.Parent = espFolder

		-- === BILLBOARDGUI ===
		local bg = Instance.new("BillboardGui")
		bg.Name = "GH_ESP_" .. jogador.Name
		bg.Adornee = head
		bg.Size = UDim2.new(0, 180, 0, 70)
		bg.StudsOffset = Vector3.new(0, 3.5, 0)
		bg.AlwaysOnTop = true
		bg.Parent = espFolder

		-- Tag (TEAM / ENEMY / PLAYER)
		local tagLabel = Instance.new("TextLabel")
		tagLabel.Name = "GH_ESP_Tag"
		tagLabel.Size = UDim2.new(1, 0, 0, 16)
		tagLabel.Position = UDim2.new(0, 0, 0, 0)
		tagLabel.BackgroundTransparency = 1
		tagLabel.Text = colors.Tag
		tagLabel.TextColor3 = colors.Main
		tagLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
		tagLabel.TextStrokeTransparency = 0.1
		tagLabel.Font = Enum.Font.GothamBlack
		tagLabel.TextSize = 15
		tagLabel.TextXAlignment = Enum.TextXAlignment.Center
		tagLabel.Parent = bg

		-- Nome
		local nameLabel = Instance.new("TextLabel")
		nameLabel.Name = "GH_ESP_Name"
		nameLabel.Size = UDim2.new(1, 0, 0, 13)
		nameLabel.Position = UDim2.new(0, 0, 0, 16)
		nameLabel.BackgroundTransparency = 1
		nameLabel.Text = jogador.Name
		nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
		nameLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
		nameLabel.TextStrokeTransparency = 0.2
		nameLabel.Font = Enum.Font.GothamBold
		nameLabel.TextSize = 11
		nameLabel.TextXAlignment = Enum.TextXAlignment.Center
		nameLabel.Parent = bg

		-- Distancia
		local distLabel = Instance.new("TextLabel")
		distLabel.Name = "GH_ESP_Dist"
		distLabel.Size = UDim2.new(1, 0, 0, 12)
		distLabel.Position = UDim2.new(0, 0, 0, 30)
		distLabel.BackgroundTransparency = 1
		distLabel.Text = "0M"
		distLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
		distLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
		distLabel.TextStrokeTransparency = 0.3
		distLabel.Font = Enum.Font.GothamMedium
		distLabel.TextSize = 10
		distLabel.TextXAlignment = Enum.TextXAlignment.Center
		distLabel.Parent = bg

		-- === BARRA DE VIDA HORIZONTAL (fundo escuro) ===
		local hpBarBg = Instance.new("Frame")
		hpBarBg.Name = "GH_ESP_HpBarBg"
		hpBarBg.Size = UDim2.new(0.7, 0, 0, 8)
		hpBarBg.Position = UDim2.new(0.15, 0, 0, 44)
		hpBarBg.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
		hpBarBg.BackgroundTransparency = 0.2
		hpBarBg.BorderSizePixel = 1
		hpBarBg.BorderColor3 = Color3.fromRGB(80, 80, 80)
		hpBarBg.Parent = bg
		Instance.new("UICorner", hpBarBg).CornerRadius = UDim.new(0, 3)

		-- === PREENCHIMENTO (cresce da esquerda pra direita) ===
		local hpBarFill = Instance.new("Frame")
		hpBarFill.Name = "GH_ESP_HpBarFill"
		hpBarFill.Size = UDim2.new(1, 0, 1, 0)
		hpBarFill.Position = UDim2.new(0, 0, 0, 0)
		hpBarFill.BackgroundColor3 = colors.Main
		hpBarFill.BorderSizePixel = 0
		hpBarFill.Parent = hpBarBg
		Instance.new("UICorner", hpBarFill).CornerRadius = UDim.new(0, 3)

		-- Texto da vida dentro da barra
		local hpText = Instance.new("TextLabel")
		hpText.Name = "GH_ESP_HpText"
		hpText.Size = UDim2.new(1, 0, 1, 0)
		hpText.Position = UDim2.new(0, 0, 0, 0)
		hpText.BackgroundTransparency = 1
		hpText.Text = "100/100"
		hpText.TextColor3 = Color3.fromRGB(255, 255, 255)
		hpText.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
		hpText.TextStrokeTransparency = 0.1
		hpText.Font = Enum.Font.GothamBold
		hpText.TextSize = 8
		hpText.TextXAlignment = Enum.TextXAlignment.Center
		hpText.Parent = hpBarBg

		espData[jogador] = {gui = bg, hl = hl}
	end

	function Cheats_ToggleESP(state, btn)
		removerESP()

		if state then
			espFolder = Instance.new("Folder")
			espFolder.Name = "GH_ESP_Folder"
			local ok = pcall(function() espFolder.Parent = GH.TargetGui end)
			if not ok then
				espFolder.Parent = LocalPlayer:WaitForChild("PlayerGui")
			end

			for _, jogador in ipairs(Players:GetPlayers()) do
				criarESP(jogador)
			end

			GH.Connections.ESP_Added = Players.PlayerAdded:Connect(function(jogador)
				jogador.CharacterAdded:Connect(function()
					if GH.States.ESP then
						-- Esconder nome padrao no respawn
						pcall(function()
							local hum = jogador.Character and jogador.Character:FindFirstChildOfClass("Humanoid")
							if hum then hum.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None end
						end)
						task.wait(0.5)
						criarESP(jogador)
					end
				end)
			end)

			GH.Connections.ESP_Removing = Players.PlayerRemoving:Connect(function(jogador)
				espData[jogador] = nil
			end)

			for _, jogador in ipairs(Players:GetPlayers()) do
				if jogador ~= LocalPlayer then
					jogador.CharacterAdded:Connect(function()
						if GH.States.ESP then
							-- Esconder nome padrao no respawn
							pcall(function()
								local hum = jogador.Character and jogador.Character:FindFirstChildOfClass("Humanoid")
								if hum then hum.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None end
							end)
							task.wait(0.5)
							criarESP(jogador)
						end
					end)
				end
			end

			-- Loop de atualizacao
			GH.Connections.ESP_Render = RunService.RenderStepped:Connect(function()
				if not GH.States.ESP then return end

				local meuChar = LocalPlayer.Character
				local minhaHrp = meuChar and meuChar:FindFirstChild("HumanoidRootPart")
				if not minhaHrp then return end
				local myPos = minhaHrp.Position

				for jogador, data in pairs(espData) do
					pcall(function()
						if not (jogador and jogador.Parent and jogador.Character) then return end

						local char = jogador.Character
						local head = char:FindFirstChild("Head") or char:FindFirstChild("HumanoidRootPart")
						local hum = char:FindFirstChildOfClass("Humanoid")
						local bg = data.gui
						local hl = data.hl
						if not (head and hum and bg and bg.Parent) then return end

						-- Distancia
						local dist = (myPos - head.Position).Magnitude
						local isFar = dist > GH.Settings.ESPMaxDistance

						if isFar then
							bg.Enabled = false
							if hl then hl.Enabled = false end
							return
						end

						bg.Enabled = true
						if hl then hl.Enabled = true end

						-- Aplicar configs PRIMEIRO (antes de qualquer continue)
						local tagLabel = bg:FindFirstChild("GH_ESP_Tag")
						local nameLabel = bg:FindFirstChild("GH_ESP_Name")
						local hpBarBg = bg:FindFirstChild("GH_ESP_HpBarBg")
						local distLabel = bg:FindFirstChild("GH_ESP_Dist")

						if tagLabel then tagLabel.Visible = GH.Settings.ESPShowTag end
						if nameLabel then nameLabel.Visible = GH.Settings.ESPShowName end
						if hpBarBg then hpBarBg.Visible = GH.Settings.ESPShowHealth end
						if distLabel then distLabel.Visible = GH.Settings.ESPShowDistance end

						-- Relation
						local relation = GetPlayerRelation(jogador)
						if not relation then return end
						local colors = ESPColors[relation]

						-- Tag
						if tagLabel then
							tagLabel.Text = colors.Tag
							tagLabel.TextColor3 = colors.Main
						end

						-- Highlight cor
						if hl then
							hl.OutlineColor = colors.Main
						end

						-- Nome
						if nameLabel then nameLabel.Text = jogador.Name end

						-- Vida
						dist = math.floor(dist)
						local hp = math.floor(hum.Health)
						local maxHp = math.floor(hum.MaxHealth)
						local ratio = maxHp > 0 and math.clamp(hp / maxHp, 0, 1) or 0

						-- Barra de vida
						if hpBarBg then
							local hpBarFill = hpBarBg:FindFirstChild("GH_ESP_HpBarFill")
							if hpBarFill then
								hpBarFill.Size = UDim2.new(ratio, 0, 1, 0)
								if ratio >= 0.6 then
									hpBarFill.BackgroundColor3 = Color3.fromRGB(0, 220, 80)
								elseif ratio >= 0.3 then
									hpBarFill.BackgroundColor3 = Color3.fromRGB(255, 180, 0)
								else
									hpBarFill.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
								end
							end
							local hpText = hpBarBg:FindFirstChild("GH_ESP_HpText")
							if hpText then
								hpText.Text = hp .. "/" .. maxHp
							end
						end

						-- Distancia
						if distLabel then
							distLabel.Text = dist .. "M"
						end
					end)
				end
			end)
		end

		GH.ShowToast(state and ("ESP " .. GH.T("toast_activated")) or ("ESP " .. GH.T("toast_deactivated")), state and GH.Theme.On or GH.Theme.Off, 2)
	end

	GH.RegisterToggleButton("ESP", "toggle_esp", Cheats_ToggleESP, "Combat", "desc_esp")
end
