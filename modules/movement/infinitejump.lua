-- =============================================================================
-- COMMAND: INFINITE JUMP
-- =============================================================================
return function(GH)
	local UserInputService = GH.Services.UserInputService
	local LocalPlayer = GH.LocalPlayer

	function Cheats_ToggleInfiniteJump(state, btn)
		GH.Disconnect("InfJump")
		if state then
			GH.Connections.InfJump = UserInputService.JumpRequest:Connect(function()
				if not GH.States.InfiniteJump then return end
				local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
				if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
			end)
		end
	end

	GH.RegisterToggleButton("InfiniteJump", GH.T("toggle_infinitejump"), Cheats_ToggleInfiniteJump, "Movement", GH.T("desc_infinitejump"))
end