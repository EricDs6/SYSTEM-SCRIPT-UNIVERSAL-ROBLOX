-- =============================================================================
-- PERSISTENCE — Configuracao persistente (salva/carrega via writefile/readfile)
-- =============================================================================
return function(GH, services)
local HttpService = services.HttpService

-- ==========================================
-- CONFIG PATH (global, persists across games)
-- ==========================================
local CONFIG_FOLDER = "SystemScript"
local CONFIG_FILE = CONFIG_FOLDER .. "/config.json"
local CONFIG_VERSION = 1

-- ==========================================
-- DEFAULT CONFIG STRUCTURE
-- ==========================================
local DEFAULT_CONFIG = {
    version = CONFIG_VERSION,
    settings = {},   -- GH.Settings values
    toggles = {},    -- GH.States toggle on/off
    keybinds = {},   -- GH.Keybinds
    flySpeed = 20,   -- GH.FlySpeed
}

-- ==========================================
-- SAFE FILE OPS (executor APIs)
-- ==========================================
local hasWriteFile = (type(writefile) == "function")
local hasReadFile = (type(readfile) == "function")
local hasIsFile = (type(isfile) == "function")
local hasMakeFolder = (type(makefolder) == "function")
local hasDelFile = (type(delfile) == "function")

-- ==========================================
-- SAVE CONFIG
-- ==========================================
function GH.SaveConfig()
    if not hasWriteFile then
        warn("[PERSISTENCE] writefile nao disponivel neste executor")
        return false
    end

    -- Ensure folder exists
    if hasMakeFolder then
        pcall(function() makefolder(CONFIG_FOLDER) end)
    end

    -- Build config from current state
    local config = {
        version = CONFIG_VERSION,
        settings = {},
        toggles = {},
        keybinds = {},
        flySpeed = GH.FlySpeed or 20,
    }

    -- Save GH.Settings (except Language, which is auto-detected)
    if GH.Settings then
        for k, v in pairs(GH.Settings) do
            if k ~= "Language" then
                config.settings[k] = v
            end
        end
    end

    -- Save all toggle states
    if GH.States then
        for name, state in pairs(GH.States) do
            if type(state) == "boolean" then
                config.toggles[name] = state
            end
        end
    end

    -- Save keybinds
    if GH.Keybinds then
        for k, v in pairs(GH.Keybinds) do
            config.keybinds[k] = v
        end
    end

    -- Encode and write
    local ok, encoded = pcall(HttpService.JSONEncode, HttpService, config)
    if not ok then
        warn("[PERSISTENCE] Erro ao codificar JSON: " .. tostring(encoded))
        return false
    end

    local writeOk, writeErr = pcall(writefile, CONFIG_FILE, encoded)
    if not writeOk then
        warn("[PERSISTENCE] Erro ao salvar: " .. tostring(writeErr))
        return false
    end

    return true
end

-- ==========================================
-- LOAD CONFIG
-- ==========================================
function GH.LoadConfig()
    if not hasReadFile or not hasIsFile then
        warn("[PERSISTENCE] readfile/isfile nao disponivel neste executor")
        return nil
    end

    -- Check if config exists
    local exists = pcall(function() return isfile(CONFIG_FILE) end)
    if not exists then
        return nil
    end

    -- Read file
    local readOk, content = pcall(readfile, CONFIG_FILE)
    if not readOk or not content or content == "" then
        return nil
    end

    -- Decode JSON
    local decodeOk, config = pcall(HttpService.JSONDecode, HttpService, content)
    if not decodeOk or type(config) ~= "table" then
        warn("[PERSISTENCE] Erro ao decodificar config: " .. tostring(config))
        return nil
    end

    -- Version check
    if config.version ~= CONFIG_VERSION then
        warn("[PERSISTENCE] Versao incompativel, usando defaults")
        return nil
    end

    return config
end

-- ==========================================
-- APPLY LOADED CONFIG (called after settings & state init)
-- ==========================================
function GH.ApplyConfig(config)
    if not config then return false end

    -- Apply settings
    if config.settings and GH.Settings then
        for k, v in pairs(config.settings) do
            if GH.Settings[k] ~= nil then
                GH.Settings[k] = v
            end
        end
    end

    -- Apply fly speed
    if config.flySpeed then
        GH.FlySpeed = config.flySpeed
    end

    -- Apply keybinds
    if config.keybinds and GH.Keybinds then
        for k, v in pairs(config.keybinds) do
            GH.Keybinds[k] = v
        end
    end

    -- Apply toggle states (stored for later, applied after UI creates buttons)
    GH._SavedToggles = config.toggles or {}

    return true
end

-- ==========================================
-- RESTORE TOGGLE STATES (called after all buttons are created)
-- ==========================================
function GH.RestoreToggles()
    if not GH._SavedToggles then return end

    GH.SilentRestore = true

    for name, savedState in pairs(GH._SavedToggles) do
        if savedState and GH.Buttons[name] and GH.Callbacks[name] then
            GH.States[name] = true
            -- Update UI toggle visual via SetValue (triggers setToggle animation)
            local btn = GH.Buttons[name]
            if btn and btn.SetValue then
                btn:SetValue(true)
            end
            -- Trigger callback to activate the feature
            pcall(GH.Callbacks[name], true, btn)
        end
    end

    GH.SilentRestore = false
    GH._SavedToggles = nil
end

-- ==========================================
-- DELETE CONFIG
-- ==========================================
function GH.DeleteConfig()
    if hasDelFile then
        pcall(function() delfile(CONFIG_FILE) end)
    end
    return true
end

-- ==========================================
-- AUTO-SAVE ON STATE CHANGE (hook into toggle clicks)
-- ==========================================
function GH.AutoSave()
    -- Debounce: save after 0.5s of no changes
    if GH._AutoSaveTimer then
        pcall(task.cancel, GH._AutoSaveTimer)
    end
    GH._AutoSaveTimer = task.delay(0.5, function()
        GH.SaveConfig()
    end)
end

-- ==========================================
-- INITIAL LOAD
-- ==========================================
local loadedConfig = GH.LoadConfig()
if loadedConfig then
    GH.ApplyConfig(loadedConfig)
    GH._ConfigLoaded = true
else
    GH._ConfigLoaded = false
end

end -- module
