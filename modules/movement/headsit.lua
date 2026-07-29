return function(GH)
	local Players = GH.Services.Players
	local LocalPlayer = GH.LocalPlayer

	local targetNameInput = ""
	local selectedTarget = nil

	-- Função para buscar o jogador pelo nick ou display name
	local function FindPlayer(name)
		if not name or name == "" then return nil end
		name = name:lower()
		for _, p in ipairs(Players:GetPlayers()) do
			if p ~= LocalPlayer and (p.Name:lower():sub(1, #name) == name or p.DisplayName:lower():sub(1, #name) == name) then
				return p
			end
		end
		return nil
	end

	function Cheats_ToggleHeadSit(state, btn)
		GH.UnregisterMasterLoop("HeadSit")
		selectedTarget = nil

		if not state then
			-- Restaura o estado normal do Humanoide ao desativar
			local char = LocalPlayer.Character
			if char then
				local hum = char:FindFirstChildOfClass("Humanoid")
				if hum then
					hum.Sit = false
				end
			end
			return
		end

		-- Tenta encontrar o jogador digitado na caixa de texto
		selectedTarget = FindPlayer(targetNameInput)

		if not selectedTarget then
			if GH.ShowToast then
				GH.ShowToast("Jogador não encontrado!", GH.Theme.Off, 2)
			end
			-- Desliga o toggle se não encontrar o player
			if btn and btn.SetState then
				btn.SetState(false)
			end
			return
		end

		if GH.ShowToast then
			GH.ShowToast("HeadSit ativo em: " .. selectedTarget.DisplayName, GH.Theme.On, 2)
		end

		-- Loop principal atualizado a cada frame de renderização
		GH.RegisterMasterLoop("HeadSit", "Render", function()
			if not selectedTarget then return end

			local targetChar = selectedTarget.Character
			local myChar = LocalPlayer.Character

			if targetChar and myChar then
				local targetHead = targetChar:FindFirstChild("Head")
				local myRoot = myChar:FindFirstChild("HumanoidRootPart")
				local myHum = myChar:FindFirstChildOfClass("Humanoid")

				if targetHead and myRoot and myHum then
					-- Ativa animação de sentado e anula forças de queda
					myHum.Sit = true
					myRoot.AssemblyLinearVelocity = Vector3.zero
					myRoot.AssemblyAngularVelocity = Vector3.zero

					-- Posiciona exatamente acima da cabeça do alvo mantendo a orientação dele
					myRoot.CFrame = targetHead.CFrame * CFrame.new(0, 1.8, 0)
				end
			else
				-- Se o alvo sair do jogo ou morrer, encerra a função
				GH.UnregisterMasterLoop("HeadSit")
			end
		end)
	end

	-- Callback para atualizar o nome digitado na caixa de texto
	function Cheats_InputHeadSit(text)
		targetNameInput = text
		-- Se já estiver ativo e o usuário mudar o nome, atualiza o alvo em tempo real
		if GH.States and GH.States.HeadSit then
			selectedTarget = FindPlayer(targetNameInput)
		end
	end

	-- Registro dos elementos no painel
	GH.RegisterTextBox("HeadSitTarget", "placeholder_headsit", Cheats_InputHeadSit, "Movement", "desc_headsit_input")
	GH.RegisterToggleButton("HeadSit", "toggle_headsit", Cheats_ToggleHeadSit, "Movement", "desc_headsit")
end