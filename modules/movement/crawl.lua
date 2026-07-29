-- =============================================================================
-- COMMAND: CRAWL (Rastejar) - CORRIGIDO
-- =============================================================================
return function(GH)
	local LocalPlayer = GH.LocalPlayer

	GH.Cache.OrigHipHeight = nil
	GH.Cache.OrigWalkSpeed = nil

	local function CleanupCrawl()
		GH.UnregisterMasterLoop("Crawl")

		local char = LocalPlayer.Character
		if char then
			local hum = char:FindFirstChildOfClass("Humanoid")
			local hrp = char:FindFirstChild("HumanoidRootPart")

			if hum then
				hum.AutoRotate = true
				if GH.Cache.OrigHipHeight then
					hum.HipHeight = GH.Cache.OrigHipHeight
					GH.Cache.OrigHipHeight = nil
				end
				if GH.Cache.OrigWalkSpeed then
					hum.WalkSpeed = GH.Cache.OrigWalkSpeed
					GH.Cache.OrigWalkSpeed = nil
				end
				pcall(function() hum:ChangeState(Enum.HumanoidStateType.GettingUp) end)
			end

			if hrp then
				-- Restaura o alinhamento em pé
				local look = hrp.CFrame.LookVector
				local flatLook = Vector3.new(look.X, 0, look.Z)
				if flatLook.Magnitude > 0.1 then
					hrp.CFrame = CFrame.new(hrp.Position, hrp.Position + flatLook)
				end
			end
		end
	end

	function Cheats_ToggleCrawl(state, btn)
		CleanupCrawl()

		if not state then return end

		local char = LocalPlayer.Character
		if not char then return end

		local hrp = char:FindFirstChild("HumanoidRootPart")
		local hum = char:FindFirstChildOfClass("Humanoid")
		if not hrp or not hum then return end

		-- Salva os valores originais
		GH.Cache.OrigHipHeight = hum.HipHeight
		GH.Cache.OrigWalkSpeed = hum.WalkSpeed

		-- Desativa rotação padrão do Humanoide
		hum.AutoRotate = false

		GH.RegisterMasterLoop("Crawl", "Render", function()
			if GH.isClosing or not GH.States.Crawl then
				CleanupCrawl()
				return
			end

			local c = LocalPlayer.Character
			local h = c and c:FindFirstChild("HumanoidRootPart")
			local hm = c and c:FindFirstChildOfClass("Humanoid")
			if not c or not h or not hm then return end

			-- Mantém o HipHeight em um valor baixo, mas seguro para não atravessar o chão
			hm.HipHeight = 0.2
			
			-- Ajusta a velocidade de rastejar
			if GH.Cache.OrigWalkSpeed then
				hm.WalkSpeed = GH.Cache.OrigWalkSpeed * 0.4
			end

			-- Direção de movimento baseada nos inputs ou na rotação atual
			local moveDir = hm.MoveDirection
			local lookVector = h.CFrame.LookVector

			if moveDir.Magnitude > 0.1 then
				lookVector = moveDir.Unit
			else
				lookVector = Vector3.new(lookVector.X, 0, lookVector.Z).Unit
			end

			-- Monta o CFrame deitado em relação ao chão (Inclinado -90° no eixo X)
			local targetCFrame = CFrame.new(h.Position, h.Position + lookVector) * CFrame.Angles(math.rad(-90), 0, 0)

			-- Suaviza a rotação para evitar o efeito "pula-pula"
			h.CFrame = h.CFrame:Lerp(targetCFrame, 0.3)
		end)
	end

	GH.RegisterToggleButton("Crawl", "toggle_crawl", Cheats_ToggleCrawl, "Movement", "desc_crawl")
end