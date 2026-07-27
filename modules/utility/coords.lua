-- =============================================================================
-- COMMAND: COORDS
-- Mostra coordenadas, salva pontos e teleporta
-- =============================================================================
return function(GH)
	local Players = GH.Services.Players
	local RunService = GH.Services.RunService
	local TweenService = GH.Services.TweenService
	local LocalPlayer = GH.LocalPlayer

	local CacheCoords = { SavedPoints = {}, GUI = nil }

	local function RefreshCoordsList(scroll)
		for _, child in ipairs(scroll:GetChildren()) do
			if child:IsA("Frame") then child:Destroy() end
		end

		for i, point in ipairs(CacheCoords.SavedPoints) do
			local item = Instance.new("Frame")
			item.Size = UDim2.new(1, 0, 0, 28)
			item.BackgroundColor3 = Color3.fromRGB(28, 28, 32)
			item.BorderSizePixel = 0
			item.LayoutOrder = i
			item.Parent = scroll

			local label = Instance.new("TextLabel")
			label.Size = UDim2.new(0.55, 0, 1, 0)
			label.Position = UDim2.new(0, 6, 0, 0)
			label.BackgroundTransparency = 1
			label.Text = point.Name
			label.TextColor3 = Color3.fromRGB(235, 235, 240)
			label.Font = Enum.Font.GothamMedium
			label.TextSize = 10
			label.TextXAlignment = Enum.TextXAlignment.Left
			label.TextTruncate = Enum.TextTruncate.AtEnd
			label.Parent = item

			local tpBtn = Instance.new("TextButton")
			tpBtn.Size = UDim2.new(0, 30, 0, 18)
			tpBtn.Position = UDim2.new(1, -66, 0.5, -9)
			tpBtn.BackgroundColor3 = Color3.fromRGB(0, 99, 177)
			tpBtn.Text = "TP"
			tpBtn.TextColor3 = Color3.new(1, 1, 1)
			tpBtn.Font = Enum.Font.GothamBold
			tpBtn.TextSize = 8
			tpBtn.AutoButtonColor = false
			tpBtn.Parent = item

			tpBtn.MouseButton1Click:Connect(function()
				local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
				if hrp then
					GH.TweenTeleport(hrp, CFrame.new(point.Position + Vector3.new(0, 3, 0)))
					GH.ShowToast("Teleportado para " .. point.Name, GH.Theme.On, 2)
				end
			end)

			local delBtn = Instance.new("TextButton")
			delBtn.Size = UDim2.new(0, 22, 0, 18)
			delBtn.Position = UDim2.new(1, -32, 0.5, -9)
			delBtn.BackgroundColor3 = Color3.fromRGB(80, 30, 30)
			delBtn.Text = "X"
			delBtn.TextColor3 = Color3.fromRGB(200, 100, 100)
			delBtn.Font = Enum.Font.GothamBold
			delBtn.TextSize = 9
			delBtn.AutoButtonColor = false
			delBtn.Parent = item

			delBtn.MouseButton1Click:Connect(function()
				table.remove(CacheCoords.SavedPoints, i)
				RefreshCoordsList(scroll)
			end)
		end
	end

	function Cheats_ToggleCoords(state, btn)
		if not state then
			if CacheCoords.GUI then
				CacheCoords.GUI:Destroy()
				CacheCoords.GUI = nil
			end
			return
		end

		-- Criar GUI independente (igual Op.txt)
		if CacheCoords.GUI then CacheCoords.GUI:Destroy() end

		local gui = Instance.new("ScreenGui")
		gui.Name = "GH_CoordsGUI"
		gui.ResetOnSpawn = false
		gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
		gui.DisplayOrder = 100
		gui.Parent = GH.TargetGui
		CacheCoords.GUI = gui

		local frame = Instance.new("Frame")
		frame.Size = UDim2.new(0, 180, 0, 250)
		frame.Position = UDim2.new(0, 10, 0.5, -125)
		frame.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
		frame.BorderSizePixel = 0
		frame.Active = true
		frame.Parent = gui
		Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 8)
		local stroke = Instance.new("UIStroke")
		stroke.Color = Color3.fromRGB(60, 60, 70)
		stroke.Thickness = 1
		stroke.Parent = frame

		local title = Instance.new("TextLabel")
		title.Size = UDim2.new(1, 0, 0, 24)
		title.BackgroundColor3 = Color3.fromRGB(16, 16, 20)
		title.Text = "COORDENADAS"
		title.TextColor3 = Color3.fromRGB(0, 120, 212)
		title.Font = Enum.Font.GothamBold
		title.TextSize = 10
		title.BorderSizePixel = 0
		title.Parent = frame

		-- Coordenadas atuais
		local coordsLabel = Instance.new("TextLabel")
		coordsLabel.Size = UDim2.new(1, -8, 0, 16)
		coordsLabel.Position = UDim2.new(0, 4, 0, 26)
		coordsLabel.BackgroundTransparency = 1
		coordsLabel.Text = "X: 0  Y: 0  Z: 0"
		coordsLabel.TextColor3 = Color3.fromRGB(235, 235, 240)
		coordsLabel.Font = Enum.Font.RobotoMono
		coordsLabel.TextSize = 9
		coordsLabel.TextXAlignment = Enum.TextXAlignment.Left
		coordsLabel.Parent = frame

		local scroll = Instance.new("ScrollingFrame")
		scroll.Size = UDim2.new(1, -8, 1, -74)
		scroll.Position = UDim2.new(0, 4, 0, 44)
		scroll.BackgroundTransparency = 1
		scroll.ScrollBarThickness = 2
		scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
		scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
		scroll.BorderSizePixel = 0
		scroll.Parent = frame
		Instance.new("UIListLayout", scroll).Padding = UDim.new(0, 3)

		-- Botao salvar
		local saveBtn = Instance.new("TextButton")
		saveBtn.Size = UDim2.new(1, 0, 0, 24)
		saveBtn.Position = UDim2.new(0, 0, 1, -26)
		saveBtn.BackgroundColor3 = Color3.fromRGB(0, 99, 177)
		saveBtn.Text = "+ Salvar Posicao"
		saveBtn.TextColor3 = Color3.new(1, 1, 1)
		saveBtn.Font = Enum.Font.GothamBold
		saveBtn.TextSize = 10
		saveBtn.AutoButtonColor = false
		saveBtn.Parent = frame

		saveBtn.MouseButton1Click:Connect(function()
			local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
			if hrp then
				local pos = hrp.Position
				local name = "Ponto " .. (#CacheCoords.SavedPoints + 1)
				table.insert(CacheCoords.SavedPoints, { Name = name, Position = pos })
				RefreshCoordsList(scroll)
				GH.ShowToast(name .. " salvo: " .. math.floor(pos.X) .. ", " .. math.floor(pos.Y) .. ", " .. math.floor(pos.Z), GH.Theme.On, 2)
			end
		end)

		RefreshCoordsList(scroll)

		-- Loop para atualizar coordenadas
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

		-- Drag pela title bar
		local dragging, dragStart, startPos
		title.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				dragging = true
				dragStart = input.Position
				startPos = frame.Position
				input.Changed:Connect(function()
					if input.UserInputState == Enum.UserInputState.End then dragging = false end
				end)
			end
		end)
		title.InputChanged:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
				dragStart = input.Position
			end
		end)
		GH.Services.UserInputService.InputChanged:Connect(function(input)
			if dragging and input.Position then
				local delta = input.Position - dragStart
				frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
			end
		end)
	end

	GH.RegisterToggleButton("Coords", "toggle_coords", Cheats_ToggleCoords, "Utility", "desc_coords")
end
