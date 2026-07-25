-- =============================================================================
-- SYSTEM SCRIPT UNIVERSAL - LOADER
-- Execute este script no executor para carregar tudo via loadstring
-- =============================================================================
--!nonstrict
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local CoreGui = (RunService:IsStudio() and Players.LocalPlayer:WaitForChild("PlayerGui")) or (gethui and gethui()) or game:GetService("CoreGui")

-- ==========================================
-- THEME (mesmo padrão do Fluent)
-- ==========================================
local Theme = {
	BG = Color3.fromRGB(28, 28, 28),
	BGDark = Color3.fromRGB(20, 20, 20),
	Topbar = Color3.fromRGB(35, 35, 35),
	Card = Color3.fromRGB(40, 40, 40),
	Accent = Color3.fromRGB(0, 120, 210),
	AccentDim = Color3.fromRGB(0, 80, 150),
	On = Color3.fromRGB(0, 200, 100),
	Red = Color3.fromRGB(255, 70, 70),
	Text = Color3.fromRGB(240, 240, 240),
	TextDim = Color3.fromRGB(160, 160, 160),
	Border = Color3.fromRGB(70, 70, 70),
}

local Font = Enum.Font.GothamMedium
local FontBold = Enum.Font.GothamBold

-- ==========================================
-- TELA DE CARREGAMENTO FLUENT STYLE
-- ==========================================
local LoadGui = Instance.new("ScreenGui")
LoadGui.Name = "GH_LoadingScreen"
LoadGui.ResetOnSpawn = false
LoadGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
LoadGui.IgnoreGuiInset = true
LoadGui.Parent = CoreGui

-- Backdrop escurecido
local Backdrop = Instance.new("Frame")
Backdrop.Name = "Backdrop"
Backdrop.Size = UDim2.new(1, 0, 1, 0)
Backdrop.BackgroundColor3 = Color3.new(0, 0, 0)
Backdrop.BackgroundTransparency = 1
Backdrop.BorderSizePixel = 0
Backdrop.Parent = LoadGui

-- Container centralizado
local Container = Instance.new("Frame")
Container.Name = "Container"
Container.AnchorPoint = Vector2.new(0.5, 0.5)
Container.Position = UDim2.new(0.5, 0, 0.5, 0)
Container.Size = UDim2.new(0, 320, 0, 180)
Container.BackgroundColor3 = Theme.BG
Container.BackgroundTransparency = 1
Container.BorderSizePixel = 0
Container.Parent = Backdrop
Instance.new("UICorner", Container).CornerRadius = UDim.new(0, 8)

local ContainerStroke = Instance.new("UIStroke")
ContainerStroke.Color = Theme.Border
ContainerStroke.Thickness = 1
ContainerStroke.Transparency = 1
ContainerStroke.Parent = Container

-- Topbar
local Topbar = Instance.new("Frame")
Topbar.Name = "Topbar"
Topbar.Size = UDim2.new(1, 0, 0, 36)
Topbar.BackgroundColor3 = Theme.Topbar
Topbar.BackgroundTransparency = 1
Topbar.BorderSizePixel = 0
Topbar.Parent = Container
Instance.new("UICorner", Topbar).CornerRadius = UDim.new(0, 8)

-- Separador do topbar
local TopbarSep = Instance.new("Frame")
TopbarSep.Size = UDim2.new(1, 0, 0, 1)
TopbarSep.Position = UDim2.new(0, 0, 1, -1)
TopbarSep.BackgroundColor3 = Theme.Border
TopbarSep.BackgroundTransparency = 0.7
TopbarSep.BorderSizePixel = 0
TopbarSep.Parent = Topbar

-- Titulo
local Title = Instance.new("TextLabel")
Title.Name = "Title"
Title.Size = UDim2.new(1, -20, 1, 0)
Title.Position = UDim2.new(0, 12, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "SYSTEM SCRIPT"
Title.TextColor3 = Theme.Accent
Title.Font = FontBold
Title.TextSize = 13
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.TextTransparency = 1
Title.Parent = Topbar

-- Subtitle
local Subtitle = Instance.new("TextLabel")
Subtitle.Name = "Subtitle"
Subtitle.Size = UDim2.new(0, 40, 1, 0)
Subtitle.Position = UDim2.new(1, -52, 0, 0)
Subtitle.BackgroundTransparency = 1
Subtitle.Text = "v2.0"
Subtitle.TextColor3 = Theme.TextDim
Subtitle.Font = Font
Subtitle.TextSize = 11
Subtitle.TextXAlignment = Enum.TextXAlignment.Right
Subtitle.TextTransparency = 1
Subtitle.Parent = Topbar

-- Conteudo
local Content = Instance.new("Frame")
Content.Name = "Content"
Content.Size = UDim2.new(1, -24, 1, -48)
Content.Position = UDim2.new(0, 12, 0, 42)
Content.BackgroundTransparency = 1
Content.Parent = Container

-- Status label
local StatusLabel = Instance.new("TextLabel")
StatusLabel.Name = "Status"
StatusLabel.Size = UDim2.new(1, 0, 0, 16)
StatusLabel.Position = UDim2.new(0, 0, 0, 0)
StatusLabel.BackgroundTransparency = 1
StatusLabel.Text = "Inicializando..."
StatusLabel.TextColor3 = Theme.Text
StatusLabel.Font = Font
StatusLabel.TextSize = 12
StatusLabel.TextXAlignment = Enum.TextXAlignment.Left
StatusLabel.TextTransparency = 1
StatusLabel.Parent = Content

-- Progress bar background
local ProgressBg = Instance.new("Frame")
ProgressBg.Name = "ProgressBg"
ProgressBg.Size = UDim2.new(1, 0, 0, 4)
ProgressBg.Position = UDim2.new(0, 0, 0, 24)
ProgressBg.BackgroundColor3 = Theme.BGDark
ProgressBg.BorderSizePixel = 0
ProgressBg.BackgroundTransparency = 1
ProgressBg.Parent = Content
Instance.new("UICorner", ProgressBg).CornerRadius = UDim.new(1, 0)

-- Progress bar fill
local ProgressFill = Instance.new("Frame")
ProgressFill.Name = "Fill"
ProgressFill.Size = UDim2.new(0, 0, 1, 0)
ProgressFill.BackgroundColor3 = Theme.Accent
ProgressFill.BorderSizePixel = 0
ProgressFill.BackgroundTransparency = 1
ProgressFill.Parent = ProgressBg
Instance.new("UICorner", ProgressFill).CornerRadius = UDim.new(1, 0)

-- Glow no progress bar
local ProgressGlow = Instance.new("Frame")
ProgressGlow.Name = "Glow"
ProgressGlow.Size = UDim2.new(1, 4, 1, 4)
ProgressGlow.Position = UDim2.new(0, -2, 0, -2)
ProgressGlow.BackgroundColor3 = Theme.Accent
ProgressGlow.BackgroundTransparency = 0.85
ProgressGlow.BorderSizePixel = 0
ProgressGlow.ZIndex = 0
ProgressGlow.Parent = ProgressBg
Instance.new("UICorner", ProgressGlow).CornerRadius = UDim.new(1, 0)

-- Progress percent
local ProgressLabel = Instance.new("TextLabel")
ProgressLabel.Name = "Percent"
ProgressLabel.Size = UDim2.new(1, 0, 0, 14)
ProgressLabel.Position = UDim2.new(0, 0, 0, 34)
ProgressLabel.BackgroundTransparency = 1
ProgressLabel.Text = "0%"
ProgressLabel.TextColor3 = Theme.TextDim
ProgressLabel.Font = Font
ProgressLabel.TextSize = 10
ProgressLabel.TextXAlignment = Enum.TextXAlignment.Left
ProgressLabel.TextTransparency = 1
ProgressLabel.Parent = Content

-- Detalhe do modulo atual
local DetailLabel = Instance.new("TextLabel")
DetailLabel.Name = "Detail"
DetailLabel.Size = UDim2.new(1, 0, 0, 14)
DetailLabel.Position = UDim2.new(0, 0, 0, 50)
DetailLabel.BackgroundTransparency = 1
DetailLabel.Text = ""
DetailLabel.TextColor3 = Theme.TextDim
DetailLabel.Font = Font
DetailLabel.TextSize = 10
DetailLabel.TextXAlignment = Enum.TextXAlignment.Left
DetailLabel.TextTransparency = 1
DetailLabel.Parent = Content

-- ==========================================
-- ANIMACAO DE ENTRADA
-- ==========================================
local function animateIn()
	local t = TweenInfo.new(0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)

	TweenService:Create(Backdrop, t, {BackgroundTransparency = 0.4}):Play()
	TweenService:Create(Container, t, {BackgroundTransparency = 0}):Play()
	TweenService:Create(ContainerStroke, t, {Transparency = 0}):Play()
	TweenService:Create(Topbar, t, {BackgroundTransparency = 0}):Play()
	TweenService:Create(Title, t, {TextTransparency = 0}):Play()
	TweenService:Create(Subtitle, t, {TextTransparency = 0}):Play()
	TweenService:Create(StatusLabel, t, {TextTransparency = 0}):Play()
	TweenService:Create(ProgressBg, t, {BackgroundTransparency = 0}):Play()
	TweenService:Create(ProgressFill, t, {BackgroundTransparency = 0}):Play()
	TweenService:Create(ProgressLabel, t, {TextTransparency = 0}):Play()
	TweenService:Create(DetailLabel, t, {TextTransparency = 0}):Play()
end

local function animateOut()
	local t = TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.In)

	TweenService:Create(Backdrop, t, {BackgroundTransparency = 1}):Play()
	TweenService:Create(Container, t, {BackgroundTransparency = 1}):Play()
	TweenService:Create(ContainerStroke, t, {Transparency = 1}):Play()
	TweenService:Create(Topbar, t, {BackgroundTransparency = 1}):Play()
	TweenService:Create(Title, t, {TextTransparency = 1}):Play()
	TweenService:Create(Subtitle, t, {TextTransparency = 1}):Play()
	TweenService:Create(StatusLabel, t, {TextTransparency = 1}):Play()
	TweenService:Create(ProgressBg, t, {BackgroundTransparency = 1}):Play()
	TweenService:Create(ProgressFill, t, {BackgroundTransparency = 1}):Play()
	TweenService:Create(ProgressGlow, t, {BackgroundTransparency = 1}):Play()
	TweenService:Create(ProgressLabel, t, {TextTransparency = 1}):Play()
	TweenService:Create(DetailLabel, t, {TextTransparency = 1}):Play()

	task.wait(0.35)
	LoadGui:Destroy()
end

animateIn()
task.wait(0.45)

-- ==========================================
-- HELPERS DE STATUS
-- ==========================================
local currentProgress = 0

local function UpdateStatus(text, detail)
	StatusLabel.Text = text
	if detail then
		DetailLabel.Text = detail
	end
end

local function SetProgress(percent, detail)
	currentProgress = percent
	local targetSize = UDim2.new(math.clamp(percent / 100, 0, 1), 0, 1, 0)
	TweenService:Create(ProgressFill, TweenInfo.new(0.25, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
		Size = targetSize
	}):Play()
	ProgressLabel.Text = math.floor(percent) .. "%"
	if detail then
		DetailLabel.Text = detail
	end
end

-- ==========================================
-- LOGICA DE DOWNLOAD
-- ==========================================
local CACHE_BUST = tostring(os.clock()):gsub("%.", "")
local BASE_URL = "https://raw.githubusercontent.com/EricDs6/SYSTEM-SCRIPT-UNIVERSAL-ROBLOX/main/"

local function fetch_module(path)
	local ok, content = pcall(function()
		return game:HttpGet(BASE_URL .. path .. "?v=" .. CACHE_BUST, true)
	end)

	if not ok or not content or content == "" then
		warn("[SYSTEM] Falha ao baixar: " .. path)
		return nil
	end

	local fn, err = loadstring(content)
	if not fn then
		warn("[SYSTEM] Erro de sintaxe em: " .. path .. " | " .. tostring(err))
		return nil
	end

	return fn
end

local function load_and_run(path)
	local fn = fetch_module(path)
	if fn then
		return fn()
	end
	return nil
end

-- ==========================================
-- 1. CORE
-- ==========================================
UpdateStatus("Carregando sistema...", "core/init.lua")
SetProgress(2, "core/init.lua")
local Core = load_and_run("core/init.lua")

if not Core then
	UpdateStatus("Erro Critico no Core!", "Abortando...")
	SetProgress(0)
	ProgressFill.BackgroundColor3 = Theme.Red
	warn("[SYSTEM] Core falhou. Abortando.")
	task.wait(1.5)
	animateOut()
	return
end

SetProgress(5, "Core carregado")

-- ==========================================
-- 2. MODULOS (download paralelo)
-- ==========================================
local categories = {
	{ name = "Combat", files = {
		"esp", "hitbox", "triggerbot", "silentaim", "nofling",
		"wallbang", "infinitehealth", "killaura", "nofalldamage", "headsize"
	}},
	{ name = "Movement", files = {
		"fly", "noclip", "sprint", "speed", "infinitejump", "bunnyhop",
		"teleportplayer", "blink", "vehiclespeed", "nojumpcooldown",
		"float", "swim", "vehiclegoto", "walkto", "orbit", "headsit",
		"vehiclefly", "spectate", "gotopart"
	}},
	{ name = "Visual", files = {
		"xray", "nightmode", "fullbright", "tracers", "crosshair", "fovchanger"
	}},
	{ name = "Utility", files = {
		"clicktp", "gravity", "customspawn", "freecam", "flashback", "coords",
		"serverrejoin", "autoclicker", "proximityinstant", "antiafk", "antikick",
		"autocollect", "fireclickdetectors", "fireproximityprompts", "btools",
		"breakvelocity", "invisibleparts"
	}},
	{ name = "Troll", files = {
		"trollfling", "targetfling", "spasms", "naked", "freeze"
	}}
}

-- Contar total
local totalFiles = 0
for _, cat in ipairs(categories) do
	totalFiles = totalFiles + #cat.files
end

-- Download paralelo
local downloaded = {}
local completed = 0

UpdateStatus("Baixando modulos...", "0/" .. totalFiles)
SetProgress(5)

for _, cat in ipairs(categories) do
	for _, fileName in ipairs(cat.files) do
		local path = "modules/" .. cat.name:lower() .. "/" .. fileName .. ".lua"
		local key = cat.name .. "/" .. fileName

		task.spawn(function()
			local fn = fetch_module(path)
			if fn then
				downloaded[key] = fn
			end
			completed += 1
			local percent = 5 + (completed / totalFiles) * 55
			SetProgress(percent, completed .. "/" .. totalFiles .. " arquivos")
		end)
	end
end

-- Esperar downloads
while completed < totalFiles do
	task.wait(0.05)
end

SetProgress(60, "Downloads concluidos")

-- Executar comandos
local executed = 0
for _, cat in ipairs(categories) do
	UpdateStatus("Carregando " .. cat.name .. "...", "")
	for _, fileName in ipairs(cat.files) do
		local key = cat.name .. "/" .. fileName
		local loadFn = downloaded[key]
		if loadFn then
			local ok1, cmdFn = pcall(loadFn)
			if ok1 and type(cmdFn) == "function" then
				local ok2, err2 = pcall(cmdFn, Core)
				if not ok2 then
					warn("[SYSTEM] Erro ao executar " .. key .. ": " .. tostring(err2))
				end
			else
				warn("[SYSTEM] Erro de sintaxe em " .. key .. ": " .. tostring(cmdFn))
			end
		else
			warn("[SYSTEM] Falha ao baixar: " .. key)
		end
		executed += 1
		local percent = 60 + (executed / totalFiles) * 38
		SetProgress(percent, key)
	end
end

SetProgress(100, "Pronto!")
UpdateStatus("Tudo pronto!", "Iniciando painel...")
task.wait(0.3)

-- ==========================================
-- 3. FECHAR LOADER E ABRIR PAINEL
-- ==========================================
animateOut()
task.wait(0.1)
Core.Initialize()