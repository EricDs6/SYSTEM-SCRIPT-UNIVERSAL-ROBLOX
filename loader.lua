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
	CardHover = Color3.fromRGB(38, 38, 44),
	Accent = Color3.fromRGB(80, 140, 255),
	AccentGlow = Color3.fromRGB(60, 120, 255),
	AccentDim = Color3.fromRGB(40, 80, 180),
	On = Color3.fromRGB(0, 220, 120),
	Red = Color3.fromRGB(255, 60, 60),
	Text = Color3.fromRGB(235, 235, 240),
	TextDim = Color3.fromRGB(130, 130, 145),
	TextMuted = Color3.fromRGB(80, 80, 95),
	Border = Color3.fromRGB(50, 50, 60),
	BorderLight = Color3.fromRGB(65, 65, 75),
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
Container.Size = UDim2.new(0, 340, 0, 200)
Container.BackgroundColor3 = Theme.BG
Container.BackgroundTransparency = 1
Container.BorderSizePixel = 0
Container.Parent = Backdrop
Instance.new("UICorner", Container).CornerRadius = UDim.new(0, 12)

local ContainerStroke = Instance.new("UIStroke")
ContainerStroke.Color = Theme.Border
ContainerStroke.Thickness = 1
ContainerStroke.Transparency = 1
ContainerStroke.Parent = Container

-- Linha de destaque no topo (accent glow bar)
local AccentBar = Instance.new("Frame")
AccentBar.Name = "AccentBar"
AccentBar.Size = UDim2.new(0, 0, 0, 2)
AccentBar.Position = UDim2.new(0.5, 0, 0, 0)
AccentBar.AnchorPoint = Vector2.new(0.5, 0)
AccentBar.BackgroundColor3 = Theme.Accent
AccentBar.BackgroundTransparency = 0.15
AccentBar.BorderSizePixel = 0
AccentBar.Parent = Container
Instance.new("UICorner", AccentBar).CornerRadius = UDim.new(1, 0)

-- Glow da accent bar
local AccentGlow = Instance.new("Frame")
AccentGlow.Name = "AccentGlow"
AccentGlow.Size = UDim2.new(1, 20, 1, 10)
AccentGlow.Position = UDim2.new(0.5, 0, 0, 0)
AccentGlow.AnchorPoint = Vector2.new(0.5, 0)
AccentGlow.BackgroundColor3 = Theme.AccentGlow
AccentGlow.BackgroundTransparency = 0.92
AccentGlow.BorderSizePixel = 0
AccentGlow.ZIndex = 0
AccentGlow.Parent = Container
Instance.new("UICorner", AccentGlow).CornerRadius = UDim.new(1, 0)

-- Topbar
local Topbar = Instance.new("Frame")
Topbar.Name = "Topbar"
Topbar.Size = UDim2.new(1, 0, 0, 44)
Topbar.Position = UDim2.new(0, 0, 0, 8)
Topbar.BackgroundTransparency = 1
Topbar.BorderSizePixel = 0
Topbar.Parent = Container

-- Titulo
local Title = Instance.new("TextLabel")
Title.Name = "Title"
Title.Size = UDim2.new(1, -24, 0, 20)
Title.Position = UDim2.new(0, 16, 0, 2)
Title.BackgroundTransparency = 1
Title.Text = "SYSTEM SCRIPT"
Title.TextColor3 = Theme.Accent
Title.Font = FontBold
Title.TextSize = 16
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.TextTransparency = 1
Title.Parent = Topbar

-- Subtitle / versao badge
local VersionBadge = Instance.new("Frame")
VersionBadge.Name = "VersionBadge"
VersionBadge.Size = UDim2.new(0, 36, 0, 16)
VersionBadge.Position = UDim2.new(0, 16, 0, 24)
VersionBadge.BackgroundColor3 = Theme.AccentDim
VersionBadge.BackgroundTransparency = 0.6
VersionBadge.BorderSizePixel = 0
VersionBadge.Parent = Topbar
Instance.new("UICorner", VersionBadge).CornerRadius = UDim.new(0, 4)

local VersionText = Instance.new("TextLabel")
VersionText.Name = "VersionText"
VersionText.Size = UDim2.new(1, 0, 1, 0)
VersionText.BackgroundTransparency = 1
VersionText.Text = "v2.0"
VersionText.TextColor3 = Theme.Accent
VersionText.Font = FontMono
VersionText.TextSize = 9
VersionText.TextTransparency = 1
VersionText.Parent = VersionBadge

-- Conteudo
local Content = Instance.new("Frame")
Content.Name = "Content"
Content.Size = UDim2.new(1, -32, 1, -68)
Content.Position = UDim2.new(0, 16, 0, 60)
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

-- Progress bar container
local ProgressContainer = Instance.new("Frame")
ProgressContainer.Name = "ProgressContainer"
ProgressContainer.Size = UDim2.new(1, 0, 0, 22)
ProgressContainer.Position = UDim2.new(0, 0, 0, 22)
ProgressContainer.BackgroundTransparency = 1
ProgressContainer.Parent = Content

-- Progress bar background
local ProgressBg = Instance.new("Frame")
ProgressBg.Name = "ProgressBg"
ProgressBg.Size = UDim2.new(1, 0, 0, 6)
ProgressBg.Position = UDim2.new(0, 0, 0, 4)
ProgressBg.BackgroundColor3 = Theme.BGDark
ProgressBg.BorderSizePixel = 0
ProgressBg.BackgroundTransparency = 1
ProgressBg.Parent = ProgressContainer
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
ProgressGlow.Size = UDim2.new(1, 6, 1, 6)
ProgressGlow.Position = UDim2.new(0, -3, 0, -3)
ProgressGlow.BackgroundColor3 = Theme.AccentGlow
ProgressGlow.BackgroundTransparency = 0.88
ProgressGlow.BorderSizePixel = 0
ProgressGlow.ZIndex = 0
ProgressGlow.Parent = ProgressBg
Instance.new("UICorner", ProgressGlow).CornerRadius = UDim.new(1, 0)

-- Shimmer effect na progress bar
local Shimmer = Instance.new("Frame")
Shimmer.Name = "Shimmer"
Shimmer.Size = UDim2.new(0, 60, 1, 0)
Shimmer.Position = UDim2.new(0, -60, 0, 0)
Shimmer.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
Shimmer.BackgroundTransparency = 0.85
Shimmer.BorderSizePixel = 0
Shimmer.ZIndex = 2
Shimmer.Parent = ProgressFill
Instance.new("UICorner", Shimmer).CornerRadius = UDim.new(1, 0)
Instance.new("UIGradient", Shimmer).Transparency = NumberSequence.new({
	NumberSequenceKeypoint.new(0, 1),
	NumberSequenceKeypoint.new(0.4, 0.5),
	NumberSequenceKeypoint.new(0.5, 0),
	NumberSequenceKeypoint.new(0.6, 0.5),
	NumberSequenceKeypoint.new(1, 1),
})

-- Percent label
local ProgressLabel = Instance.new("TextLabel")
ProgressLabel.Name = "Percent"
ProgressLabel.Size = UDim2.new(0, 40, 0, 16)
ProgressLabel.Position = UDim2.new(1, -40, 0, 0)
ProgressLabel.BackgroundTransparency = 1
ProgressLabel.Text = "0%"
ProgressLabel.TextColor3 = Theme.TextDim
ProgressLabel.Font = FontMono
ProgressLabel.TextSize = 10
ProgressLabel.TextXAlignment = Enum.TextXAlignment.Right
ProgressLabel.TextTransparency = 1
ProgressLabel.Parent = ProgressContainer

-- Detail label
local DetailLabel = Instance.new("TextLabel")
DetailLabel.Name = "Detail"
DetailLabel.Size = UDim2.new(1, 0, 0, 14)
DetailLabel.Position = UDim2.new(0, 0, 0, 50)
DetailLabel.BackgroundTransparency = 1
DetailLabel.Text = ""
DetailLabel.TextColor3 = Theme.TextMuted
DetailLabel.Font = FontMono
DetailLabel.TextSize = 9
DetailLabel.TextXAlignment = Enum.TextXAlignment.Left
DetailLabel.TextTransparency = 1
DetailLabel.Parent = Content

-- Linha separadora sutil
local Separator = Instance.new("Frame")
Separator.Name = "Separator"
Separator.Size = UDim2.new(1, 0, 0, 1)
Separator.Position = UDim2.new(0, 0, 0, 46)
Separator.BackgroundColor3 = Theme.Border
Separator.BackgroundTransparency = 0.8
Separator.BorderSizePixel = 0
Separator.Parent = Content

-- ==========================================
-- ANIMACAO SHIMMER LOOP
-- ==========================================
local shimmerActive = false

local function startShimmer()
	if shimmerActive then return end
	shimmerActive = true
	task.spawn(function()
		while shimmerActive do
			Shimmer.Position = UDim2.new(0, -60, 0, 0)
			Shimmer.BackgroundTransparency = 0.85
			local tween = TweenService:Create(Shimmer, TweenInfo.new(1.2, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {
				Position = UDim2.new(1, 0, 0, 0),
			})
			tween:Play()
			tween.Completed:Wait()
			task.wait(0.3)
		end
	end)
end

local function stopShimmer()
	shimmerActive = false
end

-- ==========================================
-- ANIMACAO DE ENTRADA (staggered)
-- ==========================================
local function animateIn()
	local tFast = TweenInfo.new(0.35, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
	local tSlow = TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)

	-- Backdrop primeiro
	TweenService:Create(Backdrop, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {BackgroundTransparency = 0.35}):Play()

	task.wait(0.08)

	-- Container
	TweenService:Create(Container, tSlow, {BackgroundTransparency = 0}):Play()
	TweenService:Create(ContainerStroke, tSlow, {Transparency = 0}):Play()

	task.wait(0.06)

	-- Accent bar com efeito de expansao
	TweenService:Create(AccentBar, TweenInfo.new(0.6, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Size = UDim2.new(0.6, 0, 0, 2)}):Play()
	TweenService:Create(AccentGlow, TweenInfo.new(0.6, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Size = UDim2.new(0.6, 26, 1, 10)}):Play()

	task.wait(0.1)

	-- Topbar elements
	TweenService:Create(Title, tFast, {TextTransparency = 0}):Play()
	TweenService:Create(VersionBadge, tFast, {BackgroundTransparency = 0.6}):Play()
	TweenService:Create(VersionText, tFast, {TextTransparency = 0.1}):Play()

	task.wait(0.12)

	-- Content
	TweenService:Create(StatusLabel, tFast, {TextTransparency = 0}):Play()
	TweenService:Create(ProgressBg, tFast, {BackgroundTransparency = 0}):Play()
	TweenService:Create(ProgressFill, tFast, {BackgroundTransparency = 0}):Play()
	TweenService:Create(ProgressLabel, tFast, {TextTransparency = 0}):Play()
	TweenService:Create(DetailLabel, tFast, {TextTransparency = 0}):Play()

	task.wait(0.3)
	startShimmer()
end

local function animateOut()
	stopShimmer()
	local t = TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.In)

	TweenService:Create(Backdrop, t, {BackgroundTransparency = 1}):Play()
	TweenService:Create(Container, t, {BackgroundTransparency = 1}):Play()
	TweenService:Create(ContainerStroke, t, {Transparency = 1}):Play()
	TweenService:Create(AccentBar, t, {BackgroundTransparency = 1}):Play()
	TweenService:Create(AccentGlow, t, {BackgroundTransparency = 1}):Play()
	TweenService:Create(Title, t, {TextTransparency = 1}):Play()
	TweenService:Create(VersionBadge, t, {BackgroundTransparency = 1}):Play()
	TweenService:Create(VersionText, t, {TextTransparency = 1}):Play()
	TweenService:Create(StatusLabel, t, {TextTransparency = 1}):Play()
	TweenService:Create(ProgressBg, t, {BackgroundTransparency = 1}):Play()
	TweenService:Create(ProgressFill, t, {BackgroundTransparency = 1}):Play()
	TweenService:Create(ProgressGlow, t, {BackgroundTransparency = 1}):Play()
	TweenService:Create(ProgressLabel, t, {TextTransparency = 1}):Play()
	TweenService:Create(DetailLabel, t, {TextTransparency = 1}):Play()
	TweenService:Create(Separator, t, {BackgroundTransparency = 1}):Play()

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
	TweenService:Create(ProgressFill, TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
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
	AccentBar.BackgroundColor3 = Theme.Red
	AccentGlow.BackgroundColor3 = Theme.Red
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
