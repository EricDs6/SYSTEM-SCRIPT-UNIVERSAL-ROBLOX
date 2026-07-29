-- =============================================================================
-- COMMAND: MIRROR - Clone que segue e copia os movimentos do alvo
-- =============================================================================
return function(GH)
	local Players = GH.Services.Players
	local LocalPlayer = GH.LocalPlayer

	GH.Cache.MirrorTarget = nil
	GH.Cache.MirrorDied = nil
	GH.Cache.MirrorBodyPos = nil
	GH.Cache.MirrorBodyGyro = nil

	local function CleanupMirror()
		GH.UnregisterMasterLoop("Mirror")

		if GH.Cache.MirrorBodyPos and GH.Cache.MirrorBodyPos.Parent then
			GH.Cache.MirrorBodyPos:Destroy()
		end
		if GH.Cache.MirrorBodyGyro and GH.Cache.MirrorBodyGyro.Parent then
			GH.Cache.MirrorBodyGyro:Destroy()
		end
		if GH.Cache.MirrorDied then
			GH.Cache.MirrorDied:Disconnect()
			GH.Cache.MirrorDied = nil
		end

		pcall(function()
			local char = LocalPlayer.Character
			local hum = char and char:FindFirstChildOfClass("Humanoid")
			if hum then hum.AutoRotate = true end

			local hrp = char and char:FindFirstChild("HumanoidRootPart")
			if hrp then
				hrp.AssemblyLinearVelocity = Vector3.zero
				hrp.AssemblyAngularVelocity = Vector3.zero
			end

			-- Restaura a colisão padrão do personagem
			if char then
				for _, child in pairs(char:GetDescendants()) do
					if child:IsA("BasePart") then
						child.CanCollide = true
						child.Massless = false
					end
				end
			end
		end)

		GH.Cache.MirrorTarget = nil
		GH.Cache.MirrorBodyPos = nil
		GH.Cache.MirrorBodyGyro = nil
	end

	function Cheats_ToggleMirror(state, btn)
		CleanupMirror()

		if not state then
			if GH.Objects.MirrorPicker then
				GH.Objects.MirrorPicker.Close()
				GH.Objects.MirrorPicker = nil
			end
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
					myHum.AutoRotate = false

					-- Salva o alvo
					GH.Cache.MirrorTarget = player

					-- Posiciona o clone atrás do alvo (usando CFrame relativo)
					local behindCF = targetRoot.CFrame * CFrame.new(0, 0, 3)
					myRoot.CFrame = CFrame.new(behindCF.Position, behindCF.Position + targetRoot.CFrame.LookVector)

					-- BodyPosition para movimento suave do clone
					local bp = Instance.new("BodyPosition")
					bp.Name = "GH_MirrorBP"
					bp.MaxForce = Vector3.new(1e6, 1e6, 1e6)
					bp.P = 15000
					bp.D = 600
					bp.Position = myRoot.Position
					bp.Parent = myRoot
					GH.Cache.MirrorBodyPos = bp

					-- BodyGyro para fazer o clone olhar na mesma direção
					local bg = Instance.new("BodyGyro")
					bg.Name = "GH_MirrorBG"
					bg.MaxTorque = Vector3.new(1e6, 1e6, 1e6)
					bg.P = 15000
					bg.D = 500
					bg.CFrame = myRoot.CFrame
					bg.Parent = myRoot
					GH.Cache.MirrorBodyGyro = bg

					-- Auto desativar ao morrer
					GH.Cache.MirrorDied = myHum.Died:Connect(function()
						if GH.States.Mirror then
							GH.States.Mirror = false
							local b = GH.Buttons and GH.Buttons["Mirror"]
							if b and GH.Callbacks and GH.Callbacks["Mirror"] then
								pcall(GH.Callbacks["Mirror"], false, b)
							else
								CleanupMirror()
							end
						end
					end)

					if GH.ShowToast then
						GH.ShowToast(string.format("Clonando %s", name), GH.Theme.Accent or GH.Theme.On, 2)
					end
				end
			end
		end)
		GH.Objects.MirrorPicker = picker

		-- Loop principal: copia os movimentos do alvo (mesma direção, mesmos passos)
		GH.RegisterMasterLoop("Mirror", "Render", function()
			if GH.isClosing or not GH.States.Mirror then
				CleanupMirror()
				return
			end

			local target = GH.Cache.MirrorTarget
			local bp = GH.Cache.MirrorBodyPos
			local bg = GH.Cache.MirrorBodyGyro

			if not target or not target.Character or not bp or not bp.Parent then return end

			local targetRoot = target.Character:FindFirstChild("HumanoidRootPart")
			local myChar = LocalPlayer.Character
			local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")

			if not targetRoot or not myRoot then return end

			-- Desativa colisões continuamente para não travar em objetos
			pcall(function()
				for _, child in pairs(myChar:GetDescendants()) do
					if child:IsA("BasePart") then
						child.CanCollide = false
						if child ~= myRoot then
							child.Massless = true
						end
					end
				end
			end)

			-- Mantém o clone sempre 3 studs atrás do alvo (acompanha a mesma trajetória)
			local behindCF = targetRoot.CFrame * CFrame.new(0, 0, 3)
			bp.Position = behindCF.Position
			bg.CFrame = CFrame.new(myRoot.Position, myRoot.Position + targetRoot.CFrame.LookVector)
		end)
	end

	GH.RegisterToggleButton("Mirror", "toggle_mirror", Cheats_ToggleMirror, "Troll", "desc_mirror")
end