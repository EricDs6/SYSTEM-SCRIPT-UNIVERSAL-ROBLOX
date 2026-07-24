-- =============================================================================
-- CORE — Sistema compartilhado entre todos os módulos (Fluent UI)
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
	_stats_injections = "Injecoes Totais",
		stats_device = "Meu Device",
		stats_status = "Status",
		stats_active = "Ativo",
		-- Toasts
		toast_activated = "Ativado!",
		toast_deactivated = "Desativado!",
		toast_script_loaded = "Script carregado com sucesso!",
		toast_debug_failed = "DEBUG: %s falhou",
		-- ESP
		esp_enemy = "[INIMIGO]",
		esp_ally = "[ALIADO]",
		esp_neutral = "[JOGADOR]",
		-- Toggle titles
		toggle_hitbox = "Hitbox Gigante",
		toggle_esp = "Ativar ESP",
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
		toggle_flashback = "Flashback",
		toggle_coords = "Coordenadas",
		toggle_serverrejoin = "Server Rejoin",
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
		toggle_trollfling = "Tornado Fling",
		toggle_targetfling = "Target Fling",
		toggle_spasms = "Spasmos",
		toggle_naked = "Naked",
		toggle_freeze = "Freeze All",
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
		desc_flashback = "Pressione P para voltar ao local da ultima morte",
		desc_coords = "Mostra coordenadas atuais e salva posicoes",
		desc_serverrejoin = "Reconecta ao mesmo servidor",
		desc_autoclicker = "Clique automatico segurando a tecla X",
		desc_proximityinstant = "Interacao instantanea com prompts sem segurar",
		desc_antiafk = "Impede ser desconectado por inatividade",
		desc_antikick = "Impede ser expulso do servidor",
		desc_autocollect = "Coleta automaticamente tools e itens proximos",
		desc_fireclickdetectors = "Ativa todos os ClickDetectors do mapa",
		desc_fireproximityprompts = "Ativa todos os ProximityPrompts do mapa",
		desc_btools = "Ferramentas de construcao (HopperBins)",
		desc_breakvelocity = "Reseta toda velocidade do personagem",
		desc_invisibleparts = "Mostra partes que estao invisiveis no mapa",
		desc_trollfling = "Gira rapidamente para jogar outros jogadores",
		desc_targetfling = "Seleciona um alvo e voa ate ele para derrubar",
		desc_spasms = "Animacao de convulsao (requer R6)",
		desc_naked = "Remove todas as roupas do seu personagem",
		desc_freeze = "Congela todos os jogadores no servidor",
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
		-- Toasts
		toast_activated = "Enabled!",
		toast_deactivated = "Disabled!",
		toast_script_loaded = "Script loaded successfully!",
		toast_debug_failed = "DEBUG: %s failed",
		-- ESP
		esp_enemy = "[ENEMY]",
		esp_ally = "[ALLY]",
		esp_neutral = "[PLAYER]",
		-- Toggle titles
		toggle_hitbox = "Giant Hitbox",
		toggle_esp = "Enable ESP",
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
		toggle_flashback = "Flashback",
		toggle_coords = "Coordinates",
		toggle_serverrejoin = "Server Rejoin",
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
		toggle_trollfling = "Tornado Fling",
		toggle_targetfling = "Target Fling",
		toggle_spasms = "Spasms",
		toggle_naked = "Naked",
		toggle_freeze = "Freeze All",
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
		desc_flashback = "Press P to return to last death location",
		desc_coords = "Shows current coordinates and saves positions",
		desc_serverrejoin = "Reconnect to the same server",
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
		desc_trollfling = "Spins rapidly to fling other players",
		desc_targetfling = "Select a target and fly to them to knock down",
		desc_spasms = "Convulsion animation (requires R6)",
		desc_naked = "Removes all clothes from your character",
		desc_freeze = "Freezes all players in the server",
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
		-- Toasts
		toast_activated = "Activado!",
		toast_deactivated = "Desactivado!",
		toast_script_loaded = "Script cargado con exito!",
		toast_debug_failed = "DEBUG: %s fallo",
		-- ESP
		esp_enemy = "[ENEMIGO]",
		esp_ally = "[ALIADO]",
		esp_neutral = "[JUGADOR]",
		-- Toggle titles
		toggle_hitbox = "Hitbox Gigante",
		toggle_esp = "Activar ESP",
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
		toggle_flashback = "Flashback",
		toggle_coords = "Coordenadas",
		toggle_serverrejoin = "Server Rejoin",
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
		toggle_trollfling = "Tornado Fling",
		toggle_targetfling = "Target Fling",
		toggle_spasms = "Espasmos",
		toggle_naked = "Naked",
		toggle_freeze = "Freeze All",
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
		desc_flashback = "Presiona P para volver al lugar de la ultima muerte",
		desc_coords = "Muestra coordenadas actuales y guarda posiciones",
		desc_serverrejoin = "Reconecta al mismo servidor",
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
		desc_trollfling = "Gira rapidamente para lanzar a otros jugadores",
		desc_targetfling = "Selecciona un objetivo y vuela hasta el para derribar",
		desc_spasms = "Animacion de convulsion (requiere R6)",
		desc_naked = "Elimina todas las ropas de tu personaje",
		desc_freeze = "Congela a todos los jugadores en el servidor",
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
	BG = Color3.fromRGB(28, 28, 28), BGDark = Color3.fromRGB(20, 20, 20),
	Topbar = Color3.fromRGB(35, 35, 35), Card = Color3.fromRGB(40, 40, 40),
	CardHover = Color3.fromRGB(55, 55, 55), Accent = Color3.fromRGB(0, 120, 210),
	AccentDim = Color3.fromRGB(0, 80, 150), On = Color3.fromRGB(0, 200, 100),
	OnBG = Color3.fromRGB(15, 50, 30), Off = Color3.fromRGB(200, 200, 200),
	OffBG = Color3.fromRGB(45, 45, 45), Text = Color3.fromRGB(240, 240, 240),
	Border = Color3.fromRGB(70, 70, 70), Red = Color3.fromRGB(255, 70, 70),
}

-- TweenInfos
GH.TI = TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
GH.TI_Slow = TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)

-- ==========================================
-- UI DIMENSIONS (mantidos para compatibilidade)
-- ==========================================
GH.PanelWidth = 520
GH.PanelHeight = 300
GH.TopbarHeight = 20
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
-- NOTIFICATION SYSTEM (via Fluent)
-- ==========================================
function GH.ShowToast(message, color, duration)
	if GH.SilentRestore then return end
	if not GH.Fluent then return end

	pcall(function()
		GH.Fluent:Notify({
			Title = "SYSTEM",
			Content = message,
			Duration = duration or 3,
		})
	end)
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
}

-- Botões pendentes que serão criados após a UI existir
GH.PendingButtons = {} -- { {name, text, callback, category, description}, ... }

function GH.RegisterToggleButton(name, text, callback, category, description)
	table.insert(GH.PendingButtons, {name = name, text = text, callback = callback, category = category, description = description})
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
		while GH.Stats.IsOnline do
			task.wait(60)
			if GH.Stats.IsOnline then
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
	GH.isClosing = true

	-- Enviar evento de desligamento
	if GH.Stats then
		GH.Stats.IsOnline = false
		pcall(function() GH.Stats.SendDisconnectEvent() end)
	end

	-- Desativar todos os states
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

	-- Limpar float pad
	pcall(function()
		local pad = workspace:FindFirstChild("GH_FloatPad")
		if pad then pad:Destroy() end
		if LocalPlayer.Character then
			local pad2 = LocalPlayer.Character:FindFirstChild("GH_FloatPad")
			if pad2 then pad2:Destroy() end
		end
	end)

	-- Limpar VehicleFly body movers
	pcall(function()
		if LocalPlayer.Character then
			local r = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
			if r then
				local bv = r:FindFirstChild("GH_VFlyBV")
				if bv then bv:Destroy() end
				local bg = r:FindFirstChild("GH_VFlyBG")
				if bg then bg:Destroy() end
			end
		end
	end)

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
	for _, p in ipairs(Players:GetPlayers()) do
		if p ~= LocalPlayer and p.Character then
			for _, obj in ipairs(p.Character:GetChildren()) do
				if obj.Name:sub(1, 6) == "GH_ESP" then
					pcall(function() obj:Destroy() end)
				end
			end
		end
	end

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
	end)

	-- Limpar tabelas
	table.clear(GH.Cache.HitboxAdornments)
	table.clear(GH.Cache.ESPPlayers)
end

-- ==========================================
-- INITIALIZE: Monta UI via Fluent e processa módulos
-- ==========================================
function GH.Initialize()
	-- Limpar GUI antiga
	if GH.TargetGui:FindFirstChild("SystemScript") then
		GH.TargetGui["SystemScript"]:Destroy()
	end

	-- Carregar Fluent UI
	local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
	local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
	local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()

	GH.Fluent = Fluent
	GH.SaveManager = SaveManager

	-- Criar Window
	local Window = Fluent:CreateWindow({
		Title = "SYSTEM SCRIPT",
		SubTitle = "v2.0",
		TabWidth = 160,
		Size = UDim2.fromOffset(580, 460),
		Theme = "Dark",
		MinimizeKey = Enum.KeyCode.RightControl,
	})
	GH.Window = Window

	-- ==========================================
	-- STATS NO TOPBAR (discreto)
	-- ==========================================
	task.spawn(function()
		task.wait(1) -- Esperar a janela renderizar

		-- Encontrar o ScreenGui do Fluent
		local screenGui = nil
		for _, gui in ipairs(GH.TargetGui:GetChildren()) do
			if gui:IsA("ScreenGui") and gui:FindFirstChild("Main", true) then
				screenGui = gui
				break
			end
		end

		if screenGui then
			-- Encontrar o topbar (frame principal com titulo)
			local mainFrame = screenGui:FindFirstChild("Main", true)
			if mainFrame then
				-- Criar frame discreto para stats no canto superior direito
				local statsFrame = Instance.new("Frame")
				statsFrame.Name = "StatsFrame"
				statsFrame.Size = UDim2.new(0, 180, 0, 16)
				statsFrame.Position = UDim2.new(1, -190, 0, 2)
				statsFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
				statsFrame.BackgroundTransparency = 0.3
				statsFrame.BorderSizePixel = 0
				statsFrame.Parent = mainFrame

				local corner = Instance.new("UICorner")
				corner.CornerRadius = UDim.new(0, 4)
				corner.Parent = statsFrame

				-- Texto de stats
				local statsLabel = Instance.new("TextLabel")
				statsLabel.Name = "StatsLabel"
				statsLabel.Size = UDim2.new(1, -8, 1, 0)
				statsLabel.Position = UDim2.new(0, 4, 0, 0)
				statsLabel.BackgroundTransparency = 1
				statsLabel.Text = "🟢 1 | 💉 1"
				statsLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
				statsLabel.TextSize = 10
				statsLabel.Font = Enum.Font.Gotham
				statsLabel.TextXAlignment = Enum.TextXAlignment.Right
				statsLabel.Parent = statsFrame

				GH.Objects.StatsLabel = statsLabel

				-- Atualizar stats periodicamente
				while true do
					task.wait(15)
					pcall(function()
						if statsLabel and statsLabel.Parent then
							statsLabel.Text = string.format("🟢 %d | 💉 %d",
								GH.Stats.OnlineUsers,
								GH.Stats.TotalInjections
							)
						end
					end)
				end
			end
		end
	end)

	-- Iniciar sistema de metricas
	task.spawn(function()
		GH.Stats.Start()
	end)

	-- Criar Tabs
	local Tabs = {}
	for _, cat in ipairs(GH.Categories) do
		Tabs[cat.Name] = Window:AddTab({ Title = cat.Name, Icon = cat.Icon })
	end
	local SettingsTab = Window:AddTab({ Title = "Settings", Icon = "settings" })
	GH.Tabs = Tabs

	-- Processar toggles pendentes dos módulos
	table.sort(GH.PendingButtons, function(a, b)
		if a.category == b.category then
			return a.text:lower() < b.text:lower()
		end
		return a.category < b.category
	end)

	for _, pending in ipairs(GH.PendingButtons) do
		GH.States[pending.name] = false
		local tab = Tabs[pending.category] or Tabs["Combat"]

		local toggle = tab:AddToggle(pending.name, {
			Title = pending.text,
			Description = pending.description or "",
			Default = false,
		})

		toggle:OnChanged(function()
			local state = toggle.Value
			GH.States[pending.name] = state
			if state then
				GH.ShowToast(pending.name .. " " .. GH.T("toast_activated"), GH.Theme.On, 2)
			else
				GH.ShowToast(pending.name .. " " .. GH.T("toast_deactivated"), GH.Theme.Off, 2)
			end
			pcall(pending.callback, state, toggle)
		end)

		GH.Buttons[pending.name] = toggle
		GH.Callbacks[pending.name] = pending.callback
	end

	-- ==========================================
	-- SETTINGS TAB
	-- ==========================================
	local SettingsSection = SettingsTab:AddSection(GH.T("settings_config"))

	local LanguageMap = { ["Portugues"] = "pt", ["English"] = "en", ["Espanol"] = "es" }
	local LanguageReverse = { pt = "Portugues", en = "English", es = "Espanol" }

	SettingsSection:AddDropdown("Language", {
		Title = GH.T("settings_language"),
		Values = {"Portugues", "English", "Espanol"},
		Default = LanguageReverse[GH.Settings.Language] or "Portugues",
		Callback = function(value)
			GH.Settings.Language = LanguageMap[value] or "pt"
		end,
	})

	SettingsSection:AddToggle("DebugMode", {
		Title = "Debug Mode",
		Default = GH.Settings.DebugMode,
		Callback = function(value)
			GH.Settings.DebugMode = value
		end,
	})

	SettingsSection:AddToggle("ESPShowDistance", {
		Title = GH.T("settings_show_distance"),
		Default = GH.Settings.ESPShowDistance,
		Callback = function(value)
			GH.Settings.ESPShowDistance = value
		end,
	})

	SettingsSection:AddToggle("ESPShowHealth", {
		Title = GH.T("settings_show_health"),
		Default = GH.Settings.ESPShowHealth,
		Callback = function(value)
			GH.Settings.ESPShowHealth = value
		end,
	})

	SettingsSection:AddToggle("ESPShowTag", {
		Title = GH.T("settings_show_tag"),
		Default = GH.Settings.ESPShowTag,
		Callback = function(value)
			GH.Settings.ESPShowTag = value
		end,
	})

	SettingsSection:AddToggle("ESPShowName", {
		Title = GH.T("settings_show_name"),
		Default = GH.Settings.ESPShowName,
		Callback = function(value)
			GH.Settings.ESPShowName = value
		end,
	})

	SettingsSection:AddSlider("HitboxSize", {
		Title = GH.T("settings_hitbox_size"),
		Default = GH.Settings.HitboxSize,
		Min = 5,
		Max = 50,
		Rounding = 0,
		Callback = function(value)
			GH.Settings.HitboxSize = value
		end,
	})

	SettingsSection:AddSlider("ESPMaxDistance", {
		Title = GH.T("settings_esp_max_distance"),
		Default = GH.Settings.ESPMaxDistance,
		Min = 50,
		Max = 2000,
		Rounding = 0,
		Callback = function(value)
			GH.Settings.ESPMaxDistance = value
		end,
	})

	SettingsSection:AddSlider("NoClipRadius", {
		Title = GH.T("settings_noclip_radius"),
		Default = GH.Settings.NoClipRadius,
		Min = 1,
		Max = 20,
		Rounding = 1,
		Callback = function(value)
			GH.Settings.NoClipRadius = value
		end,
	})

	SettingsSection:AddSlider("FlySpeed", {
		Title = GH.T("settings_fly_speed"),
		Default = GH.FlySpeed,
		Min = 5,
		Max = 100,
		Rounding = 0,
		Callback = function(value)
			GH.FlySpeed = value
		end,
	})

	-- ==========================================
	-- SAVE / LOAD CONFIG
	-- ==========================================
	SaveManager:SetLibrary(Fluent)
	InterfaceManager:SetLibrary(Fluent)
	SaveManager:IgnoreThemeSettings()
	SaveManager:SetIgnoreIndexes({})
	SaveManager:SetFolder("SystemScript")
	InterfaceManager:SetFolder("SystemScript")
	InterfaceManager:BuildInterfaceSection(SettingsTab)
	SaveManager:BuildConfigSection(SettingsTab)

	-- ==========================================
	-- INPUT MANAGER GLOBAL CONNECTIONS
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
		for name, callback in pairs(GH.MasterCallbacks.Heartbeat) do
			pcall(callback)
		end
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
	-- CHARACTER ADDED: Reset + Restore
	-- ==========================================
	GH.LocalPlayer.CharacterAdded:Connect(function(char)
		local wasActive = {}
		for name, state in pairs(GH.States) do
			if state then wasActive[name] = true end
		end

		-- Resetar todas as features
		for name, _ in pairs(GH.States) do
			GH.UnregisterMasterLoop(name)
			GH.States[name] = false
			local btn = GH.Buttons[name]
			local callback = GH.Callbacks[name]
			if btn and callback then callback(false, btn) end
			if btn and btn.SetValue then
				pcall(function() btn:SetValue(false) end)
			end
		end

		-- Limpar conexoes (exceto as globais)
		for name, conn in pairs(GH.Connections) do
			if conn and conn.Connected then pcall(conn.Disconnect, conn) end
		end
		table.clear(GH.Connections)

		-- Restaurar features
		GH.SilentRestore = true
		task.defer(function()
			for name, _ in pairs(wasActive) do
				if GH.States[name] == false and GH.Buttons[name] and GH.Callbacks[name] then
					GH.States[name] = true
					local btn = GH.Buttons[name]
					if btn and btn.SetValue then
						pcall(function() btn:SetValue(true) end)
					end
					GH.Callbacks[name](true, btn)
				end
			end
			GH.SilentRestore = false
		end)
	end)

	-- ==========================================
	-- FECHAR (via botao do Fluent ou unloading)
	-- ==========================================
	-- O Fluent gerencia minimize/fechar via MinimizeKeybind
	-- Cleanup é chamado quando o script é descarregado

	Players.PlayerRemoving:Connect(function(player)
		if player == GH.LocalPlayer then
			pcall(function()
				GH.FullCleanup()
			end)
		end
	end)

	-- Cleanup quando o script e destruido pelo executor
	if script then
		script.Destroying:Connect(function()
			pcall(function()
				GH.FullCleanup()
			end)
		end)
	end

	-- Notificacao de carregamento
	task.delay(0.5, function()
		GH.ShowToast(GH.T("toast_script_loaded"), GH.Theme.On, 5)
	end)

	-- Selecionar primeira aba
	Window:SelectTab(1)
end

-- ==========================================
-- RETURN GH
-- ==========================================
return GH
