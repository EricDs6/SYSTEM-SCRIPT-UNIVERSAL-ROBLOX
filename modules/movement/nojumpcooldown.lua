-- =============================================================================
-- COMMAND: NO JUMP COOLDOWN
-- =============================================================================
return function(GH)
	local RunService = GH.Services.RunService
	local LocalPlayer = GH.LocalPlayer

	function Cheats_ToggleNoJumpCooldown(state, btn)
		GH.UnregisterMasterLoop("NoJumpCooldown")
		if state then
			local h = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
			if h then
				GH.Cache.OrigJumpHeight = h.JumpHeight
				GH.Cache.OrigJumpPower = h.JumpPower
			end
			GH.RegisterMasterLoop("NoJumpCooldown", "Heartbeat", function()
				if GH.isClosing or not GH.States.NoJumpCooldown then
					GH.UnregisterMasterLoop("NoJumpCooldown")
					local h2 = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
					if h2 then
						h2.JumpHeight = GH.Cache.OrigJumpHeight or 7.2
						h2.JumpPower = GH.Cache.OrigJumpPower or 50
					end
					return
				end
				local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
				if hum then
					hum.JumpHeight = 50
					hum.JumpPower = 100
				end
			end)
		else
			local h = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
			if h then
				h.JumpHeight = GH.Cache.OrigJumpHeight or 7.2
				h.JumpPower = GH.Cache.OrigJumpPower or 50
			end
		end
	end

	GH.RegisterToggleButton("NoJumpCooldown", "toggle_nojumpcooldown", Cheats_ToggleNoJumpCooldown, "Movement", "desc_nojumpcooldown")
end