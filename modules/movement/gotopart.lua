-- =============================================================================
-- COMMAND: GOTO PART
-- =============================================================================
return function(GH)
	local LocalPlayer = GH.LocalPlayer

	function Cheats_ToggleGotoPart(state, btn)
		if not state then
			if GH.Objects.GotoPartPicker then
				GH.Objects.GotoPartPicker.Close()
				GH.Objects.GotoPartPicker = nil
			end
			return
		end

		local picker = GH.ShowInputPicker(GH.T("input_gotopart_title"), GH.T("input_gotopart_placeholder"), function(partName)
			for _, v in ipairs(workspace:GetDescendants()) do
				if v:IsA("BasePart") and v.Name:lower() == partName:lower() then
					local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
					if hrp then
						hrp.CFrame = v.CFrame + Vector3.new(0, 3, 0)
						GH.ShowToast(string.format(GH.T("toast_tp_to"), v.Name), GH.Theme.On, 2)
					end
					break
				end
			end
		end)
		GH.Objects.GotoPartPicker = picker
	end

	GH.RegisterToggleButton("GotoPart", "toggle_gotopart", Cheats_ToggleGotoPart, "Movement", "desc_gotopart")
end
