-- =============================================================================
-- COMMAND: GRAVITY
-- =============================================================================
return function(GH)
	local Players = GH.Services.Players
	local RunService = GH.Services.RunService
	local UserInputService = GH.Services.UserInputService
	local TweenService = GH.Services.TweenService
	local LocalPlayer = GH.LocalPlayer

	function Cheats_ToggleGravity(state, btn)
		if state then
			GH.Cache.OrigGravity = workspace.Gravity
			workspace.Gravity = 10
		else
			workspace.Gravity = GH.Cache.OrigGravity or 196.2
		end
	end

	GH.RegisterToggleButton("Gravity", GH.T("toggle_gravity"), Cheats_ToggleGravity, "Utility", GH.T("desc_gravity"))
end
