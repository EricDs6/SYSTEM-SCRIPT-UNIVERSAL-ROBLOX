-- =============================================================================
-- SYSTEM SCRIPT UNIVERSAL — LOADER
-- Execute este script no executor para carregar tudo via loadstring
-- =============================================================================
--!nonstrict

local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

-- ==========================================
-- LOADING SCREEN
-- ==========================================
local TargetGui = (RunService:IsStudio() and Players.LocalPlayer:WaitForChild("PlayerGui"))
	or (gethui and gethui())
	or CoreGui

-- Limpar tela antiga se existir
if TargetGui:FindFirstChild("SystemScript_Loading") then
	TargetGui["SystemScript_Loading"]:Destroy()
end

local LoadingGui = Instance.new("ScreenGui")
LoadingGui.Name = "SystemScript_Loading"
LoadingGui.ResetOnSpawn = false
LoadingGui.IgnoreGuiInset = true
LoadingGui.DisplayOrder = 999
LoadingGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
LoadingGui.Parent = TargetGui

-- Fundo escuro
local BG = Instance.new("Frame")
BG.Name = "BG"
BG.Size = UDim2.new(1, 0, 1, 0)
BG.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
BG.BackgroundTransparency = 0
BG.BorderSizePixel = 0
BG.Parent = LoadingGui

-- Container centralizado
local Center = Instance.new("Frame")
Center.Size = UDim2.new(0, 260, 0, 120)
Center.Position = UDim2.new(0.5, -130, 0.5, -60)
Center.BackgroundTransparency = 1
Center.Parent = BG

-- Titulo "SYSTEM"
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 32)
Title.Position = UDim2.new(0, 0, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "SYSTEM"
Title.TextColor3 = Color3.fromRGB(240, 240, 240)
Title.Font = Enum.Font.GothamBlack
Title.TextSize = 24
Title.TextTransparency = 1
Title.Parent = Center

-- Spinner (4 pontes rolando)
local SpinnerFrame = Instance.new("Frame")
SpinnerFrame.Size = UDim2.new(0, 40, 0, 40)
SpinnerFrame.Position = UDim2.new(0.5, -20, 0, 48)
SpinnerFrame.BackgroundTransparency = 1
SpinnerFrame.Parent = Center

local SpinnerCircle = Instance.new("UIStroke")
SpinnerCircle.Thickness = 2
SpinnerCircle.Color = Color3.fromRGB(0, 120, 210)
SpinnerCircle.Transparency = 0.5
SpinnerCircle.Parent = SpinnerFrame

-- Arco visivel (Frame transparente com borda visivel em um quadrante)
local Arc = Instance.new("Frame")
Arc.Size = UDim2.new(1, 0, 1, 0)
Arc.BackgroundTransparency = 1
Arc.Parent = SpinnerFrame

local ArcStroke = Instance.new("UIStroke")
ArcStroke.Thickness = 2.5
ArcStroke.Color = Color3.fromRGB(0, 160, 255)
ArcStroke.Transparency = 0
ArcStroke.Parent = Arc

local ArcCorner = Instance.new("UICorner")
ArcCorner.CornerRadius = UDim.new(1, 0)
ArcCorner.Parent = Arc

-- Linha de progresso
local ProgressBG = Instance.new("Frame")
ProgressBG.Size = UDim2.new(0, 180, 0, 3)
ProgressBG.Position = UDim2.new(0.5, -90, 0, 100)
ProgressBG.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
ProgressBG.BorderSizePixel = 0
ProgressBG.Parent = Center

local ProgressCorner = Instance.new("UICorner")
ProgressCorner.CornerRadius = UDim.new(1, 0)
ProgressCorner.Parent = ProgressBG

local ProgressBar = Instance.new("Frame")
ProgressBar.Size = UDim2.new(0, 0, 1, 0)
ProgressBar.BackgroundColor3 = Color3.fromRGB(0, 160, 255)
ProgressBar.BorderSizePixel = 0
ProgressBar.Parent = ProgressBG

local ProgressFill = Instance.new("UICorner")
ProgressFill.CornerRadius = UDim.new(1, 0)
ProgressFill.Parent = ProgressBar

-- Texto de status
local StatusText = Instance.new("TextLabel")
StatusText.Size = UDim2.new(1, 0, 0, 16)
StatusText.Position = UDim2.new(0, 0, 0, 110)
StatusText.BackgroundTransparency = 1
StatusText.Text = "Carregando..."
StatusText.TextColor3 = Color3.fromRGB(140, 140, 140)
StatusText.Font = Enum.Font.GothamMedium
StatusText.TextSize = 10
StatusText.TextTransparency = 1
StatusText.Parent = Center

-- ==========================================
-- ANIMACAO DE ENTRADA
-- ==========================================
local fadeInInfo = TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

pcall(function()
	TweenService:Create(Title, fadeInInfo, {TextTransparency = 0.2}):Play()
end)

task.delay(0.2, function()
	pcall(function()
		TweenService:Create(StatusText, fadeInInfo, {TextTransparency = 0.2}):Play()
	end)
end)

task.delay(0.3, function()
	pcall(function()
		TweenService:Create(ProgressBG, fadeInInfo, {BackgroundTransparency = 0.2}):Play()
	end)
end)

-- Spinner rotation loop
local spinning = true
task.spawn(function()
	local angle = 0
	while spinning do
		angle = angle + 4
		Arc.Rotation = angle
		SpinnerCircle.Transparency = 0.5 + math.sin(tick() * 3) * 0.3
		RunService.RenderStepped:Wait()
	end
end)

-- ==========================================
-- ESTADOS DO LOADING
-- ==========================================
local loadSteps = {
	{ text = "Baixando core...",      progress = 0.15 },
	{ text = "Carregando módulos...", progress = 0.50 },
	{ text = "Inicializando painel...", progress = 0.80 },
	{ text = "Pronto!",               progress = 1.0 },
}

local currentStep = 0

local function UpdateLoading(step)
	if step > currentStep then
		currentStep = step
		local data = loadSteps[step]
		if data then
			StatusText.Text = data.text
			pcall(function()
				TweenService:Create(ProgressBar, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
					Size = UDim2.new(data.progress, 0, 1, 0)
				}):Play()
			end)
		end
	end
end

-- ==========================================
-- FETCH MODULE (original)
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
		warn("[SYSTEM] Erro de sintaxe em: " .. path .. " — " .. tostring(err))
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
-- 1. CORE: Inicialização e sistema compartilhado
-- ==========================================
UpdateLoading(1)
local Core = load_and_run("core/init.lua")
if not Core then
	warn("[SYSTEM] Core falhou. Abortando.")
	spinning = false
	LoadingGui:Destroy()
	return
end

-- ==========================================
-- 2. MÓDULOS POR CATEGORIA
-- ==========================================
UpdateLoading(2)
local modules = {
	{ path = "modules/combat.lua",   name = "Combat" },
	{ path = "modules/movement.lua", name = "Movement" },
	{ path = "modules/visual.lua",   name = "Visual" },
	{ path = "modules/utility.lua",  name = "Utility" },
	{ path = "modules/troll.lua",    name = "Troll" },
}

for _, mod in ipairs(modules) do
	local fn = fetch_module(mod.path)
	if fn then
		-- Módulos retornam uma função que recebe GH
		-- Precisamos chamá-la passando o Core
		local ok, result = pcall(fn, Core)
		if not ok then
			warn("[SYSTEM] Erro no módulo " .. mod.name .. ": " .. tostring(result))
		elseif type(result) == "function" then
			-- Se retornou uma função, chamá-la com Core
			local ok2, err2 = pcall(result, Core)
			if not ok2 then
				warn("[SYSTEM] Erro ao executar módulo " .. mod.name .. ": " .. tostring(err2))
			end
		end
	else
		warn("[SYSTEM] Módulo não encontrado: " .. mod.path)
	end
end

-- ==========================================
-- 3. INICIALIZAR: Montar UI + restaurar config
-- ==========================================
UpdateLoading(3)
Core.Initialize()

-- ==========================================
-- 4. FADE OUT + DELAY PARA INJECAO
-- ==========================================
UpdateLoading(4)

-- Aguardar um tempo para garantir que o painel injetou corretamente
task.wait(1.2)

-- Fade out suave da tela de loading
spinning = false
local fadeOutInfo = TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
pcall(function()
	TweenService:Create(Title, fadeOutInfo, {TextTransparency = 1}):Play()
	TweenService:Create(StatusText, fadeOutInfo, {TextTransparency = 1}):Play()
	TweenService:Create(ProgressBG, fadeOutInfo, {BackgroundTransparency = 1}):Play()
	TweenService:Create(ProgressBar, fadeOutInfo, {BackgroundTransparency = 1}):Play()
	TweenService:Create(BG, fadeOutInfo, {BackgroundTransparency = 1}):Play()
end)

task.delay(0.6, function()
	LoadingGui:Destroy()
end)
