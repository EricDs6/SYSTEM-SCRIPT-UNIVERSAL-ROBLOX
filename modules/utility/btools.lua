-- =============================================================================
-- COMMAND: BTOOLS (Building Tools)
-- =============================================================================
return function(GH)
	local Players = GH.Services.Players
	local RunService = GH.Services.RunService
	local UserInputService = GH.Services.UserInputService
	local TweenService = GH.Services.TweenService
	local LocalPlayer = GH.LocalPlayer

	function Cheats_ToggleBTools(state, btn)
		if state then
			local bp = LocalPlayer:FindFirstChild("Backpack")
			if bp then
				for i = 1, 4 do
					local tool = Instance.new("HopperBin")
					tool.BinType = i
					tool.Name = "BTool_" .. i
					tool.Parent = bp
				end
			end
			GH.ShowToast(GH.T("toast_btools"), GH.Theme.On, 2)
		else
			local bp = LocalPlayer:FindFirstChild("Backpack")
			if bp then
				for _, v in ipairs(bp:GetChildren()) do
					if v:IsA("HopperBin") and v.Name:sub(1, 6) == "BTool_" then
						v:Destroy()
					end
				end
			end
		end
	end

	GH.RegisterToggleButton("BTools", GH.T("toggle_btools"), Cheats_ToggleBTools, "Utility", GH.T("desc_btools"))
end
