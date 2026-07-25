-- =============================================================================
-- COMMAND: X-RAY
-- =============================================================================
return function(GH)
	function Cheats_ToggleXRay(state, btn)
		if state then
			GH.Cache.XRayParts = {}
			GH.Cache.XRayOriginals = GH.MakeWeakCache("k")

			local function isWorkspacePart(part)
				if not part:IsA("BasePart") then return false end
				local obj = part
				while obj and obj ~= workspace do
					if obj:IsA("Humanoid") then return false end
					obj = obj.Parent
				end
				return true
			end

			local function scanFolder(folder)
				for _, v in ipairs(folder:GetChildren()) do
					if isWorkspacePart(v) then
						GH.Cache.XRayOriginals[v] = v.LocalTransparencyModifier
						table.insert(GH.Cache.XRayParts, v)
					elseif v:IsA("Model") or v:IsA("Folder") then
						scanFolder(v)
					end
				end
			end
			scanFolder(workspace)

			for _, part in ipairs(GH.Cache.XRayParts) do
				if part and part.Parent then part.LocalTransparencyModifier = 0.65 end
			end

			GH.Connections.XRayLoop = workspace.DescendantAdded:Connect(function(desc)
				if not GH.States.XRay then return end
				if desc:IsA("BasePart") then
					GH.Cache.XRayOriginals[desc] = desc.LocalTransparencyModifier
					table.insert(GH.Cache.XRayParts, desc)
					desc.LocalTransparencyModifier = 0.65
				end
			end)
		else
			for _, part in ipairs(GH.Cache.XRayParts) do
				if part and part.Parent then
					part.LocalTransparencyModifier = (GH.Cache.XRayOriginals and GH.Cache.XRayOriginals[part]) or 0
				end
			end
			table.clear(GH.Cache.XRayParts)
			if GH.Cache.XRayOriginals then table.clear(GH.Cache.XRayOriginals) end
		end
	end

	GH.RegisterToggleButton("XRay", GH.T("toggle_xray"), Cheats_ToggleXRay, "Visual", GH.T("desc_xray"))
end