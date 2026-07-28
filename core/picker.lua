-- =============================================================================
-- PICKER — GUIs flutuantes (ShowPlayerPicker + ShowInputPicker)
-- =============================================================================
return function(GH, services)
local Players = services.Players
local TweenService = services.TweenService
local UserInputService = services.UserInputService
local LocalPlayer = GH.LocalPlayer

-- ==========================================
-- PLAYER PICKER (GUI flutuante independente)
-- ==========================================
GH._Pickers = GH._Pickers or {}
GH._PickerCount = GH._PickerCount or 0

function GH.ShowPlayerPicker(title, callback)
	GH._PickerCount = GH._PickerCount + 1
	local pickerId = GH._PickerCount

	local gui = Instance.new("ScreenGui")
	gui.Name = "GH_PlayerPicker_" .. pickerId
	gui.ResetOnSpawn = false
	gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	gui.DisplayOrder = 100
	gui.Parent = GH.TargetGui

	-- Posicionar cada novo picker deslocado
	local offset = (pickerId % 5) * 30

	local W = 200
	local H = 280
	local TOPBAR = 32

	-- Main frame (sem ClipsDescendants!)
	local frame = Instance.new("Frame")
	frame.Name = "Frame"
	frame.Size = UDim2.new(0, W, 0, H)
	frame.Position = UDim2.new(0.5, -W / 2 + offset, 0.5, -H / 2 + offset)
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
	titlelbl.Text = title or "Select"
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
	searchBox.PlaceholderText = "Procurar player..."
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

	local selectedName = nil
	local minimized = false
	local searchText = ""

	local function buildList()
		for _, c in ipairs(scroll:GetChildren()) do
			if c:IsA("TextButton") or c:IsA("TextLabel") then c:Destroy() end
		end
		local myTeam = LocalPlayer.Team
		local names = {}
		for _, p in ipairs(Players:GetPlayers()) do
			if p ~= LocalPlayer then
				if searchText == "" or p.Name:lower():find(searchText:lower(), 1, true) then
					table.insert(names, p.Name)
				end
			end
		end
		table.sort(names)
		if #names == 0 then
			local e = Instance.new("TextLabel")
			e.Size = UDim2.new(1, 0, 0, 40)
			e.BackgroundTransparency = 1
			e.Text = "Nenhum jogador"
			e.TextColor3 = Color3.fromRGB(140, 140, 155)
			e.Font = Enum.Font.GothamMedium
			e.TextSize = 11
			e.Parent = scroll
			return
		end
		for i, name in ipairs(names) do
			local player = Players:FindFirstChild(name)
			local tag = ""
			local nameColor = Color3.fromRGB(235, 235, 240)
			if player then
				local pTeam = player.Team
				local pTeamColor = player.TeamColor
				local myTeamColor = myTeam and myTeam.TeamColor or LocalPlayer.TeamColor
				local hasTeams = (myTeam ~= nil) or (myTeamColor and myTeamColor ~= BrickColor.new("Medium stone grey"))
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
			end
			local b = Instance.new("TextButton")
			b.Name = name
			b.Size = UDim2.new(1, 0, 0, 28)
			b.BackgroundColor3 = Color3.fromRGB(28, 28, 32)
			b.Text = ""
			b.AutoButtonColor = false
			b.LayoutOrder = i
			b.Parent = scroll
			Instance.new("UICorner", b).CornerRadius = UDim.new(0, 4)

			if tag ~= "" then
				local tagLbl = Instance.new("TextLabel")
				tagLbl.Size = UDim2.new(0, 55, 1, 0)
				tagLbl.Position = UDim2.new(0, 6, 0, 0)
				tagLbl.BackgroundTransparency = 1
				tagLbl.Text = tag
				tagLbl.TextColor3 = nameColor
				tagLbl.Font = Enum.Font.GothamBold
				tagLbl.TextSize = 9
				tagLbl.TextXAlignment = Enum.TextXAlignment.Left
				tagLbl.Parent = b
			end

			local nameLbl = Instance.new("TextLabel")
			nameLbl.Size = UDim2.new(1, -65, 1, 0)
			nameLbl.Position = UDim2.new(0, 60, 0, 0)
			nameLbl.BackgroundTransparency = 1
			nameLbl.Text = name
			nameLbl.TextColor3 = nameColor
			nameLbl.Font = Enum.Font.GothamMedium
			nameLbl.TextSize = 11
			nameLbl.TextXAlignment = Enum.TextXAlignment.Left
			nameLbl.TextTruncate = Enum.TextTruncate.AtEnd
			nameLbl.Parent = b

			b.MouseEnter:Connect(function()
				if selectedName ~= name then
					TweenService:Create(b, GH.TI, { BackgroundColor3 = Color3.fromRGB(38, 38, 42) }):Play()
				end
			end)
			b.MouseLeave:Connect(function()
				if selectedName ~= name then
					TweenService:Create(b, GH.TI, { BackgroundColor3 = Color3.fromRGB(28, 28, 32) }):Play()
				end
			end)
			b.MouseButton1Click:Connect(function()
				selectedName = name
				for _, c in ipairs(scroll:GetChildren()) do
					if c:IsA("TextButton") then
						TweenService:Create(c, GH.TI, { BackgroundColor3 = Color3.fromRGB(28, 28, 32) }):Play()
					end
				end
				TweenService:Create(b, GH.TI, { BackgroundColor3 = Color3.fromRGB(0, 99, 177) }):Play()
				if callback then pcall(callback, name) end
			end)
		end
	end

	buildList()

	searchBox:GetPropertyChangedSignal("Text"):Connect(function()
		searchText = searchBox.Text
		buildList()
	end)

	local connAdded = Players.PlayerAdded:Connect(function()
		if gui and gui.Parent then buildList() end
	end)
	local connRemoving = Players.PlayerRemoving:Connect(function()
		if gui and gui.Parent then buildList() end
	end)

	GH._Pickers[pickerId] = { gui = gui, conns = { connAdded, connRemoving }, dragConn = nil }

	closeBtn.MouseButton1Click:Connect(function()
		pcall(function() connAdded:Disconnect() end)
		pcall(function() connRemoving:Disconnect() end)
		if GH._Pickers[pickerId] and GH._Pickers[pickerId].dragConn then
			pcall(function() GH._Pickers[pickerId].dragConn:Disconnect() end)
		end
		GH._Pickers[pickerId] = nil
		gui:Destroy()
	end)

	minBtn.MouseButton1Click:Connect(function()
		minimized = not minimized
		if minimized then
			content.Visible = false
			TweenService:Create(frame, GH.TI, { Size = UDim2.new(0, W, 0, TOPBAR) }):Play()
			minBtn:GetPropertyChangedSignal("Text"):Wait()
		else
			content.Visible = true
			TweenService:Create(frame, GH.TI, { Size = UDim2.new(0, W, 0, H) }):Play()
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
				dragConn = services.RunService.Heartbeat:Connect(function()
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
end

-- ==========================================
-- INPUT PICKER (GUI flutuante para inputs)
-- ==========================================
function GH.ShowInputPicker(title, placeholder, callback)
	GH._PickerCount = GH._PickerCount + 1
	local pickerId = GH._PickerCount

	local gui = Instance.new("ScreenGui")
	gui.Name = "GH_InputPicker_" .. pickerId
	gui.ResetOnSpawn = false
	gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	gui.DisplayOrder = 100
	gui.Parent = GH.TargetGui

	local offset = (pickerId % 5) * 30
	local W = 250
	local H = 120
	local TOPBAR = 32

	local frame = Instance.new("Frame")
	frame.Name = "Frame"
	frame.Size = UDim2.new(0, W, 0, H)
	frame.Position = UDim2.new(0.5, -W / 2 + offset, 0.5, -H / 2 + offset)
	frame.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
	frame.BorderSizePixel = 0
	frame.Active = true
	frame.Parent = gui
	Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 10)
	local stroke = Instance.new("UIStroke")
	stroke.Color = Color3.fromRGB(60, 60, 70)
	stroke.Thickness = 1
	stroke.Parent = frame

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
	titlelbl.Text = title or "Input"
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

	local inputBox = Instance.new("TextBox")
	inputBox.Size = UDim2.new(1, 0, 0, 28)
	inputBox.Position = UDim2.new(0, 0, 0, 8)
	inputBox.BackgroundColor3 = Color3.fromRGB(28, 28, 32)
	inputBox.PlaceholderText = placeholder or "Digite..."
	inputBox.PlaceholderColor3 = Color3.fromRGB(100, 100, 115)
	inputBox.Text = ""
	inputBox.TextColor3 = Color3.fromRGB(235, 235, 240)
	inputBox.Font = Enum.Font.GothamMedium
	inputBox.TextSize = 11
	inputBox.TextXAlignment = Enum.TextXAlignment.Left
	inputBox.ClearTextOnFocus = false
	inputBox.ZIndex = 10
	inputBox.Parent = content
	Instance.new("UICorner", inputBox).CornerRadius = UDim.new(0, 4)
	Instance.new("UIPadding", inputBox).PaddingLeft = UDim.new(0, 6)

	local confirmBtn = Instance.new("TextButton")
	confirmBtn.Size = UDim2.new(1, 0, 0, 28)
	confirmBtn.Position = UDim2.new(0, 0, 0, 42)
	confirmBtn.BackgroundColor3 = Color3.fromRGB(0, 99, 177)
	confirmBtn.Text = "Confirmar"
	confirmBtn.TextColor3 = Color3.fromRGB(235, 235, 240)
	confirmBtn.Font = Enum.Font.GothamMedium
	confirmBtn.TextSize = 11
	confirmBtn.AutoButtonColor = false
	confirmBtn.ZIndex = 10
	confirmBtn.Parent = content
	Instance.new("UICorner", confirmBtn).CornerRadius = UDim.new(0, 4)

	confirmBtn.MouseEnter:Connect(function()
		TweenService:Create(confirmBtn, GH.TI, { BackgroundColor3 = Color3.fromRGB(0, 120, 212) }):Play()
	end)
	confirmBtn.MouseLeave:Connect(function()
		TweenService:Create(confirmBtn, GH.TI, { BackgroundColor3 = Color3.fromRGB(0, 99, 177) }):Play()
	end)

	local function close()
		gui:Destroy()
	end

	confirmBtn.MouseButton1Click:Connect(function()
		if callback then pcall(callback, inputBox.Text) end
		close()
	end)

	inputBox.FocusLost:Connect(function(enterPressed)
		if enterPressed then
			if callback then pcall(callback, inputBox.Text) end
			close()
		end
	end)

	closeBtn.MouseButton1Click:Connect(close)

	local minimized = false
	minBtn.MouseButton1Click:Connect(function()
		minimized = not minimized
		if minimized then
			content.Visible = false
			TweenService:Create(frame, GH.TI, { Size = UDim2.new(0, W, 0, TOPBAR) }):Play()
		else
			content.Visible = true
			TweenService:Create(frame, GH.TI, { Size = UDim2.new(0, W, 0, H) }):Play()
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
				dragConn = services.RunService.Heartbeat:Connect(function()
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
end

end -- module
