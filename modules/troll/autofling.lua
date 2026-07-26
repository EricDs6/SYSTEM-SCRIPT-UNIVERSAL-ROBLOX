-- =============================================================================
-- COMMAND: AUTO FLING
-- Vai automaticamente ate os players e aplica walkfling ao colidir
-- =============================================================================
return function(GH)
	local Players = GH.Services.Players
	local RunService = GH.Services.RunService
	local LocalPlayer = GH.LocalPlayer

	GH.Cache.AutoFlingConn = nil
	GH.Cache.AutoFlingDied = nil

	function Cheats_ToggleAutoFling(state, btn)
		-- Parar se ja estiver ativo
		if GH.Cache.AutoFlingConn then
			GH.Cache.AutoFlingConn:Disconnect()
			GH.Cache.AutoFlingConn = nil
		end
		if GH.Cache.AutoFlingDied then
			GH.Cache.AutoFlingDied:Disconnect()
			GH.Cache.AutoFlingDied = nil
		end

		if not state then return end

		local char = LocalPlayer.Character
		local root = char and char:FindFirstChild("HumanoidRootPart")
		local hum = char and char:FindFirstChildOfClass("Humanoid")
		if not root or not hum then return end

		-- Detectar morte
		GH.Cache.AutoFlingDied = hum.Died:Connect(function()
			if GH.States.AutoFling then
				GH.States.AutoFling = false
				local b = GH.Buttons["AutoFling"]
				if b and GH.Callbacks["AutoFling"] then
					pcall(GH.Callbacks["AutoFling"], false, b)
				end
			end
		end)

		local targetIndex = 1
		local movel = 0.1
		local FLY_SPEED = 150

		GH.Cache.AutoFlingConn = RunService.Heartbeat:Connect(function()
			if not GH.States.AutoFling then
				if GH.Cache.AutoFlingConn then
					GH.Cache.AutoFlingConn:Disconnect()
					GH.Cache.AutoFlingConn = nil
				end
				return
			end

			local c = LocalPlayer.Character
			local r = c and c:FindFirstChild("HumanoidRootPart")
			local h = c and c:FindFirstChildOfClass("Humanoid")
			if not r or not r.Parent or not h then return end

			-- Pegar lista de jogadores vivos
			local targets = {}
			for _, player in ipairs(Players:GetPlayers()) do
				if player ~= LocalPlayer and player.Character then
					local tRoot = player.Character:FindFirstChild("HumanoidRootPart")
					local tHum = player.Character:FindFirstChildOfClass("Humanoid")
					if tRoot and tHum and tHum.Health > 0 then
						table.insert(targets, { player = player, root = tRoot })
					end
				end
			end

			if #targets == 0 then return end

			-- Ciclar entre os targets
			if targetIndex > #targets then targetIndex = 1 end
			local target = targets[targetIndex]
			local targetRoot = target.root

			-- Voar ate o alvo
			local dir = (targetRoot.Position - r.Position)
			local dist = dir.Magnitude

			if dist > 3 then
				-- Voar ate proximity
				local moveDir = dir.Unit
				r.Velocity = moveDir * FLY_SPEED + Vector3.new(0, 10, 0)
			else
				-- Perto: aplicar walkfling
				local vel = r.Velocity
				r.Velocity = vel * 10000 + Vector3.new(0, 10000, 0)

				RunService.RenderStepped:Wait()
				if r and r.Parent then
					r.Velocity = vel
				end

				RunService.Stepped:Wait()
				if r and r.Parent then
					r.Velocity = vel + Vector3.new(0, movel, 0)
					movel = movel * -1
				end

				-- Mudar para o proximo player
				targetIndex = targetIndex + 1
			end
		end)
	end

	GH.RegisterToggleButton("AutoFling", "toggle_autofling", Cheats_ToggleAutoFling, "Troll", "desc_autofling")
end
