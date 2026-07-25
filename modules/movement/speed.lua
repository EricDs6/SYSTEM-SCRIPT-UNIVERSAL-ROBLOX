-- =============================================================================
-- COMMAND: SPEED HACK
-- =============================================================================
return function(GH)
	local LocalPlayer = GH.LocalPlayer

	function Cheats_ToggleSpeed(state, btn)
		local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
		if state and hum then
			GH.Cache.OrigWalkSpeed = hum.WalkSpeed
			hum.WalkSpeed = GH.FlySpeed
		else
			if hum then hum.WalkSpeed = GH.Cache.OrigWalkSpeed or 16 end
		end
	end

	GH.RegisterToggleButton("Speed", GH.T("toggle_speed"), Cheats_ToggleSpeed, "Movement", GH.T("desc_speed"))
end