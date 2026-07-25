-- =============================================================================
-- COMMAND: ORBIT
-- =============================================================================
return function(GH)
	local Players = GH.Services.Players
	local RunService = GH.Services.RunService
	local LocalPlayer = GH.LocalPlayer

	GH.Cache.OrbitTarget = nil

	function Cheats_ToggleOrbit(state, btn)
		GH.UnregisterMasterLoop("Orbit")

		if not state then
			if GH.Objects.OrbitPicker then
				GH.Objects.OrbitPicker.Close()
				GH.Objects.OrbitPicker = nil
			end
			GH.Cache.OrbitTarget = nil
			return
		end

		local picker = GH.ShowPlayerPicker(GH.T("dropdown_orbit_title"), function(name)
			local player = Players:FindFirstChild(name)
			if player then
				GH.Cache.OrbitTarget = player
				GH.ShowToast(string.format("Orbitando %s", name), GH.Theme.On, 2)
			end
		end)
		GH.Objects.OrbitPicker = picker

		local angle = 0
		GH.RegisterMasterLoop("Orbit", "Render", function()
			local target = GH.Cache.OrbitTarget
			if not target or not target.Character then return end
			local targetRoot = target.Character:FindFirstChild("HumanoidRootPart")
			local myRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
			if not targetRoot or not myRoot then return end

			angle += 0.03
			local radius = 6
			local offset = Vector3.new(math.cos(angle) * radius, 2, math.sin(angle) * radius)
			myRoot.CFrame = CFrame.new(targetRoot.Position + offset, targetRoot.Position)
		end)
	end

	GH.RegisterToggleButton("Orbit", "toggle_orbit", Cheats_ToggleOrbit, "Movement", "desc_orbit")
end
