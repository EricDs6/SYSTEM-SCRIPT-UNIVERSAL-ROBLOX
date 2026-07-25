-- =============================================================================
-- COMMAND: NAKED
-- =============================================================================
return function(GH)
	local LocalPlayer = GH.LocalPlayer

	function Cheats_ToggleNaked(state, btn)
		if state then
			local char = LocalPlayer.Character
			if char then
				for _, v in ipairs(char:GetDescendants()) do
					if v:IsA("Clothing") or v:IsA("ShirtGraphic") then
						v:Destroy()
					end
				end
			end
			GH.ShowToast(GH.T("toast_clothes_removed"), GH.Theme.On, 2)
		end
	end

	GH.RegisterToggleButton("Naked", "toggle_naked", Cheats_ToggleNaked, "Troll", "desc_naked")
end