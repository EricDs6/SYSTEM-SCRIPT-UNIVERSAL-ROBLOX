-- =============================================================================
-- COMMAND: HEAD SIZE
-- =============================================================================
return function(GH)
	local Players = GH.Services.Players
	local RunService = GH.Services.RunService
	local LocalPlayer = GH.LocalPlayer

	GH.Cache.HeadSizeTargets = GH.Cache.HeadSizeTargets or {}
	GH.Cache.OrigHeadSizes = GH.Cache.OrigHeadSizes or {}

	function Cheats_ToggleHeadSize(state, btn)
		GH.UnregisterMasterLoop("HeadSize")

		if not state then
			if GH.Objects.HeadSizePicker then
				GH.Objects.HeadSizePicker.Close()
				GH.Objects.HeadSizePicker = nil
			end
			-- Restore original head sizes
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
			table.clear(GH.Cache.HeadSizeTargets)
			return
		end

		local picker = GH.ShowPlayerPicker(GH.T("dropdown_headsize_title"), function(name)
			local player = Players:FindFirstChild(name)
			if player and player.Character then
				local head = player.Character:FindFirstChild("Head")
				if head and head:IsA("BasePart") then
					if not GH.Cache.OrigHeadSizes[player] then
						GH.Cache.OrigHeadSizes[player] = head.Size
					end
					GH.Cache.HeadSizeTargets[player] = true
					head.Size = Vector3.new(5, 5, 5)
					GH.ShowToast(string.format(GH.T("toast_head_amplified"), name), GH.Theme.On, 2)
				end
			end
		end)
		GH.Objects.HeadSizePicker = picker

		GH.RegisterMasterLoop("HeadSize", "Heartbeat", function()
			for player, _ in pairs(GH.Cache.HeadSizeTargets) do
				pcall(function()
					if player.Character then
						local head = player.Character:FindFirstChild("Head")
						if head and head:IsA("BasePart") then
							head.Size = Vector3.new(5, 5, 5)
						end
					end
				end)
			end
		end)
	end

	GH.RegisterToggleButton("HeadSize", "toggle_headsize", Cheats_ToggleHeadSize, "Combat", "desc_headsize")
end
