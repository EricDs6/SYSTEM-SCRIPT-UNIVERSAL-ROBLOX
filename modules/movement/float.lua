-- =============================================================================
-- COMMAND: FLOAT
-- =============================================================================
return function(GH)
	local UserInputService = GH.Services.UserInputService
	local RunService = GH.Services.RunService
	local LocalPlayer = GH.LocalPlayer

	function Cheats_ToggleFloat(state, btn)
		GH.UnregisterMasterLoop("Float")
		GH.Disconnect("FloatKeyQ")
		GH.Disconnect("FloatKeyE")
		GH.Disconnect("FloatKeyEnded")
		GH.Disconnect("FloatLoop")

		local char = LocalPlayer.Character
		if char then
			local old = char:FindFirstChild("GH_FloatPad")
			if old then old:Destroy() end
		end

		if state then
			local char = LocalPlayer.Character
			local hrp = char and char:FindFirstChild("HumanoidRootPart")
			if not char or not hrp then return end

			local FloatValue = -3.1

			local pad = Instance.new("Part")
			pad.Name = "GH_FloatPad"
			pad.Size = Vector3.new(2, 0.2, 1.5)
			pad.Transparency = 1
			pad.Anchored = true
			pad.CFrame = hrp.CFrame * CFrame.new(0, FloatValue, 0)
			pad.Parent = char

			GH.Connections.FloatKeyQ = UserInputService.InputBegan:Connect(function(input, gpe)
				if gpe or not GH.States.Float then return end
				if input.KeyCode == Enum.KeyCode.Q then
					FloatValue = FloatValue - 0.5
				end
			end)
			GH.Connections.FloatKeyE = UserInputService.InputBegan:Connect(function(input, gpe)
				if gpe or not GH.States.Float then return end
				if input.KeyCode == Enum.KeyCode.E then
					FloatValue = FloatValue + 1.5
				end
			end)

			GH.Connections.FloatKeyEnded = UserInputService.InputEnded:Connect(function(input)
				if not GH.States.Float then return end
				if input.KeyCode == Enum.KeyCode.Q then
					FloatValue = FloatValue + 0.5
				elseif input.KeyCode == Enum.KeyCode.E then
					FloatValue = FloatValue - 1.5
				end
			end)

			GH.Connections.FloatLoop = RunService.Heartbeat:Connect(function()
				if not GH.States.Float or not char or not char.Parent then
					GH.Disconnect("FloatLoop")
					return
				end
				local r = char:FindFirstChild("HumanoidRootPart")
				local p = char:FindFirstChild("GH_FloatPad")
				if r and p then
					p.CFrame = r.CFrame * CFrame.new(0, FloatValue, 0)
				end
			end)
		else
			local p = char and char:FindFirstChild("GH_FloatPad")
			if p then p:Destroy() end
		end
	end

	GH.RegisterToggleButton("Float", "toggle_float", Cheats_ToggleFloat, "Movement", "desc_float")
end