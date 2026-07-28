-- =============================================================================
-- STATE — Gestao de estados, conexoes, master loops e input manager
-- =============================================================================
return function(GH, services)
local RunService = services.RunService
local UserInputService = services.UserInputService

-- ==========================================
-- STATE MANAGEMENT
-- ==========================================
GH.States = {}

GH.Buttons = {} :: {[string]: any}
GH.Callbacks = {} :: {[string]: (boolean, any) -> ()}
GH.Connections = {} :: {[string]: RBXScriptConnection}
GH.Objects = {}
GH.isClosing = false
GH.SilentRestore = false
GH.Stopped = false
GH.Version = { Hash = "unknown", Date = "unknown" }

-- ==========================================
-- CONNECTION MANAGEMENT
-- ==========================================
GH.GlobalConnections = {}

function GH.Disconnect(name)
	local c = GH.Connections[name]
	if c then GH.Connections[name] = nil; pcall(c.Disconnect, c) end
end

function GH.TrackGlobalConnection(name, conn)
	if conn then GH.GlobalConnections[name] = conn end
end

function GH.CleanupGlobalConnections()
	for name, conn in pairs(GH.GlobalConnections) do
		if conn and typeof(conn) == "RBXScriptConnection" then
			pcall(function() conn:Disconnect() end)
		end
		GH.GlobalConnections[name] = nil
	end
end

-- ==========================================
-- MASTER LOOP (Batching)
-- ==========================================
GH.MasterTick = { Render = 0, Heartbeat = 0, PreSim = 0 }
GH.MasterCallbacks = {
	Render = {} :: {[string]: () -> ()},
	Heartbeat = {} :: {[string]: () -> ()},
	PreSim = {} :: {[string]: () -> ()},
}

function GH.RegisterMasterLoop(name, phase, callback)
	GH.MasterCallbacks[phase][name] = callback
end

function GH.UnregisterMasterLoop(name)
	for phase, callbacks in pairs(GH.MasterCallbacks) do
		callbacks[name] = nil
	end
end

-- ==========================================
-- INPUT MANAGER
-- ==========================================
GH.InputManager = {}
GH.InputManager._bindings = {} :: {[Enum.KeyCode]: {onDown: (() -> ())?, onUp: (() -> ())?}}

function GH.InputManager.Bind(keyCode, onDown, onUp)
	GH.InputManager._bindings[keyCode] = { onDown = onDown, onUp = onUp }
end

function GH.InputManager.Unbind(keyCode)
	GH.InputManager._bindings[keyCode] = nil
end

function GH.InputManager.IsHeld(keyCode)
	return UserInputService:IsKeyDown(keyCode)
end

end -- module
