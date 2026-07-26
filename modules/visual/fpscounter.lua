-- =============================================================================
-- COMMAND: FPS COUNTER
-- =============================================================================
return function(GH)
	local fpsObjects = {}

	function Cheats_ToggleFPSCounter(state, btn)
		if state then
			if fpsObjects.GUI then return end

			local gui = Instance.new("ScreenGui")
			gui.Name = "GH_FPSCounter"
			gui.ResetOnSpawn = false
			gui.IgnoreGuiInset = true
			gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
			gui.DisplayOrder = 999
			gui.Parent = GH.TargetGui

			local label = Instance.new("TextLabel")
			label.Name = "FPSLabel"
			label.Size = UDim2.new(0, 80, 0, 16)
			label.Position = UDim2.new(0, 8, 1, -22)
			label.BackgroundTransparency = 1
			label.Text = "FPS: --"
			label.TextColor3 = Color3.fromRGB(100, 100, 115)
			label.Font = Enum.Font.RobotoMono
			label.TextSize = 9
			label.TextXAlignment = Enum.TextXAlignment.Left
			label.Parent = gui

			-- FPS tracking
			local fpsFrames = 0
			local fpsLastUpdate = os.clock()
			local conn
			conn = GH.Services.RunService.RenderStepped:Connect(function()
				fpsFrames += 1
				local now = os.clock()
				if now - fpsLastUpdate >= 1 then
					local fps = math.floor(fpsFrames / (now - fpsLastUpdate) + 0.5)
					label.Text = "FPS: " .. fps
					if fps >= 50 then
						label.TextColor3 = Color3.fromRGB(80, 200, 120)
					elseif fps >= 30 then
						label.TextColor3 = Color3.fromRGB(200, 180, 80)
					else
						label.TextColor3 = Color3.fromRGB(255, 80, 80)
					end
					fpsFrames = 0
					fpsLastUpdate = now
				end
			end)

			fpsObjects = { GUI = gui, Label = label, Conn = conn }
		else
			if fpsObjects.GUI then
				if fpsObjects.Conn then
					fpsObjects.Conn:Disconnect()
				end
				fpsObjects.GUI:Destroy()
				fpsObjects = {}
			end
		end
	end

	GH.RegisterToggleButton("FPSCounter", "toggle_fpscounter", Cheats_ToggleFPSCounter, "Visual", "desc_fpscounter")
end
