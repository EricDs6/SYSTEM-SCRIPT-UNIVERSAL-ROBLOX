-- =============================================================================
-- COMMAND: ESP
-- Mostra nomes, vida e distancia dos jogadores atraves de paredes
-- Baseado no script ESP standalone do usuario
-- =============================================================================
return function(GH)
	local Players = GH.Services.Players
	local RunService = GH.Services.RunService
	local LocalPlayer = GH.LocalPlayer

	local espFolder = nil
	local espLabels = {}

	local function removerESP()
		if espFolder then
			pcall(function() espFolder:Destroy() end)
			espFolder = nil
		end
		GH.Disconnect("ESP_Render")
		GH.Disconnect("ESP_Added")
		GH.Disconnect("ESP_Removing")
		espLabels = {}
	end

	local function criarMarcador(jogador)
		if jogador == LocalPlayer then return end
		if not espFolder then return end

		local char = jogador.Character
		if not char then return end

		local head = char:FindFirstChild("Head")
		if not head then return end

		-- BillboardGui
		local gui = Instance.new("BillboardGui")
		gui.Name = "GH_ESP_" .. jogador.Name
		gui.Adornee = head
		gui.Size = UDim2.new(0, 200, 0, 50)
		gui.StudsOffset = Vector3.new(0, 3, 0)
		gui.AlwaysOnTop = true
		gui.Parent = espFolder

		-- Texto
		local texto = Instance.new("TextLabel")
		texto.Size = UDim2.new(1, 0, 1, 0)
		texto.BackgroundTransparency = 1
		texto.Font = Enum.Font.GothamBold
		texto.TextSize = 13
		texto.TextStrokeTransparency = 0
		texto.TextStrokeColor3 = Color3.new(0, 0, 0)
		texto.TextColor3 = Color3.fromRGB(255, 50, 50)
		texto.Parent = gui

		-- Cor baseada no time
		if LocalPlayer.Team and jogador.Team then
			if LocalPlayer.Team == jogador.Team then
				texto.TextColor3 = Color3.fromRGB(50, 255, 50)
			else
				texto.TextColor3 = Color3.fromRGB(255, 50, 50)
			end
		else
			texto.TextColor3 = Color3.fromRGB(255, 50, 50)
		end

		espLabels[jogador] = texto
	end

	function Cheats_ToggleESP(state, btn)
		removerESP()

		if state then
			-- Criar pasta no TargetGui
			espFolder = Instance.new("Folder")
			espFolder.Name = "GH_ESP_Folder"
			local ok = pcall(function() espFolder.Parent = GH.TargetGui end)
			if not ok then
				espFolder.Parent = LocalPlayer:WaitForChild("PlayerGui")
			end

			-- Criar marcadores para quem ja esta no servidor
			for _, jogador in ipairs(Players:GetPlayers()) do
				criarMarcador(jogador)
			end

			-- Novos players
			GH.Connections.ESP_Added = Players.PlayerAdded:Connect(function(jogador)
				jogador.CharacterAdded:Connect(function()
					if GH.States.ESP then
						task.wait(1)
						criarMarcador(jogador)
					end
				end)
			end)

			-- Players que saem
			GH.Connections.ESP_Removing = Players.PlayerRemoving:Connect(function(jogador)
				espLabels[jogador] = nil
			end)

			-- Recriar marcadores no respawn
			for _, jogador in ipairs(Players:GetPlayers()) do
				if jogador ~= LocalPlayer then
					jogador.CharacterAdded:Connect(function()
						if GH.States.ESP then
							task.wait(1)
							criarMarcador(jogador)
						end
					end)
				end
			end

			-- Loop de atualizacao
			GH.Connections.ESP_Render = RunService.RenderStepped:Connect(function()
				if not GH.States.ESP then return end

				local meuChar = LocalPlayer.Character
				local minhaHrp = meuChar and meuChar:FindFirstChild("HumanoidRootPart")

				for jogador, texto in pairs(espLabels) do
					if jogador and jogador.Character and texto and texto.Parent then
						local alvoChar = jogador.Character
						local alvoHrp = alvoChar:FindFirstChild("HumanoidRootPart")
						local alvoHum = alvoChar:FindFirstChildOfClass("Humanoid")

						if alvoHrp and alvoHum and minhaHrp then
							local distancia = math.floor((minhaHrp.Position - alvoHrp.Position).Magnitude)
							local vida = math.floor(alvoHum.Health)
							local vidaMax = math.floor(alvoHum.MaxHealth)

							-- Formato do texto
							local parts = {}
							table.insert(parts, jogador.Name)

							if GH.Settings.ESPShowHealth and GH.Settings.ESPShowDistance then
								table.insert(parts, string.format("HP %d/%d | %dm", vida, vidaMax, distancia))
							elseif GH.Settings.ESPShowHealth then
								table.insert(parts, string.format("HP %d/%d", vida, vidaMax))
							elseif GH.Settings.ESPShowDistance then
								table.insert(parts, string.format("%dm", distancia))
							end

							texto.Text = table.concat(parts, "\n")

							-- Esconder se morto
							texto.Visible = vida > 0

							-- Atualizar cor baseada no time
							if LocalPlayer.Team and jogador.Team then
								if LocalPlayer.Team == jogador.Team then
									texto.TextColor3 = Color3.fromRGB(50, 255, 50)
								else
									texto.TextColor3 = Color3.fromRGB(255, 50, 50)
								end
							end
						else
							texto.Text = jogador.Name
						end
					end
				end
			end)
		end

		GH.ShowToast(state and ("ESP " .. GH.T("toast_activated")) or ("ESP " .. GH.T("toast_deactivated")), state and GH.Theme.On or GH.Theme.Off, 2)
	end

	GH.RegisterToggleButton("ESP", "toggle_esp", Cheats_ToggleESP, "Combat", "desc_esp")
end
