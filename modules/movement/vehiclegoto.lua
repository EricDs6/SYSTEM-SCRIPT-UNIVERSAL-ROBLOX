-- =============================================================================
-- COMMAND: VEHICLE GOTO
-- =============================================================================
return function(GH)
	local Players = GH.Services.Players
	local LocalPlayer = GH.LocalPlayer

	function Cheats_ToggleVehicleGoto(state, btn)
		if not state then
			if GH.Objects.VehicleGotoPicker then
				GH.Objects.VehicleGotoPicker.Close()
				GH.Objects.VehicleGotoPicker = nil
			end
			return
		end

		local picker = GH.ShowPlayerPicker(GH.T("dropdown_vehiclegoto_title"), function(name)
			local player = Players:FindFirstChild(name)
			if player and player.Character then
				local targetRoot = player.Character:FindFirstChild("HumanoidRootPart")
				local myChar = LocalPlayer.Character
				local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
				if targetRoot and myRoot then
					-- Check if seated in vehicle
					local seat = myRoot.Parent:FindFirstChildWhichIsA("VehicleSeat") or myRoot.Parent:FindFirstChildWhichIsA("Seat")
					if seat then
						seat:MoveTo(targetRoot.Position)
						GH.ShowToast(string.format(GH.T("toast_vehicle_to"), name), GH.Theme.On, 2)
					else
						GH.ShowToast("Not in a vehicle!", GH.Theme.Red, 2)
					end
				end
			end
		end)
		GH.Objects.VehicleGotoPicker = picker
	end

	GH.RegisterToggleButton("VehicleGoto", "toggle_vehiclegoto", Cheats_ToggleVehicleGoto, "Movement", "desc_vehiclegoto")
end
