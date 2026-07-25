-- =============================================================================
-- COMMAND: NOCLIP
-- =============================================================================
return function(GH)
	local RunService = GH.Services.RunService
	local LocalPlayer = GH.LocalPlayer

	local NoClipDisabledParts = {}

	function Cheats_ToggleNoClip(state, btn)
		GH.Disconnect("NoClip")
		GH.UnregisterMasterLoop("NoClip")

		for p, _ in pairs(NoClipDisabledParts) do
			if p and p.Parent then GH.SafeCall("NoClip:restore", function() p.CanCollide = true end) end
		end
		table.clear(NoClipDisabledParts)

		if state then
			local cachedRayParams = RaycastParams.new()
			cachedRayParams.FilterType = Enum.RaycastFilterType.Exclude
			local cachedOverlapParams = OverlapParams.new()
			cachedOverlapParams.FilterType = Enum.RaycastFilterType.Exclude

			GH.RegisterMasterLoop("NoClip", "PreSim", function()
				if GH.isClosing or not GH.States.NoClip then
					GH.UnregisterMasterLoop("NoClip")
					for p, _ in pairs(NoClipDisabledParts) do
						if p and p.Parent then pcall(function() p.CanCollide = true end) end
					end
					table.clear(NoClipDisabledParts)
					return
				end
				local char = LocalPlayer.Character
				local hrp = char and char:FindFirstChild("HumanoidRootPart")
				if not char or not hrp then return end

				cachedRayParams.FilterDescendantsInstances = { char }
				cachedOverlapParams.FilterDescendantsInstances = { char }

				local r = GH.Settings.NoClipRadius
				local parts = workspace:GetPartBoundsInBox(hrp.CFrame, Vector3.new(r, r * 1.4, r), cachedOverlapParams)
				local currentParts = {}

				for _, p in ipairs(parts) do
					if p:IsA("BasePart") and p.Name ~= "Terrain" and not p:HasTag("GH_NoClipIgnore") then
						local parent = p.Parent
						if parent and not parent:FindFirstChildOfClass("Humanoid") then
							currentParts[p] = true
							if p.CanCollide then
								p.CanCollide = false
								NoClipDisabledParts[p] = true
							end
						end
					end
				end

				for p, _ in pairs(NoClipDisabledParts) do
					if not currentParts[p] then
						if p and p.Parent then pcall(function() p.CanCollide = true end) end
						NoClipDisabledParts[p] = nil
					end
				end
			end)
		end
	end

	GH.RegisterToggleButton("NoClip", GH.T("toggle_noclip"), Cheats_ToggleNoClip, "Movement", GH.T("desc_noclip"))
end