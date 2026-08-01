-- =============================================================================
-- COMMAND: VEHTP (Vehicle Teleport)
-- Lista veiculos com coordenadas, teleporta instantaneamente e salva posicoes
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
	-- SCAN: Encontra todos os veiculos no mapa
	-- ==========================================
	local function scanVehicles()
		local vehicles = {}
		local seen = {}
		for _, obj in ipairs(workspace:GetDescendants()) do
			if obj:IsA("VehicleSeat") or obj:IsA("Seat") then
				local model = obj:FindFirstAncestorOfClass("Model")
				if model and not seen[model] then
					seen[model] = true
					local pos = obj.Position
					table.insert(vehicles, {
						model = model,
						seat = obj,
						name = model.Name,
						position = pos,
					})
				end
			end
		end
		return vehicles
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
			-- Teleportar veiculo inteiro
			pcall(function()
				local pivot = vehicleModel:GetPivot()
				local offset = pivot:ToObjectSpace(hum.SeatPart.CFrame)
				local newPivot = targetCFrame * offset:Inverse()
				vehicleModel:PivotTo(newPivot)
			end)
				return true
			end
		end

		-- Fallback: teleportar o player
		local root = myChar:FindFirstChild("HumanoidRootPart")
		if root then
			root.CFrame = targetCFrame
			return true
		end
		return false
	end

	-- ==========================================
	-- REFRESH LISTA
	-- ==========================================
	local function RefreshVehList(scroll, searchText)
		for _, child in ipairs(scroll:GetChildren()) do
			if child:IsA("Frame") then child:Destroy() end
		end

		local vehicles = scanVehicles()
		local filtered = {}
		for _, v in ipairs(vehicles) do
			if searchText == "" or v.name:lower():find(searchText:lower(), 1, true) then
				table.insert(filtered, v)
			end
		end

		-- Veiculos encontrados
		if #filtered == 0 then
			local empty = Instance.new("TextLabel")
			empty.Size = UDim2.new(1, 0, 0, 36)
			empty.BackgroundTransparency = 1
			empty.Text = GH.T("toast_tptovehicle_notfound")
			empty.TextColor3 = Color3.fromRGB(140, 140, 155)
			empty.Font = Enum.Font.GothamMedium
			empty.TextSize = 11
			empty.Parent = scroll
			return
		end

		for i, vehicle in ipairs(filtered) do
			local item = Instance.new("Frame")
			item.Size = UDim2.new(1, 0, 0, 36)
			item.BackgroundColor3 = Color3.fromRGB(28, 28, 32)
			item.BorderSizePixel = 0
			item.LayoutOrder = i
			item.Parent = scroll
			Instance.new("UICorner", item).CornerRadius = UDim.new(0, 5)

			-- Nome
			local nameLabel = Instance.new("TextLabel")
			nameLabel.Size = UDim2.new(0.45, 0, 0, 14)
			nameLabel.Position = UDim2.new(0, 8, 0, 3)
			nameLabel.BackgroundTransparency = 1
			nameLabel.Text = vehicle.name
			nameLabel.TextColor3 = Color3.fromRGB(235, 235, 240)
			nameLabel.Font = Enum.Font.GothamMedium
			nameLabel.TextSize = 10
			nameLabel.TextXAlignment = Enum.TextXAlignment.Left
			nameLabel.TextTruncate = Enum.TextTruncate.AtEnd
			nameLabel.Parent = item

			-- Coordenadas
			local coordLabel = Instance.new("TextLabel")
			coordLabel.Size = UDim2.new(0.45, 0, 0, 11)
			coordLabel.Position = UDim2.new(0, 8, 0, 19)
			coordLabel.BackgroundTransparency = 1
			coordLabel.Text = string.format("X:%d Y:%d Z:%d", math.floor(vehicle.position.X), math.floor(vehicle.position.Y), math.floor(vehicle.position.Z))
			coordLabel.TextColor3 = Color3.fromRGB(120, 120, 135)
			coordLabel.Font = Enum.Font.RobotoMono
			coordLabel.TextSize = 8
			coordLabel.TextXAlignment = Enum.TextXAlignment.Left
			coordLabel.Parent = item

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
				local seatCFrame = vehicle.seat and vehicle.seat.CFrame
				if seatCFrame then
					local ok = instantTeleportTo(seatCFrame * CFrame.new(0, 3, 0))
					if ok then
						GH.ShowToast(string.format(GH.T("toast_vehtp_tp"), vehicle.name), GH.Theme.On, 2)
					end
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
		frame.Size = UDim2.new(0, 220, 0, 340)
		frame.Position = UDim2.new(0, 10, 0.5, -170)
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

		-- Tabs: Veiculos | Salvos
		local tabFrame = Instance.new("Frame")
		tabFrame.Size = UDim2.new(1, -8, 0, 24)
		tabFrame.Position = UDim2.new(0, 4, 0, 28)
		tabFrame.BackgroundTransparency = 1
		tabFrame.Parent = frame

		local tabVeh = Instance.new("TextButton")
		tabVeh.Size = UDim2.new(0.5, -2, 1, 0)
		tabVeh.BackgroundColor3 = Color3.fromRGB(0, 99, 177)
		tabVeh.Text = GH.T("tab_vehtp_vehicles")
		tabVeh.TextColor3 = Color3.new(1, 1, 1)
		tabVeh.Font = Enum.Font.GothamBold
		tabVeh.TextSize = 9
		tabVeh.AutoButtonColor = false
		tabVeh.Parent = tabFrame
		Instance.new("UICorner", tabVeh).CornerRadius = UDim.new(0, 4)

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

		-- Tab: Veiculos
		local vehScroll = Instance.new("ScrollingFrame")
		vehScroll.Size = UDim2.new(1, 0, 1, 0)
		vehScroll.BackgroundTransparency = 1
		vehScroll.ScrollBarThickness = 2
		vehScroll.ScrollBarImageColor3 = Color3.fromRGB(0, 120, 212)
		vehScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
		vehScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
		vehScroll.BorderSizePixel = 0
		vehScroll.Parent = contentFrame
		Instance.new("UIListLayout", vehScroll).Padding = UDim.new(0, 3)

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

		local currentTab = "vehicles"

		local function switchTab(tab)
			currentTab = tab
			if tab == "vehicles" then
				vehScroll.Visible = true
				savedScroll.Visible = false
				searchBox.Visible = true
				TweenService:Create(tabVeh, GH.TI, { BackgroundColor3 = Color3.fromRGB(0, 99, 177) }):Play()
				tabVeh.TextColor3 = Color3.new(1, 1, 1)
				TweenService:Create(tabSaved, GH.TI, { BackgroundColor3 = Color3.fromRGB(35, 35, 40) }):Play()
				tabSaved.TextColor3 = Color3.fromRGB(180, 180, 190)
			else
				vehScroll.Visible = false
				savedScroll.Visible = true
				searchBox.Visible = false
				TweenService:Create(tabSaved, GH.TI, { BackgroundColor3 = Color3.fromRGB(0, 99, 177) }):Play()
				tabSaved.TextColor3 = Color3.new(1, 1, 1)
				TweenService:Create(tabVeh, GH.TI, { BackgroundColor3 = Color3.fromRGB(35, 35, 40) }):Play()
				tabVeh.TextColor3 = Color3.fromRGB(180, 180, 190)
				RefreshSavedList(savedScroll)
			end
		end

		tabVeh.MouseButton1Click:Connect(function() switchTab("vehicles") end)
		tabSaved.MouseButton1Click:Connect(function() switchTab("saved") end)

		-- Search filter
		searchBox:GetPropertyChangedSignal("Text"):Connect(function()
			RefreshVehList(vehScroll, searchBox.Text)
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
		RefreshVehList(vehScroll, "")

		-- Auto-refresh ao adicionar/remover veiculos
		local connAdded = workspace.DescendantAdded:Connect(function(obj)
			if obj:IsA("VehicleSeat") or obj:IsA("Seat") then
				if gui and gui.Parent and currentTab == "vehicles" then
					task.defer(function()
						RefreshVehList(vehScroll, searchBox.Text)
					end)
				end
			end
		end)
		local connRemoving = workspace.DescendantRemoving:Connect(function(obj)
			if obj:IsA("VehicleSeat") or obj:IsA("Seat") then
				if gui and gui.Parent and currentTab == "vehicles" then
					task.defer(function()
						RefreshVehList(vehScroll, searchBox.Text)
					end)
				end
			end
		end)

		-- Close
		closeBtn.MouseButton1Click:Connect(function()
			pcall(function() connAdded:Disconnect() end)
			pcall(function() connRemoving:Disconnect() end)
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
