-- =============================================================================
-- SYSTEM SCRIPT UNIVERSAL - LOADER
-- Execute este script no executor para carregar tudo via loadstring
-- =============================================================================
--!nonstrict
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local CoreGui = (RunService:IsStudio() and game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")) or (gethui and gethui()) or game:GetService("CoreGui")

-- ==========================================
-- TELA DE CARREGAMENTO (LOADING UI) COM SPINNER
-- ==========================================
local LoadGui = Instance.new("ScreenGui")
LoadGui.Name = "GH_LoadingScreen"
LoadGui.ResetOnSpawn = false
LoadGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
LoadGui.Parent = CoreGui

local LoadFrame = Instance.new("Frame")
LoadFrame.Size = UDim2.new(0, 240, 0, 90) -- Caixinha um pouco mais alta
LoadFrame.Position = UDim2.new(0.5, -120, 0.5, -45)
LoadFrame.BackgroundColor3 = Color3.fromRGB(28, 28, 28) -- GH.Theme.BG
LoadFrame.BorderSizePixel = 0
LoadFrame.Parent = LoadGui
Instance.new("UICorner", LoadFrame).CornerRadius = UDim.new(0, 6)
Instance.new("UIStroke", LoadFrame).Color = Color3.fromRGB(70, 70, 70)

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Size = UDim2.new(1, 0, 0, 20)
TitleLabel.Position = UDim2.new(0, 0, 0, 10)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "SYSTEM INITIALIZING"
TitleLabel.TextColor3 = Color3.fromRGB(0, 120, 210) -- GH.Theme.Accent
TitleLabel.Font = Enum.Font.GothamBlack
TitleLabel.TextSize = 12
TitleLabel.Parent = LoadFrame

-- Criando o Spinner (Sem precisar de ID de Imagem)
local SpinnerFrame = Instance.new("Frame")
SpinnerFrame.Size = UDim2.new(0, 26, 0, 26)
SpinnerFrame.Position = UDim2.new(0.5, -13, 0, 35) -- Centralizado
SpinnerFrame.BackgroundTransparency = 1
SpinnerFrame.Parent = LoadFrame

local SpinnerCorner = Instance.new("UICorner")
SpinnerCorner.CornerRadius = UDim.new(1, 0) -- Deixa redondo
SpinnerCorner.Parent = SpinnerFrame

local SpinnerStroke = Instance.new("UIStroke")
SpinnerStroke.Thickness = 3
SpinnerStroke.Color = Color3.fromRGB(0, 120, 210) -- GH.Theme.Accent
SpinnerStroke.Parent = SpinnerFrame

-- UIGradient para criar o efeito de "cauda" no círculo
local SpinnerGradient = Instance.new("UIGradient")
SpinnerGradient.Transparency = NumberSequence.new({
    NumberSequenceKeypoint.new(0, 0),
    NumberSequenceKeypoint.new(1, 1)
})
SpinnerGradient.Parent = SpinnerStroke

-- Animação de giro infinito
local spinnerTween = TweenService:Create(
    SpinnerFrame, 
    TweenInfo.new(0.8, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, -1), -- -1 faz repetir infinitamente
    {Rotation = 360}
)
spinnerTween:Play()

local StatusLabel = Instance.new("TextLabel")
StatusLabel.Size = UDim2.new(1, 0, 0, 15)
StatusLabel.Position = UDim2.new(0, 0, 1, -22)
StatusLabel.BackgroundTransparency = 1
StatusLabel.Text = "Connecting to GitHub..."
StatusLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
StatusLabel.Font = Enum.Font.GothamMedium
StatusLabel.TextSize = 10
StatusLabel.Parent = LoadFrame

local function UpdateStatus(text)
    StatusLabel.Text = text
end

-- ==========================================
-- LÓGICA DE DOWNLOAD
-- ==========================================
local CACHE_BUST = tostring(os.clock()):gsub("%.", "")
local BASE_URL = "https://raw.githubusercontent.com/EricDs6/SYSTEM-SCRIPT-UNIVERSAL-ROBLOX/main/"

local function fetch_module(path)
    UpdateStatus("Baixando: " .. path)
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
-- 1. CORE: Inicializa o sistema compartilhado
-- ==========================================
UpdateStatus("Carregando Core...")
local Core = load_and_run("core/init.lua")

if not Core then
    UpdateStatus("Erro Crítico no Core!")
    StatusLabel.TextColor3 = Color3.fromRGB(255, 70, 70)
    SpinnerStroke.Color = Color3.fromRGB(255, 70, 70)
    spinnerTween:Pause()
    warn("[SYSTEM] Core falhou. Abortando.")
    task.wait(2)
    LoadGui:Destroy()
    return
end

-- ==========================================
-- 2. MÓDULOS POR CATEGORIA
-- ==========================================
local modules = {
    { path = "modules/combat.lua",   name = "Combat" },
    { path = "modules/movement.lua", name = "Movement" },
    { path = "modules/visual.lua",   name = "Visual" },
    { path = "modules/utility.lua",  name = "Utility" },
    { path = "modules/troll.lua",    name = "Troll" }
}

for _, mod in ipairs(modules) do
    UpdateStatus("Carregando " .. mod.name .. "...")
    
    local fn = fetch_module(mod.path)
    
    if fn then
        local ok, result = pcall(fn, Core)
        if not ok then
            warn("[SYSTEM] Erro no módulo " .. mod.name .. ": " .. tostring(result))
        elseif type(result) == "function" then
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
UpdateStatus("Tudo pronto! Iniciando...")

-- Transição suave para desaparecer (Fade Out)
TweenService:Create(LoadFrame, TweenInfo.new(0.25), {BackgroundTransparency = 1}):Play()
TweenService:Create(TitleLabel, TweenInfo.new(0.25), {TextTransparency = 1}):Play()
TweenService:Create(StatusLabel, TweenInfo.new(0.25), {TextTransparency = 1}):Play()
TweenService:Create(SpinnerStroke, TweenInfo.new(0.25), {Transparency = 1}):Play()
LoadFrame.UIStroke.Transparency = 1

task.wait(0.25)
LoadGui:Destroy()

-- Chama o painel principal APÓS a tela de load sumir completamente
Core.Initialize()