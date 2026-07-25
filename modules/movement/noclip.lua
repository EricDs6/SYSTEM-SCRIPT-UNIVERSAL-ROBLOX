-- =============================================================================
-- COMMAND: NOCLIP
-- Atravessar paredes e objetos solidos
-- =============================================================================
return function(GH)
	local RunService = GH.Services.RunService
	local LocalPlayer = GH.LocalPlayer

	function Cheats_ToggleNoClip(state, btn)
		GH.Disconnect("Noclip_Stepped")

		-- Restaurar CanCollide de todas as partes
		if not state then
			local char = LocalPlayer.Character
			if char then
				for _, part in ipairs(char:GetDescendants()) do
					if part:IsA("BasePart") then
						pcall(function() part.CanCollide = true end)
					end
				end
			end
			return
		end

		-- Ativar noclip
		GH.Connections.Noclip_Stepped = RunService.Stepped:Connect(function()
			if not GH.States.NoClip then return end
			local char = LocalPlayer.Character
			if char then
				for _, part in ipairs(char:GetDescendants()) do
					if part:IsA("BasePart") then
						part.CanCollide = false
					end
				end
			end
		end)
	end

	GH.RegisterToggleButton("NoClip", "toggle_noclip", Cheats_ToggleNoClip, "Movement", "desc_noclip")
end
