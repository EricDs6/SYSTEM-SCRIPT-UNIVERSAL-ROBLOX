# SYSTEM - Universal Roblox Script

Script universal para Roblox com painel de interface completo, múltiplos módulos e suporte a diversas funcionalidades.

## Como Usar

Copie o conteúdo do `loader.lua` e execute no executor (Synapse, Fluxus, Wave, etc.):

```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/EricDs6/SYSTEM-SCRIPT-UNIVERSAL-ROBLOX/main/loader.lua"))()
```

## Estrutura do Projeto

```
SYSTEM-SCRIPT-UNIVERSAL-ROBLOX/
├── loader.lua              # Loader principal (executar este)
├── core/
│   └── init.lua            # Core: UI, temas, sistemas compartilhados
├── modules/
│   ├── combat.lua          # Módulo de combate
│   ├── movement.lua        # Módulo de movimento
│   ├── visual.lua          # Módulo visual
│   ├── utility.lua         # Módulo de utilidades
│   └── troll.lua           # Módulo de troll
└── libs/                   # Bibliotecas externas
```

## Comandos por Categoria

### Combat (10)
| Comando | Descrição |
|---------|-----------|
| Hitbox Gigante | Expande a hitbox dos inimigos para acertar mais fácil |
| ESP | Mostra nomes, vida e distância dos jogadores através de paredes |
| TriggerBot | Atira automaticamente quando mira no inimigo |
| Silent Aim | Redireciona tiros para o jogador mais próximo do cursor |
| No Fling | Impede que você seja jogado por exploits de fling |
| Wall Bang | Permite atirar através de paredes e objetos |
| Infinite Health | Mantém sua vida sempre no máximo |
| Kill Aura | Ataca automaticamente jogadores próximos |
| No Fall Damage | Remove dano de queda |
| Head Size | Amplia cabeça de jogadores para acertar mais fácil |

### Movement (19)
| Comando | Descrição |
|---------|-----------|
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
| Comando | Descrição |
|---------|-----------|
| X-Ray | Veja através de paredes e objetos |
| Night Mode | Escurece o ambiente para ver melhor |
| Fullbright | Iluminação máxima, nada de sombras |
| Tracers | Linhas que apontam para jogadores |
| Custom Crosshair | Mira personalizada no centro da tela |
| FOV Changer | Aumenta ou diminui o campo de visão |

### Utility (17)
| Comando | Descrição |
|---------|-----------|
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
| Comando | Descrição |
|---------|-----------|
| Tornado Fling | Gira rapidamente para jogar outros jogadores |
| Target Fling | Seleciona um alvo e voa até ele para derrubar |
| Spasmos | Animação de convulsão (requer R6) |
| Naked | Remove todas as roupas do personagem |
| Freeze All | Congela todos os jogadores no servidor |

## Funcionalidades do Painel

- **Interface moderna** com tema escuro
- **5 categorias**: Combat, Movement, Visual, Utility, Troll
- **Tooltips** ao passar o mouse em cada comando
- **Minimizar** o painel com o botão —
- **Filtro** de busca na barra inferior
- **Settings** com toggles e sliders configuráveis
- **Auto-save** das configurações
- **Arrastar** o painel pela barra superior
- **Restore automático** das features ao renascer

## Configurações

O painel de Settings (⚙) permite configurar:

| Setting | Descrição | Padrão |
|---------|-----------|--------|
| Debug Mode | Mostra erros detalhados | OFF |
| Mostrar Distância | ESP mostra distância | ON |
| Mostrar Vida | ESP mostra barra de vida | ON |
| Mostrar Tag | ESP mostra tag [INIMIGO] | ON |
| Mostrar Nome | ESP mostra nome | ON |
| Tamanho Hitbox | Tamanho da hitbox expandida | 15 |
| Distância Max ESP | Alcance máximo do ESP | 300 |
| Raio NoClip | Raio de ativação do NoClip | 3.8 |

## Requisitos

- Executor Roblox compatível (Synapse, Fluxus, Wave, etc.)
- `loadstring` suportado
- `HttpGet` suportado
- `fireclickdetector` / `fireproximityprompt` (opcional, para comandos específicos)

## Licença

MIT License - Veja o arquivo `LICENSE` para mais detalhes.
