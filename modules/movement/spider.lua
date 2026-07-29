-- =============================================================================
-- COMMAND: SPIDER / WALL CLIMB (REAL WALL-WALKER)
-- Simula o player grudando os pes na parede e andando sobre ela
-- =============================================================================
return function(GH)
	local RunService = GH.Services.RunService
	local LocalPlayer = GH.LocalPlayer

	local climbSpeed = 20
	local rayDistance = 3.5

	-- Projetar vetor na superficie da parede
	local function ProjectOnWall(vector, wallNormal)
		local projected = vector - wallNormal * vector:Dot(wallNormal)
		if projected.Magnitude < 0.001 then
			return nil
		end
		return projected.Unit
	end

	-- Raycast para encontrar a parede mais proxima
	local function GetWallInfo(character)
		local rootPart = character:FindFirstChild("HumanoidRootPart")
		if not rootPart then return nil end

		local raycastParams = RaycastParams.new()
		raycastParams.FilterDescendantsInstances = { character }
		raycastParams.FilterType = Enum.RaycastFilterType.Exclude

		local directions = {
			rootPart.CFrame.LookVector,
			rootPart.CFrame.RightVector,
			-rootPart.CFrame.RightVector,
			-rootPart.CFrame.LookVector,
		}

		local bestWall = nil
		local bestDistance = math.huge

		for _, dir in ipairs(directions) do
			local rayResult = workspace:Raycast(rootPart.Position, dir * rayDistance, raycastParams)

			if rayResult and rayResult.Instance then
				local normalUpDot = math.abs(rayResult.Normal:Dot(Vector3.yAxis))
				-- Apenas superficies verticais (paredes)
				if normalUpDot < 0.7 then
					local dist = (rayResult.Position - rootPart.Position).Magnitude
					if dist < bestDistance then
						bestDistance = dist
						bestWall = {
							normal = rayResult.Normal,
							position = rayResult.Position,
							instance = rayResult.Instance,
						}
					end
				end
			end
		end

		return bestWall
	end

	-- Cria os elementos de fisica (LinearVelocity e AlignOrientation)
	local function CreateWallConstraints(rootPart)
		local oldLV = rootPart:FindFirstChild("GH_SpiderLV")
		local oldAO = rootPart:FindFirstChild("GH_SpiderAO")
		if oldLV then oldLV:Destroy() end
		if oldAO then oldAO:Destroy() end

		local attachment = rootPart:FindFirstChild("GH_SpiderAttachment")
		if not attachment then
			attachment = Instance.new("Attachment")
			attachment.Name = "GH_SpiderAttachment"
			attachment.Parent = rootPart
		end

		local lv = Instance.new("LinearVelocity")
		lv.Name = "GH_SpiderLV"
		lv.MaxForce = 999999
		lv.Attachment0 = attachment
		lv.VectorVelocity = Vector3.zero
		lv.VelocityConstraintMode = Enum.VelocityConstraintMode.Vector
		lv.Parent = rootPart

		local ao = Instance.new("AlignOrientation")
		ao.Name = "GH_SpiderAO"
		ao.MaxTorque = 999999
		ao.Attachment0 = attachment
		ao.Mode = Enum.OrientationAlignmentMode.OneAttachment
		ao.Responsiveness = 40
		ao.RigidityEnabled = false
		ao.Parent = rootPart

		return lv, ao
	end

	local function RemoveWallConstraints(rootPart)
		if not rootPart then return end
		local lv = rootPart:FindFirstChild("GH_SpiderLV")
		local ao = rootPart:FindFirstChild("GH_SpiderAO")
		local att = rootPart:FindFirstChild("GH_SpiderAttachment")
		if lv then lv:Destroy() end
		if ao then ao:Destroy() end
		if att then att:Destroy() end
	end

	function Cheats_ToggleSpider(state, btn)
		GH.Disconnect("Spider_Stepped")

		local char = LocalPlayer.Character
		if not char then return end
		local hrp = char:FindFirstChild("HumanoidRootPart")
		local hum = char:FindFirstChildWhichIsA("Humanoid")

		if not state then
			if hrp then
				RemoveWallConstraints(hrp)
				hrp.AssemblyLinearVelocity = Vector3.zero
				hrp.AssemblyAngularVelocity = Vector3.zero
			end

			if hum then
				hum.AutoRotate = true
				hum:SetStateEnabled(Enum.HumanoidStateType.Freefall, true)
				hum:SetStateEnabled(Enum.HumanoidStateType.Climbing, true)
				pcall(function() hum:ChangeState(Enum.HumanoidStateType.GettingUp) end)
			end
			return
		end

		if not hrp or not hum then return end

		local lv, ao = CreateWallConstraints(hrp)
		local isOnWall = false

		GH.Connections.Spider_Stepped = RunService.Heartbeat:Connect(function()
			if GH.isClosing or not GH.States.Spider then
				GH.Disconnect("Spider_Stepped")
				return
			end

			local currentCharacter = LocalPlayer.Character
			if not currentCharacter then return end
			local root = currentCharacter:FindFirstChild("HumanoidRootPart")
			local humanoid = currentCharacter:FindFirstChildWhichIsA("Humanoid")

			if not root or not humanoid or not lv.Parent or not ao.Parent then return end

			local wallInfo = GetWallInfo(currentCharacter)

			-- Se detectou parede e o jogador esta tentando se mover (W/A/S/D)
			if wallInfo and humanoid.MoveDirection.Magnitude > 0.1 then
				if not isOnWall then
					isOnWall = true
					humanoid.AutoRotate = false
					humanoid:SetStateEnabled(Enum.HumanoidStateType.Freefall, false)
				end

				root.AssemblyAngularVelocity = Vector3.zero
				local camera = workspace.CurrentCamera

				-- Direcao de movimento na parede baseada na Camera
				local camCF = camera.CFrame
				local wallNormal = wallInfo.normal
				local wallUp = Vector3.yAxis

				-- Projeto a intencao do jogador na superficie da parede
				local rawMove = (camCF.RightVector * humanoid.MoveDirection.X) + (camCF.LookVector * -humanoid.MoveDirection.Z)
				local wallMoveDir = ProjectOnWall(rawMove, wallNormal)

				if wallMoveDir then
					-- Orientacao: Pes apontando para longe da parede, Olhar virado para a direcao que anda
					local targetLook = wallMoveDir
					local targetUp = wallNormal
					local targetRight = targetLook:Cross(targetUp).Unit
					targetLook = targetUp:Cross(targetRight).Unit

					ao.CFrame = CFrame.fromMatrix(root.Position, targetRight, targetUp, -targetLook)

					-- Movimento + Forca constante de atracao para grudar os pes
					local moveVelocity = wallMoveDir * climbSpeed
					local stickVelocity = -wallNormal * 10

					lv.VectorVelocity = moveVelocity + stickVelocity
				end

			else
				-- Fora da parede ou sem apertar teclas
				if isOnWall then
					isOnWall = false
					humanoid.AutoRotate = true
					humanoid:SetStateEnabled(Enum.HumanoidStateType.Freefall, true)
				end

				lv.VectorVelocity = Vector3.zero
				ao.CFrame = root.CFrame
			end
		end)

		if GH.ShowToast then
			GH.ShowToast(GH.T("toast_spider_active"), GH.Theme.On, 2)
		end
	end

	-- Auto-Reconectar ao Respawn
	GH.Connections.Spider_CharAdded = LocalPlayer.CharacterAdded:Connect(function()
		if GH.States.Spider then
			task.wait(0.5)
			GH.States.Spider = false
			Cheats_ToggleSpider(false, nil)
			task.wait(0.5)
			GH.States.Spider = true
			Cheats_ToggleSpider(true, nil)
		end
	end)

	GH.RegisterToggleButton("Spider", "toggle_spider", Cheats_ToggleSpider, "Movement", "desc_spider")
end
