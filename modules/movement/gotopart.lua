-- =============================================================================
-- COMMAND: GOTO PART
-- =============================================================================
return function(GH)
	local LocalPlayer = GH.LocalPlayer

	function Cheats_ToggleGotoPart(state, btn)
		if GH.Objects.GotoPartInput then
			GH.Objects.GotoPartInput:Destroy()
			GH.Objects.GotoPartInput = nil
		end
		if not state then return end

		local function teleportToPart(partName)
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
		end

		local input = GH.Tabs["Movement"]:AddInput("GotoPartInput", {
			Title = GH.T("input_gotopart_title"),
			Placeholder = GH.T("input_gotopart_placeholder"),
			Finished = true,
			Callback = function(value)
				if value and value ~= "" then
					teleportToPart(value)
				end
			end,
		})
		GH.Objects.GotoPartInput = input
	end

	GH.RegisterToggleButton("GotoPart", GH.T("toggle_gotopart"), Cheats_ToggleGotoPart, "Movement", GH.T("desc_gotopart"))
end