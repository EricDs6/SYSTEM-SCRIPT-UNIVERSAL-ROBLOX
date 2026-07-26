-- =============================================================================
-- COMMAND: VOICE AUDIO
-- Toca audio no voice do Roblox via link
-- =============================================================================
return function(GH)
	local Players = GH.Services.Players
	local RunService = GH.Services.RunService
	local UserInputService = GH.Services.UserInputService
	local TweenService = GH.Services.TweenService
	local HttpService = GH.Services.HttpService
	local LocalPlayer = GH.LocalPlayer

	local activeSound = nil
	local currentUrl = ""

	local function stopAudio()
		if activeSound then
			pcall(function()
				activeSound:Stop()
				activeSound:Destroy()
			end)
			activeSound = nil
		end
	end

	local function playAudio(url, volume)
		stopAudio()

		if not url or url == "" then
			GH.ShowToast(GH.T("toast_voiceaudio_no_url"), GH.Theme.Red)
			return false
		end

		-- Converter links do Roblox para asset ID
		local assetId = nil

		-- Link direto de audio (.mp3, .ogg, .wav)
		if url:match("%.mp3$") or url:match("%.ogg$") or url:match("%.wav$") then
			-- Usar URL direta (funciona em executores com suporte)
			assetId = url
		-- Link de asset do Roblox (rbxassetid:// ou roblox.com/library)
		elseif url:match("rbxassetid://(%d+)") then
			assetId = url:match("rbxassetid://(%d+)")
		elseif url:match("roblox%.com/library/(%d+)") then
			assetId = url:match("roblox%.com/library/(%d+)")
		elseif url:match("roblox%.com/catalog/(%d+)") then
			assetId = url:match("roblox%.com/catalog/(%d+)")
		-- ID numerico puro
		elseif url:match("^%d+$") then
			assetId = url
		else
			assetId = url
		end

		local char = LocalPlayer.Character
		if not char then
			GH.ShowToast(GH.T("toast_voiceaudio_no_char"), GH.Theme.Red)
			return false
		end

		local hrp = char:FindFirstChild("HumanoidRootPart")
		if not hrp then
			GH.ShowToast(GH.T("toast_voiceaudio_no_char"), GH.Theme.Red)
			return false
		end

		local sound = Instance.new("Sound")
		sound.Name = "GH_VoiceAudio"

		-- Definir o link do audio
		if assetId:match("^rbxassetid://") or assetId:match("^%d+$") then
			local id = assetId:match("(%d+)")
			sound.SoundId = "rbxassetid://" .. id
		else
			sound.SoundId = assetId
		end

		sound.Volume = volume or 1
		sound.Looped = false
		sound.PlaybackSpeed = 1
		sound.RollOffMaxDistance = 100
		sound.RollOffMinDistance = 10
		sound.RollOffMode = Enum.RollOffMode.Inverse
		sound.Parent = hrp

		sound.Ended:Connect(function()
			if activeSound == sound then
				activeSound = nil
				GH.States.VoiceAudio = false
				GH.SafeCall("VoiceAudio", function()
					local btn = GH.Buttons["VoiceAudio"]
					if btn and btn.Callback then
						GH.Callbacks["VoiceAudio"](false, btn)
					end
				end)
			end
		end)

		sound:Play()
		activeSound = sound
		currentUrl = url

		GH.ShowToast(GH.T("toast_voiceaudio_playing"), GH.Theme.Accent)
		return true
	end

	local function toggleVoiceAudio(state, btn)
		if state then
			-- Pedir URL ao ativar
			GH.ShowInputPicker(
				GH.T("input_voiceaudio_title"),
				GH.T("input_voiceaudio_placeholder"),
				function(url)
					if url and url ~= "" then
						playAudio(url, 1)
					else
						-- Desativar se nao informou URL
						GH.States.VoiceAudio = false
						GH.SafeCall("VoiceAudio", function()
							if btn and btn.Callback then
								btn.Callback(false, btn)
							end
						end)
					end
				end
			)
		else
			stopAudio()
			currentUrl = ""
		end
	end

	GH.RegisterToggleButton("VoiceAudio", "toggle_voiceaudio", toggleVoiceAudio, "Utility", "desc_voiceaudio")

	-- Comando via chat: !audio <url>
	local function onChatted(msg)
		local command = msg:lower():match("^!audio%s+(.+)")
		if command then
			playAudio(command, 1)
		end
	end

	LocalPlayer.Chatted:Connect(onChatted)
end
