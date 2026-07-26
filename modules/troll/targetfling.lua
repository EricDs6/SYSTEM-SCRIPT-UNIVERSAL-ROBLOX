-- =============================================================================
-- COMMAND: TARGET FLING
-- Fling em direcao a um jogador alvo (logica FE Cosmic)
-- =============================================================================
return function(GH)
	local Players = GH.Services.Players
	local RunService = GH.Services.RunService
	local LocalPlayer = GH.LocalPlayer

	GH.Cache.TargetFlingTarget = nil
	GH.Cache.TargetFlingDied = nil

	function Cheats_ToggleTargetFling(state, btn)
		GH.UnregisterMasterLoop("TargetFling")

		if not state then
			if GH.Objects.TargetFlingPicker then
				GH.Objects.TargetFlingPicker.Close()
				GH.Objects.TargetFlingPicker = nil
			end
			GH.Cache.TargetFlingTarget = nil
			-- Restaurar
			pcall(function()
				local char = LocalPlayer.Character
				local hrp = char and char:FindFirstChild("HumanoidRootPart")
				local hum = char and char:FindFirstChildOfClass("Humanoid")
				if hrp then
					local spin = hrp:FindFirstChild("GH_TargetSpin")
					if spin then spin:Destroy() end
					hrp.AssemblyAngularVelocity = Vector3.zero
					hrp.AssemblyLinearVelocity = Vector3.zero
				end
				if hum then hum.AutoRotate = true end
				if char then
					for _, child in pairs(char:GetDescendants()) do
						if child:IsA("BasePart") then
							child.CustomPhysicalProperties = PhysicalProperties.new(0.7, 0.3, 0.5)
							child.Massless = false
							child.CanCollide = true
						end
					end
				end
				if GH.Cache.TargetFlingDied then
					GH.Cache.TargetFlingDied:Disconnect()
					GH.Cache.TargetFlingDied = nil
				end
			end)
			return
		end

		local picker = GH.ShowPlayerPicker(GH.T("dropdown_targetfling_title"), function(name)
			local player = Players:FindFirstChild(name)
			if player then
				GH.Cache.TargetFlingTarget = player
				GH.ShowToast(string.format(GH.T("toast_target_fling"), name), GH.Theme.Red, 2)
			end
		end)
		GH.Objects.TargetFlingPicker = picker

		GH.RegisterMasterLoop("TargetFling", "Heartbeat", function()
			if GH.isClosing or not GH.States.TargetFling then
				GH.UnregisterMasterLoop("TargetFling")
				return
			end

			local target = GH.Cache.TargetFlingTarget
			local myChar = LocalPlayer.Character
			local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
			local myHum = myChar and myChar:FindFirstChildOfClass("Humanoid")
			if not target or not target.Character or not myRoot or not myHum then return end

			local targetRoot = target.Character:FindFirstChild("HumanoidRootPart")
			if not targetRoot then return end

			-- Aplicar PhysicalProperties pesadas (uma vez)
			if not myRoot:GetAttribute("FlingSetup") then
				for _, child in pairs(myChar:GetDescendants()) do
					if child:IsA("BasePart") then
						child.CustomPhysicalProperties = PhysicalProperties.new(100, 0.3, 0.5)
						child.Massless = true
						child.CanCollide = false
					end
				end
				myRoot:SetAttribute("FlingSetup", true)

				-- Detectar morte
				if myHum then
					GH.Cache.TargetFlingDied = myHum.Died:Connect(function()
						if GH.States.TargetFling then
							GH.States.TargetFling = false
							local b = GH.Buttons["TargetFling"]
							if b and GH.Callbacks["TargetFling"] then
								pcall(GH.Callbacks["TargetFling"], false, b)
							end
						end
					end)
				end
			end

			myHum.AutoRotate = false

			-- Criar BodyAngularVelocity pulsante
			local spin = myRoot:FindFirstChild("GH_TargetSpin")
			if not spin then
				spin = Instance.new("BodyAngularVelocity")
				spin.Name = "GH_TargetSpin"
				spin.AngularVelocity = Vector3.new(0, 99999, 0)
				spin.MaxTorque = Vector3.new(0, math.huge, 0)
				spin.P = math.huge
				spin.Parent = myRoot
			end

			-- Mover em direcao ao alvo
			local dir = (targetRoot.Position - myRoot.Position)
			local dist = dir.Magnitude

			if dist > 5 then
				-- Voar ate o alvo
				local moveDir = dir.Unit
				local speed = 120
				myRoot.AssemblyLinearVelocity = moveDir * speed + Vector3.new(0, 15, 0)
			else
				-- Perto: girar em cima dele (pulso)
				myRoot.CFrame = myRoot.CFrame:Lerp(
					CFrame.new(targetRoot.Position + Vector3.new(0, 1, 0)),
					0.4
				)
				myRoot.AssemblyLinearVelocity = Vector3.new(0, 25, 0)
			end

			-- Pulso de velocidade angular
			if spin then
				spin.AngularVelocity = Vector3.new(0, 99999, 0)
			end
		end)
	end

	GH.RegisterToggleButton("TargetFling", "toggle_targetfling", Cheats_ToggleTargetFling, "Troll", "desc_targetfling")
end
