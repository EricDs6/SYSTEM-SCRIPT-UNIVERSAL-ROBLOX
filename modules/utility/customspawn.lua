-- =============================================================================
-- COMMAND: CUSTOMSPAWN
-- =============================================================================
return function(GH)
	local Players = GH.Services.Players
	local RunService = GH.Services.RunService
	local UserInputService = GH.Services.UserInputService
	local TweenService = GH.Services.TweenService
	local LocalPlayer = GH.LocalPlayer

	function Cheats_ToggleCustomSpawn(state, btn)
		GH.Disconnect("CustomSpawnMonitor")
		GH.Disconnect("CustomSpawnDied")
		GH.Cache.SpawnCFrame = nil
		GH.Cache.ShouldSpawnAtCustom = false

		if not state then
			return
		end

		local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
		if not hrp then
			GH.States.CustomSpawn = false
			return
		end

		GH.Cache.SpawnCFrame = hrp.CFrame

		local function connectDiedListener()
			local c = LocalPlayer.Character
			if not c then return end
			local h = c:FindFirstChildOfClass("Humanoid")
			if not h then return end
			GH.Disconnect("CustomSpawnDied")
			GH.Connections.CustomSpawnDied = h.Died:Connect(function()
				if GH.States.CustomSpawn and GH.Cache.SpawnCFrame then
					GH.Cache.ShouldSpawnAtCustom = true
				end
			end)
		end

		connectDiedListener()

		GH.Connections.CustomSpawnMonitor = LocalPlayer.CharacterAdded:Connect(function(newChar)
			if not GH.States.CustomSpawn then return end
			task.defer(connectDiedListener)
			if GH.Cache.ShouldSpawnAtCustom and GH.Cache.SpawnCFrame then
				GH.Cache.ShouldSpawnAtCustom = false
				local function forceSpawn()
					local r = newChar:FindFirstChild("HumanoidRootPart")
					if r and GH.Cache.SpawnCFrame then
						r.CFrame = GH.Cache.SpawnCFrame
						r.AssemblyLinearVelocity = Vector3.zero
						r.AssemblyAngularVelocity = Vector3.zero
					end
				end
				forceSpawn()
				task.delay(0.05, forceSpawn)
				task.delay(0.1, forceSpawn)
				task.delay(0.2, forceSpawn)
			end
		end)
	end

	GH.RegisterToggleButton("CustomSpawn", "toggle_customspawn", Cheats_ToggleCustomSpawn, "Utility", "desc_customspawn")
end
