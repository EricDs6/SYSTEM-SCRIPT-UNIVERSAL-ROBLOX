-- =============================================================================
-- CORE — Sistema compartilhado entre todos os módulos (Fluent UI)
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
-- THEME (cores para uso interno dos módulos)
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
-- UI DIMENSIONS (mantidos para compatibilidade)
-- ==========================================
GH.PanelWidth = 520
GH.PanelHeight = 300
GH.TopbarHeight = 20
GH.SidebarWidth = 130
GH.ButtonHeight = 30
GH.SettingsWidth = 220

-- ==========================================
-- STATE MANAGEMENT
-- ==========================================
GH.States = {}

GH.Buttons = {} :: {[string]: any}
GH.Callbacks = {} :: {[string]: (boolean, any) -> ()}
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
-- NOTIFICATION SYSTEM (via Fluent)
-- ==========================================
function GH.ShowToast(message, color, duration)
	if GH.SilentRestore then return end
	if not GH.Fluent then return end

	pcall(function()
		GH.Fluent:Notify({
			Title = "SYSTEM",
			Content = message,
			Duration = duration or 3,
		})
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
	{ Name = "Combat",   Icon = "crosshair", Order = 1 },
	{ Name = "Movement", Icon = "move",      Order = 2 },
	{ Name = "Visual",   Icon = "eye",       Order = 3 },
	{ Name = "Utility",  Icon = "wrench",    Order = 4 },
	{ Name = "Troll",    Icon = "smile",     Order = 5 },
}

-- Botões pendentes que serão criados após a UI existir
GH.PendingButtons = {} -- { {name, text, callback, category, description}, ... }

function GH.RegisterToggleButton(name, text, callback, category, description)
	table.insert(GH.PendingButtons, {name = name, text = text, callback = callback, category = category, description = description})
end

-- ==========================================
-- NAMECALL HANDLERS (módulos registram aqui)
-- ==========================================
GH.NamecallHandlers = {}

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
-- FULL CLEANUP
-- ==========================================
function GH.FullCleanup()
	GH.isClosing = true

	-- Desativar todos os states
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
-- INITIALIZE: Monta UI via Fluent e processa módulos
-- ==========================================
function GH.Initialize()
	-- Limpar GUI antiga
	if GH.TargetGui:FindFirstChild("SystemScript") then
		GH.TargetGui["SystemScript"]:Destroy()
	end

	-- Carregar Fluent UI
	local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
	local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
	local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()

	GH.Fluent = Fluent
	GH.SaveManager = SaveManager

	-- Criar Window
	local Window = Fluent:CreateWindow({
		Title = "SYSTEM SCRIPT",
		SubTitle = "v2.0",
		TabWidth = 160,
		Size = UDim2.fromOffset(580, 460),
		Theme = "Dark",
		MinimizeKey = Enum.KeyCode.RightControl,
	})
	GH.Window = Window

	-- Criar Tabs
	local Tabs = {}
	for _, cat in ipairs(GH.Categories) do
		Tabs[cat.Name] = Window:AddTab({ Title = cat.Name, Icon = cat.Icon })
	end
	local SettingsTab = Window:AddTab({ Title = "Settings", Icon = "settings" })
	GH.Tabs = Tabs

	-- Processar toggles pendentes dos módulos
	table.sort(GH.PendingButtons, function(a, b)
		if a.category == b.category then
			return a.text:lower() < b.text:lower()
		end
		return a.category < b.category
	end)

	for _, pending in ipairs(GH.PendingButtons) do
		GH.States[pending.name] = false
		local tab = Tabs[pending.category] or Tabs["Combat"]

		local toggle = tab:AddToggle(pending.name, {
			Title = pending.text,
			Description = pending.description or "",
			Default = false,
		})

		toggle:OnChanged(function()
			local state = toggle.Value
			GH.States[pending.name] = state
			if state then
				GH.ShowToast(pending.name .. " Ativado!", GH.Theme.On, 2)
			else
				GH.ShowToast(pending.name .. " Desativado!", GH.Theme.Off, 2)
			end
			pcall(pending.callback, state, toggle)
		end)

		GH.Buttons[pending.name] = toggle
		GH.Callbacks[pending.name] = pending.callback
	end

	-- ==========================================
	-- SETTINGS TAB
	-- ==========================================
	local SettingsSection = SettingsTab:AddSection("Configuracoes")

	SettingsSection:AddToggle("DebugMode", {
		Title = "Debug Mode",
		Default = GH.Settings.DebugMode,
		Callback = function(value)
			GH.Settings.DebugMode = value
		end,
	})

	SettingsSection:AddToggle("ESPShowDistance", {
		Title = "Mostrar Distancia",
		Default = GH.Settings.ESPShowDistance,
		Callback = function(value)
			GH.Settings.ESPShowDistance = value
		end,
	})

	SettingsSection:AddToggle("ESPShowHealth", {
		Title = "Mostrar Vida",
		Default = GH.Settings.ESPShowHealth,
		Callback = function(value)
			GH.Settings.ESPShowHealth = value
		end,
	})

	SettingsSection:AddToggle("ESPShowTag", {
		Title = "Mostrar Tag",
		Default = GH.Settings.ESPShowTag,
		Callback = function(value)
			GH.Settings.ESPShowTag = value
		end,
	})

	SettingsSection:AddToggle("ESPShowName", {
		Title = "Mostrar Nome",
		Default = GH.Settings.ESPShowName,
		Callback = function(value)
			GH.Settings.ESPShowName = value
		end,
	})

	SettingsSection:AddSlider("HitboxSize", {
		Title = "Tamanho Hitbox",
		Default = GH.Settings.HitboxSize,
		Min = 5,
		Max = 50,
		Rounding = 0,
		Callback = function(value)
			GH.Settings.HitboxSize = value
		end,
	})

	SettingsSection:AddSlider("ESPMaxDistance", {
		Title = "Distancia Max ESP",
		Default = GH.Settings.ESPMaxDistance,
		Min = 50,
		Max = 2000,
		Rounding = 0,
		Callback = function(value)
			GH.Settings.ESPMaxDistance = value
		end,
	})

	SettingsSection:AddSlider("NoClipRadius", {
		Title = "Raio NoClip",
		Default = GH.Settings.NoClipRadius,
		Min = 1,
		Max = 20,
		Rounding = 1,
		Callback = function(value)
			GH.Settings.NoClipRadius = value
		end,
	})

	SettingsSection:AddSlider("FlySpeed", {
		Title = "Velocidade Fly",
		Default = GH.FlySpeed,
		Min = 5,
		Max = 100,
		Rounding = 0,
		Callback = function(value)
			GH.FlySpeed = value
		end,
	})

	-- ==========================================
	-- SAVE / LOAD CONFIG
	-- ==========================================
	SaveManager:SetLibrary(Fluent)
	InterfaceManager:SetLibrary(Fluent)
	SaveManager:IgnoreThemeSettings()
	SaveManager:SetIgnoreIndexes({})
	SaveManager:SetFolder("SystemScript")
	InterfaceManager:SetFolder("SystemScript")
	InterfaceManager:BuildInterfaceSection(SettingsTab)
	SaveManager:BuildConfigSection(SettingsTab)

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
			if btn and btn.SetValue then
				pcall(function() btn:SetValue(false) end)
			end
		end

		-- Limpar conexoes (exceto as globais)
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
					if btn and btn.SetValue then
						pcall(function() btn:SetValue(true) end)
					end
					GH.Callbacks[name](true, btn)
				end
			end
			GH.SilentRestore = false
		end)
	end)

	-- ==========================================
	-- FECHAR (via botao do Fluent ou unloading)
	-- ==========================================
	-- O Fluent gerencia minimize/fechar via MinimizeKeybind
	-- Cleanup é chamado quando o script é descarregado

	Players.PlayerRemoving:Connect(function(player)
		if player == GH.LocalPlayer then
			pcall(function()
				GH.FullCleanup()
			end)
		end
	end)

	-- Notificacao de carregamento
	task.delay(0.5, function()
		GH.ShowToast("Script carregado com sucesso!", GH.Theme.On, 5)
	end)

	-- Selecionar primeira aba
	Window:SelectTab(1)
end

-- ==========================================
-- RETURN GH
-- ==========================================
return GH
