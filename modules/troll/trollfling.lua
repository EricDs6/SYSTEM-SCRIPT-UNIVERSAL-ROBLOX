-- =============================================================================
-- COMMAND: TrollFling
-- Logica do FE Cosmic: BodyAngularVelocity pulsante + PhysicalProperties pesadas
-- =============================================================================
return function(GH)
	local Players = GH.Services.Players
	local RunService = GH.Services.RunService
	local LocalPlayer = GH.LocalPlayer

	GH.Cache.TrollFlingDied = nil

	function Cheats_ToggleTrollFling(state, btn)
		GH.UnregisterMasterLoop("TrollFling")

		local char = LocalPlayer.Character
		local hrp = char and char:FindFirstChild("HumanoidRootPart")
		local hum = char and char:FindFirstChildOfClass("Humanoid")

		if state and hrp and hum then
			-- Aplicar PhysicalProperties pesadas em todas as partes
			for _, child in pairs(char:GetDescendants()) do
				if child:IsA("BasePart") then
					child.CustomPhysicalProperties = PhysicalProperties.new(100, 0.3, 0.5)
				end
			end

			hum.AutoRotate = false

			-- Criar BodyAngularVelocity (pulso)
			local oldSpin = hrp:FindFirstChild("GH_TrollSpin")
			if oldSpin then oldSpin:Destroy() end

			local spinForce = Instance.new("BodyAngularVelocity")
			spinForce.Name = "GH_TrollSpin"
			spinForce.AngularVelocity = Vector3.new(0, 99999, 0)
			spinForce.MaxTorque = Vector3.new(0, math.huge, 0)
			spinForce.P = math.huge
			spinForce.Parent = hrp

			-- Desativar colisao e massless
			for _, v in pairs(char:GetChildren()) do
				if v:IsA("BasePart") then
					v.CanCollide = false
					v.Massless = true
					v.Velocity = Vector3.zero
				end
			end

			-- Detectar morte
			GH.Cache.TrollFlingDied = hum.Died:Connect(function()
				if GH.States.TrollFling then
					GH.States.TrollFling = false
					local b = GH.Buttons["TrollFling"]
					if b and GH.Callbacks["TrollFling"] then
						pcall(GH.Callbacks["TrollFling"], false, b)
					end
				end
			end)

			-- Loop de pulso (99999 -> 0 -> 99999)
			GH.RegisterMasterLoop("TrollFling", "Heartbeat", function()
				if GH.isClosing or not GH.States.TrollFling then
					GH.UnregisterMasterLoop("TrollFling")
					-- Restaurar
					local c = LocalPlayer.Character
					local h = c and c:FindFirstChildOfClass("Humanoid")
					local r = c and c:FindFirstChild("HumanoidRootPart")
					if h then h.AutoRotate = true end
					if r then
						local spin = r:FindFirstChild("GH_TrollSpin")
						if spin then spin:Destroy() end
						r.AssemblyAngularVelocity = Vector3.zero
					end
					if c then
						for _, child in pairs(c:GetDescendants()) do
							if child:IsA("BasePart") then
								child.CustomPhysicalProperties = PhysicalProperties.new(0.7, 0.3, 0.5)
								child.Massless = false
							end
						end
					end
					return
				end

				local c = LocalPlayer.Character
				local r = c and c:FindFirstChild("HumanoidRootPart")
				if not r then return end

				local spin = r:FindFirstChild("GH_TrollSpin")
				if spin then
					-- Pulso: alterna entre girando e parado
					spin.AngularVelocity = Vector3.new(0, 99999, 0)
					task.wait(0.2)
					if spin and spin.Parent then
						spin.AngularVelocity = Vector3.new(0, 0, 0)
					end
					task.wait(0.1)
				end

				-- Manter no ar
				r.AssemblyLinearVelocity = Vector3.new(r.AssemblyLinearVelocity.X, 3, r.AssemblyLinearVelocity.Z)
			end)
		else
			if hum then hum.AutoRotate = true end
			if hrp then
				local spin = hrp:FindFirstChild("GH_TrollSpin")
				if spin then spin:Destroy() end
				hrp.AssemblyAngularVelocity = Vector3.zero
			end
			-- Restaurar propriedades
			if char then
				for _, child in pairs(char:GetDescendants()) do
					if child:IsA("BasePart") then
						child.CustomPhysicalProperties = PhysicalProperties.new(0.7, 0.3, 0.5)
						child.Massless = false
					end
				end
			end
			if GH.Cache.TrollFlingDied then
				GH.Cache.TrollFlingDied:Disconnect()
				GH.Cache.TrollFlingDied = nil
			end
		end
	end

	GH.RegisterToggleButton("TrollFling", "toggle_trollfling", Cheats_ToggleTrollFling, "Troll", "desc_trollfling")
end
