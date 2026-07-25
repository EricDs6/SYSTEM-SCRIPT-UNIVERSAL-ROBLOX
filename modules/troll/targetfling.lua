-- =============================================================================
-- COMMAND: TARGET FLING
-- =============================================================================
return function(GH)
	local Players = GH.Services.Players
	local RunService = GH.Services.RunService
	local LocalPlayer = GH.LocalPlayer

	local TargetFlingTarget = nil

	function Cheats_ToggleTargetFling(state, btn)
		GH.UnregisterMasterLoop("TargetFling")
		GH.Disconnect("TargetFlingRespawn")
		GH.Disconnect("TargetFlingPlayerAdded")
		GH.Disconnect("TargetFlingPlayerRemoving")
		if GH.Objects.TargetFlingDropdown then
			GH.Objects.TargetFlingDropdown:Destroy()
			GH.Objects.TargetFlingDropdown = nil
		end
		TargetFlingTarget = nil

		pcall(function()
			local char = LocalPlayer.Character
			local hrp = char and char:FindFirstChild("HumanoidRootPart")
			if hrp then
				local oldSpin = hrp:FindFirstChild("GH_TargetSpin")
				if oldSpin then oldSpin:Destroy() end
				hrp.AssemblyAngularVelocity = Vector3.zero
				hrp.AssemblyLinearVelocity = Vector3.zero
				for _, part in ipairs(char:GetDescendants()) do
					if part:IsA("BasePart") then part.CanCollide = true end
				end
				local hum = char:FindFirstChildOfClass("Humanoid")
				if hum then hum.AutoRotate = true end
			end
		end)

		if not state then return end

		local function startFlinging(targetPlayer)
			TargetFlingTarget = targetPlayer

			local char = LocalPlayer.Character
			local hrp = char and char:FindFirstChild("HumanoidRootPart")
			local hum = char and char:FindFirstChildOfClass("Humanoid")
			if not hrp or not hum then return end
			hum.AutoRotate = false
			for _, part in ipairs(char:GetDescendants()) do
				if part:IsA("BasePart") then part.CanCollide = false end
			end

			local oldSpin = hrp:FindFirstChild("GH_TargetSpin")
			if oldSpin then oldSpin:Destroy() end
			local spinForce = Instance.new("AngularVelocity")
			spinForce.Name = "GH_TargetSpin"
			spinForce.AngularVelocity = Vector3.new(0, 5000, 0)
			spinForce.MaxTorque = math.huge
			spinForce.Attachment0 = hrp:FindFirstChildOfClass("Attachment") or Instance.new("Attachment", hrp)
			spinForce.Parent = hrp

			GH.ShowToast(string.format(GH.T("toast_target_fling"), targetPlayer.Name), GH.Theme.Red, 2)

			GH.RegisterMasterLoop("TargetFling", "Heartbeat", function()
				if GH.isClosing or not GH.States.TargetFling then
					GH.UnregisterMasterLoop("TargetFling"); return
				end
				local myHRP = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
				local myHum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
				if not myHRP or not myHum or myHum.Health <= 0 then return end
				for _, part in ipairs(LocalPlayer.Character:GetDescendants()) do
					if part:IsA("BasePart") then part.CanCollide = false end
				end
				local targetHRP = TargetFlingTarget and TargetFlingTarget.Character and TargetFlingTarget.Character:FindFirstChild("HumanoidRootPart")
				if targetHRP then
					myHRP.CFrame = targetHRP.CFrame
					myHRP.AssemblyLinearVelocity = Vector3.new(0, 100, 0)
				end
			end)
		end

		local function refreshList()
			local names = {}
			for _, player in ipairs(Players:GetPlayers()) do
				if player ~= LocalPlayer then
					table.insert(names, player.Name)
				end
			end
			if GH.Objects.TargetFlingDropdown then
				GH.Objects.TargetFlingDropdown:SetValues(names)
			end
		end

		local initialNames = {}
		for _, player in ipairs(Players:GetPlayers()) do
			if player ~= LocalPlayer then
				table.insert(initialNames, player.Name)
			end
		end

		local dropdown = GH.Tabs["Troll"]:AddDropdown("TargetFling_Select", {
			Title = GH.T("dropdown_targetfling_title"),
			Values = initialNames,
			AllowNull = true,
		})
		GH.Objects.TargetFlingDropdown = dropdown

		dropdown:OnChanged(function(name)
			if name then
				local player = Players:FindFirstChild(name)
				if player then
					startFlinging(player)
				end
			end
		end)

		refreshList()
		GH.Connections.TargetFlingPlayerAdded = Players.PlayerAdded:Connect(function()
			if GH.States.TargetFling then refreshList() end
		end)
		GH.Connections.TargetFlingPlayerRemoving = Players.PlayerRemoving:Connect(function()
			if GH.States.TargetFling then refreshList() end
		end)
	end

	GH.RegisterToggleButton("TargetFling", GH.T("toggle_targetfling"), Cheats_ToggleTargetFling, "Troll", GH.T("desc_targetfling"))
end