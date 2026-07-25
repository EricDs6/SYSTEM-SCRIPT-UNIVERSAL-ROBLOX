-- =============================================================================
-- COMMAND: TELEPORT PLAYER
-- =============================================================================
return function(GH)
	local Players = GH.Services.Players
	local UserInputService = GH.Services.UserInputService
	local LocalPlayer = GH.LocalPlayer

	function Cheats_ToggleTeleportPlayer(state, btn)
		GH.Disconnect("TeleportPlayerAdded")
		GH.Disconnect("TeleportPlayerRemoving")
		if GH.Objects.TeleportPlayerDropdown then
			GH.Objects.TeleportPlayerDropdown:Destroy()
			GH.Objects.TeleportPlayerDropdown = nil
		end
		if not state then return end

		local function refreshList()
			local names = {}
			for _, player in ipairs(Players:GetPlayers()) do
				if player ~= LocalPlayer then
					table.insert(names, player.Name)
				end
			end
			if GH.Objects.TeleportPlayerDropdown then
				GH.Objects.TeleportPlayerDropdown:SetValues(names)
			end
		end

		local initialNames = {}
		for _, player in ipairs(Players:GetPlayers()) do
			if player ~= LocalPlayer then
				table.insert(initialNames, player.Name)
			end
		end

		local dropdown = GH.Tabs["Movement"]:AddDropdown("TPPlayer_Select", {
			Title = GH.T("dropdown_tpplayer_title"),
			Values = initialNames,
			AllowNull = true,
		})
		GH.Objects.TeleportPlayerDropdown = dropdown

		dropdown:OnChanged(function(name)
			if name then
				local player = Players:FindFirstChild(name)
				local targetHrp = player and player.Character and player.Character:FindFirstChild("HumanoidRootPart")
				local myHrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
				if targetHrp and myHrp then
					GH.TweenTeleport(myHrp, targetHrp.CFrame + Vector3.new(0, 3, 2))
					GH.ShowToast(string.format(GH.T("toast_tp_to"), name), GH.Theme.On, 2)
				end
			end
		end)

		GH.Connections.TeleportPlayerAdded = Players.PlayerAdded:Connect(function()
			if GH.States.TeleportPlayer then refreshList() end
		end)
		GH.Connections.TeleportPlayerRemoving = Players.PlayerRemoving:Connect(function()
			if GH.States.TeleportPlayer then refreshList() end
		end)
	end

	GH.RegisterToggleButton("TeleportPlayer", GH.T("toggle_teleportplayer"), Cheats_ToggleTeleportPlayer, "Movement", GH.T("desc_teleportplayer"))
end