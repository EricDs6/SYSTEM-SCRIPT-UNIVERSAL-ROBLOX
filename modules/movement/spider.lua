-- =============================================================================
-- COMMAND: SPIDER / WALL CLIMB
-- Simula o player grudando os pes na parede e andando sobre ela
-- =============================================================================
return function(GH)
	local RunService = GH.Services.RunService
	local LocalPlayer = GH.LocalPlayer

	local climbSpeed = 20
	local wallStickOffset = 0.8 -- distancia do personagem para a parede
	local rayDistance = 3.0
	local rotationSmoothness = 0.3 -- suavidade da rotacao (0-1)

	-- Funcao para detectar a parede e obter informacoes da superficie
	local function GetWallInfo(character)
		local rootPart = character:FindFirstChild("HumanoidRootPart")
		if not rootPart then return nil end

		local raycastParams = RaycastParams.new()
		raycastParams.FilterDescendantsInstances = { character }
		raycastParams.FilterType = Enum.RaycastFilterType.Exclude

		-- Dispara raios em multiplas direcoes, priorizando a frente
		local directions = {
			rootPart.CFrame.LookVector,        -- frente (prioridade)
			rootPart.CFrame.RightVector,       -- direita
			-rootPart.CFrame.RightVector,      -- esquerda
			-rootPart.CFrame.LookVector,       -- tras
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
				-- Verifica se a normal indica uma parede (vertical ou quase)
				local normalUpDot = math.abs(rayResult.Normal:Dot(Vector3.yAxis))
				if normalUpDot < 0.7 then -- nao e chao nem teto
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

	-- Funcao para projetar um vetor na superficie da parede
	local function ProjectOnWall(vector, wallNormal)
		local projected = vector - wallNormal * vector:Dot(wallNormal)
		if projected.Magnitude < 0.001 then
			return nil
		end
		return projected.Unit
	end

	-- Funcao para calcular a CFrame do personagem na parede
	local function CalculateWallCFrame(rootPart, wallInfo, moveDirection)
		local wallNormal = wallInfo.normal
		local wallPos = wallInfo.position

		-- Vetor "up" do personagem aponta para fora da parede
		local characterUp = wallNormal

		-- Calcula a direcao que o personagem deve olhar na parede
		local lookAlongWall
		if moveDirection.Magnitude > 0.1 then
			lookAlongWall = ProjectOnWall(moveDirection, wallNormal)
		end

		-- Fallback: tenta projetar o LookVector do rootPart na parede
		if not lookAlongWall then
			lookAlongWall = ProjectOnWall(rootPart.CFrame.LookVector, wallNormal)
		end

		-- Fallback final: usa eixo Y global
		if not lookAlongWall then
			lookAlongWall = ProjectOnWall(Vector3.yAxis, wallNormal)
		end

		-- Fallback extremo: usa RightVector do rootPart
		if not lookAlongWall then
			lookAlongWall = ProjectOnWall(rootPart.CFrame.RightVector, wallNormal)
		end

		-- Se ainda nil (parede e chao/teto), retorna CFrame atual
		if not lookAlongWall then
			return rootPart.CFrame
		end

		-- Calcula o "right" do personagem
		local characterRight = lookAlongWall:Cross(characterUp)
		if characterRight.Magnitude < 0.001 then
			return rootPart.CFrame
		end
		characterRight = characterRight.Unit

		-- Recalcula look para garantir ortogonalidade
		lookAlongWall = characterUp:Cross(characterRight).Unit

		-- Monta a CFrame: posicao ligeiramente afastada da parede
		local targetPos = wallPos + wallNormal * wallStickOffset

		-- CFrame com orientacao correta
		local targetCFrame = CFrame.fromMatrix(
			targetPos,
			characterRight,
			characterUp,
			-lookAlongWall
		)

		return targetCFrame
	end

	-- Funcao para calcular a direcao de movimento na superficie da parede
	local function GetWallMoveDirection(rootPart, wallNormal, humanoidMoveDir, camera)
		if humanoidMoveDir.Magnitude < 0.1 then
			return Vector3.zero
		end

		-- Pega a direcao relativa a camera
		local camCF = camera.CFrame
		local camForward = camCF.LookVector
		local camRight = camCF.RightVector

		-- Projeta as direcoes da camera na superficie da parede
		local wallForward = ProjectOnWall(camForward, wallNormal)
		local wallRight = ProjectOnWall(camRight, wallNormal)

		-- Se projecao falhar, retorna zero
		if not wallForward or not wallRight then
			return Vector3.zero
		end

		-- Combina baseado no input do jogador
		local inputX = humanoidMoveDir.X
		local inputZ = humanoidMoveDir.Z

		local moveDir = (wallForward * -inputZ + wallRight * inputX)

		if moveDir.Magnitude > 0.1 then
			return moveDir.Unit
		end

		return Vector3.zero
	end

	function Cheats_ToggleSpider(state, btn)
		GH.Disconnect("Spider_Stepped")

		if not state then
			-- Restaurar ao desativar
			local char = LocalPlayer.Character
			if char then
				local hrp = char:FindFirstChild("HumanoidRootPart")
				local hum = char:FindFirstChildWhichIsA("Humanoid")
				if hrp then
					-- Zera velocidade para nao voar ao desativar
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
					hum.PlatformStand = false
					pcall(function() hum:ChangeState(Enum.HumanoidStateType.GettingUp) end)
				end
			end
			return
		end

		-- Ativa a verificacao a cada frame
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

			-- Detecta parede proxima
			local wallInfo = GetWallInfo(character)

			if wallInfo and humanoid.MoveDirection.Magnitude > 0 then
				-- Jogador esta contra uma parede e se movendo
				local camera = workspace.CurrentCamera

				-- Ativa PlatformStand para evitar luta com fisica do humanoid
				if not humanoid.PlatformStand then
					humanoid.PlatformStand = true
				end

				-- Calcula direcao de movimento na superficie da parede
				local wallMoveDir = GetWallMoveDirection(
					rootPart,
					wallInfo.normal,
					humanoid.MoveDirection,
					camera
				)

				-- Calcula CFrame alvo na parede
				local targetCFrame = CalculateWallCFrame(rootPart, wallInfo, wallMoveDir)

				-- Aplica rotacao suave
				rootPart.CFrame = rootPart.CFrame:Lerp(targetCFrame, rotationSmoothness)

				-- Aplica velocidade de movimento na superficie da parede
				if wallMoveDir.Magnitude > 0.1 then
					-- Calcula velocidade baseada na direcao de movimento
					local velocity = wallMoveDir * climbSpeed

					-- Mantem o personagem grudado na parede
					velocity = velocity + wallInfo.normal * -2

					rootPart.AssemblyLinearVelocity = velocity
				else
					-- Apenas mantem grudado na parede quando parado
					rootPart.AssemblyLinearVelocity = wallInfo.normal * -5
				end
			else
				-- Nao esta contra parede
				if humanoid.PlatformStand then
					humanoid.PlatformStand = false
				end

				-- Verifica se ainda esta na parede (pode estar subindo)
				if rootPart.CFrame.UpVector:Dot(Vector3.new(0, 1, 0)) < 0.5 then
					-- Esta na parede, mantem gravidade suave
					local vel = rootPart.AssemblyLinearVelocity
					rootPart.AssemblyLinearVelocity = Vector3.new(
						vel.X,
						math.max(vel.Y, -10),
						vel.Z
					)
				end
			end
		end)

		GH.ShowToast(GH.T("toast_spider_active"), GH.Theme.On, 2)
	end

	-- Reconectar ao respawn
	GH.Connections.Spider_CharAdded = LocalPlayer.CharacterAdded:Connect(function()
		if GH.States.Spider then
			task.wait(0.5)
			-- Resetar PlatformStand antes de reativar
			local char = LocalPlayer.Character
			if char then
				local hum = char:FindFirstChildWhichIsA("Humanoid")
				if hum then hum.PlatformStand = false end
			end
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
