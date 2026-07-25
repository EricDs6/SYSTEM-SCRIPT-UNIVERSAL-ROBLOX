-- =============================================================================
-- COMMAND: TELEPORT PLAYER
-- =============================================================================
return function(GH)
	local Players = GH.Services.Players
	local LocalPlayer = GH.LocalPlayer

	function Cheats_ToggleTeleportPlayer(state, btn)
		if not state then
			if GH.Objects.TeleportPlayerPicker then
				GH.Objects.TeleportPlayerPicker.Close()
				GH.Objects.TeleportPlayerPicker = nil
			end
			return
		end

		local picker = GH.ShowPlayerPicker(GH.T("dropdown_tpplayer_title"), function(name)
			local player = Players:FindFirstChild(name)
			local targetHrp = player and player.Character and player.Character:FindFirstChild("HumanoidRootPart")
			local myHrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
			if targetHrp and myHrp then
				GH.TweenTeleport(myHrp, targetHrp.CFrame + Vector3.new(0, 3, 2))
				GH.ShowToast(string.format(GH.T("toast_tp_to"), name), GH.Theme.On, 2)
			end
		end)
		GH.Objects.TeleportPlayerPicker = picker
	end

	GH.RegisterToggleButton("TeleportPlayer", "toggle_teleportplayer", Cheats_ToggleTeleportPlayer, "Movement", "desc_teleportplayer")
end
