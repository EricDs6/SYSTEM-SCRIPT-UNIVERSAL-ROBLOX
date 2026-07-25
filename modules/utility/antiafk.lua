-- =============================================================================
-- COMMAND: ANTI-AFK
-- =============================================================================
return function(GH)
	local Players = GH.Services.Players
	local RunService = GH.Services.RunService
	local UserInputService = GH.Services.UserInputService
	local TweenService = GH.Services.TweenService
	local LocalPlayer = GH.LocalPlayer

	function Cheats_ToggleAntiAFK(state, btn)
		GH.Disconnect("AntiAFK")
		if state then
			GH.Connections.AntiAFK = RunService.Heartbeat:Connect(function()
				if not GH.States.AntiAFK then
					GH.Disconnect("AntiAFK"); return
				end
			end)
			task.spawn(function()
				while GH.States.AntiAFK do
					task.wait(math.random(120, 300))
					if not GH.States.AntiAFK then break end
					pcall(function()
						local VirtualUser = game:GetService("VirtualUser")
						VirtualUser:CaptureController()
						VirtualUser:ClickButton2(Vector2.new())
					end)
				end
			end)
		end
	end

	GH.RegisterToggleButton("AntiAFK", GH.T("toggle_antiafk"), Cheats_ToggleAntiAFK, "Utility", GH.T("desc_antiafk"))
end
