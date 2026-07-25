-- =============================================================================
-- COMMAND: COORDS
-- =============================================================================
return function(GH)
	local Players = GH.Services.Players
	local RunService = GH.Services.RunService
	local UserInputService = GH.Services.UserInputService
	local TweenService = GH.Services.TweenService
	local LocalPlayer = GH.LocalPlayer

	local CacheCoords = { SavedPoints = {}, CoordsParagraph = nil, SavedDropdown = nil }

	function Cheats_ToggleCoords(state, btn)
		GH.UnregisterMasterLoop("Coords")
		if GH.Objects.CoordsParagraph then
			GH.Objects.CoordsParagraph:Destroy()
			GH.Objects.CoordsParagraph = nil
		end
		if GH.Objects.CoordsSaveBtn then
			GH.Objects.CoordsSaveBtn:Destroy()
			GH.Objects.CoordsSaveBtn = nil
		end
		if GH.Objects.CoordsSavedDropdown then
			GH.Objects.CoordsSavedDropdown:Destroy()
			GH.Objects.CoordsSavedDropdown = nil
		end
		if GH.Objects.CoordsTPBtn then
			GH.Objects.CoordsTPBtn:Destroy()
			GH.Objects.CoordsTPBtn = nil
		end
		if not state then return end

		local section = GH.Tabs["Utility"]:AddSection(GH.T("section_coords"))

		local paragraph = section:AddParagraph({
			Title = GH.T("coords_current"),
			Content = "X: 0  Y: 0  Z: 0",
		})
		GH.Objects.CoordsParagraph = paragraph

		local saveBtn = section:AddButton({
			Title = GH.T("coords_save"),
			Callback = function()
				local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
				if hrp then
					local pos = hrp.Position
					table.insert(CacheCoords.SavedPoints, { Name = GH.T("coords_point_prefix") .. (#CacheCoords.SavedPoints + 1), Position = pos })
					if GH.Objects.CoordsSavedDropdown then
						local names = {}
						for _, p in ipairs(CacheCoords.SavedPoints) do
							table.insert(names, p.Name)
						end
						GH.Objects.CoordsSavedDropdown:SetValues(names)
					end
					GH.ShowToast(GH.T("toast_position_saved"), GH.Theme.On, 2)
				end
			end,
		})
		GH.Objects.CoordsSaveBtn = saveBtn

		local savedNames = {}
		for _, p in ipairs(CacheCoords.SavedPoints) do
			table.insert(savedNames, p.Name)
		end

		local dropdown = section:AddDropdown("CoordsSaved_Select", {
			Title = GH.T("coords_saved"),
			Values = savedNames,
			AllowNull = true,
		})
		GH.Objects.CoordsSavedDropdown = dropdown

		local tpBtn = section:AddButton({
			Title = GH.T("coords_tp"),
			Callback = function()
				local selectedName = dropdown.Value
				if selectedName then
					for _, p in ipairs(CacheCoords.SavedPoints) do
						if p.Name == selectedName then
							local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
							if hrp then
								hrp.CFrame = CFrame.new(p.Position + Vector3.new(0, 3, 0))
								GH.ShowToast(string.format(GH.T("toast_tp_to"), p.Name), GH.Theme.On, 2)
							end
							break
						end
					end
				end
			end,
		})
		GH.Objects.CoordsTPBtn = tpBtn

		-- Loop para atualizar coordenadas
		GH.RegisterMasterLoop("Coords", "Render", function()
			if GH.isClosing or not GH.States.Coords then
				GH.UnregisterMasterLoop("Coords")
				return
			end
			local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
			if hrp and GH.Objects.CoordsParagraph then
				local p = hrp.Position
				pcall(function()
					GH.Objects.CoordsParagraph:SetDesc("X: " .. math.floor(p.X) .. "  Y: " .. math.floor(p.Y) .. "  Z: " .. math.floor(p.Z))
				end)
			end
		end)
	end

	GH.RegisterToggleButton("Coords", "toggle_coords", Cheats_ToggleCoords, "Utility", "desc_coords")
end
