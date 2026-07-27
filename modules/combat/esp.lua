-- =============================================================================
-- COMMAND: ESP
-- BoxHandleAdornment (box 3D) + BillboardGui + Highlight
-- Estilo: Team (verde) / Enemy (vermelho) / Neutral (amarelo)
-- Features: Barra de vida + Distancia
-- =============================================================================
return function(GH)
	local Players = GH.Services.Players
	local RunService = GH.Services.RunService
	local LocalPlayer = GH.LocalPlayer

	-- Cores configuraveis
	_G.FriendColor = Color3.fromRGB(0, 0, 255)
	_G.EnemyColor = Color3.fromRGB(255, 0, 0)
	_G.UseTeamColor = true

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

	local function GetESPColor(player)
		if _G.UseTeamColor and player.TeamColor then
			return player.TeamColor.Color
		end
		return (GetPlayerRelation(player) == "Ally") and _G.FriendColor or _G.EnemyColor
	end

	local espFolder = nil
	local espData = {}
	local charAddedConns = {}

	-- === Templates ===
	local BoxTemplate = Instance.new("BoxHandleAdornment")
	BoxTemplate.Name = "ESP_Box"
	BoxTemplate.Size = Vector3.new(1, 2, 1)
	BoxTemplate.Color3 = Color3.new(100 / 255, 100 / 255, 100 / 255)
	BoxTemplate.Transparency = 0.7
	BoxTemplate.ZIndex = 0
	BoxTemplate.AlwaysOnTop = true
	BoxTemplate.Visible = false

	local function removerESP()
		-- Restaurar nome padrao do Roblox
		for _, jogador in ipairs(Players:GetPlayers()) do
			pcall(function()
				if jogador ~= LocalPlayer and jogador.Character then
					local hum = jogador.Character:FindFirstChildOfClass("Humanoid")
					if hum then
						hum.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.Viewer
					end
				end
			end)
		end

		-- Restaurar Billboards escondidos
		for _, jogador in ipairs(Players:GetPlayers()) do
			pcall(function()
				if jogador ~= LocalPlayer and jogador.Character then
					for _, obj in ipairs(jogador.Character:GetDescendants()) do
						if obj:IsA("BillboardGui") and not obj.Name:find("GH_ESP") then
							obj.Enabled = true
						end
					end
				end
			end)
		end

		-- Desconectar CharacterAdded
		for _, conn in ipairs(charAddedConns) do
			pcall(function() conn:Disconnect() end)
		end
		table.clear(charAddedConns)

		-- Destruir folder
		if espFolder then
			pcall(function() espFolder:Destroy() end)
			espFolder = nil
			GH.Objects.ESP_Folder = nil
		end

		if GH.Objects.ESP_Folder and GH.Objects.ESP_Folder.Parent then
			pcall(function() GH.Objects.ESP_Folder:Destroy() end)
			GH.Objects.ESP_Folder = nil
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

		local hum = char:FindFirstChildOfClass("Humanoid")
		if not hum then return end

		if hum.Health <= 0 then return end

		-- Pular jogadores dentro de veiculos
		local hrp = char:FindFirstChild("HumanoidRootPart")
		if hrp then
			local parent = hrp.Parent
			while parent do
				if parent:IsA("VehicleSeat") or parent:IsA("Seat") then
					return
				end
				parent = parent.Parent
			end
		end

		-- Esconder nome padrao
		hum.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
		for _, obj in ipairs(char:GetDescendants()) do
			if obj:IsA("BillboardGui") and not obj.Name:find("GH_ESP") then
				pcall(function() obj.Enabled = false end)
			end
		end

		local relation = GetPlayerRelation(jogador)
		if not relation then return end
		local colors = ESPColors[relation]
		local espColor = GetESPColor(jogador)

		-- === BOX HANDLE ADORNMENT (Box 3D) ===
		local box = BoxTemplate:Clone()
		box.Name = "GH_ESP_Box_" .. jogador.Name
		box.Color3 = espColor
		box.Adornee = char
		box.AlwaysOnTop = true
		box.Visible = true
		box.Parent = espFolder

		-- === HIGHLIGHT (Outline) ===
		local hl = Instance.new("Highlight")
		hl.Name = "GH_ESP_HL"
		hl.FillColor = espColor
		hl.FillTransparency = 1
		hl.OutlineColor = espColor
		hl.OutlineTransparency = 0
		hl.Adornee = char
		hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
		hl.Parent = espFolder

		-- === BILLBOARDGUI ===
		local bg = Instance.new("BillboardGui")
		bg.Name = "GH_ESP_" .. jogador.Name
		bg.Adornee = head
		bg.Size = UDim2.new(0, 200, 0, 70)
		bg.StudsOffset = Vector3.new(0, 3.5, 0)
		bg.AlwaysOnTop = true
		bg.Parent = espFolder

		-- Tag
		local tagLabel = Instance.new("TextLabel")
		tagLabel.Name = "GH_ESP_Tag"
		tagLabel.Size = UDim2.new(1, 0, 0, 16)
		tagLabel.Position = UDim2.new(0, 0, 0, 0)
		tagLabel.BackgroundTransparency = 1
		tagLabel.Text = colors.Tag
		tagLabel.TextColor3 = espColor
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

		-- Barra de vida
		local hpBarBg = Instance.new("Frame")
		hpBarBg.Name = "GH_ESP_HpBarBg"
		hpBarBg.Size = UDim2.new(0.5, 0, 0, 5)
		hpBarBg.Position = UDim2.new(0.25, 0, 0, 44)
		hpBarBg.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
		hpBarBg.BackgroundTransparency = 0.2
		hpBarBg.BorderSizePixel = 1
		hpBarBg.BorderColor3 = Color3.fromRGB(80, 80, 80)
		hpBarBg.Parent = bg
		Instance.new("UICorner", hpBarBg).CornerRadius = UDim.new(1, 0)

		local hpBarFill = Instance.new("Frame")
		hpBarFill.Name = "GH_ESP_HpBarFill"
		hpBarFill.Size = UDim2.new(1, 0, 1, 0)
		hpBarFill.BackgroundColor3 = espColor
		hpBarFill.BorderSizePixel = 0
		hpBarFill.Parent = hpBarBg
		Instance.new("UICorner", hpBarFill).CornerRadius = UDim.new(1, 0)

		-- Texto HP
		local hpText = Instance.new("TextLabel")
		hpText.Name = "GH_ESP_HpText"
		hpText.Size = UDim2.new(0.5, 0, 0, 10)
		hpText.Position = UDim2.new(0.25, 0, 0, 49)
		hpText.BackgroundTransparency = 1
		hpText.Text = "100/100"
		hpText.TextColor3 = Color3.fromRGB(255, 255, 255)
		hpText.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
		hpText.TextStrokeTransparency = 0.1
		hpText.Font = Enum.Font.GothamBold
		hpText.TextSize = 8
		hpText.TextXAlignment = Enum.TextXAlignment.Center
		hpText.Parent = bg

		espData[jogador] = {gui = bg, hl = hl, box = box}
	end

	function Cheats_ToggleESP(state, btn)
		removerESP()

		if state then
			espFolder = Instance.new("Folder")
			espFolder.Name = "GH_ESP_Folder"
			GH.Objects.ESP_Folder = espFolder
			local ok = pcall(function() espFolder.Parent = GH.TargetGui end)
			if not ok then
				espFolder.Parent = LocalPlayer:WaitForChild("PlayerGui")
			end

			for _, jogador in ipairs(Players:GetPlayers()) do
				criarESP(jogador)
			end

			charAddedConns = {}

			GH.Connections.ESP_Added = Players.PlayerAdded:Connect(function(jogador)
				local conn = jogador.CharacterAdded:Connect(function()
					if GH.States.ESP then
						pcall(function()
							local hum = jogador.Character and jogador.Character:FindFirstChildOfClass("Humanoid")
							if hum then hum.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None end
						end)
						task.wait(0.5)
						criarESP(jogador)
					end
				end)
				table.insert(charAddedConns, conn)
			end)

			GH.Connections.ESP_Removing = Players.PlayerRemoving:Connect(function(jogador)
				espData[jogador] = nil
			end)

			for _, jogador in ipairs(Players:GetPlayers()) do
				if jogador ~= LocalPlayer then
					local conn = jogador.CharacterAdded:Connect(function()
						if GH.States.ESP then
							pcall(function()
								local hum = jogador.Character and jogador.Character:FindFirstChildOfClass("Humanoid")
								if hum then hum.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None end
							end)
							task.wait(0.5)
							criarESP(jogador)
						end
					end)
					table.insert(charAddedConns, conn)
				end
			end

			-- Loop de atualizacao
			GH.Connections.ESP_Render = RunService.RenderStepped:Connect(function()
				if not GH.States.ESP or GH.isClosing then return end

				if not espFolder or not espFolder.Parent then
					removerESP()
					return
				end

				local meuChar = LocalPlayer.Character
				local minhaHrp = meuChar and meuChar:FindFirstChild("HumanoidRootPart")
				if not minhaHrp then return end
				local myPos = minhaHrp.Position

				for jogador, data in pairs(espData) do
					pcall(function()
						local bg = data.gui
						local hl = data.hl
						local box = data.box
						if not (bg and bg.Parent) then return end

						-- Aplicar configs
						local tagLabel = bg:FindFirstChild("GH_ESP_Tag")
						local nameLabel = bg:FindFirstChild("GH_ESP_Name")
						local hpBarBg = bg:FindFirstChild("GH_ESP_HpBarBg")
						local distLabel = bg:FindFirstChild("GH_ESP_Dist")

						if tagLabel then tagLabel.Visible = GH.Settings.ESPShowTag end
						if nameLabel then nameLabel.Visible = GH.Settings.ESPShowName end
						if hpBarBg then hpBarBg.Visible = GH.Settings.ESPShowHealth end
						if distLabel then distLabel.Visible = GH.Settings.ESPShowDistance end
						local hpText = bg:FindFirstChild("GH_ESP_HpText")
						if hpText then hpText.Visible = GH.Settings.ESPShowHealth end

						-- Verificar se player existe
						if not (jogador and jogador.Parent and jogador.Character) then
							bg.Enabled = false
							if hl then hl.Enabled = false end
							if box then box.Visible = false end
							return
						end

						local char = jogador.Character
						local head = char:FindFirstChild("Head") or char:FindFirstChild("HumanoidRootPart")
						local hum = char:FindFirstChildOfClass("Humanoid")
						if not (head and hum) then
							bg.Enabled = false
							if hl then hl.Enabled = false end
							if box then box.Visible = false end
							return
						end

						-- Distancia
						local dist = (myPos - head.Position).Magnitude

						if dist > GH.Settings.ESPMaxDistance then
							bg.Enabled = false
							if hl then hl.Enabled = false end
							if box then box.Visible = false end
							return
						end

						bg.Enabled = true
						if hl then hl.Enabled = true end
						if box then box.Visible = true end

						-- Cores e dados
						local relation = GetPlayerRelation(jogador)
						if not relation then return end
						local espColor = GetESPColor(jogador)

						if tagLabel then
							tagLabel.Text = ESPColors[relation].Tag
							tagLabel.TextColor3 = espColor
						end

						if hl then
							hl.OutlineColor = espColor
						end

						if box then
							box.Color3 = espColor
						end

						if nameLabel then
							nameLabel.Text = jogador.Name
						end

						dist = math.floor(dist)
						local hp = math.floor(hum.Health)
						local maxHp = math.floor(hum.MaxHealth)
						local ratio = maxHp > 0 and math.clamp(hp / maxHp, 0, 1) or 0

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
							local hpText2 = hpBarBg:FindFirstChild("GH_ESP_HpText")
							if hpText2 then
								hpText2.Text = hp .. "/" .. maxHp
							end
						end

						if distLabel then
							distLabel.Text = dist .. "M"
						end
					end)
				end
			end)
		end
	end

	GH.RegisterToggleButton("ESP", "toggle_esp", Cheats_ToggleESP, "Combat", "desc_esp")
end
