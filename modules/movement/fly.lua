-- =============================================================================
-- COMMAND: FLY (Profissional - Destravado)
-- Voar livremente com WASD + Space/Shift. Scroll ajusta velocidade.
-- =============================================================================
return function(GH)
	local UserInputService = GH.Services.UserInputService
	local RunService = GH.Services.RunService
	local Players = GH.Services.Players
	local LocalPlayer = GH.LocalPlayer

	local flySpeedMult = 1
	local noclipParts = {}

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
			return
		end

		local char = LocalPlayer.Character
		local hum = char and char:FindFirstChildOfClass("Humanoid")
		local hrp = char and char:FindFirstChild("HumanoidRootPart")
		if not hum or not hrp then return end

		flySpeedMult = 1
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

		-- AngularVelocity para estabilidade
		local av = Instance.new("AngularVelocity")
		av.Name = "GH_FlyAV"
		av.MaxTorque = math.huge
		av.Attachment0 = lv.Attachment0
		av.AngularVelocity = Vector3.zero
		av.Parent = hrp

		-- Scroll para ajustar velocidade
		GH.Connections.Fly_Scroll = UserInputService.InputChanged:Connect(function(input)
			if not GH.States.Fly then return end
			if input.UserInputType == Enum.UserInputType.MouseWheel then
				local dir = input.Position.Z > 0 and 1 or -1
				flySpeedMult = math.clamp(flySpeedMult + dir * 0.25, 0.25, 10)
			end
		end)

		-- Loop principal
		GH.Connections.Fly_Stepped = RunService.Stepped:Connect(function()
			if GH.isClosing then return end
			if not LocalPlayer.Character or not hrp.Parent or hum.Health <= 0 then
				GH.Disconnect("Fly_Stepped")
				GH.Disconnect("Fly_Scroll")
				clearNoclip()
				return
			end

			hum.PlatformStand = false
			av.AngularVelocity = Vector3.zero

			-- Velocidade base do slider + multiplicador do scroll
			local baseSpeed = GH.FlySpeed or 20
			local flySpeed = baseSpeed * flySpeedMult

			-- Boost com LeftControl (2x velocidade)
			if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
				flySpeed = flySpeed * 2
			end

			-- Movimento horizontal (WASD)
			local vel = Vector3.zero
			if hum.MoveDirection.Magnitude > 0 then
				vel = hum.MoveDirection * flySpeed
			end

			-- Movimento vertical (Space = subir, Shift = descer)
			local vert = 0
			if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
				vert = flySpeed
			elseif UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
				vert = -flySpeed
			end

			lv.VectorVelocity = Vector3.new(vel.X, vert, vel.Z)

			-- Noclip enquanto voa (desativa CanCollide de partes proximas)
			local r = 3
			local char = LocalPlayer.Character
			if char then
				-- Restaurar partes que nao estao mais proximas
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

				-- Desativar CanCollide de partes proximas
				for _, part in ipairs(char:GetDescendants()) do
					if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
						part.CanCollide = false
					end
				end

				-- Desativar de partes do mapa proximas
				local overlapParams = OverlapParams.new()
				overlapParams.FilterDescendantsInstances = { char }
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

		GH.ShowToast("Fly ativado! WASD + Space/Shift | Scroll = velocidade", GH.Theme.On, 3)
	end

	-- Parar fly ao morrer
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
