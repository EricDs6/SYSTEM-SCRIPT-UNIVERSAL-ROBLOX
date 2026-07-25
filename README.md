# SYSTEM - Universal Roblox Script

Script universal para Roblox com interface Fluent UI, 57 módulos organizados por categoria e suporte a multi-idioma (PT/EN/ES).

## Como Usar

Execute este script no executor:

```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/EricDs6/SYSTEM-SCRIPT-UNIVERSAL-ROBLOX/main/loader.lua"))()
```

## Estrutura do Projeto

```
SYSTEM-SCRIPT-UNIVERSAL-ROBLOX/
├── loader.lua                  # Loader principal (tela de carregamento + download dos módulos)
├── core/
│   └── init.lua                # Core: UI Fluent, temas, sistemas compartilhados
├── modules/
│   ├── combat/                 # 10 módulos de combate
│   │   ├── esp.lua
│   │   ├── hitbox.lua
│   │   ├── triggerbot.lua
│   │   ├── silentaim.lua
│   │   ├── nofling.lua
│   │   ├── wallbang.lua
│   │   ├── infinitehealth.lua
│   │   ├── killaura.lua
│   │   ├── nofalldamage.lua
│   │   └── headsize.lua
│   ├── movement/               # 19 módulos de movimento
│   │   ├── fly.lua
│   │   ├── noclip.lua
│   │   ├── sprint.lua
│   │   ├── speed.lua
│   │   ├── infinitejump.lua
│   │   ├── bunnyhop.lua
│   │   ├── teleportplayer.lua
│   │   ├── blink.lua
│   │   ├── vehiclespeed.lua
│   │   ├── nojumpcooldown.lua
│   │   ├── float.lua
│   │   ├── swim.lua
│   │   ├── vehiclegoto.lua
│   │   ├── walkto.lua
│   │   ├── orbit.lua
│   │   ├── headsit.lua
│   │   ├── vehiclefly.lua
│   │   ├── spectate.lua
│   │   └── gotopart.lua
│   ├── visual/                 # 6 módulos visuais
│   │   ├── xray.lua
│   │   ├── nightmode.lua
│   │   ├── fullbright.lua
│   │   ├── tracers.lua
│   │   ├── crosshair.lua
│   │   └── fovchanger.lua
│   ├── utility/                # 17 módulos de utilidade
│   │   ├── clicktp.lua
│   │   ├── gravity.lua
│   │   ├── customspawn.lua
│   │   ├── freecam.lua
│   │   ├── flashback.lua
│   │   ├── coords.lua
│   │   ├── serverrejoin.lua
│   │   ├── autoclicker.lua
│   │   ├── proximityinstant.lua
│   │   ├── antiafk.lua
│   │   ├── antikick.lua
│   │   ├── autocollect.lua
│   │   ├── fireclickdetectors.lua
│   │   ├── fireproximityprompts.lua
│   │   ├── btools.lua
│   │   ├── breakvelocity.lua
│   │   └── invisibleparts.lua
│   └── troll/                  # 5 módulos de troll
│       ├── trollfling.lua
│       ├── targetfling.lua
│       ├── spasms.lua
│       ├── naked.lua
│       └── freeze.lua
└── libs/                       # Bibliotecas externas
```

## Módulos por Categoria

### Combat (10)
| Módulo | Descrição |
|--------|-----------|
| ESP | Mostra nomes, vida e distância dos jogadores através de paredes |
| Hitbox Gigante | Expande a hitbox dos inimigos para acertar mais fácil |
| TriggerBot | Atira automaticamente quando mira no inimigo |
| Silent Aim | Redireciona tiros para o jogador mais próximo do cursor |
| No Fling | Impede que você seja jogado por exploits de fling |
| Wall Bang | Permite atirar através de paredes e objetos |
| Infinite Health | Mantém sua vida sempre no máximo |
| Kill Aura | Ataca automaticamente jogadores próximos |
| No Fall Damage | Remove dano de queda |
| Head Size | Amplia cabeça de jogadores para acertar mais fácil |

### Movement (19)
| Módulo | Descrição |
|--------|-----------|
| Fly | Voar pelo mapa com WASD. Scroll ajusta velocidade |
| NoClip | Atravessar paredes e objetos sólidos |
| Sprint | Correr mais segurando a tecla Shift |
| Speed Hack | Aumenta a velocidade de caminhada |
| Infinite Jump | Pular infinitas vezes no ar |
| Bunny Hop | Pular continuamente ao correr |
| TP para Player | Seleciona um player para teleportar até ele |
| Blink | Dash rápido na direção que olha. Tecla Q |
| Vehicle Speed | Aumenta velocidade e torque de veículos |
| No Jump Cooldown | Remove cooldown de pulo |
| Float | Plataforma voadora. Q desce, E sobe |
| Swim | Natação no ar, gravidade zero |
| Vehicle Goto | Teleporta seu veículo para um jogador |
| Walk To | Segue um jogador automaticamente |
| Orbit | Gira ao redor de um jogador |
| HeadSit | Senta na cabeça de um jogador |
| Vehicle Fly | Voar dirigindo veículos. WASD+QE |
| Spectate | Câmera segue um jogador selecionado |
| Goto Part | Teleporta para uma parte pelo nome |

### Visual (6)
| Módulo | Descrição |
|--------|-----------|
| X-Ray | Veja através de paredes e objetos |
| Night Mode | Escurece o ambiente para ver melhor |
| Fullbright | Iluminação máxima, nada de sombras |
| Tracers | Linhas que apontam para jogadores |
| Custom Crosshair | Mira personalizada no centro da tela |
| FOV Changer | Aumenta ou diminui o campo de visão |

### Utility (17)
| Módulo | Descrição |
|--------|-----------|
| Tool TP Click | Ferramenta para teleportar clicando no chão |
| Gravity Baixa | Gravidade reduzida para pular alto |
| Marcar Spawn | Marca posição para renascer automaticamente |
| Freecam | Câmera livre para explorar o mapa. WASD+QE+Mouse |
| Flashback | Pressione P para voltar ao local da última morte |
| Coordenadas | Mostra coordenadas atuais e salva posições |
| Server Rejoin | Reconecta ao mesmo servidor |
| Auto-Clicker | Clique automático segurando a tecla X |
| Proximity Instant | Interação instantânea com prompts sem segurar |
| Anti-AFK | Impede ser desconectado por inatividade |
| Anti-Kick | Impede ser expulso do servidor |
| Auto Collect | Coleta automaticamente tools e itens próximos |
| Fire Click Detectors | Ativa todos os ClickDetectors do mapa |
| Fire Proximity Prompts | Ativa todos os ProximityPrompts do mapa |
| BTools | Ferramentas de construção (HopperBins) |
| Break Velocity | Reseta toda velocidade do personagem |
| Invisible Parts | Mostra partes que estão invisíveis no mapa |

### Troll (5)
| Módulo | Descrição |
|--------|-----------|
| Tornado Fling | Gira rapidamente para jogar outros jogadores |
| Target Fling | Seleciona um alvo e voa até ele para derrubar |
| Spasmos | Animação de convulsão (requer R6) |
| Naked | Remove todas as roupas do personagem |
| Freeze All | Congela todos os jogadores no servidor |

## Tela de Carregamento

- **Barra de progresso segmentada** com 20 blocos animados
- **Shimmer effect** durante o download
- **Download paralelo** dos módulos para carregamento rápido
- **Mensagens de status** detalhadas por módulo

## Funcionalidades do Painel

- **Interface Fluent UI** com tema escuro
- **5 categorias**: Combat, Movement, Visual, Utility, Troll
- **Tooltips** com descrição detalhada de cada módulo
- **Minimizar** com RightControl
- **Settings** com toggles, sliders e dropdown de idioma
- **Auto-save** das configurações
- **Restore automático** das features ao renascer
- **Multi-idioma**: Português, English, Español
- **Atualização automática** do GitHub (versão + data do commit)

## Configurações

| Setting | Descrição | Padrão |
|---------|-----------|--------|
| Idioma | PT / EN / ES | Português |
| Debug Mode | Mostra erros detalhados | OFF |
| Mostrar Distância | ESP mostra distância | ON |
| Mostrar Vida | ESP mostra barra de vida | ON |
| Mostrar Tag | ESP mostra tag [INIMIGO] | ON |
| Mostrar Nome | ESP mostra nome | ON |
| Tamanho Hitbox | Tamanho da hitbox expandida | 15 |
| Distância Max ESP | Alcance máximo do ESP | 300 |
| Raio NoClip | Raio de ativação do NoClip | 3.8 |
| Velocidade Fly | Velocidade do fly | 20 |

## Requisitos

- Executor Roblox compatível (Synapse, Fluxus, Wave, etc.)
- `loadstring` suportado
- `HttpGet` suportado
- `hookmetamethod` / `checkcaller` (opcional, para namecall hook)

## Licença

MIT License - Veja o arquivo `LICENSE` para mais detalhes.
