-- =============================================================================
-- COMMAND: INVISIBLE PARTS (Mostrar partes invisiveis)
-- =============================================================================
return function(GH)
	local Players = GH.Services.Players
	local RunService = GH.Services.RunService
	local UserInputService = GH.Services.UserInputService
	local TweenService = GH.Services.TweenService
	local LocalPlayer = GH.LocalPlayer

	local ShownParts = {}

	function Cheats_ToggleInvisibleParts(state, btn)
		if state then
			ShownParts = {}
			for _, v in ipairs(workspace:GetDescendants()) do
				if v:IsA("BasePart") and v.Transparency == 1 then
					table.insert(ShownParts, v)
					v.Transparency = 0
				end
			end
			GH.ShowToast(string.format(GH.T("toast_invisible_shown"), #ShownParts), GH.Theme.On, 2)
		else
			for _, v in ipairs(ShownParts) do
				if v and v.Parent then
					v.Transparency = 1
				end
			end
			ShownParts = {}
		end
	end

	GH.RegisterToggleButton("InvisibleParts", GH.T("toggle_invisibleparts"), Cheats_ToggleInvisibleParts, "Utility", GH.T("desc_invisible_parts"))
end
