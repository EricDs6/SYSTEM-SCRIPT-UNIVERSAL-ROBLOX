-- =============================================================================
-- COMMAND: HEADSIT
-- =============================================================================
return function(GH)
	local Players = GH.Services.Players
	local RunService = GH.Services.RunService
	local LocalPlayer = GH.LocalPlayer

	function Cheats_ToggleHeadSit(state, btn)
		GH.UnregisterMasterLoop("HeadSit")
		GH.Disconnect("HeadSitPlayerAdded")
		GH.Disconnect("HeadSitPlayerRemoving")
		if GH.Objects.HeadSitDropdown then
			GH.Objects.HeadSitDropdown:Destroy()
			GH.Objects.HeadSitDropdown = nil
		end
		if not state then return end

		local function refreshList()
			local names = {}
			for _, player in ipairs(Players:GetPlayers()) do
				if player ~= LocalPlayer then
					table.insert(names, player.Name)
				end
			end
			if GH.Objects.HeadSitDropdown then
				GH.Objects.HeadSitDropdown:SetValues(names)
			end
		end

		local initialNames = {}
		for _, player in ipairs(Players:GetPlayers()) do
			if player ~= LocalPlayer then
				table.insert(initialNames, player.Name)
			end
		end

		local dropdown = GH.Tabs["Movement"]:AddDropdown("HeadSit_Select", {
			Title = GH.T("dropdown_headsit_title"),
			Values = initialNames,
			AllowNull = true,
		})
		GH.Objects.HeadSitDropdown = dropdown

		dropdown:OnChanged(function(name)
			if name then
				local targetName = name
				local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
				if hum then hum.Sit = true end

				GH.RegisterMasterLoop("HeadSit", "Heartbeat", function()
					if GH.isClosing or not GH.States.HeadSit then
						GH.UnregisterMasterLoop("HeadSit")
						return
					end
					local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
					local myHum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
					local target = Players:FindFirstChild(targetName)
					local targetRoot = target and target.Character and target.Character:FindFirstChild("HumanoidRootPart")
					if root and targetRoot and myHum and myHum.Sit then
						root.CFrame = targetRoot.CFrame * CFrame.Angles(0, math.rad(0), 0) * CFrame.new(0, 1.6, 0.4)
					else
						GH.UnregisterMasterLoop("HeadSit")
						GH.States.HeadSit = false
					end
				end)
			end
		end)

		refreshList()
		GH.Connections.HeadSitPlayerAdded = Players.PlayerAdded:Connect(function()
			if GH.States.HeadSit then refreshList() end
		end)
		GH.Connections.HeadSitPlayerRemoving = Players.PlayerRemoving:Connect(function()
			if GH.States.HeadSit then refreshList() end
		end)
	end

	GH.RegisterToggleButton("HeadSit", "toggle_headsit", Cheats_ToggleHeadSit, "Movement", "desc_headsit")
end