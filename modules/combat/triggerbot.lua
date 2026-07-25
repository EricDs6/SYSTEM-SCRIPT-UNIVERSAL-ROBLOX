-- =============================================================================
-- COMMAND: TRIGGERBOT
-- =============================================================================
return function(GH)
	local Players = GH.Services.Players
	local RunService = GH.Services.RunService
	local UserInputService = GH.Services.UserInputService
	local LocalPlayer = GH.LocalPlayer

	function Cheats_ToggleTriggerBot(state, btn)
		GH.Disconnect("TriggerBot")

		if state then
			GH.Connections.TriggerBot = RunService.RenderStepped:Connect(function()
				if GH.isClosing or not GH.States.TriggerBot then
					GH.Disconnect("TriggerBot"); return
				end
				local character = LocalPlayer.Character
				if not character then return end
				local tool = character:FindFirstChildOfClass("Tool")
				if not tool then return end
				local cam = workspace.CurrentCamera
				if not cam then return end

				local viewportCenter = cam.ViewportSize / 2
				local unitRay = cam:ViewportPointToRay(viewportCenter.X, viewportCenter.Y)
				local rayParams = RaycastParams.new()
				rayParams.FilterDescendantsInstances = { character }
				rayParams.FilterType = Enum.RaycastFilterType.Exclude

				local result = workspace:Raycast(unitRay.Origin, unitRay.Direction * 250, rayParams)
				if not result or not result.Instance then return end
				local targetChar = result.Instance:FindFirstAncestorOfClass("Model")
				if not targetChar then return end
				local targetHum = targetChar:FindFirstChildOfClass("Humanoid")
				if not targetHum or targetHum.Health <= 0 then return end

				local targetPlayer = Players:GetPlayerFromCharacter(targetChar)
				if targetPlayer and LocalPlayer.Team and targetPlayer.Team == LocalPlayer.Team then return end

				pcall(function() tool:Activate() end)
			end)
		end
	end

	GH.RegisterToggleButton("TriggerBot", GH.T("toggle_triggerbot"), Cheats_ToggleTriggerBot, "Combat", GH.T("desc_triggerbot"))
end