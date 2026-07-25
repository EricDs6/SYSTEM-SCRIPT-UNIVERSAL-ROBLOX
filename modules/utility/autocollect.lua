-- =============================================================================
-- COMMAND: AUTO COLLECT
-- =============================================================================
return function(GH)
	local Players = GH.Services.Players
	local RunService = GH.Services.RunService
	local UserInputService = GH.Services.UserInputService
	local TweenService = GH.Services.TweenService
	local LocalPlayer = GH.LocalPlayer

	function Cheats_ToggleAutoCollect(state, btn)
		GH.UnregisterMasterLoop("AutoCollect")
		if state then
			local tick = 0
			GH.RegisterMasterLoop("AutoCollect", "Heartbeat", function()
				if GH.isClosing or not GH.States.AutoCollect then
					GH.UnregisterMasterLoop("AutoCollect"); return
				end
				tick += 1
				if tick % 30 ~= 0 then return end
				local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
				if not hrp then return end
				pcall(function()
					for _, obj in ipairs(workspace:GetChildren()) do
						if obj:IsA("Tool") and obj:FindFirstChild("Handle") then
							if (obj.Handle.Position - hrp.Position).Magnitude <= 18 then
								if typeof(firetouchinterest) == "function" then
									firetouchinterest(hrp, obj.Handle, 0)
									firetouchinterest(hrp, obj.Handle, 1)
								else
									obj.Handle.CFrame = hrp.CFrame
								end
							end
						end
					end
				end)
			end)
		end
	end

	GH.RegisterToggleButton("AutoCollect", GH.T("toggle_autocollect"), Cheats_ToggleAutoCollect, "Utility", GH.T("desc_autocollect"))
end
