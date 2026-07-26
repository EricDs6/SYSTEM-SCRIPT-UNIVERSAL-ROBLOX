-- =============================================================================
-- COMMAND: WALK FLING
-- Fling ao caminhar (logica FE Cosmic) - sem girar, so andar
-- =============================================================================
return function(GH)
	local RunService = GH.Services.RunService
	local LocalPlayer = GH.LocalPlayer

	GH.Cache.WalkFlingDied = nil
	GH.Cache.WalkFlingConn = nil

	function Cheats_ToggleWalkFling(state, btn)
		-- Parar se ja estiver ativo
		if GH.Cache.WalkFlingConn then
			GH.Cache.WalkFlingConn:Disconnect()
			GH.Cache.WalkFlingConn = nil
		end
		if GH.Cache.WalkFlingDied then
			GH.Cache.WalkFlingDied:Disconnect()
			GH.Cache.WalkFlingDied = nil
		end

		if not state then return end

		local char = LocalPlayer.Character
		local root = char and char:FindFirstChild("HumanoidRootPart")
		local hum = char and char:FindFirstChildOfClass("Humanoid")
		if not root or not hum then return end

		-- Detectar morte
		GH.Cache.WalkFlingDied = hum.Died:Connect(function()
			if GH.States.WalkFling then
				GH.States.WalkFling = false
				local b = GH.Buttons["WalkFling"]
				if b and GH.Callbacks["WalkFling"] then
					pcall(GH.Callbacks["WalkFling"], false, b)
				end
			end
		end)

		local movel = 0.1

		-- Logica FE Cosmic: pulso de velocidade a cada frame
		GH.Cache.WalkFlingConn = RunService.Heartbeat:Connect(function()
			if not GH.States.WalkFling then
				if GH.Cache.WalkFlingConn then
					GH.Cache.WalkFlingConn:Disconnect()
					GH.Cache.WalkFlingConn = nil
				end
				return
			end

			local c = LocalPlayer.Character
			local r = c and c:FindFirstChild("HumanoidRootPart")
			if not r or not r.Parent then return end

			-- Salvar velocidade atual
			local vel = r.Velocity

			-- Heartbeat: multiplicar velocidade por 10000 + subir
			r.Velocity = vel * 10000 + Vector3.new(0, 10000, 0)

			-- RenderStepped: restaurar velocidade
			RunService.RenderStepped:Wait()
			if r and r.Parent then
				r.Velocity = vel
			end

			-- Stepped: alternar +/- movel no Y
			RunService.Stepped:Wait()
			if r and r.Parent then
				r.Velocity = vel + Vector3.new(0, movel, 0)
				movel = movel * -1
			end
		end)
	end

	GH.RegisterToggleButton("WalkFling", "toggle_walkfling", Cheats_ToggleWalkFling, "Troll", "desc_walkfling")
end
