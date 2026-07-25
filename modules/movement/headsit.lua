-- =============================================================================
-- COMMAND: HEADSIT
-- =============================================================================
return function(GH)
	local Players = GH.Services.Players
	local RunService = GH.Services.RunService
	local LocalPlayer = GH.LocalPlayer

	function Cheats_ToggleHeadSit(state, btn)
		GH.UnregisterMasterLoop("HeadSit")

		if not state then
			if GH.Objects.HeadSitPicker then
				GH.Objects.HeadSitPicker.Close()
				GH.Objects.HeadSitPicker = nil
			end
			local char = LocalPlayer.Character
			if char then
				local hum = char:FindFirstChildOfClass("Humanoid")
				if hum then hum.PlatformStand = false end
			end
			return
		end

		local picker = GH.ShowPlayerPicker(GH.T("dropdown_headsit_title"), function(name)
			local player = Players:FindFirstChild(name)
			if player and player.Character then
				local targetHead = player.Character:FindFirstChild("Head")
				local myChar = LocalPlayer.Character
				local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
				local myHum = myChar and myChar:FindFirstChildOfClass("Humanoid")
				if targetHead and myRoot and myHum then
					myRoot.CFrame = targetHead.CFrame + Vector3.new(0, 1.5, 0)
					myHum.PlatformStand = true
				end
			end
		end)
		GH.Objects.HeadSitPicker = picker

		GH.RegisterMasterLoop("HeadSit", "Render", function()
			-- Find target from last selected
			-- This will be managed by the picker callback
		end)
	end

	GH.RegisterToggleButton("HeadSit", "toggle_headsit", Cheats_ToggleHeadSit, "Movement", "desc_headsit")
end
