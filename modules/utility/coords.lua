-- =============================================================================
-- COMMAND: COORDS
-- =============================================================================
return function(GH)
	local Players = GH.Services.Players
	local RunService = GH.Services.RunService
	local LocalPlayer = GH.LocalPlayer

	local CacheCoords = { SavedPoints = {} }

	function Cheats_ToggleCoords(state, btn)
		GH.UnregisterMasterLoop("Coords")

		if not state then
			if GH.Objects.CoordsGui then
				pcall(function() GH.Objects.CoordsGui:Destroy() end)
				GH.Objects.CoordsGui = nil
			end
			return
		end

		-- Independent GUI
		local gui = Instance.new("ScreenGui")
		gui.Name = "GH_CoordsGui"
		gui.ResetOnSpawn = false
		gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
		gui.DisplayOrder = 20
		gui.Parent = GH.TargetGui
		GH.Objects.CoordsGui = gui

		local W = 200
		local H = 240

		local frame = Instance.new("Frame")
		frame.Name = "CoordsFrame"
		frame.Size = UDim2.new(0, W, 0, H)
		frame.Position = UDim2.new(0.5, -W / 2, 0.5, -H / 2)
		frame.BackgroundColor3 = GH.Theme.BG
		frame.BorderSizePixel = 0
		frame.ClipsDescendants = true
		frame.Parent = gui
		Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 8)
		local stroke = Instance.new("UIStroke")
		stroke.Color = Color3.fromRGB(60, 60, 70)
		stroke.Thickness = 1
		stroke.Transparency = 0.2
		stroke.Parent = frame

		-- Topbar
		local topbar = Instance.new("Frame")
		topbar.Name = "Topbar"
		topbar.Size = UDim2.new(1, 0, 0, 28)
		topbar.BackgroundColor3 = Color3.fromRGB(16, 16, 20)
		topbar.BorderSizePixel = 0
		topbar.ZIndex = 2
		topbar.Parent = frame

		local titleLabel = Instance.new("TextLabel")
		titleLabel.Size = UDim2.new(1, -34, 1, 0)
		titleLabel.Position = UDim2.new(0, 10, 0, 0)
		titleLabel.BackgroundTransparency = 1
		titleLabel.Text = GH.T("section_coords")
		titleLabel.TextColor3 = GH.Theme.Accent
		titleLabel.Font = Enum.Font.GothamBold
		titleLabel.TextSize = 11
		titleLabel.TextXAlignment = Enum.TextXAlignment.Left
		titleLabel.ZIndex = 3
		titleLabel.Parent = topbar

		local closeBtn = Instance.new("TextButton")
		closeBtn.Name = "Close"
		closeBtn.Size = UDim2.new(0, 24, 0, 24)
		closeBtn.Position = UDim2.new(1, -28, 0, 2)
		closeBtn.BackgroundColor3 = GH.Theme.Card
		closeBtn.Text = ""
		closeBtn.AutoButtonColor = false
		closeBtn.ZIndex = 3
		closeBtn.Parent = topbar
		Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 4)
		local closeX = Instance.new("TextLabel")
		closeX.Size = UDim2.new(1, 0, 1, 0)
		closeX.BackgroundTransparency = 1
		closeX.Text = "X"
		closeX.TextColor3 = GH.Theme.Text
		closeX.Font = Enum.Font.SourceSans
		closeX.TextSize = 14
		closeX.ZIndex = 4
		closeX.Parent = closeBtn

		-- Coords display
		local coordsLabel = Instance.new("TextLabel")
		coordsLabel.Name = "Coords"
		coordsLabel.Size = UDim2.new(1, -16, 0, 20)
		coordsLabel.Position = UDim2.new(0, 8, 0, 34)
		coordsLabel.BackgroundTransparency = 1
		coordsLabel.Text = "X: 0  Y: 0  Z: 0"
		coordsLabel.TextColor3 = GH.Theme.Text
		coordsLabel.Font = Enum.Font.RobotoMono
		coordsLabel.TextSize = 11
		coordsLabel.TextXAlignment = Enum.TextXAlignment.Left
		coordsLabel.ZIndex = 3
		coordsLabel.Parent = frame

		-- Save button
		local saveBtn = Instance.new("TextButton")
		saveBtn.Size = UDim2.new(1, -16, 0, 26)
		saveBtn.Position = UDim2.new(0, 8, 0, 58)
		saveBtn.BackgroundColor3 = GH.Theme.Accent
		saveBtn.Text = GH.T("coords_save")
		saveBtn.TextColor3 = GH.Theme.Text
		saveBtn.Font = Enum.Font.GothamMedium
		saveBtn.TextSize = 11
		saveBtn.AutoButtonColor = false
		saveBtn.ZIndex = 3
		saveBtn.Parent = frame
		Instance.new("UICorner", saveBtn).CornerRadius = UDim.new(0, 4)

		-- Saved points list
		local listLabel = Instance.new("TextLabel")
		listLabel.Size = UDim2.new(1, -16, 0, 14)
		listLabel.Position = UDim2.new(0, 8, 0, 90)
		listLabel.BackgroundTransparency = 1
		listLabel.Text = GH.T("coords_saved")
		listLabel.TextColor3 = GH.Theme.Off
		listLabel.Font = Enum.Font.GothamBold
		listLabel.TextSize = 10
		listLabel.TextXAlignment = Enum.TextXAlignment.Left
		listLabel.ZIndex = 3
		listLabel.Parent = frame

		local listScroll = Instance.new("ScrollingFrame")
		listScroll.Name = "SavedList"
		listScroll.Size = UDim2.new(1, -16, 0, 80)
		listScroll.Position = UDim2.new(0, 8, 0, 106)
		listScroll.BackgroundTransparency = 1
		listScroll.ScrollBarThickness = 3
		listScroll.ScrollBarImageColor3 = GH.Theme.Accent
		listScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
		listScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
		listScroll.BorderSizePixel = 0
		listScroll.ZIndex = 3
		listScroll.Parent = frame
		Instance.new("UIListLayout", listScroll).Padding = UDim.new(0, 2)

		local selectedPoint = nil

		local function refreshList()
			for _, child in ipairs(listScroll:GetChildren()) do
				if child:IsA("TextButton") then child:Destroy() end
			end
			for i, point in ipairs(CacheCoords.SavedPoints) do
				local btn = Instance.new("TextButton")
				btn.Name = point.Name
				btn.Size = UDim2.new(1, 0, 0, 22)
				btn.BackgroundColor3 = GH.Theme.Card
				btn.Text = "  " .. point.Name
				btn.TextColor3 = GH.Theme.Text
				btn.Font = Enum.Font.GothamMedium
				btn.TextSize = 10
				btn.TextXAlignment = Enum.TextXAlignment.Left
				btn.AutoButtonColor = false
				btn.LayoutOrder = i
				btn.ZIndex = 4
				btn.Parent = listScroll
				Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 3)

				btn.MouseButton1Click:Connect(function()
					selectedPoint = point
					for _, child in ipairs(listScroll:GetChildren()) do
						if child:IsA("TextButton") then
							GH.Services.TweenService:Create(child, GH.TI, { BackgroundColor3 = GH.Theme.Card }):Play()
						end
					end
					GH.Services.TweenService:Create(btn, GH.TI, { BackgroundColor3 = GH.Theme.AccentDim }):Play()
				end)
			end
		end

		refreshList()

		-- TP button
		local tpBtn = Instance.new("TextButton")
		tpBtn.Size = UDim2.new(1, -16, 0, 26)
		tpBtn.Position = UDim2.new(0, 8, 0, 192)
		tpBtn.BackgroundColor3 = GH.Theme.Accent
		tpBtn.Text = GH.T("coords_tp")
		tpBtn.TextColor3 = GH.Theme.Text
		tpBtn.Font = Enum.Font.GothamMedium
		tpBtn.TextSize = 11
		tpBtn.AutoButtonColor = false
		tpBtn.ZIndex = 3
		tpBtn.Parent = frame
		Instance.new("UICorner", tpBtn).CornerRadius = UDim.new(0, 4)

		saveBtn.MouseButton1Click:Connect(function()
			local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
			if hrp then
				local pos = hrp.Position
				table.insert(CacheCoords.SavedPoints, { Name = GH.T("coords_point_prefix") .. (#CacheCoords.SavedPoints + 1), Position = pos })
				refreshList()
				GH.ShowToast(GH.T("toast_position_saved"), GH.Theme.On, 2)
			end
		end)

		tpBtn.MouseButton1Click:Connect(function()
			if selectedPoint then
				local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
				if hrp then
					hrp.CFrame = CFrame.new(selectedPoint.Position + Vector3.new(0, 3, 0))
					GH.ShowToast(string.format(GH.T("toast_tp_to"), selectedPoint.Name), GH.Theme.On, 2)
				end
			end
		end)

		-- Close
		closeBtn.MouseEnter:Connect(function()
			GH.Services.TweenService:Create(closeBtn, GH.TI, { BackgroundColor3 = GH.Theme.Red }):Play()
		end)
		closeBtn.MouseLeave:Connect(function()
			GH.Services.TweenService:Create(closeBtn, GH.TI, { BackgroundColor3 = GH.Theme.Card }):Play()
		end)
		closeBtn.MouseButton1Click:Connect(function()
			GH.UnregisterMasterLoop("Coords")
			gui:Destroy()
			GH.Objects.CoordsGui = nil
		end)

		-- Drag
		local dragging, dragInput, dragStart, startPos
		topbar.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				dragging = true
				dragStart = input.Position
				startPos = frame.Position
				input.Changed:Connect(function()
					if input.UserInputState == Enum.UserInputState.End then dragging = false end
				end)
			end
		end)
		topbar.InputChanged:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
				dragInput = input
			end
		end)
		GH.Services.UserInputService.InputChanged:Connect(function(input)
			if dragging and input == dragInput then
				local delta = input.Position - dragStart
				frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
			end
		end)

		-- Update coords loop
		GH.RegisterMasterLoop("Coords", "Render", function()
			if GH.isClosing or not GH.States.Coords then
				GH.UnregisterMasterLoop("Coords")
				return
			end
			local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
			if hrp and coordsLabel and coordsLabel.Parent then
				local p = hrp.Position
				coordsLabel.Text = "X: " .. math.floor(p.X) .. "  Y: " .. math.floor(p.Y) .. "  Z: " .. math.floor(p.Z)
			end
		end)
	end

	GH.RegisterToggleButton("Coords", "toggle_coords", Cheats_ToggleCoords, "Utility", "desc_coords")
end
