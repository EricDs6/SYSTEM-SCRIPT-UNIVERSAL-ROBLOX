-- =============================================================================
-- MODULE: VISUAL
-- =============================================================================
--!nonstrict
return function(GH)
	local Players = GH.Services.Players
	local RunService = GH.Services.RunService
	local UserInputService = GH.Services.UserInputService
	local TweenService = GH.Services.TweenService
	local Lighting = GH.Services.Lighting
	local LocalPlayer = GH.LocalPlayer

	-- ==========================================
	-- X-RAY
	-- ==========================================
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

	-- ==========================================
	-- NIGHT MODE
	-- ==========================================
	function Cheats_ToggleNightMode(state, btn)
		if state then
			GH.Cache.OrigBrightness = Lighting.Brightness
			GH.Cache.OrigClockTime = Lighting.ClockTime
			GH.Cache.OrigAmbient = Lighting.Ambient
			GH.Cache.OrigOutdoorAmbient = Lighting.OutdoorAmbient
			Lighting.Brightness = 0
			Lighting.ClockTime = 0
			Lighting.Ambient = Color3.fromRGB(25, 25, 35)
			Lighting.OutdoorAmbient = Color3.fromRGB(15, 15, 25)
			if not Lighting:FindFirstChild("GH_NightBloom") then
				local bloom = Instance.new("BloomEffect")
				bloom.Name = "GH_NightBloom"
				bloom.Intensity = 0.3
				bloom.Size = 24
				bloom.Threshold = 0.8
				bloom.Parent = Lighting
			end
		else
			Lighting.Brightness = GH.Cache.OrigBrightness or 1
			Lighting.ClockTime = GH.Cache.OrigClockTime or 14
			Lighting.Ambient = GH.Cache.OrigAmbient or Color3.fromRGB(128, 128, 128)
			Lighting.OutdoorAmbient = GH.Cache.OrigOutdoorAmbient or Color3.fromRGB(128, 128, 128)
			local bloom = Lighting:FindFirstChild("GH_NightBloom")
			if bloom then bloom:Destroy() end
		end
	end

	-- ==========================================
	-- FULLBRIGHT
	-- ==========================================
	function Cheats_ToggleFullbright(state, btn)
		if state then
			GH.Cache.OrigBrightness = Lighting.Brightness
			GH.Cache.OrigClockTime = Lighting.ClockTime
			GH.Cache.OrigAmbient = Lighting.Ambient
			GH.Cache.OrigOutdoorAmbient = Lighting.OutdoorAmbient
			Lighting.Brightness = 2
			Lighting.ClockTime = 14
			Lighting.Ambient = Color3.fromRGB(200, 200, 200)
			Lighting.OutdoorAmbient = Color3.fromRGB(200, 200, 200)
		else
			Lighting.Brightness = GH.Cache.OrigBrightness or 1
			Lighting.ClockTime = GH.Cache.OrigClockTime or 14
			Lighting.Ambient = GH.Cache.OrigAmbient or Color3.fromRGB(128, 128, 128)
			Lighting.OutdoorAmbient = GH.Cache.OrigOutdoorAmbient or Color3.fromRGB(128, 128, 128)
		end
	end

	-- ==========================================
	-- FOV CHANGER
	-- ==========================================
	function Cheats_ToggleFOVChanger(state, btn)
		if state then
			workspace.CurrentCamera.FieldOfView = 90
			GH.ShowToast(GH.T("toast_fov"), GH.Theme.Accent, 2)
		else
			workspace.CurrentCamera.FieldOfView = 70
		end
	end

	-- ==========================================
	-- TRACERS
	-- ==========================================
	local TracerPool = GH.ObjectPool.new(
		function()
			local line = Drawing.new("Line")
			line.Thickness = 1.5
			line.Transparency = 0.7
			return line
		end,
		function(line)
			line.Visible = false
			line.From = Vector2.zero
			line.To = Vector2.zero
		end
	)
	local CacheTracers = { Lines = {} }

	function Cheats_ToggleTracers(state, btn)
		for player, line in pairs(CacheTracers.Lines) do
			TracerPool:release(line)
			CacheTracers.Lines[player] = nil
		end
		if not state then return end

		local function ensureTracer(player)
			if player == LocalPlayer then return end
			if not CacheTracers.Lines[player] then
				CacheTracers.Lines[player] = TracerPool:get()
			end
		end

		if GH.States.ESP then
			for player, _ in pairs(GH.Cache.ESPPlayers) do
				if player and player.Parent then ensureTracer(player) end
			end
		end

		GH.Connections.TracersLoop = RunService.RenderStepped:Connect(function()
			if GH.isClosing or not GH.States.Tracers then return end
			local cam = workspace.CurrentCamera
			if not cam then return end
			local screenCenter = Vector2.new(cam.ViewportSize.X / 2, cam.ViewportSize.Y)

			for player, _ in pairs(GH.Cache.ESPPlayers) do
				if player and player.Parent and player.Character then
					local hrp = player.Character:FindFirstChild("HumanoidRootPart")
					if not hrp then continue end
					if not CacheTracers.Lines[player] then
						CacheTracers.Lines[player] = TracerPool:get()
					end
					local line = CacheTracers.Lines[player]
					local screenPos, onScreen = cam:WorldToViewportPoint(hrp.Position)
					if onScreen then
						line.From = screenCenter
						line.To = Vector2.new(screenPos.X, screenPos.Y)
						line.Visible = true
						if LocalPlayer.Team and player.Team then
							line.Color = (player.Team == LocalPlayer.Team) and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
						else
							line.Color = Color3.fromRGB(255, 255, 0)
						end
					else
						line.Visible = false
					end
				end
			end
		end)
	end

	-- ==========================================
	-- CROSSHAIR
	-- ==========================================
	local CacheCrosshair = { Objects = {} }
	local CrosshairStyle = "cross"
	local CrosshairColor = Color3.fromRGB(0, 255, 0)
	local CrosshairSize = 4

	function Cheats_ToggleCrosshair(state, btn)
		if state then
			if CacheCrosshair.Objects.Main then return end
			local gui = Instance.new("ScreenGui")
			gui.Name = "GH_Crosshair"
			gui.ResetOnSpawn = false
			gui.IgnoreGuiInset = true
			gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
			gui.Parent = GH.TargetGui
			local center = Instance.new("Frame")
			center.Size = UDim2.new(0, 0, 0, 0)
			center.Position = UDim2.new(0.5, 0, 0.5, 0)
			center.BackgroundTransparency = 1
			center.Parent = gui
			CacheCrosshair.Objects = { GUI = gui, Center = center }

			local h = Instance.new("Frame")
			h.Size = UDim2.new(0, CrosshairSize * 3, 0, 1)
			h.Position = UDim2.new(0.5, -CrosshairSize * 1.5, 0.5, -0.5)
			h.BackgroundColor3 = CrosshairColor
			h.BorderSizePixel = 0
			h.Parent = center
			local v = Instance.new("Frame")
			v.Size = UDim2.new(0, 1, 0, CrosshairSize * 3)
			v.Position = UDim2.new(0.5, -0.5, 0.5, -CrosshairSize * 1.5)
			v.BackgroundColor3 = CrosshairColor
			v.BorderSizePixel = 0
			v.Parent = center
		else
			if CacheCrosshair.Objects.GUI then
				CacheCrosshair.Objects.GUI:Destroy()
				CacheCrosshair.Objects = {}
			end
		end
	end

	-- ==========================================
	-- REGISTRAR BOTÕES
	-- ==========================================
	GH.RegisterToggleButton("XRay", GH.T("toggle_xray"), Cheats_ToggleXRay, "Visual", GH.T("desc_xray"))
	GH.RegisterToggleButton("NightMode", GH.T("toggle_nightmode"), Cheats_ToggleNightMode, "Visual", GH.T("desc_nightmode"))
	GH.RegisterToggleButton("Fullbright", GH.T("toggle_fullbright"), Cheats_ToggleFullbright, "Visual", GH.T("desc_fullbright"))
	GH.RegisterToggleButton("Tracers", GH.T("toggle_tracers"), Cheats_ToggleTracers, "Visual", GH.T("desc_tracers"))
	GH.RegisterToggleButton("Crosshair", GH.T("toggle_crosshair"), Cheats_ToggleCrosshair, "Visual", GH.T("desc_crosshair"))
	GH.RegisterToggleButton("FOVChanger", GH.T("toggle_fovchanger"), Cheats_ToggleFOVChanger, "Visual", GH.T("desc_fovchanger"))
end
