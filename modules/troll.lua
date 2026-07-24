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

	function Cheats_ToggleTargetFling(state, btn)
		GH.UnregisterMasterLoop("TargetFling")
		GH.Disconnect("TargetFlingRespawn")
		GH.Disconnect("TargetFlingPlayerAdded")
		GH.Disconnect("TargetFlingPlayerRemoving")
		if GH.Objects.TargetFlingDropdown then
			GH.Objects.TargetFlingDropdown:Destroy()
			GH.Objects.TargetFlingDropdown = nil
		end
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

		local function startFlinging(targetPlayer)
			TargetFlingTarget = targetPlayer

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

		local function refreshList()
			local names = {}
			for _, player in ipairs(Players:GetPlayers()) do
				if player ~= LocalPlayer then
					table.insert(names, player.Name)
				end
			end
			if GH.Objects.TargetFlingDropdown then
				GH.Objects.TargetFlingDropdown:SetValues(names)
			end
		end

		local dropdown = GH.Tabs["Troll"]:AddDropdown("TargetFling_Select", {
			Title = "Target Fling - Selecionar Alvo",
			Values = {},
			AllowNull = true,
		})
		GH.Objects.TargetFlingDropdown = dropdown

		dropdown:OnChanged(function(name)
			if name then
				local player = Players:FindFirstChild(name)
				if player then
					startFlinging(player)
				end
			end
		end)

		refreshList()
		GH.Connections.TargetFlingPlayerAdded = Players.PlayerAdded:Connect(function()
			if GH.States.TargetFling then refreshList() end
		end)
		GH.Connections.TargetFlingPlayerRemoving = Players.PlayerRemoving:Connect(function()
			if GH.States.TargetFling then refreshList() end
		end)
	end

	-- ==========================================
	-- SPASMOS (Animacao do FE Cosmic)
	-- ==========================================
	function Cheats_ToggleSpasmos(state, btn)

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
