-- =============================================================================
-- COMMAND: PROXIMITY INSTANT
-- =============================================================================
return function(GH)
	local Players = GH.Services.Players
	local RunService = GH.Services.RunService
	local UserInputService = GH.Services.UserInputService
	local TweenService = GH.Services.TweenService
	local LocalPlayer = GH.LocalPlayer

	local ProximityCache = {}

	function Cheats_ToggleProximityInstant(state, btn)
		GH.Disconnect("ProximityLoop")
		if state then
			for _, obj in ipairs(workspace:GetDescendants()) do
				if obj:IsA("ProximityPrompt") then
					if not ProximityCache[obj] then ProximityCache[obj] = obj.HoldDuration end
					obj.HoldDuration = 0
				end
			end
			GH.Connections.ProximityLoop = workspace.DescendantAdded:Connect(function(desc)
				if GH.States.ProximityInstant and desc:IsA("ProximityPrompt") then
					if not ProximityCache[desc] then ProximityCache[desc] = desc.HoldDuration end
					desc.HoldDuration = 0
				end
			end)
		else
			for prompt, dur in pairs(ProximityCache) do
				if prompt and prompt.Parent then pcall(function() prompt.HoldDuration = dur end) end
			end
			table.clear(ProximityCache)
		end
	end

	GH.RegisterToggleButton("ProximityInstant", "toggle_proximityinstant", Cheats_ToggleProximityInstant, "Utility", "desc_proximityinstant")
end
