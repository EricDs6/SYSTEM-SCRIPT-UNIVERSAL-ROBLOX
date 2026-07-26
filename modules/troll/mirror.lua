-- =============================================================================
-- COMMAND: MIRROR - Espelha o movimento de um jogador suavemente
-- =============================================================================
return function(GH)
	local Players = GH.Services.Players
	local RunService = GH.Services.RunService
	local LocalPlayer = GH.LocalPlayer

	GH.Cache.MirrorTarget = nil
	GH.Cache.MirrorCenter = nil
	GH.Cache.MirrorDied = nil
	GH.Cache.MirrorBodyPos = nil

	function Cheats_ToggleMirror(state, btn)
		GH.UnregisterMasterLoop("Mirror")

		if not state then
			if GH.Objects.MirrorPicker then
				GH.Objects.MirrorPicker.Close()
				GH.Objects.MirrorPicker = nil
			end
			-- Limpar BodyPosition
			if GH.Cache.MirrorBodyPos and GH.Cache.MirrorBodyPos.Parent then
				GH.Cache.MirrorBodyPos:Destroy()
			end
			-- Restaurar estado
			pcall(function()
				local char = LocalPlayer.Character
				local hum = char and char:FindFirstChildOfClass("Humanoid")
				if hum then hum.AutoRotate = true end
				local hrp = char and char:FindFirstChild("HumanoidRootPart")
				if hrp then
					hrp.AssemblyLinearVelocity = Vector3.zero
					hrp.AssemblyAngularVelocity = Vector3.zero
				end
			end)
			if GH.Cache.MirrorDied then
				GH.Cache.MirrorDied:Disconnect()
				GH.Cache.MirrorDied = nil
			end
			GH.Cache.MirrorTarget = nil
			GH.Cache.MirrorCenter = nil
			GH.Cache.MirrorBodyPos = nil
			return
		end

		local picker = GH.ShowPlayerPicker(GH.T("dropdown_mirror_title"), function(name)
			local player = Players:FindFirstChild(name)
			if player and player.Character then
				local targetRoot = player.Character:FindFirstChild("HumanoidRootPart")
				local myChar = LocalPlayer.Character
				local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
				local myHum = myChar and myChar:FindFirstChildOfClass("Humanoid")
				if targetRoot and myRoot and myHum then
					-- Desliga auto-rotate para evitar que o humanoid lute contra o movimento
					myHum.AutoRotate = false

					-- Salva o centro do espelho
					GH.Cache.MirrorTarget = player
					GH.Cache.MirrorCenter = (myRoot.Position + targetRoot.Position) / 2

					-- Cria BodyPosition para movimento suave
					local bp = Instance.new("BodyPosition")
					bp.Name = "GH_MirrorBP"
					bp.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
					bp.P = 2000
					bp.D = 100
					bp.Position = myRoot.Position
					bp.Parent = myRoot
					GH.Cache.MirrorBodyPos = bp

					-- Torna as partes massless e sem colisao pra nao prender
					for _, child in pairs(myChar:GetDescendants()) do
						if child:IsA("BasePart") then
							child.Massless = true
							child.CanCollide = false
						end
					end

					-- Detecta morte para desligar automaticamente
					GH.Cache.MirrorDied = myHum.Died:Connect(function()
						if GH.States.Mirror then
							GH.States.Mirror = false
							local b = GH.Buttons["Mirror"]
							if b and GH.Callbacks["Mirror"] then
								pcall(GH.Callbacks["Mirror"], false, b)
							end
						end
					end)

					GH.ShowToast(string.format("Espelhando %s", name), GH.Theme.Accent, 2)
				end
			end
		end)
		GH.Objects.MirrorPicker = picker

		GH.RegisterMasterLoop("Mirror", "Render", function()
			if GH.isClosing or not GH.States.Mirror then
				GH.UnregisterMasterLoop("Mirror")
				return
			end

			local target = GH.Cache.MirrorTarget
			local center = GH.Cache.MirrorCenter
			local bp = GH.Cache.MirrorBodyPos
			if not target or not target.Character or not center or not bp or not bp.Parent then return end

			local targetRoot = target.Character:FindFirstChild("HumanoidRootPart")
			local myRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
			if not targetRoot or not myRoot then return end

			-- Calcula posicao espelhada: mirrored = 2 * center - targetPos
			local mirroredPos = 2 * center - targetRoot.Position

			-- Move suavemente via BodyPosition
			bp.Position = mirroredPos

			-- Espelha a rotacao no eixo Y (inverte a direcao que o alvo olha)
			local targetCF = targetRoot.CFrame
			local mirrorCF = CFrame.new(myRoot.Position) * CFrame.Angles(0, -targetCF:ToEulerAnglesYXZ(), 0)
			myRoot.CFrame = mirrorCF
		end)
	end

	GH.RegisterToggleButton("Mirror", "toggle_mirror", Cheats_ToggleMirror, "Troll", "desc_mirror")
end
