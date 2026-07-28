-- =============================================================================
-- CORE — Orquestrador (carrega todos os submodulos e exporta GH)
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
-- GH: Tabela compartilhada entre todos os modulos
-- ==========================================
local GH = {}

-- Services compartilhados
local services = {
	Players = Players,
	RunService = RunService,
	CoreGui = CoreGui,
	UserInputService = UserInputService,
	TweenService = TweenService,
	HttpService = HttpService,
	Lighting = Lighting,
}
GH.Services = services
GH.LocalPlayer = LocalPlayer

-- Target GUI
GH.TargetGui = (RunService:IsStudio() and LocalPlayer:WaitForChild("PlayerGui"))
	or (gethui and gethui())
	or CoreGui

-- ==========================================
-- UI DIMENSIONS (mantidos para compatibilidade)
-- ==========================================
GH.PanelWidth = 560
GH.PanelHeight = 400
GH.TopbarHeight = 32
GH.SidebarWidth = 130
GH.ButtonHeight = 30
GH.SettingsWidth = 220

-- TweenInfos (basico, antes dos modulos sobrescreverem)
GH.TI = TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
GH.TI_Slow = TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)

-- ==========================================
-- DOWNLOAD DE SUBMODULOS
-- ==========================================
local BASE_URL = "https://raw.githubusercontent.com/EricDs6/SYSTEM-SCRIPT-UNIVERSAL-ROBLOX/main/"

local function fetch_module(path)
	local MAX_RETRIES = 3
	local content = nil

	for attempt = 1, MAX_RETRIES do
		local ok, result = pcall(function()
			return game:HttpGet(BASE_URL .. path, true)
		end)

		if ok and result and result ~= "" then
			content = result
			break
		end

		if attempt < MAX_RETRIES then
			warn("[CORE] Tentativa " .. attempt .. "/" .. MAX_RETRIES .. " falhou: " .. path .. " - retrying...")
			task.wait(0.5 * attempt)
		else
			warn("[CORE] FALHA ao baixar apos " .. MAX_RETRIES .. " tentativas: " .. path)
		end
	end

	if not content then
		return nil
	end

	local fn, err = loadstring(content)
	if not fn then
		warn("[CORE] Erro de sintaxe em: " .. path .. " | " .. tostring(err))
		return nil
	end

	return fn
end

local function load_module(path)
	local fn = fetch_module(path)
	if fn then
		local ok, result = pcall(fn)
		if ok and type(result) == "function" then
			return result
		else
			warn("[CORE] Erro ao executar modulo: " .. path .. " | " .. tostring(result))
		end
	end
	return nil
end

-- ==========================================
-- CARREGAR SUBMODULOS NA ORDEM CORRETA
-- ==========================================

-- 1. Locales (sem dependencias)
local loadLocales = load_module("core/locales.lua")
if loadLocales then loadLocales(GH) end

-- 2. Theme + Settings + State basics
local loadSettings = load_module("core/settings.lua")
if loadSettings then loadSettings(GH, services) end

-- 3. State Management + Connections + MasterLoop + InputManager
local loadState = load_module("core/state.lua")
if loadState then loadState(GH, services) end

-- 4. Toast System
local loadToast = load_module("core/toast.lua")
if loadToast then loadToast(GH, services) end

-- 5. Player Picker + Input Picker
local loadPicker = load_module("core/picker.lua")
if loadPicker then loadPicker(GH, services) end

-- 6. Utils (SafeCall, WeakCache, ObjectPool, TweenTeleport)
local loadUtils = load_module("core/utils.lua")
if loadUtils then loadUtils(GH, services) end

-- 7. Stats/Firebase + UpdateLiveIndicators
local loadStats = load_module("core/stats.lua")
if loadStats then loadStats(GH, services) end

-- 8. FullCleanup
local loadCleanup = load_module("core/cleanup.lua")
if loadCleanup then loadCleanup(GH, services) end

-- 9. UI Builder (Initialize) — carrega por ultimo pois depende de tudo
local loadUI = load_module("core/ui.lua")
if loadUI then loadUI(GH, services) end

-- ==========================================
-- RETURN GH
-- ==========================================
return GH
