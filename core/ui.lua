-- =============================================================================
-- UI — Initialize (construcao da janela principal Win11)
-- =============================================================================
return function(GH, services)
local Players = services.Players
local RunService = services.RunService
local UserInputService = services.UserInputService
local TweenService = services.TweenService
local Lighting = services.Lighting
local HttpService = services.HttpService
local LocalPlayer = GH.LocalPlayer

function GH.Initialize()
	-- Limpar GUI antiga
	if GH.TargetGui:FindFirstChild("SystemScript") then
		GH.TargetGui["SystemScript"]:Destroy()
	end

	-- ==========================================
	-- THEME WIN11
	-- ==========================================
	local W11 = {
		BG = Color3.fromRGB(18, 18, 22),
		BGAlt = Color3.fromRGB(22, 22, 26),
		Surface = Color3.fromRGB(28, 28, 32),
		SurfaceHover = Color3.fromRGB(38, 38, 42),
		SurfaceActive = Color3.fromRGB(42, 42, 46),
		Accent = Color3.fromRGB(0, 120, 212),
		AccentDark = Color3.fromRGB(0, 99, 177),
		AccentGlow = Color3.fromRGB(0, 150, 255),
		On = Color3.fromRGB(0, 120, 212),
		OnBG = Color3.fromRGB(10, 35, 60),
		Off = Color3.fromRGB(180, 180, 190),
		OffBG = Color3.fromRGB(35, 35, 40),
		Text = Color3.fromRGB(235, 235, 240),
		TextSecondary = Color3.fromRGB(140, 140, 155),
		TextMuted = Color3.fromRGB(90, 90, 105),
		Border = Color3.fromRGB(50, 50, 58),
		BorderSubtle = Color3.fromRGB(40, 40, 48),
		Red = Color3.fromRGB(255, 60, 60),
		RedHover = Color3.fromRGB(255, 80, 80),
	}
	GH.Theme = W11

	local Font = Enum.Font.GothamMedium
	local FontBold = Enum.Font.GothamBold

	-- ==========================================
	-- SCREEN GUI
	-- ==========================================
	local ScreenGui = Instance.new("ScreenGui")
	ScreenGui.Name = "SystemScript"
	ScreenGui.ResetOnSpawn = false
	ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	ScreenGui.DisplayOrder = 10
	ScreenGui.Parent = GH.TargetGui
	GH.ScreenGui = ScreenGui

	-- ==========================================
	-- DIMENSIONS
	-- ==========================================
	local PanelW = 560
	local PanelH = 400
	local TopbarH = 32
	local SidebarW = 130
	local BtnH = 30

	-- ==========================================
	-- MAIN FRAME
	-- ==========================================
	local MainFrame = Instance.new("Frame")
	MainFrame.Name = "MainFrame"
	MainFrame.Size = UDim2.new(0, PanelW, 0, PanelH)
	MainFrame.Position = UDim2.new(0.5, -PanelW / 2, 0.5, -PanelH / 2)
	MainFrame.BackgroundColor3 = W11.BG
	MainFrame.BorderSizePixel = 0
	MainFrame.ClipsDescendants = true
	MainFrame.Parent = ScreenGui
	Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 10)
	local mainStroke = Instance.new("UIStroke")
	mainStroke.Color = Color3.fromRGB(60, 60, 70)
	mainStroke.Thickness = 1
	mainStroke.Transparency = 0.2
	mainStroke.Parent = MainFrame

-- ==========================================
-- FPS COUNTER
-- ==========================================
local FPSLabel = Instance.new("TextLabel")
FPSLabel.Name = "FPSCounter"
FPSLabel.Size = UDim2.new(0, 80, 0, 16)
FPSLabel.Position = UDim2.new(0, 8, 1, -22)
FPSLabel.BackgroundTransparency = 1
FPSLabel.Text = "FPS: --"
FPSLabel.TextColor3 = Color3.fromRGB(100, 100, 115)
FPSLabel.Font = Enum.Font.RobotoMono
FPSLabel.TextSize = 9
FPSLabel.TextXAlignment = Enum.TextXAlignment.Left
FPSLabel.ZIndex = 3
FPSLabel.Parent = MainFrame

-- ==========================================
-- NICKNAME (Rainbow) - by @FiascoPlays
-- ==========================================
local NickLabel = Instance.new("TextLabel")
NickLabel.Name = "NickLabel"
NickLabel.Size = UDim2.new(0, 120, 0, 16)
NickLabel.Position = UDim2.new(0, 50, 1, -22)
NickLabel.BackgroundTransparency = 1
NickLabel.Text = "by: @FiascoPlays"
NickLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
NickLabel.Font = Enum.Font.GothamBold
NickLabel.TextSize = 9
NickLabel.TextXAlignment = Enum.TextXAlignment.Left
NickLabel.ZIndex = 3
NickLabel.Parent = MainFrame

-- Rainbow color cycle for nickname
local nickHue = 0
task.spawn(function()
	while not GH.Stopped and not GH.isClosing do
		nickHue = nickHue + 0.008
		if nickHue > 1 then nickHue = nickHue - 1 end
		local color = Color3.fromHSV(nickHue, 0.85, 1)
		NickLabel.TextColor3 = color
		task.wait(0.03)
	end
end)

local fpsFrames = 0
local fpsLastUpdate = os.clock()
RunService.RenderStepped:Connect(function()
	fpsFrames += 1
	local now = os.clock()
	if now - fpsLastUpdate >= 1 then
		local fps = math.floor(fpsFrames / (now - fpsLastUpdate) + 0.5)
		FPSLabel.Text = "FPS: " .. fps
		if fps >= 50 then
			FPSLabel.TextColor3 = Color3.fromRGB(80, 200, 120)
		elseif fps >= 30 then
			FPSLabel.TextColor3 = Color3.fromRGB(200, 180, 80)
		else
			FPSLabel.TextColor3 = Color3.fromRGB(255, 80, 80)
		end
		fpsFrames = 0
		fpsLastUpdate = now
	end
end)

	-- ==========================================
	-- TOPBAR
	-- ==========================================
	local Topbar = Instance.new("Frame")
	Topbar.Name = "Topbar"
	Topbar.Size = UDim2.new(1, 0, 0, TopbarH)
	Topbar.BackgroundColor3 = Color3.fromRGB(16, 16, 20)
	Topbar.BorderSizePixel = 0
	Topbar.ZIndex = 2
	Topbar.Parent = MainFrame

	local TitleLabel = Instance.new("TextLabel")
	TitleLabel.Size = UDim2.new(1, -360, 1, 0)
	TitleLabel.Position = UDim2.new(0, 14, 0, 0)
	TitleLabel.BackgroundTransparency = 1
	TitleLabel.Text = "SYSTEM SCRIPT"
	TitleLabel.TextColor3 = W11.Accent
	TitleLabel.Font = FontBold
	TitleLabel.TextSize = 11
	TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
	TitleLabel.ZIndex = 3
	TitleLabel.Parent = Topbar

	-- ==========================================
	-- LIVE INDICATOR
	-- ==========================================
	local LiveContainer = Instance.new("Frame")
	LiveContainer.Name = "LiveContainer"
	LiveContainer.Size = UDim2.new(0, 220, 0, 20)
	LiveContainer.Position = UDim2.new(1, -340, 0.5, -10)
	LiveContainer.BackgroundTransparency = 1
	LiveContainer.ZIndex = 3
	LiveContainer.Parent = Topbar

	local LiveDot = Instance.new("Frame")
	LiveDot.Name = "LiveDot"
	LiveDot.Size = UDim2.new(0, 6, 0, 6)
	LiveDot.Position = UDim2.new(0, 0, 0.5, -3)
	LiveDot.BackgroundColor3 = Color3.fromRGB(255, 70, 70)
	LiveDot.BackgroundTransparency = 0
	LiveDot.BorderSizePixel = 0
	LiveDot.ZIndex = 4
	LiveDot.Parent = LiveContainer
	Instance.new("UICorner", LiveDot).CornerRadius = UDim.new(1, 0)

	local LiveGlow = Instance.new("Frame")
	LiveGlow.Name = "LiveGlow"
	LiveGlow.Size = UDim2.new(0, 10, 0, 10)
	LiveGlow.Position = UDim2.new(0, -2, 0.5, -5)
	LiveGlow.BackgroundColor3 = Color3.fromRGB(255, 70, 70)
	LiveGlow.BackgroundTransparency = 0.7
	LiveGlow.BorderSizePixel = 0
	LiveGlow.ZIndex = 3
	LiveGlow.Parent = LiveContainer
	Instance.new("UICorner", LiveGlow).CornerRadius = UDim.new(1, 0)

	local LiveLabel = Instance.new("TextLabel")
	LiveLabel.Name = "LiveLabel"
	LiveLabel.Size = UDim2.new(0, 44, 1, 0)
	LiveLabel.Position = UDim2.new(0, 12, 0, 0)
	LiveLabel.BackgroundTransparency = 1
	LiveLabel.Text = GH.T("stats_live")
	LiveLabel.TextColor3 = Color3.fromRGB(255, 70, 70)
	LiveLabel.Font = FontBold
	LiveLabel.TextSize = 8
	LiveLabel.TextXAlignment = Enum.TextXAlignment.Left
	LiveLabel.ZIndex = 4
	LiveLabel.Parent = LiveContainer

	local OnlineIcon = Instance.new("TextLabel")
	OnlineIcon.Name = "OnlineIcon"
	OnlineIcon.Size = UDim2.new(0, 10, 1, 0)
	OnlineIcon.Position = UDim2.new(0, 60, 0, 0)
	OnlineIcon.BackgroundTransparency = 1
	OnlineIcon.Text = "●"
	OnlineIcon.TextColor3 = Color3.fromRGB(0, 200, 100)
	OnlineIcon.Font = Enum.Font.SourceSans
	OnlineIcon.TextSize = 8
	OnlineIcon.ZIndex = 4
	OnlineIcon.Parent = LiveContainer

	local OnlineLabel = Instance.new("TextLabel")
	OnlineLabel.Name = "OnlineLabel"
	OnlineLabel.Size = UDim2.new(0, 40, 1, 0)
	OnlineLabel.Position = UDim2.new(0, 70, 0, 0)
	OnlineLabel.BackgroundTransparency = 1
	OnlineLabel.Text = GH.T("stats_online_label")
	OnlineLabel.TextColor3 = W11.TextSecondary
	OnlineLabel.Font = Font
	OnlineLabel.TextSize = 8
	OnlineLabel.TextXAlignment = Enum.TextXAlignment.Left
	OnlineLabel.ZIndex = 4
	OnlineLabel.Parent = LiveContainer

	local OnlineValue = Instance.new("TextLabel")
	OnlineValue.Name = "OnlineValue"
	OnlineValue.Size = UDim2.new(0, 30, 1, 0)
	OnlineValue.Position = UDim2.new(0, 106, 0, 0)
	OnlineValue.BackgroundTransparency = 1
	OnlineValue.Text = "0"
	OnlineValue.TextColor3 = Color3.fromRGB(0, 200, 100)
	OnlineValue.Font = FontBold
	OnlineValue.TextSize = 9
	OnlineValue.TextXAlignment = Enum.TextXAlignment.Left
	OnlineValue.ZIndex = 4
	OnlineValue.Parent = LiveContainer

	GH._LiveIndicators = { OnlineValue = OnlineValue }

	-- Live dot pulse animation
	task.spawn(function()
		while not GH.Stopped and not GH.isClosing do
			TweenService:Create(LiveDot, TweenInfo.new(0.8, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
				BackgroundTransparency = 0,
				Size = UDim2.new(0, 8, 0, 8),
			}):Play()
			TweenService:Create(LiveGlow, TweenInfo.new(0.8, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
				BackgroundTransparency = 0.3,
				Size = UDim2.new(0, 14, 0, 14),
				Position = UDim2.new(0, -4, 0.5, -7),
			}):Play()
			task.wait(0.8)
			TweenService:Create(LiveDot, TweenInfo.new(0.8, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
				BackgroundTransparency = 0.5,
				Size = UDim2.new(0, 6, 0, 6),
			}):Play()
			TweenService:Create(LiveGlow, TweenInfo.new(0.8, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
				BackgroundTransparency = 0.7,
				Size = UDim2.new(0, 10, 0, 10),
				Position = UDim2.new(0, -2, 0.5, -5),
			}):Play()
			task.wait(0.8)
		end
	end)

	-- ==========================================
	-- TOPBAR BUTTONS (Win11 style)
	-- ==========================================
	local BTN_SIZE = 24

	local CloseBtn = Instance.new("TextButton")
	CloseBtn.Name = "Close"
	CloseBtn.Size = UDim2.new(0, BTN_SIZE, 0, BTN_SIZE)
	CloseBtn.Position = UDim2.new(1, -BTN_SIZE - 8, 0.5, -BTN_SIZE / 2)
	CloseBtn.BackgroundColor3 = W11.Surface
	CloseBtn.Text = ""
	CloseBtn.AutoButtonColor = false
	CloseBtn.ZIndex = 4
	CloseBtn.Parent = Topbar
	Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 4)
	local CloseBtnX = Instance.new("TextLabel")
	CloseBtnX.Size = UDim2.new(1, 0, 1, 0)
	CloseBtnX.BackgroundTransparency = 1
	CloseBtnX.Text = "X"
	CloseBtnX.TextColor3 = W11.Text
	CloseBtnX.Font = Enum.Font.SourceSans
	CloseBtnX.TextSize = 16
	CloseBtnX.ZIndex = 5
	CloseBtnX.Parent = CloseBtn

	local MinBtn = Instance.new("TextButton")
	MinBtn.Name = "Minimize"
	MinBtn.Size = UDim2.new(0, BTN_SIZE, 0, BTN_SIZE)
	MinBtn.Position = UDim2.new(1, -BTN_SIZE * 2 - 14, 0.5, -BTN_SIZE / 2)
	MinBtn.BackgroundColor3 = W11.Surface
	MinBtn.Text = ""
	MinBtn.AutoButtonColor = false
	MinBtn.ZIndex = 4
	MinBtn.Parent = Topbar
	Instance.new("UICorner", MinBtn).CornerRadius = UDim.new(0, 4)
	local MinBtnDash = Instance.new("TextLabel")
	MinBtnDash.Size = UDim2.new(1, 0, 1, 0)
	MinBtnDash.BackgroundTransparency = 1
	MinBtnDash.Text = "-"
	MinBtnDash.TextColor3 = W11.TextSecondary
	MinBtnDash.Font = Enum.Font.SourceSans
	MinBtnDash.TextSize = 16
	MinBtnDash.ZIndex = 5
	MinBtnDash.Parent = MinBtn

	local ReloadBtn = Instance.new("TextButton")
	ReloadBtn.Name = "Reload"
	ReloadBtn.Size = UDim2.new(0, BTN_SIZE, 0, BTN_SIZE)
	ReloadBtn.Position = UDim2.new(1, -BTN_SIZE * 3 - 20, 0.5, -BTN_SIZE / 2)
	ReloadBtn.BackgroundColor3 = W11.Surface
	ReloadBtn.Text = ""
	ReloadBtn.AutoButtonColor = false
	ReloadBtn.ZIndex = 4
	ReloadBtn.Parent = Topbar
	Instance.new("UICorner", ReloadBtn).CornerRadius = UDim.new(0, 4)
	local ReloadBtnIcon = Instance.new("TextLabel")
	ReloadBtnIcon.Size = UDim2.new(1, 0, 1, 0)
	ReloadBtnIcon.BackgroundTransparency = 1
	ReloadBtnIcon.Text = "R"
	ReloadBtnIcon.TextColor3 = W11.TextSecondary
	ReloadBtnIcon.Font = Enum.Font.SourceSans
	ReloadBtnIcon.TextSize = 16
	ReloadBtnIcon.ZIndex = 5
	ReloadBtnIcon.Parent = ReloadBtn

	ReloadBtn.MouseEnter:Connect(function()
		TweenService:Create(ReloadBtn, GH.TI, { BackgroundColor3 = W11.AccentDark }):Play()
		TweenService:Create(ReloadBtnIcon, GH.TI, { TextColor3 = W11.AccentGlow }):Play()
	end)
	ReloadBtn.MouseLeave:Connect(function()
		TweenService:Create(ReloadBtn, GH.TI, { BackgroundColor3 = W11.Surface }):Play()
		TweenService:Create(ReloadBtnIcon, GH.TI, { TextColor3 = W11.TextSecondary }):Play()
	end)
	ReloadBtn.MouseButton1Click:Connect(function()
		task.spawn(function()
			pcall(function()
				game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer)
			end)
		end)
		GH.ShowToast(GH.T("toast_reloading") or "Reiniciando servidor...", W11.Accent, 3)
	end)

	-- ==========================================
	-- SIDEBAR
	-- ==========================================
	local Sidebar = Instance.new("Frame")
	Sidebar.Name = "Sidebar"
	Sidebar.Size = UDim2.new(0, SidebarW, 1, -TopbarH)
	Sidebar.Position = UDim2.new(0, 0, 0, TopbarH)
	Sidebar.BackgroundColor3 = Color3.fromRGB(14, 14, 17)
	Sidebar.BorderSizePixel = 0
	Sidebar.ZIndex = 2
	Sidebar.ClipsDescendants = true
	Sidebar.Parent = MainFrame

	local AccentBar = Instance.new("Frame")
	AccentBar.Name = "AccentBar"
	AccentBar.Size = UDim2.new(0, 2, 1, -TopbarH)
	AccentBar.Position = UDim2.new(0, 0, 0, TopbarH)
	AccentBar.BackgroundColor3 = W11.Accent
	AccentBar.BackgroundTransparency = 0.6
	AccentBar.BorderSizePixel = 0
	AccentBar.ZIndex = 3
	AccentBar.Parent = MainFrame

	local SidebarBorder = Instance.new("Frame")
	SidebarBorder.Name = "SidebarBorder"
	SidebarBorder.Size = UDim2.new(0, 1, 1, -TopbarH)
	SidebarBorder.Position = UDim2.new(0, SidebarW - 1, 0, TopbarH)
	SidebarBorder.BackgroundColor3 = W11.Border
	SidebarBorder.BackgroundTransparency = 0.5
	SidebarBorder.BorderSizePixel = 0
	SidebarBorder.ZIndex = 3
	SidebarBorder.Parent = MainFrame

	local SidebarLayout = Instance.new("UIListLayout")
	SidebarLayout.SortOrder = Enum.SortOrder.LayoutOrder
	SidebarLayout.Padding = UDim.new(0, 3)
	SidebarLayout.Parent = Sidebar
	Instance.new("UIPadding", Sidebar).PaddingLeft = UDim.new(0, 6)
	Instance.new("UIPadding", Sidebar).PaddingTop = UDim.new(0, 6)

	-- ==========================================
	-- CONTENT AREA
	-- ==========================================
	local Content = Instance.new("Frame")
	Content.Name = "Content"
	Content.Size = UDim2.new(1, -(SidebarW + 2), 1, -(TopbarH + 8))
	Content.Position = UDim2.new(0, SidebarW + 1, 0, TopbarH + 4)
	Content.BackgroundTransparency = 1
	Content.ZIndex = 2
	Content.Parent = MainFrame
	Instance.new("UIPadding", Content).PaddingLeft = UDim.new(0, 4)
	Instance.new("UIPadding", Content).PaddingRight = UDim.new(0, 4)

	-- ==========================================
	-- SETTINGS TAB
	-- ==========================================
	local SettingsContainer = Instance.new("ScrollingFrame")
	SettingsContainer.Name = "Tab_Settings"
	SettingsContainer.Size = UDim2.new(1, 0, 1, -30)
	SettingsContainer.Position = UDim2.new(0, 0, 0, 30)
	SettingsContainer.BackgroundTransparency = 1
	SettingsContainer.ScrollBarThickness = 3
	SettingsContainer.ScrollBarImageColor3 = W11.Accent
	SettingsContainer.AutomaticCanvasSize = Enum.AutomaticSize.Y
	SettingsContainer.CanvasSize = UDim2.new(0, 0, 0, 0)
	SettingsContainer.BorderSizePixel = 0
	SettingsContainer.Visible = false
	SettingsContainer.ZIndex = 3
	SettingsContainer.Parent = Content
	Instance.new("UIListLayout", SettingsContainer).Padding = UDim.new(0, 3)
	SettingsContainer.UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
	Instance.new("UIPadding", SettingsContainer).PaddingTop = UDim.new(0, 2)

	-- ==========================================
	-- SIDEBAR TABS + CONTENT TABS
	-- ==========================================
	local Categories = GH.Categories
	local TabContainers = {}
	local TabAPIs = {}
	local TabButtons = {}
	local ActiveTab = "Combat"

	for _, cat in ipairs(Categories) do
		local btn = Instance.new("TextButton")
		btn.Name = cat.Name
		btn.Size = UDim2.new(1, -4, 0, 30)
		btn.BackgroundColor3 = (cat.Name == ActiveTab) and Color3.fromRGB(10, 35, 60) or Color3.fromRGB(30, 30, 36)
		btn.Text = "  " .. cat.Name
		btn.TextColor3 = (cat.Name == ActiveTab) and W11.Accent or Color3.fromRGB(200, 200, 210)
		btn.Font = FontBold
		btn.TextSize = 11
		btn.TextXAlignment = Enum.TextXAlignment.Left
		btn.AutoButtonColor = false
		btn.LayoutOrder = cat.Order
		btn.ZIndex = 5
		btn.Parent = Sidebar
		Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 5)

		local indicator = Instance.new("Frame")
		indicator.Name = "Indicator"
		indicator.Size = UDim2.new(0, 2, 0, 16)
		indicator.Position = UDim2.new(0, 0, 0.5, -8)
		indicator.BackgroundColor3 = W11.Accent
		indicator.BorderSizePixel = 0
		indicator.ZIndex = 6
		indicator.Visible = (cat.Name == ActiveTab)
		indicator.Parent = btn

		btn.MouseEnter:Connect(function()
			if ActiveTab ~= cat.Name then
				TweenService:Create(btn, GH.TI, { BackgroundColor3 = Color3.fromRGB(40, 40, 48) }):Play()
				TweenService:Create(btn, GH.TI, { TextColor3 = Color3.fromRGB(235, 235, 240) }):Play()
			end
		end)
		btn.MouseLeave:Connect(function()
			if ActiveTab ~= cat.Name then
				TweenService:Create(btn, GH.TI, { BackgroundColor3 = Color3.fromRGB(30, 30, 36) }):Play()
				TweenService:Create(btn, GH.TI, { TextColor3 = Color3.fromRGB(200, 200, 210) }):Play()
			end
		end)

		local container
		if cat.Name == "Settings" then
			container = SettingsContainer
			container.Visible = false
		else
			container = Instance.new("ScrollingFrame")
			container.Name = "Tab_" .. cat.Name
			container.Size = UDim2.new(1, 0, 1, -30)
			container.Position = UDim2.new(0, 0, 0, 30)
			container.BackgroundTransparency = 1
			container.ScrollBarThickness = 3
			container.ScrollBarImageColor3 = W11.Accent
			container.AutomaticCanvasSize = Enum.AutomaticSize.Y
			container.CanvasSize = UDim2.new(0, 0, 0, 0)
			container.BorderSizePixel = 0
			container.Visible = (cat.Name == ActiveTab)
			container.ZIndex = 3
			container.Parent = Content
			Instance.new("UIListLayout", container).Padding = UDim.new(0, 3)
			container.UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
			Instance.new("UIPadding", container).PaddingTop = UDim.new(0, 2)
		end

		TabContainers[cat.Name] = container

		btn.MouseButton1Click:Connect(function()
			if ActiveTab == cat.Name then return end
			if TabContainers[ActiveTab] then TabContainers[ActiveTab].Visible = false end
			if TabButtons[ActiveTab] then
				TweenService:Create(TabButtons[ActiveTab], GH.TI, { BackgroundColor3 = Color3.fromRGB(30, 30, 36), TextColor3 = Color3.fromRGB(200, 200, 210) }):Play()
				local oldIndicator = TabButtons[ActiveTab]:FindFirstChild("Indicator")
				if oldIndicator then oldIndicator.Visible = false end
			end
			ActiveTab = cat.Name
			if TabContainers[ActiveTab] then TabContainers[ActiveTab].Visible = true end
			TweenService:Create(btn, GH.TI, { BackgroundColor3 = Color3.fromRGB(10, 35, 60), TextColor3 = W11.Accent }):Play()
			indicator.Visible = true
		end)

		TabButtons[cat.Name] = btn
	end

	-- ==========================================
	-- SEARCH BAR
	-- ==========================================
	local SearchBar = Instance.new("TextBox")
	SearchBar.Name = "SearchBar"
	SearchBar.Size = UDim2.new(1, -32, 0, 28)
	SearchBar.Position = UDim2.new(0, 0, 0, 0)
	SearchBar.BackgroundColor3 = Color3.fromRGB(28, 28, 32)
	SearchBar.PlaceholderText = GH.T("search_placeholder") or "Search command..."
	SearchBar.PlaceholderColor3 = Color3.fromRGB(90, 90, 105)
	SearchBar.Text = ""
	SearchBar.TextColor3 = W11.Text
	SearchBar.Font = Font
	SearchBar.TextSize = 11
	SearchBar.TextXAlignment = Enum.TextXAlignment.Left
	SearchBar.ClearTextOnFocus = false
	SearchBar.ZIndex = 10
	SearchBar.Parent = Content
	Instance.new("UICorner", SearchBar).CornerRadius = UDim.new(0, 6)
	Instance.new("UIPadding", SearchBar).PaddingLeft = UDim.new(0, 8)

	local SearchClear = Instance.new("TextButton")
	SearchClear.Name = "ClearBtn"
	SearchClear.Size = UDim2.new(0, 22, 0, 22)
	SearchClear.Position = UDim2.new(1, -26, 0.5, -11)
	SearchClear.BackgroundColor3 = Color3.fromRGB(50, 50, 58)
	SearchClear.Text = ""
	SearchClear.AutoButtonColor = false
	SearchClear.Visible = false
	SearchClear.ZIndex = 11
	SearchClear.Parent = SearchBar
	Instance.new("UICorner", SearchClear).CornerRadius = UDim.new(0, 4)
	local ClearX = Instance.new("TextLabel")
	ClearX.Size = UDim2.new(1, 0, 1, 0)
	ClearX.BackgroundTransparency = 1
	ClearX.Text = "X"
	ClearX.TextColor3 = W11.TextSecondary
	ClearX.Font = Enum.Font.SourceSans
	ClearX.TextSize = 12
	ClearX.ZIndex = 12
	ClearX.Parent = SearchClear
	SearchClear.MouseEnter:Connect(function()
		TweenService:Create(ClearX, GH.TI, { TextColor3 = W11.Red }):Play()
	end)
	SearchClear.MouseLeave:Connect(function()
		TweenService:Create(ClearX, GH.TI, { TextColor3 = W11.TextSecondary }):Play()
	end)

	SearchBar.Focused:Connect(function()
		TweenService:Create(SearchBar, GH.TI, { BackgroundColor3 = Color3.fromRGB(35, 35, 42) }):Play()
	end)
	SearchBar.FocusLost:Connect(function()
		TweenService:Create(SearchBar, GH.TI, { BackgroundColor3 = Color3.fromRGB(28, 28, 32) }):Play()
	end)

	GH.Tabs = TabAPIs

	-- ==========================================
	-- SEARCH FILTER
	-- ==========================================
	local PreviousActiveTab = ActiveTab

	local function FilterToggles(text)
		local search = text:lower():gsub("%s+", "")
		local totalMatches = 0
		local firstMatchTab = nil
		local isSearching = (search ~= "")

		for catName, container in pairs(TabContainers) do
			if catName ~= "Settings" then
				for _, child in ipairs(container:GetChildren()) do
					if child:IsA("TextButton") then
						local label = child:FindFirstChild("GH_ToggleLabel")
						local desc = child:FindFirstChild("GH_DescLabel")
						if label then
							local cmdName = label.Text:lower():gsub("%s+", "")
							local cmdDesc = desc and desc.Text:lower():gsub("%s+", "") or ""
							local match = (search == "") or cmdName:find(search, 1, true) or cmdDesc:find(search, 1, true)
							child.Visible = match
							if match and search ~= "" then
								totalMatches = totalMatches + 1
								if not firstMatchTab then firstMatchTab = catName end
							end
						end
					end
				end
			end
		end

		if isSearching and firstMatchTab and firstMatchTab ~= ActiveTab then
			PreviousActiveTab = ActiveTab
			if TabContainers[ActiveTab] then TabContainers[ActiveTab].Visible = false end
			if TabButtons[ActiveTab] then
				TweenService:Create(TabButtons[ActiveTab], GH.TI, { BackgroundColor3 = Color3.fromRGB(30, 30, 36), TextColor3 = Color3.fromRGB(200, 200, 210) }):Play()
				local oldIndicator = TabButtons[ActiveTab]:FindFirstChild("Indicator")
				if oldIndicator then oldIndicator.Visible = false end
			end
			ActiveTab = firstMatchTab
			if TabContainers[ActiveTab] then TabContainers[ActiveTab].Visible = true end
			if TabButtons[ActiveTab] then
				TweenService:Create(TabButtons[ActiveTab], GH.TI, { BackgroundColor3 = Color3.fromRGB(10, 35, 60), TextColor3 = W11.Accent }):Play()
				local newIndicator = TabButtons[ActiveTab]:FindFirstChild("Indicator")
				if newIndicator then newIndicator.Visible = true end
			end
			Sidebar.Visible = true
			Content.Visible = true
		end

		if not isSearching and PreviousActiveTab and PreviousActiveTab ~= ActiveTab then
			if TabContainers[ActiveTab] then TabContainers[ActiveTab].Visible = false end
			if TabButtons[ActiveTab] then
				TweenService:Create(TabButtons[ActiveTab], GH.TI, { BackgroundColor3 = Color3.fromRGB(30, 30, 36), TextColor3 = Color3.fromRGB(200, 200, 210) }):Play()
				local oldIndicator = TabButtons[ActiveTab]:FindFirstChild("Indicator")
				if oldIndicator then oldIndicator.Visible = false end
			end
			ActiveTab = PreviousActiveTab
			if TabContainers[ActiveTab] then TabContainers[ActiveTab].Visible = true end
			if TabButtons[ActiveTab] then
				TweenService:Create(TabButtons[ActiveTab], GH.TI, { BackgroundColor3 = Color3.fromRGB(10, 35, 60), TextColor3 = W11.Accent }):Play()
				local newIndicator = TabButtons[ActiveTab]:FindFirstChild("Indicator")
				if newIndicator then newIndicator.Visible = true end
			end
		end
	end

	SearchBar:GetPropertyChangedSignal("Text"):Connect(function()
		SearchClear.Visible = (SearchBar.Text ~= "")
		FilterToggles(SearchBar.Text)
	end)

	SearchClear.MouseButton1Click:Connect(function()
		SearchBar.Text = ""
		SearchClear.Visible = false
		FilterToggles("")
	end)

	-- ==========================================
	-- FLUENT-LIKE API for TabContainers
	-- ==========================================
	local function WireTabAPI(api)
		local container = api._frame
		local orderCounter = 0

		function api:AddDropdown(id, config)
			orderCounter += 1
			local frame = Instance.new("Frame")
			frame.Name = id
			frame.Size = UDim2.new(1, 0, 0, 38)
			frame.BackgroundColor3 = W11.Surface
			frame.BorderSizePixel = 0
			frame.LayoutOrder = orderCounter * 100
			frame.ZIndex = 4
			frame.Parent = container
			Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 5)

			local title = Instance.new("TextLabel")
			title.Size = UDim2.new(0.6, 0, 0, 14)
			title.Position = UDim2.new(0, 10, 0, 4)
			title.BackgroundTransparency = 1
			title.Text = config.Title or id
			title.TextColor3 = W11.TextSecondary
			title.Font = Font
			title.TextSize = 10
			title.TextXAlignment = Enum.TextXAlignment.Left
			title.ZIndex = 5
			title.Parent = frame

			local dropBtn = Instance.new("TextButton")
			dropBtn.Size = UDim2.new(0.38, -6, 0, 22)
			dropBtn.Position = UDim2.new(0.6, 4, 0, 8)
			dropBtn.BackgroundColor3 = W11.OffBG
			dropBtn.Text = "  Select..."
			dropBtn.TextColor3 = W11.TextMuted
			dropBtn.Font = Font
			dropBtn.TextSize = 10
			dropBtn.TextXAlignment = Enum.TextXAlignment.Left
			dropBtn.AutoButtonColor = false
			dropBtn.ZIndex = 5
			dropBtn.Parent = frame
			Instance.new("UICorner", dropBtn).CornerRadius = UDim.new(0, 4)

			local arrow = Instance.new("TextLabel")
			arrow.Size = UDim2.new(0, 14, 1, 0)
			arrow.Position = UDim2.new(1, -16, 0, 0)
			arrow.BackgroundTransparency = 1
			arrow.Text = "▼"
			arrow.TextColor3 = W11.TextMuted
			arrow.Font = Font
			arrow.TextSize = 8
			arrow.ZIndex = 6
			arrow.Parent = dropBtn

			local listFrame = Instance.new("Frame")
			listFrame.Name = "DropdownList"
			listFrame.Size = UDim2.new(0, dropBtn.AbsoluteSize.X, 0, 0)
			listFrame.Position = UDim2.new(0.6, 4, 0, 32)
			listFrame.BackgroundColor3 = W11.Surface
			listFrame.BorderSizePixel = 0
			listFrame.ClipsDescendants = true
			listFrame.ZIndex = 20
			listFrame.Visible = false
			listFrame.Parent = frame
			Instance.new("UICorner", listFrame).CornerRadius = UDim.new(0, 4)
			local listStroke = Instance.new("UIStroke")
			listStroke.Color = W11.Border
			listStroke.Thickness = 1
			listStroke.Parent = listFrame

			local listScroll = Instance.new("ScrollingFrame")
			listScroll.Size = UDim2.new(1, -4, 1, -4)
			listScroll.Position = UDim2.new(0, 2, 0, 2)
			listScroll.BackgroundTransparency = 1
			listScroll.ScrollBarThickness = 2
			listScroll.ScrollBarImageColor3 = W11.Accent
			listScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
			listScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
			listScroll.BorderSizePixel = 0
			listScroll.ZIndex = 21
			listScroll.Parent = listFrame
			Instance.new("UIListLayout", listScroll).Padding = UDim.new(0, 1)
			listScroll.UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder

			local dropdownObj = {
				Value = nil,
				_values = config.Values or {},
				_callbacks = {},
				_listFrame = listFrame,
				_dropBtn = dropBtn,
				_title = title,
			}

			local function buildList(values)
				for _, child in ipairs(listScroll:GetChildren()) do
					if child:IsA("TextButton") then child:Destroy() end
				end
				for i, val in ipairs(values) do
					local opt = Instance.new("TextButton")
					opt.Name = val
					opt.Size = UDim2.new(1, 0, 0, 24)
					opt.BackgroundColor3 = W11.Surface
					opt.Text = "  " .. tostring(val)
					opt.TextColor3 = W11.TextSecondary
					opt.Font = Font
					opt.TextSize = 10
					opt.TextXAlignment = Enum.TextXAlignment.Left
					opt.AutoButtonColor = false
					opt.LayoutOrder = i
					opt.ZIndex = 22
					opt.Parent = listScroll
					Instance.new("UICorner", opt).CornerRadius = UDim.new(0, 3)

					opt.MouseEnter:Connect(function()
						TweenService:Create(opt, GH.TI, { BackgroundColor3 = W11.SurfaceHover }):Play()
					end)
					opt.MouseLeave:Connect(function()
						TweenService:Create(opt, GH.TI, { BackgroundColor3 = W11.Surface }):Play()
					end)
					opt.MouseButton1Click:Connect(function()
						dropdownObj.Value = val
						dropBtn.Text = "  " .. tostring(val)
						dropBtn.TextColor3 = W11.Text
						TweenService:Create(listFrame, GH.TI, { Size = UDim2.new(0, dropBtn.AbsoluteSize.X, 0, 0) }):Play()
						task.delay(0.15, function() listFrame.Visible = false end)
						for _, cb in ipairs(dropdownObj._callbacks) do
							pcall(cb, val)
						end
					end)
				end
			end

			function dropdownObj:SetValues(values)
				self._values = values
				buildList(values)
			end

			function dropdownObj:OnChanged(callback)
				table.insert(self._callbacks, callback)
			end

			function dropdownObj:Destroy()
				frame:Destroy()
			end

			buildList(dropdownObj._values)

			dropBtn.MouseButton1Click:Connect(function()
				if listFrame.Visible then
					TweenService:Create(listFrame, GH.TI, { Size = UDim2.new(0, dropBtn.AbsoluteSize.X, 0, 0) }):Play()
					task.delay(0.15, function() listFrame.Visible = false end)
				else
					listFrame.Visible = true
					local itemCount = #dropdownObj._values
					local listH = math.min(itemCount * 25 + 4, 150)
					TweenService:Create(listFrame, GH.TI, { Size = UDim2.new(0, dropBtn.AbsoluteSize.X, 0, listH) }):Play()
				end
			end)

			dropBtn:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
				if listFrame.Visible then
					listFrame.Size = UDim2.new(0, dropBtn.AbsoluteSize.X, 0, listFrame.Size.Y.Offset)
				end
			end)

			return dropdownObj
		end

		function api:AddSection(title)
			orderCounter += 1
			local sectionLabel = Instance.new("TextLabel")
			sectionLabel.Size = UDim2.new(1, 0, 0, 18)
			sectionLabel.BackgroundTransparency = 1
			sectionLabel.Text = "── " .. title .. " ──"
			sectionLabel.TextColor3 = W11.TextMuted
			sectionLabel.Font = FontBold
			sectionLabel.TextSize = 10
			sectionLabel.TextXAlignment = Enum.TextXAlignment.Left
			sectionLabel.LayoutOrder = orderCounter * 100
			sectionLabel.ZIndex = 4
			sectionLabel.Parent = container

			local sectionObj = {}

			function sectionObj:AddParagraph(config)
				orderCounter += 1
				local pFrame = Instance.new("Frame")
				pFrame.Size = UDim2.new(1, 0, 0, 36)
				pFrame.BackgroundColor3 = W11.Surface
				pFrame.BackgroundTransparency = 0.3
				pFrame.BorderSizePixel = 0
				pFrame.LayoutOrder = orderCounter * 100
				pFrame.ZIndex = 4
				pFrame.Parent = container
				Instance.new("UICorner", pFrame).CornerRadius = UDim.new(0, 4)

				local pTitle = Instance.new("TextLabel")
				pTitle.Size = UDim2.new(1, -12, 0, 14)
				pTitle.Position = UDim2.new(0, 8, 0, 4)
				pTitle.BackgroundTransparency = 1
				pTitle.Text = config.Title or ""
				pTitle.TextColor3 = W11.Text
				pTitle.Font = FontBold
				pTitle.TextSize = 10
				pTitle.TextXAlignment = Enum.TextXAlignment.Left
				pTitle.ZIndex = 5
				pTitle.Parent = pFrame

				local pContent = Instance.new("TextLabel")
				pContent.Size = UDim2.new(1, -12, 0, 14)
				pContent.Position = UDim2.new(0, 8, 0, 20)
				pContent.BackgroundTransparency = 1
				pContent.Text = config.Content or ""
				pContent.TextColor3 = W11.Accent
				pContent.Font = Font
				pContent.TextSize = 10
				pContent.TextXAlignment = Enum.TextXAlignment.Left
				pContent.ZIndex = 5
				pContent.Parent = pFrame

				local pObj = {}
				function pObj:SetTitle(t) pTitle.Text = t end
				function pObj:SetDesc(d) pContent.Text = d end
				function pObj:Destroy() pFrame:Destroy() end
				return pObj
			end

			function sectionObj:AddButton(config)
				orderCounter += 1
				local bFrame = Instance.new("TextButton")
				bFrame.Size = UDim2.new(1, 0, 0, 28)
				bFrame.BackgroundColor3 = W11.AccentDim
				bFrame.Text = ""
				bFrame.AutoButtonColor = false
				bFrame.LayoutOrder = orderCounter * 100
				bFrame.ZIndex = 4
				bFrame.Parent = container
				Instance.new("UICorner", bFrame).CornerRadius = UDim.new(0, 4)

				local bLabel = Instance.new("TextLabel")
				bLabel.Size = UDim2.new(1, -16, 1, 0)
				bLabel.Position = UDim2.new(0, 10, 0, 0)
				bLabel.BackgroundTransparency = 1
				bLabel.Text = config.Title or "Button"
				bLabel.TextColor3 = W11.Text
				bLabel.Font = Font
				bLabel.TextSize = 11
				bLabel.TextXAlignment = Enum.TextXAlignment.Left
				bLabel.ZIndex = 5
				bLabel.Parent = bFrame

				bFrame.MouseEnter:Connect(function()
					TweenService:Create(bFrame, GH.TI, { BackgroundColor3 = W11.Accent }):Play()
				end)
				bFrame.MouseLeave:Connect(function()
					TweenService:Create(bFrame, GH.TI, { BackgroundColor3 = W11.AccentDim }):Play()
				end)
				bFrame.MouseButton1Click:Connect(function()
					if config.Callback then pcall(config.Callback) end
				end)

				local bObj = {}
				function bObj:Destroy() bFrame:Destroy() end
				return bObj
			end

			function sectionObj:AddDropdown(id, config)
				return api:AddDropdown(id, config)
			end

			return sectionObj
		end

		function api:AddInput(id, config)
			orderCounter += 1
			local frame = Instance.new("Frame")
			frame.Name = id
			frame.Size = UDim2.new(1, 0, 0, 38)
			frame.BackgroundColor3 = W11.Surface
			frame.BorderSizePixel = 0
			frame.LayoutOrder = orderCounter * 100
			frame.ZIndex = 4
			frame.Parent = container
			Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 5)

			local title = Instance.new("TextLabel")
			title.Size = UDim2.new(1, -12, 0, 14)
			title.Position = UDim2.new(0, 10, 0, 4)
			title.BackgroundTransparency = 1
			title.Text = config.Title or id
			title.TextColor3 = W11.TextSecondary
			title.Font = Font
			title.TextSize = 10
			title.TextXAlignment = Enum.TextXAlignment.Left
			title.ZIndex = 5
			title.Parent = frame

			local inputBox = Instance.new("TextBox")
			inputBox.Size = UDim2.new(1, -20, 0, 20)
			inputBox.Position = UDim2.new(0, 10, 0, 20)
			inputBox.BackgroundColor3 = W11.OffBG
			inputBox.PlaceholderText = config.Placeholder or ""
			inputBox.PlaceholderColor3 = W11.TextMuted
			inputBox.Text = ""
			inputBox.TextColor3 = W11.Text
			inputBox.Font = Font
			inputBox.TextSize = 10
			inputBox.TextXAlignment = Enum.TextXAlignment.Left
			inputBox.ClearTextOnFocus = false
			inputBox.ZIndex = 5
			inputBox.Parent = frame
			Instance.new("UICorner", inputBox).CornerRadius = UDim.new(0, 3)
			Instance.new("UIPadding", inputBox).PaddingLeft = UDim.new(0, 6)

			local inputObj = {}

			if config.Callback then
				if config.Finished then
					inputBox.FocusLost:Connect(function(enterPressed)
						if enterPressed then
							pcall(config.Callback, inputBox.Text)
						end
					end)
				else
					inputBox:GetPropertyChangedSignal("Text"):Connect(function()
						pcall(config.Callback, inputBox.Text)
					end)
				end
			end

			function inputObj:Destroy() frame:Destroy() end
			return inputObj
		end
	end

	-- Wire API to all tab containers
	for _, cat in ipairs(Categories) do
		if TabContainers[cat.Name] then
			local api = { _frame = TabContainers[cat.Name] }
			WireTabAPI(api)
			TabAPIs[cat.Name] = api
		end
	end

	-- ==========================================
	-- CREATE TOGGLE BUTTON (Win11 style)
	-- ==========================================
	local function CreateToggle(name, displayName, desc, category, callback)
		local target = TabContainers[category] or TabContainers["Combat"]
		if not target then return end
		GH.States[name] = false

		local frame = Instance.new("TextButton")
		frame.Name = name
		frame.Size = UDim2.new(1, 0, 0, BtnH)
		frame.BackgroundColor3 = W11.OffBG
		frame.Text = ""
		frame.AutoButtonColor = false
		frame.LayoutOrder = #target:GetChildren() + 1
		frame.ZIndex = 4
		frame.Parent = target
		Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 5)

		local label = Instance.new("TextLabel")
		label.Name = "GH_ToggleLabel"
		label.Size = UDim2.new(1, -50, 1, 0)
		label.Position = UDim2.new(0, 10, 0, 0)
		label.BackgroundTransparency = 1
		label.Text = "  " .. displayName
		label.TextColor3 = W11.Off
		label.Font = Font
		label.TextSize = 11
		label.TextXAlignment = Enum.TextXAlignment.Left
		label.ZIndex = 5
		label.Parent = frame

		if desc and desc ~= "" then
			local descLabel = Instance.new("TextLabel")
			descLabel.Name = "GH_DescLabel"
			descLabel.Size = UDim2.new(1, -50, 0, 12)
			descLabel.Position = UDim2.new(0, 10, 1, -14)
			descLabel.BackgroundTransparency = 1
			descLabel.Text = "  " .. desc
			descLabel.TextColor3 = W11.TextMuted
			descLabel.Font = Enum.Font.Gotham
			descLabel.TextSize = 8
			descLabel.TextXAlignment = Enum.TextXAlignment.Left
			descLabel.TextTruncate = Enum.TextTruncate.AtEnd
			descLabel.ZIndex = 5
			descLabel.Parent = frame
		end

		-- Toggle switch
		local switchBG = Instance.new("Frame")
		switchBG.Size = UDim2.new(0, 32, 0, 16)
		switchBG.Position = UDim2.new(1, -42, 0.5, -8)
		switchBG.BackgroundColor3 = W11.Surface
		switchBG.BorderSizePixel = 0
		switchBG.ZIndex = 5
		switchBG.Parent = frame
		Instance.new("UICorner", switchBG).CornerRadius = UDim.new(1, 0)

		local switchKnob = Instance.new("Frame")
		switchKnob.Size = UDim2.new(0, 12, 0, 12)
		switchKnob.Position = UDim2.new(0, 2, 0.5, -6)
		switchKnob.BackgroundColor3 = W11.TextSecondary
		switchKnob.BorderSizePixel = 0
		switchKnob.ZIndex = 6
		switchKnob.Parent = switchBG
		Instance.new("UICorner", switchKnob).CornerRadius = UDim.new(1, 0)

		local function setToggle(state)
			GH.States[name] = state
			if state then
				TweenService:Create(switchBG, GH.TI, { BackgroundColor3 = W11.Accent }):Play()
				TweenService:Create(switchKnob, GH.TI, { Position = UDim2.new(1, -14, 0.5, -6), BackgroundColor3 = Color3.new(1, 1, 1) }):Play()
				TweenService:Create(frame, GH.TI, { BackgroundColor3 = W11.OnBG }):Play()
				label.TextColor3 = W11.On
			else
				TweenService:Create(switchBG, GH.TI, { BackgroundColor3 = W11.Surface }):Play()
				TweenService:Create(switchKnob, GH.TI, { Position = UDim2.new(0, 2, 0.5, -6), BackgroundColor3 = W11.TextSecondary }):Play()
				TweenService:Create(frame, GH.TI, { BackgroundColor3 = W11.OffBG }):Play()
				label.TextColor3 = W11.Off
			end
		end

		frame.MouseEnter:Connect(function()
			TweenService:Create(frame, GH.TI, { BackgroundColor3 = W11.SurfaceHover }):Play()
		end)
		frame.MouseLeave:Connect(function()
			if not GH.States[name] then
				TweenService:Create(frame, GH.TI, { BackgroundColor3 = W11.OffBG }):Play()
			else
				TweenService:Create(frame, GH.TI, { BackgroundColor3 = W11.OnBG }):Play()
			end
		end)

		local proxy = {
			Instance = frame,
			Value = false,
			SetValue = function(self, state) self.Value = state; setToggle(state) end,
			SetTitle = function(_, text) label.Text = "  " .. text end,
			SetDesc = function(_, d) local dl = frame:FindFirstChild("GH_DescLabel"); if dl then dl.Text = "  " .. d end end,
			IsA = function(_, className) return frame:IsA(className) end,
		}

		frame.MouseButton1Click:Connect(function()
			local newState = not GH.States[name]
			setToggle(newState)
			if not GH.SilentRestore then
				local toastMsg = displayName .. (newState and (" " .. GH.T("toast_activated")) or (" " .. GH.T("toast_deactivated")))
				GH.ShowToast(toastMsg, newState and W11.On or W11.TextSecondary, 2)
			end
			pcall(callback, newState, proxy)
		end)

		GH.Buttons[name] = proxy
		GH.Callbacks[name] = callback
	end

	-- ==========================================
	-- SETTINGS UI HELPERS
	-- ==========================================
	local stOrder = 0

	local function stSection(text)
		stOrder += 1
		local s = Instance.new("TextLabel")
		s.Name = "STSection_" .. stOrder
		s.Size = UDim2.new(1, 0, 0, 14)
		s.BackgroundTransparency = 1
		s.Text = "── " .. text .. " ──"
		s.TextColor3 = W11.TextMuted
		s.Font = FontBold
		s.TextSize = 9
		s.LayoutOrder = stOrder
		s.ZIndex = 3
		s.Parent = SettingsContainer
		stOrder += 1
		return s
	end

	local function stDropdown(label, values, default, cb)
		stOrder += 1
		local frame = Instance.new("Frame")
		frame.Name = "STDropdown_" .. stOrder
		frame.Size = UDim2.new(1, 0, 0, 26)
		frame.BackgroundColor3 = W11.Surface
		frame.BorderSizePixel = 0
		frame.LayoutOrder = stOrder
		frame.ZIndex = 3
		frame.Parent = SettingsContainer
		Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 4)

		local lbl = Instance.new("TextLabel")
		lbl.Size = UDim2.new(0.55, 0, 1, 0)
		lbl.Position = UDim2.new(0, 8, 0, 0)
		lbl.BackgroundTransparency = 1
		lbl.Text = label
		lbl.TextColor3 = W11.Off
		lbl.Font = Font
		lbl.TextSize = 10
		lbl.TextXAlignment = Enum.TextXAlignment.Left
		lbl.ZIndex = 4
		lbl.Parent = frame

		local dropBtn = Instance.new("TextButton")
		dropBtn.Size = UDim2.new(0.38, -6, 0, 18)
		dropBtn.Position = UDim2.new(0.6, 4, 0.5, -9)
		dropBtn.BackgroundColor3 = W11.OffBG
		dropBtn.Text = "  " .. tostring(default)
		dropBtn.TextColor3 = W11.Text
		dropBtn.Font = Font
		dropBtn.TextSize = 10
		dropBtn.TextXAlignment = Enum.TextXAlignment.Left
		dropBtn.AutoButtonColor = false
		dropBtn.ZIndex = 4
		dropBtn.Parent = frame
		Instance.new("UICorner", dropBtn).CornerRadius = UDim.new(0, 3)

		local arrow = Instance.new("TextLabel")
		arrow.Size = UDim2.new(0, 14, 1, 0)
		arrow.Position = UDim2.new(1, -16, 0, 0)
		arrow.BackgroundTransparency = 1
		arrow.Text = "▼"
		arrow.TextColor3 = W11.TextMuted
		arrow.Font = Font
		arrow.TextSize = 8
		arrow.ZIndex = 5
		arrow.Parent = dropBtn

		-- listFrame is parented to ScreenGui to float above ScrollingFrame clipping
		local listFrame = Instance.new("Frame")
		listFrame.Name = "STDropdownList"
		listFrame.Size = UDim2.new(0, 0, 0, 0)
		listFrame.BackgroundColor3 = W11.Surface
		listFrame.BorderSizePixel = 0
		listFrame.ClipsDescendants = true
		listFrame.ZIndex = 100
		listFrame.Visible = false
		listFrame.Parent = ScreenGui
		Instance.new("UICorner", listFrame).CornerRadius = UDim.new(0, 4)
		local listStroke = Instance.new("UIStroke")
		listStroke.Color = W11.Border
		listStroke.Thickness = 1
		listStroke.Parent = listFrame

		local listScroll = Instance.new("ScrollingFrame")
		listScroll.Size = UDim2.new(1, -4, 1, -4)
		listScroll.Position = UDim2.new(0, 2, 0, 2)
		listScroll.BackgroundTransparency = 1
		listScroll.ScrollBarThickness = 2
		listScroll.ScrollBarImageColor3 = W11.Accent
		listScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
		listScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
		listScroll.BorderSizePixel = 0
		listScroll.ZIndex = 101
		listScroll.Parent = listFrame
		Instance.new("UIListLayout", listScroll).Padding = UDim.new(0, 1)

		local function positionList()
			local absPos = dropBtn.AbsolutePosition
			local absSize = dropBtn.AbsoluteSize
			listFrame.Position = UDim2.new(0, absPos.X, 0, absPos.Y + absSize.Y + 2)
			listFrame.Size = UDim2.new(0, absSize.X, 0, 0)
		end

		for i, val in ipairs(values) do
			local opt = Instance.new("TextButton")
			opt.Name = tostring(val)
			opt.Size = UDim2.new(1, 0, 0, 22)
			opt.BackgroundColor3 = (val == default) and W11.OnBG or W11.Surface
			opt.Text = "  " .. tostring(val)
			opt.TextColor3 = (val == default) and W11.Accent or W11.TextSecondary
			opt.Font = Font
			opt.TextSize = 10
			opt.TextXAlignment = Enum.TextXAlignment.Left
			opt.AutoButtonColor = false
			opt.LayoutOrder = i
			opt.ZIndex = 102
			opt.Parent = listScroll
			Instance.new("UICorner", opt).CornerRadius = UDim.new(0, 3)
			opt.MouseEnter:Connect(function()
				TweenService:Create(opt, GH.TI, { BackgroundColor3 = W11.SurfaceHover }):Play()
			end)
			opt.MouseLeave:Connect(function()
				TweenService:Create(opt, GH.TI, { BackgroundColor3 = (opt.TextColor3 == W11.Accent) and W11.OnBG or W11.Surface }):Play()
			end)
			opt.MouseButton1Click:Connect(function()
				dropBtn.Text = "  " .. tostring(val)
				TweenService:Create(listFrame, GH.TI, { Size = UDim2.new(0, dropBtn.AbsoluteSize.X, 0, 0) }):Play()
				task.delay(0.15, function() listFrame.Visible = false end)
				if cb then pcall(cb, val) end
			end)
		end

		dropBtn.MouseButton1Click:Connect(function()
			if listFrame.Visible then
				TweenService:Create(listFrame, GH.TI, { Size = UDim2.new(0, dropBtn.AbsoluteSize.X, 0, 0) }):Play()
				task.delay(0.15, function() listFrame.Visible = false end)
			else
				positionList()
				listFrame.Visible = true
				local itemCount = #values
				local listH = math.min(itemCount * 23 + 4, 100)
				TweenService:Create(listFrame, GH.TI, { Size = UDim2.new(0, dropBtn.AbsoluteSize.X, 0, listH) }):Play()
			end
		end)

		local obj = {}
		function obj:SetValue(v)
			dropBtn.Text = "  " .. tostring(v)
		end
		return obj
	end

	local function stToggle(label, default, cb)
		stOrder += 1
		local frame = Instance.new("Frame")
		frame.Size = UDim2.new(1, 0, 0, 26)
		frame.BackgroundColor3 = W11.Surface
		frame.BorderSizePixel = 0
		frame.LayoutOrder = stOrder
		frame.ZIndex = 3
		frame.Parent = SettingsContainer
		Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 4)

		local lbl = Instance.new("TextLabel")
		lbl.Size = UDim2.new(0.7, 0, 1, 0)
		lbl.Position = UDim2.new(0, 8, 0, 0)
		lbl.BackgroundTransparency = 1
		lbl.Text = label
		lbl.TextColor3 = W11.Off
		lbl.Font = Font
		lbl.TextSize = 10
		lbl.TextXAlignment = Enum.TextXAlignment.Left
		lbl.ZIndex = 4
		lbl.Parent = frame

		local switchBG = Instance.new("Frame")
		switchBG.Size = UDim2.new(0, 28, 0, 14)
		switchBG.Position = UDim2.new(1, -36, 0.5, -7)
		switchBG.BackgroundColor3 = default and W11.Accent or W11.Surface
		switchBG.BorderSizePixel = 0
		switchBG.ZIndex = 4
		switchBG.Parent = frame
		Instance.new("UICorner", switchBG).CornerRadius = UDim.new(1, 0)

		local knob = Instance.new("Frame")
		knob.Size = UDim2.new(0, 10, 0, 10)
		knob.Position = UDim2.new(0, default and 16 or 2, 0.5, -5)
		knob.BackgroundColor3 = default and Color3.new(1, 1, 1) or W11.TextSecondary
		knob.BorderSizePixel = 0
		knob.ZIndex = 5
		knob.Parent = switchBG
		Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)

		local isOn = default
		frame.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 then
				isOn = not isOn
				TweenService:Create(switchBG, GH.TI, { BackgroundColor3 = isOn and W11.Accent or W11.Surface }):Play()
				TweenService:Create(knob, GH.TI, { Position = UDim2.new(0, isOn and 16 or 2, 0.5, -5), BackgroundColor3 = isOn and Color3.new(1, 1, 1) or W11.TextSecondary }):Play()
				if cb then cb(isOn) end
			end
		end)
	end

	local function stSlider(label, min, max, default, cb)
		stOrder += 1
		local frame = Instance.new("Frame")
		frame.Size = UDim2.new(1, 0, 0, 38)
		frame.BackgroundColor3 = W11.Surface
		frame.BorderSizePixel = 0
		frame.LayoutOrder = stOrder
		frame.ZIndex = 3
		frame.Parent = SettingsContainer
		Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 4)

		local lbl = Instance.new("TextLabel")
		lbl.Size = UDim2.new(0.55, 0, 0, 16)
		lbl.Position = UDim2.new(0, 8, 0, 4)
		lbl.BackgroundTransparency = 1
		lbl.Text = label
		lbl.TextColor3 = W11.Off
		lbl.Font = Font
		lbl.TextSize = 10
		lbl.TextXAlignment = Enum.TextXAlignment.Left
		lbl.ZIndex = 4
		lbl.Parent = frame

		local valLabel = Instance.new("TextLabel")
		valLabel.Size = UDim2.new(0.35, 0, 0, 16)
		valLabel.Position = UDim2.new(0.58, 0, 0, 4)
		valLabel.BackgroundTransparency = 1
		valLabel.Text = tostring(default)
		valLabel.TextColor3 = W11.Accent
		valLabel.Font = FontBold
		valLabel.TextSize = 10
		valLabel.TextXAlignment = Enum.TextXAlignment.Right
		valLabel.ZIndex = 4
		valLabel.Parent = frame

		local bar = Instance.new("Frame")
		bar.Size = UDim2.new(0.88, 0, 0, 4)
		bar.Position = UDim2.new(0.06, 0, 0, 28)
		bar.BackgroundColor3 = W11.BorderSubtle
		bar.BorderSizePixel = 0
		bar.ZIndex = 4
		bar.Parent = frame

		local fill = Instance.new("Frame")
		fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
		fill.BackgroundColor3 = W11.Accent
		fill.BorderSizePixel = 0
		fill.ZIndex = 5
		fill.Parent = bar

		local knob = Instance.new("Frame")
		knob.Size = UDim2.new(0, 8, 0, 8)
		knob.Position = UDim2.new((default - min) / (max - min), -4, 0.5, -4)
		knob.BackgroundColor3 = Color3.new(1, 1, 1)
		knob.BorderSizePixel = 0
		knob.ZIndex = 6
		knob.Parent = bar
		Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)

		local currentVal = default
		local inputBtn = Instance.new("TextButton")
		inputBtn.Size = UDim2.new(1, 10, 0, 20)
		inputBtn.Position = UDim2.new(0, -5, 0.5, -10)
		inputBtn.BackgroundTransparency = 1
		inputBtn.Text = ""
		inputBtn.ZIndex = 7
		inputBtn.Parent = bar

		inputBtn.MouseButton1Down:Connect(function()
			GH._activeSlider = function(x)
				local absPos = bar.AbsolutePosition.X
				local absSize = bar.AbsoluteSize.X
				if absSize == 0 then return end
				local ratio = math.clamp((x - absPos) / absSize, 0, 1)
				currentVal = math.floor(min + (max - min) * ratio)
				valLabel.Text = tostring(currentVal)
				fill.Size = UDim2.new(ratio, 0, 1, 0)
				knob.Position = UDim2.new(ratio, -5, 0.5, -5)
				if cb then cb(currentVal) end
			end
			GH._activeSlider(UserInputService:GetMouseLocation().X)
		end)
	end

	-- ==========================================
	-- MONTAR SETTINGS
	-- ==========================================
	stSection(GH.T("settings_language") .. " / LANGUAGE")
	local langMap = {en = "English", pt = "Portugues", es = "Espanol"}
	local langKeys = {"en", "pt", "es"}
	local langDisplay = {}
	for _, k in ipairs(langKeys) do table.insert(langDisplay, langMap[k]) end
	local langDropdown = stDropdown(GH.T("settings_language"), langDisplay, langMap[GH.Settings.Language] or "English", function(v)
		for k, name in pairs(langMap) do
			if name == v then GH.Settings.Language = k break end
		end
		GH.RefreshUI()
	end)

	stSection(GH.T("settings_config"))
	stSlider(GH.T("settings_fly_speed"), 5, 200, 20, function(v) GH.FlySpeed = v end)
	stSlider(GH.T("settings_noclip_radius"), 1, 20, 3.8, function(v) GH.Settings.NoClipRadius = v end)

	stSection("HITBOX")
	stSlider(GH.T("settings_hitbox_size"), 5, 50, 15, function(v) GH.Settings.HitboxSize = v end)

	stSection("ESP")
	stToggle(GH.T("settings_show_tag"), true, function(v) GH.Settings.ESPShowTag = v end)
	stToggle(GH.T("settings_show_name"), true, function(v) GH.Settings.ESPShowName = v end)
	stToggle(GH.T("settings_show_distance"), true, function(v) GH.Settings.ESPShowDistance = v end)
	stToggle(GH.T("settings_show_health"), true, function(v) GH.Settings.ESPShowHealth = v end)
	stSlider(GH.T("settings_esp_max_distance"), 50, 2000, 300, function(v) GH.Settings.ESPMaxDistance = v end)

	-- ==========================================
	-- FECHAR — Windows 11 style
	-- ==========================================
	CloseBtn.MouseButton1Click:Connect(function()
		GH.FullCleanup()
		pcall(function() ScreenGui:Destroy() end)
	end)

	CloseBtn.MouseEnter:Connect(function()
		TweenService:Create(CloseBtn, GH.TI, { BackgroundColor3 = W11.Red, TextColor3 = Color3.new(1, 1, 1) }):Play()
	end)
	CloseBtn.MouseLeave:Connect(function()
		TweenService:Create(CloseBtn, GH.TI, { BackgroundColor3 = W11.Surface, TextColor3 = W11.Text }):Play()
	end)
	MinBtn.MouseEnter:Connect(function()
		TweenService:Create(MinBtn, GH.TI, { BackgroundColor3 = W11.SurfaceHover }):Play()
	end)
	MinBtn.MouseLeave:Connect(function()
		TweenService:Create(MinBtn, GH.TI, { BackgroundColor3 = W11.Surface }):Play()
	end)

	-- ==========================================
	-- MINIMIZAR
	-- ==========================================
	local minimized = false
	local NormalW, NormalH = PanelW, PanelH
	local MiniW, MiniH = 200, TopbarH

	MinBtn.MouseButton1Click:Connect(function()
		minimized = not minimized
		if minimized then
			Sidebar.Visible = false
			Content.Visible = false
			FPSLabel.Visible = false
			NickLabel.Visible = false
			LiveContainer.Visible = false
			for _, c in pairs(TabContainers) do c.Visible = false end
			TitleLabel.Size = UDim2.new(0, MiniW - BTN_SIZE * 2 - 30, 1, 0)
			TitleLabel.TextTruncate = Enum.TextTruncate.AtEnd
			TweenService:Create(MainFrame, GH.TI_Slow, { Size = UDim2.new(0, MiniW, 0, MiniH) }):Play()
		else
			TitleLabel.Size = UDim2.new(1, -360, 1, 0)
			TitleLabel.TextTruncate = Enum.TextTruncate.None
			TweenService:Create(MainFrame, GH.TI_Slow, { Size = UDim2.new(0, NormalW, 0, NormalH) }):Play()
			task.delay(0.15, function()
			Sidebar.Visible = true
			Content.Visible = true
			FPSLabel.Visible = true
			NickLabel.Visible = true
			LiveContainer.Visible = true
				if TabContainers[ActiveTab] then TabContainers[ActiveTab].Visible = true end
			end)
		end
	end)

	-- ==========================================
	-- DRAG (topbar)
	-- ==========================================
	local dragging, dragInput, dragStart, startPos
	local dragConn = nil

	Topbar.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			dragStart = input.Position
			startPos = MainFrame.Position
			if not dragConn then
				dragConn = RunService.Heartbeat:Connect(function()
					if not dragging then return end
					if dragInput then
						local delta = dragInput.Position - dragStart
						MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
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

	Topbar.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
			dragInput = input
		end
	end)

	-- Slider global input
	GH.TrackGlobalConnection("SliderEnded", UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			GH._activeSlider = nil
		end
	end))
	GH.TrackGlobalConnection("SliderChanged", UserInputService.InputChanged:Connect(function(input)
		if GH._activeSlider and input.UserInputType == Enum.UserInputType.MouseMovement then
			GH._activeSlider(UserInputService:GetMouseLocation().X)
		end
	end))

	-- ==========================================
	-- TOGGLE HOTKEY (RightCtrl)
	-- ==========================================
	local panelVisible = true
	GH.InputManager.Bind(Enum.KeyCode.RightControl, function()
		panelVisible = not panelVisible
		MainFrame.Visible = panelVisible
	end)

	-- ==========================================
	-- PROCESSAR MODULES (toggles pendentes)
	-- ==========================================
	if #GH.PendingButtons == 0 then
		warn("[SYSTEM] AVISO: Nenhum modulo registrou toggle!")
	end

	pcall(function()
		table.sort(GH.PendingButtons, function(a, b)
			if a.category == b.category then return (a.localeKey or ""):lower() < (b.localeKey or ""):lower() end
			return (a.category or "") < (b.category or "")
		end)
	end)

	GH.SilentRestore = true
	for _, pending in ipairs(GH.PendingButtons) do
		local ok, err = pcall(function()
			CreateToggle(
				pending.name,
				GH.T(pending.localeKey or pending.name),
				pending.descKey and GH.T(pending.descKey) or "",
				pending.category,
				pending.callback
			)
		end)
		if not ok then warn("[SYSTEM] Erro ao criar toggle '" .. tostring(pending.name) .. "': " .. tostring(err)) end
	end
	GH.SilentRestore = false

	-- ==========================================
	-- CHARACTER ADDED: Reset + Restore
	-- ==========================================
	GH.TrackGlobalConnection("CharacterAdded", GH.LocalPlayer.CharacterAdded:Connect(function(char)
		if GH.Stopped then return end
		local wasActive = {}
		for name, state in pairs(GH.States) do
			if state then wasActive[name] = true end
		end
		GH.SilentRestore = true
		for name, _ in pairs(GH.States) do
			GH.UnregisterMasterLoop(name)
			GH.States[name] = false
			local btn = GH.Buttons[name]
			local callback = GH.Callbacks[name]
			if btn and callback then pcall(callback, false, btn) end
			if btn and btn.SetValue then pcall(btn.SetValue, btn, false) end
		end
		for name, conn in pairs(GH.Connections) do
			if conn and conn.Connected then pcall(conn.Disconnect, conn) end
		end
		table.clear(GH.Connections)
		task.defer(function()
			if GH.Stopped then return end
			for name, _ in pairs(wasActive) do
				if GH.States[name] == false and GH.Buttons[name] and GH.Callbacks[name] then
					GH.States[name] = true
					local btn = GH.Buttons[name]
					if btn and btn.SetValue then pcall(btn.SetValue, btn, true) end
					pcall(GH.Callbacks[name], true, btn)
				end
			end
			GH.SilentRestore = false
		end)
	end))

	-- ==========================================
	-- CLEANUP HOOKS
	-- ==========================================
	Players.PlayerRemoving:Connect(function(player)
		if player == GH.LocalPlayer then pcall(GH.FullCleanup) end
	end)
	if script then
		script.Destroying:Connect(function() pcall(GH.FullCleanup) end)
	end

	-- ==========================================
	-- INPUT MANAGER
	-- ==========================================
	GH.TrackGlobalConnection("InputManager_Began", UserInputService.InputBegan:Connect(function(input, gpe)
		if gpe then return end
		if input.UserInputType ~= Enum.UserInputType.Keyboard then return end
		local binding = GH.InputManager._bindings[input.KeyCode]
		if binding and binding.onDown then binding.onDown() end
	end))
	GH.TrackGlobalConnection("InputManager_Ended", UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType ~= Enum.UserInputType.Keyboard then return end
		local binding = GH.InputManager._bindings[input.KeyCode]
		if binding and binding.onUp then binding.onUp() end
	end))

	-- ==========================================
	-- MASTER LOOPS
	-- ==========================================
	GH.TrackGlobalConnection("MasterRender", RunService.RenderStepped:Connect(function()
		GH.MasterTick.Render += 1
		for name, callback in pairs(GH.MasterCallbacks.Render) do
			if GH.MasterTick.Render % 3 == 0 then pcall(callback) end
		end
	end))
	GH.TrackGlobalConnection("MasterHeartbeat", RunService.Heartbeat:Connect(function()
		GH.MasterTick.Heartbeat += 1
		for name, callback in pairs(GH.MasterCallbacks.Heartbeat) do pcall(callback) end
	end))
	GH.TrackGlobalConnection("MasterPreSim", RunService.PreSimulation:Connect(function()
		GH.MasterTick.PreSim += 1
		for name, callback in pairs(GH.MasterCallbacks.PreSim) do
			if GH.MasterTick.PreSim % 3 == 0 then pcall(callback) end
		end
	end))

	-- ==========================================
	-- NAMECALL HOOK
	-- ==========================================
	if hookmetamethod and checkcaller then
		local old_namecall = hookmetamethod(game, "__namecall", function(self, ...)
			if not checkcaller() then
				local method = getnamecallmethod()
				local args = {...}
				for _, handler in ipairs(GH.NamecallHandlers) do
					local handled = handler(self, method, args)
					if handled then return old_namecall(self, unpack(args)) end
				end
			end
			return old_namecall(self, ...)
		end)
	end

	-- ==========================================
	-- METRICS
	-- ==========================================
	task.spawn(function() GH.Stats.Start() end)

	-- ==========================================
	-- TOAST DE CARREGAMENTO
	-- ==========================================
	task.delay(0.5, function()
		local v = GH.Version and GH.Version.Hash or ""
		local msg = GH.T("toast_script_loaded")
		if v and v ~= "unknown" then msg = msg .. " (v" .. v .. ")" end
		GH.ShowToast(msg, W11.On, 5)
	end)

	-- ==========================================
	-- AUTO-UPDATE CHECKER
	-- ==========================================
	task.spawn(function()
		task.wait(30)
		local currentHash = GH.Version and GH.Version.Hash or "unknown"
		if currentHash == "unknown" then return end

		while not GH.Stopped do
			task.wait(60)
			if GH.Stopped then break end
			if not GH.ScreenGui or not GH.ScreenGui.Parent then break end

			local ok, result = pcall(function()
				local resp = game:HttpGet(
					"https://api.github.com/repos/EricDs6/SYSTEM-SCRIPT-UNIVERSAL-ROBLOX/commits/main?_=" .. tostring(os.clock()):gsub("%.", ""),
					true
				)
				if resp then
					local data = HttpService:JSONDecode(resp)
					if data and data.sha then
						local latestHash = string.sub(data.sha, 1, 7)
						if latestHash ~= currentHash then
							GH.ShowToast(
								GH.T("toast_new_update") .. " (v" .. latestHash .. ")",
								Color3.fromRGB(255, 180, 0),
								nil,
								true
							)
							return true
						end
					end
				end
				return false
			end)
			if ok and result == true then break end
		end
	end)
end

end -- module
