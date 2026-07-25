-- =============================================================================
-- COMMAND: INFINITE HEALTH
-- =============================================================================
return function(GH)
	local RunService = GH.Services.RunService
	local LocalPlayer = GH.LocalPlayer

	function Cheats_ToggleInfiniteHealth(state, btn)
		GH.UnregisterMasterLoop("InfiniteHealth")
		if state then
			GH.RegisterMasterLoop("InfiniteHealth", "Heartbeat", function()
				if GH.isClosing or not GH.States.InfiniteHealth then
					GH.UnregisterMasterLoop("InfiniteHealth"); return
				end
				local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
				if hum then hum.Health = hum.MaxHealth end
			end)
		end
		GH.ShowToast(state and ("Infinite Health " .. GH.T("toast_activated")) or ("Infinite Health " .. GH.T("toast_deactivated")), state and GH.Theme.On or GH.Theme.Off, 2)
	end

	GH.RegisterToggleButton("InfiniteHealth", GH.T("toggle_infinitehealth"), Cheats_ToggleInfiniteHealth, "Combat", GH.T("desc_infinitehealth"))
end