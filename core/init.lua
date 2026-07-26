-- =============================================================================
-- CORE — Sistema compartilhado entre todos os módulos (GUI Custom Win11)
-- =============================================================================
--!nonstrict

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local Lighting = game:GetService("Lighting")
local LocalPlayer = Players.LocalPlayer

-- ==========================================
-- GH: Tabela compartilhada entre todos os módulos
-- ==========================================
local GH = {}

-- ==========================================
-- LOCALES (PT/EN/ES)
-- ==========================================
GH.Locales = {
	pt = {
		-- Settings
		settings_config = "Configuracoes",
		settings_language = "Idioma",
		settings_debug_mode = "Debug Mode",
		settings_show_distance = "Mostrar Distancia",
		settings_show_health = "Mostrar Vida",
		settings_show_tag = "Mostrar Tag",
		settings_show_name = "Mostrar Nome",
		settings_hitbox_size = "Tamanho Hitbox",
		settings_esp_max_distance = "Distancia Max ESP",
		settings_noclip_radius = "Raio NoClip",
		settings_fly_speed = "Velocidade Fly",
		-- Stats
		stats_section = "Estatisticas",
		stats_online = "Usuarios Online",
		stats_injections = "Injecoes Totais",
		stats_device = "Meu Device",
		stats_status = "Status",
		stats_active = "Ativo",
		-- Update info
		update_section = "Atualizacao",
		update_version = "Versao",
		update_date = "Data da Atualizacao",
		update_loading = "Carregando...",
		update_error = "Erro ao buscar",
		-- Toasts
		toast_activated = "Ativado!",
		toast_deactivated = "Desativado!",
		toast_script_loaded = "Script carregado com sucesso!",
		toast_new_update = "Nova atualizacao disponivel! Reinjecte para atualizar",
		toast_debug_failed = "DEBUG: %s falhou",
		-- ESP
		esp_enemy = "[INIMIGO]",
		esp_ally = "[ALIADO]",
		esp_neutral = "[JOGADOR]",
		-- Toggle titles
		toggle_hitbox = "Hitbox Gigante",
		toggle_esp = "Ativar ESP",
		toggle_crawl = "Rastejar",
		toggle_triggerbot = "TriggerBot",
		toggle_silentaim = "Silent Aim",
		toggle_nofling = "No Fling",
		toggle_wallbang = "Wall Bang",
		toggle_infinitehealth = "Infinite Health",
		toggle_killaura = "Kill Aura",
		toggle_nofalldamage = "No Fall Damage",
		toggle_headsize = "Head Size",
		toggle_fly = "Ativar Fly",
		toggle_noclip = "Ativar NoClip",
		toggle_sprint = "Sprint (Shift)",
		toggle_speed = "Speed Hack",
		toggle_infinitejump = "Infinite Jump",
		toggle_bunnyhop = "Bunny Hop",
		toggle_teleportplayer = "TP para Player",
		toggle_blink = "Blink (Q)",
		toggle_vehiclespeed = "Vehicle Speed",
		toggle_nojumpcooldown = "No Jump Cooldown",
		toggle_float = "Float",
		toggle_swim = "Swim",
		toggle_vehiclegoto = "Vehicle Goto",
		toggle_walkto = "Walk To",
		toggle_orbit = "Orbit",
		toggle_headsit = "HeadSit",
		toggle_vehiclefly = "Vehicle Fly",
		toggle_spectate = "Spectate",
		toggle_gotopart = "Goto Part",
		toggle_xray = "X-Ray (Paredes)",
		toggle_nightmode = "Night Mode",
		toggle_fullbright = "Fullbright",
		toggle_tracers = "Tracers",
		toggle_crosshair = "Custom Crosshair",
		toggle_fovchanger = "FOV Changer",
		toggle_clicktp = "Tool TP Click",
		toggle_gravity = "Gravity Baixa",
		toggle_customspawn = "Marcar Spawn",
		toggle_freecam = "Freecam",
		toggle_thirdperson = "Third Person",
		toggle_flashback = "Flashback",
		toggle_coords = "Coordenadas",
		toggle_serverrejoin = "Server Rejoin",
		toggle_anchor = "Se Ancorar",
		toggle_autoclicker = "Auto-Clicker",
		toggle_proximityinstant = "Proximity Instant",
		toggle_antiafk = "Anti-AFK",
		toggle_antikick = "Anti-Kick",
		toggle_autocollect = "Auto Collect",
		toggle_fireclickdetectors = "Fire Click Detectors",
		toggle_fireproximityprompts = "Fire Proximity Prompts",
		toggle_btools = "BTools",
		toggle_breakvelocity = "Break Velocity",
		toggle_invisibleparts = "Invisible Parts",
		toggle_voiceaudio = "Voice Audio (Link)",
		toggle_tptovehicle = "TP para Veiculo",
		toggle_noplayercollide = "Sem Colisao com Players",
		toggle_forcepush = "Force Push (Defesa)",
		toggle_trollfling = "Tornado Fling",
		toggle_targetfling = "Target Fling",
		toggle_spasms = "Spasmos",
		toggle_naked = "Naked",
		toggle_freeze = "Freeze All",
		toggle_pushall = "Push All",
		-- Toggle descriptions
		desc_hitbox = "Expande a hitbox dos inimigos para acertar mais facil",
		desc_esp = "Mostra nomes, vida e distancia dos jogadores atraves de paredes",
		desc_triggerbot = "Atira automaticamente quando mira no inimigo",
		desc_silentaim = "Redireciona tiros para o jogador mais proximo do cursor",
		desc_nofling = "Impede que voce seja jogado por exploits de fling",
		desc_wallbang = "Permite atirar atraves de paredes e objeitos",
		desc_infinitehealth = "Mantem sua vida sempre no maximo",
		desc_killaura = "Ataca automaticamente jogadores proximos",
		desc_nofalldamage = "Remove dano de queda",
		desc_headsize = "Amplia cabeca de jogadores para acertar mais facil",
		desc_fly = "Voar pelo mapa com WASD. Scroll ajusta velocidade",
		desc_noclip = "Atravessar paredes e objeitos solidos",
		desc_sprint = "Correr mais segurando a tecla Shift",
		desc_speed = "Aumenta a velocidade de caminhada",
		desc_infinitejump = "Pular infinitas vezes no ar",
		desc_bunnyhop = "Pular continuamente ao correr",
		desc_teleportplayer = "Seleciona um player para teleportar ate ele",
		desc_blink = "Dash rapido na direcao que olha. Tecla Q",
		desc_vehiclespeed = "Aumenta velocidade e torqu de veiculos",
		desc_nojumpcooldown = "Remove cooldown de pulo, pula sem parar",
		desc_float = "Plataforma voadora. Q desce, E sobe",
		desc_swim = "Natacao no ar, gravedade zero",
		desc_vehiclegoto = "Teleporta seu veiculo para um jogador",
		desc_walkto = "Segue um jogador automaticamente",
		desc_orbit = "Gira ao redor de um jogador",
		desc_headsit = "Senta na cabeca de um jogador",
		desc_vehiclefly = "Voar dirigindo veiculos. WASD+QE",
		desc_spectate = "Camera segue um jogador selecionado",
		desc_gotopart = "Teleporta para uma parte pelo nome",
		desc_crawl = "Faz o personagem rastejar no chao",
		desc_xray = "Veja atraves de paredes e objeitos",
		desc_nightmode = "Escurece o ambiente para ver melhor",
		desc_fullbright = "Iluminacao maxima, nada de sombras",
		desc_tracers = "Linhas que apontam para jogadores",
		desc_crosshair = "Mira personalizada no centro da tela",
		desc_fovchanger = "Aumenta ou diminui o campo de visao",
		desc_clicktp = "Ferramenta para teleportar clicando no chao",
		desc_gravity = "Gravidade reduzida para pular alto",
		desc_customspawn = "Marca posicao para renascer automaticamente",
		desc_freecam = "Camera livre para explorar o mapa. WASD+QE+Mouse",
		desc_thirdperson = "Forca visao em terceira pessoa com camera afastada",
		desc_flashback = "Pressione P para voltar ao local da ultima morte",
		desc_coords = "Mostra coordenadas atuais e salva posicoes",
		desc_serverrejoin = "Reconecta ao mesmo servidor",
		desc_anchor = "Ancora seu personagem no lugar, impedindo movimento",
		desc_autoclicker = "Clique automatico segurando a tecla X",
		desc_proximityinstant = "Interacao instantanea com prompts sem segurar",
		desc_antiafk = "Impede ser desconectado por inatividade",
		desc_antikick = "Impede ser expulso do servidor",
		desc_autocollect = "Coleta automaticamente tools e itens proximos",
		desc_fireclickdetectors = "Ativa todos os ClickDetectors do mapa",
		desc_fireproximityprompts = "Ativa todos os ProximityPrompts do mapa",
		desc_btools = "Ferramentas de construcao (HopperBins)",
		desc_breakvelocity = "Reseta toda velocidade do personagem",
		desc_invisible_parts = "Mostra partes que estao invisiveis no mapa",
		desc_voiceaudio = "Toca audio no voice do Roblox via link. Comando: !audio <url>",
		desc_tptovehicle = "Mostra lista de veiculos e teleporta direto para o piloto",
		desc_noplayercollide = "Remove colisao com outros jogadores, passe atraves deles",
		desc_forcepush = "Empurra jogadores proximos automaticamente (defesa contra flingers)",
		desc_trollfling = "Gira rapidamente para jogar outros jogadores",
		desc_targetfling = "Seleciona um alvo e voa ate ele para derrubar",
		desc_spasms = "Animacao de convulsao (requer R6)",
		desc_naked = "Remove todas as roupas do seu personagem",
		desc_freeze = "Congela todos os jogadores no servidor",
		desc_pushall = "Empurra todos os jogadores proximos com forca",
		-- Dropdown titles
		dropdown_select_player = "Selecionar Player",
		dropdown_select_target = "Selecionar Alvo",
		dropdown_headsize_title = "Head Size - Selecionar Player",
		dropdown_tpplayer_title = "TP para Player - Selecionar",
		dropdown_vehiclegoto_title = "Vehicle Goto - Selecionar Player",
		dropdown_walkto_title = "Walk To - Selecionar Player",
		dropdown_orbit_title = "Orbit - Selecionar Player",
		dropdown_headsit_title = "HeadSit - Selecionar Player",
		dropdown_spectate_title = "Spectate - Selecionar Player",
		dropdown_targetfling_title = "Target Fling - Selecionar Alvo",
		input_gotopart_title = "Goto Part - Nome da Parte",
		input_gotopart_placeholder = "Digite o nome...",
		-- Coords section
		section_coords = "Coordenadas",
		coords_current = "Posicao Atual",
		coords_save = "Salvar Posicao",
		coords_saved = "Pontos Salvos",
		coords_tp = "TP para Ponto Selecionado",
		coords_point_prefix = "Ponto ",
		-- Toasts (dynamic)
		toast_head_amplified = "Head de %s ampliada!",
		toast_tp_to = "TP para %s",
		toast_vehicle_to = "Vehicle -> %s",
		toast_target_fling = "Target Fling: %s",
		toast_position_saved = "Posicao salva!",
		toast_flashback = "Flashback!",
		toast_fov = "FOV: 90",
		toast_anti_kick_no_hook = "Anti-Kick: hookfunction nao disponivel",
		toast_anti_kick = "Anti-Kick ativado",
		toast_click_detectors = "Click Detectors ativados!",
		toast_proximity_prompts = "Proximity Prompts ativados!",
		toast_btools = "BTools ativados!",
		toast_voiceaudio_playing = "Tocando audio no voice!",
		toast_voiceaudio_no_url = "Nenhum link de audio informado",
		toast_voiceaudio_no_char = "Personagem nao encontrado",
		input_voiceaudio_title = "Voice Audio - Link do Audio",
		input_voiceaudio_placeholder = "Cole o link do audio...",
		toast_tptovehicle_tp = "TP para %s",
		toast_tptovehicle_notfound = "Nenhum veiculo encontrado",
		input_tptovehicle_title = "TP para Veiculo",
		input_tptovehicle_placeholder = "Procurar veiculo...",
		toast_velocity_reset = "Velocity resetado!",
		toast_invisible_shown = "%s partes invisiveis mostradas",
		toast_clothes_removed = "Roupas removidas!",
		toast_players_frozen = "Jogadores congelados!",
		toast_players_unfrozen = "Jogadores descongelados!",
		-- Loader
		load_system_init = "SYSTEM INITIALIZING",
		load_connecting = "Connecting to GitHub...",
		load_downloading = "Baixando: %s",
		load_loading_core = "Carregando Core...",
		load_error_core = "Erro Critico no Core!",
		load_ready = "Tudo pronto! Iniciando...",
	},
	en = {
		-- Settings
		settings_config = "Settings",
		settings_language = "Language",
		settings_debug_mode = "Debug Mode",
		settings_show_distance = "Show Distance",
		settings_show_health = "Show Health",
		settings_show_tag = "Show Tag",
		settings_show_name = "Show Name",
		settings_hitbox_size = "Hitbox Size",
		settings_esp_max_distance = "Max ESP Distance",
		settings_noclip_radius = "NoClip Radius",
		settings_fly_speed = "Fly Speed",
		-- Stats
		stats_section = "Statistics",
		stats_online = "Online Users",
		stats_injections = "Total Injections",
		stats_device = "My Device",
		stats_status = "Status",
		stats_active = "Active",
		-- Update info
		update_section = "Update Info",
		update_version = "Version",
		update_date = "Last Update",
		update_loading = "Loading...",
		update_error = "Failed to fetch",
		-- Toasts
		toast_activated = "Enabled!",
		toast_deactivated = "Disabled!",
		toast_script_loaded = "Script loaded successfully!",
		toast_new_update = "New update available! Reinject to update",
		toast_debug_failed = "DEBUG: %s failed",
		-- ESP
		esp_enemy = "[ENEMY]",
		esp_ally = "[ALLY]",
		esp_neutral = "[PLAYER]",
		-- Toggle titles
		toggle_hitbox = "Giant Hitbox",
		toggle_esp = "Enable ESP",
		toggle_crawl = "Crawl",
		toggle_triggerbot = "TriggerBot",
		toggle_silentaim = "Silent Aim",
		toggle_nofling = "No Fling",
		toggle_wallbang = "Wall Bang",
		toggle_infinitehealth = "Infinite Health",
		toggle_killaura = "Kill Aura",
		toggle_nofalldamage = "No Fall Damage",
		toggle_headsize = "Head Size",
		toggle_fly = "Enable Fly",
		toggle_noclip = "Enable NoClip",
		toggle_sprint = "Sprint (Shift)",
		toggle_speed = "Speed Hack",
		toggle_infinitejump = "Infinite Jump",
		toggle_bunnyhop = "Bunny Hop",
		toggle_teleportplayer = "TP to Player",
		toggle_blink = "Blink (Q)",
		toggle_vehiclespeed = "Vehicle Speed",
		toggle_nojumpcooldown = "No Jump Cooldown",
		toggle_float = "Float",
		toggle_swim = "Swim",
		toggle_vehiclegoto = "Vehicle Goto",
		toggle_walkto = "Walk To",
		toggle_orbit = "Orbit",
		toggle_headsit = "HeadSit",
		toggle_vehiclefly = "Vehicle Fly",
		toggle_spectate = "Spectate",
		toggle_gotopart = "Goto Part",
		toggle_xray = "X-Ray (Walls)",
		toggle_nightmode = "Night Mode",
		toggle_fullbright = "Fullbright",
		toggle_tracers = "Tracers",
		toggle_crosshair = "Custom Crosshair",
		toggle_fovchanger = "FOV Changer",
		toggle_clicktp = "Tool TP Click",
		toggle_gravity = "Low Gravity",
		toggle_customspawn = "Set Spawn",
		toggle_freecam = "Freecam",
		toggle_thirdperson = "Third Person",
		toggle_flashback = "Flashback",
		toggle_coords = "Coordinates",
		toggle_serverrejoin = "Server Rejoin",
		toggle_anchor = "Anchor Self",
		toggle_autoclicker = "Auto-Clicker",
		toggle_proximityinstant = "Proximity Instant",
		toggle_antiafk = "Anti-AFK",
		toggle_antikick = "Anti-Kick",
		toggle_autocollect = "Auto Collect",
		toggle_fireclickdetectors = "Fire Click Detectors",
		toggle_fireproximityprompts = "Fire Proximity Prompts",
		toggle_btools = "BTools",
		toggle_breakvelocity = "Break Velocity",
		toggle_invisibleparts = "Invisible Parts",
		toggle_voiceaudio = "Voice Audio (Link)",
		toggle_tptovehicle = "TP to Vehicle",
		toggle_noplayercollide = "No Player Collision",
		toggle_forcepush = "Force Push (Defense)",
		toggle_trollfling = "Tornado Fling",
		toggle_targetfling = "Target Fling",
		toggle_spasms = "Spasms",
		toggle_naked = "Naked",
		toggle_freeze = "Freeze All",
		toggle_pushall = "Push All",
		-- Toggle descriptions
		desc_hitbox = "Expands enemy hitbox for easier hits",
		desc_esp = "Shows names, health and distance through walls",
		desc_triggerbot = "Shoots automatically when aiming at enemy",
		desc_silentaim = "Redirects shots to nearest player to cursor",
		desc_nofling = "Prevents being flung by exploits",
		desc_wallbang = "Allows shooting through walls and objects",
		desc_infinitehealth = "Keeps your health at maximum",
		desc_killaura = "Automatically attacks nearby players",
		desc_nofalldamage = "Removes fall damage",
		desc_headsize = "Enlarges player heads for easier hits",
		desc_fly = "Fly around the map with WASD. Scroll adjusts speed",
		desc_noclip = "Walk through walls and solid objects",
		desc_sprint = "Run faster holding Shift key",
		desc_speed = "Increases walk speed",
		desc_infinitejump = "Jump infinitely in the air",
		desc_bunnyhop = "Jump continuously while running",
		desc_teleportplayer = "Select a player to teleport to them",
		desc_blink = "Quick dash in look direction. Key Q",
		desc_vehiclespeed = "Increases vehicle speed and torque",
		desc_nojumpcooldown = "Removes jump cooldown, jump non-stop",
		desc_float = "Flying platform. Q descends, E ascends",
		desc_swim = "Air swimming, zero gravity",
		desc_vehiclegoto = "Teleport your vehicle to a player",
		desc_walkto = "Follow a player automatically",
		desc_orbit = "Orbit around a player",
		desc_headsit = "Sit on a player's head",
		desc_vehiclefly = "Fly while driving vehicles. WASD+QE",
		desc_spectate = "Camera follows a selected player",
		desc_gotopart = "Teleport to a part by name",
		desc_crawl = "Makes the character crawl on the ground",
		desc_xray = "See through walls and objects",
		desc_nightmode = "Darkens environment for better visibility",
		desc_fullbright = "Maximum brightness, no shadows",
		desc_tracers = "Lines pointing to players",
		desc_crosshair = "Custom crosshair in screen center",
		desc_fovchanger = "Increases or decreases field of view",
		desc_clicktp = "Tool to teleport by clicking the ground",
		desc_gravity = "Reduced gravity for higher jumps",
		desc_customspawn = "Set position to respawn automatically",
		desc_freecam = "Free camera to explore the map. WASD+QE+Mouse",
		desc_thirdperson = "Forces third person view with distant camera",
		desc_flashback = "Press P to return to last death location",
		desc_coords = "Shows current coordinates and saves positions",
		desc_serverrejoin = "Reconnect to the same server",
		desc_anchor = "Anchors your character in place, preventing movement",
		desc_autoclicker = "Auto click holding key X",
		desc_proximityinstant = "Instant interaction with prompts without holding",
		desc_antiafk = "Prevents disconnection for inactivity",
		desc_antikick = "Prevents being kicked from server",
		desc_autocollect = "Automatically collects nearby tools and items",
		desc_fireclickdetectors = "Activates all ClickDetectors on map",
		desc_fireproximityprompts = "Activates all ProximityPrompts on map",
		desc_btools = "Building tools (HopperBins)",
		desc_breakvelocity = "Resets all character velocity",
		desc_invisible_parts = "Shows invisible parts on map",
		desc_voiceaudio = "Plays audio in Roblox voice via link. Command: !audio <url>",
		desc_tptovehicle = "Shows vehicle list and teleports directly to the pilot",
		desc_noplayercollide = "Removes collision with other players, walk through them",
		desc_forcepush = "Pushes nearby players away automatically (defense against flingers)",
		desc_trollfling = "Spins rapidly to fling other players",
		desc_targetfling = "Select a target and fly to them to knock down",
		desc_spasms = "Convulsion animation (requires R6)",
		desc_naked = "Removes all clothes from your character",
		desc_freeze = "Freezes all players in the server",
		desc_pushall = "Pushes all nearby players away with force",
		-- Dropdown titles
		dropdown_select_player = "Select Player",
		dropdown_select_target = "Select Target",
		dropdown_headsize_title = "Head Size - Select Player",
		dropdown_tpplayer_title = "TP to Player - Select",
		dropdown_vehiclegoto_title = "Vehicle Goto - Select Player",
		dropdown_walkto_title = "Walk To - Select Player",
		dropdown_orbit_title = "Orbit - Select Player",
		dropdown_headsit_title = "HeadSit - Select Player",
		dropdown_spectate_title = "Spectate - Select Player",
		dropdown_targetfling_title = "Target Fling - Select Target",
		input_gotopart_title = "Goto Part - Part Name",
		input_gotopart_placeholder = "Type the name...",
		-- Coords section
		section_coords = "Coordinates",
		coords_current = "Current Position",
		coords_save = "Save Position",
		coords_saved = "Saved Points",
		coords_tp = "TP to Selected Point",
		coords_point_prefix = "Point ",
		-- Toasts (dynamic)
		toast_head_amplified = "%s's head enlarged!",
		toast_tp_to = "TP to %s",
		toast_vehicle_to = "Vehicle -> %s",
		toast_target_fling = "Target Fling: %s",
		toast_position_saved = "Position saved!",
		toast_flashback = "Flashback!",
		toast_fov = "FOV: 90",
		toast_anti_kick_no_hook = "Anti-Kick: hookfunction not available",
		toast_anti_kick = "Anti-Kick enabled",
		toast_click_detectors = "Click Detectors enabled!",
		toast_proximity_prompts = "Proximity Prompts enabled!",
		toast_btools = "BTools enabled!",
		toast_voiceaudio_playing = "Playing audio in voice!",
		toast_voiceaudio_no_url = "No audio link provided",
		toast_voiceaudio_no_char = "Character not found",
		input_voiceaudio_title = "Voice Audio - Audio Link",
		input_voiceaudio_placeholder = "Paste audio link...",
		toast_tptovehicle_tp = "TP to %s",
		toast_tptovehicle_notfound = "No vehicles found",
		input_tptovehicle_title = "TP to Vehicle",
		input_tptovehicle_placeholder = "Search vehicle...",
		toast_velocity_reset = "Velocity reset!",
		toast_invisible_shown = "%s invisible parts shown",
		toast_clothes_removed = "Clothes removed!",
		toast_players_frozen = "Players frozen!",
		toast_players_unfrozen = "Players unfrozen!",
		-- Loader
		load_system_init = "SYSTEM INITIALIZING",
		load_connecting = "Connecting to GitHub...",
		load_downloading = "Downloading: %s",
		load_loading_core = "Loading Core...",
		load_error_core = "Critical Core Error!",
		load_ready = "All ready! Starting...",
	},
	es = {
		-- Settings
		settings_config = "Configuracion",
		settings_language = "Idioma",
		settings_debug_mode = "Debug Mode",
		settings_show_distance = "Mostrar Distancia",
		settings_show_health = "Mostrar Vida",
		settings_show_tag = "Mostrar Etiqueta",
		settings_show_name = "Mostrar Nombre",
		settings_hitbox_size = "Tamano Hitbox",
		settings_esp_max_distance = "Distancia Max ESP",
		settings_noclip_radius = "Radio NoClip",
		settings_fly_speed = "Velocidad Fly",
		-- Stats
		stats_section = "Estadisticas",
		stats_online = "Usuarios En Linea",
		stats_injections = "Inyecciones Totales",
		stats_device = "Mi Dispositivo",
		stats_status = "Estado",
		stats_active = "Activo",
		-- Update info
		update_section = "Info de Actualizacion",
		update_version = "Version",
		update_date = "Ultima Actualizacion",
		update_loading = "Cargando...",
		update_error = "Error al obtener",
		-- Toasts
		toast_activated = "Activado!",
		toast_deactivated = "Desactivado!",
		toast_script_loaded = "Script cargado con exito!",
		toast_new_update = "Nueva actualizacion disponible! Reinyecte para actualizar",
		toast_debug_failed = "DEBUG: %s fallo",
		-- ESP
		esp_enemy = "[ENEMIGO]",
		esp_ally = "[ALIADO]",
		esp_neutral = "[JUGADOR]",
		-- Toggle titles
		toggle_hitbox = "Hitbox Gigante",
		toggle_esp = "Activar ESP",
		toggle_crawl = "Arrastrarse",
		toggle_triggerbot = "TriggerBot",
		toggle_silentaim = "Silent Aim",
		toggle_nofling = "No Fling",
		toggle_wallbang = "Wall Bang",
		toggle_infinitehealth = "Infinite Health",
		toggle_killaura = "Kill Aura",
		toggle_nofalldamage = "No Fall Damage",
		toggle_headsize = "Head Size",
		toggle_fly = "Activar Fly",
		toggle_noclip = "Activar NoClip",
		toggle_sprint = "Sprint (Shift)",
		toggle_speed = "Speed Hack",
		toggle_infinitejump = "Infinite Jump",
		toggle_bunnyhop = "Bunny Hop",
		toggle_teleportplayer = "TP a Jugador",
		toggle_blink = "Blink (Q)",
		toggle_vehiclespeed = "Vehicle Speed",
		toggle_nojumpcooldown = "No Jump Cooldown",
		toggle_float = "Float",
		toggle_swim = "Swim",
		toggle_vehiclegoto = "Vehicle Goto",
		toggle_walkto = "Walk To",
		toggle_orbit = "Orbit",
		toggle_headsit = "HeadSit",
		toggle_vehiclefly = "Vehicle Fly",
		toggle_spectate = "Spectate",
		toggle_gotopart = "Goto Part",
		toggle_xray = "X-Ray (Paredes)",
		toggle_nightmode = "Night Mode",
		toggle_fullbright = "Fullbright",
		toggle_tracers = "Tracers",
		toggle_crosshair = "Custom Crosshair",
		toggle_fovchanger = "FOV Changer",
		toggle_clicktp = "Tool TP Click",
		toggle_gravity = "Gravedad Baja",
		toggle_customspawn = "Marcar Spawn",
		toggle_freecam = "Freecam",
		toggle_thirdperson = "Third Person",
		toggle_flashback = "Flashback",
		toggle_coords = "Coordenadas",
		toggle_serverrejoin = "Server Rejoin",
		toggle_anchor = "Anclarse",
		toggle_autoclicker = "Auto-Clicker",
		toggle_proximityinstant = "Proximity Instant",
		toggle_antiafk = "Anti-AFK",
		toggle_antikick = "Anti-Kick",
		toggle_autocollect = "Auto Collect",
		toggle_fireclickdetectors = "Fire Click Detectors",
		toggle_fireproximityprompts = "Fire Proximity Prompts",
		toggle_btools = "BTools",
		toggle_breakvelocity = "Break Velocity",
		toggle_invisibleparts = "Invisible Parts",
		toggle_voiceaudio = "Voice Audio (Link)",
		toggle_tptovehicle = "TP a Vehiculo",
		toggle_noplayercollide = "Sin Colision con Jugadores",
		toggle_forcepush = "Force Push (Defensa)",
		toggle_trollfling = "Tornado Fling",
		toggle_targetfling = "Target Fling",
		toggle_spasms = "Espasmos",
		toggle_naked = "Naked",
		toggle_freeze = "Freeze All",
		toggle_pushall = "Push All",
		-- Toggle descriptions
		desc_hitbox = "Expande la hitbox de los enemigos para acertar mas facil",
		desc_esp = "Muestra nombres, vida y distancia de los jugadores a traves de paredes",
		desc_triggerbot = "Dispara automaticamente cuando apuntas al enemigo",
		desc_silentaim = "Redirige los disparos al jugador mas cercano al cursor",
		desc_nofling = "Impide que seas lanzado por exploits de fling",
		desc_wallbang = "Permite disparar a traves de paredes y objetos",
		desc_infinitehealth = "Mantiene tu vida siempre al maximo",
		desc_killaura = "Ataca automaticamente a jugadores cercanos",
		desc_nofalldamage = "Elimina el dano de caida",
		desc_headsize = "Amplia cabeza de jugadores para acertar mas facil",
		desc_fly = "Volar por el mapa con WASD. Scroll ajusta velocidad",
		desc_noclip = "Atravesar paredes y objetos solidos",
		desc_sprint = "Correr mas rapido sosteniendo Shift",
		desc_speed = "Aumenta la velocidad de caminata",
		desc_infinitejump = "Saltar infinitas veces en el aire",
		desc_bunnyhop = "Saltar continuamente al correr",
		desc_teleportplayer = "Selecciona un jugador para teletransportarte",
		desc_blink = "Dash rapido en la direccion que miras. Tecla Q",
		desc_vehiclespeed = "Aumenta velocidad y torque de vehiculos",
		desc_nojumpcooldown = "Elimina cooldown de salto, salta sin parar",
		desc_float = "Plataforma voladora. Q baja, E sube",
		desc_swim = "Natacion en el aire, gravedad cero",
		desc_vehiclegoto = "Teletransporta tu vehiculo a un jugador",
		desc_walkto = "Sigue a un jugador automaticamente",
		desc_orbit = "Gira alrededor de un jugador",
		desc_headsit = "Se sienta en la cabeza de un jugador",
		desc_vehiclefly = "Volando manejando vehiculos. WASD+QE",
		desc_spectate = "Camara sigue a un jugador seleccionado",
		desc_gotopart = "Teletransporta a una parte por nombre",
		desc_crawl = "Hace que el personaje se arrastre por el suelo",
		desc_xray = "Ver a traves de paredes y objetos",
		desc_nightmode = "Oscurece el ambiente para ver mejor",
		desc_fullbright = "Iluminacion maxima, sin sombras",
		desc_tracers = "Lineas que apuntan a jugadores",
		desc_crosshair = "Mira personalizada en el centro de la pantalla",
		desc_fovchanger = "Aumenta o disminuye el campo de vision",
		desc_clicktp = "Herramienta para teletransportar haciendo clic en el suelo",
		desc_gravity = "Gravedad reducida para saltar alto",
		desc_customspawn = "Marca posicion para renacer automaticamente",
		desc_freecam = "Camara libre para explorar el mapa. WASD+QE+Mouse",
		desc_thirdperson = "Fuerza vista en tercera persona con camara alejada",
		desc_flashback = "Presiona P para volver al lugar de la ultima muerte",
		desc_coords = "Muestra coordenadas actuales y guarda posiciones",
		desc_serverrejoin = "Reconecta al mismo servidor",
		desc_anchor = "Ancla tu personaje en su lugar, impidiendo movimiento",
		desc_autoclicker = "Cliqueo automatico sosteniendo la tecla X",
		desc_proximityinstant = "Interaccion instantanea con prompts sin sostener",
		desc_antiafk = "Impide ser desconectado por inactividad",
		desc_antikick = "Impide ser expulsado del servidor",
		desc_autocollect = "Recoge automaticamente tools e itens cercanos",
		desc_fireclickdetectors = "Activa todos los ClickDetectors del mapa",
		desc_fireproximityprompts = "Activa todos los ProximityPrompts del mapa",
		desc_btools = "Herramientas de construccion (HopperBins)",
		desc_breakvelocity = "Resetea toda velocidad del personaje",
		desc_invisible_parts = "Muestra partes que estan invisibles en el mapa",
		desc_voiceaudio = "Reproduce audio en el voice de Roblox via enlace. Comando: !audio <url>",
		desc_tptovehicle = "Muestra lista de vehiculos y teleporta directo al piloto",
		desc_noplayercollide = "Elimina la colision con otros jugadores, pasa atraves de ellos",
		desc_forcepush = "Empuja a los jugadores cercanos automaticamente (defensa contra flingers)",
		desc_trollfling = "Gira rapidamente para lanzar a otros jugadores",
		desc_targetfling = "Selecciona un objetivo y vuela hasta el para derribar",
		desc_spasms = "Animacion de convulsion (requiere R6)",
		desc_naked = "Elimina todas las ropas de tu personaje",
		desc_freeze = "Congela a todos los jugadores en el servidor",
		desc_pushall = "Empuja a todos los jugadores cercanos con fuerza",
		-- Dropdown titles
		dropdown_select_player = "Seleccionar Jugador",
		dropdown_select_target = "Seleccionar Objetivo",
		dropdown_headsize_title = "Head Size - Seleccionar Jugador",
		dropdown_tpplayer_title = "TP a Jugador - Seleccionar",
		dropdown_vehiclegoto_title = "Vehicle Goto - Seleccionar Jugador",
		dropdown_walkto_title = "Walk To - Seleccionar Jugador",
		dropdown_orbit_title = "Orbit - Seleccionar Jugador",
		dropdown_headsit_title = "HeadSit - Seleccionar Jugador",
		dropdown_spectate_title = "Spectate - Seleccionar Jugador",
		dropdown_targetfling_title = "Target Fling - Seleccionar Objetivo",
		input_gotopart_title = "Goto Part - Nombre de Parte",
		input_gotopart_placeholder = "Escribe el nombre...",
		-- Coords section
		section_coords = "Coordenadas",
		coords_current = "Posicion Actual",
		coords_save = "Guardar Posicion",
		coords_saved = "Puntos Guardados",
		coords_tp = "TP a Punto Seleccionado",
		coords_point_prefix = "Punto ",
		-- Toasts (dynamic)
		toast_head_amplified = "Cabeza de %s ampliada!",
		toast_tp_to = "TP a %s",
		toast_vehicle_to = "Vehicle -> %s",
		toast_target_fling = "Target Fling: %s",
		toast_position_saved = "Posicion guardada!",
		toast_flashback = "Flashback!",
		toast_fov = "FOV: 90",
		toast_anti_kick_no_hook = "Anti-Kick: hookfunction no disponible",
		toast_anti_kick = "Anti-Kick activado",
		toast_click_detectors = "Click Detectors activados!",
		toast_proximity_prompts = "Proximity Prompts activados!",
		toast_btools = "BTools activados!",
		toast_voiceaudio_playing = "Reproduciendo audio en voice!",
		toast_voiceaudio_no_url = "No se proporciono enlace de audio",
		toast_voiceaudio_no_char = "Personaje no encontrado",
		input_voiceaudio_title = "Voice Audio - Enlace del Audio",
		input_voiceaudio_placeholder = "Pega el enlace del audio...",
		toast_tptovehicle_tp = "TP a %s",
		toast_tptovehicle_notfound = "No se encontraron vehiculos",
		input_tptovehicle_title = "TP a Vehiculo",
		input_tptovehicle_placeholder = "Buscar vehiculo...",
		toast_velocity_reset = "Velocity reseteado!",
		toast_invisible_shown = "%s partes invisibles mostradas",
		toast_clothes_removed = "Ropa eliminada!",
		toast_players_frozen = "Jugadores congelados!",
		toast_players_unfrozen = "Jugadores descongelados!",
		-- Loader
		load_system_init = "SYSTEM INITIALIZING",
		load_connecting = "Connecting to GitHub...",
		load_downloading = "Descargando: %s",
		load_loading_core = "Cargando Core...",
		load_error_core = "Error Critico en Core!",
		load_ready = "Todo listo! Iniciando...",
	},
}

-- Translation helper: GH.T("key") or GH.T("key", "arg1", "arg2")
function GH.T(key, ...)
	local lang = (GH.Settings and GH.Settings.Language) or "pt"
	local str = GH.Locales[lang] and GH.Locales[lang][key] or GH.Locales["pt"][key] or key
	if select("#", ...) > 0 then
		return string.format(str, ...)
	end
	return str
end

-- Services
GH.Services = {
	Players = Players,
	RunService = RunService,
	CoreGui = CoreGui,
	UserInputService = UserInputService,
	TweenService = TweenService,
	HttpService = HttpService,
	Lighting = Lighting,
}
GH.LocalPlayer = LocalPlayer

-- Target GUI
GH.TargetGui = (RunService:IsStudio() and LocalPlayer:WaitForChild("PlayerGui"))
	or (gethui and gethui())
	or CoreGui

-- ==========================================
-- THEME (cores para uso interno dos módulos)
-- ==========================================
GH.Theme = {
	BG = Color3.fromRGB(18, 18, 22), BGDark = Color3.fromRGB(12, 12, 15),
	Topbar = Color3.fromRGB(22, 22, 26), Card = Color3.fromRGB(28, 28, 32),
	CardHover = Color3.fromRGB(38, 38, 42), Accent = Color3.fromRGB(0, 120, 212),
	AccentDim = Color3.fromRGB(0, 99, 177), On = Color3.fromRGB(0, 120, 212),
	OnBG = Color3.fromRGB(10, 35, 60), Off = Color3.fromRGB(180, 180, 190),
	OffBG = Color3.fromRGB(35, 35, 40), Text = Color3.fromRGB(235, 235, 240),
	Border = Color3.fromRGB(50, 50, 58), Red = Color3.fromRGB(255, 60, 60),
}

-- TweenInfos
GH.TI = TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
GH.TI_Slow = TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)

-- ==========================================
-- UI DIMENSIONS (mantidos para compatibilidade)
-- ==========================================
GH.PanelWidth = 560
GH.PanelHeight = 400
GH.TopbarHeight = 32
GH.SidebarWidth = 130
GH.ButtonHeight = 30
GH.SettingsWidth = 220

-- ==========================================
-- STATE MANAGEMENT
-- ==========================================
GH.States = {}

GH.Buttons = {} :: {[string]: any}
GH.Callbacks = {} :: {[string]: (boolean, any) -> ()}
GH.Connections = {} :: {[string]: RBXScriptConnection}
GH.Objects = {}
GH.isClosing = false
GH.SilentRestore = false
GH.Stopped = false
GH.Version = { Hash = "unknown", Date = "unknown" }

-- ==========================================
-- CONNECTION MANAGEMENT
-- ==========================================
GH.GlobalConnections = {}

function GH.Disconnect(name)
	local c = GH.Connections[name]
	if c then GH.Connections[name] = nil; pcall(c.Disconnect, c) end
end

function GH.TrackGlobalConnection(name, conn)
	if conn then GH.GlobalConnections[name] = conn end
end

function GH.CleanupGlobalConnections()
	for name, conn in pairs(GH.GlobalConnections) do
		if conn and typeof(conn) == "RBXScriptConnection" then
			pcall(function() conn:Disconnect() end)
		end
		GH.GlobalConnections[name] = nil
	end
end

-- ==========================================
-- MASTER LOOP (Batching)
-- ==========================================
GH.MasterTick = { Render = 0, Heartbeat = 0, PreSim = 0 }
GH.MasterCallbacks = {
	Render = {} :: {[string]: () -> ()},
	Heartbeat = {} :: {[string]: () -> ()},
	PreSim = {} :: {[string]: () -> ()},
}

function GH.RegisterMasterLoop(name, phase, callback)
	GH.MasterCallbacks[phase][name] = callback
end

function GH.UnregisterMasterLoop(name)
	for phase, callbacks in pairs(GH.MasterCallbacks) do
		callbacks[name] = nil
	end
end

-- ==========================================
-- INPUT MANAGER
-- ==========================================
GH.InputManager = {}
GH.InputManager._bindings = {} :: {[Enum.KeyCode]: {onDown: (() -> ())?, onUp: (() -> ())?}}

function GH.InputManager.Bind(keyCode, onDown, onUp)
	GH.InputManager._bindings[keyCode] = { onDown = onDown, onUp = onUp }
end

function GH.InputManager.Unbind(keyCode)
	GH.InputManager._bindings[keyCode] = nil
end

function GH.InputManager.IsHeld(keyCode)
	return UserInputService:IsKeyDown(keyCode)
end

-- ==========================================
-- NOTIFICATION SYSTEM (Toast customizado Win11)
-- ==========================================
function GH.ShowToast(message, color, duration, persistent)
	if GH.SilentRestore then return end
	if not GH.ScreenGui or not GH.ScreenGui.Parent then return end

	pcall(function()
		if not GH.ToastContainer then
			GH.ToastContainer = Instance.new("Frame")
			GH.ToastContainer.Name = "GH_ToastContainer"
			GH.ToastContainer.Size = UDim2.new(0, 320, 1, 0)
			GH.ToastContainer.Position = UDim2.new(1, -330, 0, 40)
			GH.ToastContainer.BackgroundTransparency = 1
			GH.ToastContainer.ZIndex = 9999
			GH.ToastContainer.Parent = GH.ScreenGui
			local layout = Instance.new("UIListLayout")
			layout.Padding = UDim.new(0, 6)
			layout.SortOrder = Enum.SortOrder.LayoutOrder
			layout.VerticalAlignment = Enum.VerticalAlignment.Top
			layout.Parent = GH.ToastContainer
		end

		GH._toastIndex = (GH._toastIndex or 0) + 1
		local toast = Instance.new("Frame")
		toast.Size = UDim2.new(1, 0, 0, 0)
		toast.BackgroundColor3 = Color3.fromRGB(22, 22, 26)
		toast.BackgroundTransparency = 0.05
		toast.BorderSizePixel = 0
		toast.LayoutOrder = GH._toastIndex
		toast.ZIndex = 10000
		toast.ClipsDescendants = true
		toast.Parent = GH.ToastContainer
		Instance.new("UICorner", toast).CornerRadius = UDim.new(0, 8)

		local stroke = Instance.new("UIStroke")
		stroke.Color = color or GH.Theme.Accent
		stroke.Thickness = 1
		stroke.Transparency = 0.5
		stroke.Parent = toast

		local accent = Instance.new("Frame")
		accent.Size = UDim2.new(0, 3, 1, 0)
		accent.BackgroundColor3 = color or GH.Theme.Accent
		accent.BorderSizePixel = 0
		accent.Parent = toast

		-- Botao X para fechar (apenas em toasts persistentes)
		local closeBtn = nil
		if persistent then
			closeBtn = Instance.new("TextButton")
			closeBtn.Size = UDim2.new(0, 22, 0, 22)
			closeBtn.Position = UDim2.new(1, -26, 0.5, -11)
			closeBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 58)
			closeBtn.Text = ""
			closeBtn.AutoButtonColor = false
			closeBtn.ZIndex = 10003
			closeBtn.Parent = toast
			Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 4)

			local closeX = Instance.new("TextLabel")
			closeX.Size = UDim2.new(1, 0, 1, 0)
			closeX.BackgroundTransparency = 1
			closeX.Text = "X"
			closeX.TextColor3 = Color3.fromRGB(180, 180, 190)
			closeX.Font = Enum.Font.SourceSans
			closeX.TextSize = 12
			closeX.ZIndex = 10004
			closeX.Parent = closeBtn

			closeBtn.MouseEnter:Connect(function()
				TweenService:Create(closeBtn, GH.TI, { BackgroundColor3 = Color3.fromRGB(255, 60, 60) }):Play()
			end)
			closeBtn.MouseLeave:Connect(function()
				TweenService:Create(closeBtn, GH.TI, { BackgroundColor3 = Color3.fromRGB(50, 50, 58) }):Play()
			end)
		end

		local label = Instance.new("TextLabel")
		label.Size = UDim2.new(1, persistent and -40 or -14, 1, 0)
		label.Position = UDim2.new(0, 10, 0, 0)
		label.BackgroundTransparency = 1
		label.Text = message
		label.TextColor3 = GH.Theme.Text
		label.Font = Enum.Font.GothamMedium
		label.TextSize = 11
		label.TextXAlignment = Enum.TextXAlignment.Left
		label.TextWrapped = true
		label.ZIndex = 10001
		label.Parent = toast

		TweenService:Create(toast, GH.TI_Slow, {
			Size = UDim2.new(1, 0, 0, 32),
		}):Play()

		local function closeToast()
			if toast and toast.Parent then
				TweenService:Create(toast, GH.TI_Slow, {
					Size = UDim2.new(1, 0, 0, 0),
				}):Play()
				task.delay(0.35, function()
					if toast and toast.Parent then toast:Destroy() end
				end)
			end
		end

		if closeBtn then
			closeBtn.MouseButton1Click:Connect(closeToast)
		end

		if not persistent then
			task.delay(duration or 3, closeToast)
		end
	end)
end

-- ==========================================
-- PLAYER PICKER (GUI flutuante independente)
-- ==========================================
GH._Pickers = GH._Pickers or {}
GH._PickerCount = GH._PickerCount or 0

function GH.ShowPlayerPicker(title, callback)
	GH._PickerCount = GH._PickerCount + 1
	local pickerId = GH._PickerCount

	local Players = GH.Services.Players
	local LocalPlayer = GH.LocalPlayer
	local TS = GH.Services.TweenService

	local gui = Instance.new("ScreenGui")
	gui.Name = "GH_PlayerPicker_" .. pickerId
	gui.ResetOnSpawn = false
	gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	gui.DisplayOrder = 100
	gui.Parent = GH.TargetGui

	-- Posicionar cada novo picker deslocado
	local offset = (pickerId % 5) * 30

	local W = 200
	local H = 280
	local TOPBAR = 32

	-- Main frame (sem ClipsDescendants!)
	local frame = Instance.new("Frame")
	frame.Name = "Frame"
	frame.Size = UDim2.new(0, W, 0, H)
	frame.Position = UDim2.new(0.5, -W / 2 + offset, 0.5, -H / 2 + offset)
	frame.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
	frame.BorderSizePixel = 0
	frame.Active = true
	frame.Parent = gui
	Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 10)
	local s = Instance.new("UIStroke")
	s.Color = Color3.fromRGB(60, 60, 70)
	s.Thickness = 1
	s.Parent = frame

	-- Topbar (TextButton para receber InputBegan do drag)
	local tb = Instance.new("TextButton")
	tb.Name = "Topbar"
	tb.Size = UDim2.new(1, 0, 0, TOPBAR)
	tb.BackgroundColor3 = Color3.fromRGB(16, 16, 20)
	tb.BorderSizePixel = 0
	tb.Text = ""
	tb.AutoButtonColor = false
	tb.Parent = frame

	local titlelbl = Instance.new("TextLabel")
	titlelbl.Size = UDim2.new(1, -66, 1, 0)
	titlelbl.Position = UDim2.new(0, 10, 0, 0)
	titlelbl.BackgroundTransparency = 1
	titlelbl.Text = title or "Select"
	titlelbl.TextColor3 = Color3.fromRGB(0, 120, 212)
	titlelbl.Font = Enum.Font.GothamBold
	titlelbl.TextSize = 11
	titlelbl.TextXAlignment = Enum.TextXAlignment.Left
	titlelbl.Parent = tb

	-- Botao -
	local function makeBtn(posX, text)
		local b = Instance.new("TextButton")
		b.Size = UDim2.new(0, 24, 0, 24)
		b.Position = UDim2.new(1, posX, 0.5, -12)
		b.BackgroundColor3 = Color3.fromRGB(28, 28, 32)
		b.Text = ""
		b.AutoButtonColor = false
		b.Parent = tb
		Instance.new("UICorner", b).CornerRadius = UDim.new(0, 4)
		local lbl = Instance.new("TextLabel")
		lbl.Size = UDim2.new(1, 0, 1, 0)
		lbl.BackgroundTransparency = 1
		lbl.Text = text
		lbl.TextColor3 = text == "X" and Color3.fromRGB(235, 235, 240) or Color3.fromRGB(180, 180, 190)
		lbl.Font = Enum.Font.SourceSans
		lbl.TextSize = 14
		lbl.Parent = b
		return b
	end

	local minBtn = makeBtn(-56, "-")
	local closeBtn = makeBtn(-28, "X")

	closeBtn.MouseEnter:Connect(function()
		TS:Create(closeBtn, GH.TI, { BackgroundColor3 = Color3.fromRGB(255, 60, 60) }):Play()
	end)
	closeBtn.MouseLeave:Connect(function()
		TS:Create(closeBtn, GH.TI, { BackgroundColor3 = Color3.fromRGB(28, 28, 32) }):Play()
	end)

	-- Content
	local content = Instance.new("Frame")
	content.Name = "Content"
	content.Size = UDim2.new(1, -8, 1, -TOPBAR - 4)
	content.Position = UDim2.new(0, 4, 0, TOPBAR + 2)
	content.BackgroundTransparency = 1
	content.Parent = frame

	-- Search bar
	local searchBox = Instance.new("TextBox")
	searchBox.Name = "Search"
	searchBox.Size = UDim2.new(1, 0, 0, 26)
	searchBox.Position = UDim2.new(0, 0, 0, 0)
	searchBox.BackgroundColor3 = Color3.fromRGB(28, 28, 32)
	searchBox.PlaceholderText = "Procurar player..."
	searchBox.PlaceholderColor3 = Color3.fromRGB(100, 100, 115)
	searchBox.Text = ""
	searchBox.TextColor3 = Color3.fromRGB(235, 235, 240)
	searchBox.Font = Enum.Font.GothamMedium
	searchBox.TextSize = 11
	searchBox.TextXAlignment = Enum.TextXAlignment.Left
	searchBox.ClearTextOnFocus = false
	searchBox.ZIndex = 10
	searchBox.Parent = content
	Instance.new("UICorner", searchBox).CornerRadius = UDim.new(0, 4)
	Instance.new("UIPadding", searchBox).PaddingLeft = UDim.new(0, 6)

	-- ScrollingFrame
	local scroll = Instance.new("ScrollingFrame")
	scroll.Name = "List"
	scroll.Size = UDim2.new(1, 0, 1, -30)
	scroll.Position = UDim2.new(0, 0, 0, 30)
	scroll.BackgroundTransparency = 1
	scroll.ScrollBarThickness = 3
	scroll.ScrollBarImageColor3 = Color3.fromRGB(0, 120, 212)
	scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
	scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
	scroll.BorderSizePixel = 0
	scroll.Parent = content
	Instance.new("UIListLayout", scroll).Padding = UDim.new(0, 2)

	local selectedName = nil
	local minimized = false
	local searchText = ""

	local function buildList()
		for _, c in ipairs(scroll:GetChildren()) do
			if c:IsA("TextButton") or c:IsA("TextLabel") then c:Destroy() end
		end
		local myTeam = LocalPlayer.Team
		local names = {}
		for _, p in ipairs(Players:GetPlayers()) do
			if p ~= LocalPlayer then
				if searchText == "" or p.Name:lower():find(searchText:lower(), 1, true) then
					table.insert(names, p.Name)
				end
			end
		end
		table.sort(names)
		if #names == 0 then
			local e = Instance.new("TextLabel")
			e.Size = UDim2.new(1, 0, 0, 40)
			e.BackgroundTransparency = 1
			e.Text = "Nenhum jogador"
			e.TextColor3 = Color3.fromRGB(140, 140, 155)
			e.Font = Enum.Font.GothamMedium
			e.TextSize = 11
			e.Parent = scroll
			return
		end
		for i, name in ipairs(names) do
			local player = Players:FindFirstChild(name)
			local tag = ""
			local nameColor = Color3.fromRGB(235, 235, 240)
			if player then
				local pTeam = player.Team
				local pTeamColor = player.TeamColor
				local myTeamColor = myTeam and myTeam.TeamColor or LocalPlayer.TeamColor

				-- Detectar time via Team object ou TeamColor
				local hasTeams = (myTeam ~= nil) or (myTeamColor and myTeamColor ~= BrickColor.new("Medium stone grey"))
				if hasTeams then
					if pTeam and myTeam and pTeam == myTeam then
						tag = "[ALIADO] "
						nameColor = pTeam.TeamColor.Color
					elseif pTeam and myTeam and pTeam ~= myTeam then
						tag = "[INIMIGO] "
						nameColor = pTeam.TeamColor.Color
					elseif pTeamColor and myTeamColor and pTeamColor == myTeamColor then
						tag = "[ALIADO] "
						nameColor = pTeamColor.Color
					elseif pTeamColor and myTeamColor and pTeamColor ~= myTeamColor then
						tag = "[INIMIGO] "
						nameColor = pTeamColor.Color
					else
						tag = "[NEUTRO] "
						nameColor = Color3.fromRGB(180, 180, 190)
					end
				end
			end
			local b = Instance.new("TextButton")
			b.Name = name
			b.Size = UDim2.new(1, 0, 0, 28)
			b.BackgroundColor3 = Color3.fromRGB(28, 28, 32)
			b.Text = ""
			b.AutoButtonColor = false
			b.LayoutOrder = i
			b.Parent = scroll
			Instance.new("UICorner", b).CornerRadius = UDim.new(0, 4)

			-- Tag label
			if tag ~= "" then
				local tagLbl = Instance.new("TextLabel")
				tagLbl.Size = UDim2.new(0, 55, 1, 0)
				tagLbl.Position = UDim2.new(0, 6, 0, 0)
				tagLbl.BackgroundTransparency = 1
				tagLbl.Text = tag
				tagLbl.TextColor3 = nameColor
				tagLbl.Font = Enum.Font.GothamBold
				tagLbl.TextSize = 9
				tagLbl.TextXAlignment = Enum.TextXAlignment.Left
				tagLbl.Parent = b
			end

			-- Name label
			local nameLbl = Instance.new("TextLabel")
			nameLbl.Size = UDim2.new(1, -65, 1, 0)
			nameLbl.Position = UDim2.new(0, 60, 0, 0)
			nameLbl.BackgroundTransparency = 1
			nameLbl.Text = name
			nameLbl.TextColor3 = nameColor
			nameLbl.Font = Enum.Font.GothamMedium
			nameLbl.TextSize = 11
			nameLbl.TextXAlignment = Enum.TextXAlignment.Left
			nameLbl.TextTruncate = Enum.TextTruncate.AtEnd
			nameLbl.Parent = b

			b.MouseEnter:Connect(function()
				if selectedName ~= name then
					TS:Create(b, GH.TI, { BackgroundColor3 = Color3.fromRGB(38, 38, 42) }):Play()
				end
			end)
			b.MouseLeave:Connect(function()
				if selectedName ~= name then
					TS:Create(b, GH.TI, { BackgroundColor3 = Color3.fromRGB(28, 28, 32) }):Play()
				end
			end)
			b.MouseButton1Click:Connect(function()
				selectedName = name
				for _, c in ipairs(scroll:GetChildren()) do
					if c:IsA("TextButton") then
						TS:Create(c, GH.TI, { BackgroundColor3 = Color3.fromRGB(28, 28, 32) }):Play()
					end
				end
				TS:Create(b, GH.TI, { BackgroundColor3 = Color3.fromRGB(0, 99, 177) }):Play()
				if callback then pcall(callback, name) end
			end)
		end
	end

	buildList()

	-- Search filter
	searchBox:GetPropertyChangedSignal("Text"):Connect(function()
		searchText = searchBox.Text
		buildList()
	end)

	-- Refresh
	local connAdded = Players.PlayerAdded:Connect(function()
		if gui and gui.Parent then buildList() end
	end)
	local connRemoving = Players.PlayerRemoving:Connect(function()
		if gui and gui.Parent then buildList() end
	end)

	-- Salvar referencia do picker
	GH._Pickers[pickerId] = { gui = gui, conns = { connAdded, connRemoving }, dragConn = nil }

	-- Close
	closeBtn.MouseButton1Click:Connect(function()
		pcall(function() connAdded:Disconnect() end)
		pcall(function() connRemoving:Disconnect() end)
		if GH._Pickers[pickerId] and GH._Pickers[pickerId].dragConn then
			pcall(function() GH._Pickers[pickerId].dragConn:Disconnect() end)
		end
		GH._Pickers[pickerId] = nil
		gui:Destroy()
	end)

	-- Minimize
	minBtn.MouseButton1Click:Connect(function()
		minimized = not minimized
		if minimized then
			content.Visible = false
			TS:Create(frame, GH.TI, { Size = UDim2.new(0, W, 0, TOPBAR) }):Play()
		else
			TS:Create(frame, GH.TI, { Size = UDim2.new(0, W, 0, H) }):Play()
			task.delay(0.15, function() content.Visible = true end)
		end
	end)

	-- Drag (exatamente igual ao painel principal)
	local dragging, dragInput, dragStart, startPos
	local dragConn = nil

	tb.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			dragStart = input.Position
			startPos = frame.Position
			if not dragConn then
				dragConn = GH.Services.RunService.Heartbeat:Connect(function()
					if not dragging then return end
					if dragInput then
						local delta = dragInput.Position - dragStart
						frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
					end
				end)
			end
			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					dragging = false
					if dragConn then dragConn:Disconnect(); dragConn = nil end
				end
			end)
		end
	end)

	tb.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
			dragInput = input
		end
	end)

	return {
		Close = function()
			pcall(function() connAdded:Disconnect() end)
			pcall(function() connRemoving:Disconnect() end)
			if dragConn then pcall(function() dragConn:Disconnect() end) end
			GH._Pickers[pickerId] = nil
			gui:Destroy()
		end,
	}
end

-- ==========================================
-- INPUT PICKER (GUI flutuante para texto)
-- ==========================================
function GH.ShowInputPicker(title, placeholder, callback)
	GH._PickerCount = GH._PickerCount + 1
	local pickerId = GH._PickerCount

	local TS = GH.Services.TweenService

	local gui = Instance.new("ScreenGui")
	gui.Name = "GH_InputPicker_" .. pickerId
	gui.ResetOnSpawn = false
	gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	gui.DisplayOrder = 100
	gui.Parent = GH.TargetGui

	-- Posicionar cada novo picker deslocado
	local offset = (pickerId % 5) * 30

	local W = 220
	local H = 110
	local TOPBAR = 32

	local frame = Instance.new("Frame")
	frame.Name = "Frame"
	frame.Size = UDim2.new(0, W, 0, H)
	frame.Position = UDim2.new(0.5, -W / 2 + offset, 0.5, -H / 2 + offset)
	frame.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
	frame.BorderSizePixel = 0
	frame.Active = true
	frame.Parent = gui
	Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 10)
	local s = Instance.new("UIStroke")
	s.Color = Color3.fromRGB(60, 60, 70)
	s.Thickness = 1
	s.Parent = frame

	-- Topbar (TextButton para receber InputBegan do drag)
	local tb = Instance.new("TextButton")
	tb.Name = "Topbar"
	tb.Size = UDim2.new(1, 0, 0, TOPBAR)
	tb.BackgroundColor3 = Color3.fromRGB(16, 16, 20)
	tb.BorderSizePixel = 0
	tb.Text = ""
	tb.AutoButtonColor = false
	tb.Parent = frame

	local titlelbl = Instance.new("TextLabel")
	titlelbl.Size = UDim2.new(1, -66, 1, 0)
	titlelbl.Position = UDim2.new(0, 10, 0, 0)
	titlelbl.BackgroundTransparency = 1
	titlelbl.Text = title or "Input"
	titlelbl.TextColor3 = Color3.fromRGB(0, 120, 212)
	titlelbl.Font = Enum.Font.GothamBold
	titlelbl.TextSize = 11
	titlelbl.TextXAlignment = Enum.TextXAlignment.Left
	titlelbl.Parent = tb

	local function makeBtn(posX, text)
		local b = Instance.new("TextButton")
		b.Size = UDim2.new(0, 24, 0, 24)
		b.Position = UDim2.new(1, posX, 0.5, -12)
		b.BackgroundColor3 = Color3.fromRGB(28, 28, 32)
		b.Text = ""
		b.AutoButtonColor = false
		b.Parent = tb
		Instance.new("UICorner", b).CornerRadius = UDim.new(0, 4)
		local lbl = Instance.new("TextLabel")
		lbl.Size = UDim2.new(1, 0, 1, 0)
		lbl.BackgroundTransparency = 1
		lbl.Text = text
		lbl.TextColor3 = text == "X" and Color3.fromRGB(235, 235, 240) or Color3.fromRGB(180, 180, 190)
		lbl.Font = Enum.Font.SourceSans
		lbl.TextSize = 14
		lbl.Parent = b
		return b
	end

	local minBtn = makeBtn(-56, "-")
	local closeBtn = makeBtn(-28, "X")

	closeBtn.MouseEnter:Connect(function()
		TS:Create(closeBtn, GH.TI, { BackgroundColor3 = Color3.fromRGB(255, 60, 60) }):Play()
	end)
	closeBtn.MouseLeave:Connect(function()
		TS:Create(closeBtn, GH.TI, { BackgroundColor3 = Color3.fromRGB(28, 28, 32) }):Play()
	end)

	-- Content
	local inputBox = Instance.new("TextBox")
	inputBox.Size = UDim2.new(1, -20, 0, 28)
	inputBox.Position = UDim2.new(0, 10, 0, TOPBAR + 10)
	inputBox.BackgroundColor3 = Color3.fromRGB(28, 28, 32)
	inputBox.PlaceholderText = placeholder or "Type..."
	inputBox.PlaceholderColor3 = Color3.fromRGB(140, 140, 155)
	inputBox.Text = ""
	inputBox.TextColor3 = Color3.fromRGB(235, 235, 240)
	inputBox.Font = Enum.Font.GothamMedium
	inputBox.TextSize = 12
	inputBox.TextXAlignment = Enum.TextXAlignment.Left
	inputBox.ClearTextOnFocus = false
	inputBox.Parent = frame
	Instance.new("UICorner", inputBox).CornerRadius = UDim.new(0, 4)
	Instance.new("UIPadding", inputBox).PaddingLeft = UDim.new(0, 6)

	inputBox.FocusLost:Connect(function(enterPressed)
		if enterPressed and inputBox.Text ~= "" then
			if callback then pcall(callback, inputBox.Text) end
			inputBox.Text = ""
		end
	end)

	-- Minimize
	local minimized = false
	minBtn.MouseButton1Click:Connect(function()
		minimized = not minimized
		if minimized then
			inputBox.Visible = false
			TS:Create(frame, GH.TI, { Size = UDim2.new(0, W, 0, TOPBAR) }):Play()
		else
			TS:Create(frame, GH.TI, { Size = UDim2.new(0, W, 0, H) }):Play()
			task.delay(0.15, function() inputBox.Visible = true end)
		end
	end)

	-- Salvar referencia do picker
	GH._Pickers[pickerId] = { gui = gui, conns = {}, dragConn = nil }

	-- Close
	closeBtn.MouseButton1Click:Connect(function()
		if GH._Pickers[pickerId] and GH._Pickers[pickerId].dragConn then
			pcall(function() GH._Pickers[pickerId].dragConn:Disconnect() end)
		end
		GH._Pickers[pickerId] = nil
		gui:Destroy()
	end)

	-- Drag (exatamente igual ao painel principal)
	local dragging, dragInput, dragStart, startPos
	local dragConn = nil

	tb.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			dragStart = input.Position
			startPos = frame.Position
			if not dragConn then
				dragConn = GH.Services.RunService.Heartbeat:Connect(function()
					if not dragging then return end
					if dragInput then
						local delta = dragInput.Position - dragStart
						frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
					end
				end)
			end
			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					dragging = false
					if dragConn then dragConn:Disconnect(); dragConn = nil end
				end
			end)
		end
	end)

	tb.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
			dragInput = input
		end
	end)

	return {
		Close = function()
			if dragConn then pcall(function() dragConn:Disconnect() end) end
			GH._Pickers[pickerId] = nil
			gui:Destroy()
		end,
	}
end

-- ==========================================
-- SAFE CALL
-- ==========================================
function GH.SafeCall(context, fn)
	local ok, err = pcall(fn)
	if not ok and GH.Settings and GH.Settings.DebugMode then
		warn("[GH DEBUG] " .. context .. ": " .. tostring(err))
		GH.ShowToast(string.format(GH.T("toast_debug_failed"), context), GH.Theme.Red, 4)
	end
end

-- ==========================================
-- SETTINGS DEFAULTS
-- ==========================================
GH.Settings = {
	Language = "pt",
	DebugMode = false,
	HitboxSize = 15,
	ESPShowDistance = true,
	ESPShowHealth = true,
	ESPShowTag = true,
	ESPShowName = true,
	ESPMaxDistance = 300,
	NoClipRadius = 3.8,
}

GH.FlySpeed = 20
GH.KeybindDefaults = {
	Sprint = "LeftShift",
	AutoClicker = "X",
	Blink = "Q",
}
GH.Keybinds = {}
for k, v in pairs(GH.KeybindDefaults) do GH.Keybinds[k] = v end

function GH.GetKeyCode(name)
	local keyName = GH.Keybinds[name]
	if keyName then return Enum.KeyCode[keyName] end
	return nil
end

-- ==========================================
-- CATEGORIES (Tabs)
-- ==========================================
GH.Categories = {
	{ Name = "Combat",   Icon = "crosshair", Order = 1 },
	{ Name = "Movement", Icon = "move",      Order = 2 },
	{ Name = "Visual",   Icon = "eye",       Order = 3 },
	{ Name = "Utility",  Icon = "wrench",    Order = 4 },
	{ Name = "Troll",    Icon = "smile",     Order = 5 },
	{ Name = "Settings", Icon = "gear",      Order = 6 },
}

-- Botões pendentes que serão criados após a UI existir
GH.PendingButtons = {} -- { {name, localeKey, callback, category, descKey}, ... }

function GH.RegisterToggleButton(name, localeKey, callback, category, descKey)
	table.insert(GH.PendingButtons, {name = name, localeKey = localeKey, callback = callback, category = category, descKey = descKey})
end

-- ==========================================
-- UI REFRESH (atualiza textos ao trocar idioma)
-- ==========================================
function GH.RefreshUI()
	for _, pending in ipairs(GH.PendingButtons) do
		local btn = GH.Buttons[pending.name]
		if btn and btn.Instance then
			local lbl = btn.Instance:FindFirstChild("GH_ToggleLabel")
			if lbl then
				pcall(function() lbl.Text = "  " .. GH.T(pending.localeKey) end)
			end
		end
	end
end

-- ==========================================
-- NAMECALL HANDLERS (módulos registram aqui)
-- ==========================================
GH.NamecallHandlers = {}

-- ==========================================
-- CACHE
-- ==========================================
GH.Cache = {
	ESPPlayers = {} :: {[Player]: boolean | RBXScriptConnection},
	XRayParts = {} :: {BasePart},
	OrigHRPSizes = {} :: {[Player]: Vector3},
	OrigWalkSpeed = 16,
	OrigGravity = 196.2,
	HitboxAdornments = {} :: {[Player]: SelectionBox},
	HitboxCharConns = {} :: {[Player]: {RBXScriptConnection}},
	HitboxRemoving = {} :: {[Player]: boolean},
	ShouldSpawnAtCustom = false,
	SpawnCFrame = nil :: CFrame?,
	SpasmTrack = nil,
	SpasmAnim = nil,
	LastDeathCFrame = nil :: CFrame?,
	SwimOldGravity = 196.2,
}

-- ==========================================
-- WEAK TABLES
-- ==========================================
function GH.MakeWeakCache(mode)
	return setmetatable({}, { __mode = mode })
end

-- ==========================================
-- OBJECT POOL (para Drawing)
-- ==========================================
GH.ObjectPool = {}
GH.ObjectPool.__index = GH.ObjectPool

function GH.ObjectPool.new(factory, destructor)
	local self = setmetatable({}, GH.ObjectPool)
	self._pool = {}
	self._factory = factory
	self._destructor = destructor
	return self
end

function GH.ObjectPool:get(...)
	local n = #self._pool
	if n > 0 then
		local obj = self._pool[n]
		self._pool[n] = nil
		return obj
	end
	return self._factory(...)
end

function GH.ObjectPool:release(obj)
	if obj then
		self._destructor(obj)
		table.insert(self._pool, obj)
	end
end

function GH.ObjectPool:clear()
	for i = 1, #self._pool do
		pcall(self._destructor, self._pool[i])
		self._pool[i] = nil
	end
end

-- ==========================================
-- TWEEN TELEPORT HELPER
-- ==========================================
function GH.TweenTeleport(hrp, targetCFrame, duration)
	if not hrp then return end
	if not LocalPlayer.Character then return end
	duration = duration or 0.15

	local originalCollisions = {}
	for _, part in ipairs(LocalPlayer.Character:GetDescendants()) do
		if part:IsA("BasePart") then
			originalCollisions[part] = part.CanCollide
			part.CanCollide = false
		end
	end

	local tween = TweenService:Create(hrp, TweenInfo.new(duration, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		CFrame = targetCFrame
	})
	tween:Play()

	task.delay(duration + 0.05, function()
		for part, canCollide in pairs(originalCollisions) do
			if part and part.Parent then
				part.CanCollide = canCollide
			end
		end
	end)
end

-- ==========================================
-- STATS / WEBHOOK SYSTEM
-- ==========================================
GH.Stats = {
	WebhookURL = "https://discord.com/api/webhooks/1530334217723052042/NKbEN44nHaLiUwgYov5NiixxVtCPbvMOf0Gc12KHp1PI9cZYNoBRfJt4MW797h32DkhO",
	OnlineUsers = 0,
	TotalInjections = 0,
	DeviceID = tostring(LocalPlayer.UserId),
	IsOnline = true,
}

-- Gerar ID unico do dispositivo baseado no UserId
function GH.Stats.GetDeviceID()
	return "DEV_" .. tostring(LocalPlayer.UserId)
end

-- Enviar evento de injecao para o Discord webhook
function GH.Stats.SendInjectionEvent()
	pcall(function()
		local deviceID = GH.Stats.GetDeviceID()
		local payload = {
			content = nil,
			embeds = {{
				title = "🚀 Script Injetado",
				description = string.format(
					"**Jogador:** %s\n**UserID:** %s\n**DeviceID:** %s\n**Servidor:** %s\n**Horario:** %s",
					LocalPlayer.Name,
					LocalPlayer.UserId,
					deviceID,
					game.JobId ~= "" and game.JobId or "Studio",
					os.date("%d/%m/%Y %H:%M:%S")
				),
				color = 3066993,
				thumbnail = {
					url = string.format("https://www.roblox.com/headshot-thumb/image?userId=%d&width=150&height=150&format=png", LocalPlayer.UserId)
				},
				footer = {
					text = "System Script - Metrics"
				}
			}}
		}

		local httpService = game:GetService("HttpService")
		local jsonPayload = httpService:JSONEncode(payload)

		-- Usar HttpService RequestAsync para enviar
		local request = http_request or (syn and syn.request) or (http and http.request)
		if request then
			request({
				Url = GH.Stats.WebhookURL,
				Method = "POST",
				Headers = {
					["Content-Type"] = "application/json",
				},
				Body = jsonPayload,
			})
		else
			-- Fallback: usar game:HttpGet (so funciona para GET, mas tentamos)
			warn("[SystemScript] HTTP request nao disponivel para webhook")
		end
	end)
end

-- Enviar heartbeat para manter online
function GH.Stats.SendHeartbeat()
	pcall(function()
		local deviceID = GH.Stats.GetDeviceID()
		local payload = {
			content = nil,
			embeds = {{
				title = "💓 Heartbeat",
				description = string.format(
					"**Jogador:** %s\n**DeviceID:** %s\n**Status:** Online\n**Horario:** %s",
					LocalPlayer.Name,
					deviceID,
					os.date("%d/%m/%Y %H:%M:%S")
				),
				color = 3066993,
			}}
		}

		local httpService = game:GetService("HttpService")
		local jsonPayload = httpService:JSONEncode(payload)

		local request = http_request or (syn and syn.request) or (http and http.request)
		if request then
			request({
				Url = GH.Stats.WebhookURL,
				Method = "POST",
				Headers = {
					["Content-Type"] = "application/json",
				},
				Body = jsonPayload,
			})
		end
	end)
end

-- Enviar evento de desligamento
function GH.Stats.SendDisconnectEvent()
	pcall(function()
		local deviceID = GH.Stats.GetDeviceID()
		local payload = {
			content = nil,
			embeds = {{
				title = "🔴 Script Desligado",
				description = string.format(
					"**Jogador:** %s\n**DeviceID:** %s\n**Horario:** %s",
					LocalPlayer.Name,
					deviceID,
					os.date("%d/%m/%Y %H:%M:%S")
				),
				color = 15158332,
			}}
		}

		local httpService = game:GetService("HttpService")
		local jsonPayload = httpService:JSONEncode(payload)

		local request = http_request or (syn and syn.request) or (http and http.request)
		if request then
			request({
				Url = GH.Stats.WebhookURL,
				Method = "POST",
				Headers = {
					["Content-Type"] = "application/json",
				},
				Body = jsonPayload,
			})
		end
	end)
end

-- Iniciar sistema de metricas
function GH.Stats.Start()
	-- Enviar evento de injecao
	GH.Stats.SendInjectionEvent()

	-- Enviar heartbeat a cada 60 segundos
	task.spawn(function()
		while GH.Stats.IsOnline and not GH.Stopped do
			task.wait(60)
			if GH.Stats.IsOnline and not GH.Stopped then
				GH.Stats.SendHeartbeat()
			end
		end
	end)

	-- Enviar desligamento quando o script for destruido
	if script then
		script.Destroying:Connect(function()
			GH.Stats.IsOnline = false
			GH.Stats.SendDisconnectEvent()
		end)
	end
end

-- ==========================================
-- FULL CLEANUP
-- ==========================================
function GH.FullCleanup()
	if GH._cleaningUp then return end
	GH._cleaningUp = true
	GH.isClosing = true
	GH.Stopped = true

	-- Enviar evento de desligamento
	if GH.Stats then
		GH.Stats.IsOnline = false
		pcall(function() GH.Stats.SendDisconnectEvent() end)
	end

	-- ==========================================
	-- LIMPEZA EXPLICITA DE FEATURES (antes dos callbacks)
	-- ==========================================

	-- Fly/VehicleFly: remover BodyVelocity/BodyGyro, restaurar humanoid
	pcall(function()
		local char = LocalPlayer.Character
		if char then
			local hrp = char:FindFirstChild("HumanoidRootPart")
			if hrp then
				for _, name in ipairs({"GH_FlyBV","GH_FlyBG","GH_VFlyBV","GH_VFlyBG"}) do
					local obj = hrp:FindFirstChild(name)
					if obj then obj:Destroy() end
				end
				hrp.AssemblyLinearVelocity = Vector3.zero
				hrp.AssemblyAngularVelocity = Vector3.zero
			end
			local hum = char:FindFirstChildOfClass("Humanoid")
			if hum then
				hum.PlatformStand = false
				hum.AutoRotate = true
				hum:SetStateEnabled(Enum.HumanoidStateType.Freefall, true)
				pcall(function() hum:ChangeState(Enum.HumanoidStateType.GettingUp) end)
			end
			-- Restaurar CanCollide e descongelar joints
			for _, part in ipairs(char:GetDescendants()) do
				if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
					part.CanCollide = true
				end
				if part:IsA("Motor6D") then
					pcall(function() part:SetJointFrozen(Enum.JointType.Motor, false) end)
				end
			end
		end
	end)

	-- Float: remover plataforma
	pcall(function()
		local char = LocalPlayer.Character
		if char then
			local pad = char:FindFirstChild("GH_FloatPad")
			if pad then pad:Destroy() end
		end
		local pad2 = workspace:FindFirstChild("GH_FloatPad")
		if pad2 then pad2:Destroy() end
	end)

	-- TrollFling/TargetFling: remover AngularVelocity
	pcall(function()
		local char = LocalPlayer.Character
		if char then
			local hrp = char:FindFirstChild("HumanoidRootPart")
			if hrp then
				for _, name in ipairs({"GH_TrollSpin","GH_TargetSpin"}) do
					local obj = hrp:FindFirstChild(name)
					if obj then obj:Destroy() end
				end
				hrp.AssemblyAngularVelocity = Vector3.zero
				hrp.AssemblyLinearVelocity = Vector3.zero
			end
			local hum = char:FindFirstChildOfClass("Humanoid")
			if hum then hum.AutoRotate = true end
			for _, part in ipairs(char:GetDescendants()) do
				if part:IsA("BasePart") then part.CanCollide = true end
			end
		end
	end)

	-- NoFling: restaurar CustomPhysicalProperties
	pcall(function()
		local char = LocalPlayer.Character
		if char then
			for _, part in ipairs(char:GetDescendants()) do
				if part:IsA("BasePart") then part.CustomPhysicalProperties = nil end
			end
		end
	end)

	-- Freecam: unbind render step e restaurar camera
	pcall(function()
		RunService:UnbindFromRenderStep("GH_Freecam")
		local CAS = game:GetService("ContextActionService")
		CAS:UnbindAction("GH_FCKeys")
		CAS:UnbindAction("GH_FCMouse")
		local cam = workspace.CurrentCamera
		if cam then
			cam.CameraType = Enum.CameraType.Custom
			cam.FieldOfView = 70
		end
		UserInputService.MouseIconEnabled = true
	end)

	-- NightMode/Fullbright: restaurar Lighting
	pcall(function()
		Lighting.Brightness = GH.Cache.OrigNightBrightness or GH.Cache.OrigFBBrightness or 1
		Lighting.ClockTime = GH.Cache.OrigNightClockTime or GH.Cache.OrigFBClockTime or 14
		Lighting.Ambient = GH.Cache.OrigNightAmbient or GH.Cache.OrigFBAmbient or Color3.fromRGB(128, 128, 128)
		Lighting.OutdoorAmbient = GH.Cache.OrigNightOutdoorAmbient or GH.Cache.OrigFBOutdoorAmbient or Color3.fromRGB(128, 128, 128)
		local bloom = Lighting:FindFirstChild("GH_NightBloom")
		if bloom then bloom:Destroy() end
	end)

	-- XRay: restaurar LocalTransparencyModifier
	pcall(function()
		if GH.Cache.XRayParts then
			for _, part in ipairs(GH.Cache.XRayParts) do
				if part and part.Parent then part.LocalTransparencyModifier = 0 end
			end
		end
		table.clear(GH.Cache.XRayParts or {})
	end)

	-- BTools/ClickTP: remover tools
	pcall(function()
		local bp = LocalPlayer:FindFirstChild("Backpack")
		if bp then
			for _, v in ipairs(bp:GetChildren()) do
				if v:IsA("HopperBin") and v.Name:sub(1, 6) == "BTool_" then v:Destroy() end
				if v:IsA("Tool") and v.Name == "Click TP" then v:Destroy() end
			end
		end
	end)

	-- Crosshair: remover GUI
	pcall(function()
		local gui = GH.TargetGui:FindFirstChild("GH_Crosshair")
		if gui then gui:Destroy() end
	end)

	-- VoiceAudio: parar e destruir som
	pcall(function()
		local char = LocalPlayer.Character
		if char then
			local hrp = char:FindFirstChild("HumanoidRootPart")
			if hrp then
				local snd = hrp:FindFirstChild("GH_VoiceAudio")
				if snd then
					snd:Stop()
					snd:Destroy()
				end
			end
		end
	end)

	-- TpToVehicle: fechar GUI
	pcall(function()
		if GH.TargetGui:FindFirstChild("GH_VehiclePicker") then
			GH.TargetGui["GH_VehiclePicker"]:Destroy()
		end
	end)

	-- NoPlayerCollide: restaurar colisao de todos os players
	pcall(function()
		for part, origCanCollide in pairs(GH.Cache.OrigPlayerCollides) do
			if part and part.Parent then
				part.CanCollide = origCanCollide
			end
		end
		table.clear(GH.Cache.OrigPlayerCollides)
	end)

	-- Crawl: restaurar HipHeight
	pcall(function()
		local char = LocalPlayer.Character
		if char then
			local hum = char:FindFirstChildOfClass("Humanoid")
			if hum and GH.Cache.OrigHipHeight then
				hum.HipHeight = GH.Cache.OrigHipHeight
				GH.Cache.OrigHipHeight = nil
			end
		end
	end)

	-- Spasms: parar animacao
	pcall(function()
		if GH.Cache.SpasmTrack then GH.Cache.SpasmTrack:Stop(); GH.Cache.SpasmTrack = nil end
		if GH.Cache.SpasmAnim then GH.Cache.SpasmAnim:Destroy(); GH.Cache.SpasmAnim = nil end
	end)

	-- ==========================================
	-- DESATIVAR TODOS OS STATES (via callbacks)
	-- ==========================================
	GH.SilentRestore = true
	local statesToClean = {}
	for name, state in pairs(GH.States) do
		if state then table.insert(statesToClean, name) end
	end
	for _, name in ipairs(statesToClean) do
		GH.States[name] = false
		if GH.Callbacks[name] and GH.Buttons[name] then
			pcall(GH.Callbacks[name], false, GH.Buttons[name])
		end
	end
	GH.SilentRestore = false

	-- Desregistrar todos os master loops
	for phase, callbacks in pairs(GH.MasterCallbacks) do
		for name, _ in pairs(callbacks) do
			callbacks[name] = nil
		end
	end

	-- Desconectar todas as conexoes locais
	for name, conn in pairs(GH.Connections) do
		if conn and typeof(conn) == "RBXScriptConnection" then
			pcall(function() conn:Disconnect() end)
		end
		GH.Connections[name] = nil
	end

	-- Limpar conexoes globais
	GH.CleanupGlobalConnections()

	-- Limpar input manager
	table.clear(GH.InputManager._bindings)

	-- Destruir todas as GUIs auxiliares
	for key, obj in pairs(GH.Objects) do
		if obj and typeof(obj) == "Instance" then
			pcall(function() obj:Destroy() end)
		end
		GH.Objects[key] = nil
	end

	-- Restaurar workspace
	pcall(function()
		workspace.Gravity = GH.Cache.OrigGravity or 196.2
	end)

	-- Restaurar humanoid
	pcall(function()
		local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
		if hum then
			hum.WalkSpeed = GH.Cache.OrigWalkSpeed or 16
			hum.JumpHeight = 7.2
			hum.JumpPower = 50
			hum.PlatformStand = false
			hum.AutoRotate = true
			local enums = Enum.HumanoidStateType:GetEnumItems()
			table.remove(enums, table.find(enums, Enum.HumanoidStateType.None))
			for _, v in ipairs(enums) do hum:SetStateEnabled(v, true) end
		end
	end)

	-- Limpar HRP sizes
	for player, origSize in pairs(GH.Cache.OrigHRPSizes) do
		pcall(function()
			if player.Character then
				local hrp = player.Character:FindFirstChild("HumanoidRootPart")
				if hrp and origSize then
					hrp.Size = origSize
					hrp.Transparency = 1
					hrp.CanCollide = false
				end
			end
		end)
	end
	table.clear(GH.Cache.OrigHRPSizes)

	-- Restaurar Head Sizes
	if GH.Cache.OrigHeadSizes then
		for player, origSize in pairs(GH.Cache.OrigHeadSizes) do
			pcall(function()
				if player.Character then
					local head = player.Character:FindFirstChild("Head")
					if head and head:IsA("BasePart") then
						head.Size = origSize
						head.CanCollide = true
					end
				end
			end)
		end
		table.clear(GH.Cache.OrigHeadSizes)
	end

	-- Limpar SelectionBoxes
	pcall(function()
		for _, obj in ipairs(GH.TargetGui:GetChildren()) do
			if obj:IsA("SelectionBox") and obj.Name:sub(1, 12) == "GH_Hitbox_SB" then
				obj.Adornee = nil
				obj:Destroy()
			end
		end
	end)

	-- Limpar ESP
	pcall(function()
		-- Destruir espFolder completa (Highlights + BillboardGuis)
		if GH.Objects.ESP_Folder and GH.Objects.ESP_Folder.Parent then
			GH.Objects.ESP_Folder:Destroy()
			GH.Objects.ESP_Folder = nil
		end
		-- Restaurar DisplayDistanceType de todos os jogadores
		for _, p in ipairs(Players:GetPlayers()) do
			if p ~= LocalPlayer and p.Character then
				local hum = p.Character:FindFirstChildOfClass("Humanoid")
				if hum then
					hum.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.Viewer
				end
			end
		end
	end)

	-- Limpar animacoes
	pcall(function()
		if GH.Cache.SpasmTrack then GH.Cache.SpasmTrack:Stop(); GH.Cache.SpasmTrack = nil end
		if GH.Cache.SpasmAnim then GH.Cache.SpasmAnim:Destroy(); GH.Cache.SpasmAnim = nil end
	end)

	-- Destruir janela Fluent
	pcall(function()
		if GH.Window then
			if GH.Window.Window then GH.Window.Window:Destroy() end
			GH.Window = nil
		end
		if GH.TargetGui:FindFirstChild("SystemScript") then
			GH.TargetGui["SystemScript"]:Destroy()
		end
		-- Destruir GUI de stats
		if GH.TargetGui:FindFirstChild("SystemScriptStats") then
			GH.TargetGui["SystemScriptStats"]:Destroy()
		end
		-- Destruir todos os pickers abertos
		for id, picker in pairs(GH._Pickers or {}) do
			if picker then
				for _, conn in ipairs(picker.conns or {}) do
					pcall(function() conn:Disconnect() end)
				end
				if picker.dragConn then pcall(function() picker.dragConn:Disconnect() end) end
				if picker.gui then pcall(function() picker.gui:Destroy() end) end
			end
		end
		GH._Pickers = {}
	end)

	-- Limpar tabelas
	table.clear(GH.Cache.HitboxAdornments)
	table.clear(GH.Cache.ESPPlayers)
end

-- ==========================================
-- INITIALIZE: GUI Customizada Win11 (sem Fluent)
-- ==========================================
function GH.Initialize()
	-- Limpar GUI antiga
	if GH.TargetGui:FindFirstChild("SystemScript") then
		GH.TargetGui["SystemScript"]:Destroy()
	end

	-- ==========================================
	-- THEME WIN11
	-- ==========================================
	local W11 = {
		BG = Color3.fromRGB(18, 18, 22),
		BGAlt = Color3.fromRGB(22, 22, 26),
		Surface = Color3.fromRGB(28, 28, 32),
		SurfaceHover = Color3.fromRGB(38, 38, 42),
		SurfaceActive = Color3.fromRGB(42, 42, 46),
		Accent = Color3.fromRGB(0, 120, 212),
		AccentDark = Color3.fromRGB(0, 99, 177),
		AccentGlow = Color3.fromRGB(0, 150, 255),
		On = Color3.fromRGB(0, 120, 212),
		OnBG = Color3.fromRGB(10, 35, 60),
		Off = Color3.fromRGB(180, 180, 190),
		OffBG = Color3.fromRGB(35, 35, 40),
		Text = Color3.fromRGB(235, 235, 240),
		TextSecondary = Color3.fromRGB(140, 140, 155),
		TextMuted = Color3.fromRGB(90, 90, 105),
		Border = Color3.fromRGB(50, 50, 58),
		BorderSubtle = Color3.fromRGB(40, 40, 48),
		Red = Color3.fromRGB(255, 60, 60),
		RedHover = Color3.fromRGB(255, 80, 80),
	}
	GH.Theme = W11

	local Font = Enum.Font.GothamMedium
	local FontBold = Enum.Font.GothamBold

	-- ==========================================
	-- SCREEN GUI
	-- ==========================================
	local ScreenGui = Instance.new("ScreenGui")
	ScreenGui.Name = "SystemScript"
	ScreenGui.ResetOnSpawn = false
	ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	ScreenGui.DisplayOrder = 10
	ScreenGui.Parent = GH.TargetGui
	GH.ScreenGui = ScreenGui

	-- ==========================================
	-- DIMENSIONS
	-- ==========================================
	local PanelW = 560
	local PanelH = 400
	local TopbarH = 32
	local SidebarW = 130
	local BtnH = 30

	-- ==========================================
	-- MAIN FRAME
	-- ==========================================
	local MainFrame = Instance.new("Frame")
	MainFrame.Name = "MainFrame"
	MainFrame.Size = UDim2.new(0, PanelW, 0, PanelH)
	MainFrame.Position = UDim2.new(0.5, -PanelW / 2, 0.5, -PanelH / 2)
	MainFrame.BackgroundColor3 = W11.BG
	MainFrame.BorderSizePixel = 0
	MainFrame.ClipsDescendants = true
	MainFrame.Parent = ScreenGui
	Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 10)
	local mainStroke = Instance.new("UIStroke")
	mainStroke.Color = Color3.fromRGB(60, 60, 70)
	mainStroke.Thickness = 1
	mainStroke.Transparency = 0.2
	mainStroke.Parent = MainFrame

	-- ==========================================
	-- FPS COUNTER (canto inferior esquerdo)
	-- ==========================================
	local FPSLabel = Instance.new("TextLabel")
	FPSLabel.Name = "FPSCounter"
	FPSLabel.Size = UDim2.new(0, 80, 0, 16)
	FPSLabel.Position = UDim2.new(0, 8, 1, -22)
	FPSLabel.BackgroundTransparency = 1
	FPSLabel.Text = "FPS: --"
	FPSLabel.TextColor3 = Color3.fromRGB(100, 100, 115)
	FPSLabel.Font = Enum.Font.RobotoMono
	FPSLabel.TextSize = 9
	FPSLabel.TextXAlignment = Enum.TextXAlignment.Left
	FPSLabel.ZIndex = 3
	FPSLabel.Parent = MainFrame

	-- FPS tracking
	local fpsFrames = 0
	local fpsLastUpdate = os.clock()
	RunService.RenderStepped:Connect(function()
		fpsFrames += 1
		local now = os.clock()
		if now - fpsLastUpdate >= 1 then
			local fps = math.floor(fpsFrames / (now - fpsLastUpdate) + 0.5)
			FPSLabel.Text = "FPS: " .. fps
			if fps >= 50 then
				FPSLabel.TextColor3 = Color3.fromRGB(80, 200, 120)
			elseif fps >= 30 then
				FPSLabel.TextColor3 = Color3.fromRGB(200, 180, 80)
			else
				FPSLabel.TextColor3 = Color3.fromRGB(255, 80, 80)
			end
			fpsFrames = 0
			fpsLastUpdate = now
		end
	end)

	-- ==========================================
	-- TOPBAR
	-- ==========================================
	local Topbar = Instance.new("Frame")
	Topbar.Name = "Topbar"
	Topbar.Size = UDim2.new(1, 0, 0, TopbarH)
	Topbar.BackgroundColor3 = Color3.fromRGB(16, 16, 20)
	Topbar.BorderSizePixel = 0
	Topbar.ZIndex = 2
	Topbar.Parent = MainFrame

	local TitleLabel = Instance.new("TextLabel")
	TitleLabel.Size = UDim2.new(1, -120, 1, 0)
	TitleLabel.Position = UDim2.new(0, 14, 0, 0)
	TitleLabel.BackgroundTransparency = 1
	TitleLabel.Text = "SYSTEM SCRIPT"
	TitleLabel.TextColor3 = W11.Accent
	TitleLabel.Font = FontBold
	TitleLabel.TextSize = 11
	TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
	TitleLabel.ZIndex = 3
	TitleLabel.Parent = Topbar

	-- Topbar buttons (Win11 style: small equal squares)
	local BTN_SIZE = 24

	local CloseBtn = Instance.new("TextButton")
	CloseBtn.Name = "Close"
	CloseBtn.Size = UDim2.new(0, BTN_SIZE, 0, BTN_SIZE)
	CloseBtn.Position = UDim2.new(1, -BTN_SIZE - 8, 0.5, -BTN_SIZE / 2)
	CloseBtn.BackgroundColor3 = W11.Surface
	CloseBtn.Text = ""
	CloseBtn.AutoButtonColor = false
	CloseBtn.ZIndex = 4
	CloseBtn.Parent = Topbar
	Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 4)
	local CloseBtnX = Instance.new("TextLabel")
	CloseBtnX.Size = UDim2.new(1, 0, 1, 0)
	CloseBtnX.BackgroundTransparency = 1
	CloseBtnX.Text = "X"
	CloseBtnX.TextColor3 = W11.Text
	CloseBtnX.Font = Enum.Font.SourceSans
	CloseBtnX.TextSize = 16
	CloseBtnX.ZIndex = 5
	CloseBtnX.Parent = CloseBtn

	local MinBtn = Instance.new("TextButton")
	MinBtn.Name = "Minimize"
	MinBtn.Size = UDim2.new(0, BTN_SIZE, 0, BTN_SIZE)
	MinBtn.Position = UDim2.new(1, -BTN_SIZE * 2 - 14, 0.5, -BTN_SIZE / 2)
	MinBtn.BackgroundColor3 = W11.Surface
	MinBtn.Text = ""
	MinBtn.AutoButtonColor = false
	MinBtn.ZIndex = 4
	MinBtn.Parent = Topbar
	Instance.new("UICorner", MinBtn).CornerRadius = UDim.new(0, 4)
	local MinBtnDash = Instance.new("TextLabel")
	MinBtnDash.Size = UDim2.new(1, 0, 1, 0)
	MinBtnDash.BackgroundTransparency = 1
	MinBtnDash.Text = "-"
	MinBtnDash.TextColor3 = W11.TextSecondary
	MinBtnDash.Font = Enum.Font.SourceSans
	MinBtnDash.TextSize = 16
	MinBtnDash.ZIndex = 5
	MinBtnDash.Parent = MinBtn

	-- Reload button (restart server)
	local ReloadBtn = Instance.new("TextButton")
	ReloadBtn.Name = "Reload"
	ReloadBtn.Size = UDim2.new(0, BTN_SIZE, 0, BTN_SIZE)
	ReloadBtn.Position = UDim2.new(1, -BTN_SIZE * 3 - 20, 0.5, -BTN_SIZE / 2)
	ReloadBtn.BackgroundColor3 = W11.Surface
	ReloadBtn.Text = ""
	ReloadBtn.AutoButtonColor = false
	ReloadBtn.ZIndex = 4
	ReloadBtn.Parent = Topbar
	Instance.new("UICorner", ReloadBtn).CornerRadius = UDim.new(0, 4)
	local ReloadBtnIcon = Instance.new("TextLabel")
	ReloadBtnIcon.Size = UDim2.new(1, 0, 1, 0)
	ReloadBtnIcon.BackgroundTransparency = 1
	ReloadBtnIcon.Text = "R"
	ReloadBtnIcon.TextColor3 = W11.TextSecondary
	ReloadBtnIcon.Font = Enum.Font.SourceSans
	ReloadBtnIcon.TextSize = 16
	ReloadBtnIcon.ZIndex = 5
	ReloadBtnIcon.Parent = ReloadBtn

	-- Reload hover effect
	ReloadBtn.MouseEnter:Connect(function()
		TweenService:Create(ReloadBtn, GH.TI, { BackgroundColor3 = W11.AccentDark }):Play()
		TweenService:Create(ReloadBtnIcon, GH.TI, { TextColor3 = W11.AccentGlow }):Play()
	end)
	ReloadBtn.MouseLeave:Connect(function()
		TweenService:Create(ReloadBtn, GH.TI, { BackgroundColor3 = W11.Surface }):Play()
		TweenService:Create(ReloadBtnIcon, GH.TI, { TextColor3 = W11.TextSecondary }):Play()
	end)

	-- Reload click: restart server (same as ServerRejoin)
	ReloadBtn.MouseButton1Click:Connect(function()
		task.spawn(function()
			pcall(function()
				game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer)
			end)
		end)
		GH.ShowToast("Reiniciando servidor...", W11.Accent, 3)
	end)

	-- ==========================================
	-- SIDEBAR
	-- ==========================================
	local Sidebar = Instance.new("Frame")
	Sidebar.Name = "Sidebar"
	Sidebar.Size = UDim2.new(0, SidebarW, 1, -TopbarH)
	Sidebar.Position = UDim2.new(0, 0, 0, TopbarH)
	Sidebar.BackgroundColor3 = Color3.fromRGB(14, 14, 17)
	Sidebar.BorderSizePixel = 0
	Sidebar.ZIndex = 2
	Sidebar.ClipsDescendants = true
	Sidebar.Parent = MainFrame

	-- Accent bar left (behind buttons) — parented to MainFrame to avoid UIListLayout
	local AccentBar = Instance.new("Frame")
	AccentBar.Name = "AccentBar"
	AccentBar.Size = UDim2.new(0, 2, 1, -TopbarH)
	AccentBar.Position = UDim2.new(0, 0, 0, TopbarH)
	AccentBar.BackgroundColor3 = W11.Accent
	AccentBar.BackgroundTransparency = 0.6
	AccentBar.BorderSizePixel = 0
	AccentBar.ZIndex = 3
	AccentBar.Parent = MainFrame

	-- Sidebar right border — parented to MainFrame to avoid UIListLayout
	local SidebarBorder = Instance.new("Frame")
	SidebarBorder.Name = "SidebarBorder"
	SidebarBorder.Size = UDim2.new(0, 1, 1, -TopbarH)
	SidebarBorder.Position = UDim2.new(0, SidebarW - 1, 0, TopbarH)
	SidebarBorder.BackgroundColor3 = W11.Border
	SidebarBorder.BackgroundTransparency = 0.5
	SidebarBorder.BorderSizePixel = 0
	SidebarBorder.ZIndex = 3
	SidebarBorder.Parent = MainFrame

	local SidebarLayout = Instance.new("UIListLayout")
	SidebarLayout.SortOrder = Enum.SortOrder.LayoutOrder
	SidebarLayout.Padding = UDim.new(0, 3)
	SidebarLayout.Parent = Sidebar
	Instance.new("UIPadding", Sidebar).PaddingLeft = UDim.new(0, 6)
	Instance.new("UIPadding", Sidebar).PaddingTop = UDim.new(0, 6)

	-- ==========================================
	-- CONTENT AREA
	-- ==========================================
	local Content = Instance.new("Frame")
	Content.Name = "Content"
	Content.Size = UDim2.new(1, -(SidebarW + 2), 1, -(TopbarH + 8))
	Content.Position = UDim2.new(0, SidebarW + 1, 0, TopbarH + 4)
	Content.BackgroundTransparency = 1
	Content.ZIndex = 2
	Content.Parent = MainFrame
	Instance.new("UIPadding", Content).PaddingLeft = UDim.new(0, 4)
	Instance.new("UIPadding", Content).PaddingRight = UDim.new(0, 4)

	-- ==========================================
	-- SETTINGS TAB (via sidebar, same as other tabs)
	-- ==========================================
	local SettingsContainer = Instance.new("ScrollingFrame")
	SettingsContainer.Name = "Tab_Settings"
	SettingsContainer.Size = UDim2.new(1, 0, 1, -30)
	SettingsContainer.Position = UDim2.new(0, 0, 0, 30)
	SettingsContainer.BackgroundTransparency = 1
	SettingsContainer.ScrollBarThickness = 3
	SettingsContainer.ScrollBarImageColor3 = W11.Accent
	SettingsContainer.AutomaticCanvasSize = Enum.AutomaticSize.Y
	SettingsContainer.CanvasSize = UDim2.new(0, 0, 0, 0)
	SettingsContainer.BorderSizePixel = 0
	SettingsContainer.Visible = false
	SettingsContainer.ZIndex = 3
	SettingsContainer.Parent = Content
	Instance.new("UIListLayout", SettingsContainer).Padding = UDim.new(0, 3)
	SettingsContainer.UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
	Instance.new("UIPadding", SettingsContainer).PaddingTop = UDim.new(0, 2)

	-- ==========================================
	-- TOAST CONTAINER
	-- ==========================================
	GH.ToastContainer = nil
	GH._toastIndex = 0

	-- ==========================================
	-- SIDEBAR TABS + CONTENT TABS
	-- ==========================================
	local Categories = GH.Categories
	local TabContainers = {} -- ScrollingFrame instances (for CreateToggle + .Visible)
	local TabAPIs = {} -- Wrapper tables with AddDropdown/AddSection/AddInput methods (for GH.Tabs)
	local TabButtons = {}
	local ActiveTab = "Combat"

	for _, cat in ipairs(Categories) do
		local btn = Instance.new("TextButton")
		btn.Name = cat.Name
		btn.Size = UDim2.new(1, -4, 0, 30)
		btn.BackgroundColor3 = (cat.Name == ActiveTab) and Color3.fromRGB(10, 35, 60) or Color3.fromRGB(30, 30, 36)
		btn.Text = "  " .. cat.Name
		btn.TextColor3 = (cat.Name == ActiveTab) and W11.Accent or Color3.fromRGB(200, 200, 210)
		btn.Font = FontBold
		btn.TextSize = 11
		btn.TextXAlignment = Enum.TextXAlignment.Left
		btn.AutoButtonColor = false
		btn.LayoutOrder = cat.Order
		btn.ZIndex = 5
		btn.Parent = Sidebar
		Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 5)

		-- Active indicator bar on left
		local indicator = Instance.new("Frame")
		indicator.Name = "Indicator"
		indicator.Size = UDim2.new(0, 2, 0, 16)
		indicator.Position = UDim2.new(0, 0, 0.5, -8)
		indicator.BackgroundColor3 = W11.Accent
		indicator.BorderSizePixel = 0
		indicator.ZIndex = 6
		indicator.Visible = (cat.Name == ActiveTab)
		indicator.Parent = btn

		btn.MouseEnter:Connect(function()
			if ActiveTab ~= cat.Name then
				TweenService:Create(btn, GH.TI, { BackgroundColor3 = Color3.fromRGB(40, 40, 48) }):Play()
				TweenService:Create(btn, GH.TI, { TextColor3 = Color3.fromRGB(235, 235, 240) }):Play()
			end
		end)
		btn.MouseLeave:Connect(function()
			if ActiveTab ~= cat.Name then
				TweenService:Create(btn, GH.TI, { BackgroundColor3 = Color3.fromRGB(30, 30, 36) }):Play()
				TweenService:Create(btn, GH.TI, { TextColor3 = Color3.fromRGB(200, 200, 210) }):Play()
			end
		end)

		-- Use existing SettingsContainer for Settings tab, create new for others
		local container
		if cat.Name == "Settings" then
			container = SettingsContainer
			container.Visible = false
		else
			container = Instance.new("ScrollingFrame")
			container.Name = "Tab_" .. cat.Name
			container.Size = UDim2.new(1, 0, 1, -30)
			container.Position = UDim2.new(0, 0, 0, 30)
			container.BackgroundTransparency = 1
			container.ScrollBarThickness = 3
			container.ScrollBarImageColor3 = W11.Accent
			container.AutomaticCanvasSize = Enum.AutomaticSize.Y
			container.CanvasSize = UDim2.new(0, 0, 0, 0)
			container.BorderSizePixel = 0
			container.Visible = (cat.Name == ActiveTab)
			container.ZIndex = 3
			container.Parent = Content
			Instance.new("UIListLayout", container).Padding = UDim.new(0, 3)
			container.UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
			Instance.new("UIPadding", container).PaddingTop = UDim.new(0, 2)
		end

		TabContainers[cat.Name] = container

		btn.MouseButton1Click:Connect(function()
			if ActiveTab == cat.Name then return end
			if TabContainers[ActiveTab] then TabContainers[ActiveTab].Visible = false end
			if TabButtons[ActiveTab] then
				TweenService:Create(TabButtons[ActiveTab], GH.TI, { BackgroundColor3 = Color3.fromRGB(30, 30, 36), TextColor3 = Color3.fromRGB(200, 200, 210) }):Play()
				local oldIndicator = TabButtons[ActiveTab]:FindFirstChild("Indicator")
				if oldIndicator then oldIndicator.Visible = false end
			end
			ActiveTab = cat.Name
			if TabContainers[ActiveTab] then TabContainers[ActiveTab].Visible = true end
			TweenService:Create(btn, GH.TI, { BackgroundColor3 = Color3.fromRGB(10, 35, 60), TextColor3 = W11.Accent }):Play()
			indicator.Visible = true
		end)

		TabButtons[cat.Name] = btn
	end

	-- ==========================================
	-- SEARCH BAR (DEPOIS das tabs para ficar por cima)
	-- ==========================================
	local SearchBar = Instance.new("TextBox")
	SearchBar.Name = "SearchBar"
	SearchBar.Size = UDim2.new(1, -32, 0, 28)
	SearchBar.Position = UDim2.new(0, 0, 0, 0)
	SearchBar.BackgroundColor3 = Color3.fromRGB(28, 28, 32)
	SearchBar.PlaceholderText = "Procurar comando..."
	SearchBar.PlaceholderColor3 = Color3.fromRGB(90, 90, 105)
	SearchBar.Text = ""
	SearchBar.TextColor3 = W11.Text
	SearchBar.Font = Font
	SearchBar.TextSize = 11
	SearchBar.TextXAlignment = Enum.TextXAlignment.Left
	SearchBar.ClearTextOnFocus = false
	SearchBar.ZIndex = 10
	SearchBar.Parent = Content
	Instance.new("UICorner", SearchBar).CornerRadius = UDim.new(0, 6)
	Instance.new("UIPadding", SearchBar).PaddingLeft = UDim.new(0, 8)

	-- Clear button (X)
	local SearchClear = Instance.new("TextButton")
	SearchClear.Name = "ClearBtn"
	SearchClear.Size = UDim2.new(0, 22, 0, 22)
	SearchClear.Position = UDim2.new(1, -26, 0.5, -11)
	SearchClear.BackgroundColor3 = Color3.fromRGB(50, 50, 58)
	SearchClear.Text = ""
	SearchClear.AutoButtonColor = false
	SearchClear.Visible = false
	SearchClear.ZIndex = 11
	SearchClear.Parent = SearchBar
	Instance.new("UICorner", SearchClear).CornerRadius = UDim.new(0, 4)
	local ClearX = Instance.new("TextLabel")
	ClearX.Size = UDim2.new(1, 0, 1, 0)
	ClearX.BackgroundTransparency = 1
	ClearX.Text = "X"
	ClearX.TextColor3 = W11.TextSecondary
	ClearX.Font = Enum.Font.SourceSans
	ClearX.TextSize = 12
	ClearX.ZIndex = 12
	ClearX.Parent = SearchClear
	SearchClear.MouseEnter:Connect(function()
		TweenService:Create(ClearX, GH.TI, { TextColor3 = W11.Red }):Play()
	end)
	SearchClear.MouseLeave:Connect(function()
		TweenService:Create(ClearX, GH.TI, { TextColor3 = W11.TextSecondary }):Play()
	end)

	-- Hover effect for search bar
	SearchBar.Focused:Connect(function()
		TweenService:Create(SearchBar, GH.TI, { BackgroundColor3 = Color3.fromRGB(35, 35, 42) }):Play()
	end)
	SearchBar.FocusLost:Connect(function()
		TweenService:Create(SearchBar, GH.TI, { BackgroundColor3 = Color3.fromRGB(28, 28, 32) }):Play()
	end)

	GH.Tabs = TabAPIs

	-- ==========================================
	-- SEARCH FILTER (pesquisa em TODAS as abas, nome + descricao)
	-- ==========================================
	local PreviousActiveTab = ActiveTab

	local function FilterToggles(text)
		local search = text:lower():gsub("%s+", "")
		local totalMatches = 0
		local firstMatchTab = nil
		local isSearching = (search ~= "")

		for catName, container in pairs(TabContainers) do
			if catName ~= "Settings" then
				for _, child in ipairs(container:GetChildren()) do
					if child:IsA("TextButton") then
						local label = child:FindFirstChild("GH_ToggleLabel")
						local desc = child:FindFirstChild("GH_DescLabel")
						if label then
							local cmdName = label.Text:lower():gsub("%s+", "")
							local cmdDesc = desc and desc.Text:lower():gsub("%s+", "") or ""
							local match = (search == "") or cmdName:find(search, 1, true) or cmdDesc:find(search, 1, true)
							child.Visible = match
							if match and search ~= "" then
								totalMatches = totalMatches + 1
								if not firstMatchTab then firstMatchTab = catName end
							end
						end
					end
				end
			end
		end

		-- Auto-mudar para aba com resultado quando pesquisando
		if isSearching and firstMatchTab and firstMatchTab ~= ActiveTab then
			PreviousActiveTab = ActiveTab
			if TabContainers[ActiveTab] then TabContainers[ActiveTab].Visible = false end
			if TabButtons[ActiveTab] then
				TweenService:Create(TabButtons[ActiveTab], GH.TI, { BackgroundColor3 = Color3.fromRGB(30, 30, 36), TextColor3 = Color3.fromRGB(200, 200, 210) }):Play()
				local oldIndicator = TabButtons[ActiveTab]:FindFirstChild("Indicator")
				if oldIndicator then oldIndicator.Visible = false end
			end
			ActiveTab = firstMatchTab
			if TabContainers[ActiveTab] then TabContainers[ActiveTab].Visible = true end
			if TabButtons[ActiveTab] then
				TweenService:Create(TabButtons[ActiveTab], GH.TI, { BackgroundColor3 = Color3.fromRGB(10, 35, 60), TextColor3 = W11.Accent }):Play()
				local newIndicator = TabButtons[ActiveTab]:FindFirstChild("Indicator")
				if newIndicator then newIndicator.Visible = true end
			end
			Sidebar.Visible = true
			Content.Visible = true
		end

		-- Restaurar aba anterior quando limpar busca
		if not isSearching and PreviousActiveTab and PreviousActiveTab ~= ActiveTab then
			if TabContainers[ActiveTab] then TabContainers[ActiveTab].Visible = false end
			if TabButtons[ActiveTab] then
				TweenService:Create(TabButtons[ActiveTab], GH.TI, { BackgroundColor3 = Color3.fromRGB(30, 30, 36), TextColor3 = Color3.fromRGB(200, 200, 210) }):Play()
				local oldIndicator = TabButtons[ActiveTab]:FindFirstChild("Indicator")
				if oldIndicator then oldIndicator.Visible = false end
			end
			ActiveTab = PreviousActiveTab
			if TabContainers[ActiveTab] then TabContainers[ActiveTab].Visible = true end
			if TabButtons[ActiveTab] then
				TweenService:Create(TabButtons[ActiveTab], GH.TI, { BackgroundColor3 = Color3.fromRGB(10, 35, 60), TextColor3 = W11.Accent }):Play()
				local newIndicator = TabButtons[ActiveTab]:FindFirstChild("Indicator")
				if newIndicator then newIndicator.Visible = true end
			end
		end
	end

	SearchBar:GetPropertyChangedSignal("Text"):Connect(function()
		SearchClear.Visible = (SearchBar.Text ~= "")
		FilterToggles(SearchBar.Text)
	end)

	SearchClear.MouseButton1Click:Connect(function()
		SearchBar.Text = ""
		SearchClear.Visible = false
		FilterToggles("")
	end)

	-- ==========================================
	-- FLUENT-LIKE API for TabContainers
	-- ==========================================
	local function WireTabAPI(api)
		local container = api._frame
		local orderCounter = 0

		function api:AddDropdown(id, config)
			orderCounter += 1
			local frame = Instance.new("Frame")
			frame.Name = id
			frame.Size = UDim2.new(1, 0, 0, 38)
			frame.BackgroundColor3 = W11.Surface
			frame.BorderSizePixel = 0
			frame.LayoutOrder = orderCounter * 100
			frame.ZIndex = 4
			frame.Parent = container
			Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 5)

			local title = Instance.new("TextLabel")
			title.Size = UDim2.new(0.6, 0, 0, 14)
			title.Position = UDim2.new(0, 10, 0, 4)
			title.BackgroundTransparency = 1
			title.Text = config.Title or id
			title.TextColor3 = W11.TextSecondary
			title.Font = Font
			title.TextSize = 10
			title.TextXAlignment = Enum.TextXAlignment.Left
			title.ZIndex = 5
			title.Parent = frame

			-- Dropdown button
			local dropBtn = Instance.new("TextButton")
			dropBtn.Size = UDim2.new(0.38, -6, 0, 22)
			dropBtn.Position = UDim2.new(0.6, 4, 0, 8)
			dropBtn.BackgroundColor3 = W11.OffBG
			dropBtn.Text = "  Select..."
			dropBtn.TextColor3 = W11.TextMuted
			dropBtn.Font = Font
			dropBtn.TextSize = 10
			dropBtn.TextXAlignment = Enum.TextXAlignment.Left
			dropBtn.AutoButtonColor = false
			dropBtn.ZIndex = 5
			dropBtn.Parent = frame
			Instance.new("UICorner", dropBtn).CornerRadius = UDim.new(0, 4)

			-- Arrow indicator
			local arrow = Instance.new("TextLabel")
			arrow.Size = UDim2.new(0, 14, 1, 0)
			arrow.Position = UDim2.new(1, -16, 0, 0)
			arrow.BackgroundTransparency = 1
			arrow.Text = "▼"
			arrow.TextColor3 = W11.TextMuted
			arrow.Font = Font
			arrow.TextSize = 8
			arrow.ZIndex = 6
			arrow.Parent = dropBtn

			-- Dropdown list (hidden by default)
			local listFrame = Instance.new("Frame")
			listFrame.Name = "DropdownList"
			listFrame.Size = UDim2.new(0, dropBtn.AbsoluteSize.X, 0, 0)
			listFrame.Position = UDim2.new(0.6, 4, 0, 32)
			listFrame.BackgroundColor3 = W11.Surface
			listFrame.BorderSizePixel = 0
			listFrame.ClipsDescendants = true
			listFrame.ZIndex = 20
			listFrame.Visible = false
			listFrame.Parent = frame
			Instance.new("UICorner", listFrame).CornerRadius = UDim.new(0, 4)
			local listStroke = Instance.new("UIStroke")
			listStroke.Color = W11.Border
			listStroke.Thickness = 1
			listStroke.Parent = listFrame

			local listScroll = Instance.new("ScrollingFrame")
			listScroll.Size = UDim2.new(1, -4, 1, -4)
			listScroll.Position = UDim2.new(0, 2, 0, 2)
			listScroll.BackgroundTransparency = 1
			listScroll.ScrollBarThickness = 2
			listScroll.ScrollBarImageColor3 = W11.Accent
			listScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
			listScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
			listScroll.BorderSizePixel = 0
			listScroll.ZIndex = 21
			listScroll.Parent = listFrame
			Instance.new("UIListLayout", listScroll).Padding = UDim.new(0, 1)
			listScroll.UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder

			local dropdownObj = {
				Value = nil,
				_values = config.Values or {},
				_callbacks = {},
				_listFrame = listFrame,
				_dropBtn = dropBtn,
				_title = title,
			}

			local function buildList(values)
				for _, child in ipairs(listScroll:GetChildren()) do
					if child:IsA("TextButton") then child:Destroy() end
				end
				for i, val in ipairs(values) do
					local opt = Instance.new("TextButton")
					opt.Name = val
					opt.Size = UDim2.new(1, 0, 0, 24)
					opt.BackgroundColor3 = W11.Surface
					opt.Text = "  " .. tostring(val)
					opt.TextColor3 = W11.TextSecondary
					opt.Font = Font
					opt.TextSize = 10
					opt.TextXAlignment = Enum.TextXAlignment.Left
					opt.AutoButtonColor = false
					opt.LayoutOrder = i
					opt.ZIndex = 22
					opt.Parent = listScroll
					Instance.new("UICorner", opt).CornerRadius = UDim.new(0, 3)

					opt.MouseEnter:Connect(function()
						TweenService:Create(opt, GH.TI, { BackgroundColor3 = W11.SurfaceHover }):Play()
					end)
					opt.MouseLeave:Connect(function()
						TweenService:Create(opt, GH.TI, { BackgroundColor3 = W11.Surface }):Play()
					end)
					opt.MouseButton1Click:Connect(function()
						dropdownObj.Value = val
						dropBtn.Text = "  " .. tostring(val)
						dropBtn.TextColor3 = W11.Text
						TweenService:Create(listFrame, GH.TI, { Size = UDim2.new(0, dropBtn.AbsoluteSize.X, 0, 0) }):Play()
						task.delay(0.15, function() listFrame.Visible = false end)
						for _, cb in ipairs(dropdownObj._callbacks) do
							pcall(cb, val)
						end
					end)
				end
			end

			function dropdownObj:SetValues(values)
				self._values = values
				buildList(values)
			end

			function dropdownObj:OnChanged(callback)
				table.insert(self._callbacks, callback)
			end

			function dropdownObj:Destroy()
				frame:Destroy()
			end

			buildList(dropdownObj._values)

			-- Toggle list open/close
			dropBtn.MouseButton1Click:Connect(function()
				if listFrame.Visible then
					TweenService:Create(listFrame, GH.TI, { Size = UDim2.new(0, dropBtn.AbsoluteSize.X, 0, 0) }):Play()
					task.delay(0.15, function() listFrame.Visible = false end)
				else
					listFrame.Visible = true
					local itemCount = #dropdownObj._values
					local listH = math.min(itemCount * 25 + 4, 150)
					TweenService:Create(listFrame, GH.TI, { Size = UDim2.new(0, dropBtn.AbsoluteSize.X, 0, listH) }):Play()
				end
			end)

			-- Update list width when absolute size changes
			dropBtn:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
				if listFrame.Visible then
					listFrame.Size = UDim2.new(0, dropBtn.AbsoluteSize.X, 0, listFrame.Size.Y.Offset)
				end
			end)

			return dropdownObj
		end

		function api:AddSection(title)
			orderCounter += 1
			local sectionLabel = Instance.new("TextLabel")
			sectionLabel.Size = UDim2.new(1, 0, 0, 18)
			sectionLabel.BackgroundTransparency = 1
			sectionLabel.Text = "── " .. title .. " ──"
			sectionLabel.TextColor3 = W11.TextMuted
			sectionLabel.Font = FontBold
			sectionLabel.TextSize = 10
			sectionLabel.TextXAlignment = Enum.TextXAlignment.Left
			sectionLabel.LayoutOrder = orderCounter * 100
			sectionLabel.ZIndex = 4
			sectionLabel.Parent = container

			local sectionObj = {}

			function sectionObj:AddParagraph(config)
				orderCounter += 1
				local pFrame = Instance.new("Frame")
				pFrame.Size = UDim2.new(1, 0, 0, 36)
				pFrame.BackgroundColor3 = W11.Surface
				pFrame.BackgroundTransparency = 0.3
				pFrame.BorderSizePixel = 0
				pFrame.LayoutOrder = orderCounter * 100
				pFrame.ZIndex = 4
				pFrame.Parent = container
				Instance.new("UICorner", pFrame).CornerRadius = UDim.new(0, 4)

				local pTitle = Instance.new("TextLabel")
				pTitle.Size = UDim2.new(1, -12, 0, 14)
				pTitle.Position = UDim2.new(0, 8, 0, 4)
				pTitle.BackgroundTransparency = 1
				pTitle.Text = config.Title or ""
				pTitle.TextColor3 = W11.Text
				pTitle.Font = FontBold
				pTitle.TextSize = 10
				pTitle.TextXAlignment = Enum.TextXAlignment.Left
				pTitle.ZIndex = 5
				pTitle.Parent = pFrame

				local pContent = Instance.new("TextLabel")
				pContent.Size = UDim2.new(1, -12, 0, 14)
				pContent.Position = UDim2.new(0, 8, 0, 20)
				pContent.BackgroundTransparency = 1
				pContent.Text = config.Content or ""
				pContent.TextColor3 = W11.Accent
				pContent.Font = Font
				pContent.TextSize = 10
				pContent.TextXAlignment = Enum.TextXAlignment.Left
				pContent.ZIndex = 5
				pContent.Parent = pFrame

				local pObj = {}
				function pObj:SetTitle(t) pTitle.Text = t end
				function pObj:SetDesc(d) pContent.Text = d end
				function pObj:Destroy() pFrame:Destroy() end
				return pObj
			end

			function sectionObj:AddButton(config)
				orderCounter += 1
				local bFrame = Instance.new("TextButton")
				bFrame.Size = UDim2.new(1, 0, 0, 28)
				bFrame.BackgroundColor3 = W11.AccentDim
				bFrame.Text = ""
				bFrame.AutoButtonColor = false
				bFrame.LayoutOrder = orderCounter * 100
				bFrame.ZIndex = 4
				bFrame.Parent = container
				Instance.new("UICorner", bFrame).CornerRadius = UDim.new(0, 4)

				local bLabel = Instance.new("TextLabel")
				bLabel.Size = UDim2.new(1, -16, 1, 0)
				bLabel.Position = UDim2.new(0, 10, 0, 0)
				bLabel.BackgroundTransparency = 1
				bLabel.Text = config.Title or "Button"
				bLabel.TextColor3 = W11.Text
				bLabel.Font = Font
				bLabel.TextSize = 11
				bLabel.TextXAlignment = Enum.TextXAlignment.Left
				bLabel.ZIndex = 5
				bLabel.Parent = bFrame

				bFrame.MouseEnter:Connect(function()
					TweenService:Create(bFrame, GH.TI, { BackgroundColor3 = W11.Accent }):Play()
				end)
				bFrame.MouseLeave:Connect(function()
					TweenService:Create(bFrame, GH.TI, { BackgroundColor3 = W11.AccentDim }):Play()
				end)
				bFrame.MouseButton1Click:Connect(function()
					if config.Callback then pcall(config.Callback) end
				end)

				local bObj = {}
				function bObj:Destroy() bFrame:Destroy() end
				return bObj
			end

			function sectionObj:AddDropdown(id, config)
				return api:AddDropdown(id, config)
			end

			return sectionObj
		end

		function api:AddInput(id, config)
			orderCounter += 1
			local frame = Instance.new("Frame")
			frame.Name = id
			frame.Size = UDim2.new(1, 0, 0, 38)
			frame.BackgroundColor3 = W11.Surface
			frame.BorderSizePixel = 0
			frame.LayoutOrder = orderCounter * 100
			frame.ZIndex = 4
			frame.Parent = container
			Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 5)

			local title = Instance.new("TextLabel")
			title.Size = UDim2.new(1, -12, 0, 14)
			title.Position = UDim2.new(0, 10, 0, 4)
			title.BackgroundTransparency = 1
			title.Text = config.Title or id
			title.TextColor3 = W11.TextSecondary
			title.Font = Font
			title.TextSize = 10
			title.TextXAlignment = Enum.TextXAlignment.Left
			title.ZIndex = 5
			title.Parent = frame

			local inputBox = Instance.new("TextBox")
			inputBox.Size = UDim2.new(1, -20, 0, 20)
			inputBox.Position = UDim2.new(0, 10, 0, 20)
			inputBox.BackgroundColor3 = W11.OffBG
			inputBox.PlaceholderText = config.Placeholder or ""
			inputBox.PlaceholderColor3 = W11.TextMuted
			inputBox.Text = ""
			inputBox.TextColor3 = W11.Text
			inputBox.Font = Font
			inputBox.TextSize = 10
			inputBox.TextXAlignment = Enum.TextXAlignment.Left
			inputBox.ClearTextOnFocus = false
			inputBox.ZIndex = 5
			inputBox.Parent = frame
			Instance.new("UICorner", inputBox).CornerRadius = UDim.new(0, 3)
			Instance.new("UIPadding", inputBox).PaddingLeft = UDim.new(0, 6)

			local inputObj = {}

			if config.Callback then
				if config.Finished then
					inputBox.FocusLost:Connect(function(enterPressed)
						if enterPressed then
							pcall(config.Callback, inputBox.Text)
						end
					end)
				else
					inputBox:GetPropertyChangedSignal("Text"):Connect(function()
						pcall(config.Callback, inputBox.Text)
					end)
				end
			end

			function inputObj:Destroy() frame:Destroy() end
			return inputObj
		end
	end

	-- Wire API to all tab containers (via wrapper tables, not Instances)
	for _, cat in ipairs(Categories) do
		if TabContainers[cat.Name] then
			local api = { _frame = TabContainers[cat.Name] }
			WireTabAPI(api)
			TabAPIs[cat.Name] = api
		end
	end

	-- ==========================================
	-- CREATE TOGGLE BUTTON (Win11 style)
	-- ==========================================
	local function CreateToggle(name, displayName, desc, category, callback)
		local target = TabContainers[category] or TabContainers["Combat"]
		if not target then return end
		GH.States[name] = false

		local frame = Instance.new("TextButton")
		frame.Name = name
		frame.Size = UDim2.new(1, 0, 0, BtnH)
		frame.BackgroundColor3 = W11.OffBG
		frame.Text = ""
		frame.AutoButtonColor = false
		frame.LayoutOrder = #target:GetChildren() + 1
		frame.ZIndex = 4
		frame.Parent = target
		Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 5)

		local label = Instance.new("TextLabel")
		label.Name = "GH_ToggleLabel"
		label.Size = UDim2.new(1, -50, 1, 0)
		label.Position = UDim2.new(0, 10, 0, 0)
		label.BackgroundTransparency = 1
		label.Text = "  " .. displayName
		label.TextColor3 = W11.Off
		label.Font = Font
		label.TextSize = 11
		label.TextXAlignment = Enum.TextXAlignment.Left
		label.ZIndex = 5
		label.Parent = frame

		if desc and desc ~= "" then
			local descLabel = Instance.new("TextLabel")
			descLabel.Name = "GH_DescLabel"
			descLabel.Size = UDim2.new(1, -50, 0, 12)
			descLabel.Position = UDim2.new(0, 10, 1, -14)
			descLabel.BackgroundTransparency = 1
			descLabel.Text = "  " .. desc
			descLabel.TextColor3 = W11.TextMuted
			descLabel.Font = Enum.Font.Gotham
			descLabel.TextSize = 8
			descLabel.TextXAlignment = Enum.TextXAlignment.Left
			descLabel.TextTruncate = Enum.TextTruncate.AtEnd
			descLabel.ZIndex = 5
			descLabel.Parent = frame
		end

		-- Toggle switch (compacto estilo SKECH)
		local switchBG = Instance.new("Frame")
		switchBG.Size = UDim2.new(0, 32, 0, 16)
		switchBG.Position = UDim2.new(1, -42, 0.5, -8)
		switchBG.BackgroundColor3 = W11.Surface
		switchBG.BorderSizePixel = 0
		switchBG.ZIndex = 5
		switchBG.Parent = frame
		Instance.new("UICorner", switchBG).CornerRadius = UDim.new(1, 0)

		local switchKnob = Instance.new("Frame")
		switchKnob.Size = UDim2.new(0, 12, 0, 12)
		switchKnob.Position = UDim2.new(0, 2, 0.5, -6)
		switchKnob.BackgroundColor3 = W11.TextSecondary
		switchKnob.BorderSizePixel = 0
		switchKnob.ZIndex = 6
		switchKnob.Parent = switchBG
		Instance.new("UICorner", switchKnob).CornerRadius = UDim.new(1, 0)

		local function setToggle(state)
			GH.States[name] = state
			if state then
				TweenService:Create(switchBG, GH.TI, { BackgroundColor3 = W11.Accent }):Play()
				TweenService:Create(switchKnob, GH.TI, { Position = UDim2.new(1, -14, 0.5, -6), BackgroundColor3 = Color3.new(1, 1, 1) }):Play()
				TweenService:Create(frame, GH.TI, { BackgroundColor3 = W11.OnBG }):Play()
				label.TextColor3 = W11.On
			else
				TweenService:Create(switchBG, GH.TI, { BackgroundColor3 = W11.Surface }):Play()
				TweenService:Create(switchKnob, GH.TI, { Position = UDim2.new(0, 2, 0.5, -6), BackgroundColor3 = W11.TextSecondary }):Play()
				TweenService:Create(frame, GH.TI, { BackgroundColor3 = W11.OffBG }):Play()
				label.TextColor3 = W11.Off
			end
		end

		frame.MouseEnter:Connect(function()
			TweenService:Create(frame, GH.TI, { BackgroundColor3 = W11.SurfaceHover }):Play()
		end)
		frame.MouseLeave:Connect(function()
			if not GH.States[name] then
				TweenService:Create(frame, GH.TI, { BackgroundColor3 = W11.OffBG }):Play()
			else
				TweenService:Create(frame, GH.TI, { BackgroundColor3 = W11.OnBG }):Play()
			end
		end)

		-- Proxy table (Roblox Instances are sealed, can't add custom methods)
		local proxy = {
			Instance = frame,
			Value = false,
			SetValue = function(self, state) self.Value = state; setToggle(state) end,
			SetTitle = function(_, text) label.Text = "  " .. text end,
			SetDesc = function(_, d) local dl = frame:FindFirstChild("GH_DescLabel"); if dl then dl.Text = "  " .. d end end,
			IsA = function(_, className) return frame:IsA(className) end,
		}

		frame.MouseButton1Click:Connect(function()
			local newState = not GH.States[name]
			setToggle(newState)
			if not GH.SilentRestore then
				local toastMsg = displayName .. (newState and (" " .. GH.T("toast_activated")) or (" " .. GH.T("toast_deactivated")))
				GH.ShowToast(toastMsg, newState and W11.On or W11.TextSecondary, 2)
			end
			pcall(callback, newState, proxy)
		end)

		GH.Buttons[name] = proxy
		GH.Callbacks[name] = callback
	end

	-- ==========================================
	-- SETTINGS UI HELPERS
	-- ==========================================
	local stOrder = 0

	local function stSection(text)
		stOrder += 1
		local s = Instance.new("TextLabel")
		s.Size = UDim2.new(1, 0, 0, 14)
		s.BackgroundTransparency = 1
		s.Text = "── " .. text .. " ──"
		s.TextColor3 = W11.TextMuted
		s.Font = FontBold
		s.TextSize = 9
		s.LayoutOrder = stOrder
		s.ZIndex = 3
		s.Parent = SettingsContainer
		stOrder += 1
	end

	local function stToggle(label, default, cb)
		stOrder += 1
		local frame = Instance.new("Frame")
		frame.Size = UDim2.new(1, 0, 0, 26)
		frame.BackgroundColor3 = W11.Surface
		frame.BorderSizePixel = 0
		frame.LayoutOrder = stOrder
		frame.ZIndex = 3
		frame.Parent = SettingsContainer
		Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 4)

		local lbl = Instance.new("TextLabel")
		lbl.Size = UDim2.new(0.7, 0, 1, 0)
		lbl.Position = UDim2.new(0, 8, 0, 0)
		lbl.BackgroundTransparency = 1
		lbl.Text = label
		lbl.TextColor3 = W11.Off
		lbl.Font = Font
		lbl.TextSize = 10
		lbl.TextXAlignment = Enum.TextXAlignment.Left
		lbl.ZIndex = 4
		lbl.Parent = frame

		local switchBG = Instance.new("Frame")
		switchBG.Size = UDim2.new(0, 28, 0, 14)
		switchBG.Position = UDim2.new(1, -36, 0.5, -7)
		switchBG.BackgroundColor3 = default and W11.Accent or W11.Surface
		switchBG.BorderSizePixel = 0
		switchBG.ZIndex = 4
		switchBG.Parent = frame
		Instance.new("UICorner", switchBG).CornerRadius = UDim.new(1, 0)

		local knob = Instance.new("Frame")
		knob.Size = UDim2.new(0, 10, 0, 10)
		knob.Position = UDim2.new(0, default and 16 or 2, 0.5, -5)
		knob.BackgroundColor3 = default and Color3.new(1, 1, 1) or W11.TextSecondary
		knob.BorderSizePixel = 0
		knob.ZIndex = 5
		knob.Parent = switchBG
		Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)

		local isOn = default
		frame.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 then
				isOn = not isOn
				TweenService:Create(switchBG, GH.TI, { BackgroundColor3 = isOn and W11.Accent or W11.Surface }):Play()
				TweenService:Create(knob, GH.TI, { Position = UDim2.new(0, isOn and 16 or 2, 0.5, -5), BackgroundColor3 = isOn and Color3.new(1, 1, 1) or W11.TextSecondary }):Play()
				if cb then cb(isOn) end
			end
		end)
	end

	local function stSlider(label, min, max, default, cb)
		stOrder += 1
		local frame = Instance.new("Frame")
		frame.Size = UDim2.new(1, 0, 0, 38)
		frame.BackgroundColor3 = W11.Surface
		frame.BorderSizePixel = 0
		frame.LayoutOrder = stOrder
		frame.ZIndex = 3
		frame.Parent = SettingsContainer
		Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 4)

		local lbl = Instance.new("TextLabel")
		lbl.Size = UDim2.new(0.55, 0, 0, 16)
		lbl.Position = UDim2.new(0, 8, 0, 4)
		lbl.BackgroundTransparency = 1
		lbl.Text = label
		lbl.TextColor3 = W11.Off
		lbl.Font = Font
		lbl.TextSize = 10
		lbl.TextXAlignment = Enum.TextXAlignment.Left
		lbl.ZIndex = 4
		lbl.Parent = frame

		local valLabel = Instance.new("TextLabel")
		valLabel.Size = UDim2.new(0.35, 0, 0, 16)
		valLabel.Position = UDim2.new(0.58, 0, 0, 4)
		valLabel.BackgroundTransparency = 1
		valLabel.Text = tostring(default)
		valLabel.TextColor3 = W11.Accent
		valLabel.Font = FontBold
		valLabel.TextSize = 10
		valLabel.TextXAlignment = Enum.TextXAlignment.Right
		valLabel.ZIndex = 4
		valLabel.Parent = frame

		local bar = Instance.new("Frame")
		bar.Size = UDim2.new(0.88, 0, 0, 4)
		bar.Position = UDim2.new(0.06, 0, 0, 28)
		bar.BackgroundColor3 = W11.BorderSubtle
		bar.BorderSizePixel = 0
		bar.ZIndex = 4
		bar.Parent = frame

		local fill = Instance.new("Frame")
		fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
		fill.BackgroundColor3 = W11.Accent
		fill.BorderSizePixel = 0
		fill.ZIndex = 5
		fill.Parent = bar

		local knob = Instance.new("Frame")
		knob.Size = UDim2.new(0, 8, 0, 8)
		knob.Position = UDim2.new((default - min) / (max - min), -4, 0.5, -4)
		knob.BackgroundColor3 = Color3.new(1, 1, 1)
		knob.BorderSizePixel = 0
		knob.ZIndex = 6
		knob.Parent = bar
		Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)

		local currentVal = default
		local inputBtn = Instance.new("TextButton")
		inputBtn.Size = UDim2.new(1, 10, 0, 20)
		inputBtn.Position = UDim2.new(0, -5, 0.5, -10)
		inputBtn.BackgroundTransparency = 1
		inputBtn.Text = ""
		inputBtn.ZIndex = 7
		inputBtn.Parent = bar

		inputBtn.MouseButton1Down:Connect(function()
			GH._activeSlider = function(x)
				local absPos = bar.AbsolutePosition.X
				local absSize = bar.AbsoluteSize.X
				if absSize == 0 then return end
				local ratio = math.clamp((x - absPos) / absSize, 0, 1)
				currentVal = math.floor(min + (max - min) * ratio)
				valLabel.Text = tostring(currentVal)
				fill.Size = UDim2.new(ratio, 0, 1, 0)
				knob.Position = UDim2.new(ratio, -5, 0.5, -5)
				if cb then cb(currentVal) end
			end
			GH._activeSlider(UserInputService:GetMouseLocation().X)
		end)
	end

	-- ==========================================
	-- MONTAR SETTINGS
	-- ==========================================
	stSection("GERAL")
	stSlider("Velocidade Fly", 5, 200, 20, function(v) GH.FlySpeed = v end)
	stSlider("Raio NoClip", 1, 20, 3.8, function(v) GH.Settings.NoClipRadius = v end)

	stSection("HITBOX")
	stSlider("Tamanho Hitbox", 5, 50, 15, function(v) GH.Settings.HitboxSize = v end)

	stSection("ESP")
	stToggle("Mostrar Tag", true, function(v) GH.Settings.ESPShowTag = v end)
	stToggle("Mostrar Nome", true, function(v) GH.Settings.ESPShowName = v end)
	stToggle("Mostrar Distancia", true, function(v) GH.Settings.ESPShowDistance = v end)
	stToggle("Mostrar HP", true, function(v) GH.Settings.ESPShowHealth = v end)
	stSlider("Distancia Max ESP", 50, 2000, 300, function(v) GH.Settings.ESPMaxDistance = v end)

	-- ==========================================
	-- FECHAR — Windows 11 style
	-- ==========================================
	CloseBtn.MouseButton1Click:Connect(function()
		GH.FullCleanup()
		pcall(function() ScreenGui:Destroy() end)
	end)

	-- Close button: Windows 11 style (red hover, white X)
	CloseBtn.MouseEnter:Connect(function()
		TweenService:Create(CloseBtn, GH.TI, { BackgroundColor3 = W11.Red, TextColor3 = Color3.new(1, 1, 1) }):Play()
	end)
	CloseBtn.MouseLeave:Connect(function()
		TweenService:Create(CloseBtn, GH.TI, { BackgroundColor3 = W11.Surface, TextColor3 = W11.Text }):Play()
	end)
	MinBtn.MouseEnter:Connect(function()
		TweenService:Create(MinBtn, GH.TI, { BackgroundColor3 = W11.SurfaceHover }):Play()
	end)
	MinBtn.MouseLeave:Connect(function()
		TweenService:Create(MinBtn, GH.TI, { BackgroundColor3 = W11.Surface }):Play()
	end)

	-- ==========================================
	-- MINIMIZAR
	-- ==========================================
	local minimized = false
	local NormalW, NormalH = PanelW, PanelH
	local MiniW, MiniH = 200, TopbarH

	MinBtn.MouseButton1Click:Connect(function()
		minimized = not minimized
		if minimized then
			Sidebar.Visible = false
			Content.Visible = false
			FPSLabel.Visible = false
			for _, c in pairs(TabContainers) do c.Visible = false end
			TweenService:Create(MainFrame, GH.TI_Slow, { Size = UDim2.new(0, MiniW, 0, MiniH) }):Play()
			MinBtn.Text = "+"
		else
			TweenService:Create(MainFrame, GH.TI_Slow, { Size = UDim2.new(0, NormalW, 0, NormalH) }):Play()
			MinBtn.Text = "—"
			task.delay(0.15, function()
				Sidebar.Visible = true
				Content.Visible = true
				FPSLabel.Visible = true
				if TabContainers[ActiveTab] then TabContainers[ActiveTab].Visible = true end
			end)
		end
	end)

	-- ==========================================
	-- DRAG (topbar)
	-- ==========================================
	local dragging, dragInput, dragStart, startPos
	local dragConn = nil

	Topbar.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			dragStart = input.Position
			startPos = MainFrame.Position
			if not dragConn then
				dragConn = RunService.Heartbeat:Connect(function()
					if not dragging then return end
					if dragInput then
						local delta = dragInput.Position - dragStart
						MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
					end
				end)
			end
			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					dragging = false
					if dragConn then dragConn:Disconnect(); dragConn = nil end
				end
			end)
		end
	end)

	Topbar.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
			dragInput = input
		end
	end)

	-- Slider global input
	GH.TrackGlobalConnection("SliderEnded", UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			GH._activeSlider = nil
		end
	end))
	GH.TrackGlobalConnection("SliderChanged", UserInputService.InputChanged:Connect(function(input)
		if GH._activeSlider and input.UserInputType == Enum.UserInputType.MouseMovement then
			GH._activeSlider(UserInputService:GetMouseLocation().X)
		end
	end))

	-- ==========================================
	-- TOGGLE HOTKEY (RightCtrl)
	-- ==========================================
	local panelVisible = true
	GH.InputManager.Bind(Enum.KeyCode.RightControl, function()
		panelVisible = not panelVisible
		MainFrame.Visible = panelVisible
	end)

	-- ==========================================
	-- PROCESSAR MODULES (toggles pendentes)
	-- ==========================================
	if #GH.PendingButtons == 0 then
		warn("[SYSTEM] AVISO: Nenhum modulo registrou toggle!")
	end

	pcall(function()
		table.sort(GH.PendingButtons, function(a, b)
			if a.category == b.category then return (a.localeKey or ""):lower() < (b.localeKey or ""):lower() end
			return (a.category or "") < (b.category or "")
		end)
	end)

	GH.SilentRestore = true
	for _, pending in ipairs(GH.PendingButtons) do
		local ok, err = pcall(function()
			CreateToggle(
				pending.name,
				GH.T(pending.localeKey or pending.name),
				pending.descKey and GH.T(pending.descKey) or "",
				pending.category,
				pending.callback
			)
		end)
		if not ok then warn("[SYSTEM] Erro ao criar toggle '" .. tostring(pending.name) .. "': " .. tostring(err)) end
	end
	GH.SilentRestore = false

	-- ==========================================
	-- CHARACTER ADDED: Reset + Restore
	-- ==========================================
	GH.TrackGlobalConnection("CharacterAdded", GH.LocalPlayer.CharacterAdded:Connect(function(char)
		if GH.Stopped then return end
		local wasActive = {}
		for name, state in pairs(GH.States) do
			if state then wasActive[name] = true end
		end
		GH.SilentRestore = true
		for name, _ in pairs(GH.States) do
			GH.UnregisterMasterLoop(name)
			GH.States[name] = false
			local btn = GH.Buttons[name]
			local callback = GH.Callbacks[name]
			if btn and callback then pcall(callback, false, btn) end
			if btn and btn.SetValue then pcall(btn.SetValue, btn, false) end
		end
		for name, conn in pairs(GH.Connections) do
			if conn and conn.Connected then pcall(conn.Disconnect, conn) end
		end
		table.clear(GH.Connections)
		task.defer(function()
			if GH.Stopped then return end
			for name, _ in pairs(wasActive) do
				if GH.States[name] == false and GH.Buttons[name] and GH.Callbacks[name] then
					GH.States[name] = true
					local btn = GH.Buttons[name]
					if btn and btn.SetValue then pcall(btn.SetValue, btn, true) end
					pcall(GH.Callbacks[name], true, btn)
				end
			end
			GH.SilentRestore = false
		end)
	end))

	-- ==========================================
	-- CLEANUP HOOKS
	-- ==========================================
	Players.PlayerRemoving:Connect(function(player)
		if player == GH.LocalPlayer then pcall(GH.FullCleanup) end
	end)
	if script then
		script.Destroying:Connect(function() pcall(GH.FullCleanup) end)
	end

	-- ==========================================
	-- INPUT MANAGER
	-- ==========================================
	GH.TrackGlobalConnection("InputManager_Began", UserInputService.InputBegan:Connect(function(input, gpe)
		if gpe then return end
		if input.UserInputType ~= Enum.UserInputType.Keyboard then return end
		local binding = GH.InputManager._bindings[input.KeyCode]
		if binding and binding.onDown then binding.onDown() end
	end))
	GH.TrackGlobalConnection("InputManager_Ended", UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType ~= Enum.UserInputType.Keyboard then return end
		local binding = GH.InputManager._bindings[input.KeyCode]
		if binding and binding.onUp then binding.onUp() end
	end))

	-- ==========================================
	-- MASTER LOOPS
	-- ==========================================
	GH.TrackGlobalConnection("MasterRender", RunService.RenderStepped:Connect(function()
		GH.MasterTick.Render += 1
		for name, callback in pairs(GH.MasterCallbacks.Render) do
			if GH.MasterTick.Render % 3 == 0 then pcall(callback) end
		end
	end))
	GH.TrackGlobalConnection("MasterHeartbeat", RunService.Heartbeat:Connect(function()
		GH.MasterTick.Heartbeat += 1
		for name, callback in pairs(GH.MasterCallbacks.Heartbeat) do pcall(callback) end
	end))
	GH.TrackGlobalConnection("MasterPreSim", RunService.PreSimulation:Connect(function()
		GH.MasterTick.PreSim += 1
		for name, callback in pairs(GH.MasterCallbacks.PreSim) do
			if GH.MasterTick.PreSim % 3 == 0 then pcall(callback) end
		end
	end))

	-- ==========================================
	-- NAMECALL HOOK
	-- ==========================================
	if hookmetamethod and checkcaller then
		local old_namecall = hookmetamethod(game, "__namecall", function(self, ...)
			if not checkcaller() then
				local method = getnamecallmethod()
				local args = {...}
				for _, handler in ipairs(GH.NamecallHandlers) do
					local handled = handler(self, method, args)
					if handled then return old_namecall(self, unpack(args)) end
				end
			end
			return old_namecall(self, ...)
		end)
	end

	-- ==========================================
	-- METRICS
	-- ==========================================
	task.spawn(function() GH.Stats.Start() end)

	-- ==========================================
	-- TOAST DE CARREGAMENTO
	-- ==========================================
	task.delay(0.5, function()
		local v = GH.Version and GH.Version.Hash or ""
		local msg = GH.T("toast_script_loaded")
		if v and v ~= "unknown" then msg = msg .. " (v" .. v .. ")" end
		GH.ShowToast(msg, W11.On, 5)
	end)

	-- ==========================================
	-- AUTO-UPDATE CHECKER (checa a cada 60s)
	-- ==========================================
	task.spawn(function()
		task.wait(30)
		local currentHash = GH.Version and GH.Version.Hash or "unknown"
		if currentHash == "unknown" then return end

		while not GH.Stopped do
			task.wait(60)
			if GH.Stopped then break end
			if not GH.ScreenGui or not GH.ScreenGui.Parent then break end

			local ok, result = pcall(function()
				local HttpService = game:GetService("HttpService")
				local resp = game:HttpGet(
					"https://api.github.com/repos/EricDs6/SYSTEM-SCRIPT-UNIVERSAL-ROBLOX/commits/main?_=" .. tostring(os.clock()):gsub("%.", ""),
					true
				)
				if resp then
					local data = HttpService:JSONDecode(resp)
					if data and data.sha then
						local latestHash = string.sub(data.sha, 1, 7)
						if latestHash ~= currentHash then
							GH.ShowToast(
								GH.T("toast_new_update") .. " (v" .. latestHash .. ")",
								Color3.fromRGB(255, 180, 0),
								nil,
								true
							)
							return true
						end
					end
				end
				return false
			end)
			if ok and result == true then break end
		end
	end)
end

-- ==========================================
-- RETURN GH
-- ==========================================
return GH
