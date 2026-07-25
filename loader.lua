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
-- TELA DE CARREGAMENTO
-- ==========================================
local LoadGui = Instance.new("ScreenGui")
LoadGui.Name = "GH_LoadingScreen"
LoadGui.ResetOnSpawn = false
LoadGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
LoadGui.IgnoreGuiInset = true
LoadGui.Parent = CoreGui

-- Backdrop
local Backdrop = Instance.new("Frame")
Backdrop.Name = "Backdrop"
Backdrop.Size = UDim2.new(1, 0, 1, 0)
Backdrop.BackgroundColor3 = Color3.new(0, 0, 0)
Backdrop.BackgroundTransparency = 1
Backdrop.BorderSizePixel = 0
Backdrop.Parent = LoadGui

-- Container principal
local Container = Instance.new("Frame")
Container.Name = "Container"
Container.AnchorPoint = Vector2.new(0.5, 0.5)
Container.Position = UDim2.new(0.5, 0, 0.5, 0)
Container.Size = UDim2.new(0, 340, 0, 130)
Container.BackgroundColor3 = Theme.BG
Container.BackgroundTransparency = 1
Container.BorderSizePixel = 0
Container.Parent = Backdrop
Instance.new("UICorner", Container).CornerRadius = UDim.new(0, 10)

local ContainerStroke = Instance.new("UIStroke")
ContainerStroke.Color = Theme.Border
ContainerStroke.Thickness = 1
ContainerStroke.Transparency = 1
ContainerStroke.Parent = Container

-- ==========================================
-- BARRA SEGMENTADA
-- ==========================================
local BAR_SEGMENTS = 20
local BAR_WIDTH = 290
local BAR_HEIGHT = 24
local SEG_GAP = 3
local SEG_WIDTH = (BAR_WIDTH - (BAR_SEGMENTS - 1) * SEG_GAP) / BAR_SEGMENTS

local BarContainer = Instance.new("Frame")
BarContainer.Name = "BarContainer"
BarContainer.Size = UDim2.new(0, BAR_WIDTH, 0, BAR_HEIGHT)
BarContainer.Position = UDim2.new(0.5, 0, 0, 30)
BarContainer.AnchorPoint = Vector2.new(0.5, 0)
BarContainer.BackgroundTransparency = 1
BarContainer.Parent = Container

-- Borda externa da barra
local BarBorder = Instance.new("Frame")
BarBorder.Name = "BarBorder"
BarBorder.Size = UDim2.new(1, 6, 1, 6)
BarBorder.Position = UDim2.new(0, -3, 0, -3)
BarBorder.BackgroundColor3 = Theme.Border
BarBorder.BackgroundTransparency = 0.3
BarBorder.BorderSizePixel = 0
BarBorder.ZIndex = 0
BarBorder.Parent = BarContainer
Instance.new("UICorner", BarBorder).CornerRadius = UDim.new(0, 4)

-- Fundo da barra
local BarBg = Instance.new("Frame")
BarBg.Name = "BarBg"
BarBg.Size = UDim2.new(1, 0, 1, 0)
BarBg.BackgroundColor3 = Theme.BGDark
BarBg.BackgroundTransparency = 0.3
BarBg.BorderSizePixel = 0
BarBg.Parent = BarContainer
Instance.new("UICorner", BarBg).CornerRadius = UDim.new(0, 3)

-- Glow da barra
local BarGlow = Instance.new("Frame")
BarGlow.Name = "BarGlow"
BarGlow.Size = UDim2.new(1, 14, 1, 14)
BarGlow.Position = UDim2.new(0, -7, 0, -7)
BarGlow.BackgroundColor3 = Theme.AccentGlow
BarGlow.BackgroundTransparency = 0.94
BarGlow.BorderSizePixel = 0
BarGlow.ZIndex = -1
BarGlow.Parent = BarContainer
Instance.new("UICorner", BarGlow).CornerRadius = UDim.new(0, 6)

-- Criar segmentos
local Segments = {}
for i = 1, BAR_SEGMENTS do
	local seg = Instance.new("Frame")
	seg.Name = "Seg_" .. i
	seg.Size = UDim2.new(0, SEG_WIDTH, 1, -4)
	seg.Position = UDim2.new(0, (i - 1) * (SEG_WIDTH + SEG_GAP), 0, 2)
	seg.BackgroundColor3 = Theme.AccentDim
	seg.BackgroundTransparency = 1
	seg.BorderSizePixel = 0
	seg.Parent = BarContainer
	Instance.new("UICorner", seg).CornerRadius = UDim.new(0, 2)

	Segments[i] = seg
end

-- Shimmer effect
local Shimmer = Instance.new("Frame")
Shimmer.Name = "Shimmer"
Shimmer.Size = UDim2.new(0, 50, 1, 0)
Shimmer.Position = UDim2.new(0, -50, 0, 0)
Shimmer.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
Shimmer.BackgroundTransparency = 0.82
Shimmer.BorderSizePixel = 0
Shimmer.ZIndex = 3
Shimmer.ClipsDescendants = true
Shimmer.Parent = BarContainer
Instance.new("UICorner", Shimmer).CornerRadius = UDim.new(0, 2)
local shimmerGrad = Instance.new("UIGradient", Shimmer)
shimmerGrad.Transparency = NumberSequence.new({
	NumberSequenceKeypoint.new(0, 1),
	NumberSequenceKeypoint.new(0.35, 0.4),
	NumberSequenceKeypoint.new(0.5, 0),
	NumberSequenceKeypoint.new(0.65, 0.4),
	NumberSequenceKeypoint.new(1, 1),
})

-- ==========================================
-- TEXTOS
-- ==========================================
-- Loading text (principal)
local LoadingText = Instance.new("TextLabel")
LoadingText.Name = "LoadingText"
LoadingText.Size = UDim2.new(1, -32, 0, 22)
LoadingText.Position = UDim2.new(0, 16, 0, 64)
LoadingText.BackgroundTransparency = 1
LoadingText.Text = "LOADING..."
LoadingText.TextColor3 = Theme.Text
LoadingText.Font = FontBold
LoadingText.TextSize = 15
LoadingText.TextXAlignment = Enum.TextXAlignment.Left
LoadingText.TextTransparency = 1
LoadingText.Parent = Container

-- Percent label
local ProgressLabel = Instance.new("TextLabel")
ProgressLabel.Name = "Percent"
ProgressLabel.Size = UDim2.new(0, 50, 0, 22)
ProgressLabel.Position = UDim2.new(1, -66, 0, 64)
ProgressLabel.BackgroundTransparency = 1
ProgressLabel.Text = "0%"
ProgressLabel.TextColor3 = Theme.TextDim
ProgressLabel.Font = FontMono
ProgressLabel.TextSize = 11
ProgressLabel.TextXAlignment = Enum.TextXAlignment.Right
ProgressLabel.TextTransparency = 1
ProgressLabel.Parent = Container

-- Status label
local StatusLabel = Instance.new("TextLabel")
StatusLabel.Name = "Status"
StatusLabel.Size = UDim2.new(1, -32, 0, 14)
StatusLabel.Position = UDim2.new(0, 16, 0, 92)
StatusLabel.BackgroundTransparency = 1
StatusLabel.Text = "Inicializando..."
StatusLabel.TextColor3 = Theme.TextDim
StatusLabel.Font = Font
StatusLabel.TextSize = 11
StatusLabel.TextXAlignment = Enum.TextXAlignment.Left
StatusLabel.TextTransparency = 1
StatusLabel.Parent = Container

-- Detail label
local DetailLabel = Instance.new("TextLabel")
DetailLabel.Name = "Detail"
DetailLabel.Size = UDim2.new(1, -32, 0, 12)
DetailLabel.Position = UDim2.new(0, 16, 0, 108)
DetailLabel.BackgroundTransparency = 1
DetailLabel.Text = ""
DetailLabel.TextColor3 = Theme.TextMuted
DetailLabel.Font = FontMono
DetailLabel.TextSize = 9
DetailLabel.TextXAlignment = Enum.TextXAlignment.Left
DetailLabel.TextTransparency = 1
DetailLabel.Parent = Container

-- ==========================================
-- SHIMMER LOOP
-- ==========================================
local shimmerActive = false

local function startShimmer()
	if shimmerActive then return end
	shimmerActive = true
	task.spawn(function()
		while shimmerActive do
			Shimmer.Position = UDim2.new(0, -50, 0, 0)
			Shimmer.BackgroundTransparency = 0.82
			local tween = TweenService:Create(Shimmer, TweenInfo.new(1.0, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {
				Position = UDim2.new(1, 0, 0, 0),
			})
			tween:Play()
			tween.Completed:Wait()
			task.wait(0.4)
		end
	end)
end

local function stopShimmer()
	shimmerActive = false
end

-- ==========================================
-- PULSE NA BORDA (efeito breathing)
-- ==========================================
local pulseActive = false

local function startPulse()
	if pulseActive then return end
	pulseActive = true
	task.spawn(function()
		while pulseActive do
			local t1 = TweenService:Create(ContainerStroke, TweenInfo.new(1.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
				Color = Theme.AccentDim,
				Transparency = 0.3,
			})
			t1:Play()
			t1.Completed:Wait()
			local t2 = TweenService:Create(ContainerStroke, TweenInfo.new(1.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
				Color = Theme.Border,
				Transparency = 0,
			})
			t2:Play()
			t2.Completed:Wait()
		end
	end)
end

local function stopPulse()
	pulseActive = false
end

-- ==========================================
-- ANIMACAO DE ENTRADA
-- ==========================================
local function animateIn()
	local tFast = TweenInfo.new(0.35, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
	local tSlow = TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)

	TweenService:Create(Backdrop, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {BackgroundTransparency = 0.35}):Play()
	task.wait(0.08)

	TweenService:Create(Container, tSlow, {BackgroundTransparency = 0}):Play()
	TweenService:Create(ContainerStroke, tSlow, {Transparency = 0}):Play()
	task.wait(0.1)

	TweenService:Create(BarBorder, tFast, {BackgroundTransparency = 0.3}):Play()
	TweenService:Create(BarBg, tFast, {BackgroundTransparency = 0.3}):Play()
	TweenService:Create(BarGlow, tFast, {BackgroundTransparency = 0.94}):Play()
	task.wait(0.08)

	-- Loading text aparece
	TweenService:Create(LoadingText, tFast, {TextTransparency = 0}):Play()
	TweenService:Create(ProgressLabel, tFast, {TextTransparency = 0}):Play()
	task.wait(0.1)

	TweenService:Create(StatusLabel, tFast, {TextTransparency = 0}):Play()
	TweenService:Create(DetailLabel, tFast, {TextTransparency = 0}):Play()

	task.wait(0.3)
	startShimmer()
	startPulse()
end

local function animateOut()
	stopShimmer()
	stopPulse()
	local t = TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.In)

	TweenService:Create(Backdrop, t, {BackgroundTransparency = 1}):Play()
	TweenService:Create(Container, t, {BackgroundTransparency = 1}):Play()
	TweenService:Create(ContainerStroke, t, {Transparency = 1}):Play()
	TweenService:Create(BarBorder, t, {BackgroundTransparency = 1}):Play()
	TweenService:Create(BarBg, t, {BackgroundTransparency = 1}):Play()
	TweenService:Create(BarGlow, t, {BackgroundTransparency = 1}):Play()
	for _, seg in ipairs(Segments) do
		TweenService:Create(seg, t, {BackgroundTransparency = 1}):Play()
	end
	TweenService:Create(LoadingText, t, {TextTransparency = 1}):Play()
	TweenService:Create(ProgressLabel, t, {TextTransparency = 1}):Play()
	TweenService:Create(StatusLabel, t, {TextTransparency = 1}):Play()
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
local litSegments = 0

local function UpdateStatus(text, detail)
	StatusLabel.Text = text
	if detail then
		DetailLabel.Text = detail
	end
end

local function SetProgress(percent, detail)
	currentProgress = percent
	ProgressLabel.Text = math.floor(percent) .. "%"

	-- Calcular quantos segmentos devem estar acesos
	local targetLit = math.floor((percent / 100) * BAR_SEGMENTS)
	targetLit = math.clamp(targetLit, 0, BAR_SEGMENTS)

	-- Acender/apagar segmentos com animacao
	for i = 1, BAR_SEGMENTS do
		if i <= targetLit and i > litSegments then
			-- Acender com delay escalonado
			task.spawn(function()
				task.wait((i - litSegments) * 0.02)
				TweenService:Create(Segments[i], TweenInfo.new(0.2, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
					BackgroundTransparency = 0,
					BackgroundColor3 = Theme.Accent,
				}):Play()
			end)
		elseif i > targetLit and i <= litSegments then
			-- Apagar
			TweenService:Create(Segments[i], TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
				BackgroundTransparency = 1,
			}):Play()
		end
	end

	litSegments = targetLit

	if detail then
		DetailLabel.Text = detail
	end
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
			UpdateStatus("Versao detectada: " .. LatestCommitHash, "Commit: " .. LatestCommitDate)
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
UpdateStatus("Baixando core (ultima versao)...", "commit: " .. LatestCommitHash)
SetProgress(2, "core/init.lua")
local Core = load_and_run("core/init.lua")

if not Core then
	UpdateStatus("Erro Critico no Core!", "Abortando...")
	SetProgress(0)
	for _, seg in ipairs(Segments) do
		seg.BackgroundColor3 = Theme.Red
	end
	LoadingText.Text = "ERRO"
	LoadingText.TextColor3 = Theme.Red
	warn("[SYSTEM] Core falhou. Abortando.")
	task.wait(1.5)
	animateOut()
	return
end

SetProgress(5, "Core: " .. LatestCommitHash)

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

local totalFiles = 0
for _, cat in ipairs(categories) do
	totalFiles = totalFiles + #cat.files
end

local downloaded = {}
local completed = 0

UpdateStatus("Baixando modulos...", LatestCommitHash .. " | 0/" .. totalFiles)
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
			SetProgress(percent, completed .. "/" .. totalFiles .. " | " .. LatestCommitHash)
		end)
	end
end

while completed < totalFiles do
	task.wait(0.05)
end

SetProgress(60, "Downloads concluidos")

local executed = 0
for _, cat in ipairs(categories) do
	UpdateStatus("Carregando " .. cat.name .. "...", LatestCommitHash)
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

SetProgress(100, LatestCommitHash)
UpdateStatus("Tudo pronto!", "v" .. LatestCommitHash .. " | " .. LatestCommitDate)
LoadingText.Text = "COMPLETE"
task.wait(0.3)

-- ==========================================
-- 3. FECHAR LOADER E ABRIR PAINEL
-- ==========================================
animateOut()
task.wait(0.1)

-- Passar versao para o Core
Core.Version = { Hash = LatestCommitHash, Date = LatestCommitDate }

Core.Initialize()
