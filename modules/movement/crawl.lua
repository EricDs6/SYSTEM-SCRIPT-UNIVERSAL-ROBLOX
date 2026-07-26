-- =============================================================================
-- COMMAND: CRAWL (Rastejar)
-- Faz o personagem rastejar no chao
-- =============================================================================
return function(GH)
	local RunService = GH.Services.RunService
	local LocalPlayer = GH.LocalPlayer

	GH.Cache.OrigHipHeight = nil

	function Cheats_ToggleCrawl(state, btn)
		GH.UnregisterMasterLoop("Crawl")

		-- Restaurar ao desativar
		if not state then
			local char = LocalPlayer.Character
			if char then
				local hum = char:FindFirstChildOfClass("Humanoid")
				if hum and GH.Cache.OrigHipHeight then
					hum.HipHeight = GH.Cache.OrigHipHeight
					GH.Cache.OrigHipHeight = nil
				end
				-- Restaurar CFrame em pe
				local hrp = char:FindFirstChild("HumanoidRootPart")
				if hrp then
					hrp.CFrame = CFrame.new(hrp.Position) * CFrame.Angles(0, math.atan2(-hrp.CFrame.LookVector.X, -hrp.CFrame.LookVector.Z), 0)
				end
				pcall(function() hum:ChangeState(Enum.HumanoidStateType.GettingUp) end)
			end
			return
		end

		local char = LocalPlayer.Character
		if not char then return end
		local hrp = char:FindFirstChild("HumanoidRootPart")
		local hum = char:FindFirstChildOfClass("Humanoid")
		if not hrp or not hum then return end

		-- Salvar valor original
		GH.Cache.OrigHipHeight = hum.HipHeight
		local originalSpeed = hum.WalkSpeed

		GH.RegisterMasterLoop("Crawl", "PreSim", function()
			if GH.isClosing or not GH.States.Crawl then
				GH.UnregisterMasterLoop("Crawl")
				return
			end

			local c = LocalPlayer.Character
			local h = c and c:FindFirstChild("HumanoidRootPart")
			local hm = c and c:FindFirstChildOfClass("Humanoid")
			if not c or not h or not hm then return end

			-- Reduzir hip height para ficar baixo
			hm.HipHeight = -1.8

			-- Velocidade reduzida
			hm.WalkSpeed = originalSpeed * 0.5

			-- Forcar velocidade Y para 0 (nao cair nem subir)
			local vel = h.AssemblyLinearVelocity
			h.AssemblyLinearVelocity = Vector3.new(vel.X, 0, vel.Z)

			-- Pegar direcao do movimento
			local flatVel = Vector3.new(vel.X, 0, vel.Z)
			local lookDir
			if flatVel.Magnitude > 0.5 then
				lookDir = flatVel.Unit
			else
				lookDir = h.CFrame.LookVector
			end

			-- Rotacionar para ficar deitado (pe para tras, cabeca para frente)
			local yaw = math.atan2(-lookDir.X, -lookDir.Z)
			local targetCFrame = CFrame.new(h.Position)
				* CFrame.Angles(0, yaw, 0)
				* CFrame.Angles(math.rad(-75), 0, 0)

			-- Aplicar suavemente
			h.CFrame = h.CFrame:Lerp(targetCFrame, 0.25)
		end)
	end

	GH.RegisterToggleButton("Crawl", "toggle_crawl", Cheats_ToggleCrawl, "Movement", "desc_crawl")
end
