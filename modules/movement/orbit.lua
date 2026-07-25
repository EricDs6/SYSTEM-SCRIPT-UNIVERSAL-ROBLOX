-- =============================================================================
-- COMMAND: ORBIT
-- =============================================================================
return function(GH)
	local Players = GH.Services.Players
	local RunService = GH.Services.RunService
	local LocalPlayer = GH.LocalPlayer

	function Cheats_ToggleOrbit(state, btn)
		GH.UnregisterMasterLoop("Orbit")
		GH.UnregisterMasterLoop("OrbitLook")
		GH.Disconnect("OrbitPlayerAdded")
		GH.Disconnect("OrbitPlayerRemoving")
		if GH.Objects.OrbitDropdown then
			GH.Objects.OrbitDropdown:Destroy()
			GH.Objects.OrbitDropdown = nil
		end
		if not state then return end

		local function refreshList()
			local names = {}
			for _, player in ipairs(Players:GetPlayers()) do
				if player ~= LocalPlayer then
					table.insert(names, player.Name)
				end
			end
			if GH.Objects.OrbitDropdown then
				GH.Objects.OrbitDropdown:SetValues(names)
			end
		end

		local initialNames = {}
		for _, player in ipairs(Players:GetPlayers()) do
			if player ~= LocalPlayer then
				table.insert(initialNames, player.Name)
			end
		end

		local dropdown = GH.Tabs["Movement"]:AddDropdown("Orbit_Select", {
			Title = GH.T("dropdown_orbit_title"),
			Values = initialNames,
			AllowNull = true,
		})
		GH.Objects.OrbitDropdown = dropdown

		dropdown:OnChanged(function(name)
			if name then
				local targetName = name
				local rotation = 0

				GH.RegisterMasterLoop("Orbit", "Heartbeat", function()
					if GH.isClosing or not GH.States.Orbit then
						GH.UnregisterMasterLoop("Orbit")
						GH.UnregisterMasterLoop("OrbitLook")
						return
					end
					local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
					local target = Players:FindFirstChild(targetName)
					local targetRoot = target and target.Character and target.Character:FindFirstChild("HumanoidRootPart")
					if root and targetRoot then
						rotation = rotation + 0.2
						root.CFrame = CFrame.new(targetRoot.Position) * CFrame.Angles(0, math.rad(rotation), 0) * CFrame.new(6, 0, 0)
					end
				end)

				GH.RegisterMasterLoop("OrbitLook", "Render", function()
					if GH.isClosing or not GH.States.Orbit then return end
					local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
					local target = Players:FindFirstChild(targetName)
					local targetRoot = target and target.Character and target.Character:FindFirstChild("HumanoidRootPart")
					if root and targetRoot then
						root.CFrame = CFrame.new(root.Position, targetRoot.Position)
					end
				end)
			end
		end)

		refreshList()
		GH.Connections.OrbitPlayerAdded = Players.PlayerAdded:Connect(function()
			if GH.States.Orbit then refreshList() end
		end)
		GH.Connections.OrbitPlayerRemoving = Players.PlayerRemoving:Connect(function()
			if GH.States.Orbit then refreshList() end
		end)
	end

	GH.RegisterToggleButton("Orbit", GH.T("toggle_orbit"), Cheats_ToggleOrbit, "Movement", GH.T("desc_orbit"))
end