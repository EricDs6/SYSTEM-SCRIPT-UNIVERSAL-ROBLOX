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
		if GH.Cache.AntiAFKThread then
			task.cancel(GH.Cache.AntiAFKThread)
			GH.Cache.AntiAFKThread = nil
		end
		if state then
			GH.Cache.AntiAFKThread = task.spawn(function()
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

	GH.RegisterToggleButton("AntiAFK", "toggle_antiafk", Cheats_ToggleAntiAFK, "Utility", "desc_antiafk")
end
