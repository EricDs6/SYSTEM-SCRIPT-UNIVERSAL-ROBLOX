-- =============================================================================
-- SETTINGS — Configuracoes, Keybinds, Categories, PendingButtons, Cache
-- =============================================================================
return function(GH, services)

-- ==========================================
-- AUTO-DETECT LANGUAGE
-- ==========================================
local LocalizationService = game:GetService("LocalizationService")

local function DetectLanguage()
	local detectedLang = "en" -- Default for international users

	pcall(function()
		local robloxLocale = LocalizationService.RobloxLocaleId:lower()
		local systemLocale = LocalizationService.SystemLocaleId:lower()

		-- Portuguese (BR, PT)
		if robloxLocale:sub(1, 2) == "pt" or systemLocale:sub(1, 2) == "pt" then
			detectedLang = "pt"
		-- Spanish (ES, MX, etc.)
		elseif robloxLocale:sub(1, 2) == "es" or systemLocale:sub(1, 2) == "es" then
			detectedLang = "es"
		end
	end)

	return detectedLang
end

-- ==========================================
-- SETTINGS DEFAULTS
-- ==========================================
GH.Settings = {
	Language = DetectLanguage(),
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
	{ Name = "Troll",    Icon = "troll",     Order = 3 },
	{ Name = "Utility",  Icon = "tool",      Order = 4 },
	{ Name = "Visual",   Icon = "eye",       Order = 5 },
	{ Name = "Settings", Icon = "gear",      Order = 6 },
}

-- ==========================================
-- PENDING BUTTONS (modulos registram antes do Initialize)
-- ==========================================
GH.PendingButtons = {} -- { {name, localeKey, callback, category, descKey}, ... }

function GH.RegisterToggleButton(name, localeKey, callback, category, descKey)
	table.insert(GH.PendingButtons, {name = name, localeKey = localeKey, callback = callback, category = category, descKey = descKey})
end

-- ==========================================
-- REFRESH UI (atualiza todos os botoes registrados)
-- ==========================================
function GH.RefreshUI()
	for name, pending in ipairs(GH.PendingButtons) do
		if GH.Buttons[name] and GH.Callbacks[name] then
			local state = GH.States[name] or false
			pcall(GH.Callbacks[name], state, GH.Buttons[name])
		end
	end
end

-- ==========================================
-- VERSION / CACHE
-- ==========================================
GH.Version = GH.Version or { Hash = "unknown", Date = "unknown" }
GH.Cache = {
	OrigWalkSpeed = 16,
	OrigGravity = 196.2,
	OrigHRPSizes = {},
	OrigHeadSizes = {},
	OrigPlayerCollides = {},
	XRayParts = {},
	ESPPlayers = {},
	HitboxAdornments = {},
	OrigNightBrightness = nil,
	OrigNightClockTime = nil,
	OrigNightAmbient = nil,
	OrigNightOutdoorAmbient = nil,
	OrigFBBrightness = nil,
	OrigFBClockTime = nil,
	OrigFBAmbient = nil,
	OrigFBOutdoorAmbient = nil,
	OrigHipHeight = nil,
	WalkFlingConn = nil,
	WalkFlingDied = nil,
	AutoFlingConn = nil,
	AutoFlingDied = nil,
	SpasmTrack = nil,
	SpasmAnim = nil,
	HeadSizeTargets = {},
}

-- ==========================================
-- NAMECALL HANDLERS
-- ==========================================
GH.NamecallHandlers = {}

-- ==========================================
-- SAFE CALL
-- ==========================================
function GH.SafeCall(context, fn)
	local ok, err = pcall(fn)
	if not ok and GH.Settings and GH.Settings.DebugMode then
		warn("[DEBUG] " .. context .. ": " .. tostring(err))
	end
	return ok, err
end

end -- module
