-- =============================================================================
-- COMMAND: NOCLIP
-- Atravesar paredes e objetos solidos (logica do Op.txt legado)
-- =============================================================================
return function(GH)
	local RunService = GH.Services.RunService
	local LocalPlayer = GH.LocalPlayer

	GH.Cache.DisabledParts = GH.Cache.DisabledParts or {}

	function Cheats_ToggleNoClip(state, btn)
		GH.UnregisterMasterLoop("NoClip")

		-- Restaurar CanCollide de todas as partes desativadas
		if not state then
			for p, _ in pairs(GH.Cache.DisabledParts) do
				if p and p.Parent then
					pcall(function() p.CanCollide = true end)
				end
			end
			table.clear(GH.Cache.DisabledParts)
			return
		end

		-- Ativar noclip com logica de raio (igual Op.txt)
		local cachedRayParams = RaycastParams.new()
		cachedRayParams.FilterType = Enum.RaycastFilterType.Exclude
		local cachedOverlapParams = OverlapParams.new()
		cachedOverlapParams.FilterType = Enum.RaycastFilterType.Exclude

		GH.RegisterMasterLoop("NoClip", "PreSim", function()
			if GH.isClosing then return end
			if not GH.States.NoClip then GH.UnregisterMasterLoop("NoClip"); return end

			local char = LocalPlayer.Character
			local hrp = char and char:FindFirstChild("HumanoidRootPart")
			if not char or not hrp then return end

			cachedRayParams.FilterDescendantsInstances = { char }
			cachedOverlapParams.FilterDescendantsInstances = { char }

			-- Detectar chao
			local floorRay = workspace:Raycast(hrp.Position, Vector3.new(0, -6, 0), cachedRayParams)
			local currentFloor = floorRay and floorRay.Instance

			-- Raio de noclip (3.8 studs por padrao)
			local r = GH.Settings.NoClipRadius or 3.8
			local parts = workspace:GetPartBoundsInBox(hrp.CFrame, Vector3.new(r, r * 1.4, r), cachedOverlapParams)

			local currentParts = {}
			for _, p in ipairs(parts) do
				if p:IsA("BasePart")
					and p ~= currentFloor
					and p.Name ~= "Terrain"
				then
					local parent = p.Parent
					if parent and not parent:FindFirstChildOfClass("Humanoid") then
						currentParts[p] = true
						if p.CanCollide then
							p.CanCollide = false
							GH.Cache.DisabledParts[p] = true
						end
					end
				end
			end

			-- Restaurar CanCollide de partes que nao estao mais proximas
			for p, _ in pairs(GH.Cache.DisabledParts) do
				if not currentParts[p] then
					if p and p.Parent then
						pcall(function() p.CanCollide = true end)
					end
					GH.Cache.DisabledParts[p] = nil
				end
			end
		end)
	end

	GH.RegisterToggleButton("NoClip", "toggle_noclip", Cheats_ToggleNoClip, "Movement", "desc_noclip")
end
