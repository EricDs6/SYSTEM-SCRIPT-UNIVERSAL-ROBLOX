-- =============================================================================
-- COMMAND: SPEED HACK
-- =============================================================================
return function(GH)
	local RunService = GH.Services.RunService
	local LocalPlayer = GH.LocalPlayer

	local SpeedValue = 32

	function Cheats_ToggleSpeed(state, btn)
		GH.UnregisterMasterLoop("Speed")
		if state then
			GH.RegisterMasterLoop("Speed", "Heartbeat", function()
				if GH.isClosing or not GH.States.Speed then
					GH.UnregisterMasterLoop("Speed")
					local h = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
					if h then h.WalkSpeed = 16 end
					return
				end
				local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
				if hum then
					hum.WalkSpeed = SpeedValue
				end
			end)
		else
			local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
			if hum then hum.WalkSpeed = 16 end
		end
	end

	GH.RegisterToggleButton("Speed", "toggle_speed", Cheats_ToggleSpeed, "Movement", "desc_speed")
end
