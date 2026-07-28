-- =============================================================================
-- COMMAND: SERVER TELEPORT (TP por Job ID / Servidor)
-- Teleporta direto para um servidor especifico usando o Job ID dos logs
-- Suporta teleportar entre jogos diferentes via Place ID
-- =============================================================================
return function(GH)
	local Players = GH.Services.Players
	local TeleportService = game:GetService("TeleportService")
	local TweenService = GH.Services.TweenService
	local RunService = GH.Services.RunService
	local LocalPlayer = GH.LocalPlayer

	local serverGui = nil
	local isOpen = false

	local function createServerTeleportGUI()
		if serverGui then
			serverGui:Destroy()
			serverGui = nil
		end

		local gui = Instance.new("ScreenGui")
		gui.Name = "GH_ServerTeleport"
		gui.ResetOnSpawn = false
		gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
		gui.DisplayOrder = 100
		gui.Parent = GH.TargetGui
		serverGui = gui

		local W = 300
		local H = 200
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
		titlelbl.Text = GH.T("toggle_serverteleport")
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
		content.Size = UDim2.new(1, -16, 1, -TOPBAR - 8)
		content.Position = UDim2.new(0, 8, 0, TOPBAR + 4)
		content.BackgroundTransparency = 1
		content.Parent = frame

		-- Job ID Input
		local jobIdBox = Instance.new("TextBox")
		jobIdBox.Name = "JobIdBox"
		jobIdBox.Size = UDim2.new(1, 0, 0, 30)
		jobIdBox.Position = UDim2.new(0, 0, 0, 0)
		jobIdBox.BackgroundColor3 = Color3.fromRGB(28, 28, 32)
		jobIdBox.PlaceholderText = "Job ID"
		jobIdBox.PlaceholderColor3 = Color3.fromRGB(120, 120, 130)
		jobIdBox.Text = ""
		jobIdBox.TextColor3 = Color3.fromRGB(235, 235, 240)
		jobIdBox.Font = Enum.Font.GothamMedium
		jobIdBox.TextSize = 11
		jobIdBox.TextXAlignment = Enum.TextXAlignment.Left
		jobIdBox.ClearTextOnFocus = false
		jobIdBox.Parent = content
		Instance.new("UICorner", jobIdBox).CornerRadius = UDim.new(0, 4)
		Instance.new("UIPadding", jobIdBox).PaddingLeft = UDim.new(0, 8)

		-- Place ID Input (Opcional)
		local placeIdBox = Instance.new("TextBox")
		placeIdBox.Name = "PlaceIdBox"
		placeIdBox.Size = UDim2.new(1, 0, 0, 30)
		placeIdBox.Position = UDim2.new(0, 0, 0, 36)
		placeIdBox.BackgroundColor3 = Color3.fromRGB(28, 28, 32)
		placeIdBox.PlaceholderText = GH.T("input_serverteleport_placeholder")
		placeIdBox.PlaceholderColor3 = Color3.fromRGB(120, 120, 130)
		placeIdBox.Text = ""
		placeIdBox.TextColor3 = Color3.fromRGB(235, 235, 240)
		placeIdBox.Font = Enum.Font.GothamMedium
		placeIdBox.TextSize = 11
		placeIdBox.TextXAlignment = Enum.TextXAlignment.Left
		placeIdBox.ClearTextOnFocus = false
		placeIdBox.Parent = content
		Instance.new("UICorner", placeIdBox).CornerRadius = UDim.new(0, 4)
		Instance.new("UIPadding", placeIdBox).PaddingLeft = UDim.new(0, 8)

		-- Teleport Button
		local tpBtn = Instance.new("TextButton")
		tpBtn.Name = "TpBtn"
		tpBtn.Size = UDim2.new(1, 0, 0, 32)
		tpBtn.Position = UDim2.new(0, 0, 0, 76)
		tpBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 212)
		tpBtn.Text = GH.T("toggle_serverteleport")
		tpBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
		tpBtn.Font = Enum.Font.GothamBold
		tpBtn.TextSize = 11
		tpBtn.Parent = content
		Instance.new("UICorner", tpBtn).CornerRadius = UDim.new(0, 6)

		tpBtn.MouseEnter:Connect(function()
			TweenService:Create(tpBtn, GH.TI, { BackgroundColor3 = Color3.fromRGB(20, 140, 232) }):Play()
		end)
		tpBtn.MouseLeave:Connect(function()
			TweenService:Create(tpBtn, GH.TI, { BackgroundColor3 = Color3.fromRGB(0, 120, 212) }):Play()
		end)

		-- Status Label
		local statusLbl = Instance.new("TextLabel")
		statusLbl.Name = "Status"
		statusLbl.Size = UDim2.new(1, 0, 0, 20)
		statusLbl.Position = UDim2.new(0, 0, 0, 116)
		statusLbl.BackgroundTransparency = 1
		statusLbl.Text = GH.T("input_serverteleport_status")
		statusLbl.TextColor3 = Color3.fromRGB(150, 150, 160)
		statusLbl.Font = Enum.Font.Gotham
		statusLbl.TextSize = 10
		statusLbl.Parent = content

		-- Teleport Logic
		tpBtn.MouseButton1Click:Connect(function()
			local rawJobId = jobIdBox.Text
			local rawPlaceId = placeIdBox.Text

			if rawJobId == "" or rawJobId:match("^%s*$") then
				statusLbl.Text = GH.T("toast_serverteleport_error")
				statusLbl.TextColor3 = Color3.fromRGB(255, 80, 80)
				return
			end

			local cleanJobId = rawJobId:match("^%s*(.-)%s*$")
			local targetPlaceId = tonumber(rawPlaceId) or game.PlaceId

			if targetPlaceId == game.PlaceId then
				-- Mesmo jogo: entra direto no JobID
				statusLbl.Text = GH.T("toast_serverteleport_connecting")
				statusLbl.TextColor3 = Color3.fromRGB(0, 200, 100)

				pcall(function()
					TeleportService:TeleportToPlaceInstance(targetPlaceId, cleanJobId, LocalPlayer)
				end)
			else
				-- Jogo diferente: agenda a entrada do JobID
				statusLbl.Text = GH.T("toast_serverteleport_queueing")
				statusLbl.TextColor3 = Color3.fromRGB(255, 180, 0)

				local queueFunc = (queue_on_teleport or (syn and syn.queue_on_teleport))
				if queueFunc then
					queueFunc(string.format([[
						repeat task.wait() until game:IsLoaded()
						local TS = game:GetService("TeleportService")
						local LP = game:GetService("Players").LocalPlayer
						TS:TeleportToPlaceInstance(%d, "%s", LP)
					]], targetPlaceId, cleanJobId))
				end

				pcall(function()
					TeleportService:Teleport(targetPlaceId, LocalPlayer)
				end)
			end
		end)

		-- Close
		closeBtn.MouseButton1Click:Connect(function()
			isOpen = false
			GH.States.ServerTeleport = false
			serverGui:Destroy()
			serverGui = nil
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

	function Cheats_ToggleServerTeleport(state, btn)
		if state then
			if isOpen then return end
			isOpen = true
			createServerTeleportGUI()
		else
			if serverGui then
				serverGui:Destroy()
				serverGui = nil
			end
			isOpen = false
		end
	end

	GH.RegisterToggleButton("ServerTeleport", "toggle_serverteleport", Cheats_ToggleServerTeleport, "Utility", "desc_serverteleport")
end
