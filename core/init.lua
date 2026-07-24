-- =============================================================================
-- CORE — Sistema compartilhado entre todos os módulos
-- =============================================================================
--!nonstrict

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local Lighting = game:GetService("Lighting")
local LocalPlayer = Players.LocalPlayer

-- ==========================================
-- GH: Tabela compartilhada entre todos os módulos
-- ==========================================
local GH = {}

-- Services
GH.Services = {
	Players = Players,
	RunService = RunService,
	CoreGui = CoreGui,
	UserInputService = UserInputService,
	TweenService = TweenService,
	HttpService = HttpService,
	Lighting = Lighting,
}
GH.LocalPlayer = LocalPlayer

-- Target GUI
GH.TargetGui = (RunService:IsStudio() and LocalPlayer:WaitForChild("PlayerGui"))
	or (gethui and gethui())
	or CoreGui

-- ==========================================
-- THEME
-- ==========================================
GH.Theme = {
	BG = Color3.fromRGB(28, 28, 28), BGDark = Color3.fromRGB(20, 20, 20),
	Topbar = Color3.fromRGB(35, 35, 35), Card = Color3.fromRGB(40, 40, 40),
	CardHover = Color3.fromRGB(55, 55, 55), Accent = Color3.fromRGB(0, 120, 210),
	AccentDim = Color3.fromRGB(0, 80, 150), On = Color3.fromRGB(0, 200, 100),
	OnBG = Color3.fromRGB(15, 50, 30), Off = Color3.fromRGB(200, 200, 200),
	OffBG = Color3.fromRGB(45, 45, 45), Text = Color3.fromRGB(240, 240, 240),
	Border = Color3.fromRGB(70, 70, 70), Red = Color3.fromRGB(255, 70, 70),
}

-- TweenInfos
GH.TI = TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
GH.TI_Slow = TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)

-- ==========================================
-- UI DIMENSIONS
-- ==========================================
GH.PanelWidth = 720
GH.PanelHeight = 380
GH.TopbarHeight = 22
GH.SidebarWidth = 160
GH.ButtonHeight = 36
GH.SettingsWidth = 220

-- ==========================================
-- STATE MANAGEMENT
-- ==========================================
GH.States = {
	-- Inicializado vazio, cada módulo registra seus estados
}

GH.Buttons = {} :: {[string]: TextButton}
GH.Callbacks = {} :: {[string]: (boolean, TextButton) -> ()}
GH.Connections = {} :: {[string]: RBXScriptConnection}
GH.Objects = {}
GH.isClosing = false
GH.SilentRestore = false

-- ==========================================
-- CONNECTION MANAGEMENT
-- ==========================================
GH.GlobalConnections = {}

function GH.Disconnect(name)
	local c = GH.Connections[name]
	if c then GH.Connections[name] = nil; pcall(c.Disconnect, c) end
end

function GH.TrackGlobalConnection(name, conn)
	if conn then GH.GlobalConnections[name] = conn end
end

function GH.CleanupGlobalConnections()
	for name, conn in pairs(GH.GlobalConnections) do
		if conn and typeof(conn) == "RBXScriptConnection" then
			pcall(function() conn:Disconnect() end)
		end
		GH.GlobalConnections[name] = nil
	end
end

-- ==========================================
-- MASTER LOOP (Batching)
-- ==========================================
GH.MasterTick = { Render = 0, Heartbeat = 0, PreSim = 0 }
GH.MasterCallbacks = {
	Render = {} :: {[string]: () -> ()},
	Heartbeat = {} :: {[string]: () -> ()},
	PreSim = {} :: {[string]: () -> ()},
}

function GH.RegisterMasterLoop(name, phase, callback)
	GH.MasterCallbacks[phase][name] = callback
end

function GH.UnregisterMasterLoop(name)
	for phase, callbacks in pairs(GH.MasterCallbacks) do
		callbacks[name] = nil
	end
end

-- ==========================================
-- INPUT MANAGER
-- ==========================================
GH.InputManager = {}
GH.InputManager._bindings = {} :: {[Enum.KeyCode]: {onDown: (() -> ())?, onUp: (() -> ())?}}

function GH.InputManager.Bind(keyCode, onDown, onUp)
	GH.InputManager._bindings[keyCode] = { onDown = onDown, onUp = onUp }
end

function GH.InputManager.Unbind(keyCode)
	GH.InputManager._bindings[keyCode] = nil
end

function GH.InputManager.IsHeld(keyCode)
	return UserInputService:IsKeyDown(keyCode)
end

-- ==========================================
-- TOAST SYSTEM
-- ==========================================
GH.ToastContainer = nil
GH.ActiveToasts = 0

function GH.ShowToast(message, color, duration)
	if GH.SilentRestore then return end
	if not GH.ScreenGui or not GH.ScreenGui.Parent then return end

	if not GH.ToastContainer or not GH.ToastContainer.Parent then
		GH.ToastContainer = Instance.new("Frame")
		GH.ToastContainer.Name = "GH_ToastContainer"
		GH.ToastContainer.Size = UDim2.new(0, 260, 1, 0)
		GH.ToastContainer.Position = UDim2.new(1, -270, 0, 40)
		GH.ToastContainer.BackgroundTransparency = 1
		GH.ToastContainer.ZIndex = 9999
		GH.ToastContainer.Parent = GH.ScreenGui
		local layout = Instance.new("UIListLayout")
		layout.Padding = UDim.new(0, 6)
		layout.SortOrder = Enum.SortOrder.LayoutOrder
		layout.VerticalAlignment = Enum.VerticalAlignment.Top
		layout.Parent = GH.ToastContainer
	end

	GH.ActiveToasts = GH.ActiveToasts + 1
	local toastIndex = GH.ActiveToasts

	local toast = Instance.new("Frame")
	toast.Name = "GH_Toast"
	toast.Size = UDim2.new(1, 0, 0, 32)
	toast.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
	toast.BackgroundTransparency = 0.1
	toast.BorderSizePixel = 0
	toast.LayoutOrder = toastIndex
	toast.ZIndex = 10000
	toast.Parent = GH.ToastContainer
	toast.ClipsDescendants = true

	local toastBorder = Instance.new("UIStroke")
	toastBorder.Color = color or GH.Theme.Accent
	toastBorder.Thickness = 1
	toastBorder.Transparency = 0.3
	toastBorder.ZIndex = 10001
	toastBorder.Parent = toast

	local accent = Instance.new("Frame")
	accent.Size = UDim2.new(0, 4, 1, 0)
	accent.BackgroundColor3 = color or GH.Theme.Accent
	accent.BorderSizePixel = 0
	accent.ZIndex = 10001
	accent.Parent = toast

	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1, -16, 1, 0)
	label.Position = UDim2.new(0, 12, 0, 0)
	label.BackgroundTransparency = 1
	label.Text = message
	label.TextColor3 = Color3.fromRGB(240, 240, 240)
	label.Font = Enum.Font.GothamMedium
	label.TextSize = 11
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.TextWrapped = true
	label.ZIndex = 10001
	label.Parent = toast

	toast.Size = UDim2.new(0, 0, 0, 0)
	toast.Position = UDim2.new(1, 0, 0, 0)
	TweenService:Create(toast, GH.TI_Slow, {
		Size = UDim2.new(1, 0, 0, 32),
		Position = UDim2.new(0, 0, 0, 0),
	}):Play()

	task.delay(duration or 3, function()
		if toast and toast.Parent then
			TweenService:Create(toast, GH.TI_Slow, {
				Size = UDim2.new(0, 0, 0, 0),
				Position = UDim2.new(1, 0, 0, 0),
			}):Play()
			task.delay(0.35, function()
				if toast and toast.Parent then toast:Destroy() end
			end)
		end
	end)
end

-- ==========================================
-- SAFE CALL
-- ==========================================
function GH.SafeCall(context, fn)
	local ok, err = pcall(fn)
	if not ok and GH.Settings and GH.Settings.DebugMode then
		warn("[GH DEBUG] " .. context .. ": " .. tostring(err))
		GH.ShowToast("DEBUG: " .. context .. " falhou", GH.Theme.Red, 4)
	end
end

-- ==========================================
-- SETTINGS DEFAULTS
-- ==========================================
GH.Settings = {
	DebugMode = false,
	HitboxSize = 15,
	ESPShowDistance = true,
	ESPShowHealth = true,
	ESPShowTag = true,
	ESPShowName = true,
	ESPMaxDistance = 300,
	NoClipRadius = 3.8,
}

GH.FlySpeed = 20
GH.KeybindDefaults = {
	Sprint = "LeftShift",
	AutoClicker = "X",
	Blink = "Q",
}
GH.Keybinds = {}
for k, v in pairs(GH.KeybindDefaults) do GH.Keybinds[k] = v end

function GH.GetKeyCode(name)
	local keyName = GH.Keybinds[name]
	if keyName then return Enum.KeyCode[keyName] end
	return nil
end

-- ==========================================
-- CATEGORIES (Tabs)
-- ==========================================
GH.Categories = {
	{ Name = "Combat",   Icon = "C",  Order = 1 },
	{ Name = "Movement", Icon = "M", Order = 2 },
	{ Name = "Visual",   Icon = "V", Order = 3 },
	{ Name = "Utility",  Icon = "U", Order = 4 },
	{ Name = "Troll",    Icon = "T", Order = 5 },
}

-- Botões pendentes que serão criados após a UI existir
GH.PendingButtons = {} -- { {name, text, callback, category}, ... }

function GH.RegisterToggleButton(name, text, callback, category)
	table.insert(GH.PendingButtons, {name = name, text = text, callback = callback, category = category})
end

-- ==========================================
-- NAMECALL HANDLERS (módulos registram aqui)
-- ==========================================
GH.NamecallHandlers = {} -- array de funções(self, method, args) -> bool

-- ==========================================
-- CACHE
-- ==========================================
GH.Cache = {
	ESPPlayers = {} :: {[Player]: boolean | RBXScriptConnection},
	XRayParts = {} :: {BasePart},
	OrigHRPSizes = {} :: {[Player]: Vector3},
	OrigWalkSpeed = 16,
	OrigGravity = 196.2,
	HitboxAdornments = {} :: {[Player]: SelectionBox},
	HitboxCharConns = {} :: {[Player]: {RBXScriptConnection}},
	HitboxRemoving = {} :: {[Player]: boolean},
	ShouldSpawnAtCustom = false,
	SpawnCFrame = nil :: CFrame?,
	SpasmTrack = nil,
	SpasmAnim = nil,
	LastDeathCFrame = nil :: CFrame?,
	SwimOldGravity = 196.2,
}

-- ==========================================
-- WEAK TABLES
-- ==========================================
function GH.MakeWeakCache(mode)
	return setmetatable({}, { __mode = mode })
end

-- ==========================================
-- OBJECT POOL (para Drawing)
-- ==========================================
GH.ObjectPool = {}
GH.ObjectPool.__index = GH.ObjectPool

function GH.ObjectPool.new(factory, destructor)
	local self = setmetatable({}, GH.ObjectPool)
	self._pool = {}
	self._factory = factory
	self._destructor = destructor
	return self
end

function GH.ObjectPool:get(...)
	local n = #self._pool
	if n > 0 then
		local obj = self._pool[n]
		self._pool[n] = nil
		return obj
	end
	return self._factory(...)
end

function GH.ObjectPool:release(obj)
	if obj then
		self._destructor(obj)
		table.insert(self._pool, obj)
	end
end

function GH.ObjectPool:clear()
	for i = 1, #self._pool do
		pcall(self._destructor, self._pool[i])
		self._pool[i] = nil
	end
end

-- ==========================================
-- UI CREATION: Toggle Button
-- ==========================================
function GH.CreateToggleButton(name, defaultText, callback, category)
	local targetContainer = GH.TabContainers[category or "Combat"]
	if not targetContainer then targetContainer = GH.TabContainers["Combat"] end

	local Btn = Instance.new("TextButton")
	Btn.Name = name
	Btn.Size = UDim2.new(1, 0, 0, GH.ButtonHeight)
	Btn.BackgroundColor3 = GH.Theme.OffBG
	Btn.AutoButtonColor = false
	Btn.LayoutOrder = #targetContainer:GetChildren()
	Btn.Text = "  " .. defaultText
	Btn.TextColor3 = GH.Theme.Off
	Btn.Font = Enum.Font.GothamMedium
	Btn.TextSize = 12
	Btn.TextXAlignment = Enum.TextXAlignment.Left
	Btn.ZIndex = 3
	Btn.ClipsDescendants = true
	Btn.Parent = targetContainer

	local StatusDot = Instance.new("Frame")
	StatusDot.Name = "StatusDot"
	StatusDot.Size = UDim2.new(0, 6, 0, 6)
	StatusDot.Position = UDim2.new(1, -15, 0.5, -3)
	StatusDot.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
	StatusDot.BorderSizePixel = 0
	StatusDot.ZIndex = 4
	StatusDot.Parent = Btn

	Btn.MouseEnter:Connect(function()
		if not GH.States[name] then
			TweenService:Create(Btn, GH.TI, {BackgroundColor3 = GH.Theme.CardHover}):Play()
		end
	end)
	Btn.MouseLeave:Connect(function()
		if not GH.States[name] then
			TweenService:Create(Btn, GH.TI, {BackgroundColor3 = GH.Theme.OffBG}):Play()
		end
	end)

	Btn.MouseButton1Click:Connect(function()
		GH.States[name] = not GH.States[name]
		if GH.States[name] then
			TweenService:Create(Btn, GH.TI, {BackgroundColor3 = GH.Theme.OnBG, TextColor3 = GH.Theme.On}):Play()
			TweenService:Create(StatusDot, GH.TI, {Size = UDim2.new(0, 8, 0, 8), Position = UDim2.new(1, -17, 0.5, -4), BackgroundColor3 = GH.Theme.On}):Play()
			GH.ShowToast(name .. " Ativado!", GH.Theme.On, 2)
		else
			TweenService:Create(Btn, GH.TI, {BackgroundColor3 = GH.Theme.OffBG, TextColor3 = GH.Theme.Off}):Play()
			TweenService:Create(StatusDot, GH.TI, {Size = UDim2.new(0, 6, 0, 6), Position = UDim2.new(1, -15, 0.5, -3), BackgroundColor3 = Color3.fromRGB(70, 70, 70)}):Play()
			GH.ShowToast(name .. " Desativado!", GH.Theme.Off, 2)
		end
		callback(GH.States[name], Btn)
	end)

	GH.Buttons[name] = Btn
	GH.Callbacks[name] = callback
end

-- ==========================================
-- TWEEN TELEPORT HELPER
-- ==========================================
function GH.TweenTeleport(hrp, targetCFrame, duration)
	if not hrp then return end
	duration = duration or 0.15

	local originalCollisions = {}
	for _, part in ipairs(LocalPlayer.Character:GetDescendants()) do
		if part:IsA("BasePart") then
			originalCollisions[part] = part.CanCollide
			part.CanCollide = false
		end
	end

	local tween = TweenService:Create(hrp, TweenInfo.new(duration, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		CFrame = targetCFrame
	})
	tween:Play()

	task.delay(duration + 0.05, function()
		for part, canCollide in pairs(originalCollisions) do
			if part and part.Parent then
				part.CanCollide = canCollide
			end
		end
	end)
end

-- ==========================================
-- INITIALIZE: Monta UI e processa módulos
-- ==========================================
function GH.Initialize()
	-- Limpar GUI antiga
	if GH.TargetGui:FindFirstChild("SystemScript") then
		GH.TargetGui["SystemScript"]:Destroy()
	end

	-- ScreenGui
	GH.ScreenGui = Instance.new("ScreenGui")
	GH.ScreenGui.Name = "SystemScript"
	GH.ScreenGui.ResetOnSpawn = false
	GH.ScreenGui.DisplayOrder = 999
	GH.ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	GH.ScreenGui.Parent = GH.TargetGui

	-- MainFrame
	local MainFrame = Instance.new("Frame")
	MainFrame.Name = "MainFrame"
	MainFrame.Size = UDim2.new(0, GH.PanelWidth, 0, GH.PanelHeight)
	MainFrame.Position = UDim2.new(0.5, -GH.PanelWidth / 2, 0.5, -GH.PanelHeight / 2)
	MainFrame.BackgroundColor3 = GH.Theme.BG
	MainFrame.BackgroundTransparency = 0.15
	MainFrame.BorderSizePixel = 0
	MainFrame.ClipsDescendants = true
	MainFrame.Parent = GH.ScreenGui
	GH.MainFrame = MainFrame

	local MainBorder = Instance.new("UIStroke")
	MainBorder.Color = GH.Theme.Border
	MainBorder.Thickness = 1
	MainBorder.Transparency = 0.3
	MainBorder.Parent = MainFrame

	-- TOPBAR
	local Topbar = Instance.new("Frame")
	Topbar.Name = "Topbar"
	Topbar.Size = UDim2.new(1, 0, 0, GH.TopbarHeight)
	Topbar.BackgroundColor3 = GH.Theme.Topbar
	Topbar.BackgroundTransparency = 0.1
	Topbar.BorderSizePixel = 0
	Topbar.ZIndex = 2
	Topbar.Parent = MainFrame

	local Title = Instance.new("TextLabel")
	Title.Size = UDim2.new(1, -130, 1, 0)
	Title.Position = UDim2.new(0, 8, 0, 0)
	Title.BackgroundTransparency = 1
	Title.Text = "SYSTEM"
	Title.TextColor3 = GH.Theme.Text
	Title.Font = Enum.Font.GothamBlack
	Title.TextSize = 10
	Title.TextXAlignment = Enum.TextXAlignment.Left
	Title.ZIndex = 3
	Title.Parent = Topbar

	-- Topbar buttons container
	local TopbarBtns = Instance.new("Frame")
	TopbarBtns.Size = UDim2.new(0, 80, 1, 0)
	TopbarBtns.Position = UDim2.new(1, -84, 0, 0)
	TopbarBtns.BackgroundTransparency = 1
	TopbarBtns.ZIndex = 3
	TopbarBtns.Parent = Topbar

	local TopbarBtnsLayout = Instance.new("UIListLayout")
	TopbarBtnsLayout.FillDirection = Enum.FillDirection.Horizontal
	TopbarBtnsLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
	TopbarBtnsLayout.VerticalAlignment = Enum.VerticalAlignment.Center
	TopbarBtnsLayout.Padding = UDim.new(0, 4)
	TopbarBtnsLayout.Parent = TopbarBtns

	local function CreateTopbarButton(name, icon, color)
		local btn = Instance.new("TextButton")
		btn.Name = name
		btn.Size = UDim2.new(0, 16, 0, 16)
		btn.BackgroundColor3 = Color3.fromRGB(55, 55, 55)
		btn.Text = icon
		btn.TextColor3 = color or GH.Theme.Off
		btn.Font = Enum.Font.GothamBold
		btn.TextSize = 9
		btn.AutoButtonColor = false
		btn.ZIndex = 4
		btn.Parent = TopbarBtns
		return btn
	end

	local SettingsBtn = CreateTopbarButton("Settings", "⚙", GH.Theme.Off)
	local MinBtn = CreateTopbarButton("Minimize", "—", GH.Theme.Off)

	local CloseBtn = Instance.new("TextButton")
	CloseBtn.Name = "Close"
	CloseBtn.Size = UDim2.new(0, 36, 0, 16)
	CloseBtn.BackgroundColor3 = Color3.fromRGB(240, 240, 240)
	CloseBtn.Text = "Close"
	CloseBtn.TextColor3 = Color3.fromRGB(20, 20, 20)
	CloseBtn.Font = Enum.Font.GothamBold
	CloseBtn.TextSize = 8
	CloseBtn.AutoButtonColor = false
	CloseBtn.ZIndex = 4
	CloseBtn.Parent = TopbarBtns

	-- Hover effects
	CloseBtn.MouseEnter:Connect(function()
		TweenService:Create(CloseBtn, GH.TI, {BackgroundColor3 = Color3.fromRGB(220, 220, 220)}):Play()
	end)
	CloseBtn.MouseLeave:Connect(function()
		TweenService:Create(CloseBtn, GH.TI, {BackgroundColor3 = Color3.fromRGB(255, 0, 0)}):Play()
	end)

	for _, btn in ipairs({MinBtn, SettingsBtn}) do
		btn.MouseEnter:Connect(function()
			TweenService:Create(btn, GH.TI, {BackgroundColor3 = Color3.fromRGB(70, 70, 70)}):Play()
		end)
		btn.MouseLeave:Connect(function()
			TweenService:Create(btn, GH.TI, {BackgroundColor3 = Color3.fromRGB(55, 55, 55)}):Play()
		end)
	end

	-- SIDEBAR
	local TabBar = Instance.new("Frame")
	TabBar.Name = "TabBar"
	TabBar.Size = UDim2.new(0, GH.SidebarWidth, 1, -GH.TopbarHeight - 20)
	TabBar.Position = UDim2.new(0, 0, 0, GH.TopbarHeight)
	TabBar.BackgroundColor3 = GH.Theme.BGDark
	TabBar.BackgroundTransparency = 0.2
	TabBar.BorderSizePixel = 0
	TabBar.ZIndex = 2
	TabBar.Parent = MainFrame

	local TabBarLayout = Instance.new("UIListLayout")
	TabBarLayout.Parent = TabBar
	TabBarLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
	TabBarLayout.SortOrder = Enum.SortOrder.LayoutOrder
	TabBarLayout.Padding = UDim.new(0, 0)

	GH.TabContainers = {}
	GH.TabButtons = {}
	GH.ActiveTab = "Combat"

	-- Criar containers para cada aba
	for _, cat in ipairs(GH.Categories) do
		local container = Instance.new("ScrollingFrame")
		container.Name = "Tab_" .. cat.Name
		container.Size = UDim2.new(1, -(GH.SidebarWidth + 6), 1, -GH.TopbarHeight - 24)
		container.Position = UDim2.new(0, GH.SidebarWidth + 3, 0, GH.TopbarHeight + 2)
		container.BackgroundTransparency = 1
		container.ScrollBarThickness = 3
		container.ScrollBarImageColor3 = GH.Theme.Accent
		container.ScrollBarImageTransparency = 0.5
		container.AutomaticCanvasSize = Enum.AutomaticSize.Y
		container.CanvasSize = UDim2.new(0, 0, 0, 0)
		container.BorderSizePixel = 0
		container.Visible = (cat.Name == GH.ActiveTab)
		container.ZIndex = 3
		container.Parent = MainFrame

		local layout = Instance.new("UIListLayout")
		layout.Parent = container
		layout.HorizontalAlignment = Enum.HorizontalAlignment.Left
		layout.SortOrder = Enum.SortOrder.LayoutOrder
		layout.Padding = UDim.new(0, 3)

		local padding = Instance.new("UIPadding")
		padding.PaddingTop = UDim.new(0, 2)
		padding.PaddingBottom = UDim.new(0, 4)
		padding.PaddingLeft = UDim.new(0, 4)
		padding.Parent = container

		GH.TabContainers[cat.Name] = container
	end

	-- Função de troca de aba
	local function SwitchTab(tabName)
		if tabName == GH.ActiveTab then return end
		if GH.TabContainers[GH.ActiveTab] then
			GH.TabContainers[GH.ActiveTab].Visible = false
		end
		if GH.TabButtons[GH.ActiveTab] then
			TweenService:Create(GH.TabButtons[GH.ActiveTab], GH.TI, {BackgroundColor3 = GH.Theme.BGDark, TextColor3 = GH.Theme.Off}):Play()
		end
		GH.ActiveTab = tabName
		if GH.TabContainers[GH.ActiveTab] then
			GH.TabContainers[GH.ActiveTab].Visible = true
		end
		if GH.TabButtons[GH.ActiveTab] then
			TweenService:Create(GH.TabButtons[GH.ActiveTab], GH.TI, {BackgroundColor3 = GH.Theme.Accent, TextColor3 = Color3.new(1, 1, 1)}):Play()
		end
	end

	-- Botões da sidebar
	for _, cat in ipairs(GH.Categories) do
		local btn = Instance.new("TextButton")
		btn.Name = cat.Name
		btn.Size = UDim2.new(1, 0, 0, 28)
		btn.BackgroundColor3 = (cat.Name == GH.ActiveTab) and GH.Theme.Accent or GH.Theme.BGDark
		btn.Text = "  " .. cat.Name
		btn.TextColor3 = (cat.Name == GH.ActiveTab) and Color3.new(1, 1, 1) or GH.Theme.Off
		btn.Font = Enum.Font.GothamBold
		btn.TextSize = 12
		btn.TextXAlignment = Enum.TextXAlignment.Left
		btn.AutoButtonColor = false
		btn.LayoutOrder = cat.Order
		btn.ZIndex = 3
		btn.Parent = TabBar

		btn.MouseEnter:Connect(function()
			if GH.ActiveTab ~= cat.Name then
				TweenService:Create(btn, GH.TI, {BackgroundColor3 = GH.Theme.CardHover}):Play()
			end
		end)
		btn.MouseLeave:Connect(function()
			if GH.ActiveTab ~= cat.Name then
				TweenService:Create(btn, GH.TI, {BackgroundColor3 = GH.Theme.BGDark}):Play()
			end
		end)
		btn.MouseButton1Click:Connect(function() SwitchTab(cat.Name) end)
		GH.TabButtons[cat.Name] = btn
	end

	-- FOOTER
	local Footer = Instance.new("Frame")
	Footer.Name = "Footer"
	Footer.Size = UDim2.new(1, 0, 0, 22)
	Footer.Position = UDim2.new(0, 0, 1, -22)
	Footer.BackgroundColor3 = GH.Theme.BGDark
	Footer.BackgroundTransparency = 0.2
	Footer.BorderSizePixel = 0
	Footer.ZIndex = 2
	Footer.Parent = MainFrame

	local FooterSep = Instance.new("Frame")
	FooterSep.Size = UDim2.new(1, 0, 0, 1)
	FooterSep.BackgroundColor3 = GH.Theme.Border
	FooterSep.BorderSizePixel = 0
	FooterSep.ZIndex = 3
	FooterSep.Parent = Footer

	local VersionLabel = Instance.new("TextLabel")
	VersionLabel.Size = UDim2.new(0, 50, 1, 0)
	VersionLabel.Position = UDim2.new(0, 8, 0, 0)
	VersionLabel.BackgroundTransparency = 1
	VersionLabel.Text = "v2.0"
	VersionLabel.TextColor3 = Color3.fromRGB(120, 120, 120)
	VersionLabel.Font = Enum.Font.GothamMedium
	VersionLabel.TextSize = 9
	VersionLabel.TextXAlignment = Enum.TextXAlignment.Left
	VersionLabel.ZIndex = 3
	VersionLabel.Parent = Footer

	local FilterInput = Instance.new("TextBox")
	FilterInput.Name = "FilterInput"
	FilterInput.Size = UDim2.new(0, 140, 0, 16)
	FilterInput.Position = UDim2.new(0.5, -70, 0.5, -8)
	FilterInput.BackgroundColor3 = Color3.fromRGB(240, 240, 240)
	FilterInput.Text = ""
	FilterInput.PlaceholderText = "Filter..."
	FilterInput.PlaceholderColor3 = Color3.fromRGB(150, 150, 150)
	FilterInput.TextColor3 = Color3.fromRGB(30, 30, 30)
	FilterInput.Font = Enum.Font.GothamMedium
	FilterInput.TextSize = 9
	FilterInput.ClearTextOnFocus = false
	FilterInput.ZIndex = 3
	FilterInput.Parent = Footer

	local ClearBtn = Instance.new("TextButton")
	ClearBtn.Size = UDim2.new(0, 34, 0, 16)
	ClearBtn.Position = UDim2.new(0.5, 76, 0.5, -8)
	ClearBtn.BackgroundColor3 = Color3.fromRGB(240, 240, 240)
	ClearBtn.Text = "Clear"
	ClearBtn.TextColor3 = Color3.fromRGB(30, 30, 30)
	ClearBtn.Font = Enum.Font.GothamBold
	ClearBtn.TextSize = 9
	ClearBtn.AutoButtonColor = false
	ClearBtn.ZIndex = 3
	ClearBtn.Parent = Footer

	ClearBtn.MouseButton1Click:Connect(function()
		FilterInput.Text = ""
	end)

	-- Filtro de busca
	FilterInput:GetPropertyChangedSignal("Text"):Connect(function()
		local text = FilterInput.Text:lower()
		if GH.TabContainers[GH.ActiveTab] then
			for _, obj in ipairs(GH.TabContainers[GH.ActiveTab]:GetChildren()) do
				if obj:IsA("TextButton") then
					if text == "" or obj.Name:lower():find(text, 1, true) or obj.Text:lower():find(text, 1, true) then
						obj.Visible = true
					else
						obj.Visible = false
					end
				end
			end
		end
	end)

	-- ==========================================
	-- PROCESSAR BOTÕES PENDENTES DOS MÓDULOS
	-- ==========================================
	for _, pending in ipairs(GH.PendingButtons) do
		GH.States[pending.name] = false
		GH.CreateToggleButton(pending.name, pending.text, pending.callback, pending.category)
	end

	-- ==========================================
	-- DRAG
	-- ==========================================
	local dragging, dragInput, dragStart, startPos
	local dragConnection = nil

	local function StartDrag(input)
		dragging = true
		dragStart = input.Position
		startPos = MainFrame.Position
		if not dragConnection then
			dragConnection = RunService.Heartbeat:Connect(function()
				if GH.isClosing then return end
				if dragging and dragInput then
					local delta = dragInput.Position - dragStart
					MainFrame.Position = UDim2.new(
						startPos.X.Scale, startPos.X.Offset + delta.X,
						startPos.Y.Scale, startPos.Y.Offset + delta.Y
					)
				end
			end)
		end
	end

	local function StopDrag()
		dragging = false
		dragInput = nil
		if dragConnection then dragConnection:Disconnect(); dragConnection = nil end
	end

	Topbar.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1
			or input.UserInputType == Enum.UserInputType.Touch then
			StartDrag(input)
			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					StopDrag()
				end
			end)
		end
	end)

	Topbar.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement
			or input.UserInputType == Enum.UserInputType.Touch then
			dragInput = input
		end
	end)

	-- ==========================================
	-- FULL CLEANUP
	-- ==========================================
	function GH.FullCleanup()
		GH.isClosing = true

		-- Desativar todos os states (ativa os callbacks de limpeza)
		local statesToClean = {}
		for name, state in pairs(GH.States) do
			if state then table.insert(statesToClean, name) end
		end
		for _, name in ipairs(statesToClean) do
			GH.States[name] = false
			if GH.Callbacks[name] and GH.Buttons[name] then
				pcall(GH.Callbacks[name], false, GH.Buttons[name])
			end
		end

		-- Desregistrar todos os master loops
		for phase, callbacks in pairs(GH.MasterCallbacks) do
			for name, _ in pairs(callbacks) do
				callbacks[name] = nil
			end
		end

		-- Desconectar todas as conexoes locais
		for name, conn in pairs(GH.Connections) do
			if conn and typeof(conn) == "RBXScriptConnection" then
				pcall(function() conn:Disconnect() end)
			end
			GH.Connections[name] = nil
		end

		-- Limpar conexoes globais
		GH.CleanupGlobalConnections()

		-- Limpar input manager
		table.clear(GH.InputManager._bindings)

		-- Destruir todas as GUIs auxiliares
		for key, obj in pairs(GH.Objects) do
			if obj and typeof(obj) == "Instance" then
				pcall(function() obj:Destroy() end)
			end
			GH.Objects[key] = nil
		end

		-- Limpar float pad
		pcall(function()
			local pad = workspace:FindFirstChild("GH_FloatPad")
			if pad then pad:Destroy() end
			if LocalPlayer.Character then
				local pad2 = LocalPlayer.Character:FindFirstChild("GH_FloatPad")
				if pad2 then pad2:Destroy() end
			end
		end)

		-- Limpar VehicleFly body movers
		pcall(function()
			if LocalPlayer.Character then
				local r = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
				if r then
					local bv = r:FindFirstChild("GH_VFlyBV")
					if bv then bv:Destroy() end
					local bg = r:FindFirstChild("GH_VFlyBG")
					if bg then bg:Destroy() end
				end
			end
		end)

		-- Restaurar workspace
		pcall(function()
			workspace.Gravity = GH.Cache.OrigGravity or 196.2
		end)

		-- Restaurar humanoid
		pcall(function()
			local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
			if hum then
				hum.WalkSpeed = GH.Cache.OrigWalkSpeed or 16
				hum.JumpHeight = 7.2
				hum.JumpPower = 50
				hum.PlatformStand = false
				hum.AutoRotate = true
				local enums = Enum.HumanoidStateType:GetEnumItems()
				table.remove(enums, table.find(enums, Enum.HumanoidStateType.None))
				for _, v in ipairs(enums) do hum:SetStateEnabled(v, true) end
			end
		end)

		-- Limpar HRP sizes
		for player, origSize in pairs(GH.Cache.OrigHRPSizes) do
			pcall(function()
				if player.Character then
					local hrp = player.Character:FindFirstChild("HumanoidRootPart")
					if hrp and origSize then
						hrp.Size = origSize
						hrp.Transparency = 1
						hrp.CanCollide = false
					end
				end
			end)
		end
		table.clear(GH.Cache.OrigHRPSizes)

		-- Limpar SelectionBoxes
		pcall(function()
			for _, obj in ipairs(GH.TargetGui:GetChildren()) do
				if obj:IsA("SelectionBox") and obj.Name:sub(1, 12) == "GH_Hitbox_SB" then
					obj.Adornee = nil
					obj:Destroy()
				end
			end
		end)

		-- Limpar ESP
		for _, p in ipairs(Players:GetPlayers()) do
			if p ~= LocalPlayer and p.Character then
				for _, obj in ipairs(p.Character:GetChildren()) do
					if obj.Name:sub(1, 6) == "GH_ESP" then
						pcall(function() obj:Destroy() end)
					end
				end
			end
		end

		-- Limpar animacoes
		pcall(function()
			if GH.Cache.SpasmTrack then GH.Cache.SpasmTrack:Stop(); GH.Cache.SpasmTrack = nil end
			if GH.Cache.SpasmAnim then GH.Cache.SpasmAnim:Destroy(); GH.Cache.SpasmAnim = nil end
		end)

		-- Limpar tabelas
		table.clear(GH.Cache.HitboxAdornments)
		table.clear(GH.Cache.ESPPlayers)
	end

	-- ==========================================
	-- CLOSE
	-- ==========================================
	CloseBtn.MouseButton1Click:Connect(function()
		GH.FullCleanup()
		GH.ScreenGui:Destroy()
	end)

	-- ==========================================
	-- MINIMIZE
	-- ==========================================
	local minimized = false
	local NormalWidth = GH.PanelWidth
	local NormalHeight = GH.PanelHeight
	local MinimizedHeight = 22

	MinBtn.MouseButton1Click:Connect(function()
		minimized = not minimized
		if minimized then
			TabBar.Visible = false
			Footer.Visible = false
			for _, container in pairs(GH.TabContainers) do
				container.Visible = false
			end
			TweenService:Create(MainFrame, GH.TI_Slow, {
				Size = UDim2.new(0, 220, 0, MinimizedHeight)
			}):Play()
			MinBtn.Text = "+"
		else
			TweenService:Create(MainFrame, GH.TI_Slow, {
				Size = UDim2.new(0, NormalWidth, 0, NormalHeight)
			}):Play()
			MinBtn.Text = "—"
			task.delay(0.15, function()
				TabBar.Visible = true
				Footer.Visible = true
				if GH.TabContainers[GH.ActiveTab] then
					GH.TabContainers[GH.ActiveTab].Visible = true
				end
			end)
		end
	end)

	-- ==========================================
	-- SETTINGS TOGGLE
	-- ==========================================
	local settingsOpen = false
	SettingsBtn.MouseButton1Click:Connect(function()
		settingsOpen = not settingsOpen
		if settingsOpen then
			for _, container in pairs(GH.TabContainers) do
				container.Visible = false
			end
			TabBar.Visible = false
		else
			TabBar.Visible = true
			if GH.TabContainers[GH.ActiveTab] then
				GH.TabContainers[GH.ActiveTab].Visible = true
			end
		end
	end)

	-- ==========================================
	-- INPUT MANAGER GLOBAL CONNECTIONS
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
		for name, callback in pairs(GH.MasterCallbacks.Heartbeat) do
			pcall(callback)
		end
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
	-- SAVE/LOAD CONFIG
	-- ==========================================
	local SaveFile = "system_script_config.json"

	local function GetSaveData()
		local activeFeatures = {}
		for name, state in pairs(GH.States) do
			if state then activeFeatures[name] = true end
		end
		return {
			Settings = {
				DebugMode = GH.Settings.DebugMode,
				FlySpeed = GH.FlySpeed,
				HitboxSize = GH.Settings.HitboxSize,
				ESPShowDistance = GH.Settings.ESPShowDistance,
				ESPShowHealth = GH.Settings.ESPShowHealth,
				ESPShowTag = GH.Settings.ESPShowTag,
				ESPShowName = GH.Settings.ESPShowName,
				ESPMaxDistance = GH.Settings.ESPMaxDistance,
				NoClipRadius = GH.Settings.NoClipRadius,
			},
			ActiveFeatures = activeFeatures,
		}
	end

	local function SaveConfig()
		local ok, err = pcall(function()
			local data = GetSaveData()
			local json = HttpService:JSONEncode(data)
			writefile(SaveFile, json)
		end)
		return ok, err
	end

	local function LoadConfig()
		local ok, result = pcall(function()
			if not isfile(SaveFile) then return nil end
			local json = readfile(SaveFile)
			if not json or json == "" then return nil end
			local decodeOk, data = pcall(HttpService.JSONDecode, HttpService, json)
			if not decodeOk or type(data) ~= "table" then return nil end
			if data.Settings and type(data.Settings) == "table" then
				for key, value in pairs(data.Settings) do
					if GH.Settings[key] ~= nil then GH.Settings[key] = value end
				end
				if data.Settings.FlySpeed then GH.FlySpeed = data.Settings.FlySpeed end
			end
			return data
		end)
		if ok then return result end
		return nil
	end

	-- Carregar config
	local SavedData = LoadConfig()

	-- Restaurar features ativas
	if SavedData and SavedData.ActiveFeatures then
		task.delay(1, function()
			GH.SilentRestore = true
			for name, _ in pairs(SavedData.ActiveFeatures) do
				if GH.States[name] == false and GH.Buttons[name] and GH.Callbacks[name] then
					GH.States[name] = true
					local btn = GH.Buttons[name]
					local statusDot = btn:FindFirstChild("StatusDot")
					TweenService:Create(btn, GH.TI, {BackgroundColor3 = GH.Theme.OnBG, TextColor3 = GH.Theme.On}):Play()
					if statusDot then TweenService:Create(statusDot, GH.TI, {Size = UDim2.new(0, 8, 0, 8), Position = UDim2.new(1, -17, 0.5, -4), BackgroundColor3 = GH.Theme.On}):Play() end
					GH.Callbacks[name](true, btn)
				end
			end
			GH.SilentRestore = false
		end)
	end

	-- ==========================================
	-- CHARACTER ADDED: Reset + Restore
	-- ==========================================
	GH.LocalPlayer.CharacterAdded:Connect(function(char)
		local wasActive = {}
		for name, state in pairs(GH.States) do
			if state then wasActive[name] = true end
		end

		-- Resetar todas as features
		for name, _ in pairs(GH.States) do
			GH.UnregisterMasterLoop(name)
			GH.States[name] = false
			local btn = GH.Buttons[name]
			local callback = GH.Callbacks[name]
			if btn and callback then callback(false, btn) end
			if btn then
				local statusDot = btn:FindFirstChild("StatusDot")
				TweenService:Create(btn, GH.TI, {BackgroundColor3 = GH.Theme.OffBG, TextColor3 = GH.Theme.Off}):Play()
				if statusDot then
					TweenService:Create(statusDot, GH.TI, {Size = UDim2.new(0, 6, 0, 6), Position = UDim2.new(1, -15, 0.5, -3), BackgroundColor3 = Color3.fromRGB(70, 70, 70)}):Play()
				end
			end
		end

		-- Limpar conexões (exceto as globais)
		for name, conn in pairs(GH.Connections) do
			if conn and conn.Connected then pcall(conn.Disconnect, conn) end
		end
		table.clear(GH.Connections)

		-- Restaurar features
		GH.SilentRestore = true
		task.defer(function()
			for name, _ in pairs(wasActive) do
				if GH.States[name] == false and GH.Buttons[name] and GH.Callbacks[name] then
					GH.States[name] = true
					local btn = GH.Buttons[name]
					local statusDot = btn:FindFirstChild("StatusDot")
					TweenService:Create(btn, GH.TI, {BackgroundColor3 = GH.Theme.OnBG, TextColor3 = GH.Theme.On}):Play()
					if statusDot then TweenService:Create(statusDot, GH.TI, {Size = UDim2.new(0, 8, 0, 8), Position = UDim2.new(1, -17, 0.5, -4), BackgroundColor3 = GH.Theme.On}):Play() end
					GH.Callbacks[name](true, btn)
				end
			end
			GH.SilentRestore = false
		end)
	end)

	-- Auto-save ao fechar
	pcall(function()
		game:BindToClose(function() SaveConfig() end)
	end)

	Players.PlayerRemoving:Connect(function(player)
		if player == GH.LocalPlayer then
			pcall(function()
				GH.FullCleanup()
				if GH.ScreenGui and GH.ScreenGui.Parent then GH.ScreenGui:Destroy() end
			end)
		end
	end)
end

-- ==========================================
-- RETURN GH
-- ==========================================
return GH
