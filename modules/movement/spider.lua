-- =============================================================================
-- COMMAND: SPIDER / WALL CLIMB
-- Simula o player grudando os pes na parede e andando sobre ela
-- =============================================================================
return function(GH)
	local RunService = GH.Services.RunService
	local LocalPlayer = GH.LocalPlayer

	local climbSpeed = 16
	local wallStickOffset = 0.8
	local rayDistance = 3.0

	-- Funcao para projetar um vetor na superficie da parede
	local function ProjectOnWall(vector, wallNormal)
		local projected = vector - wallNormal * vector:Dot(wallNormal)
		if projected.Magnitude < 0.001 then
			return nil
		end
		return projected.Unit
	end

	-- Funcao para detectar a parede e obter informacoes da superficie
	local function GetWallInfo(character)
		local rootPart = character:FindFirstChild("HumanoidRootPart")
		if not rootPart then return nil end

		local raycastParams = RaycastParams.new()
		raycastParams.FilterDescendantsInstances = { character }
		raycastParams.FilterType = Enum.RaycastFilterType.Exclude

		-- Dispara raios em 4 direcoes, priorizando a frente
		local directions = {
			rootPart.CFrame.LookVector,
			rootPart.CFrame.RightVector,
			-rootPart.CFrame.RightVector,
			-rootPart.CFrame.LookVector,
		}

		local bestWall = nil
		local bestDistance = math.huge

		for _, dir in ipairs(directions) do
			local rayResult = workspace:Raycast(
				rootPart.Position,
				dir * rayDistance,
				raycastParams
			)

			if rayResult and rayResult.Instance then
				-- Verifica se e parede (vertical) e nao chao/teto
				local normalUpDot = math.abs(rayResult.Normal:Dot(Vector3.yAxis))
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

	-- Funcao para calcular CFrame na parede
	local function CalculateWallCFrame(rootPart, wallInfo, moveDirection)
		local wallNormal = wallInfo.normal
		local wallPos = wallInfo.position

		-- Up do personagem aponta para fora da parede
		local characterUp = wallNormal

		-- Direcao que o personagem olha na parede
		local lookAlongWall
		if moveDirection.Magnitude > 0.1 then
			lookAlongWall = ProjectOnWall(moveDirection, wallNormal)
		end
		if not lookAlongWall then
			lookAlongWall = ProjectOnWall(rootPart.CFrame.LookVector, wallNormal)
		end
		if not lookAlongWall then
			lookAlongWall = ProjectOnWall(Vector3.yAxis, wallNormal)
		end
		if not lookAlongWall then
			lookAlongWall = ProjectOnWall(rootPart.CFrame.RightVector, wallNormal)
		end
		if not lookAlongWall then
			return rootPart.CFrame
		end

		-- Right do personagem
		local characterRight = lookAlongWall:Cross(characterUp)
		if characterRight.Magnitude < 0.001 then
			return rootPart.CFrame
		end
		characterRight = characterRight.Unit

		-- Recalcula look para ortogonalidade
		lookAlongWall = characterUp:Cross(characterRight).Unit

		-- Posicao afastada da parede
		local targetPos = wallPos + wallNormal * wallStickOffset

		return CFrame.fromMatrix(targetPos, characterRight, characterUp, -lookAlongWall)
	end

	-- Funcao para calcular direcao de movimento na superficie da parede
	local function GetWallMoveDirection(wallNormal, humanoidMoveDir, camera)
		if humanoidMoveDir.Magnitude < 0.1 then
			return Vector3.zero
		end

		local camCF = camera.CFrame
		local wallForward = ProjectOnWall(camCF.LookVector, wallNormal)
		local wallRight = ProjectOnWall(camCF.RightVector, wallNormal)

		if not wallForward or not wallRight then
			return Vector3.zero
		end

		local inputX = humanoidMoveDir.X
		local inputZ = humanoidMoveDir.Z
		local moveDir = wallForward * -inputZ + wallRight * inputX

		if moveDir.Magnitude > 0.1 then
			return moveDir.Unit
		end

		return Vector3.zero
	end

	-- Criar constraints para controlar o personagem na parede
	local function CreateWallConstraints(rootPart)
		-- Remover constraints antigos se existirem
		local oldLV = rootPart:FindFirstChild("GH_SpiderLV")
		local oldAO = rootPart:FindFirstChild("GH_SpiderAO")
		if oldLV then oldLV:Destroy() end
		if oldAO then oldAO:Destroy() end

		-- Attachment base
		local attachment = rootPart:FindFirstChildOfClass("Attachment")
		if not attachment then
			attachment = Instance.new("Attachment")
			attachment.Parent = rootPart
		end

		-- LinearVelocity - controla movimento
		local lv = Instance.new("LinearVelocity")
		lv.Name = "GH_SpiderLV"
		lv.MaxForce = math.huge
		lv.Attachment0 = attachment
		lv.VectorVelocity = Vector3.zero
		lv.VelocityConstraintMode = Enum.VelocityConstraintMode.Vector
		lv.Parent = rootPart

		-- AlignOrientation - mantem orientacao na parede
		local ao = Instance.new("AlignOrientation")
		ao.Name = "GH_SpiderAO"
		ao.MaxTorque = math.huge
		ao.Attachment0 = attachment
		ao.Mode = Enum.OrientationAlignmentMode.OneAttachment
		ao.Responsiveness = 30
		ao.RigidityEnabled = false
		ao.Parent = rootPart

		return lv, ao
	end

	-- Remover constraints
	local function RemoveWallConstraints(rootPart)
		if not rootPart then return end
		local lv = rootPart:FindFirstChild("GH_SpiderLV")
		local ao = rootPart:FindFirstChild("GH_SpiderAO")
		if lv then lv:Destroy() end
		if ao then ao:Destroy() end
	end

	function Cheats_ToggleSpider(state, btn)
		GH.Disconnect("Spider_Stepped")

		if not state then
			-- Restaurar ao desativar
			local char = LocalPlayer.Character
			if char then
				local hrp = char:FindFirstChild("HumanoidRootPart")
				local hum = char:FindFirstChildWhichIsA("Humanoid")

				-- Remover constraints
				RemoveWallConstraints(hrp)

				if hrp then
					hrp.AssemblyLinearVelocity = Vector3.zero
					hrp.AssemblyAngularVelocity = Vector3.zero
					-- Restaurar orientacao vertical
					hrp.CFrame = CFrame.new(hrp.Position) * CFrame.Angles(
						0,
						math.atan2(-hrp.CFrame.LookVector.X, -hrp.CFrame.LookVector.Z),
						0
					)
				end

				if hum then
					hum.AutoRotate = true
					hum.PlatformStand = false
					hum:SetStateEnabled(Enum.HumanoidStateType.Freefall, true)
					pcall(function() hum:ChangeState(Enum.HumanoidStateType.GettingUp) end)
				end
			end
			return
		end

		local char = LocalPlayer.Character
		if not char then return end
		local hrp = char:FindFirstChild("HumanoidRootPart")
		local hum = char:FindFirstChildWhichIsA("Humanoid")
		if not hrp or not hum then return end		-- Configurar humanoid para wall-walking
		hum.AutoRotate = false
	hum:SetStateEnabled(Enum.HumanoidStateType.Freefall, false)

		-- Criar constraints
		local lv, ao = CreateWallConstraints(hrp)

		-- Armazenar referencias para acesso na conexao
		local constraintsData = {
			lv = lv,
			ao = ao,
			onWall = false,
		}

		-- Loop principal
		GH.Connections.Spider_Stepped = RunService.Heartbeat:Connect(function()
			if GH.isClosing then return end
			if not GH.States.Spider then
				GH.Disconnect("Spider_Stepped")
				return
			end

			local character = LocalPlayer.Character
			if not character then return end

			local rootPart = character:FindFirstChild("HumanoidRootPart")
			local humanoid = character:FindFirstChildWhichIsA("Humanoid")

			if not rootPart or not humanoid then return end
			if not lv or not lv.Parent then return end
			if not ao or not ao.Parent then return end

			-- Detectar parede
			local wallInfo = GetWallInfo(character)

			if wallInfo and humanoid.MoveDirection.Magnitude > 0 then
				-- Na parede - ativar wall-walking
				if not constraintsData.onWall then
					constraintsData.onWall = true
					humanoid.PlatformStand = true
				end

				-- Zerar rotacao residual
				rootPart.AssemblyAngularVelocity = Vector3.zero

				local camera = workspace.CurrentCamera

				-- Calcular direcao na superficie
				local wallMoveDir = GetWallMoveDirection(
					wallInfo.normal,
					humanoid.MoveDirection,
					camera
				)

				-- Calcular CFrame alvo
				local targetCFrame = CalculateWallCFrame(rootPart, wallInfo, wallMoveDir)

				-- Aplicar orientacao via AlignOrientation
				ao.CFrame = targetCFrame.Rotation

				-- Calcular velocidade na superficie da parede
				local velocity = Vector3.zero
				if wallMoveDir.Magnitude > 0.1 then
					-- Movimento na superficie
					velocity = wallMoveDir * climbSpeed
				end

				-- Forca para manter grudado na parede (empurra contra a parede)
				local stickForce = wallInfo.normal * -12

				-- Correcao de posicao (spring para manter distancia da parede)
				local targetPos = wallInfo.position + wallInfo.normal * wallStickOffset
				local posError = rootPart.Position - targetPos
				local springForce = -posError * 15

				-- Aplicar velocidade total via LinearVelocity
				lv.VectorVelocity = velocity + stickForce + springForce

			else
				-- Fora da parede
				if constraintsData.onWall then
					constraintsData.onWall = false
					humanoid.PlatformStand = false
				end

				-- Parar movimento
				lv.VectorVelocity = Vector3.zero
				ao.CFrame = rootPart.CFrame.Rotation
			end
		end)

		GH.ShowToast(GH.T("toast_spider_active"), GH.Theme.On, 2)
	end

	-- Reconectar ao respawn
	GH.Connections.Spider_CharAdded = LocalPlayer.CharacterAdded:Connect(function()
		if GH.States.Spider then
			task.wait(0.5)
			GH.States.Spider = false
			Cheats_ToggleSpider(false, nil)
			task.wait(0.5)
			if GH.States.Spider == false then
				GH.States.Spider = true
				Cheats_ToggleSpider(true, nil)
			end
		end
	end)

	GH.RegisterToggleButton("Spider", "toggle_spider", Cheats_ToggleSpider, "Movement", "desc_spider")
end
