-- =============================================================================
-- COMMAND: FREEZE
-- =============================================================================
	return function(GH)
	local Players = GH.Services.Players
	local LocalPlayer = GH.LocalPlayer

	function Cheats_ToggleFreeze(state, btn)
		if state then
			GH.Cache.OrigAnchoredStates = GH.Cache.OrigAnchoredStates or {}
			for _, player in ipairs(Players:GetPlayers()) do
				if player ~= LocalPlayer and player.Character then
					for _, part in ipairs(player.Character:GetDescendants()) do
						if part:IsA("BasePart") then
							if not GH.Cache.OrigAnchoredStates[part] then
								GH.Cache.OrigAnchoredStates[part] = part.Anchored
							end
							if not part.Anchored then
								part.Anchored = true
							end
						end
					end
				end
			end
			GH.ShowToast(GH.T("toast_players_frozen"), GH.Theme.On, 2)
		else
			for _, player in ipairs(Players:GetPlayers()) do
				if player ~= LocalPlayer and player.Character then
					for _, part in ipairs(player.Character:GetDescendants()) do
						if part:IsA("BasePart") then
							local origState = GH.Cache.OrigAnchoredStates[part]
							if origState ~= nil then
								part.Anchored = origState
							else
								part.Anchored = false
							end
						end
					end
				end
			end
			table.clear(GH.Cache.OrigAnchoredStates)
			GH.ShowToast(GH.T("toast_players_unfrozen"), GH.Theme.Off, 2)
		end
	end

	GH.RegisterToggleButton("Freeze", "toggle_freeze", Cheats_ToggleFreeze, "Troll", "desc_freeze")
end