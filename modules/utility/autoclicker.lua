-- =============================================================================
-- COMMAND: AUTO-CLICKER
-- =============================================================================
return function(GH)
	local Players = GH.Services.Players
	local RunService = GH.Services.RunService
	local UserInputService = GH.Services.UserInputService
	local TweenService = GH.Services.TweenService
	local LocalPlayer = GH.LocalPlayer

	function Cheats_ToggleAutoClicker(state, btn)
		GH.Disconnect("AutoClicker")
		local acKey = GH.GetKeyCode("AutoClicker")
		if acKey then GH.InputManager.Unbind(acKey) end
		if state and acKey then
			GH.InputManager.Bind(acKey, function()
				task.spawn(function()
					local vim = game:GetService("VirtualInputManager")
					while GH.States.AutoClicker and UserInputService:IsKeyDown(acKey) do
						pcall(function()
							vim:SendMouseButtonEvent(0, 0, 0, true, game, 0)
							task.wait(0.04)
							vim:SendMouseButtonEvent(0, 0, 0, false, game, 0)
						end)
						task.wait(0.06)
					end
				end)
			end)
		end
	end

	GH.RegisterToggleButton("AutoClicker", "toggle_autoclicker", Cheats_ToggleAutoClicker, "Utility", "desc_autoclicker")
end
