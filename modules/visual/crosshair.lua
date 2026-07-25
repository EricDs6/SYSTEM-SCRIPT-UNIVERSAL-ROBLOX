-- =============================================================================
-- COMMAND: CROSSHAIR
-- =============================================================================
return function(GH)
	local CacheCrosshair = { Objects = {} }
	local CrosshairSize = 4
	local CrosshairColor = Color3.fromRGB(0, 255, 0)

	function Cheats_ToggleCrosshair(state, btn)
		if state then
			if CacheCrosshair.Objects.GUI then return end
			local gui = Instance.new("ScreenGui")
			gui.Name = "GH_Crosshair"
			gui.ResetOnSpawn = false
			gui.IgnoreGuiInset = true
			gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
			gui.Parent = GH.TargetGui
			local center = Instance.new("Frame")
			center.Size = UDim2.new(0, 0, 0, 0)
			center.Position = UDim2.new(0.5, 0, 0.5, 0)
			center.BackgroundTransparency = 1
			center.Parent = gui
			CacheCrosshair.Objects = { GUI = gui, Center = center }

			local h = Instance.new("Frame")
			h.Size = UDim2.new(0, CrosshairSize * 3, 0, 1)
			h.Position = UDim2.new(0.5, -CrosshairSize * 1.5, 0.5, -0.5)
			h.BackgroundColor3 = CrosshairColor
			h.BorderSizePixel = 0
			h.Parent = center
			local v = Instance.new("Frame")
			v.Size = UDim2.new(0, 1, 0, CrosshairSize * 3)
			v.Position = UDim2.new(0.5, -0.5, 0.5, -CrosshairSize * 1.5)
			v.BackgroundColor3 = CrosshairColor
			v.BorderSizePixel = 0
			v.Parent = center
		else
			if CacheCrosshair.Objects.GUI then
				CacheCrosshair.Objects.GUI:Destroy()
				CacheCrosshair.Objects = {}
			end
		end
	end

	GH.RegisterToggleButton("Crosshair", "toggle_crosshair", Cheats_ToggleCrosshair, "Visual", "desc_crosshair")
end