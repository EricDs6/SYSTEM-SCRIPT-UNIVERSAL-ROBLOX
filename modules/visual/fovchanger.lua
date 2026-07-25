-- =============================================================================
-- COMMAND: FOV CHANGER
-- =============================================================================
return function(GH)
	function Cheats_ToggleFOVChanger(state, btn)
		if state then
			GH.Cache.OrigFOV = workspace.CurrentCamera.FieldOfView
			workspace.CurrentCamera.FieldOfView = 90
			GH.ShowToast(GH.T("toast_fov"), GH.Theme.Accent, 2)
		else
			workspace.CurrentCamera.FieldOfView = GH.Cache.OrigFOV or 70
			GH.Cache.OrigFOV = nil
		end
	end

	GH.RegisterToggleButton("FOVChanger", "toggle_fovchanger", Cheats_ToggleFOVChanger, "Visual", "desc_fovchanger")
end