-- =============================================================================
-- COMMAND: VEHICLE SPEED
-- =============================================================================
return function(GH)
	local RunService = GH.Services.RunService
	local LocalPlayer = GH.LocalPlayer

	function Cheats_ToggleVehicleSpeed(state, btn)
		GH.Disconnect("VehicleSpeed")

		-- Restaurar valores originais do veiculo
		if not state and GH.Cache.OrigVehicleSpeed then
			pcall(function()
				local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
				if hum and hum.SeatPart and hum.SeatPart:IsA("VehicleSeat") then
					hum.SeatPart.MaxSpeed = GH.Cache.OrigVehicleSpeed.MaxSpeed
					hum.SeatPart.Torque = GH.Cache.OrigVehicleSpeed.Torque
				end
			end)
			GH.Cache.OrigVehicleSpeed = nil
		end

		if state then
			GH.Connections.VehicleSpeed = RunService.Heartbeat:Connect(function()
				if GH.isClosing or not GH.States.VehicleSpeed then return end
				pcall(function()
					local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
					if hum and hum.SeatPart and hum.SeatPart:IsA("VehicleSeat") then
						if not GH.Cache.OrigVehicleSpeed then
							GH.Cache.OrigVehicleSpeed = {
								MaxSpeed = hum.SeatPart.MaxSpeed,
								Torque = hum.SeatPart.Torque,
							}
						end
						hum.SeatPart.MaxSpeed = 100
						hum.SeatPart.Torque = 200
					end
				end)
			end)
		end
	end

	GH.RegisterToggleButton("VehicleSpeed", "toggle_vehiclespeed", Cheats_ToggleVehicleSpeed, "Movement", "desc_vehiclespeed")
end