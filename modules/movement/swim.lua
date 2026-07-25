-- =============================================================================
-- COMMAND: SWIM
-- =============================================================================
return function(GH)
	local RunService = GH.Services.RunService
	local UserInputService = GH.Services.UserInputService
	local LocalPlayer = GH.LocalPlayer

	function Cheats_ToggleSwim(state, btn)
		GH.UnregisterMasterLoop("Swim")
		GH.Disconnect("SwimDied")

		if state then
			local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
			if not hum then return end

			GH.Cache.SwimOldGravity = workspace.Gravity
			workspace.Gravity = 0

			local enums = Enum.HumanoidStateType:GetEnumItems()
			table.remove(enums, table.find(enums, Enum.HumanoidStateType.None))
			for _, v in ipairs(enums) do hum:SetStateEnabled(v, false) end
			hum:ChangeState(Enum.HumanoidStateType.Swimming)

			GH.Connections.SwimDied = hum.Died:Connect(function()
				workspace.Gravity = GH.Cache.SwimOldGravity or 196.2
				GH.States.Swim = false
			end)

			GH.RegisterMasterLoop("Swim", "Heartbeat", function()
				if GH.isClosing or not GH.States.Swim then
					workspace.Gravity = GH.Cache.SwimOldGravity or 196.2
					GH.UnregisterMasterLoop("Swim")
					local h = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
					if h then
						local e2 = Enum.HumanoidStateType:GetEnumItems()
						table.remove(e2, table.find(e2, Enum.HumanoidStateType.None))
						for _, v in ipairs(e2) do h:SetStateEnabled(v, true) end
					end
					return
				end
				pcall(function()
					local c = LocalPlayer.Character
					local h = c and c:FindFirstChildOfClass("Humanoid")
					local r = c and c:FindFirstChild("HumanoidRootPart")
					if h and r then
						h:ChangeState(Enum.HumanoidStateType.Swimming)
						local moveDir = h.MoveDirection
						local isMoving = moveDir.Magnitude > 0
						local isJumping = UserInputService:IsKeyDown(Enum.KeyCode.Space)
						if not isMoving and not isJumping then
							r.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
						end
					end
				end)
			end)
		else
			workspace.Gravity = GH.Cache.SwimOldGravity or 196.2
			local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
			if hum then
				local enums = Enum.HumanoidStateType:GetEnumItems()
				table.remove(enums, table.find(enums, Enum.HumanoidStateType.None))
				for _, v in ipairs(enums) do hum:SetStateEnabled(v, true) end
			end
		end
	end

	GH.RegisterToggleButton("Swim", GH.T("toggle_swim"), Cheats_ToggleSwim, "Movement", GH.T("desc_swim"))
end