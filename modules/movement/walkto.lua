-- =============================================================================
-- COMMAND: WALK TO
-- =============================================================================
return function(GH)
	local Players = GH.Services.Players
	local LocalPlayer = GH.LocalPlayer

	GH.Cache.WalkToTarget = nil

	function Cheats_ToggleWalkTo(state, btn)
		GH.UnregisterMasterLoop("WalkTo")

		if not state then
			if GH.Objects.WalkToPicker then
				GH.Objects.WalkToPicker.Close()
				GH.Objects.WalkToPicker = nil
			end
			GH.Cache.WalkToTarget = nil
			return
		end

		local picker = GH.ShowPlayerPicker(GH.T("dropdown_walkto_title"), function(name)
			local player = Players:FindFirstChild(name)
			if player then
				GH.Cache.WalkToTarget = player
				GH.ShowToast(string.format("Indo ate %s", name), GH.Theme.On, 2)
			end
		end)
		GH.Objects.WalkToPicker = picker

		GH.RegisterMasterLoop("WalkTo", "Heartbeat", function()
			local target = GH.Cache.WalkToTarget
			if not target or not target.Character then return end
			local targetRoot = target.Character:FindFirstChild("HumanoidRootPart")
			local myChar = LocalPlayer.Character
			local myHum = myChar and myChar:FindFirstChildOfClass("Humanoid")
			if targetRoot and myHum then
				myHum:MoveTo(targetRoot.Position)
			end
		end)
	end

	GH.RegisterToggleButton("WalkTo", "toggle_walkto", Cheats_ToggleWalkTo, "Movement", "desc_walkto")
end
