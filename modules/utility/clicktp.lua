-- =============================================================================
-- COMMAND: CLICKTP (Click TP Tool)
-- =============================================================================
return function(GH)
	local Players = GH.Services.Players
	local RunService = GH.Services.RunService
	local UserInputService = GH.Services.UserInputService
	local TweenService = GH.Services.TweenService
	local LocalPlayer = GH.LocalPlayer

	local TpTool = nil

	function Cheats_ToggleTPTool(state, btn)
		if state then
			local bp = LocalPlayer:WaitForChild("Backpack", 5)
			if bp then
				TpTool = Instance.new("Tool")
				TpTool.Name = "Click TP"
				TpTool.RequiresHandle = false
				TpTool.Parent = bp
				TpTool.Activated:Connect(function()
					local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
					local mouse = LocalPlayer:GetMouse()
					if hrp and mouse.Hit then
						GH.TweenTeleport(hrp, CFrame.new(mouse.Hit.Position + Vector3.new(0, 4, 0)))
					end
				end)
			end
		else
			if TpTool then TpTool:Destroy(); TpTool = nil end
		end
	end

	GH.RegisterToggleButton("ClickTP", "toggle_clicktp", Cheats_ToggleTPTool, "Utility", "desc_clicktp")
end
