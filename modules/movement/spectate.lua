-- =============================================================================
-- COMMAND: SPECTATE
-- =============================================================================
return function(GH)
	local Players = GH.Services.Players
	local LocalPlayer = GH.LocalPlayer

	function Cheats_ToggleSpectate(state, btn)
		GH.Disconnect("SpectateDied")
		GH.Disconnect("SpectateChanged")
		GH.Disconnect("SpectatePlayerAdded")
		GH.Disconnect("SpectatePlayerRemoving")
		if GH.Objects.SpectateDropdown then
			GH.Objects.SpectateDropdown:Destroy()
			GH.Objects.SpectateDropdown = nil
		end

		if not state then
			workspace.CurrentCamera.CameraSubject = LocalPlayer.Character
			return
		end

		local function refreshList()
			local names = {}
			for _, player in ipairs(Players:GetPlayers()) do
				if player ~= LocalPlayer then
					table.insert(names, player.Name)
				end
			end
			if GH.Objects.SpectateDropdown then
				GH.Objects.SpectateDropdown:SetValues(names)
			end
		end

		local initialNames = {}
		for _, player in ipairs(Players:GetPlayers()) do
			if player ~= LocalPlayer then
				table.insert(initialNames, player.Name)
			end
		end

		local dropdown = GH.Tabs["Movement"]:AddDropdown("Spectate_Select", {
			Title = GH.T("dropdown_spectate_title"),
			Values = initialNames,
			AllowNull = true,
		})
		GH.Objects.SpectateDropdown = dropdown

		dropdown:OnChanged(function(name)
			if name then
				local player = Players:FindFirstChild(name)
				if player then
					GH.Disconnect("SpectateDied")
					if player.Character then
						workspace.CurrentCamera.CameraSubject = player.Character
					end
					GH.Connections.SpectateDied = player.CharacterAdded:Connect(function(char)
						workspace.CurrentCamera.CameraSubject = char
					end)
				end
			end
		end)

		GH.Connections.SpectatePlayerAdded = Players.PlayerAdded:Connect(function()
			if GH.States.Spectate then refreshList() end
		end)
		GH.Connections.SpectatePlayerRemoving = Players.PlayerRemoving:Connect(function()
			if GH.States.Spectate then refreshList() end
		end)
	end

	GH.RegisterToggleButton("Spectate", "toggle_spectate", Cheats_ToggleSpectate, "Movement", "desc_spectate")
end