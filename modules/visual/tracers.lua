-- =============================================================================
-- COMMAND: TRACERS
-- =============================================================================
return function(GH)
	local RunService = GH.Services.RunService
	local LocalPlayer = GH.LocalPlayer

	local TracerPool = GH.ObjectPool.new(
		function()
			local line = Drawing.new("Line")
			line.Thickness = 1.5
			line.Transparency = 0.7
			return line
		end,
		function(line)
			line.Visible = false
			line.From = Vector2.zero
			line.To = Vector2.zero
		end
	)
	local CacheTracers = { Lines = {} }

	function Cheats_ToggleTracers(state, btn)
		for player, line in pairs(CacheTracers.Lines) do
			TracerPool:release(line)
			CacheTracers.Lines[player] = nil
		end
		if not state then return end

		local function ensureTracer(player)
			if player == LocalPlayer then return end
			if not CacheTracers.Lines[player] then
				CacheTracers.Lines[player] = TracerPool:get()
			end
		end

		if GH.States.ESP then
			for player, _ in pairs(GH.Cache.ESPPlayers) do
				if player and player.Parent then ensureTracer(player) end
			end
		end

		GH.Connections.TracersLoop = RunService.RenderStepped:Connect(function()
			if GH.isClosing or not GH.States.Tracers then return end
			local cam = workspace.CurrentCamera
			if not cam then return end
			local screenCenter = Vector2.new(cam.ViewportSize.X / 2, cam.ViewportSize.Y)

			for player, _ in pairs(GH.Cache.ESPPlayers) do
				if player and player.Parent and player.Character then
					local hrp = player.Character:FindFirstChild("HumanoidRootPart")
					if not hrp then continue end
					if not CacheTracers.Lines[player] then
						CacheTracers.Lines[player] = TracerPool:get()
					end
					local line = CacheTracers.Lines[player]
					local screenPos, onScreen = cam:WorldToViewportPoint(hrp.Position)
					if onScreen then
						line.From = screenCenter
						line.To = Vector2.new(screenPos.X, screenPos.Y)
						line.Visible = true
						if LocalPlayer.Team and player.Team then
							line.Color = (player.Team == LocalPlayer.Team) and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
						else
							line.Color = Color3.fromRGB(255, 255, 0)
						end
					else
						line.Visible = false
					end
				end
			end
		end)
	end

	GH.RegisterToggleButton("Tracers", "toggle_tracers", Cheats_ToggleTracers, "Visual", "desc_tracers")
end