-- =============================================================================
-- COMMAND: SERVER REJOIN
-- =============================================================================
return function(GH)
	local Players = GH.Services.Players
	local RunService = GH.Services.RunService
	local UserInputService = GH.Services.UserInputService
	local TweenService = GH.Services.TweenService
	local LocalPlayer = GH.LocalPlayer

	function Cheats_ToggleServerRejoin(state, btn)
		if not state then return end
		task.spawn(function()
			pcall(function()
				game:GetService("TeleportService"):Teleport(game.PlaceId, LocalPlayer)
			end)
		end)
		task.delay(2, function() GH.States.ServerRejoin = false end)
	end

	GH.RegisterToggleButton("ServerRejoin", GH.T("toggle_serverrejoin"), Cheats_ToggleServerRejoin, "Utility", GH.T("desc_serverrejoin"))
end
