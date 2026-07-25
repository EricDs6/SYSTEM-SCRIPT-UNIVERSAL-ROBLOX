-- =============================================================================
-- COMMAND: SPRINT
-- =============================================================================
return function(GH)
	local LocalPlayer = GH.LocalPlayer

	function Cheats_ToggleSprint(state, btn)
		GH.Disconnect("Sprint")
		local sprintKey = GH.GetKeyCode("Sprint")
		if sprintKey then GH.InputManager.Unbind(sprintKey) end

		local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")

		if state and hum and sprintKey then
			GH.Cache.OrigWalkSpeed = hum.WalkSpeed
			GH.InputManager.Bind(sprintKey, function()
				if not GH.States.Sprint then return end
				local h = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
				if h then h.WalkSpeed = GH.FlySpeed * 2 end
			end, function()
				local h = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
				if h then h.WalkSpeed = GH.Cache.OrigWalkSpeed end
			end)
		else
			if hum then hum.WalkSpeed = GH.Cache.OrigWalkSpeed end
		end
	end

	GH.RegisterToggleButton("Sprint", "toggle_sprint", Cheats_ToggleSprint, "Movement", "desc_sprint")
end