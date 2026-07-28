-- =============================================================================
-- STATS — Firebase RTDB Online System + Live Indicators
-- =============================================================================
return function(GH, services)
local Players = services.Players
local HttpService = services.HttpService
local MarketplaceService = services.MarketplaceService
local LocalPlayer = GH.LocalPlayer

local FIREBASE_URL = "https://system-script-3b72f-default-rtdb.firebaseio.com/"

-- Detecta a funcao de requisicao HTTP suportada pelo executor
local httprequest = (syn and syn.request) or (http and http.request) or http_request or (fluxus and fluxus.request) or request

GH.Stats = {
	OnlineUsers = 0,
	IsOnline = true,
}

-- ==========================================
-- DISCORD WEBHOOK — JOIN / LEAVE / TELEPORT
-- ==========================================
local DISCORD_WEBHOOK_URL = "https://discord.com/api/webhooks/1530334217723052042/NKbEN44nHaLiUwgYov5NiixxVtCPbvMOf0Gc12KHp1PI9cZYNoBRfJt4MW797h32DkhO"

local gameName = "Desconhecido"
local gameIcon = ""
pcall(function()
	local productInfo = MarketplaceService:GetProductInfo(game.PlaceId)
	gameName = productInfo.Name
	gameIcon = "https://www.roblox.com/asset-thumbnail/image?assetId=" .. tostring(game.PlaceId) .. "&width=420&height=420&format=png"
end)

local function SendDiscordLog(eventType, color)
	if not httprequest or DISCORD_WEBHOOK_URL == "" then return end

	local titleText = ""
	if eventType == "JOIN" then
		titleText = "\xF0\x9F\x9F\xA2 Jogador Injetou o Script!"
	elseif eventType == "LEAVE" then
		titleText = "\xF0\x9F\x94\xB4 Jogador Desconectou!"
	elseif eventType == "TELEPORT" then
		titleText = "\xF0\x9F\x94\x84 Trocando de Experiencia / Servidor"
	end

	local embedData = {
		["embeds"] = {{
			["title"] = titleText,
			["color"] = color,
			["thumbnail"] = { ["url"] = gameIcon },
			["fields"] = {
				{
					["name"] = "\xF0\x9F\x91\xA4 Jogador",
					["value"] = LocalPlayer.Name .. " (@" .. LocalPlayer.DisplayName .. ")\nID: `" .. tostring(LocalPlayer.UserId) .. "`",
					["inline"] = true
				},
				{
					["name"] = "\xF0\x9F\x8E\xAE Experiencia",
					["value"] = gameName .. "\nPlace ID: `" .. tostring(game.PlaceId) .. "`",
					["inline"] = true
				},
				{
					["name"] = "\xF0\x9F\x92\xBB Servidor (JobId)",
					["value"] = "`" .. tostring(game.JobId) .. "`",
					["inline"] = false
				}
			},
			["footer"] = { ["text"] = "System Script v14.0 \xE2\x80\xA2 Presence Tracker" },
			["timestamp"] = DateTime.now():ToIsoDate()
		}}
	}

	task.spawn(function()
		pcall(function()
			httprequest({
				Url = DISCORD_WEBHOOK_URL,
				Method = "POST",
				Headers = { ["Content-Type"] = "application/json" },
				Body = HttpService:JSONEncode(embedData)
			})
		end)
	end)
end

-- URLs do Firebase
local userId = tostring(LocalPlayer.UserId)
local userNodeUrl = FIREBASE_URL .. "online_users/" .. userId .. ".json"
local allUsersUrl = FIREBASE_URL .. "online_users.json"

-- 1. Heartbeat - envia ping e calcula usuarios ativos
local function PulseHeartbeat()
	pcall(function()
		local currentTime = os.time()

		-- Envia ou atualiza a sessao do jogador atual no Firebase
		if httprequest then
			httprequest({
				Url = userNodeUrl,
				Method = "PUT",
				Headers = { ["Content-Type"] = "application/json" },
				Body = HttpService:JSONEncode({
					name = LocalPlayer.Name,
					lastPing = currentTime,
					placeId = game.PlaceId
				})
			})

			-- Busca a lista completa de usuarios registrados no Firebase
			local response = httprequest({
				Url = allUsersUrl,
				Method = "GET"
			})

			if response and response.Body then
				local data = HttpService:JSONDecode(response.Body)
				local activeCount = 0

				if type(data) == "table" then
					for id, userData in pairs(data) do
						-- Considera ativo apenas quem enviou ping nos ultimos 60 segundos
						if userData.lastPing and (currentTime - userData.lastPing) <= 60 then
							activeCount = activeCount + 1
						else
							-- Limpa registros antigos/inativos
							task.spawn(function()
								httprequest({
									Url = FIREBASE_URL .. "online_users/" .. id .. ".json",
									Method = "DELETE"
								})
							end)
						end
					end
				end

				GH.Stats.OnlineUsers = activeCount
			end
		end
	end)
end

-- 2. Limpar registro do jogador quando sair
local function CleanupPlayer()
	pcall(function()
		if httprequest then
			httprequest({
				Url = userNodeUrl,
				Method = "DELETE"
			})
		end
	end)
end

-- Expor CleanupPlayer para GH (usado no FullCleanup)
GH._CleanupPlayer = CleanupPlayer

-- 3. Iniciar sistema Firebase
function GH.Stats.Start()
	-- Discord: Log de Entrada (JOIN) - Verde
	SendDiscordLog("JOIN", 3066993)

	-- Primeiro registro imediato ao injetar
	PulseHeartbeat()
	if GH.UpdateLiveIndicators then GH.UpdateLiveIndicators() end

	-- Loop do Heartbeat a cada 25 segundos
	task.spawn(function()
		while GH.Stats.IsOnline and not GH.Stopped do
			task.wait(25)
			if GH.Stats.IsOnline and not GH.Stopped then
				PulseHeartbeat()
				if GH.UpdateLiveIndicators then GH.UpdateLiveIndicators() end
			end
		end
	end)

	-- Discord: Log de Troca de Mapa / Teleporte - Amarelo
	local queueteleport = (syn and syn.queue_on_teleport) or queue_on_teleport or (fluxus and fluxus.queue_on_teleport)
	if queueteleport then
		LocalPlayer.OnTeleport:Connect(function(State)
			if State == Enum.TeleportState.Started then
				SendDiscordLog("TELEPORT", 16776960)
			end
		end)
	end

	-- Discord: Log de Saida (LEAVE) + Firebase Cleanup - Vermelho
	Players.PlayerRemoving:Connect(function(player)
		if player == LocalPlayer then
			SendDiscordLog("LEAVE", 15158332)
			CleanupPlayer()
		end
	end)

	-- Limpar registro quando o script for destruido
	if script then
		script.Destroying:Connect(function()
			GH.Stats.IsOnline = false
			CleanupPlayer()
		end)
	end
end

-- ==========================================
-- LIVE INDICATOR — Atualizar contadores em tempo real
-- ==========================================
function GH.UpdateLiveIndicators()
	if GH._LiveIndicators and GH._LiveIndicators.OnlineValue then
		GH._LiveIndicators.OnlineValue.Text = tostring(GH.Stats.OnlineUsers)
	end
end

end -- module
