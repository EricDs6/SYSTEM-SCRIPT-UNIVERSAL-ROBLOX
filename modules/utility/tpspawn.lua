-- =============================================================================
-- COMMAND: TP TO SPAWN
-- Escaneia todos os SpawnLocation do mapa, mostra lista com busca e teleporta
-- =============================================================================
return function(GH)
	local Players = GH.Services.Players
	local RunService = GH.Services.RunService
	local TweenService = GH.Services.TweenService
	local LocalPlayer = GH.LocalPlayer

	local spawnGui = nil
	local isOpen = false

	local function scanSpawns()
		local spawns = {}
		for _, obj in ipairs(workspace:GetDescendants()) do
			if obj:IsA("SpawnLocation") then
				table.insert(spawns, {
					part = obj,
					name = obj.Name ~= "" and obj.Name or ("Spawn " .. #spawns + 1),
				})
			end
		end
		return spawns
	end

	local function teleportToSpawn(spawn)
		local myChar = LocalPlayer.Character
		if not myChar then return end
		local myRoot = myChar:FindFirstChild("HumanoidRootPart")
		if not myRoot then return end

		local spawnPart = spawn.part
		if not spawnPart or not spawnPart.Parent then
			GH.ShowToast(GH.T("toast_tpspawn_notfound"), GH.Theme.Red)
			return
		end

		GH.TweenTeleport(myRoot, spawnPart.CFrame + Vector3.new(0, 3, 0), 0.1)
		GH.ShowToast(string.format(GH.T("toast_tpspawn_tp"), spawn.name), GH.Theme.On, 2)
	end

	local function createSpawnGUI()
		if spawnGui then
			spawnGui:Destroy()
			spawnGui = nil
		end

		local gui = Instance.new("ScreenGui")
		gui.Name = "GH_SpawnPicker"
		gui.ResetOnSpawn = false
		gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
		gui.DisplayOrder = 100
		gui.Parent = GH.TargetGui
		spawnGui = gui

		local W = 220
		local H = 300
		local TOPBAR = 32

		local frame = Instance.new("Frame")
		frame.Name = "Frame"
		frame.Size = UDim2.new(0, W, 0, H)
		frame.Position = UDim2.new(0.5, -W / 2, 0.5, -H / 2)
		frame.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
		frame.BorderSizePixel = 0
		frame.Active = true
		frame.Parent = gui
		Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 10)
		local s = Instance.new("UIStroke")
		s.Color = Color3.fromRGB(60, 60, 70)
		s.Thickness = 1
		s.Parent = frame

		-- Topbar
		local tb = Instance.new("TextButton")
		tb.Name = "Topbar"
		tb.Size = UDim2.new(1, 0, 0, TOPBAR)
		tb.BackgroundColor3 = Color3.fromRGB(16, 16, 20)
		tb.BorderSizePixel = 0
		tb.Text = ""
		tb.AutoButtonColor = false
		tb.Parent = frame

		local titlelbl = Instance.new("TextLabel")
		titlelbl.Size = UDim2.new(1, -66, 1, 0)
		titlelbl.Position = UDim2.new(0, 10, 0, 0)
		titlelbl.BackgroundTransparency = 1
		titlelbl.Text = GH.T("input_tpspawn_title")
		titlelbl.TextColor3 = Color3.fromRGB(0, 120, 212)
		titlelbl.Font = Enum.Font.GothamBold
		titlelbl.TextSize = 11
		titlelbl.TextXAlignment = Enum.TextXAlignment.Left
		titlelbl.Parent = tb

		local function makeBtn(posX, text)
			local b = Instance.new("TextButton")
			b.Size = UDim2.new(0, 24, 0, 24)
			b.Position = UDim2.new(1, posX, 0.5, -12)
			b.BackgroundColor3 = Color3.fromRGB(28, 28, 32)
			b.Text = ""
			b.AutoButtonColor = false
			b.Parent = tb
			Instance.new("UICorner", b).CornerRadius = UDim.new(0, 4)
			local lbl = Instance.new("TextLabel")
			lbl.Size = UDim2.new(1, 0, 1, 0)
			lbl.BackgroundTransparency = 1
			lbl.Text = text
			lbl.TextColor3 = text == "X" and Color3.fromRGB(235, 235, 240) or Color3.fromRGB(180, 180, 190)
			lbl.Font = Enum.Font.SourceSans
			lbl.TextSize = 14
			lbl.Parent = b
			return b
		end

		local minBtn = makeBtn(-56, "-")
		local closeBtn = makeBtn(-28, "X")

		closeBtn.MouseEnter:Connect(function()
			TweenService:Create(closeBtn, GH.TI, { BackgroundColor3 = Color3.fromRGB(255, 60, 60) }):Play()
		end)
		closeBtn.MouseLeave:Connect(function()
			TweenService:Create(closeBtn, GH.TI, { BackgroundColor3 = Color3.fromRGB(28, 28, 32) }):Play()
		end)

		-- Content
		local content = Instance.new("Frame")
		content.Name = "Content"
		content.Size = UDim2.new(1, -8, 1, -TOPBAR - 4)
		content.Position = UDim2.new(0, 4, 0, TOPBAR + 2)
		content.BackgroundTransparency = 1
		content.Parent = frame

		-- Search bar
		local searchBox = Instance.new("TextBox")
		searchBox.Name = "Search"
		searchBox.Size = UDim2.new(1, 0, 0, 26)
		searchBox.Position = UDim2.new(0, 0, 0, 0)
		searchBox.BackgroundColor3 = Color3.fromRGB(28, 28, 32)
		searchBox.PlaceholderText = GH.T("input_tpspawn_placeholder")
		searchBox.PlaceholderColor3 = Color3.fromRGB(100, 100, 115)
		searchBox.Text = ""
		searchBox.TextColor3 = Color3.fromRGB(235, 235, 240)
		searchBox.Font = Enum.Font.GothamMedium
		searchBox.TextSize = 11
		searchBox.TextXAlignment = Enum.TextXAlignment.Left
		searchBox.ClearTextOnFocus = false
		searchBox.ZIndex = 10
		searchBox.Parent = content
		Instance.new("UICorner", searchBox).CornerRadius = UDim.new(0, 4)
		Instance.new("UIPadding", searchBox).PaddingLeft = UDim.new(0, 6)

		-- ScrollingFrame
		local scroll = Instance.new("ScrollingFrame")
		scroll.Name = "List"
		scroll.Size = UDim2.new(1, 0, 1, -30)
		scroll.Position = UDim2.new(0, 0, 0, 30)
		scroll.BackgroundTransparency = 1
		scroll.ScrollBarThickness = 3
		scroll.ScrollBarImageColor3 = Color3.fromRGB(0, 120, 212)
		scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
		scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
		scroll.BorderSizePixel = 0
		scroll.Parent = content
		Instance.new("UIListLayout", scroll).Padding = UDim.new(0, 2)

		local minimized = false
		local searchText = ""

		local function buildList()
			for _, c in ipairs(scroll:GetChildren()) do
				if c:IsA("TextButton") or c:IsA("TextLabel") then c:Destroy() end
			end

			local spawns = scanSpawns()
			local filtered = {}
			for _, sp in ipairs(spawns) do
				if searchText == "" or sp.name:lower():find(searchText:lower(), 1, true) then
					table.insert(filtered, sp)
				end
			end

			if #filtered == 0 then
				local e = Instance.new("TextLabel")
				e.Size = UDim2.new(1, 0, 0, 40)
				e.BackgroundTransparency = 1
				e.Text = GH.T("toast_tpspawn_notfound")
				e.TextColor3 = Color3.fromRGB(140, 140, 155)
				e.Font = Enum.Font.GothamMedium
				e.TextSize = 11
				e.Parent = scroll
				return
			end

			for i, sp in ipairs(filtered) do
				local b = Instance.new("TextButton")
				b.Name = sp.name
				b.Size = UDim2.new(1, 0, 0, 28)
				b.BackgroundColor3 = Color3.fromRGB(28, 28, 32)
				b.Text = ""
				b.AutoButtonColor = false
				b.LayoutOrder = i
				b.Parent = scroll
				Instance.new("UICorner", b).CornerRadius = UDim.new(0, 4)

				-- Spawn icon
				local iconLbl = Instance.new("TextLabel")
				iconLbl.Size = UDim2.new(0, 24, 1, 0)
				iconLbl.Position = UDim2.new(0, 6, 0, 0)
				iconLbl.BackgroundTransparency = 1
				iconLbl.Text = "\xF0\x9F\x93\x8D"
				iconLbl.TextColor3 = Color3.fromRGB(0, 120, 212)
				iconLbl.Font = Enum.Font.GothamMedium
				iconLbl.TextSize = 12
				iconLbl.Parent = b

				-- Name label
				local nameLbl = Instance.new("TextLabel")
				nameLbl.Size = UDim2.new(1, -36, 1, 0)
				nameLbl.Position = UDim2.new(0, 32, 0, 0)
				nameLbl.BackgroundTransparency = 1
				nameLbl.Text = sp.name
				nameLbl.TextColor3 = Color3.fromRGB(235, 235, 240)
				nameLbl.Font = Enum.Font.GothamMedium
				nameLbl.TextSize = 11
				nameLbl.TextXAlignment = Enum.TextXAlignment.Left
				nameLbl.TextTruncate = Enum.TextTruncate.AtEnd
				nameLbl.Parent = b

				-- Arrow
				local arrow = Instance.new("TextLabel")
				arrow.Size = UDim2.new(0, 20, 1, 0)
				arrow.Position = UDim2.new(1, -24, 0, 0)
				arrow.BackgroundTransparency = 1
				arrow.Text = "\xE2\x96\xB6"
				arrow.TextColor3 = Color3.fromRGB(140, 140, 155)
				arrow.Font = Enum.Font.GothamMedium
				arrow.TextSize = 10
				arrow.Parent = b

				b.MouseEnter:Connect(function()
					TweenService:Create(b, GH.TI, { BackgroundColor3 = Color3.fromRGB(38, 38, 42) }):Play()
				end)
				b.MouseLeave:Connect(function()
					TweenService:Create(b, GH.TI, { BackgroundColor3 = Color3.fromRGB(28, 28, 32) }):Play()
				end)
				b.MouseButton1Click:Connect(function()
					teleportToSpawn(sp)
				end)
			end
		end

		buildList()

		-- Search filter
		searchBox:GetPropertyChangedSignal("Text"):Connect(function()
			searchText = searchBox.Text
			buildList()
		end)

		-- Refresh ao adicionar/remover spawns
		local connAdded = workspace.DescendantAdded:Connect(function(obj)
			if obj:IsA("SpawnLocation") then
				if gui and gui.Parent then buildList() end
			end
		end)
		local connRemoving = workspace.DescendantRemoving:Connect(function(obj)
			if obj:IsA("SpawnLocation") then
				if gui and gui.Parent then buildList() end
			end
		end)

		-- Close
		closeBtn.MouseButton1Click:Connect(function()
			pcall(function() connAdded:Disconnect() end)
			pcall(function() connRemoving:Disconnect() end)
			isOpen = false
			GH.States.TpToSpawn = false
			spawnGui:Destroy()
			spawnGui = nil
		end)

		-- Minimize
		minBtn.MouseButton1Click:Connect(function()
			minimized = not minimized
			if minimized then
				content.Visible = false
				TweenService:Create(frame, GH.TI, { Size = UDim2.new(0, W, 0, TOPBAR) }):Play()
			else
				TweenService:Create(frame, GH.TI, { Size = UDim2.new(0, W, 0, H) }):Play()
				task.delay(0.15, function() content.Visible = true end)
			end
		end)

		-- Drag
		local dragging, dragInput, dragStart, startPos
		local dragConn = nil

		tb.InputBegan:Connect(function(input)
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

		tb.InputChanged:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
				dragInput = input
			end
		end)

		return gui
	end

	function Cheats_ToggleTpToSpawn(state, btn)
		if state then
			if isOpen then return end
			isOpen = true
			createSpawnGUI()
		else
			if spawnGui then
				spawnGui:Destroy()
				spawnGui = nil
			end
			isOpen = false
		end
	end

	GH.RegisterToggleButton("TpToSpawn", "toggle_tpspawn", Cheats_ToggleTpToSpawn, "Utility", "desc_tpspawn")
end
