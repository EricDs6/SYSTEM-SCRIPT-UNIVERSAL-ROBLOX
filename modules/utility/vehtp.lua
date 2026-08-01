-- =============================================================================
-- COMMAND: VEHTP (Vehicle Teleport)
-- Lista players em veiculos, teleporta instantaneamente e salva posicoes
-- =============================================================================
return function(GH)
	local Players = GH.Services.Players
	local RunService = GH.Services.RunService
	local UserInputService = GH.Services.UserInputService
	local TweenService = GH.Services.TweenService
	local LocalPlayer = GH.LocalPlayer

	local CacheVehTp = { SavedPoints = {}, GUI = nil }
	local isOpen = false

-- ==========================================
-- SCAN: Encontra todos os players do servidor
-- ==========================================
local function scanAllPlayers()
	local result = {}
	for _, player in ipairs(Players:GetPlayers()) do
		if player ~= LocalPlayer and player.Character then
			local hum = player.Character:FindFirstChildOfClass("Humanoid")
			local rootPart = player.Character:FindFirstChild("HumanoidRootPart")
			if hum and rootPart then
				local inVehicle = false
				local vehicleName = nil
				if hum.SeatPart and (hum.SeatPart:IsA("VehicleSeat") or hum.SeatPart:IsA("Seat")) then
					inVehicle = true
					local vehicleModel = hum.SeatPart:FindFirstAncestorOfClass("Model")
					vehicleName = vehicleModel and vehicleModel.Name or nil
				end
							-- Time
				local pTeam = player.Team
				local pTeamColor = player.TeamColor
				table.insert(result, {
					player = player,
					name = player.DisplayName,
					userName = player.Name,
					seat = hum.SeatPart,
					inVehicle = inVehicle,
					vehicleName = vehicleName,
					position = rootPart.Position,
					team = pTeam,
					teamColor = pTeamColor,
				})
			end
		end
	end
	return result
end

	-- ==========================================
	-- LIMPAR FORCAS FISICAS DO VEICULO
	-- ==========================================
	local function clearVehiclePhysics(vehicleModel)
		-- Remove todos BodyVelocity, BodyGyro e BodyMover do veiculo
		for _, obj in ipairs(vehicleModel:GetDescendants()) do
			if obj:IsA("BodyVelocity") or obj:IsA("BodyGyro") or obj:IsA("BodyAngularVelocity") or obj:IsA("BodyForce") or obj:IsA("BodyThrust") or obj:IsA("BodyPosition") or obj:IsA("LinearVelocity") or obj:IsA("AngularVelocity") then
				pcall(function() obj:Destroy() end)
			end
		end

		-- Zera velocidade de todas as partes do veiculo
		for _, part in ipairs(vehicleModel:GetDescendants()) do
			if part:IsA("BasePart") then
				part.AssemblyLinearVelocity = Vector3.zero
				part.AssemblyAngularVelocity = Vector3.zero
			end
		end

		-- Tambem zera no seat especificamente
		local seat = vehicleModel:FindFirstChildWhichIsA("VehicleSeat") or vehicleModel:FindFirstChildWhichIsA("Seat")
		if seat then
			seat.AssemblyLinearVelocity = Vector3.zero
			seat.AssemblyAngularVelocity = Vector3.zero
			-- Reseta controle do VehicleSeat
			if seat:IsA("VehicleSeat") then
				seat.Throttle = 0
				seat.Steer = 0
			end
		end
	end

	-- ==========================================
	-- TELEPORT INSTANTANEO (sem tween)
	-- ==========================================
	local function instantTeleportTo(targetCFrame)
		local myChar = LocalPlayer.Character
		if not myChar then return false end

		-- Se estiver em veiculo, teleporta o veiculo inteiro
		local hum = myChar:FindFirstChildOfClass("Humanoid")
		if hum and hum.SeatPart then
			local vehicleModel = hum.SeatPart:FindFirstAncestorOfClass("Model")
			if vehicleModel then
				-- 1. Limpa TODAS as forcas fisicas antes de teleportar
				clearVehiclePhysics(vehicleModel)

				-- 2. Anchora o veiculo inteiro para evitar luta com o physics engine
				local anchoredStates = {}
				for _, part in ipairs(vehicleModel:GetDescendants()) do
					if part:IsA("BasePart") then
						anchoredStates[part] = part.Anchored
						part.Anchored = true
					end
				end

				-- 3. Teleporta o veiculo inteiro
				pcall(function()
					local pivot = vehicleModel:GetPivot()
					local offset = pivot:ToObjectSpace(hum.SeatPart.CFrame)
					local newPivot = targetCFrame * offset:Inverse()
					vehicleModel:PivotTo(newPivot)
				end)

				-- 4. Espera 1 frame, desancora e limpa novamente
				task.wait()
				pcall(function()
					for part, wasAnchored in pairs(anchoredStates) do
						if part and part.Parent then
							part.Anchored = wasAnchored
						end
					end
					clearVehiclePhysics(vehicleModel)
				end)

				return true
			end
		end

		-- Fallback: teleportar o player
		local root = myChar:FindFirstChild("HumanoidRootPart")
		if root then
			root.AssemblyLinearVelocity = Vector3.zero
			root.AssemblyAngularVelocity = Vector3.zero
			root.CFrame = targetCFrame
			return true
		end
		return false
	end

-- ==========================================
-- REFRESH LISTA (todos os players)
-- ==========================================
local function RefreshVehList(scroll, searchText)
	for _, child in ipairs(scroll:GetChildren()) do
		if child:IsA("Frame") then child:Destroy() end
	end

	local playersData = scanAllPlayers()
	local filtered = {}
	for _, p in ipairs(playersData) do
		if searchText == "" or p.name:lower():find(searchText:lower(), 1, true) or p.userName:lower():find(searchText:lower(), 1, true) then
			table.insert(filtered, p)
		end
	end

	if #filtered == 0 then
		local empty = Instance.new("TextLabel")
		empty.Size = UDim2.new(1, 0, 0, 36)
		empty.BackgroundTransparency = 1
		empty.Text = GH.T("toast_vehtp_no_players")
		empty.TextColor3 = Color3.fromRGB(140, 140, 155)
		empty.Font = Enum.Font.GothamMedium
		empty.TextSize = 11
		empty.Parent = scroll
		return
	end

	for i, pData in ipairs(filtered) do
		local item = Instance.new("Frame")
		item.Size = UDim2.new(1, 0, 0, 40)
		item.BackgroundColor3 = Color3.fromRGB(28, 28, 32)
		item.BorderSizePixel = 0
		item.LayoutOrder = i
		item.Parent = scroll
		Instance.new("UICorner", item).CornerRadius = UDim.new(0, 5)

		-- Detecção de time (igual ao picker)
		local myTeam = LocalPlayer.Team
		local pTeam = pData.team
		local pTeamColor = pData.teamColor
		local myTeamColor = myTeam and myTeam.TeamColor or LocalPlayer.TeamColor
		local hasTeams = (myTeam ~= nil) or (myTeamColor and myTeamColor ~= BrickColor.new("Medium stone grey"))
		local tag = ""
		local nameColor = Color3.fromRGB(235, 235, 240)
		if hasTeams then
			if pTeam and myTeam and pTeam == myTeam then
				tag = "[ALIADO] "
				nameColor = pTeam.TeamColor.Color
			elseif pTeam and myTeam and pTeam ~= myTeam then
				tag = "[INIMIGO] "
				nameColor = pTeam.TeamColor.Color
			elseif pTeamColor and myTeamColor and pTeamColor == myTeamColor then
				tag = "[ALIADO] "
				nameColor = pTeamColor.Color
			elseif pTeamColor and myTeamColor and pTeamColor ~= myTeamColor then
				tag = "[INIMIGO] "
				nameColor = pTeamColor.Color
			else
				tag = "[NEUTRO] "
				nameColor = Color3.fromRGB(180, 180, 190)
			end
		end

		-- Tag do time
		if tag ~= "" then
			local tagLabel = Instance.new("TextLabel")
			tagLabel.Size = UDim2.new(0, 55, 0, 14)
			tagLabel.Position = UDim2.new(0, 6, 0, 4)
			tagLabel.BackgroundTransparency = 1
			tagLabel.Text = tag
			tagLabel.TextColor3 = nameColor
			tagLabel.Font = Enum.Font.GothamBold
			tagLabel.TextSize = 9
			tagLabel.TextXAlignment = Enum.TextXAlignment.Left
			tagLabel.Parent = item
		end

		-- Nome do player
		local nameLabel = Instance.new("TextLabel")
		nameLabel.Size = UDim2.new(0.55, 0, 0, 14)
		nameLabel.Position = UDim2.new(0, (tag ~= "" and 62 or 32), 0, 4)
		nameLabel.BackgroundTransparency = 1
		nameLabel.Text = pData.name
		nameLabel.TextColor3 = nameColor
		nameLabel.Font = Enum.Font.GothamBold
		nameLabel.TextSize = 11
		nameLabel.TextXAlignment = Enum.TextXAlignment.Left
		nameLabel.TextTruncate = Enum.TextTruncate.AtEnd
		nameLabel.Parent = item

		-- @username + status do veiculo
		local subLabel = Instance.new("TextLabel")
		subLabel.Size = UDim2.new(0.55, 0, 0, 11)
		subLabel.Position = UDim2.new(0, (tag ~= "" and 62 or 32), 0, 20)
		subLabel.BackgroundTransparency = 1
		if pData.inVehicle and pData.vehicleName then
			subLabel.Text = "@" .. pData.userName .. " | " .. pData.vehicleName
		else
			subLabel.Text = "@" .. pData.userName .. " | Sem veiculo"
		end
		subLabel.TextColor3 = Color3.fromRGB(120, 120, 135)
		subLabel.Font = Enum.Font.RobotoMono
		subLabel.TextSize = 8
		subLabel.TextXAlignment = Enum.TextXAlignment.Left
		subLabel.TextTruncate = Enum.TextTruncate.AtEnd
		subLabel.Parent = item

		-- Botao TP Instantaneo
		local tpBtn = Instance.new("TextButton")
		tpBtn.Size = UDim2.new(0, 34, 0, 22)
		tpBtn.Position = UDim2.new(1, -42, 0.5, -11)
		tpBtn.BackgroundColor3 = Color3.fromRGB(0, 140, 80)
		tpBtn.Text = "TP"
		tpBtn.TextColor3 = Color3.new(1, 1, 1)
		tpBtn.Font = Enum.Font.GothamBold
		tpBtn.TextSize = 9
		tpBtn.AutoButtonColor = false
		tpBtn.Parent = item
		Instance.new("UICorner", tpBtn).CornerRadius = UDim.new(0, 4)

		tpBtn.MouseEnter:Connect(function()
			TweenService:Create(tpBtn, GH.TI, { BackgroundColor3 = Color3.fromRGB(0, 180, 100) }):Play()
		end)
		tpBtn.MouseLeave:Connect(function()
			TweenService:Create(tpBtn, GH.TI, { BackgroundColor3 = Color3.fromRGB(0, 140, 80) }):Play()
		end)

		tpBtn.MouseButton1Click:Connect(function()
			-- Verifica se o player ainda esta no servidor
			if not pData.player or not pData.player.Parent then
				GH.ShowToast(GH.T("toast_vehtp_player_left"), GH.Theme.Red, 2)
				RefreshVehList(scroll, searchText)
				return
			end
			-- Verifica se o character ainda existe
			local char = pData.player.Character
			if not char then
				GH.ShowToast(GH.T("toast_vehtp_player_left"), GH.Theme.Red, 2)
				RefreshVehList(scroll, searchText)
				return
			end
			local rootPart = char:FindFirstChild("HumanoidRootPart")
			if not rootPart then
				GH.ShowToast(GH.T("toast_vehtp_player_left"), GH.Theme.Red, 2)
				RefreshVehList(scroll, searchText)
				return
			end
			local targetCFrame = rootPart.CFrame * CFrame.new(0, 3, 0)
			local ok = instantTeleportTo(targetCFrame)
			if ok then
				GH.ShowToast(string.format(GH.T("toast_vehtp_tp"), pData.name), GH.Theme.On, 2)
			end
		end)
	end
end

	-- ==========================================
	-- REFRESH SAVED POINTS LIST
	-- ==========================================
	local function RefreshSavedList(scroll)
		for _, child in ipairs(scroll:GetChildren()) do
			if child:IsA("Frame") then child:Destroy() end
		end

		for i, point in ipairs(CacheVehTp.SavedPoints) do
			local item = Instance.new("Frame")
			item.Size = UDim2.new(1, 0, 0, 32)
			item.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
			item.BorderSizePixel = 0
			item.LayoutOrder = i
			item.Parent = scroll
			Instance.new("UICorner", item).CornerRadius = UDim.new(0, 4)

			-- Nome
			local label = Instance.new("TextLabel")
			label.Size = UDim2.new(0.5, 0, 0, 14)
			label.Position = UDim2.new(0, 6, 0, 3)
			label.BackgroundTransparency = 1
			label.Text = point.Name
			label.TextColor3 = Color3.fromRGB(235, 235, 240)
			label.Font = Enum.Font.GothamMedium
			label.TextSize = 10
			label.TextXAlignment = Enum.TextXAlignment.Left
			label.TextTruncate = Enum.TextTruncate.AtEnd
			label.Parent = item

			-- Coordenadas salvas
			local coordLabel = Instance.new("TextLabel")
			coordLabel.Size = UDim2.new(0.5, 0, 0, 11)
			coordLabel.Position = UDim2.new(0, 6, 0, 17)
			coordLabel.BackgroundTransparency = 1
			coordLabel.Text = string.format("X:%d Y:%d Z:%d", math.floor(point.Position.X), math.floor(point.Position.Y), math.floor(point.Position.Z))
			coordLabel.TextColor3 = Color3.fromRGB(100, 100, 115)
			coordLabel.Font = Enum.Font.RobotoMono
			coordLabel.TextSize = 8
			coordLabel.TextXAlignment = Enum.TextXAlignment.Left
			coordLabel.Parent = item

			-- Botao TP
			local tpBtn = Instance.new("TextButton")
			tpBtn.Size = UDim2.new(0, 28, 0, 18)
			tpBtn.Position = UDim2.new(1, -62, 0.5, -9)
			tpBtn.BackgroundColor3 = Color3.fromRGB(0, 99, 177)
			tpBtn.Text = "TP"
			tpBtn.TextColor3 = Color3.new(1, 1, 1)
			tpBtn.Font = Enum.Font.GothamBold
			tpBtn.TextSize = 8
			tpBtn.AutoButtonColor = false
			tpBtn.Parent = item
			Instance.new("UICorner", tpBtn).CornerRadius = UDim.new(0, 3)

			tpBtn.MouseButton1Click:Connect(function()
				local ok = instantTeleportTo(CFrame.new(point.Position + Vector3.new(0, 3, 0)))
				if ok then
					GH.ShowToast(string.format(GH.T("toast_vehtp_tp"), point.Name), GH.Theme.On, 2)
				end
			end)

			-- Botao Deletar
			local delBtn = Instance.new("TextButton")
			delBtn.Size = UDim2.new(0, 22, 0, 18)
			delBtn.Position = UDim2.new(1, -30, 0.5, -9)
			delBtn.BackgroundColor3 = Color3.fromRGB(80, 30, 30)
			delBtn.Text = "X"
			delBtn.TextColor3 = Color3.fromRGB(200, 100, 100)
			delBtn.Font = Enum.Font.GothamBold
			delBtn.TextSize = 9
			delBtn.AutoButtonColor = false
			delBtn.Parent = item
			Instance.new("UICorner", delBtn).CornerRadius = UDim.new(0, 3)

			delBtn.MouseButton1Click:Connect(function()
				table.remove(CacheVehTp.SavedPoints, i)
				RefreshSavedList(scroll)
			end)
		end
	end

	-- ==========================================
	-- GUI PRINCIPAL
	-- ==========================================
	function Cheats_ToggleVehTp(state, btn)
		if not state then
			if CacheVehTp.GUI then
				CacheVehTp.GUI:Destroy()
				CacheVehTp.GUI = nil
			end
			isOpen = false
			return
		end

		if isOpen then return end
		isOpen = true

		if CacheVehTp.GUI then CacheVehTp.GUI:Destroy() end

		local gui = Instance.new("ScreenGui")
		gui.Name = "GH_VehTpGUI"
		gui.ResetOnSpawn = false
		gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
		gui.DisplayOrder = 100
		gui.Parent = GH.TargetGui
		CacheVehTp.GUI = gui

		local frame = Instance.new("Frame")
		frame.Size = UDim2.new(0, 240, 0, 360)
		frame.Position = UDim2.new(0, 10, 0.5, -180)
		frame.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
		frame.BorderSizePixel = 0
		frame.Active = true
		frame.Parent = gui
		Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 8)
		local stroke = Instance.new("UIStroke")
		stroke.Color = Color3.fromRGB(60, 60, 70)
		stroke.Thickness = 1
		stroke.Parent = frame

		-- Title bar
		local titleBar = Instance.new("Frame")
		titleBar.Size = UDim2.new(1, 0, 0, 26)
		titleBar.BackgroundColor3 = Color3.fromRGB(16, 16, 20)
		titleBar.BorderSizePixel = 0
		titleBar.Parent = frame

		local title = Instance.new("TextLabel")
		title.Size = UDim2.new(1, -60, 1, 0)
		title.Position = UDim2.new(0, 8, 0, 0)
		title.BackgroundTransparency = 1
		title.Text = GH.T("input_vehtp_title")
		title.TextColor3 = Color3.fromRGB(0, 120, 212)
		title.Font = Enum.Font.GothamBold
		title.TextSize = 10
		title.TextXAlignment = Enum.TextXAlignment.Left
		title.Parent = titleBar

		-- Close button
		local closeBtn = Instance.new("TextButton")
		closeBtn.Size = UDim2.new(0, 20, 0, 20)
		closeBtn.Position = UDim2.new(1, -24, 0, 3)
		closeBtn.BackgroundColor3 = Color3.fromRGB(28, 28, 32)
		closeBtn.Text = ""
		closeBtn.AutoButtonColor = false
		closeBtn.Parent = titleBar
		Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 4)

		local closeX = Instance.new("TextLabel")
		closeX.Size = UDim2.new(1, 0, 1, 0)
		closeX.BackgroundTransparency = 1
		closeX.Text = "X"
		closeX.TextColor3 = Color3.fromRGB(235, 235, 240)
		closeX.Font = Enum.Font.SourceSans
		closeX.TextSize = 12
		closeX.Parent = closeBtn

		closeBtn.MouseEnter:Connect(function()
			TweenService:Create(closeBtn, GH.TI, { BackgroundColor3 = Color3.fromRGB(255, 60, 60) }):Play()
		end)
		closeBtn.MouseLeave:Connect(function()
			TweenService:Create(closeBtn, GH.TI, { BackgroundColor3 = Color3.fromRGB(28, 28, 32) }):Play()
		end)

		-- Tabs: Players | Salvos
		local tabFrame = Instance.new("Frame")
		tabFrame.Size = UDim2.new(1, -8, 0, 24)
		tabFrame.Position = UDim2.new(0, 4, 0, 28)
		tabFrame.BackgroundTransparency = 1
		tabFrame.Parent = frame

		local tabPlayers = Instance.new("TextButton")
		tabPlayers.Size = UDim2.new(0.5, -2, 1, 0)
		tabPlayers.BackgroundColor3 = Color3.fromRGB(0, 99, 177)
		tabPlayers.Text = GH.T("tab_vehtp_players")
		tabPlayers.TextColor3 = Color3.new(1, 1, 1)
		tabPlayers.Font = Enum.Font.GothamBold
		tabPlayers.TextSize = 9
		tabPlayers.AutoButtonColor = false
		tabPlayers.Parent = tabFrame
		Instance.new("UICorner", tabPlayers).CornerRadius = UDim.new(0, 4)

		local tabSaved = Instance.new("TextButton")
		tabSaved.Size = UDim2.new(0.5, -2, 1, 0)
		tabSaved.Position = UDim2.new(0.5, 2, 0, 0)
		tabSaved.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
		tabSaved.Text = GH.T("tab_vehtp_saved")
		tabSaved.TextColor3 = Color3.fromRGB(180, 180, 190)
		tabSaved.Font = Enum.Font.GothamBold
		tabSaved.TextSize = 9
		tabSaved.AutoButtonColor = false
		tabSaved.Parent = tabFrame
		Instance.new("UICorner", tabSaved).CornerRadius = UDim.new(0, 4)

		-- Search
		local searchBox = Instance.new("TextBox")
		searchBox.Size = UDim2.new(1, -8, 0, 22)
		searchBox.Position = UDim2.new(0, 4, 0, 54)
		searchBox.BackgroundColor3 = Color3.fromRGB(28, 28, 32)
		searchBox.PlaceholderText = GH.T("input_vehtp_placeholder")
		searchBox.PlaceholderColor3 = Color3.fromRGB(90, 90, 105)
		searchBox.Text = ""
		searchBox.TextColor3 = Color3.fromRGB(235, 235, 240)
		searchBox.Font = Enum.Font.GothamMedium
		searchBox.TextSize = 10
		searchBox.TextXAlignment = Enum.TextXAlignment.Left
		searchBox.ClearTextOnFocus = false
		searchBox.ZIndex = 10
		searchBox.Parent = frame
		Instance.new("UICorner", searchBox).CornerRadius = UDim.new(0, 4)
		Instance.new("UIPadding", searchBox).PaddingLeft = UDim.new(0, 6)

		-- Content area
		local contentFrame = Instance.new("Frame")
		contentFrame.Size = UDim2.new(1, -8, 1, -120)
		contentFrame.Position = UDim2.new(0, 4, 0, 78)
		contentFrame.BackgroundTransparency = 1
		contentFrame.ClipsDescendants = true
		contentFrame.Parent = frame

		-- Tab: Players
		local playerScroll = Instance.new("ScrollingFrame")
		playerScroll.Size = UDim2.new(1, 0, 1, 0)
		playerScroll.BackgroundTransparency = 1
		playerScroll.ScrollBarThickness = 2
		playerScroll.ScrollBarImageColor3 = Color3.fromRGB(0, 120, 212)
		playerScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
		playerScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
		playerScroll.BorderSizePixel = 0
		playerScroll.Parent = contentFrame
		Instance.new("UIListLayout", playerScroll).Padding = UDim.new(0, 3)

		-- Tab: Salvos
		local savedScroll = Instance.new("ScrollingFrame")
		savedScroll.Size = UDim2.new(1, 0, 1, 0)
		savedScroll.BackgroundTransparency = 1
		savedScroll.ScrollBarThickness = 2
		savedScroll.ScrollBarImageColor3 = Color3.fromRGB(0, 120, 212)
		savedScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
		savedScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
		savedScroll.BorderSizePixel = 0
		savedScroll.Visible = false
		savedScroll.Parent = contentFrame
		Instance.new("UIListLayout", savedScroll).Padding = UDim.new(0, 3)

		local currentTab = "players"

		local function switchTab(tab)
			currentTab = tab
			if tab == "players" then
				playerScroll.Visible = true
				savedScroll.Visible = false
				searchBox.Visible = true
				TweenService:Create(tabPlayers, GH.TI, { BackgroundColor3 = Color3.fromRGB(0, 99, 177) }):Play()
				tabPlayers.TextColor3 = Color3.new(1, 1, 1)
				TweenService:Create(tabSaved, GH.TI, { BackgroundColor3 = Color3.fromRGB(35, 35, 40) }):Play()
				tabSaved.TextColor3 = Color3.fromRGB(180, 180, 190)
			else
				playerScroll.Visible = false
				savedScroll.Visible = true
				searchBox.Visible = false
				TweenService:Create(tabSaved, GH.TI, { BackgroundColor3 = Color3.fromRGB(0, 99, 177) }):Play()
				tabSaved.TextColor3 = Color3.new(1, 1, 1)
				TweenService:Create(tabPlayers, GH.TI, { BackgroundColor3 = Color3.fromRGB(35, 35, 40) }):Play()
				tabPlayers.TextColor3 = Color3.fromRGB(180, 180, 190)
				RefreshSavedList(savedScroll)
			end
		end

		tabPlayers.MouseButton1Click:Connect(function() switchTab("players") end)
		tabSaved.MouseButton1Click:Connect(function() switchTab("saved") end)

		-- Search filter
		searchBox:GetPropertyChangedSignal("Text"):Connect(function()
			RefreshVehList(playerScroll, searchBox.Text)
		end)

		-- Bottom bar: Salvar Posicao
		local bottomBar = Instance.new("Frame")
		bottomBar.Size = UDim2.new(1, -8, 0, 28)
		bottomBar.Position = UDim2.new(0, 4, 1, -32)
		bottomBar.BackgroundTransparency = 1
		bottomBar.Parent = frame

		local saveBtn = Instance.new("TextButton")
		saveBtn.Size = UDim2.new(1, 0, 1, 0)
		saveBtn.BackgroundColor3 = Color3.fromRGB(0, 99, 177)
		saveBtn.Text = "+ " .. GH.T("coords_save")
		saveBtn.TextColor3 = Color3.new(1, 1, 1)
		saveBtn.Font = Enum.Font.GothamBold
		saveBtn.TextSize = 10
		saveBtn.AutoButtonColor = false
		saveBtn.Parent = bottomBar
		Instance.new("UICorner", saveBtn).CornerRadius = UDim.new(0, 5)

		saveBtn.MouseEnter:Connect(function()
			TweenService:Create(saveBtn, GH.TI, { BackgroundColor3 = Color3.fromRGB(0, 120, 212) }):Play()
		end)
		saveBtn.MouseLeave:Connect(function()
			TweenService:Create(saveBtn, GH.TI, { BackgroundColor3 = Color3.fromRGB(0, 99, 177) }):Play()
		end)

		saveBtn.MouseButton1Click:Connect(function()
			local myChar = LocalPlayer.Character
			if myChar then
				local hum = myChar:FindFirstChildOfClass("Humanoid")
				if hum and hum.SeatPart then
					local pos = hum.SeatPart.Position
					local name = GH.T("coords_point_prefix") .. (#CacheVehTp.SavedPoints + 1)
					table.insert(CacheVehTp.SavedPoints, { Name = name, Position = pos })
					GH.ShowToast(name .. " salvo: " .. math.floor(pos.X) .. ", " .. math.floor(pos.Y) .. ", " .. math.floor(pos.Z), GH.Theme.On, 2)
					if currentTab == "saved" then
						RefreshSavedList(savedScroll)
					end
				else
					GH.ShowToast(GH.T("toast_vehtp_not_in_vehicle"), GH.Theme.Red, 2)
				end
			end
		end)

		-- Carregar lista inicial
		RefreshVehList(playerScroll, "")

		-- Auto-refresh periodico (a cada 2 segundos) + player join/leave
		local refreshLoop = true
		local connPlayerAdded = Players.PlayerAdded:Connect(function()
			if gui and gui.Parent and currentTab == "players" then
				task.defer(function()
					RefreshVehList(playerScroll, searchBox.Text)
				end)
			end
		end)
		local connPlayerRemoving = Players.PlayerRemoving:Connect(function()
			if gui and gui.Parent and currentTab == "players" then
				task.defer(function()
					RefreshVehList(playerScroll, searchBox.Text)
				end)
			end
		end)

		-- Periodic refresh para quando players entram/saem de veiculos
		task.spawn(function()
			while refreshLoop and gui and gui.Parent do
				task.wait(2)
				if refreshLoop and gui and gui.Parent and currentTab == "players" then
					RefreshVehList(playerScroll, searchBox.Text)
				end
			end
		end)

		-- Close
		closeBtn.MouseButton1Click:Connect(function()
			refreshLoop = false
			pcall(function() connPlayerAdded:Disconnect() end)
			pcall(function() connPlayerRemoving:Disconnect() end)
			isOpen = false
			GH.States.VehTp = false
			if CacheVehTp.GUI then
				CacheVehTp.GUI:Destroy()
				CacheVehTp.GUI = nil
			end
		end)

		-- Drag
		local dragging, dragInput, dragStart, startPos
		local dragConn = nil

		titleBar.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				dragging = true
				dragStart = input.Position
				startPos = frame.Position
				if not dragConn then
					dragConn = RunService.Heartbeat:Connect(function()
						if not dragging then return end
						if dragInput then
							local delta = dragInput.Position - dragStart
							frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
						end
					end)
				end
				input.Changed:Connect(function()
					if input.UserInputState == Enum.UserInputState.End then
						dragging = false
						if dragConn then dragConn:Disconnect(); dragConn = nil end
					end
				end)
			end
		end)

		titleBar.InputChanged:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
				dragInput = input
			end
		end)
	end

	GH.RegisterToggleButton("VehTp", "toggle_vehtp", Cheats_ToggleVehTp, "Utility", "desc_vehtp")
end
