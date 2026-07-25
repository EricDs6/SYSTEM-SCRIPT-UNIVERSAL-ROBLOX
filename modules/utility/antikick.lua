-- =============================================================================
-- COMMAND: ANTI-KICK
-- =============================================================================
return function(GH)
	local Players = GH.Services.Players
	local RunService = GH.Services.RunService
	local UserInputService = GH.Services.UserInputService
	local TweenService = GH.Services.TweenService
	local LocalPlayer = GH.LocalPlayer

	local OldKickFunction = nil

	function Cheats_ToggleAntiKick(state, btn)
		if state then
			if not hookfunction then
				GH.ShowToast(GH.T("toast_anti_kick_no_hook"), GH.Theme.Red, 3)
				GH.States.AntiKick = false; return
			end
			OldKickFunction = hookfunction(LocalPlayer.Kick, function() end)
			GH.ShowToast(GH.T("toast_anti_kick"), GH.Theme.On, 2)
		else
			if OldKickFunction then
				pcall(function() hookfunction(LocalPlayer.Kick, OldKickFunction) end)
				OldKickFunction = nil
			end
		end
	end

	GH.RegisterToggleButton("AntiKick", "toggle_antikick", Cheats_ToggleAntiKick, "Utility", "desc_antikick")
end
