-- =============================================================================
-- COMMAND: ANCHOR (Se Ancorar)
-- =============================================================================
return function(GH)
	local Players = GH.Services.Players
	local RunService = GH.Services.RunService
	local LocalPlayer = GH.LocalPlayer

	local anchorConn = nil

	function Cheats_ToggleAnchor(state, btn)
		if state then
			GH.Cache.OrigAnchorStates = {}
			GH.Cache.OrigAnchorPlatformStand = false
			GH.Cache.OrigAnchorAutoRotate = true

			local function anchorCharacter(char)
				local hrp = char:WaitForChild("HumanoidRootPart", 5)
				local hum = char:WaitForChild("Humanoid", 5)
				if not hrp or not hum then return end

				-- Salvar estado original
				GH.Cache.OrigAnchorPlatformStand = hum.PlatformStand
				GH.Cache.OrigAnchorAutoRotate = hum.AutoRotate

				for _, part in ipairs(char:GetDescendants()) do
					if part:IsA("BasePart") then
						GH.Cache.OrigAnchorStates[part] = {
							Anchored = part.Anchored,
							CanCollide = part.CanCollide,
						}
						part.Anchored = true
					end
				end

				hum.PlatformStand = true
				hum.AutoRotate = false
			end

			if LocalPlayer.Character then
				anchorCharacter(LocalPlayer.Character)
			end

			anchorConn = LocalPlayer.CharacterAdded:Connect(function(char)
				if not GH.States.Anchor then return end
				task.wait(0.5)
				anchorCharacter(char)
			end)
		else
			-- Restaurar
			if anchorConn then
				pcall(function() anchorConn:Disconnect() end)
				anchorConn = nil
			end

			local char = LocalPlayer.Character
			if char then
				local hrp = char:FindFirstChild("HumanoidRootPart")
				local hum = char:FindFirstChildOfClass("Humanoid")

				for _, part in ipairs(char:GetDescendants()) do
					if part:IsA("BasePart") then
						local orig = GH.Cache.OrigAnchorStates and GH.Cache.OrigAnchorStates[part]
						if orig then
							part.Anchored = orig.Anchored
							part.CanCollide = orig.CanCollide
						else
							part.Anchored = false
						end
					end
				end

				if hum then
					hum.PlatformStand = GH.Cache.OrigAnchorPlatformStand or false
					hum.AutoRotate = GH.Cache.OrigAnchorAutoRotate or true
				end

				if hrp then
					hrp.AssemblyLinearVelocity = Vector3.zero
					hrp.AssemblyAngularVelocity = Vector3.zero
				end
			end

			GH.Cache.OrigAnchorStates = {}
		end
	end

	GH.RegisterToggleButton("Anchor", "toggle_anchor", Cheats_ToggleAnchor, "Utility", "desc_anchor")
end
