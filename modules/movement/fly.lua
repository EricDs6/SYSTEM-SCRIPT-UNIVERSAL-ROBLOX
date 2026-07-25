-- =============================================================================
-- COMMAND: FLY
-- Voar pelo mapa com WASD. Scroll ajusta velocidade
-- =============================================================================
return function(GH)
	local UserInputService = GH.Services.UserInputService
	local RunService = GH.Services.RunService
	local LocalPlayer = GH.LocalPlayer

	function Cheats_ToggleFly(state, btn)
		GH.Disconnect("Fly_Stepped")

		local char = LocalPlayer.Character
		local hum = char and char:FindFirstChildOfClass("Humanoid")
		local hrp = char and char:FindFirstChild("HumanoidRootPart")

		if state and hum and hrp then
			hum.AutoRotate = false
			hum:SetStateEnabled(Enum.HumanoidStateType.Freefall, false)
			hum:ChangeState(Enum.HumanoidStateType.Running)

			-- LinearVelocity para movimento
			local lv = Instance.new("LinearVelocity")
			lv.Name = "GH_FlyLV"
			lv.MaxForce = math.huge
			lv.Attachment0 = hrp:FindFirstChildOfClass("Attachment") or Instance.new("Attachment", hrp)
			lv.VectorVelocity = Vector3.zero
			lv.VelocityConstraintMode = Enum.VelocityConstraintMode.Vector
			lv.Parent = hrp

			-- AngularVelocity para rotacao
			local av = Instance.new("AngularVelocity")
			av.Name = "GH_FlyAV"
			av.MaxTorque = math.huge
			av.Attachment0 = lv.Attachment0
			av.AngularVelocity = Vector3.zero
			av.Parent = hrp

			GH.Connections.Fly_Stepped = RunService.Stepped:Connect(function()
				if GH.isClosing then return end
				if not LocalPlayer.Character or not hrp.Parent or hum.Health <= 0 then
					GH.Disconnect("Fly_Stepped")
					return
				end

				hum.PlatformStand = false
				av.AngularVelocity = Vector3.zero

				local flySpeed = GH.FlySpeed or 20
				local vel = Vector3.zero
				if hum.MoveDirection.Magnitude > 0 then
					vel = hum.MoveDirection * flySpeed
				end
				local vert = 0
				if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
					vert = flySpeed
				elseif UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
					vert = -flySpeed
				end

				lv.VectorVelocity = Vector3.new(vel.X, vert, vel.Z)
			end)
		else
			if hrp then
				local lv = hrp:FindFirstChild("GH_FlyLV")
				local av = hrp:FindFirstChild("GH_FlyAV")
				if lv then lv:Destroy() end
				if av then av:Destroy() end
				hrp.AssemblyLinearVelocity = Vector3.zero
				hrp.AssemblyAngularVelocity = Vector3.zero
			end
			if hum then
				hum.AutoRotate = true
				hum:SetStateEnabled(Enum.HumanoidStateType.Freefall, true)
				hum:ChangeState(Enum.HumanoidStateType.GettingUp)
			end
		end
	end

	GH.RegisterToggleButton("Fly", "toggle_fly", Cheats_ToggleFly, "Movement", "desc_fly")
end
