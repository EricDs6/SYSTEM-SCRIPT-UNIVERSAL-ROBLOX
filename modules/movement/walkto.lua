-- =============================================================================
-- COMMAND: WALK TO
-- =============================================================================
return function(GH)
	local Players = GH.Services.Players
	local RunService = GH.Services.RunService
	local LocalPlayer = GH.LocalPlayer

	function Cheats_ToggleWalkTo(state, btn)
		GH.UnregisterMasterLoop("WalkTo")
		GH.Disconnect("WalkToDied")
		GH.Disconnect("WalkToPlayerAdded")
		GH.Disconnect("WalkToPlayerRemoving")
		if GH.Objects.WalkToDropdown then
			GH.Objects.WalkToDropdown:Destroy()
			GH.Objects.WalkToDropdown = nil
		end
		if not state then return end

		local function refreshList()
			local names = {}
			for _, player in ipairs(Players:GetPlayers()) do
				if player ~= LocalPlayer then
					table.insert(names, player.Name)
				end
			end
			if GH.Objects.WalkToDropdown then
				GH.Objects.WalkToDropdown:SetValues(names)
			end
		end

		local initialNames = {}
		for _, player in ipairs(Players:GetPlayers()) do
			if player ~= LocalPlayer then
				table.insert(initialNames, player.Name)
			end
		end

		local dropdown = GH.Tabs["Movement"]:AddDropdown("WalkTo_Select", {
			Title = GH.T("dropdown_walkto_title"),
			Values = initialNames,
			AllowNull = true,
		})
		GH.Objects.WalkToDropdown = dropdown

		dropdown:OnChanged(function(name)
			if name then
				local targetName = name
				GH.RegisterMasterLoop("WalkTo", "Heartbeat", function()
					if GH.isClosing or not GH.States.WalkTo then
						GH.UnregisterMasterLoop("WalkTo")
						return
					end
					local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
					local target = Players:FindFirstChild(targetName)
					local targetRoot = target and target.Character and target.Character:FindFirstChild("HumanoidRootPart")
					if hum and targetRoot then
						if hum.SeatPart then hum.Sit = false end
						hum:MoveTo(targetRoot.Position)
					else
						GH.UnregisterMasterLoop("WalkTo")
						GH.States.WalkTo = false
					end
				end)
			end
		end)

		refreshList()
		GH.Connections.WalkToPlayerAdded = Players.PlayerAdded:Connect(function()
			if GH.States.WalkTo then refreshList() end
		end)
		GH.Connections.WalkToPlayerRemoving = Players.PlayerRemoving:Connect(function()
			if GH.States.WalkTo then refreshList() end
		end)
	end

	GH.RegisterToggleButton("WalkTo", GH.T("toggle_walkto"), Cheats_ToggleWalkTo, "Movement", GH.T("desc_walkto"))
end