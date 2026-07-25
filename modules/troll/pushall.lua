-- =============================================================================
-- COMMAND: PUSH ALL
-- Cria projetil fisico que empurra jogadores (replica pro servidor)
-- =============================================================================
return function(GH)
	local Players = GH.Services.Players
	local RunService = GH.Services.RunService
	local LocalPlayer = GH.LocalPlayer

	local pushCooldown = false

	function Cheats_TogglePushAll(state, btn)
		GH.Disconnect("PushAll_Key")

		if not state then return end

		-- Ativar com tecla X
		GH.Connections.PushAll_Key = GH.Services.UserInputService.InputBegan:Connect(function(input, gpe)
			if gpe then return end
			if not GH.States.PushAll then return end
			if input.KeyCode ~= Enum.KeyCode.X then return end
			if pushCooldown then return end
			pushCooldown = true

			local myChar = LocalPlayer.Character
			local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
			if not myRoot then pushCooldown = false; return end

			-- Criar projetil fisico
			local ball = Instance.new("Part")
			ball.Name = "GH_PushBall"
			ball.Size = Vector3.new(4, 4, 4)
			ball.Shape = Enum.PartType.Ball
			ball.Material = Enum.Material.Neon
			ball.BrickColor = BrickColor.new("Really red")
			ball.Position = myRoot.Position + myRoot.CFrame.LookVector * 5
			ball.Anchored = false
			ball.CanCollide = true
			ball.Parent = workspace

			-- Velocity na direcao que olha
			local lv = Instance.new("LinearVelocity")
			lv.MaxForce = math.huge
			lv.Attachment0 = ball:FindFirstChildOfClass("Attachment") or Instance.new("Attachment", ball)
			lv.VectorVelocity = myRoot.CFrame.LookVector * 150 + Vector3.new(0, 30, 0)
			lv.VelocityConstraintMode = Enum.VelocityConstraintMode.Vector
			lv.Parent = ball

			-- Spin
			local av = Instance.new("AngularVelocity")
			av.MaxTorque = math.huge
			av.Attachment0 = lv.Attachment0
			av.AngularVelocity = Vector3.new(50, 50, 50)
			av.Parent = ball

			-- Destruir apos 3 segundos
			task.delay(3, function()
				if ball and ball.Parent then ball:Destroy() end
			end)

			-- Empurrar jogadores que o projetil atingir
			local hitConn
			hitConn = ball.Touched:Connect(function(hit)
				if not hit or not hit.Parent then return end
				local hitChar = hit.Parent
				local hitHum = hitChar:FindFirstChildOfClass("Humanoid")
				local hitRoot = hitChar:FindFirstChild("HumanoidRootPart")
				if hitHum and hitRoot and hitChar ~= myChar then
					local pushDir = (hitRoot.Position - ball.Position).Unit
					hitRoot.AssemblyLinearVelocity = pushDir * 100 + Vector3.new(0, 50, 0)
				end
			end)

			-- Cooldown
			task.delay(1, function()
				pushCooldown = false
				if hitConn then hitConn:Disconnect() end
			end)

			GH.ShowToast("Push! projetil disparado", GH.Theme.Red, 1)
		end)

		GH.ShowToast("Push All: pressione X para disparar", GH.Theme.On, 2)
	end

	GH.RegisterToggleButton("PushAll", "toggle_pushall", Cheats_TogglePushAll, "Troll", "desc_pushall")
end
