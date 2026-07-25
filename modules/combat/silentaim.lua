-- =============================================================================
-- COMMAND: SILENT AIM
-- =============================================================================
return function(GH)
	local Players = GH.Services.Players
	local RunService = GH.Services.RunService
	local UserInputService = GH.Services.UserInputService
	local LocalPlayer = GH.LocalPlayer

	GH.SilentAimConfig = {
		Enabled = false, TargetPart = "Head", MaxDistance = 300,
		HitChance = 100, UseFOV = false, Radius = 150,
	}

	table.insert(GH.NamecallHandlers, function(self, method, args)
		if not GH.SilentAimConfig.Enabled then return false end
		if not (method == "Raycast" or method == "FindPartOnRay" or method == "FindPartOnRayWithWhitelist") then return false end

		local cam = workspace.CurrentCamera
		if not cam then return false end

		local target = nil
		local closestDist = GH.SilentAimConfig.UseFOV and GH.SilentAimConfig.Radius or math.huge
		local mousePos = UserInputService:GetMouseLocation()

		for _, player in ipairs(Players:GetPlayers()) do
			if player ~= LocalPlayer and player.Character then
				local hrp = player.Character:FindFirstChild("HumanoidRootPart")
				local hum = player.Character:FindFirstChildOfClass("Humanoid")
				if hrp and hum and hum.Health > 0 then
					if LocalPlayer.Team and player.Team and player.Team == LocalPlayer.Team then continue end
					local screenPos, onScreen = cam:WorldToViewportPoint(hrp.Position)
					if not onScreen then continue end
					local dist = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude
					if dist < closestDist then
						closestDist = dist
						target = player
					end
				end
			end
		end

		if target and target.Character then
			local targetPart = target.Character:FindFirstChild(GH.SilentAimConfig.TargetPart)
			if targetPart and math.random(0, 100) <= GH.SilentAimConfig.HitChance then
				if method == "Raycast" then
					local origin = args[1]
					if typeof(origin) == "Vector3" then
						args[2] = (targetPart.Position - origin).Unit * 1000
						return true
					end
				end
				if method == "FindPartOnRay" or method == "FindPartOnRayWithWhitelist" then
					local ray = args[1]
					if typeof(ray) == "Ray" then
						args[1] = Ray.new(ray.Origin, (targetPart.Position - ray.Origin).Unit * 1000)
						return true
					end
				end
			end
		end
		return false
	end)

	function Cheats_ToggleSilentAim(state, btn)
		GH.SilentAimConfig.Enabled = state
		GH.ShowToast(state and ("Silent Aim " .. GH.T("toast_activated")) or ("Silent Aim " .. GH.T("toast_deactivated")), state and GH.Theme.On or GH.Theme.Off, 2)
	end

	GH.RegisterToggleButton("SilentAim", "toggle_silentaim", Cheats_ToggleSilentAim, "Combat", "desc_silentaim")
end