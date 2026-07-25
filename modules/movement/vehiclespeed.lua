-- =============================================================================
-- COMMAND: VEHICLE SPEED
-- Aumenta velocidade e torque de veiculos
-- =============================================================================
return function(GH)
	local RunService = GH.Services.RunService
	local LocalPlayer = GH.LocalPlayer

	local vehicleSpeed = 200

	function Cheats_ToggleVehicleSpeed(state, btn)
		GH.UnregisterMasterLoop("VehicleSpeed")

		if not state then return end

		GH.RegisterMasterLoop("VehicleSpeed", "Heartbeat", function()
			if GH.isClosing or not GH.States.VehicleSpeed then
				GH.UnregisterMasterLoop("VehicleSpeed")
				return
			end

			pcall(function()
				local char = LocalPlayer.Character
				if not char then return end

				local hum = char:FindFirstChildOfClass("Humanoid")
				if hum and hum.SeatPart then
					local seat = hum.SeatPart
					if seat:IsA("VehicleSeat") then
						seat.MaxSpeed = vehicleSpeed
						seat.Torque = vehicleSpeed * 2
					end
				end
			end)
		end)

		GH.ShowToast("Vehicle Speed: " .. vehicleSpeed, GH.Theme.On, 2)
	end

	GH.RegisterToggleButton("VehicleSpeed", "toggle_vehiclespeed", Cheats_ToggleVehicleSpeed, "Movement", "desc_vehiclespeed")
end
