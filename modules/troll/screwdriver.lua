-- =============================================================================
-- COMMAND: SCREWDRIVER / HELICOPTER - Helicóptero de Tronco
-- Gira o avatar nos eixos Z/X como as hélices de um helicóptero enquanto flutua
-- =============================================================================
return function(GH)
	local LocalPlayer = GH.LocalPlayer
	local RunService = GH.Services.RunService
	local TweenService = GH.Services.TweenService

	GH.Cache.ScrewdriverBP = nil
	GH.Cache.ScrewdriverBAV = nil
	GH.Cache.ScrewdriverOrigGravity = nil
	GH.Cache.ScrewdriverDied = nil

	local function CleanupScrewdriver()
		GH.UnregisterMasterLoop("Screwdriver")

		if GH.Cache.ScrewdriverBP and GH.Cache.ScrewdriverBP.Parent then
			GH.Cache.ScrewdriverBP:Destroy()
		end
		if GH.Cache.ScrewdriverBAV and GH.Cache.ScrewdriverBAV.Parent then
			GH.Cache.ScrewdriverBAV:Destroy()
		end
		if GH.Cache.ScrewdriverDied then
			GH.Cache.ScrewdriverDied:Disconnect()
			GH.Cache.ScrewdriverDied = nil
		end

		pcall(function()
			-- Restaura a gravidade original
			if GH.Cache.ScrewdriverOrigGravity then
				workspace.Gravity = GH.Cache.ScrewdriverOrigGravity
				GH.Cache.ScrewdriverOrigGravity = nil
			end

			local char = LocalPlayer.Character
			if char then
				-- Restaura colisão
				for _, child in pairs(char:GetDescendants()) do
					if child:IsA("BasePart") then
						child.CanCollide = true
						child.Massless = false
					end
				end

				local hum = char:FindFirstChildOfClass("Humanoid")
				if hum then
					hum.AutoRotate = true
					hum.PlatformStand = false
				end

				local hrp = char:FindFirstChild("HumanoidRootPart")
				if hrp then
					hrp.AssemblyLinearVelocity = Vector3.zero
					hrp.AssemblyAngularVelocity = Vector3.zero
				end
			end
		end)
	end

	function Cheats_ToggleScrewdriver(state)
		CleanupScrewdriver()

		if not state then return end

		local char = LocalPlayer.Character
		local hrp = char and char:FindFirstChild("HumanoidRootPart")
		local hum = char and char:FindFirstChildOfClass("Humanoid")

		if not hrp or not hum then return end

		-- Salva a gravidade original e zera ela
		GH.Cache.ScrewdriverOrigGravity = workspace.Gravity
		workspace.Gravity = 0

		hum.AutoRotate = false
		hum.PlatformStand = true

		-- Desativa colisão nas partes
		for _, child in pairs(char:GetDescendants()) do
			if child:IsA("BasePart") then
				child.CanCollide = false
				if child ~= hrp then
					child.Massless = true
				end
			end
		end

		-- BodyPosition para flutuar no lugar (trava posição Y e deixa X/Z livres)
		local bp = Instance.new("BodyPosition")
		bp.Name = "GH_ScrewdriverBP"
		bp.MaxForce = Vector3.new(0, 1e6, 0) -- Só força no eixo Y (flutua)
		bp.P = 5000
		bp.D = 300
		bp.Position = hrp.Position
		bp.Parent = hrp
		GH.Cache.ScrewdriverBP = bp

		-- BodyAngularVelocity para girar como hélice (eixo X = mortal / Z = parafuso)
		local bav = Instance.new("BodyAngularVelocity")
		bav.Name = "GH_ScrewdriverBAV"
		bav.MaxTorque = Vector3.new(1e6, 1e6, 1e6)
		bav.P = 5000
		-- Gira no eixo Z (parafuso) com leve inclinação no X
		bav.AngularVelocity = Vector3.new(5, 0, 15)
		bav.Parent = hrp
		GH.Cache.ScrewdriverBAV = bav

		-- Auto desativar ao morrer
		GH.Cache.ScrewdriverDied = hum.Died:Connect(function()
			if GH.States.Screwdriver then
				GH.States.Screwdriver = false
				local b = GH.Buttons and GH.Buttons["Screwdriver"]
				if b and GH.Callbacks and GH.Callbacks["Screwdriver"] then
					pcall(GH.Callbacks["Screwdriver"], false, b)
				else
					CleanupScrewdriver()
				end
			end
		end)

		if GH.ShowToast then
			GH.ShowToast("Helicóptero de Tronco ativado!", GH.Theme.Accent or GH.Theme.On, 3)
		end

		-- Loop: mantém a posição Y e garante rotação contínua
		GH.RegisterMasterLoop("Screwdriver", "Heartbeat", function()
			if GH.isClosing or not GH.States.Screwdriver then
				CleanupScrewdriver()
				return
			end

			local myChar = LocalPlayer.Character
			local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
			local myBP = GH.Cache.ScrewdriverBP
			local myBAV = GH.Cache.ScrewdriverBAV

			if not myRoot or not myBP or not myBP.Parent or not myBAV or not myBAV.Parent then return end

			-- Atualiza a posição Y para flutuar (mesmo Y)
			myBP.Position = Vector3.new(myRoot.Position.X, myBP.Position.Y, myRoot.Position.Z)

			-- Garante que a rotação continua aplicando força
			myBAV.AngularVelocity = Vector3.new(5, 0, 15)
		end)
	end

	GH.RegisterToggleButton("Screwdriver", "toggle_screwdriver", Cheats_ToggleScrewdriver, "Troll", "desc_screwdriver")
end
