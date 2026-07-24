-- =============================================================================
-- MODULE: COMBAT
-- =============================================================================
--!nonstrict
return function(GH)
	local Players = GH.Services.Players
	local RunService = GH.Services.RunService
	local UserInputService = GH.Services.UserInputService
	local TweenService = GH.Services.TweenService
	local LocalPlayer = GH.LocalPlayer

	-- ==========================================
	-- ESP
	-- ==========================================
	local ESPColors = {
		Enemy = {
			HighlightFill = Color3.fromRGB(255, 30, 30),
			HighlightOutline = Color3.fromRGB(255, 80, 80),
			Text = Color3.fromRGB(255, 60, 60),
			Tag = "[INIMIGO]",
			TextColor = Color3.fromRGB(255, 255, 255),
		},
		Ally = {
			HighlightFill = Color3.fromRGB(30, 200, 30),
			HighlightOutline = Color3.fromRGB(80, 255, 80),
			Text = Color3.fromRGB(60, 255, 60),
			Tag = "[ALIADO]",
			TextColor = Color3.fromRGB(255, 255, 255),
		},
		Neutral = {
			HighlightFill = Color3.fromRGB(255, 200, 30),
			HighlightOutline = Color3.fromRGB(255, 230, 100),
			Text = Color3.fromRGB(255, 220, 50),
			Tag = "[JOGADOR]",
			TextColor = Color3.fromRGB(255, 255, 255),
		},
	}

	local function GetPlayerRelation(player)
		if player == LocalPlayer then return nil end
		if LocalPlayer.Team and player.Team then
			if player.Team == LocalPlayer.Team then return "Ally"
			else return "Enemy" end
		end
		return "Neutral"
	end

	function Cheats_ToggleESP(state, btn)
		btn.Text = state and "Desativar ESP" or "Ativar ESP"
		GH.Disconnect("ESP_GlobalLoop")
		GH.Disconnect("ESP_Added")
		GH.Disconnect("ESP_Removing")
		GH.Disconnect("ESP_TeamChanged")
		for name, _ in pairs(GH.Connections) do
			if name:sub(1, 10) == "ESP_Team_" then
				GH.Disconnect(name)
			end
		end

		for _, p in ipairs(Players:GetPlayers()) do
			if p ~= LocalPlayer and p.Character then
				for _, obj in ipairs(p.Character:GetChildren()) do
					if obj.Name:sub(1, 6) == "GH_ESP" then obj:Destroy() end
				end
			end
		end
		table.clear(GH.Cache.ESPPlayers)

		if state then
			local function setupPlayer(player)
				if player == LocalPlayer then return end
				GH.Cache.ESPPlayers[player] = true

				local function render(char)
					if not GH.States.ESP then return end
					for _, obj in ipairs(char:GetChildren()) do
						if obj.Name:sub(1, 6) == "GH_ESP" then obj:Destroy() end
					end

					local relation = GetPlayerRelation(player)
					if not relation then return end
					local colors = ESPColors[relation]

					local hl = Instance.new("Highlight")
					hl.Name = "GH_ESP_HL"
					hl.FillColor = colors.HighlightFill
					hl.FillTransparency = 0.55
					hl.OutlineColor = colors.HighlightOutline
					hl.OutlineTransparency = 0
					hl.Adornee = char
					hl.Parent = char

					local bg = Instance.new("BillboardGui")
					bg.Name = "GH_ESP_Text"
					bg.Size = UDim2.new(0, 200, 0, 46)
					bg.StudsOffset = Vector3.new(0, 3, 0)
					bg.AlwaysOnTop = true
					bg.Parent = char

					local tagLabel = Instance.new("TextLabel")
					tagLabel.Name = "GH_ESP_Tag"
					tagLabel.Size = UDim2.new(1, 0, 0, 14)
					tagLabel.Position = UDim2.new(0, 0, 0, 0)
					tagLabel.BackgroundTransparency = 1
					tagLabel.Text = colors.Tag
					tagLabel.TextColor3 = colors.Text
					tagLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
					tagLabel.TextStrokeTransparency = 0.3
					tagLabel.Font = Enum.Font.GothamBlack
					tagLabel.TextSize = 13
					tagLabel.TextXAlignment = Enum.TextXAlignment.Center
					tagLabel.Parent = bg

					local nameLabel = Instance.new("TextLabel")
					nameLabel.Name = "GH_ESP_Name"
					nameLabel.Size = UDim2.new(1, 0, 0, 13)
					nameLabel.Position = UDim2.new(0, 0, 0, 14)
					nameLabel.BackgroundTransparency = 1
					nameLabel.Text = player.Name
					nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
					nameLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
					nameLabel.TextStrokeTransparency = 0.3
					nameLabel.Font = Enum.Font.GothamBold
					nameLabel.TextSize = 11
					nameLabel.TextXAlignment = Enum.TextXAlignment.Center
					nameLabel.Parent = bg

					local hpBg = Instance.new("Frame")
					hpBg.Name = "GH_ESP_HpBg"
					hpBg.Size = UDim2.new(0.6, 0, 0, 3)
					hpBg.Position = UDim2.new(0.2, 0, 0, 28)
					hpBg.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
					hpBg.BorderSizePixel = 0
					hpBg.Parent = bg
					Instance.new("UICorner", hpBg).CornerRadius = UDim.new(0, 2)

					local hpFill = Instance.new("Frame")
					hpFill.Name = "GH_ESP_HpFill"
					hpFill.Size = UDim2.new(1, 0, 1, 0)
					hpFill.BackgroundColor3 = colors.Text
					hpFill.BorderSizePixel = 0
					hpFill.Parent = hpBg
					Instance.new("UICorner", hpFill).CornerRadius = UDim.new(0, 2)

					local infoLabel = Instance.new("TextLabel")
					infoLabel.Name = "GH_ESP_Info"
					infoLabel.Size = UDim2.new(1, 0, 0, 12)
					infoLabel.Position = UDim2.new(0, 0, 0, 32)
					infoLabel.BackgroundTransparency = 1
					infoLabel.Text = ""
					infoLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
					infoLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
					infoLabel.TextStrokeTransparency = 0.3
					infoLabel.Font = Enum.Font.GothamMedium
					infoLabel.TextSize = 10
					infoLabel.TextXAlignment = Enum.TextXAlignment.Center
					infoLabel.Parent = bg
				end

				if player.Character then render(player.Character) end
				GH.Cache.ESPPlayers[player] = player.CharacterAdded:Connect(render)
			end

			for _, p in ipairs(Players:GetPlayers()) do setupPlayer(p) end
			GH.Connections.ESP_Added = Players.PlayerAdded:Connect(setupPlayer)
			GH.Connections.ESP_Removing = Players.PlayerRemoving:Connect(function(p)
				if GH.Cache.ESPPlayers[p] then
					if typeof(GH.Cache.ESPPlayers[p]) == "RBXScriptConnection" then
						GH.Cache.ESPPlayers[p]:Disconnect()
					end
					GH.Cache.ESPPlayers[p] = nil
				end
				if p.Character then
					for _, obj in ipairs(p.Character:GetChildren()) do
						if obj.Name:sub(1, 6) == "GH_ESP" then obj:Destroy() end
					end
				end
			end)

			GH.Connections.ESP_TeamChanged = Players.PlayerAdded:Connect(function(player)
				player:GetPropertyChangedSignal("Team"):Connect(function()
					if GH.States.ESP and player.Character then
						for _, obj in ipairs(player.Character:GetChildren()) do
							if obj.Name:sub(1, 6) == "GH_ESP" then obj:Destroy() end
						end
						if player.Character then setupPlayer(player) end
					end
				end)
			end)
			for _, p in ipairs(Players:GetPlayers()) do
				if p ~= LocalPlayer then
					p:GetPropertyChangedSignal("Team"):Connect(function()
						if GH.States.ESP and p.Character then
							for _, obj in ipairs(p.Character:GetChildren()) do
								if obj.Name:sub(1, 6) == "GH_ESP" then obj:Destroy() end
							end
							if p.Character then setupPlayer(p) end
						end
					end)
				end
			end

			-- Render loop
			GH.RegisterMasterLoop("ESP", "Render", function()
				if GH.isClosing or not GH.States.ESP then
					GH.UnregisterMasterLoop("ESP"); return
				end
				local myHrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
				if not myHrp then return end
				local myPos = myHrp.Position

				for player, _ in pairs(GH.Cache.ESPPlayers) do
					if player and player.Parent and player.Character then
						local char = player.Character
						local head = char:FindFirstChild("Head") or char:FindFirstChild("HumanoidRootPart")
						local hum = char:FindFirstChildOfClass("Humanoid")
						local bg = char:FindFirstChild("GH_ESP_Text")
						if not (head and hum and bg) then continue end

						local dist = (myPos - head.Position).Magnitude
						local isFar = dist > GH.Settings.ESPMaxDistance
						local hl = char:FindFirstChild("GH_ESP_HL")
						if isFar then
							bg.Enabled = false
							if hl then hl.Enabled = false end
							continue
						else
							bg.Enabled = true
							if hl then hl.Enabled = true end
						end

						local relation = GetPlayerRelation(player)
						if not relation then continue end
						local colors = ESPColors[relation]

						local tagLabel = bg:FindFirstChild("GH_ESP_Tag")
						if tagLabel then
							tagLabel.Visible = GH.Settings.ESPShowTag
							if tagLabel.Text ~= colors.Tag then
								tagLabel.Text = colors.Tag
								tagLabel.TextColor3 = colors.Text
							end
						end

						local nameLabel = bg:FindFirstChild("GH_ESP_Name")
						if nameLabel then nameLabel.Visible = GH.Settings.ESPShowName end

						dist = math.floor(dist)
						local hp = math.floor(hum.Health)
						local maxHp = math.floor(hum.MaxHealth)
						local ratio = maxHp > 0 and math.clamp(hp / maxHp, 0, 1) or 0

						local hpBg = bg:FindFirstChild("GH_ESP_HpBg")
						if hpBg then
							hpBg.Visible = GH.Settings.ESPShowHealth
							local hpFill = hpBg:FindFirstChild("GH_ESP_HpFill")
							if hpFill then
								hpFill.Size = UDim2.new(ratio, 0, 1, 0)
								if ratio >= 0.6 then hpFill.BackgroundColor3 = Color3.fromRGB(0, 220, 80)
								elseif ratio >= 0.3 then hpFill.BackgroundColor3 = Color3.fromRGB(255, 180, 0)
								else hpFill.BackgroundColor3 = Color3.fromRGB(255, 50, 50) end
							end
						end

						local infoLabel = bg:FindFirstChild("GH_ESP_Info")
						if infoLabel then
							local showInfo = GH.Settings.ESPShowHealth or GH.Settings.ESPShowDistance
							infoLabel.Visible = showInfo
							if showInfo then
								if GH.Settings.ESPShowHealth and GH.Settings.ESPShowDistance then
									infoLabel.Text = hp .. "/" .. maxHp .. "  |  " .. dist .. "m"
								elseif GH.Settings.ESPShowHealth then
									infoLabel.Text = hp .. "/" .. maxHp
								else
									infoLabel.Text = dist .. "m"
								end
								if ratio >= 0.6 then infoLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
								elseif ratio >= 0.3 then infoLabel.TextColor3 = Color3.fromRGB(255, 200, 80)
								else infoLabel.TextColor3 = Color3.fromRGB(255, 80, 80) end
							end
						end
					end
				end
			end)
		end
	end

	-- ==========================================
	-- HITBOX
	-- ==========================================
	function Cheats_ToggleHitbox(state, btn)
		btn.Text = state and "Desativar Hitbox" or "Hitbox Gigante"
		GH.UnregisterMasterLoop("Hitbox")
		GH.Disconnect("Hitbox_PlayerRemoving")

		-- Restaurar tamanhos originais dos HRPs
		for _, player in ipairs(Players:GetPlayers()) do
			if player.Character then
				local hrp = player.Character:FindFirstChild("HumanoidRootPart")
				if hrp and GH.Cache.OrigHRPSizes[player] then
					hrp.Size = GH.Cache.OrigHRPSizes[player]
					hrp.Transparency = 1
					hrp.CanCollide = false
				end
			end
		end

		-- Limpar SelectionBox de todos os locais possiveis
		local function cleanSelectionBox(obj)
			if obj and obj.Parent and obj:IsA("SelectionBox") and obj.Name:sub(1, 12) == "GH_Hitbox_SB" then
				obj.Adornee = nil
				obj:Destroy()
			end
		end

		-- Limpar do TargetGui
		for _, obj in ipairs(GH.TargetGui:GetChildren()) do
			cleanSelectionBox(obj)
		end

		-- Limpar dos personagens
		for _, player in ipairs(Players:GetPlayers()) do
			if player.Character then
				for _, obj in ipairs(player.Character:GetChildren()) do
					cleanSelectionBox(obj)
				end
			end
		end

		table.clear(GH.Cache.OrigHRPSizes)
		table.clear(GH.Cache.HitboxAdornments)

		if not state then return end

		GH.Connections.Hitbox_PlayerRemoving = Players.PlayerRemoving:Connect(function(player)
			if GH.Cache.HitboxAdornments[player] then
				local sb = GH.Cache.HitboxAdornments[player]
				if sb and sb.Parent then
					sb.Adornee = nil
					sb:Destroy()
				end
				GH.Cache.HitboxAdornments[player] = nil
			end
			-- Limpar SelectionBox do character tambem
			if player.Character then
				for _, obj in ipairs(player.Character:GetChildren()) do
					if obj:IsA("SelectionBox") and obj.Name:sub(1, 12) == "GH_Hitbox_SB" then
						obj.Adornee = nil
						obj:Destroy()
					end
				end
			end
			GH.Cache.OrigHRPSizes[player] = nil
		end)

		GH.RegisterMasterLoop("Hitbox", "Render", function()
			if GH.isClosing or not GH.States.Hitbox then
				GH.UnregisterMasterLoop("Hitbox")
				GH.Disconnect("Hitbox_PlayerRemoving")
				return
			end
			for _, player in ipairs(Players:GetPlayers()) do
				if player == LocalPlayer then continue end
				if LocalPlayer.Team and player.Team and player.Team == LocalPlayer.Team then continue end

				if not player.Character then
					if GH.Cache.HitboxAdornments[player] then
						local sb = GH.Cache.HitboxAdornments[player]
						if sb and sb.Parent then
							sb.Adornee = nil
							sb:Destroy()
						end
						GH.Cache.HitboxAdornments[player] = nil
					end
					GH.Cache.OrigHRPSizes[player] = nil
					continue
				end

				local hrp = player.Character:FindFirstChild("HumanoidRootPart")
				local hum = player.Character:FindFirstChildOfClass("Humanoid")
				if not hrp or not hrp.Parent or not hum or hum.Health <= 0 then
					if GH.Cache.HitboxAdornments[player] then
						local sb = GH.Cache.HitboxAdornments[player]
						if sb and sb.Parent then
							sb.Adornee = nil
							sb:Destroy()
						end
						GH.Cache.HitboxAdornments[player] = nil
					end
					if hrp and hrp.Parent and GH.Cache.OrigHRPSizes[player] then
						hrp.Size = GH.Cache.OrigHRPSizes[player]
						hrp.Transparency = 1
						hrp.CanCollide = false
					end
					GH.Cache.OrigHRPSizes[player] = nil
					continue
				end

				if not GH.Cache.OrigHRPSizes[player] then
					GH.Cache.OrigHRPSizes[player] = hrp.Size
				end
				hrp.Size = Vector3.new(GH.Settings.HitboxSize, GH.Settings.HitboxSize, GH.Settings.HitboxSize)
				hrp.Transparency = 1
				hrp.CanCollide = false

				local sb = GH.Cache.HitboxAdornments[player]
				if not sb or not sb.Parent or sb.Adornee ~= hrp then
					if sb and sb.Parent then
						sb.Adornee = nil
						sb:Destroy()
					end
					sb = Instance.new("SelectionBox")
					sb.Name = "GH_Hitbox_SB_" .. player.Name
					sb.Adornee = hrp
					sb.Color3 = Color3.fromRGB(255, 0, 0)
					sb.SurfaceTransparency = 1
					sb.Parent = GH.TargetGui
					GH.Cache.HitboxAdornments[player] = sb
				end
			end
		end)
	end

	-- ==========================================
	-- TRIGGER BOT
	-- ==========================================
	function Cheats_ToggleTriggerBot(state, btn)
		btn.Text = state and "Desativar TriggerBot" or "TriggerBot"
		GH.Disconnect("TriggerBot")

		if state then
			GH.Connections.TriggerBot = RunService.RenderStepped:Connect(function()
				if GH.isClosing or not GH.States.TriggerBot then
					GH.Disconnect("TriggerBot"); return
				end
				local character = LocalPlayer.Character
				if not character then return end
				local tool = character:FindFirstChildOfClass("Tool")
				if not tool then return end
				local cam = workspace.CurrentCamera
				if not cam then return end

				local viewportCenter = cam.ViewportSize / 2
				local unitRay = cam:ViewportPointToRay(viewportCenter.X, viewportCenter.Y)
				local rayParams = RaycastParams.new()
				rayParams.FilterDescendantsInstances = { character }
				rayParams.FilterType = Enum.RaycastFilterType.Exclude

				local result = workspace:Raycast(unitRay.Origin, unitRay.Direction * 250, rayParams)
				if not result or not result.Instance then return end
				local targetChar = result.Instance:FindFirstAncestorOfClass("Model")
				if not targetChar then return end
				local targetHum = targetChar:FindFirstChildOfClass("Humanoid")
				if not targetHum or targetHum.Health <= 0 then return end

				local targetPlayer = Players:GetPlayerFromCharacter(targetChar)
				if targetPlayer and LocalPlayer.Team and targetPlayer.Team == LocalPlayer.Team then return end

				pcall(function() tool:Activate() end)
			end)
		end
	end

	-- ==========================================
	-- SILENT AIM (via Namecall)
	-- ==========================================
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
		btn.Text = state and "Desativar SilentAim" or "Silent Aim"
		GH.SilentAimConfig.Enabled = state
		GH.ShowToast(state and "Silent Aim ativado" or "Silent Aim desativado", state and GH.Theme.On or GH.Theme.Off, 2)
	end

	-- ==========================================
	-- NO KNOCKBACK (via Namecall)
	-- ==========================================
	table.insert(GH.NamecallHandlers, function(self, method, args)
		if not GH.States.NoKnockback then return false end
		if not (method == "ApplyImpulse" or method == "ApplyInstantForce") then return false end
		if self:IsA("BasePart") then
			local char = LocalPlayer.Character
			if char and self:IsDescendantOf(char) then return true end
		end
		return false
	end)

	function Cheats_ToggleNoKnockback(state, btn)
		btn.Text = state and "Desativar NoKnockback" or "No Knockback"
		GH.ShowToast(state and "No Knockback ativado" or "No Knockback desativado", state and GH.Theme.On or GH.Theme.Off, 2)
	end

	-- ==========================================
	-- WALL BANG (via Namecall)
	-- ==========================================
	table.insert(GH.NamecallHandlers, function(self, method, args)
		if not GH.States.WallBang then return false end
		if method ~= "Raycast" then return false end
		if args[3] and typeof(args[3]) == "RaycastParams" then
			args[3].FilterType = Enum.RaycastFilterType.Exclude
			local ignoreList = {}
			for _, obj in ipairs(workspace:GetChildren()) do
				if not obj:IsA("Model") or not obj:FindFirstChildOfClass("Humanoid") then
					table.insert(ignoreList, obj)
				end
			end
			args[3].FilterDescendantsInstances = ignoreList
			return true
		end
		return false
	end)

	function Cheats_ToggleWallBang(state, btn)
		btn.Text = state and "Desativar WallBang" or "Wall Bang"
		GH.ShowToast(state and "Wall Bang ativado" or "Wall Bang desativado", state and GH.Theme.On or GH.Theme.Off, 2)
	end

	-- ==========================================
	-- NO FALL DAMAGE (via Namecall)
	-- ==========================================
	table.insert(GH.NamecallHandlers, function(self, method, args)
		if not GH.States.NoFallDamage then return false end
		if method ~= "TakeDamage" then return false end
		if self:IsA("Humanoid") then
			local char = self.Parent
			if char and char == LocalPlayer.Character then
				if args[1] and typeof(args[1]) == "number" and args[1] > 0 then return true end
			end
		end
		return false
	end)

	function Cheats_ToggleNoFallDamage(state, btn)
		btn.Text = state and "Desativar NoFallDmg" or "No Fall Damage"
		GH.ShowToast(state and "No Fall Damage ativado" or "No Fall Damage desativado", state and GH.Theme.On or GH.Theme.Off, 2)
	end

	-- ==========================================
	-- INFINITE HEALTH
	-- ==========================================
	function Cheats_ToggleInfiniteHealth(state, btn)
		btn.Text = state and "Desativar InfHealth" or "Infinite Health"
		GH.UnregisterMasterLoop("InfiniteHealth")
		if state then
			GH.RegisterMasterLoop("InfiniteHealth", "Heartbeat", function()
				if GH.isClosing or not GH.States.InfiniteHealth then
					GH.UnregisterMasterLoop("InfiniteHealth"); return
				end
				local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
				if hum then hum.Health = hum.MaxHealth end
			end)
		end
		GH.ShowToast(state and "Infinite Health ativado" or "Infinite Health desativado", state and GH.Theme.On or GH.Theme.Off, 2)
	end

	-- ==========================================
	-- KILL AURA
	-- ==========================================
	function Cheats_ToggleKillAura(state, btn)
		btn.Text = state and "Desativar KillAura" or "Kill Aura"
		GH.UnregisterMasterLoop("KillAura")
		if state then
			GH.RegisterMasterLoop("KillAura", "Heartbeat", function()
				if GH.isClosing or not GH.States.KillAura then
					GH.UnregisterMasterLoop("KillAura"); return
				end
				local char = LocalPlayer.Character
				local hrp = char and char:FindFirstChild("HumanoidRootPart")
				local tool = char and char:FindFirstChildOfClass("Tool")
				if not hrp or not tool then return end

				local closestPlayer, closestDist = nil, 15
				for _, player in ipairs(Players:GetPlayers()) do
					if player == LocalPlayer then continue end
					if not player.Character then continue end
					local tHrp = player.Character:FindFirstChild("HumanoidRootPart")
					local tHum = player.Character:FindFirstChildOfClass("Humanoid")
					if not tHrp or not tHum or tHum.Health <= 0 then continue end
					if LocalPlayer.Team and player.Team and player.Team == LocalPlayer.Team then continue end
					local dist = (tHrp.Position - hrp.Position).Magnitude
					if dist < closestDist then closestDist = dist; closestPlayer = player end
				end

				if closestPlayer and closestPlayer.Character then
					local tHrp = closestPlayer.Character:FindFirstChild("HumanoidRootPart")
					if tHrp then
						hrp.CFrame = CFrame.new(hrp.Position, Vector3.new(tHrp.Position.X, hrp.Position.Y, tHrp.Position.Z))
						pcall(function() tool:Activate() end)
					end
				end
			end)
		end
		GH.ShowToast(state and "Kill Aura ativado" or "Kill Aura desativado", state and GH.Theme.On or GH.Theme.Off, 2)
	end

	-- ==========================================
	-- REGISTRAR BOTÕES
	-- ==========================================
	GH.RegisterToggleButton("Hitbox", "Hitbox Gigante", Cheats_ToggleHitbox, "Combat")
	GH.RegisterToggleButton("ESP", "Ativar ESP", Cheats_ToggleESP, "Combat")
	GH.RegisterToggleButton("TriggerBot", "TriggerBot", Cheats_ToggleTriggerBot, "Combat")
	GH.RegisterToggleButton("SilentAim", "Silent Aim", Cheats_ToggleSilentAim, "Combat")
	GH.RegisterToggleButton("NoKnockback", "No Knockback", Cheats_ToggleNoKnockback, "Combat")
	GH.RegisterToggleButton("WallBang", "Wall Bang", Cheats_ToggleWallBang, "Combat")
	GH.RegisterToggleButton("InfiniteHealth", "Infinite Health", Cheats_ToggleInfiniteHealth, "Combat")
	GH.RegisterToggleButton("KillAura", "Kill Aura", Cheats_ToggleKillAura, "Combat")
	GH.RegisterToggleButton("NoFallDamage", "No Fall Damage", Cheats_ToggleNoFallDamage, "Combat")
end
