-- =============================================================================
-- COMMAND: VEHICLE SPEED
-- =============================================================================
return function(GH)
	local RunService = GH.Services.RunService
	local LocalPlayer = GH.LocalPlayer

	function Cheats_ToggleVehicleSpeed(state, btn)
		GH.Disconnect("VehicleSpeed")
		if state then
			GH.Connections.VehicleSpeed = RunService.Heartbeat:Connect(function()
				if GH.isClosing or not GH.States.VehicleSpeed then return end
				pcall(function()
					local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
					if hum and hum.SeatPart and hum.SeatPart:IsA("VehicleSeat") then
						hum.SeatPart.MaxSpeed = 100
						hum.SeatPart.Torque = 200
					end
				end)
			end)
		end
	end

	GH.RegisterToggleButton("VehicleSpeed", GH.T("toggle_vehiclespeed"), Cheats_ToggleVehicleSpeed, "Movement", GH.T("desc_vehiclespeed"))
end