-- =============================================================================
-- COMMAND: ANIMATION PLAYER
-- Reproduz animacoes do Roblox via ID ou link
-- =============================================================================
return function(GH)
	local Players = GH.Services.Players
	local RunService = GH.Services.RunService
	local UserInputService = GH.Services.UserInputService
	local TweenService = GH.Services.TweenService
	local LocalPlayer = GH.LocalPlayer

	local CurrentTrack = nil
	local CurrentAnim = nil
	local CurrentSpeed = 1

	-- Funcao auxiliar para extrair o ID numerico de um link ou texto
	local function ExtractAnimationId(input)
		input = tostring(input)

		-- rbxassetid://123456
		local id = input:match("rbxassetid://(%d+)")
		if id then return id end

		-- roblox.com/library/123456
		id = input:match("roblox%.com/library/(%d+)")
		if id then return id end

		-- roblox.com/catalog/123456
		id = input:match("roblox%.com/catalog/(%d+)")
		if id then return id end

		-- roblox.com/animation/123456
		id = input:match("roblox%.com/animation/(%d+)")
		if id then return id end

		-- ID numerico puro: 123456
		id = input:match("^(%d+)$")
		if id then return id end

		-- Qualquer numero dentro da string
		id = input:match("(%d+)")
		if id then return id end

		return nil
	end

	-- Funcao para parar a animacao atual
	local function StopAnimation()
		if CurrentTrack then
			pcall(function()
				CurrentTrack:Stop()
				CurrentTrack:Destroy()
			end)
			CurrentTrack = nil
		end
		if CurrentAnim then
			pcall(function()
				CurrentAnim:Destroy()
			end)
			CurrentAnim = nil
		end
	end

	-- Funcao principal: Tocar animacao
	local function PlayAnimation(inputUrlOrId, speed, isLooped)
		-- Para qualquer animacao tocada anteriormente
		StopAnimation()

		-- Extrair o ID numerico
		local animId = ExtractAnimationId(inputUrlOrId)
		if not animId then
			return false, GH.T("toast_animplayer_invalid_id")
		end

		-- Verificar personagem
		local char = LocalPlayer.Character
		if not char then
			return false, GH.T("toast_animplayer_no_char")
		end

		local hum = char:FindFirstChildOfClass("Humanoid")
		if not hum then
			return false, GH.T("toast_animplayer_no_humanoid")
		end

		-- Tentar encontrar Animator, senao usar o Humanoid diretamente
		local animator = hum:FindFirstChildOfClass("Animator")
		if not animator then
			animator = hum
		end

		-- Criar objeto Animation
		local anim = Instance.new("Animation")
		anim.AnimationId = "rbxassetid://" .. animId
		CurrentAnim = anim

		-- Carregar a AnimationTrack
		local ok, track = pcall(function()
			return animator:LoadAnimation(anim)
		end)

		if not ok or not track then
			StopAnimation()
			return false, GH.T("toast_animplayer_failed_load")
		end

		CurrentTrack = track

		-- Configurar prioridade
		track.Priority = Enum.AnimationPriority.Action4

		-- Configurar loop
		if isLooped ~= nil then
			track.Looped = isLooped
		else
			track.Looped = false
		end

		-- Tocar a animacao
		track:Play()

		-- Ajustar velocidade
		if speed and tonumber(speed) then
			track:AdjustSpeed(tonumber(speed))
			CurrentSpeed = tonumber(speed)
		end

		return true, GH.T("toast_animplayer_playing", animId)
	end

	-- Funcao para ajustar velocidade da animacao atual
	local function SetSpeed(speed)
		if CurrentTrack and tonumber(speed) then
			CurrentTrack:AdjustSpeed(tonumber(speed))
			CurrentSpeed = tonumber(speed)
			return true
		end
		return false
	end

	-- Funcao para pausar/despausar
	local function TogglePause()
		if CurrentTrack then
			if CurrentTrack.IsPlaying then
				CurrentTrack:AdjustSpeed(0)
				return true, false -- pausado
			else
				CurrentTrack:AdjustSpeed(CurrentSpeed)
				return true, true -- tocando
			end
		end
		return false, nil
	end

	-- ==========================================
	-- TOGGLE BUTTON
	-- ==========================================
	function Cheats_ToggleAnimationPlayer(state, btn)
		if state then
			-- Abrir InputPicker para colar o link/ID
			GH.ShowInputPicker(
				GH.T("input_animplayer_title"),
				GH.T("input_animplayer_placeholder"),
				function(text)
					if text and text ~= "" then
						local success, msg = PlayAnimation(text, 1, false)
						GH.ShowToast(msg, success and GH.Theme.Accent or GH.Theme.Red, 3)

						if not success then
							-- Desativar toggle se falhou
							GH.States.AnimationPlayer = false
							GH.SafeCall("AnimationPlayer", function()
								if btn and btn.SetValue then
									btn:SetValue(false)
								end
							end)
						end
					else
						-- Desativar toggle se nao informou ID
						GH.States.AnimationPlayer = false
						GH.SafeCall("AnimationPlayer", function()
							if btn and btn.SetValue then
								btn:SetValue(false)
							end
						end)
					end
				end
			)
		else
			StopAnimation()
			GH.ShowToast(GH.T("toast_animplayer_stopped"), GH.Theme.Off, 2)
		end
	end

	GH.RegisterToggleButton("AnimationPlayer", "toggle_animplayer", Cheats_ToggleAnimationPlayer, "Utility", "desc_animplayer")

	-- ==========================================
	-- COMANDOS VIA CHAT
	-- ==========================================
	-- !anim <id> - Toca animacao
	-- !anim stop - Para animacao
	-- !anim speed <numero> - Ajusta velocidade
	-- !anim loop <id> - Toca em loop
	-- !anim pause - Pausa/retoma

	local function onChatted(msg)
		local cmd = msg:lower()

		-- Comando: !anim stop
		if cmd:match("^!anim%s+stop$") then
			StopAnimation()
			GH.ShowToast(GH.T("toast_animplayer_stopped"), GH.Theme.Off, 2)
			return
		end

		-- Comando: !anim pause
		if cmd:match("^!anim%s+pause$") then
			local ok, playing = TogglePause()
			if ok then
				GH.ShowToast(
					playing and GH.T("toast_animplayer_resumed") or GH.T("toast_animplayer_paused"),
					GH.Theme.Accent, 2
				)
			end
			return
		end

		-- Comando: !anim speed <numero>
		local speedVal = cmd:match("^!anim%s+speed%s+(%d+%.?%d*)$")
		if speedVal then
			local s = tonumber(speedVal)
			if s and s > 0 and s <= 10 then
				if SetSpeed(s) then
					GH.ShowToast(GH.T("toast_animplayer_speed", tostring(s)), GH.Theme.Accent, 2)
				else
					GH.ShowToast(GH.T("toast_animplayer_no_track"), GH.Theme.Red, 2)
				end
			end
			return
		end

		-- Comando: !anim loop <id>
		local loopId = cmd:match("^!anim%s+loop%s+(.+)$")
		if loopId then
			local success, msg = PlayAnimation(loopId, 1, true)
			GH.ShowToast(msg, success and GH.Theme.Accent or GH.Theme.Red, 3)
			return
		end

		-- Comando: !anim <id> (tocar normal)
		local animId = cmd:match("^!anim%s+(.+)$")
		if animId then
			local success, msg = PlayAnimation(animId, 1, false)
			GH.ShowToast(msg, success and GH.Theme.Accent or GH.Theme.Red, 3)
			return
		end
	end

	LocalPlayer.Chatted:Connect(onChatted)

	-- Expor funcoes para uso externo (ex: outros modulos podem chamar)
	GH.PlayAnimation = PlayAnimation
	GH.StopAnimation = StopAnimation
	GH.SetAnimationSpeed = SetSpeed
end
