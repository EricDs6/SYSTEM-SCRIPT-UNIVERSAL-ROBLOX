-- =============================================================================
-- MODULE: TROLL
-- =============================================================================
--!nonstrict
return function(GH)
	local Players = GH.Services.Players
	local RunService = GH.Services.RunService
	local UserInputService = GH.Services.UserInputService
	local TweenService = GH.Services.TweenService
	local LocalPlayer = GH.LocalPlayer

	-- ==========================================
	-- TROLL FLING
	-- ==========================================
	function Cheats_ToggleTrollFling(state, btn)
		btn.Text = state and "Desativar Tornado" or "Tornado Fling"
		GH.UnregisterMasterLoop("TrollFling")

		local char = LocalPlayer.Character
		local hrp = char and char:FindFirstChild("HumanoidRootPart")
		local hum = char and char:FindFirstChildOfClass("Humanoid")

		if state and hrp and hum then
			hum.AutoRotate = false
			local oldSpin = hrp:FindFirstChild("GH_TrollSpin")
			if oldSpin then oldSpin:Destroy() end

			local spinForce = Instance.new("AngularVelocity")
			spinForce.Name = "GH_TrollSpin"
			spinForce.AngularVelocity = Vector3.new(0, 100, 0)
			spinForce.MaxTorque = math.huge
			spinForce.Attachment0 = hrp:FindFirstChildOfClass("Attachment") or Instance.new("Attachment", hrp)
			spinForce.Parent = hrp

			GH.RegisterMasterLoop("TrollFling", "Heartbeat", function()
				if GH.isClosing or not GH.States.TrollFling then
					GH.UnregisterMasterLoop("TrollFling")
					local c = LocalPlayer.Character
					local h = c and c:FindFirstChildOfClass("Humanoid")
					local r = c and c:FindFirstChild("HumanoidRootPart")
					if h then h.AutoRotate = true end
					if r then
						local spin = r:FindFirstChild("GH_TrollSpin")
						if spin then spin:Destroy() end
						r.AssemblyAngularVelocity = Vector3.zero
					end
					return
				end
				local c = LocalPlayer.Character
				local h = c and c:FindFirstChildOfClass("Humanoid")
				local r = c and c:FindFirstChild("HumanoidRootPart")
				if not r or not h or h.Health <= 0 then
					GH.UnregisterMasterLoop("TrollFling"); return
				end
				local spin = r:FindFirstChild("GH_TrollSpin")
				if not spin then
					spin = Instance.new("AngularVelocity")
					spin.Name = "GH_TrollSpin"
					spin.AngularVelocity = Vector3.new(0, 100, 0)
					spin.MaxTorque = math.huge
					spin.Attachment0 = r:FindFirstChildOfClass("Attachment") or Instance.new("Attachment", r)
					spin.Parent = r
				end
				h.AutoRotate = false
				r.AssemblyLinearVelocity = Vector3.new(r.AssemblyLinearVelocity.X, 3, r.AssemblyLinearVelocity.Z)
			end)
		else
			if hum then hum.AutoRotate = true end
			if hrp then
				local spin = hrp:FindFirstChild("GH_TrollSpin")
				if spin then spin:Destroy() end
				hrp.AssemblyAngularVelocity = Vector3.zero
			end
		end
	end

	-- ==========================================
	-- TARGET FLING
	-- ==========================================
	local TargetFlingTarget = nil
	local TargetFlingGUI = nil

	function Cheats_ToggleTargetFling(state, btn)
		btn.Text = state and "Desativar TargetFling" or "Target Fling"
		GH.UnregisterMasterLoop("TargetFling")
		GH.Disconnect("TargetFlingRespawn")
		if TargetFlingGUI then TargetFlingGUI:Destroy(); TargetFlingGUI = nil end
		TargetFlingTarget = nil

		-- Restaurar ao desativar
		pcall(function()
			local char = LocalPlayer.Character
			local hrp = char and char:FindFirstChild("HumanoidRootPart")
			if hrp then
				local oldSpin = hrp:FindFirstChild("GH_TargetSpin")
				if oldSpin then oldSpin:Destroy() end
				hrp.AssemblyAngularVelocity = Vector3.zero
				hrp.AssemblyLinearVelocity = Vector3.zero
				for _, part in ipairs(char:GetDescendants()) do
					if part:IsA("BasePart") then part.CanCollide = true end
				end
				local hum = char:FindFirstChildOfClass("Humanoid")
				if hum then hum.AutoRotate = true end
			end
		end)

		if not state then return end

		-- GUI de seleção
		local gui = Instance.new("ScreenGui")
		gui.Name = "GH_TargetFlingList"
		gui.ResetOnSpawn = false
		gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
		gui.Parent = GH.TargetGui
		TargetFlingGUI = gui

		local frame = Instance.new("Frame")
		frame.Size = UDim2.new(0, 160, 0, 220)
		frame.Position = UDim2.new(0, 10, 0.5, -110)
		frame.BackgroundColor3 = GH.Theme.BG
		frame.BorderSizePixel = 0
		frame.Parent = gui
		Instance.new("UIStroke", frame).Color = GH.Theme.Border

		local title = Instance.new("TextLabel")
		title.Size = UDim2.new(1, 0, 0, 26)
		title.BackgroundColor3 = GH.Theme.Topbar
		title.Text = "ESCOLHER ALVO"
		title.TextColor3 = GH.Theme.Red
		title.Font = Enum.Font.GothamBold
		title.TextSize = 11
		title.BorderSizePixel = 0
		title.Parent = frame

		local scroll = Instance.new("ScrollingFrame")
		scroll.Size = UDim2.new(1, -8, 1, -32)
		scroll.Position = UDim2.new(0, 4, 0, 30)
		scroll.BackgroundTransparency = 1
		scroll.ScrollBarThickness = 2
		scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
		scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
		scroll.BorderSizePixel = 0
		scroll.Parent = frame
		Instance.new("UIListLayout", scroll).Padding = UDim.new(0, 2)

		local function startFlinging(targetPlayer)
			TargetFlingTarget = targetPlayer
			if TargetFlingGUI then TargetFlingGUI:Destroy(); TargetFlingGUI = nil end

			local char = LocalPlayer.Character
			local hrp = char and char:FindFirstChild("HumanoidRootPart")
			local hum = char and char:FindFirstChildOfClass("Humanoid")
			if not hrp or not hum then return end
			hum.AutoRotate = false
			for _, part in ipairs(char:GetDescendants()) do
				if part:IsA("BasePart") then part.CanCollide = false end
			end

			local oldSpin = hrp:FindFirstChild("GH_TargetSpin")
			if oldSpin then oldSpin:Destroy() end
			local spinForce = Instance.new("AngularVelocity")
			spinForce.Name = "GH_TargetSpin"
			spinForce.AngularVelocity = Vector3.new(0, 5000, 0)
			spinForce.MaxTorque = math.huge
			spinForce.Attachment0 = hrp:FindFirstChildOfClass("Attachment") or Instance.new("Attachment", hrp)
			spinForce.Parent = hrp

			GH.ShowToast("Target Fling: " .. targetPlayer.Name, GH.Theme.Red, 2)

			GH.RegisterMasterLoop("TargetFling", "Heartbeat", function()
				if GH.isClosing or not GH.States.TargetFling then
					GH.UnregisterMasterLoop("TargetFling"); return
				end
				local myHRP = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
				local myHum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
				if not myHRP or not myHum or myHum.Health <= 0 then return end
				for _, part in ipairs(LocalPlayer.Character:GetDescendants()) do
					if part:IsA("BasePart") then part.CanCollide = false end
				end
				local targetHRP = TargetFlingTarget and TargetFlingTarget.Character and TargetFlingTarget.Character:FindFirstChild("HumanoidRootPart")
				if targetHRP then
					myHRP.CFrame = targetHRP.CFrame
					myHRP.AssemblyLinearVelocity = Vector3.new(0, 100, 0)
				end
			end)
		end

		-- Refresh list
		for _, child in ipairs(scroll:GetChildren()) do
			if child:IsA("TextButton") then child:Destroy() end
		end
		local order = 0
		for _, player in ipairs(Players:GetPlayers()) do
			if player ~= LocalPlayer then
				order += 1
				local plrBtn = Instance.new("TextButton")
				plrBtn.Size = UDim2.new(1, 0, 0, 28)
				plrBtn.BackgroundColor3 = GH.Theme.Card
				plrBtn.Text = ""
				plrBtn.AutoButtonColor = false
				plrBtn.BorderSizePixel = 0
				plrBtn.LayoutOrder = order
				plrBtn.Parent = scroll
				local nameLbl = Instance.new("TextLabel")
				nameLbl.Size = UDim2.new(0.8, 0, 1, 0)
				nameLbl.Position = UDim2.new(0, 8, 0, 0)
				nameLbl.BackgroundTransparency = 1
				nameLbl.Text = player.Name
				nameLbl.TextColor3 = GH.Theme.Text
				nameLbl.Font = Enum.Font.GothamMedium
				nameLbl.TextSize = 11
				nameLbl.TextXAlignment = Enum.TextXAlignment.Left
				nameLbl.Parent = plrBtn
				plrBtn.MouseButton1Click:Connect(function() startFlinging(player) end)
			end
		end
	end

	-- ==========================================
	-- SPASMOS (Animacao do FE Cosmic)
	-- ==========================================
	function Cheats_ToggleSpasmos(state, btn)
		btn.Text = state and "Desativar Spasmos" or "Spasmos"

		-- Limpar animacao anterior
		pcall(function()
			if GH.Cache.SpasmTrack then
				GH.Cache.SpasmTrack:Stop()
				GH.Cache.SpasmTrack:Destroy()
				GH.Cache.SpasmTrack = nil
			end
			if GH.Cache.SpasmAnim then
				GH.Cache.SpasmAnim:Destroy()
				GH.Cache.SpasmAnim = nil
			end
		end)

		if state then
			local char = LocalPlayer.Character
			local hum = char and char:FindFirstChildOfClass("Humanoid")
			if not hum then return end

			-- Limpar tracks antigas do animator
			local animator = hum:FindFirstChildOfClass("Animator")
			if animator then
				for _, track in ipairs(animator:GetPlayingAnimationTracks()) do
					track:Stop(0)
					track:Destroy()
				end
			else
				animator = Instance.new("Animator")
				animator.Parent = hum
			end

			GH.Cache.SpasmAnim = Instance.new("Animation")
			GH.Cache.SpasmAnim.AnimationId = "rbxassetid://33796059"
			GH.Cache.SpasmTrack = animator:LoadAnimation(GH.Cache.SpasmAnim)
			GH.Cache.SpasmTrack.Looped = true
			GH.Cache.SpasmTrack:Play()
			GH.Cache.SpasmTrack:AdjustSpeed(99)
		end
	end

	-- ==========================================
	-- NAKED (Remove todas as roupas)
	-- ==========================================
	function Cheats_ToggleNaked(state, btn)
		btn.Text = state and "Desativar Naked" or "Naked"
		if state then
			local char = LocalPlayer.Character
			if char then
				for _, v in ipairs(char:GetDescendants()) do
					if v:IsA("Clothing") or v:IsA("ShirtGraphic") then
						v:Destroy()
					end
				end
			end
			GH.ShowToast("Roupas removidas!", GH.Theme.On, 2)
		end
	end

	-- ==========================================
	-- FREEZE (Congela todos os jogadores)
	-- ==========================================
	function Cheats_ToggleFreeze(state, btn)
		btn.Text = state and "Desativar Freeze" or "Freeze All"
		if state then
			for _, player in ipairs(Players:GetPlayers()) do
				if player ~= LocalPlayer and player.Character then
					for _, part in ipairs(player.Character:GetDescendants()) do
						if part:IsA("BasePart") and not part.Anchored then
							part.Anchored = true
						end
					end
				end
			end
			GH.ShowToast("Jogadores congelados!", GH.Theme.On, 2)
		else
			for _, player in ipairs(Players:GetPlayers()) do
				if player ~= LocalPlayer and player.Character then
					for _, part in ipairs(player.Character:GetDescendants()) do
						if part:IsA("BasePart") and part.Anchored then
							part.Anchored = false
						end
					end
				end
			end
			GH.ShowToast("Jogadores descongelados!", GH.Theme.Off, 2)
		end
	end

	-- ==========================================
	-- REGISTRAR BOTÕES
	-- ==========================================
	GH.RegisterToggleButton("TrollFling", "Tornado Fling", Cheats_ToggleTrollFling, "Troll", "Gira rapidamente para jogar outros jogadores")
	GH.RegisterToggleButton("TargetFling", "Target Fling", Cheats_ToggleTargetFling, "Troll", "Seleciona um alvo e voa ate ele para derrubar")
	GH.RegisterToggleButton("Spasms", "Spasmos", Cheats_ToggleSpasmos, "Troll", "Animacao de convulsao (requer R6)")
	GH.RegisterToggleButton("Naked", "Naked", Cheats_ToggleNaked, "Troll", "Remove todas as roupas do seu personagem")
	GH.RegisterToggleButton("Freeze", "Freeze All", Cheats_ToggleFreeze, "Troll", "Congela todos os jogadores no servidor")
end
