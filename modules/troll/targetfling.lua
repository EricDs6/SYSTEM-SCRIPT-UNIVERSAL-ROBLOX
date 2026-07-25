-- =============================================================================
-- COMMAND: TARGET FLING
-- =============================================================================
return function(GH)
	local Players = GH.Services.Players
	local RunService = GH.Services.RunService
	local LocalPlayer = GH.LocalPlayer

	GH.Cache.TargetFlingTarget = nil

	function Cheats_ToggleTargetFling(state, btn)
		GH.UnregisterMasterLoop("TargetFling")

		if not state then
			if GH.Objects.TargetFlingPicker then
				GH.Objects.TargetFlingPicker.Close()
				GH.Objects.TargetFlingPicker = nil
			end
			GH.Cache.TargetFlingTarget = nil
			-- Restore
			pcall(function()
				local char = LocalPlayer.Character
				if char then
					local hrp = char:FindFirstChild("HumanoidRootPart")
					if hrp then
						local spin = hrp:FindFirstChild("GH_TargetSpin")
						if spin then spin:Destroy() end
						hrp.AssemblyAngularVelocity = Vector3.zero
						hrp.AssemblyLinearVelocity = Vector3.zero
					end
					local hum = char:FindFirstChildOfClass("Humanoid")
					if hum then hum.AutoRotate = true end
					for _, part in ipairs(char:GetDescendants()) do
						if part:IsA("BasePart") then part.CanCollide = true end
					end
				end
			end)
			return
		end

		local picker = GH.ShowPlayerPicker(GH.T("dropdown_targetfling_title"), function(name)
			local player = Players:FindFirstChild(name)
			if player then
				GH.Cache.TargetFlingTarget = player
				GH.ShowToast(string.format(GH.T("toast_target_fling"), name), GH.Theme.Red, 2)
			end
		end)
		GH.Objects.TargetFlingPicker = picker

		GH.RegisterMasterLoop("TargetFling", "Heartbeat", function()
			local target = GH.Cache.TargetFlingTarget
			if not target or not target.Character then return end
			local targetRoot = target.Character:FindFirstChild("HumanoidRootPart")
			local myChar = LocalPlayer.Character
			local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
			local myHum = myChar and myChar:FindFirstChildOfClass("Humanoid")
			if not targetRoot or not myRoot or not myHum then return end

			-- Disable collisions
			for _, part in ipairs(myChar:GetDescendants()) do
				if part:IsA("BasePart") then part.CanCollide = false end
			end
			myHum.AutoRotate = false

			-- Add spin
			local spin = myRoot:FindFirstChild("GH_TargetSpin")
			if not spin then
				spin = Instance.new("AngularVelocity")
				spin.Name = "GH_TargetSpin"
				spin.AngularVelocity = Vector3.new(0, 100, 0)
				spin.MaxTorque = math.huge
				spin.P = math.huge
				spin.Parent = myRoot
			end

			-- Move to target
			myRoot.CFrame = targetRoot.CFrame + Vector3.new(0, -2, 0)
		end)
	end

	GH.RegisterToggleButton("TargetFling", "toggle_targetfling", Cheats_ToggleTargetFling, "Troll", "desc_targetfling")
end
