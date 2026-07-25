-- =============================================================================
-- COMMAND: FULLBRIGHT
-- =============================================================================
return function(GH)
	local Lighting = GH.Services.Lighting

	function Cheats_ToggleFullbright(state, btn)
		if state then
			GH.Cache.OrigBrightness = Lighting.Brightness
			GH.Cache.OrigClockTime = Lighting.ClockTime
			GH.Cache.OrigAmbient = Lighting.Ambient
			GH.Cache.OrigOutdoorAmbient = Lighting.OutdoorAmbient
			Lighting.Brightness = 2
			Lighting.ClockTime = 14
			Lighting.Ambient = Color3.fromRGB(200, 200, 200)
			Lighting.OutdoorAmbient = Color3.fromRGB(200, 200, 200)
		else
			Lighting.Brightness = GH.Cache.OrigBrightness or 1
			Lighting.ClockTime = GH.Cache.OrigClockTime or 14
			Lighting.Ambient = GH.Cache.OrigAmbient or Color3.fromRGB(128, 128, 128)
			Lighting.OutdoorAmbient = GH.Cache.OrigOutdoorAmbient or Color3.fromRGB(128, 128, 128)
		end
	end

	GH.RegisterToggleButton("Fullbright", "toggle_fullbright", Cheats_ToggleFullbright, "Visual", "desc_fullbright")
end