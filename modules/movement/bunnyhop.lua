-- =============================================================================
-- COMMAND: BUNNY HOP
-- =============================================================================
return function(GH)
	local LocalPlayer = GH.LocalPlayer

	function Cheats_ToggleBunnyHop(state, btn)
		GH.UnregisterMasterLoop("BunnyHop")
		if state then
			GH.RegisterMasterLoop("BunnyHop", "Heartbeat", function()
				if GH.isClosing or not GH.States.BunnyHop then
					GH.UnregisterMasterLoop("BunnyHop"); return
				end
				local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
				if hum and hum.Health > 0 and hum.FloorMaterial ~= Enum.Material.Air then
					hum:ChangeState(Enum.HumanoidStateType.Jumping)
				end
			end)
		end
	end

	GH.RegisterToggleButton("BunnyHop", "toggle_bunnyhop", Cheats_ToggleBunnyHop, "Movement", "desc_bunnyhop")
end