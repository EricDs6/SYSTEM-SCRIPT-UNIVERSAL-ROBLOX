-- =============================================================================
-- COMMAND: FULLBRIGHT
-- =============================================================================
return function(GH)
	local Lighting = GH.Services.Lighting

	function Cheats_ToggleFullbright(state, btn)
		if state then
			GH.Cache.OrigFBBrightness = Lighting.Brightness
			GH.Cache.OrigFBClockTime = Lighting.ClockTime
			GH.Cache.OrigFBAmbient = Lighting.Ambient
			GH.Cache.OrigFBOutdoorAmbient = Lighting.OutdoorAmbient
			Lighting.Brightness = 2
			Lighting.ClockTime = 14
			Lighting.Ambient = Color3.fromRGB(200, 200, 200)
			Lighting.OutdoorAmbient = Color3.fromRGB(200, 200, 200)
		else
			Lighting.Brightness = GH.Cache.OrigFBBrightness or 1
			Lighting.ClockTime = GH.Cache.OrigFBClockTime or 14
			Lighting.Ambient = GH.Cache.OrigFBAmbient or Color3.fromRGB(128, 128, 128)
			Lighting.OutdoorAmbient = GH.Cache.OrigFBOutdoorAmbient or Color3.fromRGB(128, 128, 128)
		end
	end

	GH.RegisterToggleButton("Fullbright", "toggle_fullbright", Cheats_ToggleFullbright, "Visual", "desc_fullbright")
end