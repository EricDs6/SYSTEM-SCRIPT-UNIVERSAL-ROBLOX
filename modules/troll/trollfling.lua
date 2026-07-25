-- =============================================================================
-- COMMAND: TrollFling
-- =============================================================================
return function(GH)
	local Players = GH.Services.Players
	local RunService = GH.Services.RunService
	local UserInputService = GH.Services.UserInputService
	local LocalPlayer = GH.LocalPlayer

	function Cheats_ToggleTrollFling(state, btn)
		GH.UnregisterMasterLoop("TrollFling")

		local char = LocalPlayer.Character
		local hrp = char and char:FindFirstChild("HumanoidRootPart")
		local hum = char and char:FindFirstChildOfClass("Humanoid")

		if state and hrp and hum then
			hum.AutoRotate = false
			local oldSpin = hrp:FindFirstChild("GH_TrollSpin")
			if oldSpin then oldSpin:Destroy() end

			local spinForce = Instance.new("AngularVelocity")
			spinForce.Name = "GH_TrollSpin"
			spinForce.AngularVelocity = Vector3.new(0, 100, 0)
			spinForce.MaxTorque = math.huge
			spinForce.Attachment0 = hrp:FindFirstChildOfClass("Attachment") or Instance.new("Attachment", hrp)
			spinForce.Parent = hrp

			GH.RegisterMasterLoop("TrollFling", "Heartbeat", function()
				if GH.isClosing or not GH.States.TrollFling then
					GH.UnregisterMasterLoop("TrollFling")
					local c = LocalPlayer.Character
					local h = c and c:FindFirstChildOfClass("Humanoid")
					local r = c and c:FindFirstChild("HumanoidRootPart")
					if h then h.AutoRotate = true end
					if r then
						local spin = r:FindFirstChild("GH_TrollSpin")
						if spin then spin:Destroy() end
						r.AssemblyAngularVelocity = Vector3.zero
					end
					return
				end
				local c = LocalPlayer.Character
				local h = c and c:FindFirstChildOfClass("Humanoid")
				local r = c and c:FindFirstChild("HumanoidRootPart")
				if not r or not h or h.Health <= 0 then
					GH.UnregisterMasterLoop("TrollFling"); return
				end
				local spin = r:FindFirstChild("GH_TrollSpin")
				if not spin then
					spin = Instance.new("AngularVelocity")
					spin.Name = "GH_TrollSpin"
					spin.AngularVelocity = Vector3.new(0, 100, 0)
					spin.MaxTorque = math.huge
					spin.Attachment0 = r:FindFirstChildOfClass("Attachment") or Instance.new("Attachment", r)
					spin.Parent = r
				end
				h.AutoRotate = false
				r.AssemblyLinearVelocity = Vector3.new(r.AssemblyLinearVelocity.X, 3, r.AssemblyLinearVelocity.Z)
			end)
		else
			if hum then hum.AutoRotate = true end
			if hrp then
				local spin = hrp:FindFirstChild("GH_TrollSpin")
				if spin then spin:Destroy() end
				hrp.AssemblyAngularVelocity = Vector3.zero
			end
		end
	end

	GH.RegisterToggleButton("TrollFling", GH.T("toggle_trollfling"), Cheats_ToggleTrollFling, "Troll", GH.T("desc_trollfling"))
end
