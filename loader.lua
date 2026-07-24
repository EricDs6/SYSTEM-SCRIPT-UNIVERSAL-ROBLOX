-- =============================================================================
-- SYSTEM SCRIPT UNIVERSAL — LOADER
-- Execute este script no executor para carregar tudo via loadstring
-- =============================================================================
--!nonstrict

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
local Core = load_and_run("core/init.lua")
if not Core then
	warn("[SYSTEM] Core falhou. Abortando.")
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
	{ path = "modules/troll.lua",    name = "Troll" },
}

for _, mod in ipairs(modules) do
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
Core.Initialize()
