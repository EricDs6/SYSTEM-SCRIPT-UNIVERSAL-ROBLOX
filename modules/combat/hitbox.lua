-- =============================================================================
-- COMMAND: HITBOX
-- Expande a hitbox (HumanoidRootPart) dos jogadores para acertar mais facil
-- Abordagem: direto no Root.Size com visual colorido (estilo FE Cosmic)
-- =============================================================================
return function(GH)
	local Players = GH.Services.Players
	local LocalPlayer = GH.LocalPlayer

	-- Inicializa cache
	GH.Cache = GH.Cache or {}
	GH.Cache.OrigHRPSizes = GH.Cache.OrigHRPSizes or {}

	-- Helper pra detectar se um jogador eh inimigo (mesma logica do player picker)
	local function IsEnemy(player)
		if player == LocalPlayer then return false end
		local myTeam = LocalPlayer.Team
		local pTeam = player.Team
		local pTeamColor = player.TeamColor
		local myTeamColor = myTeam and myTeam.TeamColor or LocalPlayer.TeamColor

		local hasTeams = (myTeam ~= nil) or (myTeamColor and myTeamColor ~= BrickColor.new("Medium stone grey"))
		if hasTeams then
			if pTeam and myTeam and pTeam == myTeam then
				return false -- aliado
			elseif pTeam and myTeam and pTeam ~= myTeam then
				return true -- inimigo
			elseif pTeamColor and myTeamColor and pTeamColor == myTeamColor then
				return false -- aliado (por cor)
			elseif pTeamColor and myTeamColor and pTeamColor ~= myTeamColor then
				return true -- inimigo (por cor)
			end
			-- neutro: nao considera inimigo
			return false
		end
		-- Sem times definidos, todos sao inimigos
		return true
	end

	function Cheats_ToggleHitbox(state, btn)
		-- Restaurar hitboxes originais
		for _, player in ipairs(Players:GetPlayers()) do
			pcall(function()
				if player.Character and GH.Cache.OrigHRPSizes[player] then
					local root = player.Character:FindFirstChild("HumanoidRootPart")
					if root and root:IsA("BasePart") then
						root.Size = GH.Cache.OrigHRPSizes[player]
						root.Transparency = 1
						root.CanCollide = false
					end
				end
			end)
		end
		table.clear(GH.Cache.OrigHRPSizes)

		if state then
			local size = GH.Settings.HitboxSize or 20
			for _, player in ipairs(Players:GetPlayers()) do
				if IsEnemy(player) and player.Character then
					pcall(function()
						local root = player.Character:FindFirstChild("HumanoidRootPart")
						if root and root:IsA("BasePart") then
							if not GH.Cache.OrigHRPSizes[player] then
								GH.Cache.OrigHRPSizes[player] = root.Size
							end
							root.Size = Vector3.new(size, size, size)
							root.Transparency = 0.25
							root.CanCollide = false
							root.Color = Color3.fromRGB(255, 50, 50)
						end
					end)
				end
			end

			-- Manter hitbox com loop (para novos inimigos e respawns)
			GH.RegisterMasterLoop("Hitbox", "Heartbeat", function()
				if GH.isClosing or not GH.States.Hitbox then
					GH.UnregisterMasterLoop("Hitbox")
					return
				end
				local sz = GH.Settings.HitboxSize or 20
				for _, player in ipairs(Players:GetPlayers()) do
					if IsEnemy(player) and player.Character then
						pcall(function()
							local root = player.Character:FindFirstChild("HumanoidRootPart")
							if root and root:IsA("BasePart") then
								if not GH.Cache.OrigHRPSizes[player] then
									GH.Cache.OrigHRPSizes[player] = root.Size
								end
								if root.Size ~= Vector3.new(sz, sz, sz) then
									root.Size = Vector3.new(sz, sz, sz)
									root.Transparency = 0.25
									root.CanCollide = false
									root.Color = Color3.fromRGB(255, 50, 50)
								end
							end
						end)
					end
				end
			end)
		end
	end

	GH.RegisterToggleButton("Hitbox", "toggle_hitbox", Cheats_ToggleHitbox, "Combat", "desc_hitbox")
end
