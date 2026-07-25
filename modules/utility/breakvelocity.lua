-- =============================================================================
-- COMMAND: BREAK VELOCITY
-- =============================================================================
return function(GH)
	local Players = GH.Services.Players
	local RunService = GH.Services.RunService
	local UserInputService = GH.Services.UserInputService
	local TweenService = GH.Services.TweenService
	local LocalPlayer = GH.LocalPlayer

	function Cheats_ToggleBreakVelocity(state, btn)
		if state then
			local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
			if hrp then
				hrp.AssemblyLinearVelocity = Vector3.zero
				hrp.AssemblyAngularVelocity = Vector3.zero
			end
			for _, part in ipairs(LocalPlayer.Character:GetDescendants()) do
				if part:IsA("BasePart") then
					part.AssemblyLinearVelocity = Vector3.zero
					part.AssemblyAngularVelocity = Vector3.zero
				end
			end
			GH.ShowToast(GH.T("toast_velocity_reset"), GH.Theme.On, 2)
		end
	end

	GH.RegisterToggleButton("BreakVelocity", "toggle_breakvelocity", Cheats_ToggleBreakVelocity, "Utility", "desc_breakvelocity")
end
