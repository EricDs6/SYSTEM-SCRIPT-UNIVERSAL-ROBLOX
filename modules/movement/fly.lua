-- =============================================================================
-- COMMAND: FLY (Profissional - Destravado)
-- Voar livremente com WASD + Space/Shift. Scroll ajusta velocidade.
-- =============================================================================
return function(GH)
	local UserInputService = GH.Services.UserInputService
	local RunService = GH.Services.RunService
	local LocalPlayer = GH.LocalPlayer

	local noclipParts = {}
	local keys = { W = false, A = false, S = false, D = false, Space = false, LeftShift = false }

	local function clearNoclip()
		for p, _ in pairs(noclipParts) do
			if p and p.Parent then
				pcall(function() p.CanCollide = true end)
			end
		end
		table.clear(noclipParts)
	end

	function Cheats_ToggleFly(state, btn)
		GH.Disconnect("Fly_Stepped")
		GH.Disconnect("Fly_InputBegan")
		GH.Disconnect("Fly_InputEnded")
		GH.Disconnect("Fly_Scroll")
		clearNoclip()

		if not state then
			local char = LocalPlayer.Character
			local hrp = char and char:FindFirstChild("HumanoidRootPart")
			local hum = char and char:FindFirstChildOfClass("Humanoid")
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
			for k in pairs(keys) do keys[k] = false end
			return
		end

		local char = LocalPlayer.Character
		local hum = char and char:FindFirstChildOfClass("Humanoid")
		local hrp = char and char:FindFirstChild("HumanoidRootPart")
		if not hum or not hrp then return end

		for k in pairs(keys) do keys[k] = false end

		hum.AutoRotate = false
		hum:SetStateEnabled(Enum.HumanoidStateType.Freefall, false)
		hum:ChangeState(Enum.HumanoidStateType.Running)

		-- LinearVelocity
		local lv = Instance.new("LinearVelocity")
		lv.Name = "GH_FlyLV"
		lv.MaxForce = math.huge
		lv.Attachment0 = hrp:FindFirstChildOfClass("Attachment") or Instance.new("Attachment", hrp)
		lv.VectorVelocity = Vector3.zero
		lv.VelocityConstraintMode = Enum.VelocityConstraintMode.Vector
		lv.Parent = hrp

		-- AngularVelocity
		local av = Instance.new("AngularVelocity")
		av.Name = "GH_FlyAV"
		av.MaxTorque = math.huge
		av.Attachment0 = lv.Attachment0
		av.AngularVelocity = Vector3.zero
		av.Parent = hrp

		-- InputBegan: teclas pressionadas
		GH.Connections.Fly_InputBegan = UserInputService.InputBegan:Connect(function(input, gpe)
			if gpe then return end
			if not GH.States.Fly then return end
			local name = input.KeyCode.Name
			if keys[name] ~= nil then
				keys[name] = true
			end
		end)

		-- InputEnded: teclas soltas
		GH.Connections.Fly_InputEnded = UserInputService.InputEnded:Connect(function(input)
			local name = input.KeyCode.Name
			if keys[name] ~= nil then
				keys[name] = false
			end
		end)

		-- Scroll: ajustar velocidade
		GH.Connections.Fly_Scroll = UserInputService.InputChanged:Connect(function(input)
			if not GH.States.Fly then return end
			if input.UserInputType == Enum.UserInputType.MouseWheel then
				local dir = input.Position.Z > 0 and 5 or -5
				GH.FlySpeed = math.clamp((GH.FlySpeed or 20) + dir, 5, 200)
			end
		end)

		-- Loop principal (camera-based)
		GH.Connections.Fly_Stepped = RunService.RenderStepped:Connect(function(dt)
			if GH.isClosing then return end
			if not LocalPlayer.Character or not hrp.Parent or hum.Health <= 0 then
				GH.Disconnect("Fly_Stepped")
				GH.Disconnect("Fly_InputBegan")
				GH.Disconnect("Fly_InputEnded")
				GH.Disconnect("Fly_Scroll")
				clearNoclip()
				return
			end

			hum.PlatformStand = false
			av.AngularVelocity = Vector3.zero

			-- Velocidade
			local flySpeed = GH.FlySpeed or 20

			-- Boost com LeftShift
			if keys.LeftShift then
				flySpeed = flySpeed * 2
			end

			-- Camera vectors
			local cam = workspace.CurrentCamera
			if not cam then return end
			local camCF = cam.CFrame
			local lookVec = camCF.LookVector
			local rightVec = camCF.RightVector

			-- Direcao do movimento baseada na camera
			local moveDir = Vector3.zero
			moveDir = moveDir + lookVec * ((keys.W and 1 or 0) + (keys.S and -1 or 0))
			moveDir = moveDir + rightVec * ((keys.D and 1 or 0) + (keys.A and -1 or 0))

			-- Vertical
			local vert = 0
			if keys.Space then
				vert = flySpeed
			elseif UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
				vert = -flySpeed
			end

			-- Normalizar e aplicar velocidade
			if moveDir.Magnitude > 0 then
				moveDir = moveDir.Unit * flySpeed
			end

			lv.VectorVelocity = Vector3.new(moveDir.X, vert, moveDir.Z)

			-- Noclip
			local r = 3
			local myChar = LocalPlayer.Character
			if myChar then
				for p, _ in pairs(noclipParts) do
					if not p or not p.Parent then
						noclipParts[p] = nil
					else
						local dist = (p.Position - hrp.Position).Magnitude
						if dist > r * 2 then
							pcall(function() p.CanCollide = true end)
							noclipParts[p] = nil
						end
					end
				end

				for _, part in ipairs(myChar:GetDescendants()) do
					if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
						part.CanCollide = false
					end
				end

				local overlapParams = OverlapParams.new()
				overlapParams.FilterDescendantsInstances = { myChar }
				overlapParams.FilterType = Enum.RaycastFilterType.Exclude
				local parts = workspace:GetPartBoundsInBox(hrp.CFrame, Vector3.new(r, r, r), overlapParams)
				for _, p in ipairs(parts) do
					if p:IsA("BasePart") and p ~= hrp and p.CanCollide then
						p.CanCollide = false
						noclipParts[p] = true
					end
				end
			end
		end)

		GH.ShowToast("Fly: WASD+Space/Ctrl | Shift=boost | Scroll=velocidade (" .. (GH.FlySpeed or 20) .. ")", GH.Theme.On, 3)
	end

	-- Reconectar ao respawn
	GH.Connections.Fly_CharAdded = LocalPlayer.CharacterAdded:Connect(function()
		if GH.States.Fly then
			task.wait(0.5)
			GH.States.Fly = false
			Cheats_ToggleFly(false, nil)
			task.wait(0.5)
			if GH.States.Fly == false then
				GH.States.Fly = true
				Cheats_ToggleFly(true, nil)
			end
		end
	end)

	GH.RegisterToggleButton("Fly", "toggle_fly", Cheats_ToggleFly, "Movement", "desc_fly")
end
