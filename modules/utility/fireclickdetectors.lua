-- =============================================================================
-- COMMAND: FIRE CLICK DETECTORS
-- =============================================================================
return function(GH)
	local Players = GH.Services.Players
	local RunService = GH.Services.RunService
	local UserInputService = GH.Services.UserInputService
	local TweenService = GH.Services.TweenService
	local LocalPlayer = GH.LocalPlayer

	function Cheats_ToggleFireClickDetectors(state, btn)
		if state then
			pcall(function()
				for _, v in ipairs(workspace:GetDescendants()) do
					if v:IsA("ClickDetector") then
						pcall(function() fireclickdetector(v) end)
					end
				end
			end)
			GH.ShowToast(GH.T("toast_click_detectors"), GH.Theme.On, 2)
		end
	end

	GH.RegisterToggleButton("FireClickDetectors", GH.T("toggle_fireclickdetectors"), Cheats_ToggleFireClickDetectors, "Utility", GH.T("desc_fireclickdetectors"))
end
