-- =============================================================================
-- COMMAND: ESP
-- Box outline + Tag acima + Distancia abaixo + Barra de vida lateral
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
	local espData = {} -- [player] = {gui, hl}

	local function removerESP()
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

		local relation = GetPlayerRelation(jogador)
		if not relation then return end
		local colors = ESPColors[relation]

		-- === HIGHLIGHT (box outline no character) ===
		local hl = Instance.new("Highlight")
		hl.Name = "GH_ESP_HL"
		hl.FillColor = colors.Main
		hl.FillTransparency = 1 -- Sem preenchimento, so a borda
		hl.OutlineColor = colors.Main
		hl.OutlineTransparency = 0
		hl.Adornee = char
		hl.Parent = espFolder

		-- === BILLBOARDGUI (textos flutuando) ===
		local bg = Instance.new("BillboardGui")
		bg.Name = "GH_ESP_" .. jogador.Name
		bg.Adornee = head
		bg.Size = UDim2.new(0, 160, 0, 80)
		bg.StudsOffset = Vector3.new(0, 3.5, 0)
		bg.AlwaysOnTop = true
		bg.Parent = espFolder

		-- === BARRA DE VIDA VERTICAL (lado esquerdo, DENTRO do BillboardGui) ===
		local hpBarBg = Instance.new("Frame")
		hpBarBg.Name = "GH_ESP_HpBarBg"
		hpBarBg.Size = UDim2.new(0, 6, 0, 52)
		hpBarBg.Position = UDim2.new(0, 4, 0.5, 0)
		hpBarBg.AnchorPoint = Vector2.new(0, 0.5)
		hpBarBg.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
		hpBarBg.BackgroundTransparency = 0.2
		hpBarBg.BorderSizePixel = 1
		hpBarBg.BorderColor3 = Color3.fromRGB(60, 60, 60)
		hpBarBg.Parent = bg
		Instance.new("UICorner", hpBarBg).CornerRadius = UDim.new(0, 2)

		-- Preenchimento (cresce de baixo pra cima)
		local hpBarFill = Instance.new("Frame")
		hpBarFill.Name = "GH_ESP_HpBarFill"
		hpBarFill.Size = UDim2.new(1, 0, 1, 0)
		hpBarFill.Position = UDim2.new(0, 0, 1, 0)
		hpBarFill.AnchorPoint = Vector2.new(0, 1)
		hpBarFill.BackgroundColor3 = colors.Main
		hpBarFill.BorderSizePixel = 0
		hpBarFill.Parent = hpBarBg
		Instance.new("UICorner", hpBarFill).CornerRadius = UDim.new(0, 2)

		-- Tag (TEAM / ENEMY / PLAYER)
		local tagLabel = Instance.new("TextLabel")
		tagLabel.Name = "GH_ESP_Tag"
		tagLabel.Size = UDim2.new(1, -14, 0, 16)
		tagLabel.Position = UDim2.new(0, 14, 0, 0)
		tagLabel.BackgroundTransparency = 1
		tagLabel.Text = colors.Tag
		tagLabel.TextColor3 = colors.Main
		tagLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
		tagLabel.TextStrokeTransparency = 0.2
		tagLabel.Font = Enum.Font.GothamBlack
		tagLabel.TextSize = 14
		tagLabel.TextXAlignment = Enum.TextXAlignment.Center
		tagLabel.Parent = bg

		-- Nome
		local nameLabel = Instance.new("TextLabel")
		nameLabel.Name = "GH_ESP_Name"
		nameLabel.Size = UDim2.new(1, -14, 0, 13)
		nameLabel.Position = UDim2.new(0, 14, 0, 16)
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
		distLabel.Size = UDim2.new(1, -14, 0, 12)
		distLabel.Position = UDim2.new(0, 14, 0, 30)
		distLabel.BackgroundTransparency = 1
		distLabel.Text = "0M"
		distLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
		distLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
		distLabel.TextStrokeTransparency = 0.3
		distLabel.Font = Enum.Font.GothamMedium
		distLabel.TextSize = 10
		distLabel.TextXAlignment = Enum.TextXAlignment.Center
		distLabel.Parent = bg

		-- Vida (numero)
		local hpLabel = Instance.new("TextLabel")
		hpLabel.Name = "GH_ESP_HpText"
		hpLabel.Size = UDim2.new(1, -14, 0, 12)
		hpLabel.Position = UDim2.new(0, 14, 0, 42)
		hpLabel.BackgroundTransparency = 1
		hpLabel.Text = "100/100"
		hpLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
		hpLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
		hpLabel.TextStrokeTransparency = 0.3
		hpLabel.Font = Enum.Font.GothamBold
		hpLabel.TextSize = 10
		hpLabel.TextXAlignment = Enum.TextXAlignment.Center
		hpLabel.Parent = bg

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
					if not (jogador and jogador.Parent and jogador.Character) then continue end

					local char = jogador.Character
					local head = char:FindFirstChild("Head") or char:FindFirstChild("HumanoidRootPart")
					local hum = char:FindFirstChildOfClass("Humanoid")
					local bg = data.gui
					local hl = data.hl
					if not (head and hum and bg and bg.Parent) then continue end

					-- Distancia
					local dist = (myPos - head.Position).Magnitude
					local isFar = dist > GH.Settings.ESPMaxDistance

					if isFar then
						bg.Enabled = false
						if hl then hl.Enabled = false end
						continue
					else
						bg.Enabled = true
						if hl then hl.Enabled = true end
					end

					-- Relation
					local relation = GetPlayerRelation(jogador)
					if not relation then continue end
					local colors = ESPColors[relation]

					-- Tag
					local tagLabel = bg:FindFirstChild("GH_ESP_Tag")
					if tagLabel then
						tagLabel.Visible = GH.Settings.ESPShowTag
						tagLabel.Text = colors.Tag
						tagLabel.TextColor3 = colors.Main
					end

					-- Highlight cor
					if hl then
						hl.OutlineColor = colors.Main
					end

					-- Nome
					local nameLabel = bg:FindFirstChild("GH_ESP_Name")
					if nameLabel then nameLabel.Visible = GH.Settings.ESPShowName end

					-- Vida
					dist = math.floor(dist)
					local hp = math.floor(hum.Health)
					local maxHp = math.floor(hum.MaxHealth)
					local ratio = maxHp > 0 and math.clamp(hp / maxHp, 0, 1) or 0

					-- Barra de vida vertical
					local hpBarBg = bg:FindFirstChild("GH_ESP_HpBarBg")
					if hpBarBg then
						hpBarBg.Visible = GH.Settings.ESPShowHealth
						local hpBarFill = hpBarBg:FindFirstChild("GH_ESP_HpBarFill")
						if hpBarFill then
							hpBarFill.Size = UDim2.new(1, 0, ratio, 0)
							-- Cor da barra baseada na vida
							if ratio >= 0.6 then
								hpBarFill.BackgroundColor3 = Color3.fromRGB(0, 220, 80)
							elseif ratio >= 0.3 then
								hpBarFill.BackgroundColor3 = Color3.fromRGB(255, 180, 0)
							else
								hpBarFill.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
							end
						end
					end

					-- Texto da vida
					local hpLabel = bg:FindFirstChild("GH_ESP_HpText")
					if hpLabel then
						hpLabel.Visible = GH.Settings.ESPShowHealth
						hpLabel.Text = hp .. "/" .. maxHp
					end

					-- Distancia
					local distLabel = bg:FindFirstChild("GH_ESP_Dist")
					if distLabel then
						distLabel.Visible = GH.Settings.ESPShowDistance
						distLabel.Text = dist .. "M"
					end
				end
			end)
		end

		GH.ShowToast(state and ("ESP " .. GH.T("toast_activated")) or ("ESP " .. GH.T("toast_deactivated")), state and GH.Theme.On or GH.Theme.Off, 2)
	end

	GH.RegisterToggleButton("ESP", "toggle_esp", Cheats_ToggleESP, "Combat", "desc_esp")
end
