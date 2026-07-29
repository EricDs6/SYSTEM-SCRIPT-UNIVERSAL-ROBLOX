-- =============================================================================
-- COMMAND: MIRROR - Espelha o movimento e rotação de um jogador
-- =============================================================================
return function(GH)
	local Players = GH.Services.Players
	local LocalPlayer = GH.LocalPlayer

	GH.Cache.MirrorTarget = nil
	GH.Cache.MirrorCenter = nil
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
		GH.Cache.MirrorCenter = nil
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

					-- Salva alvo e o ponto central do espelho
					GH.Cache.MirrorTarget = player
					GH.Cache.MirrorCenter = (myRoot.Position + targetRoot.Position) / 2

					-- BodyPosition para movimento suave
					local bp = Instance.new("BodyPosition")
					bp.Name = "GH_MirrorBP"
					bp.MaxForce = Vector3.new(1e6, 1e6, 1e6)
					bp.P = 15000
					bp.D = 600
					bp.Position = myRoot.Position
					bp.Parent = myRoot
					GH.Cache.MirrorBodyPos = bp

					-- BodyGyro para rotação espelhada
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
						GH.ShowToast(string.format("Espelhando %s", name), GH.Theme.Accent or GH.Theme.On, 2)
					end
				end
			end
		end)
		GH.Objects.MirrorPicker = picker

		-- Loop principal de atualização
		GH.RegisterMasterLoop("Mirror", "Render", function()
			if GH.isClosing or not GH.States.Mirror then
				CleanupMirror()
				return
			end

			local target = GH.Cache.MirrorTarget
			local center = GH.Cache.MirrorCenter
			local bp = GH.Cache.MirrorBodyPos
			local bg = GH.Cache.MirrorBodyGyro

			if not target or not target.Character or not center or not bp or not bp.Parent then return end

			local targetRoot = target.Character:FindFirstChild("HumanoidRootPart")
			local myChar = LocalPlayer.Character
			local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")

			if not targetRoot or not myRoot then return end

			-- Desativa colisões continuamente no loop para animações não resetarem
			for _, child in pairs(myChar:GetDescendants()) do
				if child:IsA("BasePart") then
					child.CanCollide = false
					if child ~= myRoot then
						child.Massless = true
					end
				end
			end

			-- Calcula a posição espelhada: (2 * Centro) - Posição do Alvo
			local mirroredPos = Vector3.new(
				2 * center.X - targetRoot.Position.X,
				targetRoot.Position.Y,
				2 * center.Z - targetRoot.Position.Z
			)

			-- Calcula a rotação espelhada do corpo
			local targetLook = targetRoot.CFrame.LookVector
			local mirroredLook = Vector3.new(-targetLook.X, targetLook.Y, -targetLook.Z)

			bp.Position = mirroredPos
			bg.CFrame = CFrame.new(myRoot.Position, myRoot.Position + mirroredLook)
		end)
	end

	GH.RegisterToggleButton("Mirror", "toggle_mirror", Cheats_ToggleMirror, "Troll", "desc_mirror")
end