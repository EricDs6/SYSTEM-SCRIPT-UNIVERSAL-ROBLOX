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
			if name then
				local player = Players:FindFirstChild(name)
				local head = player and player.Character and player.Character:FindFirstChild("Head")
				if head and head:IsA("BasePart") then
					if not GH.Cache.OrigHeadSizes then GH.Cache.OrigHeadSizes = {} end
					if not GH.Cache.OrigHeadSizes[player] then
						GH.Cache.OrigHeadSizes[player] = head.Size
					end
					head.Size = Vector3.new(5, 5, 5)
					head.CanCollide = false
					GH.ShowToast(string.format(GH.T("toast_head_amplified"), name), GH.Theme.Red, 2)
				end
			end
		end)

		refreshList()
		GH.Connections.HeadSizePlayerAdded = Players.PlayerAdded:Connect(function()
			if GH.States.HeadSize then refreshList() end
		end)
		GH.Connections.HeadSizePlayerRemoving = Players.PlayerRemoving:Connect(function()
			if GH.States.HeadSize then refreshList() end
		end)
	end

	GH.RegisterToggleButton("HeadSize", "toggle_headsize", Cheats_ToggleHeadSize, "Combat", "desc_headsize")
end