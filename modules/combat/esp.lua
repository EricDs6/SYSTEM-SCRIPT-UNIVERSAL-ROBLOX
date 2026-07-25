-- =============================================================================
-- COMMAND: ESP
-- Mostra nomes, vida e distancia dos jogadores atraves de paredes
-- =============================================================================
return function(GH)
	local Players = GH.Services.Players
	local LocalPlayer = GH.LocalPlayer

	local ESPColors = {
		Enemy = {
			HighlightFill = Color3.fromRGB(255, 30, 30),
			HighlightOutline = Color3.fromRGB(255, 80, 80),
			Text = Color3.fromRGB(255, 60, 60),
			Tag = GH.T("esp_enemy"),
			TextColor = Color3.fromRGB(255, 255, 255),
		},
		Ally = {
			HighlightFill = Color3.fromRGB(30, 200, 30),
			HighlightOutline = Color3.fromRGB(80, 255, 80),
			Text = Color3.fromRGB(60, 255, 60),
			Tag = GH.T("esp_ally"),
			TextColor = Color3.fromRGB(255, 255, 255),
		},
		Neutral = {
			HighlightFill = Color3.fromRGB(255, 200, 30),
			HighlightOutline = Color3.fromRGB(255, 230, 100),
			Text = Color3.fromRGB(255, 220, 50),
			Tag = GH.T("esp_neutral"),
			TextColor = Color3.fromRGB(255, 255, 255),
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

	local function removeESP(char)
		if not char then return end
		for _, obj in ipairs(char:GetChildren()) do
			if obj.Name:sub(1, 6) == "GH_ESP" then
				pcall(function() obj:Destroy() end)
			end
		end
	end

	local function createESP(player)
		if not player.Character then return end
		local char = player.Character
		removeESP(char)

		local relation = GetPlayerRelation(player)
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
		hl.Parent = char

		-- BillboardGui
		local bg = Instance.new("BillboardGui")
		bg.Name = "GH_ESP_Text"
		bg.Size = UDim2.new(0, 200, 0, 46)
		bg.StudsOffset = Vector3.new(0, 3, 0)
		bg.AlwaysOnTop = true
		bg.Parent = char

		-- Tag
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
		nameLabel.Text = player.Name
		nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
		nameLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
		nameLabel.TextStrokeTransparency = 0.3
		nameLabel.Font = Enum.Font.GothamBold
		nameLabel.TextSize = 11
		nameLabel.TextXAlignment = Enum.TextXAlignment.Center
		nameLabel.Parent = bg

		-- Barra de vida
		local hpBg = Instance.new("Frame")
		hpBg.Name = "GH_ESP_HpBg"
		hpBg.Size = UDim2.new(0.6, 0, 0, 3)
		hpBg.Position = UDim2.new(0.2, 0, 0, 28)
		hpBg.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
		hpBg.BorderSizePixel = 0
		hpBg.Parent = bg
		Instance.new("UICorner", hpBg).CornerRadius = UDim.new(0, 2)

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
	end

	function Cheats_ToggleESP(state, btn)
		GH.UnregisterMasterLoop("ESP")
		GH.Disconnect("ESP_Added")
		GH.Disconnect("ESP_Removing")
		GH.Disconnect("ESP_TeamChanged")

		-- Limpar conexoes de time
		for name, _ in pairs(GH.Connections) do
			if name:sub(1, 10) == "ESP_Team_" then
				GH.Disconnect(name)
			end
		end

		-- Desconectar CharacterAdded connections
		for player, conn in pairs(GH.Cache.ESPPlayers) do
			if typeof(conn) == "RBXScriptConnection" then
				pcall(function() conn:Disconnect() end)
			end
		end

		-- Limpar ESP de todos os players
		for _, p in ipairs(Players:GetPlayers()) do
			if p ~= LocalPlayer and p.Character then
				removeESP(p.Character)
			end
		end
		table.clear(GH.Cache.ESPPlayers)

		if state then
			-- Setup de um player
			local function setupPlayer(player)
				if player == LocalPlayer then return end
				GH.Cache.ESPPlayers[player] = true

				if player.Character then createESP(player) end
				GH.Cache.ESPPlayers[player] = player.CharacterAdded:Connect(function(char)
					task.wait(0.5)
					if GH.States.ESP then createESP(player) end
				end)
			end

			for _, p in ipairs(Players:GetPlayers()) do setupPlayer(p) end
			GH.Connections.ESP_Added = Players.PlayerAdded:Connect(setupPlayer)
			GH.Connections.ESP_Removing = Players.PlayerRemoving:Connect(function(p)
				if GH.Cache.ESPPlayers[p] then
					if typeof(GH.Cache.ESPPlayers[p]) == "RBXScriptConnection" then
						pcall(function() GH.Cache.ESPPlayers[p]:Disconnect() end)
					end
					GH.Cache.ESPPlayers[p] = nil
				end
				if p.Character then removeESP(p.Character) end
			end)

			-- Team change:existing players
			for _, p in ipairs(Players:GetPlayers()) do
				if p ~= LocalPlayer then
					local conn = p:GetPropertyChangedSignal("Team"):Connect(function()
						if GH.States.ESP and p.Character then
							removeESP(p.Character)
							createESP(p)
						end
					end)
					GH.Connections["ESP_Team_" .. p.Name] = conn
				end
			end
			-- Team change: new players
			GH.Connections.ESP_TeamChanged = Players.PlayerAdded:Connect(function(player)
				local conn = player:GetPropertyChangedSignal("Team"):Connect(function()
					if GH.States.ESP and player.Character then
						removeESP(player.Character)
						createESP(player)
					end
				end)
				GH.Connections["ESP_Team_" .. player.Name] = conn
			end)

			-- Master loop: atualizar vida e distancia
			GH.RegisterMasterLoop("ESP", "Heartbeat", function()
				if GH.isClosing or not GH.States.ESP then
					GH.UnregisterMasterLoop("ESP")
					return
				end

				local myHrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
				if not myHrp then return end
				local myPos = myHrp.Position

				for player, _ in pairs(GH.Cache.ESPPlayers) do
					if not (player and player.Parent and player.Character) then continue end

					local char = player.Character
					local head = char:FindFirstChild("Head") or char:FindFirstChild("HumanoidRootPart")
					local hum = char:FindFirstChildOfClass("Humanoid")
					local bg = char:FindFirstChild("GH_ESP_Text")
					local hl = char:FindFirstChild("GH_ESP_HL")
					if not (head and hum and bg) then continue end

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
					local relation = GetPlayerRelation(player)
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

					-- Info (vida + distancia)
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
	end

	GH.RegisterToggleButton("ESP", "toggle_esp", Cheats_ToggleESP, "Combat", "desc_esp")
end
