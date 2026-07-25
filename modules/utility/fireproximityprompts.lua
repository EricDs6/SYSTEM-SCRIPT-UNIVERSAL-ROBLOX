-- =============================================================================
-- COMMAND: FIRE PROXIMITY PROMPTS
-- =============================================================================
return function(GH)
	local Players = GH.Services.Players
	local RunService = GH.Services.RunService
	local UserInputService = GH.Services.UserInputService
	local TweenService = GH.Services.TweenService
	local LocalPlayer = GH.LocalPlayer

	function Cheats_ToggleFireProximityPrompts(state, btn)
		if state then
			pcall(function()
				for _, v in ipairs(workspace:GetDescendants()) do
					if v:IsA("ProximityPrompt") then
						pcall(function() fireproximityprompt(v) end)
					end
				end
			end)
			GH.ShowToast(GH.T("toast_proximity_prompts"), GH.Theme.On, 2)
		end
	end

	GH.RegisterToggleButton("FireProximityPrompts", "toggle_fireproximityprompts", Cheats_ToggleFireProximityPrompts, "Utility", "desc_fireproximityprompts")
end
