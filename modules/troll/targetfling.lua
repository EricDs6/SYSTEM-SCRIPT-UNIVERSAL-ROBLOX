-- =============================================================================
-- COMMAND: TARGET FLING
-- Fling em direcao a um jogador alvo
-- =============================================================================
return function(GH)
	local Players = GH.Services.Players
	local RunService = GH.Services.RunService
	local LocalPlayer = GH.LocalPlayer

	GH.Cache.TargetFlingTarget = nil

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
				for _, part in ipairs(char:GetDescendants()) do
					if part:IsA("BasePart") then part.CanCollide = true end
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

			-- Desativar colisao do nosso personagem
			for _, part in ipairs(myChar:GetDescendants()) do
				if part:IsA("BasePart") then part.CanCollide = false end
			end
			myHum.AutoRotate = false

			-- Criar ou manter spin
			local spin = myRoot:FindFirstChild("GH_TargetSpin")
			if not spin then
				spin = Instance.new("AngularVelocity")
				spin.Name = "GH_TargetSpin"
				spin.AngularVelocity = Vector3.new(0, 120, 0)
				spin.MaxTorque = math.huge
				spin.Attachment0 = myRoot:FindFirstChildOfClass("Attachment") or Instance.new("Attachment", myRoot)
				spin.Parent = myRoot
			end

			-- Mover em direcao ao alvo
			local dir = (targetRoot.Position - myRoot.Position)
			local dist = dir.Magnitude

			if dist > 5 then
				-- Voar ate o alvo
				local moveDir = dir.Unit
				local speed = 120
				myRoot.AssemblyLinearVelocity = moveDir * speed + Vector3.new(0, 5, 0)
			else
				-- Perto o suficiente: girar em cima dele
				myRoot.CFrame = myRoot.CFrame:Lerp(
					CFrame.new(targetRoot.Position + Vector3.new(0, -1, 0)),
					0.4
				)
				-- Impulsionar para cima para manter no ar
				myRoot.AssemblyLinearVelocity = Vector3.new(0, 20, 0)
			end
		end)
	end

	GH.RegisterToggleButton("TargetFling", "toggle_targetfling", Cheats_ToggleTargetFling, "Troll", "desc_targetfling")
end
