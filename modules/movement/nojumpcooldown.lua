-- =============================================================================
-- COMMAND: NO JUMP COOLDOWN
-- =============================================================================
return function(GH)
	local RunService = GH.Services.RunService
	local LocalPlayer = GH.LocalPlayer

	function Cheats_ToggleNoJumpCooldown(state, btn)
		GH.UnregisterMasterLoop("NoJumpCooldown")
		if state then
			GH.RegisterMasterLoop("NoJumpCooldown", "Heartbeat", function()
				if GH.isClosing or not GH.States.NoJumpCooldown then
					GH.UnregisterMasterLoop("NoJumpCooldown")
					local h = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
					if h then h.JumpHeight = 7.2; h.JumpPower = 50 end
					return
				end
				local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
				if hum then
					hum.JumpHeight = 50
					hum.JumpPower = 100
					if hum.FloorMaterial == Enum.Material.Air then
						hum:ChangeState(Enum.HumanoidStateType.Jumping)
					end
				end
			end)
		else
			local h = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
			if h then h.JumpHeight = 7.2; h.JumpPower = 50 end
		end
	end

	GH.RegisterToggleButton("NoJumpCooldown", "toggle_nojumpcooldown", Cheats_ToggleNoJumpCooldown, "Movement", "desc_nojumpcooldown")
end