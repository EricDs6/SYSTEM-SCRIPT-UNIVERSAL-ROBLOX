-- =============================================================================
-- COMMAND: ESP
-- Mostra nomes, vida e distancia dos jogadores atraves de paredes
-- Arquitetura: Folder no TargetGui + RenderStepped direto
-- Visual: Highlight + BillboardGui com tag, nome, barra de vida, info
-- =============================================================================
return function(GH)
	local Players = GH.Services.Players
	local RunService = GH.Services.RunService
	local LocalPlayer = GH.LocalPlayer

	local ESPColors = {
		Enemy = {
			HighlightFill = Color3.fromRGB(255, 30, 30),
			HighlightOutline = Color3.fromRGB(255, 80, 80),
			Text = Color3.fromRGB(255, 60, 60),
			Tag = GH.T("esp_enemy"),
		},
		Ally = {
			HighlightFill = Color3.fromRGB(30, 200, 30),
			HighlightOutline = Color3.fromRGB(80, 255, 80),
			Text = Color3.fromRGB(60, 255, 60),
			Tag = GH.T("esp_ally"),
		},
		Neutral = {
			HighlightFill = Color3.fromRGB(255, 200, 30),
			HighlightOutline = Color3.fromRGB(255, 230, 100),
			Text = Color3.fromRGB(255, 220, 50),
			Tag = GH.T("esp_neutral"),
		},
	}

	local function GetPlayerRelation(player)
		if player == LocalPlayer then return nil end
		if LocalPlayer.Team and player.Team then
			if player.Team == LocalPlayer.Team then return "Ally"
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

		-- Highlight
		local hl = Instance.new("Highlight")
		hl.Name = "GH_ESP_HL"
		hl.FillColor = colors.HighlightFill
		hl.FillTransparency = 0.55
		hl.OutlineColor = colors.HighlightOutline
		hl.OutlineTransparency = 0
		hl.Adornee = char
		hl.Parent = espFolder

		-- BillboardGui
		local bg = Instance.new("BillboardGui")
		bg.Name = "GH_ESP_" .. jogador.Name
		bg.Adornee = head
		bg.Size = UDim2.new(0, 200, 0, 46)
		bg.StudsOffset = Vector3.new(0, 3, 0)
		bg.AlwaysOnTop = true
		bg.Parent = espFolder

		-- Tag ([INIMIGO], [ALIADO], [JOGADOR])
		local tagLabel = Instance.new("TextLabel")
		tagLabel.Name = "GH_ESP_Tag"
		tagLabel.Size = UDim2.new(1, 0, 0, 14)
		tagLabel.Position = UDim2.new(0, 0, 0, 0)
		tagLabel.BackgroundTransparency = 1
		tagLabel.Text = colors.Tag
		tagLabel.TextColor3 = colors.Text
		tagLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
		tagLabel.TextStrokeTransparency = 0.3
		tagLabel.Font = Enum.Font.GothamBlack
		tagLabel.TextSize = 13
		tagLabel.TextXAlignment = Enum.TextXAlignment.Center
		tagLabel.Parent = bg

		-- Nome
		local nameLabel = Instance.new("TextLabel")
		nameLabel.Name = "GH_ESP_Name"
		nameLabel.Size = UDim2.new(1, 0, 0, 13)
		nameLabel.Position = UDim2.new(0, 0, 0, 14)
		nameLabel.BackgroundTransparency = 1
		nameLabel.Text = jogador.Name
		nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
		nameLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
		nameLabel.TextStrokeTransparency = 0.3
		nameLabel.Font = Enum.Font.GothamBold
		nameLabel.TextSize = 11
		nameLabel.TextXAlignment = Enum.TextXAlignment.Center
		nameLabel.Parent = bg

		-- Barra de vida (fundo)
		local hpBg = Instance.new("Frame")
		hpBg.Name = "GH_ESP_HpBg"
		hpBg.Size = UDim2.new(0.6, 0, 0, 3)
		hpBg.Position = UDim2.new(0.2, 0, 0, 28)
		hpBg.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
		hpBg.BorderSizePixel = 0
		hpBg.Parent = bg
		Instance.new("UICorner", hpBg).CornerRadius = UDim.new(0, 2)

		-- Barra de vida (preenchimento)
		local hpFill = Instance.new("Frame")
		hpFill.Name = "GH_ESP_HpFill"
		hpFill.Size = UDim2.new(1, 0, 1, 0)
		hpFill.BackgroundColor3 = colors.Text
		hpFill.BorderSizePixel = 0
		hpFill.Parent = hpBg
		Instance.new("UICorner", hpFill).CornerRadius = UDim.new(0, 2)

		-- Info (vida + distancia)
		local infoLabel = Instance.new("TextLabel")
		infoLabel.Name = "GH_ESP_Info"
		infoLabel.Size = UDim2.new(1, 0, 0, 12)
		infoLabel.Position = UDim2.new(0, 0, 0, 32)
		infoLabel.BackgroundTransparency = 1
		infoLabel.Text = ""
		infoLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
		infoLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
		infoLabel.TextStrokeTransparency = 0.3
		infoLabel.Font = Enum.Font.GothamMedium
		infoLabel.TextSize = 10
		infoLabel.TextXAlignment = Enum.TextXAlignment.Center
		infoLabel.Parent = bg

		espData[jogador] = {gui = bg, hl = hl}
	end

	function Cheats_ToggleESP(state, btn)
		removerESP()

		if state then
			-- Pasta no TargetGui
			espFolder = Instance.new("Folder")
			espFolder.Name = "GH_ESP_Folder"
			local ok = pcall(function() espFolder.Parent = GH.TargetGui end)
			if not ok then
				espFolder.Parent = LocalPlayer:WaitForChild("PlayerGui")
			end

			-- Criar ESP para quem ja esta no servidor
			for _, jogador in ipairs(Players:GetPlayers()) do
				criarESP(jogador)
			end

			-- Novos players
			GH.Connections.ESP_Added = Players.PlayerAdded:Connect(function(jogador)
				jogador.CharacterAdded:Connect(function()
					if GH.States.ESP then
						task.wait(0.5)
						criarESP(jogador)
					end
				end)
			end)

			-- Players que saem
			GH.Connections.ESP_Removing = Players.PlayerRemoving:Connect(function(jogador)
				espData[jogador] = nil
			end)

			-- Recriar ESP no respawn
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

			-- Loop de atualizacao (vida, distancia, cores)
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
						if tagLabel.Text ~= colors.Tag then
							tagLabel.Text = colors.Tag
							tagLabel.TextColor3 = colors.Text
						end
					end

					-- Nome
					local nameLabel = bg:FindFirstChild("GH_ESP_Name")
					if nameLabel then nameLabel.Visible = GH.Settings.ESPShowName end

					-- Vida
					dist = math.floor(dist)
					local hp = math.floor(hum.Health)
					local maxHp = math.floor(hum.MaxHealth)
					local ratio = maxHp > 0 and math.clamp(hp / maxHp, 0, 1) or 0

					local hpBg = bg:FindFirstChild("GH_ESP_HpBg")
					if hpBg then
						hpBg.Visible = GH.Settings.ESPShowHealth
						local hpFill = hpBg:FindFirstChild("GH_ESP_HpFill")
						if hpFill then
							hpFill.Size = UDim2.new(ratio, 0, 1, 0)
							if ratio >= 0.6 then hpFill.BackgroundColor3 = Color3.fromRGB(0, 220, 80)
							elseif ratio >= 0.3 then hpFill.BackgroundColor3 = Color3.fromRGB(255, 180, 0)
							else hpFill.BackgroundColor3 = Color3.fromRGB(255, 50, 50) end
						end
					end

					-- Info
					local infoLabel = bg:FindFirstChild("GH_ESP_Info")
					if infoLabel then
						local showInfo = GH.Settings.ESPShowHealth or GH.Settings.ESPShowDistance
						infoLabel.Visible = showInfo
						if showInfo then
							if GH.Settings.ESPShowHealth and GH.Settings.ESPShowDistance then
								infoLabel.Text = hp .. "/" .. maxHp .. "  |  " .. dist .. "m"
							elseif GH.Settings.ESPShowHealth then
								infoLabel.Text = hp .. "/" .. maxHp
							else
								infoLabel.Text = dist .. "m"
							end
							if ratio >= 0.6 then infoLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
							elseif ratio >= 0.3 then infoLabel.TextColor3 = Color3.fromRGB(255, 200, 80)
							else infoLabel.TextColor3 = Color3.fromRGB(255, 80, 80) end
						end
					end
				end
			end)
		end

		GH.ShowToast(state and ("ESP " .. GH.T("toast_activated")) or ("ESP " .. GH.T("toast_deactivated")), state and GH.Theme.On or GH.Theme.Off, 2)
	end

	GH.RegisterToggleButton("ESP", "toggle_esp", Cheats_ToggleESP, "Combat", "desc_esp")
end
