-- =============================================================================
-- COMMAND: NIGHT MODE
-- =============================================================================
return function(GH)
	local Lighting = GH.Services.Lighting

	function Cheats_ToggleNightMode(state, btn)
		if state then
			GH.Cache.OrigBrightness = Lighting.Brightness
			GH.Cache.OrigClockTime = Lighting.ClockTime
			GH.Cache.OrigAmbient = Lighting.Ambient
			GH.Cache.OrigOutdoorAmbient = Lighting.OutdoorAmbient
			Lighting.Brightness = 0
			Lighting.ClockTime = 0
			Lighting.Ambient = Color3.fromRGB(25, 25, 35)
			Lighting.OutdoorAmbient = Color3.fromRGB(15, 15, 25)
			if not Lighting:FindFirstChild("GH_NightBloom") then
				local bloom = Instance.new("BloomEffect")
				bloom.Name = "GH_NightBloom"
				bloom.Intensity = 0.3
				bloom.Size = 24
				bloom.Threshold = 0.8
				bloom.Parent = Lighting
			end
		else
			Lighting.Brightness = GH.Cache.OrigBrightness or 1
			Lighting.ClockTime = GH.Cache.OrigClockTime or 14
			Lighting.Ambient = GH.Cache.OrigAmbient or Color3.fromRGB(128, 128, 128)
			Lighting.OutdoorAmbient = GH.Cache.OrigOutdoorAmbient or Color3.fromRGB(128, 128, 128)
			local bloom = Lighting:FindFirstChild("GH_NightBloom")
			if bloom then bloom:Destroy() end
		end
	end

	GH.RegisterToggleButton("NightMode", "toggle_nightmode", Cheats_ToggleNightMode, "Visual", "desc_nightmode")
end