-- =============================================================================
-- COMMAND: FOV CHANGER
-- =============================================================================
return function(GH)
	function Cheats_ToggleFOVChanger(state, btn)
		if state then
			workspace.CurrentCamera.FieldOfView = 90
			GH.ShowToast(GH.T("toast_fov"), GH.Theme.Accent, 2)
		else
			workspace.CurrentCamera.FieldOfView = 70
		end
	end

	GH.RegisterToggleButton("FOVChanger", GH.T("toggle_fovchanger"), Cheats_ToggleFOVChanger, "Visual", GH.T("desc_fovchanger"))
end