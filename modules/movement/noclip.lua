-- =============================================================================
-- COMMAND: NOCLIP
-- Atravessar paredes e objetos solidos
-- Abordagem: Stepped direto (estilo FE Cosmic)
-- =============================================================================
return function(GH)
	local Players = GH.Services.Players
	local RunService = GH.Services.RunService
	local LocalPlayer = GH.LocalPlayer

	local Clip = true
	local Noclipping = nil
	local NoclipParts = {}

	function Cheats_ToggleNoClip(state, btn)
		-- Desconectar anterior
		if Noclipping then
			pcall(function() Noclipping:Disconnect() end)
			Noclipping = nil
		end

		-- Restaurar CanCollide
		Clip = true
		for child, _ in pairs(NoclipParts) do
			if typeof(child) == "Instance" and child:IsA("BasePart") and child.Parent then
				pcall(function() child.CanCollide = true end)
			end
		end
		NoclipParts = {}

		if state then
			Clip = false
			Noclipping = RunService.Stepped:Connect(function()
				if Clip == false then
					local char = LocalPlayer.Character
					if char then
						for _, child in pairs(char:GetDescendants()) do
							if child:IsA("BasePart") and child.CanCollide == true then
								child.CanCollide = false
								NoclipParts[child] = true
							end
						end
					end
				end
			end)
		end

		GH.ShowToast(state and ("NoClip " .. GH.T("toast_activated")) or ("NoClip " .. GH.T("toast_deactivated")), state and GH.Theme.On or GH.Theme.Off, 2)
	end

	GH.RegisterToggleButton("NoClip", "toggle_noclip", Cheats_ToggleNoClip, "Movement", "desc_noclip")
end
