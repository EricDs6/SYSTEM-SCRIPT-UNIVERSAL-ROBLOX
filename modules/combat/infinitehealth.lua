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
	end

	GH.RegisterToggleButton("InfiniteHealth", "toggle_infinitehealth", Cheats_ToggleInfiniteHealth, "Combat", "desc_infinitehealth")
end