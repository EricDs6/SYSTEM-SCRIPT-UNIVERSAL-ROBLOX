-- =============================================================================
-- COMMAND: MIRROR - Espelha o movimento de um jogador
-- =============================================================================
return function(GH)
	local Players = GH.Services.Players
	local RunService = GH.Services.RunService
	local LocalPlayer = GH.LocalPlayer

	GH.Cache.MirrorTarget = nil
	GH.Cache.MirrorCenter = nil

	function Cheats_ToggleMirror(state, btn)
		GH.UnregisterMasterLoop("Mirror")

		if not state then
			if GH.Objects.MirrorPicker then
				GH.Objects.MirrorPicker.Close()
				GH.Objects.MirrorPicker = nil
			end
			GH.Cache.MirrorTarget = nil
			GH.Cache.MirrorCenter = nil
			return
		end

		local picker = GH.ShowPlayerPicker(GH.T("dropdown_mirror_title"), function(name)
			local player = Players:FindFirstChild(name)
			if player and player.Character then
				local targetRoot = player.Character:FindFirstChild("HumanoidRootPart")
				local myRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
				if targetRoot and myRoot then
					GH.Cache.MirrorTarget = player
					-- Define o centro do espelho entre os dois jogadores
					GH.Cache.MirrorCenter = (myRoot.Position + targetRoot.Position) / 2
					GH.ShowToast(string.format("Espelhando %s", name), GH.Theme.Accent, 2)
				end
			end
		end)
		GH.Objects.MirrorPicker = picker

		GH.RegisterMasterLoop("Mirror", "Render", function()
			local target = GH.Cache.MirrorTarget
			local center = GH.Cache.MirrorCenter
			if not target or not target.Character or not center then return end

			local targetRoot = target.Character:FindFirstChild("HumanoidRootPart")
			local myRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
			if not targetRoot or not myRoot then return end

			-- Calcula posicao espelhada: mirrored = 2 * center - targetPos
			local mirroredPos = 2 * center - targetRoot.Position

			-- Teleporta para a posicao espelhada mantendo a altura original
			myRoot.CFrame = CFrame.new(mirroredPos, targetRoot.Position)
		end)
	end

	GH.RegisterToggleButton("Mirror", "toggle_mirror", Cheats_ToggleMirror, "Troll", "desc_mirror")
end
