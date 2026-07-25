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
-- THEME
-- ==========================================
local Theme = {
	BG = Color3.fromRGB(18, 18, 22),
	BGDark = Color3.fromRGB(12, 12, 15),
	Topbar = Color3.fromRGB(22, 22, 26),
	Card = Color3.fromRGB(28, 28, 32),
	Accent = Color3.fromRGB(0, 120, 212),
	AccentGlow = Color3.fromRGB(0, 150, 255),
	AccentDim = Color3.fromRGB(0, 99, 177),
	On = Color3.fromRGB(0, 120, 212),
	Red = Color3.fromRGB(255, 60, 60),
	Text = Color3.fromRGB(235, 235, 240),
	TextDim = Color3.fromRGB(140, 140, 155),
	TextMuted = Color3.fromRGB(90, 90, 105),
	Border = Color3.fromRGB(50, 50, 58),
	BorderLight = Color3.fromRGB(60, 60, 68),
}

local Font = Enum.Font.GothamMedium
local FontBold = Enum.Font.GothamBold
local FontMono = Enum.Font.RobotoMono

-- ==========================================
-- TELA DE CARREGAMENTO (canto inferior direito, profissional)
-- ==========================================
local LoadGui = Instance.new("ScreenGui")
LoadGui.Name = "GH_LoadingScreen"
LoadGui.ResetOnSpawn = false
LoadGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
LoadGui.IgnoreGuiInset = true
LoadGui.Parent = CoreGui

-- Container principal
local Container = Instance.new("Frame")
Container.Name = "Container"
Container.AnchorPoint = Vector2.new(1, 1)
Container.Position = UDim2.new(1, -10, 1, -10)
Container.Size = UDim2.new(0, 190, 0, 52)
Container.BackgroundColor3 = Theme.BG
Container.BackgroundTransparency = 0.25
Container.BorderSizePixel = 0
Container.Parent = LoadGui
Instance.new("UICorner", Container).CornerRadius = UDim.new(0, 8)

local ContainerStroke = Instance.new("UIStroke")
ContainerStroke.Color = Theme.Border
ContainerStroke.Thickness = 1
ContainerStroke.Transparency = 0.4
ContainerStroke.Parent = Container

-- ==========================================
-- LINHA 1: titulo + percentual
-- ==========================================
local LoadingText = Instance.new("TextLabel")
LoadingText.Name = "LoadingText"
LoadingText.Size = UDim2.new(1, -52, 0, 14)
LoadingText.Position = UDim2.new(0, 10, 0, 6)
LoadingText.BackgroundTransparency = 1
LoadingText.Text = "SYSTEM"
LoadingText.TextColor3 = Theme.Accent
LoadingText.Font = FontBold
LoadingText.TextSize = 11
LoadingText.TextXAlignment = Enum.TextXAlignment.Left
LoadingText.TextTransparency = 1
LoadingText.Parent = Container

local ProgressLabel = Instance.new("TextLabel")
ProgressLabel.Name = "Percent"
ProgressLabel.Size = UDim2.new(0, 40, 0, 14)
ProgressLabel.Position = UDim2.new(1, -50, 0, 6)
ProgressLabel.BackgroundTransparency = 1
ProgressLabel.Text = "0%"
ProgressLabel.TextColor3 = Theme.TextDim
ProgressLabel.Font = FontMono
ProgressLabel.TextSize = 10
ProgressLabel.TextXAlignment = Enum.TextXAlignment.Right
ProgressLabel.TextTransparency = 1
ProgressLabel.Parent = Container

-- ==========================================
-- LINHA 2: status
-- ==========================================
local StatusLabel = Instance.new("TextLabel")
StatusLabel.Name = "Status"
StatusLabel.Size = UDim2.new(1, -20, 0, 12)
StatusLabel.Position = UDim2.new(0, 10, 0, 22)
StatusLabel.BackgroundTransparency = 1
StatusLabel.Text = "Inicializando..."
StatusLabel.TextColor3 = Theme.TextMuted
StatusLabel.Font = Font
StatusLabel.TextSize = 9
StatusLabel.TextXAlignment = Enum.TextXAlignment.Left
StatusLabel.TextTransparency = 1
StatusLabel.Parent = Container

-- ==========================================
-- LINHA 3: barra de progresso (fundo da container)
-- ==========================================
local BAR_HEIGHT = 3

local BarBg = Instance.new("Frame")
BarBg.Name = "BarBg"
BarBg.Size = UDim2.new(1, -20, 0, BAR_HEIGHT)
BarBg.Position = UDim2.new(0, 10, 1, -10)
BarBg.AnchorPoint = Vector2.new(0, 1)
BarBg.BackgroundColor3 = Theme.BGDark
BarBg.BackgroundTransparency = 0.3
BarBg.BorderSizePixel = 0
BarBg.Parent = Container
Instance.new("UICorner", BarBg).CornerRadius = UDim.new(1, 0)

local BarFill = Instance.new("Frame")
BarFill.Name = "BarFill"
BarFill.Size = UDim2.new(0, 0, 1, 0)
BarFill.BackgroundColor3 = Theme.Accent
BarFill.BorderSizePixel = 0
BarFill.Parent = BarBg
Instance.new("UICorner", BarFill).CornerRadius = UDim.new(1, 0)

-- ==========================================
-- ANIMACAO DE ENTRADA (sutil, sem backdrop)
-- ==========================================
local function animateIn()
	local tFast = TweenInfo.new(0.4, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)

	Container.BackgroundTransparency = 1
	ContainerStroke.Transparency = 1

	TweenService:Create(Container, tFast, {BackgroundTransparency = 0.25}):Play()
	TweenService:Create(ContainerStroke, tFast, {Transparency = 0.4}):Play()

	TweenService:Create(LoadingText, tFast, {TextTransparency = 0}):Play()
	TweenService:Create(ProgressLabel, tFast, {TextTransparency = 0}):Play()
	TweenService:Create(StatusLabel, tFast, {TextTransparency = 0}):Play()
end

local function animateOut()
	local t = TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.In)

	TweenService:Create(Container, t, {BackgroundTransparency = 1}):Play()
	TweenService:Create(ContainerStroke, t, {Transparency = 1}):Play()
	TweenService:Create(LoadingText, t, {TextTransparency = 1}):Play()
	TweenService:Create(ProgressLabel, t, {TextTransparency = 1}):Play()
	TweenService:Create(StatusLabel, t, {TextTransparency = 1}):Play()

	task.wait(0.35)
	LoadGui:Destroy()
end

animateIn()
task.wait(0.3)

-- ==========================================
-- HELPERS DE STATUS
-- ==========================================
local currentProgress = 0

local function UpdateStatus(text, detail)
	StatusLabel.Text = text
end

local function SetProgress(percent, detail)
	currentProgress = percent
	ProgressLabel.Text = math.floor(percent) .. "%"

	-- Animar fill da barra
	TweenService:Create(BarFill, TweenInfo.new(0.2, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
		Size = UDim2.new(percent / 100, 0, 1, 0),
	}):Play()
end

-- ==========================================
-- LOGICA DE DOWNLOAD (com retry e cache bust)
-- ==========================================
local CACHE_BUST = tostring(os.clock()):gsub("%.", "") .. "_" .. tostring(math.random(100000, 999999))
local BASE_URL = "https://raw.githubusercontent.com/EricDs6/SYSTEM-SCRIPT-UNIVERSAL-ROBLOX/main/"

-- Verificar versao mais recente do GitHub
local LatestCommitHash = "unknown"
local LatestCommitDate = "unknown"
do
	local ok, result = pcall(function()
		return game:HttpGet("https://api.github.com/repos/EricDs6/SYSTEM-SCRIPT-UNIVERSAL-ROBLOX/commits/main", true)
	end)
	if ok and result then
		local HttpService = game:GetService("HttpService")
		local data = HttpService:JSONDecode(result)
		if data and data.sha then
			LatestCommitHash = string.sub(data.sha, 1, 7)
			local dateRaw = data.commit and data.commit.author and data.commit.author.date or ""
			local year, month, day, hour, min = dateRaw:match("(%d+)-(%d+)-(%d+)T(%d+):(%d+)")
			if year then
				LatestCommitDate = string.format("%s/%s/%s %s:%s", day, month, year, hour, min)
			end
			UpdateStatus("v" .. LatestCommitHash)
		end
	end
end

local function fetch_module(path)
	local MAX_RETRIES = 3
	local content = nil

	for attempt = 1, MAX_RETRIES do
		local ok, result = pcall(function()
			return game:HttpGet(BASE_URL .. path .. "?v=" .. CACHE_BUST, true)
		end)

		if ok and result and result ~= "" then
			content = result
			break
		end

		if attempt < MAX_RETRIES then
			warn("[SYSTEM] Tentativa " .. attempt .. "/" .. MAX_RETRIES .. " falhou: " .. path .. " - retrying...")
			task.wait(0.5 * attempt) -- Backoff: 0.5s, 1.0s
		else
			warn("[SYSTEM] FALHA ao baixar apos " .. MAX_RETRIES .. " tentativas: " .. path)
		end
	end

	if not content then
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
UpdateStatus("Baixando core...")
SetProgress(2)
local Core = load_and_run("core/init.lua")

if not Core then
	UpdateStatus("Erro no Core!")
	SetProgress(0)
	LoadingText.TextColor3 = Theme.Red
	warn("[SYSTEM] Core falhou. Abortando.")
	task.wait(1.5)
	animateOut()
	return
end

SetProgress(5)

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
		"clicktp", "gravity", "customspawn", "freecam", "flashback", "coords", "thirdperson",
		"serverrejoin", "autoclicker", "proximityinstant", "antiafk", "antikick",
		"autocollect", "fireclickdetectors", "fireproximityprompts", "btools",
		"breakvelocity", "invisibleparts"
	}},
	{ name = "Troll", files = {
		"trollfling", "targetfling", "spasms", "naked", "freeze", "pushall"
	}}
}

local totalFiles = 0
for _, cat in ipairs(categories) do
	totalFiles = totalFiles + #cat.files
end

local downloaded = {}
local completed = 0

UpdateStatus("Baixando modulos...")
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
			SetProgress(percent)
		end)
	end
end

while completed < totalFiles do
	task.wait(0.05)
end

SetProgress(60)

local executed = 0
for _, cat in ipairs(categories) do
	UpdateStatus(cat.name .. "...")
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
		SetProgress(percent)
	end
end

SetProgress(100)
UpdateStatus("Pronto!")
LoadingText.Text = "SYSTEM"
task.wait(0.3)

-- ==========================================
-- 3. FECHAR LOADER E ABRIR PAINEL
-- ==========================================
animateOut()
task.wait(0.1)

-- Passar versao para o Core
Core.Version = { Hash = LatestCommitHash, Date = LatestCommitDate }

Core.Initialize()
