return function(GH)
	local Players = GH.Services.Players
	local LocalPlayer = GH.LocalPlayer

	local selectedTarget = nil

	function Cheats_ToggleHeadSit(state, btn)
		GH.UnregisterMasterLoop("HeadSit")
		selectedTarget = nil

		if not state then
			-- Fecha o picker se estiver aberto
			if GH.Objects.HeadSitPicker then
				GH.Objects.HeadSitPicker.Close()
				GH.Objects.HeadSitPicker = nil
			end
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

		-- Abre o seletor de jogadores (mesmo padrão dos outros módulos)
		local picker = GH.ShowPlayerPicker(GH.T("dropdown_headsit_title"), function(name)
			local player = Players:FindFirstChild(name)
			if not player then
				if GH.ShowToast then
					GH.ShowToast("Jogador não encontrado!", GH.Theme.Off, 2)
				end
				return
			end

			selectedTarget = player

			if GH.ShowToast then
				GH.ShowToast("HeadSit ativo em: " .. player.DisplayName, GH.Theme.On, 2)
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
		end)

		GH.Objects.HeadSitPicker = picker
	end

	-- Registro do botão toggle no painel (mesmo padrão dos outros módulos)
	GH.RegisterToggleButton("HeadSit", "toggle_headsit", Cheats_ToggleHeadSit, "Movement", "desc_headsit")
end