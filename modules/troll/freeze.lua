-- =============================================================================
-- COMMAND: FREEZE
-- =============================================================================
return function(GH)
	local Players = GH.Services.Players
	local LocalPlayer = GH.LocalPlayer

	function Cheats_ToggleFreeze(state, btn)
		if state then
			for _, player in ipairs(Players:GetPlayers()) do
				if player ~= LocalPlayer and player.Character then
					for _, part in ipairs(player.Character:GetDescendants()) do
						if part:IsA("BasePart") and not part.Anchored then
							part.Anchored = true
						end
					end
				end
			end
			GH.ShowToast(GH.T("toast_players_frozen"), GH.Theme.On, 2)
		else
			for _, player in ipairs(Players:GetPlayers()) do
				if player ~= LocalPlayer and player.Character then
					for _, part in ipairs(player.Character:GetDescendants()) do
						if part:IsA("BasePart") and part.Anchored then
							part.Anchored = false
						end
					end
				end
			end
			GH.ShowToast(GH.T("toast_players_unfrozen"), GH.Theme.Off, 2)
		end
	end

	GH.RegisterToggleButton("Freeze", "toggle_freeze", Cheats_ToggleFreeze, "Troll", "desc_freeze")
end