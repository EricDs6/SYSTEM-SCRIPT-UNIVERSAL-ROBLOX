-- =============================================================================
-- COMMAND: CRAWL (Rastejar)
-- Faz o personagem rastejar no chao
-- =============================================================================
return function(GH)
	local RunService = GH.Services.RunService
	local UserInputService = GH.Services.UserInputService
	local LocalPlayer = GH.LocalPlayer

	GH.Cache.OrigHipHeight = nil

	function Cheats_ToggleCrawl(state, btn)
		GH.UnregisterMasterLoop("Crawl")
		GH.Disconnect("CrawlUpdate")

		local char = LocalPlayer.Character
		if not char then return end
		local hrp = char:FindFirstChild("HumanoidRootPart")
		local hum = char:FindFirstChildOfClass("Humanoid")
		if not hrp or not hum then return end

		-- Restaurar ao desativar
		if not state then
			if GH.Cache.OrigHipHeight then
				hum.HipHeight = GH.Cache.OrigHipHeight
				GH.Cache.OrigHipHeight = nil
			end
			hum.WalkSpeed = hum.WalkSpeed
			pcall(function() hum:ChangeState(Enum.HumanoidStateType.GettingUp) end)
			return
		end

		-- Salvar valor original
		GH.Cache.OrigHipHeight = hum.HipHeight

		local CRAWL_HEIGHT = -2.5
		local originalSpeed = hum.WalkSpeed

		-- Forcar estado de pronacao
		pcall(function() hum:ChangeState(Enum.HumanoidStateType.Running) end)

		GH.RegisterMasterLoop("Crawl", "PreSim", function()
			if GH.isClosing or not GH.States.Crawl then
				GH.UnregisterMasterLoop("Crawl")
				return
			end

			local c = LocalPlayer.Character
			local h = c and c:FindFirstChild("HumanoidRootPart")
			local hm = c and c:FindFirstChildOfClass("Humanoid")
			if not c or not h or not hm then return end

			-- Manter personagem baixo
			hm.HipHeight = CRAWL_HEIGHT

			-- Rotacionar para ficar deitado (eixo Z = frente)
			local vel = h.AssemblyLinearVelocity
			local flatVel = Vector3.new(vel.X, 0, vel.Z)
			local lookDir = flatVel.Magnitude > 0.5 and flatVel.Unit or h.CFrame.LookVector

			-- Calcular CFrame deitado (90 graus no eixo X)
			local targetPos = Vector3.new(h.Position.X, h.Position.Y + CRAWL_HEIGHT + 0.5, h.Position.Z)
			local targetCFrame = CFrame.lookAt(targetPos, targetPos + lookDir)
				* CFrame.Angles(math.rad(-80), 0, 0) -- Deitar para frente

			-- Aplicar rotação suave
			h.CFrame = h.CFrame:Lerp(targetCFrame, 0.3)

			-- Manter velocidade de caminhada reduzida
			hm.WalkSpeed = originalSpeed * 0.6
		end)

		-- Atualizar direcao ao mover
		GH.Connections.CrawlUpdate = RunService.Heartbeat:Connect(function()
			if not GH.States.Crawl then
				GH.Disconnect("CrawlUpdate")
				return
			end
			local c = LocalPlayer.Character
			local h = c and c:FindFirstChild("HumanoidRootPart")
			local hm = c and c:FindFirstChildOfClass("Humanoid")
			if not c or not h or not hm then return end

			local vel = h.AssemblyLinearVelocity
			local flatVel = Vector3.new(vel.X, 0, vel.Z)

			if flatVel.Magnitude > 0.5 then
				local lookDir = flatVel.Unit
				local targetCFrame = CFrame.lookAt(h.Position, h.Position + lookDir)
					* CFrame.Angles(math.rad(-80), 0, 0)
				h.CFrame = h.CFrame:Lerp(targetCFrame, 0.2)
			end
		end)
	end

	GH.RegisterToggleButton("Crawl", "toggle_crawl", Cheats_ToggleCrawl, "Movement", "desc_crawl")
end
