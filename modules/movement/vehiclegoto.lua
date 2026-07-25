-- =============================================================================
-- COMMAND: VEHICLE GOTO
-- =============================================================================
return function(GH)
	local Players = GH.Services.Players
	local LocalPlayer = GH.LocalPlayer

	function Cheats_ToggleVehicleGoto(state, btn)
		GH.Disconnect("VehicleGotoPlayerAdded")
		GH.Disconnect("VehicleGotoPlayerRemoving")
		if GH.Objects.VehicleGotoDropdown then
			GH.Objects.VehicleGotoDropdown:Destroy()
			GH.Objects.VehicleGotoDropdown = nil
		end
		if not state then return end

		local function refreshList()
			local names = {}
			for _, player in ipairs(Players:GetPlayers()) do
				if player ~= LocalPlayer then
					table.insert(names, player.Name)
				end
			end
			if GH.Objects.VehicleGotoDropdown then
				GH.Objects.VehicleGotoDropdown:SetValues(names)
			end
		end

		local initialNames = {}
		for _, player in ipairs(Players:GetPlayers()) do
			if player ~= LocalPlayer then
				table.insert(initialNames, player.Name)
			end
		end

		local dropdown = GH.Tabs["Movement"]:AddDropdown("VehicleGoto_Select", {
			Title = GH.T("dropdown_vehiclegoto_title"),
			Values = initialNames,
			AllowNull = true,
		})
		GH.Objects.VehicleGotoDropdown = dropdown

		dropdown:OnChanged(function(name)
			if name then
				local player = Players:FindFirstChild(name)
				local char = LocalPlayer.Character
				local hum = char and char:FindFirstChildOfClass("Humanoid")
				if hum and hum.SeatPart then
					local vehicle = hum.SeatPart:FindFirstAncestorWhichIsA("Model")
					local target = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
					if vehicle and target then
						vehicle:MoveTo(target.Position)
						GH.ShowToast(string.format(GH.T("toast_vehicle_to"), name), GH.Theme.On, 2)
					end
				end
			end
		end)

		refreshList()
		GH.Connections.VehicleGotoPlayerAdded = Players.PlayerAdded:Connect(function()
			if GH.States.VehicleGoto then refreshList() end
		end)
		GH.Connections.VehicleGotoPlayerRemoving = Players.PlayerRemoving:Connect(function()
			if GH.States.VehicleGoto then refreshList() end
		end)
	end

	GH.RegisterToggleButton("VehicleGoto", GH.T("toggle_vehiclegoto"), Cheats_ToggleVehicleGoto, "Movement", GH.T("desc_vehiclegoto"))
end