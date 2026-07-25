-- =============================================================================
-- COMMAND: WALL BANG
-- =============================================================================
return function(GH)
	local LocalPlayer = GH.LocalPlayer

	table.insert(GH.NamecallHandlers, function(self, method, args)
		if not GH.States.WallBang then return false end
		if method ~= "Raycast" then return false end
		if args[3] and typeof(args[3]) == "RaycastParams" then
			args[3].FilterType = Enum.RaycastFilterType.Exclude
			local ignoreList = {}
			for _, obj in ipairs(workspace:GetChildren()) do
				if not obj:IsA("Model") or not obj:FindFirstChildOfClass("Humanoid") then
					table.insert(ignoreList, obj)
				end
			end
			args[3].FilterDescendantsInstances = ignoreList
			return true
		end
		return false
	end)

	function Cheats_ToggleWallBang(state, btn)
		GH.ShowToast(state and ("Wall Bang " .. GH.T("toast_activated")) or ("Wall Bang " .. GH.T("toast_deactivated")), state and GH.Theme.On or GH.Theme.Off, 2)
	end

	GH.RegisterToggleButton("WallBang", "toggle_wallbang", Cheats_ToggleWallBang, "Combat", "desc_wallbang")
end