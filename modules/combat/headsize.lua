-- =============================================================================
-- COMMAND: HEAD SIZE
-- =============================================================================
return function(GH)
	local Players = GH.Services.Players
	local LocalPlayer = GH.LocalPlayer

	function Cheats_ToggleHeadSize(state, btn)
		GH.UnregisterMasterLoop("HeadSize")
		GH.Disconnect("HeadSizePlayerAdded")
		GH.Disconnect("HeadSizePlayerRemoving")
		if GH.Objects.HeadSizeDropdown then
			GH.Objects.HeadSizeDropdown:Destroy()
			GH.Objects.HeadSizeDropdown = nil
		end

		-- Restaurar tamanhos originais das cabecas
		if GH.Cache.OrigHeadSizes then
			for player, origSize in pairs(GH.Cache.OrigHeadSizes) do
				pcall(function()
					if player.Character then
						local head = player.Character:FindFirstChild("Head")
						if head and head:IsA("BasePart") then
							head.Size = origSize
							head.CanCollide = true
						end
					end
				end)
			end
			table.clear(GH.Cache.OrigHeadSizes)
		end

		if not state then return end

		-- Players que terao head ampliada
		if not GH.Cache.HeadSizeTargets then
			GH.Cache.HeadSizeTargets = {}
		end

		local function refreshList()
			local names = {}
			for _, player in ipairs(Players:GetPlayers()) do
				if player ~= LocalPlayer then
					table.insert(names, player.Name)
				end
			end
			if GH.Objects.HeadSizeDropdown then
				GH.Objects.HeadSizeDropdown:SetValues(names)
			end
		end

		local initialNames = {}
		for _, player in ipairs(Players:GetPlayers()) do
			if player ~= LocalPlayer then
				table.insert(initialNames, player.Name)
			end
		end

		local dropdown = GH.Tabs["Combat"]:AddDropdown("HeadSizePlayer", {
			Title = GH.T("dropdown_headsize_title"),
			Values = initialNames,
			AllowNull = true,
		})
		GH.Objects.HeadSizeDropdown = dropdown

		dropdown:OnChanged(function(name)
			-- Limpar targets anteriores
			table.clear(GH.Cache.HeadSizeTargets)

			if name then
				local player = Players:FindFirstChild(name)
				if player and player ~= LocalPlayer then
					GH.Cache.HeadSizeTargets[player] = true
				end
			end
		end)

		refreshList()

		-- Master loop: manter head sizes todo frame
		GH.RegisterMasterLoop("HeadSize", "Render", function()
			if GH.isClosing or not GH.States.HeadSize then
				GH.UnregisterMasterLoop("HeadSize")
				return
			end

			for _, player in ipairs(Players:GetPlayers()) do
				if player == LocalPlayer then continue end
				if not player.Character then
					GH.Cache.OrigHeadSizes[player] = nil
					GH.Cache.HeadSizeTargets[player] = nil
					continue
				end

				local head = player.Character:FindFirstChild("Head")
				if not head or not head:IsA("BasePart") then
					GH.Cache.OrigHeadSizes[player] = nil
					GH.Cache.HeadSizeTargets[player] = nil
					continue
				end

				-- Se o player esta como target
				if GH.Cache.HeadSizeTargets[player] then
					-- Salvar tamanho original so uma vez
					if not GH.Cache.OrigHeadSizes[player] then
						GH.Cache.OrigHeadSizes[player] = head.Size
					end
					-- Aplicar tamanho gigante
					if head.Size ~= Vector3.new(5, 5, 5) then
						head.Size = Vector3.new(5, 5, 5)
						head.CanCollide = false
					end
				else
					-- Restaurar tamanho original se existir
					if GH.Cache.OrigHeadSizes[player] then
						pcall(function()
							head.Size = GH.Cache.OrigHeadSizes[player]
							head.CanCollide = true
						end)
						GH.Cache.OrigHeadSizes[player] = nil
					end
				end
			end
		end)

		-- PlayerAdded: atualizar lista
		GH.Connections.HeadSizePlayerAdded = Players.PlayerAdded:Connect(function()
			if GH.States.HeadSize then refreshList() end
		end)

		-- PlayerRemoving: limpar cache e atualizar lista
		GH.Connections.HeadSizePlayerRemoving = Players.PlayerRemoving:Connect(function(player)
			GH.Cache.OrigHeadSizes[player] = nil
			GH.Cache.HeadSizeTargets[player] = nil
			if GH.States.HeadSize then refreshList() end
		end)
	end

	GH.RegisterToggleButton("HeadSize", "toggle_headsize", Cheats_ToggleHeadSize, "Combat", "desc_headsize")
end
