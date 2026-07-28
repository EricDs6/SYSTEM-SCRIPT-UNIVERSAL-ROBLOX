-- =============================================================================
-- CLEANUP — FullCleanup (desativar todos os sistemas e restaurar estado)
-- =============================================================================
return function(GH, services)
local Players = services.Players
local RunService = services.RunService
local UserInputService = services.UserInputService
local Lighting = services.Lighting
local LocalPlayer = GH.LocalPlayer

function GH.FullCleanup()
	if GH._cleaningUp then return end
	GH._cleaningUp = true
	GH.isClosing = true
	GH.Stopped = true

	-- Limpar registro do Firebase
	if GH.Stats then
		GH.Stats.IsOnline = false
		if GH._CleanupPlayer then pcall(GH._CleanupPlayer) end
	end

	-- ==========================================
	-- LIMPEZA EXPLICITA DE FEATURES (antes dos callbacks)
	-- ==========================================

	-- Fly/VehicleFly: remover BodyVelocity/BodyGyro, restaurar humanoid
	pcall(function()
		local char = LocalPlayer.Character
		if char then
			local hrp = char:FindFirstChild("HumanoidRootPart")
			if hrp then
				for _, name in ipairs({"GH_FlyBV","GH_FlyBG","GH_VFlyBV","GH_VFlyBG"}) do
					local obj = hrp:FindFirstChild(name)
					if obj then obj:Destroy() end
				end
				hrp.AssemblyLinearVelocity = Vector3.zero
				hrp.AssemblyAngularVelocity = Vector3.zero
			end
			local hum = char:FindFirstChildOfClass("Humanoid")
			if hum then
				hum.PlatformStand = false
				hum.AutoRotate = true
				hum:SetStateEnabled(Enum.HumanoidStateType.Freefall, true)
				pcall(function() hum:ChangeState(Enum.HumanoidStateType.GettingUp) end)
			end
			for _, part in ipairs(char:GetDescendants()) do
				if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
					part.CanCollide = true
				end
				if part:IsA("Motor6D") then
					pcall(function() part:SetJointFrozen(Enum.JointType.Motor, false) end)
				end
			end
		end
	end)

	-- Float: remover plataforma
	pcall(function()
		local char = LocalPlayer.Character
		if char then
			local pad = char:FindFirstChild("GH_FloatPad")
			if pad then pad:Destroy() end
		end
		local pad2 = workspace:FindFirstChild("GH_FloatPad")
		if pad2 then pad2:Destroy() end
	end)

	-- TrollFling/TargetFling: remover AngularVelocity
	pcall(function()
		local char = LocalPlayer.Character
		if char then
			local hrp = char:FindFirstChild("HumanoidRootPart")
			if hrp then
				for _, name in ipairs({"GH_TrollSpin","GH_TargetSpin"}) do
					local obj = hrp:FindFirstChild(name)
					if obj then obj:Destroy() end
				end
				hrp.AssemblyAngularVelocity = Vector3.zero
				hrp.AssemblyLinearVelocity = Vector3.zero
			end
			local hum = char:FindFirstChildOfClass("Humanoid")
			if hum then hum.AutoRotate = true end
			for _, part in ipairs(char:GetDescendants()) do
				if part:IsA("BasePart") then part.CanCollide = true end
			end
		end
	end)

	-- NoFling: restaurar CustomPhysicalProperties
	pcall(function()
		local char = LocalPlayer.Character
		if char then
			for _, part in ipairs(char:GetDescendants()) do
				if part:IsA("BasePart") then part.CustomPhysicalProperties = nil end
			end
		end
	end)

	-- Freecam: unbind render step e restaurar camera
	pcall(function()
		RunService:UnbindFromRenderStep("GH_Freecam")
		local CAS = game:GetService("ContextActionService")
		CAS:UnbindAction("GH_FCKeys")
		CAS:UnbindAction("GH_FCMouse")
		local cam = workspace.CurrentCamera
		if cam then
			cam.CameraType = Enum.CameraType.Custom
			cam.FieldOfView = 70
		end
		UserInputService.MouseIconEnabled = true
	end)

	-- NightMode/Fullbright: restaurar Lighting
	pcall(function()
		Lighting.Brightness = GH.Cache.OrigNightBrightness or GH.Cache.OrigFBBrightness or 1
		Lighting.ClockTime = GH.Cache.OrigNightClockTime or GH.Cache.OrigFBClockTime or 14
		Lighting.Ambient = GH.Cache.OrigNightAmbient or GH.Cache.OrigFBAmbient or Color3.fromRGB(128, 128, 128)
		Lighting.OutdoorAmbient = GH.Cache.OrigNightOutdoorAmbient or GH.Cache.OrigFBOutdoorAmbient or Color3.fromRGB(128, 128, 128)
		local bloom = Lighting:FindFirstChild("GH_NightBloom")
		if bloom then bloom:Destroy() end
	end)

	-- XRay: restaurar LocalTransparencyModifier
	pcall(function()
		if GH.Cache.XRayParts then
			for _, part in ipairs(GH.Cache.XRayParts) do
				if part and part.Parent then part.LocalTransparencyModifier = 0 end
			end
		end
		table.clear(GH.Cache.XRayParts or {})
	end)

	-- BTools/ClickTP: remover tools
	pcall(function()
		local bp = LocalPlayer:FindFirstChild("Backpack")
		if bp then
			for _, v in ipairs(bp:GetChildren()) do
				if v:IsA("HopperBin") and v.Name:sub(1, 6) == "BTool_" then v:Destroy() end
				if v:IsA("Tool") and v.Name == "Click TP" then v:Destroy() end
			end
		end
	end)

	-- Crosshair: remover GUI
	pcall(function()
		local gui = GH.TargetGui:FindFirstChild("GH_Crosshair")
		if gui then gui:Destroy() end
	end)

	-- VoiceAudio: parar e destruir som
	pcall(function()
		local char = LocalPlayer.Character
		if char then
			local hrp = char:FindFirstChild("HumanoidRootPart")
			if hrp then
				local snd = hrp:FindFirstChild("GH_VoiceAudio")
				if snd then
					snd:Stop()
					snd:Destroy()
				end
			end
		end
	end)

	-- TpToVehicle: fechar GUI
	pcall(function()
		if GH.TargetGui:FindFirstChild("GH_VehiclePicker") then
			GH.TargetGui["GH_VehiclePicker"]:Destroy()
		end
	end)

	-- NoPlayerCollide: restaurar colisao de todos os players
	pcall(function()
		for part, origCanCollide in pairs(GH.Cache.OrigPlayerCollides) do
			if part and part.Parent then
				part.CanCollide = origCanCollide
			end
		end
		table.clear(GH.Cache.OrigPlayerCollides)
	end)

	-- Crawl: restaurar HipHeight
	pcall(function()
		local char = LocalPlayer.Character
		if char then
			local hum = char:FindFirstChildOfClass("Humanoid")
			if hum and GH.Cache.OrigHipHeight then
				hum.HipHeight = GH.Cache.OrigHipHeight
				GH.Cache.OrigHipHeight = nil
			end
		end
	end)

	-- WalkFling: desconectar
	pcall(function()
		if GH.Cache.WalkFlingConn then
			GH.Cache.WalkFlingConn:Disconnect()
			GH.Cache.WalkFlingConn = nil
		end
		if GH.Cache.WalkFlingDied then
			GH.Cache.WalkFlingDied:Disconnect()
			GH.Cache.WalkFlingDied = nil
		end
	end)

	-- AutoFling: desconectar
	pcall(function()
		if GH.Cache.AutoFlingConn then
			GH.Cache.AutoFlingConn:Disconnect()
			GH.Cache.AutoFlingConn = nil
		end
		if GH.Cache.AutoFlingDied then
			GH.Cache.AutoFlingDied:Disconnect()
			GH.Cache.AutoFlingDied = nil
		end
	end)

	-- Spasms: parar animacao
	pcall(function()
		if GH.Cache.SpasmTrack then GH.Cache.SpasmTrack:Stop(); GH.Cache.SpasmTrack = nil end
		if GH.Cache.SpasmAnim then GH.Cache.SpasmAnim:Destroy(); GH.Cache.SpasmAnim = nil end
	end)

	-- ==========================================
	-- DESATIVAR TODOS OS STATES (via callbacks)
	-- ==========================================
	GH.SilentRestore = true
	local statesToClean = {}
	for name, state in pairs(GH.States) do
		if state then table.insert(statesToClean, name) end
	end
	for _, name in ipairs(statesToClean) do
		GH.States[name] = false
		if GH.Callbacks[name] and GH.Buttons[name] then
			pcall(GH.Callbacks[name], false, GH.Buttons[name])
		end
	end
	GH.SilentRestore = false

	-- Desregistrar todos os master loops
	for phase, callbacks in pairs(GH.MasterCallbacks) do
		for name, _ in pairs(callbacks) do
			callbacks[name] = nil
		end
	end

	-- Desconectar todas as conexoes locais
	for name, conn in pairs(GH.Connections) do
		if conn and typeof(conn) == "RBXScriptConnection" then
			pcall(function() conn:Disconnect() end)
		end
		GH.Connections[name] = nil
	end

	-- Limpar conexoes globais
	GH.CleanupGlobalConnections()

	-- Limpar input manager
	table.clear(GH.InputManager._bindings)

	-- Destruir todas as GUIs auxiliares
	for key, obj in pairs(GH.Objects) do
		if obj and typeof(obj) == "Instance" then
			pcall(function() obj:Destroy() end)
		end
		GH.Objects[key] = nil
	end

	-- Restaurar workspace
	pcall(function()
		workspace.Gravity = GH.Cache.OrigGravity or 196.2
	end)

	-- Restaurar humanoid
	pcall(function()
		local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
		if hum then
			hum.WalkSpeed = GH.Cache.OrigWalkSpeed or 16
			hum.JumpHeight = 7.2
			hum.JumpPower = 50
			hum.PlatformStand = false
			hum.AutoRotate = true
			local enums = Enum.HumanoidStateType:GetEnumItems()
			table.remove(enums, table.find(enums, Enum.HumanoidStateType.None))
			for _, v in ipairs(enums) do hum:SetStateEnabled(v, true) end
		end
	end)

	-- Limpar HRP sizes
	for player, origSize in pairs(GH.Cache.OrigHRPSizes) do
		pcall(function()
			if player.Character then
				local hrp = player.Character:FindFirstChild("HumanoidRootPart")
				if hrp and origSize then
					hrp.Size = origSize
					hrp.Transparency = 1
					hrp.CanCollide = false
				end
			end
		end)
	end
	table.clear(GH.Cache.OrigHRPSizes)

	-- Restaurar Head Sizes
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

	-- Limpar SelectionBoxes
	pcall(function()
		for _, obj in ipairs(GH.TargetGui:GetChildren()) do
			if obj:IsA("SelectionBox") and obj.Name:sub(1, 12) == "GH_Hitbox_SB" then
				obj.Adornee = nil
				obj:Destroy()
			end
		end
	end)

	-- Limpar ESP
	pcall(function()
		if GH.Objects.ESP_Folder and GH.Objects.ESP_Folder.Parent then
			GH.Objects.ESP_Folder:Destroy()
			GH.Objects.ESP_Folder = nil
		end
		for _, p in ipairs(Players:GetPlayers()) do
			if p ~= LocalPlayer and p.Character then
				local hum = p.Character:FindFirstChildOfClass("Humanoid")
				if hum then
					hum.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.Viewer
				end
			end
		end
	end)

	-- Limpar animacoes
	pcall(function()
		if GH.Cache.SpasmTrack then GH.Cache.SpasmTrack:Stop(); GH.Cache.SpasmTrack = nil end
		if GH.Cache.SpasmAnim then GH.Cache.SpasmAnim:Destroy(); GH.Cache.SpasmAnim = nil end
	end)

	-- Destruir janela Fluent
	pcall(function()
		if GH.Window then
			if GH.Window.Window then GH.Window.Window:Destroy() end
			GH.Window = nil
		end
		if GH.TargetGui:FindFirstChild("SystemScript") then
			GH.TargetGui["SystemScript"]:Destroy()
		end
		if GH.TargetGui:FindFirstChild("SystemScriptStats") then
			GH.TargetGui["SystemScriptStats"]:Destroy()
		end
		for id, picker in pairs(GH._Pickers or {}) do
			if picker then
				for _, conn in ipairs(picker.conns or {}) do
					pcall(function() conn:Disconnect() end)
				end
				if picker.dragConn then pcall(function() picker.dragConn:Disconnect() end) end
				if picker.gui then pcall(function() picker.gui:Destroy() end) end
			end
		end
		GH._Pickers = {}
	end)

	-- Limpar tabelas
	table.clear(GH.Cache.HitboxAdornments)
	table.clear(GH.Cache.ESPPlayers)
end

end -- module
