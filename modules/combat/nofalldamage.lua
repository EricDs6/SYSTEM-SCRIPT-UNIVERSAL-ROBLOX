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
				if args[1] and typeof(args[1]) == "number" and args[1] > 0 then
				args[1] = 0
				return true
			end
			end
		end
		return false
	end)

	function Cheats_ToggleNoFallDamage(state, btn)
	end

	GH.RegisterToggleButton("NoFallDamage", "toggle_nofalldamage", Cheats_ToggleNoFallDamage, "Combat", "desc_nofalldamage")
end