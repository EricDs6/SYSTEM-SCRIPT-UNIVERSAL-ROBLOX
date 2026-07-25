-- =============================================================================
-- COMMAND: NO FALL DAMAGE
-- =============================================================================
return function(GH)
	local LocalPlayer = GH.LocalPlayer

	table.insert(GH.NamecallHandlers, function(self, method, args)
		if not GH.States.NoFallDamage then return false end
		if method ~= "TakeDamage" then return false end
		if self:IsA("Humanoid") then
			local char = self.Parent
			if char and char == LocalPlayer.Character then
				if args[1] and typeof(args[1]) == "number" and args[1] > 0 then return true end
			end
		end
		return false
	end)

	function Cheats_ToggleNoFallDamage(state, btn)
		GH.ShowToast(state and ("No Fall Damage " .. GH.T("toast_activated")) or ("No Fall Damage " .. GH.T("toast_deactivated")), state and GH.Theme.On or GH.Theme.Off, 2)
	end

	GH.RegisterToggleButton("NoFallDamage", GH.T("toggle_nofalldamage"), Cheats_ToggleNoFallDamage, "Combat", GH.T("desc_nofalldamage"))
end