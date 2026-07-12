# Análise do Estado Atual — ECOnnect: Teia Alimentar

> **Data:** Julho de 2026  
> **Propósito:** Diagnóstico completo do projeto para orientar a remodelagem com foco em experiência infantil, clareza pedagógica, UX/UI, arquitetura, escalabilidade e potencial de evolução.  
> **Escopo:** Código-fonte, assets, fluxos, arquitetura, game design e conteúdo pedagógico.
> **Status da revisão:** Esta é uma atualização que reflete as melhorias implementadas após a análise anterior. Alegações desatualizadas foram corrigidas.

---

## Sumário

1. [Visão geral do projeto](#1-visão-geral-do-projeto)
2. [Estrutura atual do código](#2-estrutura-atual-do-código)
3. [Estado atual das funcionalidades](#3-estado-atual-das-funcionalidades)
4. [Análise de UX/UI](#4-análise-de-uxui)
5. [Análise pedagógica](#5-análise-pedagógica)
6. [Análise de game design](#6-análise-de-game-design)
7. [Problemas atuais conhecidos](#7-problemas-atuais-conhecidos)
8. [Arquitetura e qualidade do código](#8-arquitetura-e-qualidade-do-código)
9. [Assets e identidade visual](#9-assets-e-identidade-visual)
10. [Recomendações de remodelagem](#10-recomendações-de-remodelagem)
11. [Possíveis novos fluxos de jogo](#11-possíveis-novos-fluxos-de-jogo)
12. [Roadmap sugerido](#12-roadmap-sugerido)
13. [Perguntas em aberto](#13-perguntas-em-aberto)
14. [Conclusão](#14-conclusão)
15. [Modo planejado: Classificação por Níveis Tróficos](#15-modo-planejado-classificação-por-níveis-tróficos)

---

## 1. Visão geral do projeto

### 1.1 Proposta atual

O **ECOnnect: Teia Alimentar** é um jogo educacional que ensina conceitos de ecologia e cadeias/teias alimentares. O jogador constrói teias alimentares conectando organismos de diferentes biomas brasileiros por meio de uma mecânica de arrastar (drag) entre organismos.

### 1.2 Fluxo atual do jogador

O fluxo real implementado no código é:

```
HomeScreen
  → PhasesScreen (seleção de fase)
    → BiomeIntroScreen (introdução do bioma com descrição e grid de organismos)
      → GameScreen (jogo com Flame Engine + GameTopHud + HUD inferior)
        → Modal de conclusão (estatísticas da fase)
        → Volta para PhasesScreen
  → TutorialScreen (Como Jogar — minijogo Águia → Coelho)
  → RankingScreen (pontuações salvas)
  → AboutScreen (informações do projeto + reset de progresso)
```

### 1.3 Telas existentes

| Tela | Arquivo | Função |
|------|---------|--------|
| HomeScreen | `lib/screens/home_screen.dart` | Tela inicial com logo, botão JOGAR, atalhos para Ranking, Como Jogar e Sobre, edição de nome do jogador, mute toggle |
| PhasesScreen | `lib/screens/phases_screen.dart` | Lista de fases com cards indicando desbloqueio |
| BiomeIntroScreen | `lib/screens/biome_intro_screen.dart` | Introdução do bioma: nome, descrição, card "Observe e Descubra", grid de organismos com sprites animados, botão "EXPLORAR" |
| GameScreen | `lib/screens/game_screen.dart` | Tela principal do jogo: GameTopHUD (biome card, score, progress bar, timer, back, audio toggle) + área Flame + HUD inferior (submit) + overlay de feedback + modal de conclusão |
| TutorialScreen | `lib/screens/tutorial_screen.dart` | Minijogo com Águia e Coelho para ensinar mecânica de drag |
| RankingScreen | `lib/screens/ranking_screen.dart` | Tabela de pontuações agrupadas por fase |
| AboutScreen | `lib/screens/about_screen.dart` | Informações do projeto, descrição dos biomas, tecnologias, botão de reset |

### 1.4 Fases e biomas

| # | Bioma | Organismos | Conexões | Tempo (s) | Arquivo de seed |
|---|-------|-----------|----------|-----------|-----------------|
| 1 | Campo | 7 (Capim, Gafanhoto, Coelho, Sapo, Cobra, Raposa, Águia) | 9 | 120 | `database_seed.dart` |
| 2 | Floresta | 8 (Arbusto, Lagarta, Aranha, Sapo, Cobra, Gavião, Veado, Onça-pintada) | 9 | 100 | `database_seed.dart` |
| 3 | Oceano | 7 (Fitoplâncton, Alga, Camarão, Sardinha, Polvo, Atum, Tubarão) | 8 | 80 | `database_seed.dart` |
| 4 | Pantanal | 7 (Planta aquática, Caramujo, Peixe, Garça, Jacaré, Cobra sucuri, Onça-pintada) | 9 | 60 | `database_seed.dart` |

### 1.5 Sistemas principais já implementados

- **Sistema de drag & drop:** `ConnectionSystem` em `lib/game/systems/connection_system.dart`
- **Sistema de conexão visual:** `ConnectionLine` com curvas bezier, seta direcional em ~68% da linha, glow pulsante para acertos, brilho suave para erros, partículas de folha ao longo da linha, modo foco (dimming de conexões não relacionadas)
- **Indicador de drag:** `DragIndicator` — linha pontilhada animada durante o arrasto
- **HUD superior reformulado:** `GameTopHud` em `lib/widgets/game_top_hud.dart` — cards de bioma, pontuação, progresso (conexões + barra animada com gradiente e glow), timer, botão voltar, toggle de áudio; layout responsivo (wide ≥600dp single row, compact <600dp duas linhas)
- **Card de progresso:** `_ConnectionCard` integrado no HUD, com `TweenAnimationBuilder` para barra de progresso animada e glow
- **Destaque do organismo selecionado:** `OrganismComponent` com glow multi-camada (3 layers de blur + borda luminosa + core), label de nome com fundo pill e borda glow quando destacado; persiste durante drag, removido no release/cancel
- **Modo foco automático:** ativado automaticamente ao iniciar drag; conexões relacionadas ao organismo arrastado ficam fortes, não relacionadas reduzem para 50% alpha; não revela conexões futuras; organismos não relacionados não desaparecem
- **Sistema de áudio:** `AudioService` singleton com sons ambientes por bioma e efeitos (acerto, erro, conclusão) + mute toggle global com retomada sensível ao contexto (`AudioContext` — só retoma áudio ambiente se estiver em tela de jogo)
- **Sistema de pontuação:** `ScoringService` com cálculo baseado em acertos + bônus de tempo
- **Sistema de desbloqueio progressivo:** Baseado em estrelas mínimas (1⭐ para liberar próxima fase)
- **Sistema de posicionamento:** Algoritmo de quadrantes com zonas verticais (top/middle/bottom) e rejeição por overlap
- **Sistema de persistência:** SQLite via `sqflite` com repositories (Phase, Organism, Connection, Score)
- **Sistema de feedback visual:** Partículas (`ConnectionEffect` — 70 partículas para acerto, 50 para erro), highlights, shake, animação de linha (flash branco + transição para cor), overlay de mensagens com AnimatedSwitcher
- **Sistema de animação de organismos:** Sprite sheets com animação ping-pong + efeito de "bob" (flutuação) + efeito de lunge (investida do predador ao acertar)

---

## 2. Estrutura atual do código

### 2.1 Mapeamento de diretórios

```
lib/
├── core/
│   ├── animation_config.dart     — Configurações de animação (durações, curvas)
│   ├── app_colors.dart           — Paleta de cores do tema (inclui cores de conexão, erro, glow, níveis tróficos)
│   ├── app_constants.dart        — Constantes (pontuação, tamanhos, timers, line stroke width)
│   ├── app_theme.dart            — Tema claro do Material Design 3
│   └── asset_paths.dart          — Mapeamento de paths de sprites e backgrounds por organismo
│
├── database/
│   ├── database_helper.dart      — Singleton de acesso ao SQLite (init, migrate, seed)
│   ├── database_init.dart        — Factory para selecionar driver (mobile/desktop/web)
│   ├── database_seed.dart        — Seed completo: 4 fases, 29 organismos, 36 conexões
│   ├── database_init_io.dart     — Driver nativo sqflite (mobile/desktop)
│   └── database_init_stub.dart   — Stub para testes
│
├── game/
│   ├── food_web_game.dart        — Game principal (FlameGame): 483 linhas
│   ├── tutorial_game.dart        — Versão simplificada para o tutorial
│   ├── components/
│   │   ├── background_component.dart — Fundo com sprite do bioma
│   │   ├── connection_line.dart      — Linha bezier entre predador e presa (glow, seta, folhas, foco)
│   │   ├── drag_indicator.dart       — Indicador visual durante o arrasto
│   │   └── organism_component.dart   — Componente do organismo com sprite, nome, highlight multi-camada, glow
│   ├── effects/
│   │   └── connection_effect.dart    — Partículas de acerto (70 partículas) e erro (50 partículas)
│   └── systems/
│       └── connection_system.dart    — Lógica de drag (início, atualização, fim)
│
├── models/
│   ├── correct_connection.dart  — Modelo de conexão correta (source→target)
│   ├── organism.dart            — Modelo de organismo (nome, emoji, nível trófico)
│   ├── phase.dart               — Modelo de fase (nome, bioma, ordem)
│   └── score.dart               — Modelo de pontuação (jogador, pontos, estrelas, erros)
│
├── repositories/
│   ├── connection_repository.dart — CRUD de conexões corretas no SQLite
│   ├── organism_repository.dart   — CRUD de organismos por fase
│   ├── phase_repository.dart      — CRUD de fases
│   └── score_repository.dart      — CRUD de pontuações e lógica de desbloqueio
│
├── screens/
│   ├── about_screen.dart        — Tela Sobre
│   ├── biome_intro_screen.dart  — Tela de introdução do bioma
│   ├── game_screen.dart         — Tela do jogo principal (637 linhas)
│   ├── home_screen.dart         — Tela inicial
│   ├── phases_screen.dart       — Tela de seleção de fases
│   ├── ranking_screen.dart      — Tela de ranking
│   └── tutorial_screen.dart     — Tela do tutorial
│
├── services/
│   ├── audio_service.dart       — Singleton de áudio (ambiente, efeitos, mute, AudioContext)
│   ├── game_service.dart        — Service principal (estado, timer, fases, conexões, pontuação)
│   └── scoring_service.dart     — Cálculo de pontuação e estrelas
│
├── widgets/
│   ├── audio_toggle_button.dart — Botão de mute global
│   ├── game_top_hud.dart        — HUD superior reformulado (biome card, score, progress, timer, back, audio)
│   ├── hint_button.dart         — Botão de dica
│   ├── hover_button.dart        — Botão reutilizável com hover/press animation
│   ├── organism_widget.dart     — Widget Flutter para exibição de organismo (usado fora do Flame)
│   ├── phase_card.dart          — Card de fase na lista
│   ├── progress_card.dart       — Card de progresso (widget standalone, similar ao _ConnectionCard no GameTopHud)
│   ├── score_display.dart       — Display de pontuação e erros
│   └── stars_display.dart       — Exibição de estrelas
│
├── main.dart                    — Entry point, Provider<GameService>, MaterialApp
└── test_eagle_animation.dart    — Arquivo de teste de animação standalone

assets/
├── images/
│   ├── animais/
│   │   ├── campo/       — Spritesheets do bioma Campo (ex: aguia.png, capim.png, etc.)
│   │   ├── floresta/    — Spritesheets do bioma Floresta
│   │   ├── oceano/      — Spritesheets do bioma Oceano
│   │   └── pantanal/    — Spritesheets do bioma Pantanal
│   └── cenarios/        — Backgrounds dos biomas (campo.png, floresta.png, etc.)
├── audio/
│   ├── campo/           — Áudio ambiente do Campo
│   ├── floresta/        — Áudio ambiente da Floresta
│   ├── oceano/          — Áudio ambiente do Oceano
│   ├── pantanal/        — Áudio ambiente do Pantanal
│   └── geral/           — Efeitos sonoros (acertou.mp3, errou.mp3, terminou.mp3)

web/
├── src/App.svelte       — Página Svelte com hero + iframe do jogo
├── dist/                — Build de produção
└── public/flutter-app/  — Build do Flutter web embarcado
```

### 2.2 Arquivos mais importantes e seus papéis

| Arquivo | Linhas | Papel |
|---------|--------|-------|
| `food_web_game.dart` | 483 | Núcleo do jogo Flame: carrega fase, posiciona organismos, gerencia drag, valida conexões, gerencia partículas, animações, foco automático, feedback |
| `game_service.dart` | ~250 | Camada de estado do jogo: carrega fases, gerencia timer, valida conexões, calcula pontuação, salva scores. Usa ChangeNotifier + Provider |
| `game_screen.dart` | 637 | Tela mais complexa: integra Flame GameWidget com GameTopHud, HUD inferior, modal de conclusão, feedback overlay, submit |
| `game_top_hud.dart` | 557 | HUD superior completamente reformulado: 6 subcomponentes, layout responsivo, barra de progresso animada |
| `connection_line.dart` | 267 | Linha de conexão com renderização avançada: curvas bezier, seta em 68%, glow, partículas de folha, modo foco, fade out |
| `organism_component.dart` | 323 | Componente Flame do organismo: spritesheet animada, glow multi-camada (3 layers + borda), label com pill, shake, drag events |
| `biome_intro_screen.dart` | ~618 | Tela de introdução com descrição, grid de sprites animados, botão de explorar, lógica de navegação |
| `database_seed.dart` | ~346 | Seed completo com toda a base de dados do jogo (29 organismos, 36 conexões em 4 biomas) |
| `connection_effect.dart` | 122 | Partículas de acerto/erro: 70 partículas (verde+ouro+branco) ou 50 (vermelho+laranja+cinza) |

---

## 3. Estado atual das funcionalidades

### 3.1 Tabela de funcionalidades

| Funcionalidade | Status | Arquivos relacionados | Observações |
|---------------|--------|----------------------|-------------|
| **Seleção de fases** | ✅ Funcionando | `phases_screen.dart`, `phase_card.dart` | Lista vertical com cards. Mostra ícone por bioma. |
| **Desbloqueio progressivo** | ✅ Funcionando | `score_repository.dart`, `game_service.dart` | Fase 1 sempre liberada. Próxima libera com ≥1⭐ na anterior. Feedback via SnackBar ao tentar fase bloqueada. |
| **Introdução dos biomas** | ✅ Funcionando | `biome_intro_screen.dart` | Mostra descrição, card "Observe e Descubra", grid de organismos com sprite animado. |
| **Tutorial "Como Jogar"** | ✅ Funcionando | `tutorial_screen.dart`, `tutorial_game.dart` | Minijogo com Águia e Coelho. Apenas uma conexão correta possível. |
| **GameTopHud (HUD superior)** | ✅ Funcionando | `game_top_hud.dart`, `game_screen.dart` | Cards de bioma, pontuação, progresso (conexões + barra animada), timer, botão voltar, áudio toggle. Layout responsivo (wide ≥600dp single row, compact <600dp duas linhas). |
| **Drag de conexão** | ⚠️ Parcial | `connection_system.dart`, `organism_component.dart`, `food_web_game.dart` | Drag funciona com indicador visual. Melhorias recentes: foco automático ao arrastar, highlight no source e hover target. Direção conceitual ainda confusa (ver seção 4.4). |
| **Conexões visuais** | ✅ Avançado | `connection_line.dart`, `food_web_game.dart` | Linhas curvas bezier com glow pulsante para acertos, brilho suave para erros, seta direcional em ~68% do percurso, partículas de folha ao longo da linha, modo foco (dimming de não relacionadas). |
| **Validação de conexão** | ✅ Funcionando | `game_service.dart`, `food_web_game.dart` | Valida contra grafo de conexões corretas. Detecta direção reversa. |
| **Feedback visual de acerto** | ✅ Avançado | `food_web_game.dart`, `connection_line.dart`, `connection_effect.dart` | Flash branco → cor, glow pulsante, 70 partículas (verde+ouro+branco), mensagem educativa, animação de lunge do predador. |
| **Feedback visual de erro** | ✅ Avançado | `food_web_game.dart`, `organism_component.dart`, `connection_line.dart` | Linha temporária (fade out em 2.8s) com cor suave laranja-avermelhada (`#E6553A`), glow sutil (`#FF8A65`), shake no organismo origem, 50 partículas (vermelho+laranja+cinza), overlay com mensagens instrutivas. |
| **Feedback sonoro** | ✅ Funcionando | `audio_service.dart` | Sons de acerto, erro e conclusão reproduzidos. |
| **Mute/Desmute** | ✅ Avançado | `audio_service.dart`, `audio_toggle_button.dart` | Toggle global com `AudioContext`. Ao mutar, para áudio ambiente. Ao desmutar, só retoma se estiver em contexto de jogo. Presente na Home (top-right) e no GameTopHud. |
| **Partículas** | ✅ Funcionando | `connection_effect.dart`, `food_web_game.dart` | 70 partículas para acerto (explosivo), 50 para erro (dissipação). Disparadas com delay de 2.8s. Cores temáticas (verde+ouro para acerto, laranja+cinza para erro). |
| **Destaque do organismo selecionado** | ✅ Avançado | `organism_component.dart` | Glow multi-camada (3 layers de blur: 24px, 14px, 6px), borda luminosa glow + core, label de nome com pill escuro + borda glow quando destacado. |
| **Modo foco automático** | ✅ Funcionando | `food_web_game.dart`, `connection_line.dart` | Ativado automaticamente ao iniciar drag. Conexões envolvendo o organismo arrastado mantêm intensidade total; não relacionadas reduzem para 50% alpha. Desativado ao soltar. Não revela conexões futuras. |
| **Pontuação** | ✅ Funcionando | `scoring_service.dart`, `game_service.dart` | +100 por acerto, +10 por segundo restante. Submit calcula pontuação final. |
| **Estrelas** | ✅ Funcionando | `scoring_service.dart`, `stars_display.dart` | 3⭐ (≥90%), 2⭐ (≥60%), 1⭐ (≥0%). |
| **Ranking** | ✅ Funcionando | `ranking_screen.dart`, `score_repository.dart` | Tabela de pontuações agrupadas por fase, ordenada por pontos. |
| **Modal de fase completa** | ✅ Funcionando | `game_screen.dart` | Mostra estrelas, acertos/erros/tempo, pontuação total, botão "Voltar às fases". |
| **Conteúdo educativo** | ⚠️ Parcial | `biome_intro_screen.dart`, `food_web_game.dart` | Descrições dos biomas e card "Observe e Descubra" na intro. Mensagens de feedback no jogo. Sem conteúdo após a fase. Cores de nível trófico definidas no código mas não aplicadas como badges/bordas no jogo. |
| **Posicionamento automático** | ✅ Funcionando | `food_web_game.dart` | Algoritmo de quadrantes com zonas verticais (top/middle/bottom por id do organismo) + rejeição por overlap. Substituiu posicionamento manual do `habitat_layout.dart`. |
| **Timer regressivo** | ✅ Funcionando | `game_service.dart` | Timer por fase (120s/100s/80s/60s). Submit automático ao expirar. Card do timer fica vermelho quando ≤30s. |
| **AnimatedSpriteThumbnail** (intro) | ✅ Funcionando | `biome_intro_screen.dart` | Sprites animados (ping-pong nos frames) na tela de introdução. |
| **Input de nome do jogador** | ✅ Funcionando | `home_screen.dart`, `game_service.dart` | Diálogo para editar nome, salvo em memória. |
| **Confirmação de saída** | ✅ Funcionando | `game_screen.dart` | Diálogo "Sair da fase?" com alerta de perda de progresso. |
| **Reset de progresso** | ✅ Funcionando | `about_screen.dart`, `game_service.dart` | Botão "Redefinir Progresso" com confirmação, apaga todos os scores. |

---

## 4. Análise de UX/UI

### 4.1 HomeScreen

**Pontos fortes:**
- Tema escuro com gradiente verde cria imersão no universo da natureza
- Animação de fade-in + slide-up na entrada (boa primeira impressão)
- Botão principal "JOGAR" com pulsação e gradiente — claro e convidativo
- Botões secundários (Ranking, Como Jogar, Sobre) com ícones e labels claras
- Partículas flutuantes no fundo criam ambiente vivo
- Input de nome do jogador acessível
- Mute toggle posicionado no canto superior direito

**Pontos fracos:**
- Sem logo ou ilustração — usa apenas ícone `Icons.eco` circular. Para crianças, um mascote ou ilustração de animal seria mais atrativo
- Os botões secundários têm labels curtas ("COMO JOGAR" é longo demais para botão estreito — pode truncar em telas pequenas)
- A partícula flutuante é sutil demais para chamar atenção infantil
- Não há indicação visual de progresso geral do jogo (ex: "Você completou 2 de 4 biomas")

**Sugestões:**
- Adicionar um mascote/ilustração na tela inicial (ex: uma águia ou tucano estilizado)
- Substituir "COMO JOGAR" por "TUTORIAL" e usar um ícone mais lúdico
- Mostrar barra de progresso geral na home
- Aumentar vida das partículas (mais visíveis, cores variadas)

### 4.2 Seleção de fases (PhasesScreen)

**Pontos fortes:**
- Cards com gradiente verde e ícone específico por bioma
- Feedback visual claro de bloqueio (opacity reduzida + ícone de cadeado)
- SnackBar educativo ao tentar fase bloqueada
- Animações de entrada com _ParticleOverlay

**Pontos fracos:**
- Lista vertical simples — poderia ser mais visual com preview do bioma
- Não mostra quantas estrelas o jogador já conquistou em cada fase
- Os cards usam apenas ícones Material Design (grass, forest, water, landscape) — sprites reais dos biomas seriam mais imersivos
- Descrição "Monte a teia alimentar do campo" é genérica — não diferencia os biomas emocionalmente
- Sem badge de melhor pontuação por fase

**Sugestões:**
- Mostrar estrelas conquistadas em cada fase (reutilizar StarsDisplay)
- Usar miniaturas do background do bioma como preview do card
- Adicionar badge de "Melhor: XXX pts" em cada fase
- Descrições mais específicas e curiosas para cada bioma

### 4.3 Introdução dos biomas (BiomeIntroScreen)

**Pontos fortes:**
- Nome do bioma em destaque com letra grande e sombra verde (impacto visual)
- Card "Observe e Descubra" com pergunta que estimula curiosidade
- Grid de sprites animados dos organismos (efeito ping-pong)
- Fundo do bioma em fullscreen com overlay escuro para legibilidade
- Botão "EXPLORAR" com gradiente verde e glow (convidativo)

**Pontos fracos:**
- **Grid de organismos sem legenda de nível trófico** — a criança vê os sprites mas não sabe quem é produtor, consumidor ou predador
- Descrição do bioma limitada a 2 linhas — conteúdo raso para aprendizado
- Card "Observe e Descubra" tem texto pequeno e pode passar despercebido
- A pergunta do "Observe e Descubra" não tem conexão direta com o jogo que virá
- Os sprites animados na thumbnail são muito pequenos (64×64) e perdem detalhes
- Não há indicação de quantas conexões o bioma tem (expectativa)

**Sugestões:**
- Adicionar indicadores visuais de nível trófico nos cards (ex: círculo verde=produtor, amarelo=consumidor, vermelho=predador)
- Expandir descrição do bioma com 2-3 fatos interessantes
- O card "Observe e Descubra" deveria terminar com uma pergunta que o jogo responde
- Aumentar tamanho dos sprites na grid
- Adicionar mini-mapa ou preview da teia que será construída

### 4.4 Tela do jogo (GameScreen)

**Pontos fortes:**
- **GameTopHud reformulado:** biome card com ícone específico, score card (ícone de estrela + "Pontos: N"), connection card com barra de progresso animada e glow, timer card com alerta vermelho ≤30s, back button circular, audio toggle — tudo com design consistente (altura 48px, border-radius 14px, fundo verde-escuro translúcido, borda verde, glow)
- **Layout responsivo:** wide (≥600dp) exibe tudo em uma row centralizada com max-width 1000dp; compact (<600dp) organiza em duas linhas (back+bioma+audio na primeira, score+conexões+timer na segunda)
- **Barra de progresso animada:** `TweenAnimationBuilder` com `easeOutCubic` em 500ms, gradiente verde (`#37B24D` → `#7ED957`), glow sutil. Mostra "correct/total" + label "conexões" (wide) ou apenas números (compact)
- **Timer com alerta visual:** muda para ícone `timer_off` + cor vermelha (`#EF4444`) e borda vermelha quando ≤30s
- Overlay de feedback (acerto/erro) com animação de fade (AnimatedSwitcher 300ms)
- Confirmação de saída com alerta de perda de progresso
- Modal de conclusão com estatísticas e estrelas
- Organismos com nome visível abaixo do sprite (com glow/highlight quando selecionado)

**Pontos fracos:**
- **Direção predador→presa não é intuitiva para crianças** — o jogo espera que o jogador arraste do predador (quem come) para a presa (quem é comido). A seta visual da linha sai do predador em direção à presa, mas a nomenclatura interna (`sourceId = target (prey)`, `targetId = source (predator)`) ainda é invertida, gerando confusão conceitual no código. Embora a seta aponte corretamente na direção predador→presa, a experiência de arrastar nessa direção não é natural para crianças.
- **Nomes dos organismos em fonte 14px** — pode ser pequeno para crianças em telas menores
- **Sem indicador visual de tutorial durante o jogo** — o jogador descobre o que fazer apenas pela frase "Conecte o predador a presa" no AppBar (quando existia — a AppBar foi substituída pelo GameTopHud e essa instrução pode ter se perdido)
- **Níveis tróficos parcialmente visíveis:** as cores existem no código (`_colorForTrophicLevel` em `organism_component.dart`) e estão bem definidas (verde=produtor, amarelo=consumidor_primario, laranja=secundário/terciário, vermelho=predador_topo) mas **não são aplicadas como badges, bordas ou indicadores visuais nos organismos durante o jogo**. A função existe mas não é chamada em lugar algum.
- **Modal de conclusão ainda sem conteúdo educativo** — mostra apenas estatísticas numéricas
- **Pontuação não é exibida em tempo real com animação** — sem feedback de +100/-10 flutuante

**Sugestões:**
- **Repensar direção:** inverter a mecânica para arrastar da presa para o predador (mais natural) ou adicionar seta animada de direção durante o drag
- Adicionar mini-tutorial contextual na primeira conexão de cada fase
- Incluir legendas de nível trófico visíveis nos organismos (borda/badge colorido)
- Mostrar pontuação em tempo real (+100) com animação flutuante
- Aumentar fonte dos nomes para 16-18px

### 4.5 Modal de fase completa

**Pontos fortes:**
- Slide-up com animação suave
- Estrelas grandes e visíveis
- Estatísticas completas (acertos, erros, tempo)
- Pontuação destacada com glow verde
- Botão claro "VOLTAR ÀS FASES"

**Pontos fracos:**
- **Conteúdo educativo brilhantemente ausente** — o modal mostra apenas números. Não há "O que você aprendeu?" nem conexão com o conceito ecológico
- A seção "O que você descobriu?" mencionada nas fases de design NÃO existe no modal atual
- As estatísticas valorizam mais a performance (pontos, estrelas) do que o aprendizado
- Não há replay da teia montada — a criança não vê o resultado final do seu trabalho
- O botão só leva de volta — não há opção de jogar novamente ou ir para a próxima fase

**Sugestões:**
- Adicionar seção "🌿 O que você descobriu?" com uma curiosidade ecológica sobre o bioma
- Mostrar a teia completa montada pelo jogador como uma imagem de "troféu"
- Adicionar botão "PRÓXIMA FASE" quando disponível
- Incluir uma frase de incentivo personalizada baseada nas estrelas conquistadas

### 4.6 Tutorial

**Pontos fortes:**
- Usa o mesmo motor do jogo (reaproveita FoodWebGame)
- Instrução clara: "Experimente ligar a águia ao coelho"
- Feedback visual e sonoro idêntico ao jogo real
- Botões "VOLTAR" e "COMEÇAR" após conclusão

**Pontos fracos:**
- **Apenas uma conexão** — o tutorial ensina a mecânica mas não ensina o conceito de teia alimentar
- Não explica a direção predador→presa conceitualmente (apenas "ligue a águia até o coelho")
- Fundo genérico (gradiente escuro) — não parece um bioma real
- Sem ilustração ou seta indicando como arrastar
- A mensagem de erro "Quase! A águia é o predador" assume que a criança sabe o que é predador

**Sugestões:**
- Adicionar 2-3 conexões no tutorial para demonstrar múltiplas relações
- Usar o mesmo background do bioma Campo para conectar com o jogo real
- Adicionar animação demonstrativa (hand holding + auto-drag) antes da interação
- Explicar o que é predador e presa com exemplos visuais

### 4.7 Tela Sobre (AboutScreen)

**Pontos fortes:**
- Design consistente com o tema do projeto
- Cards de biomas com ícones e descrições
- Seção de tecnologias
- Botão de reset de progresso

**Pontos fracos:**
- **Tela institucional demais** — parece mais um README visual do que uma tela de jogo
- Poderia ser uma área educativa com glossário de ecologia
- As descrições dos biomas são genéricas ("Ecossistema de gramíneas")
- Não tem ilustrações ou sprites dos biomas
- O reset de progresso fica escondido no final da tela

**Sugestões:**
- Transformar em "Área de Conhecimento" com glossário ilustrado de ecologia
- Adicionar sprites dos organismos em vez de ícones Material Design
- Incluir curiosidades sobre cada bioma com imagens
- Mover o reset de progresso para um local menos proeminente ou com proteção extra

---

## 5. Análise pedagógica

### 5.1 Conceitos e sua presença no jogo

| Conceito | Aparece? | Onde? | Clareza | Visual ou textual? | Melhoria |
|----------|----------|-------|---------|-------------------|----------|
| **Cadeia alimentar** | ⚠️ Parcial | Nas conexões feitas pelo jogador | As conexões criam cadeias, mas o jogo não explica o termo | Visual (linhas) | Explicar que uma conexão é um elo de uma cadeia |
| **Teia alimentar** | ⚠️ Parcial | Conjunto de conexões de um bioma | O nome do jogo é "Teia Alimentar" mas o jogo nunca explica o conceito | Visual | Mostrar como as cadeias se cruzam formando uma teia |
| **Produtor/consumidor/predador** | ⚠️ Parcial | No modelo Organism há `trophicLevel` | O dado existe no banco mas **não é exibido** visualmente no jogo (embora as cores estejam definidas no código) | Não aparece | Adicionar badges/cores nos organismos |
| **Fluxo de energia** | ❌ Não aparece | — | — | — | Explicar visualmente que a energia vai do produtor ao predador |
| **Predador e presa** | ✅ Aparece | Mensagens de feedback, tutorial | Mensagens usam os termos "predador" e "presa" | Textual | Adicionar ícone/indicador visual nos organismos |
| **Organismo em papéis diferentes** | ❌ Não aparece | — | Conceito complexo para criança, mas importante | — | Mostrar que um animal pode ser predador em uma relação e presa em outra (ex: sapo come gafanhoto mas é comido pela cobra) |
| **Relações por bioma** | ✅ Aparece | Fases separadas por bioma | Cada bioma tem seu próprio conjunto de organismos e conexões | Visual + textual | A introdução do bioma poderia contextualizar melhor as relações |

### 5.2 Lacunas pedagógicas

1. **Conceitos nunca explicados:** "cadeia alimentar", "teia alimentar", "nível trófico", "fluxo de energia" — o jogo usa esses conceitos na mecânica mas nunca os nomeia ou explica
2. **Sem progressão pedagógica:** a Fase 1 (Campo) é tão complexa quanto a Fase 4 (Pantanal) — não há curadoria de dificuldade conceitual
3. **Sem reforço pós-fase:** o modal de conclusão não tem conteúdo educativo
4. **Níveis tróficos invisíveis:** o dado `trophicLevel` existe no banco e as cores estão definidas em `_colorForTrophicLevel`, mas **não são aplicadas visualmente** como badges, bordas ou indicadores nos organismos durante o jogo
5. **Sem dicionário/glossário:** se a criança não sabe o que é "predador", não há onde consultar
6. **O jogo não diferencia cadeia vs teia:** o título diz "Teia Alimentar" mas o jogo permite fazer apenas conexões corretas (que formam cadeias). Uma verdadeira teia exigiria múltiplas conexões simultâneas e o sistema atual permite isso, mas não explica o conceito
7. **Papéis múltiplos não destacados:** um Sapo (Campo) come Gafanhoto e é comido por Cobra — essa dualidade nunca é mencionada

### 5.3 Oportunidades pedagógicas

- **Trilha de aprendizagem:** cada bioma poderia introduzir um conceito novo:
  - Campo: "O que é uma cadeia alimentar?"
  - Floresta: "O que é uma teia alimentar?"
  - Oceano: "Níveis tróficos e fluxo de energia"
  - Pantanal: "Biodiversidade e interdependência"
- **Pílulas de conhecimento:** cards educativos que aparecem quando uma conexão é feita ("Você sabia? A águia é um predador de topo!")
- **Glossário visual:** acessível de qualquer tela, com definições infantis e ilustrações
- **"O que você descobriu?"** no modal de conclusão com conteúdo específico do bioma

---

## 6. Análise de game design

### 6.1 O loop principal é divertido?

**Atualmente:** O loop é repetitivo (arrastar, validar, arrastar, validar). A satisfação vem de acertar a conexão, mas o ato de arrastar em si não é particularmente divertido para crianças — especialmente em dispositivos móveis onde o drag precisa ser preciso.

**Potencial:** A mecânica de "descobrir quem come quem" tem apelo de curiosidade natural ("será que a cobra come o coelho?"), que é o principal motor de engajamento.

### 6.2 Sensação de progresso

- **Positivo:** desbloqueio progressivo de fases, estrelas, timer decrescente, **barra de progresso animada no GameTopHud** (mostra visualmente quantas conexões já foram feitas)
- **Negativo:** sem indicador de progresso geral (progresso da fase é mostrado, mas não quantas faltam de forma explícita além do número), sem progressão visual da teia sendo construída
- **Perdido:** não há recompensa visual por completar uma conexão além da linha verde (embora haja glow, seta e partículas)

### 6.3 Recompensa

- **Atual:** +100 pontos, linha verde com glow + seta, partículas, animação de lunge do predador, mensagem educativa, overlay de feedback
- **Falta:** animação de celebração mais impactante, mensagem personalizada por organismo, coleta de "cards" dos organismos descobertos

### 6.4 O erro ensina ou apenas pune?

- **Ensina parcialmente:** a mensagem de erro é contextual (direção errada vs. conexão errada), usa tom não-punitivo ("Quase!", "Atenção!", "Ops!"), linha temporária com cor suave que desaparece em 2.8s
- **Pune levemente:** shake no organismo, linha laranja-avermelhada, sons de erro
- **Falta:** dica construtiva ("A cobra come sapos e coelhos. Tente ligar a cobra a um deles!")

### 6.5 O jogador entende o objetivo rapidamente?

- **Sim, mecanicamente:** o tutorial ensina drag em 2 segundos
- **Não, conceitualmente:** "montar a teia alimentar" é abstrato — a criança pode entender o drag mas não o propósito ecológico

### 6.6 O jogo fica repetitivo?

- **Sim, dentro da mesma fase:** 7-9 conexões para fazer, todas com a mesma mecânica
- **Entre fases:** cada bioma tem organismos diferentes, mas a mecânica é idêntica
- **Falta variedade:** não há eventos, mini-desafios, nem variação na jogabilidade entre biomas

### 6.7 As fases têm identidade própria?

- **Visualmente sim:** cada bioma tem background, sprites e áudio ambiente diferentes
- **Mecanicamente não:** são idênticas (mesmo número de conexões, mesma mecânica)
- **O timer diminui** (120→100→80→60), o que cria pressão mas não variedade

### 6.8 Desafio crescente

- **Leve:** timer menor nas fases seguintes
- **Falta:** mais organismos, conexões mais complexas, conceitos novos, espécies com papéis duais

### 6.9 Motivo para jogar novamente

- **Fraco:** melhorar pontuação e estrelas
- **Falta:** conteúdo desbloqueável (cards de organismos, curiosidades), modo livre, desafios diários

### 6.10 Sugestões de evolução do game design

1. **Construção visual da teia:** mostrar a teia sendo formada em tempo real no fundo
2. **Efeito "eureka":** quando o jogador faz a última conexão, animação de "teia completa" com glow
3. **Cards de organismos:** cada primeira descoberta correta de um organismo rende um card de "conhecimento"
4. **Desafios entre fases:** "encontre a cadeia de 3 elos" ou "qual produtor sustenta mais animais?"
5. **Modo cronômetro vs. modo exploração:** o timer atual pode estressar crianças — oferecer modo sem pressão

---

## 7. Problemas atuais conhecidos

### 7.1 Tabela de problemas

| # | Problema | Gravidade | Arquivos | Descrição |
|---|----------|-----------|----------|-----------|
| 1 | **Sobreposição de organismos em telas pequenas** | 🔴 Crítico | `food_web_game.dart` | Algoritmo de quadrantes com rejeição por overlap funciona na maioria dos casos, mas em telas muito pequenas (<360px) ou com densidade alta de organismos (Floresta: 8) ainda há risco de sobreposição. |
| 2 | **Direção de drag confusa (nomenclatura invertida)** | 🟠 Alto | `connection_system.dart`, `food_web_game.dart` | O código nomeia `sourceId = target (prey)` e `targetId = source (predator)`. Embora a seta visual aponte corretamente, a nomenclatura interna é invertida e gera bugs cognitivos de manutenção. |
| 3 | **Níveis tróficos não exibidos visualmente** | 🟠 Alto | `organism_component.dart`, `game_screen.dart` | `_colorForTrophicLevel` existe no componente com cores definidas (verde, amarelo, laranja, vermelho) mas **não é chamada em lugar algum**. O jogador não vê quem é produtor/consumidor/predador. |
| 4 | **Timer pode estressar crianças** | 🟠 Alto | `game_service.dart` | Timer regressivo sem pausa. Crianças podem ficar ansiosas e desistir. Sem indicação de que é apenas bônus. |
| 5 | **Conteúdo educativo praticamente ausente** | 🟠 Alto | Todas as screens | O jogo tem dados pedagógicos no banco mas não os apresenta. O modal de conclusão mostra apenas números. As mensagens de feedback ensinam parcialmente mas não há pílulas de conhecimento ou glossário. |
| 6 | **Modal de conclusão sem replay visual** | 🟠 Alto | `game_screen.dart` | A teia montada desaparece. A criança não vê o resultado do seu trabalho. |
| 7 | **Linhas de conexão se sobrepõem** | 🟡 Médio | `food_web_game.dart` | O posicionamento atual minimiza cruzamentos mas não os elimina. Floresta tem linhas que inevitavelmente se cruzam. |
| 8 | **Tutorial muito limitado** | 🟡 Médio | `tutorial_screen.dart`, `tutorial_game.dart` | Apenas 1 conexão, sem explicação conceitual, não prepara para a complexidade real. |
| 9 | **Código duplicado de partículas** | 🟡 Médio | `home_screen.dart`, `phases_screen.dart`, `about_screen.dart`, `tutorial_screen.dart` | `_ParticlePainter` e `_ParticleOverlay` são copiados em 4 telas diferentes com leve variação. |
| 10 | **Assets hardcoded** | 🟡 Médio | `asset_paths.dart` | Paths de sprites e backgrounds são mapeados em mapa hardcoded. Adicionar novo organismo exige mexer em 3 arquivos: seed, asset_paths, food_web_game (zones). |
| 11 | **Strings de bioma hardcoded** | 🟡 Médio | `biome_intro_screen.dart` | Textos descritivos e "Observe e Descubra" estão hardcoded no código da tela. Dificulta localização/edição. |
| 12 | **GameService inchado** | 🟡 Médio | `game_service.dart` | Service faz tudo: estado, persistência, validação, timer. Viola princípio de responsabilidade única. |
| 13 | **Sem testes automatizados** | 🟡 Médio | — | Nenhum teste unitário ou de widget encontrado. `flutter_test` está nas dependências mas não é usado. |
| 14 | **Tela Sobre institucional** | 🟡 Médio | `about_screen.dart` | Poderia ser mais útil como área de aprendizado. Botão de reset sensível no final da tela. |
| 15 | **Sem tratamento de overflow em labels longas** | 🟡 Médio | `organism_component.dart` | Nomes como "consumidor_primario" ou organismos com nomes compostos podem vazar. |
| 16 | **Fonte pequena em telas reduzidas** | 🟡 Médio | `game_screen.dart`, `organism_component.dart` | 14px para nome dos organismos pode ser pequeno em telas de celular. |
| 17 | **GameTopHud não mostra instrução "Conecte o predador à presa"** | 🟡 Médio | `game_top_hud.dart` | A antiga AppBar tinha um texto de instrução que foi perdido na substituição pelo GameTopHud. O jogador pode não saber o que fazer ao entrar no jogo. |
| 18 | **Delay de 2.8s para partículas é questionável** | 🟡 Médio | `food_web_game.dart` | O delay existe para sincronizar com o overlay de feedback que dura 3s, mas 2.8s é muito tempo — a criança já esqueceu a ação quando as partículas aparecem. |
| 19 | **Sem animação de "teia completa"** | 🟢 Baixo | `food_web_game.dart` | Ao completar todas as conexões, não há celebração extra antes do submit. |
| 20 | **Dependência do google_fonts sem uso claro** | 🟢 Baixo | `pubspec.yaml` | `google_fonts` está nas dependências — usado no GameTopHud com Nunito, mas inconsistente com outras telas que usam fonte padrão. |
| 21 | **Sobreposição de HUD com o jogo** | 🟢 Baixo | `game_screen.dart` | HUD inferior com gradiente pode cobrir organismos posicionados na parte inferior da tela. |
| 22 | **ProgressCard duplicado** | 🟢 Baixo | `progress_card.dart`, `game_top_hud.dart` | Existe um widget `ProgressCard` standalone (não usado) e uma implementação similar `_ConnectionCard` dentro do GameTopHud. Código duplicado. |

### 7.2 Problemas de responsividade conhecidos

- O jogo usa `MediaQuery` para adaptar tamanhos, mas o posicionamento dos organismos (quadrantes com zonas verticais) pode não considerar bem o aspect ratio
- Em tablets (proporção 4:3), o grid pode ficar espremido ou alongado
- O tamanho dinâmico dos organismos (`min(size.x/6, size.y/6)`) em telas muito largas pode criar organismos enormes
- A Floresta tem 8 organismos — em telas pequenas, fica difícil distribuir bem
- O GameTopHud lida bem com a responsividade (LayoutBuilder com breakpoint 600dp), mas o layout compact pode ficar apertado em telas muito pequenas (<360px)

---

## 8. Arquitetura e qualidade do código

### 8.1 O que está bem estruturado

1. **Separação em camadas:** UI (Screens) → Game (Flame) → Services → Repositories → Database — clara e funcional
2. **Repository Pattern:** `PhaseRepository`, `OrganismRepository`, `ConnectionRepository`, `ScoreRepository` — bem implementados com injeção do DatabaseHelper
3. **Models:** Simples, com `toMap()` e `fromMap()` — fáceis de manter
4. **ConnectionSystem:** Pequeno e focado — boa responsabilidade única
5. **AudioService:** Singleton limpo, com toggle de mute que preserva estado e `AudioContext` para retomada sensível ao contexto
6. **AnimatedSpriteThumbnail:** Componente reutilizável bem feito na intro do bioma
7. **Uso de Provider:** Mudanças de estado propagadas eficientemente
8. **GameTopHud:** Bem estruturado com subcomponentes privados, layout responsivo, tokens de design centralizados, separação de responsabilidades
9. **ConnectionLine:** Renderização avançada em Canvas com curvas bezier, glow, seta, partículas de folha, modo foco — tudo encapsulado no componente

### 8.2 O que está ficando difícil de manter

1. **GameService inchado (~250 linhas):** Mistura carregamento de dados, timer, validação de conexão, pontuação, persistência. Ideal seria quebrar em:
   - `PhaseManager` (carregar fases, unlock)
   - `ConnectionValidator` (validar conexões)
   - `GameTimer`
   - `ScoreManager`

2. **FoodWebGame (~483 linhas):** Posicionamento, validação, animação, partículas, foco — tudo no mesmo arquivo. A lógica de grid de posicionamento (100+ linhas) poderia ser extraída.

3. **Duplicação de código de partículas:** `_ParticlePainter` e `_ParticleOverlay` aparecem em 4 telas com diferenças mínimas. Deveria ser um widget compartilhado.

4. **OrganismAssetPath:** Mapa hardcoded de paths — cada novo organismo exige adicionar entrada aqui. Ideal seria usar convenção de nomenclatura (ex: `animais/{bioma}/{id}.png`).

5. **Textos hardcoded nas telas:** Descrições de bioma e textos educativos estão nas screens, não em um arquivo de constantes ou JSON externo.

6. **ProgressCard vs _ConnectionCard:** Existe um widget `ProgressCard` standalone em `lib/widgets/progress_card.dart` que não é usado em lugar algum. O GameTopHud tem sua própria implementação `_ConnectionCard` com funcionalidade similar. Código morto/duplicado.

7. **DummyGameService:** O tutorial cria um `_DummyGameService` que sobrescreve todos os getters — cheiro de design frágil. O tutorial deveria usar composição em vez de herança.

8. **TutorialGame herda FoodWebGame:** Herança para reutilizar métodos, mas sobrescreve quase tudo. Ideal seria uma classe base `BaseFoodWebGame` ou composição via mixins.

### 8.3 Análise por sistema

**Sistema de banco/seed:**
- Seed completo e bem organizado em 3 métodos (`_insertPhases`, `_insertOrganisms`, `_insertConnections`)
- Fácil de adicionar novos biomas: basta adicionar entries nos 3 métodos
- Posições X/Y manuais foram removidas do seed — agora o posicionamento é feito pelo algoritmo de quadrantes no `food_web_game.dart`

**Sistema de posicionamento:**
- Algoritmo de quadrantes com 4 zonas (top-left, top-right, bottom-left, bottom-right)
- Zonas verticais por organismo (top/middle/bottom) mapeadas no `_zoneMap`
- Rejeição por overlap com até 100 tentativas por organismo
- Substituiu completamente o `HabitatLayout` (que ainda existe mas não é mais usado)
- Código mais limpo que o anterior, mas ainda com ~100 linhas que poderiam ser extraídas

**Sistema de tutorial:**
- Funciona mas é frágil (herança + dummy service)
- Hardcoded para os IDs 7 e 3 (Águia e Coelho)
- Se o banco mudar, o tutorial quebra

**Sistema de áudio:**
- Singleton limpo, com `AudioContext` (none, home, game) para decidir se retoma áudio ao desmutar
- Fácil de adicionar novos sons
- Mute toggle bem implementado, presente na Home e no GameTopHud
- `playAmbient()` só toca se não estiver mutado, mas sempre armazena o bioma para retomada

**Sistema de feedback:**
- Mensagens aleatórias para acerto/erro (boa variação)
- Mensagens de erro com tom instrutivo e não-punitivo ("Quase!", "Atenção!", "Ops!")
- Delay de 2.8s para partículas é questionável (muito longo)
- Shake effect usa recursão manual — poderia usar AnimationController do Flame

**Facilidade para adicionar novos elementos:**
- **Nova fase:** Adicionar no database_seed + asset_paths + zoneMap no food_web_game. Médio trabalho.
- **Novo organismo:** Adicionar no seed, asset_paths, zoneMap, e spritesheet. Médio trabalho.
- **Alterar textos educativos:** Editar o código Dart (biome_intro_screen.dart). Não há arquivo de configuração externo.

---

## 9. Assets e identidade visual

### 9.1 Análise dos assets

**Sprites:**
- São spritesheets com 6 frames de animação cada
- Estilo pixel art consistente entre os organismos
- Tamanhos dos spritesheets variam — o código calcula frame width = image.width / 6
- Qualidade artística é razoável, mas poderia ser mais vibrante para crianças

**Backgrounds:**
- Imagens grandes (1376×3072 para mobile, 2720×1568 para web)
- Cenas de biomas com estilo ilustrativo/pintado
- Cobertura fullscreen com overlay escuro para legibilidade
- Campo (gramíneas abertas), Floresta (árvores densas), Oceano (submerso azul), Pantanal (alagado)

**Consistência:**
- **Problema:** Sprites são pixel art, backgrounds são ilustrações pintadas — estilos diferentes se chocam
- **Problema:** Fundo do jogo usa o background do bioma, mas com overlay escuro forte (0.45 alpha) que reduz a visibilidade do cenário
- **Problema:** Na BiomeIntroScreen o fundo é o background do bioma, mas o jogo (GameScreen) usa gradiente escuro por trás do Flame — o background do bioma é carregado pelo `BackgroundComponent` dentro do jogo

**Legibilidade:**
- Nomes em fonte branca com sombra preta — boa legibilidade na maioria dos fundos
- Tamanho 14px é aceitável em desktop mas pequeno em mobile
- Labels de nome têm pill escuro com glow quando o organismo está destacado

**Cores dos níveis tróficos (definidas mas não usadas):**
- `produtor`: verde (`AppColors.correct`)
- `consumidor_primario`: amarelo (#FFC107)
- `consumidor_secundario`: laranja (#FF9800)
- `consumidor_terciario`: laranja escuro (#F57C00)
- `predador_topo`: vermelho (`AppColors.connectionError`)

**Efeitos de partículas:**
- **Acerto:** 70 partículas (verde 50%, ouro 30%, branco 20%) — comportamento explosivo com expansão e fade
- **Erro:** 50 partículas (vermelho suave 50%, laranja 35%, cinza 15%) — dissipação suave com encolhimento
- Delay de 2.8s antes de aparecer — muito longo, a criança já esqueceu
- Sem sprites temáticos (folhas, estrelas) — apenas círculos coloridos

**Sons:**
- Ambientes por bioma com música de fundo
- Efeitos: acertou.mp3, errou.mp3, terminou.mp3
- Qualidade não avaliada (não tenho os arquivos de áudio)

**GameTopHud design system:**
- Cards: altura 48px (wide) / 36px (compact), border-radius 14px (wide) / 10px (compact), padding horizontal 16px (wide) / 8px (compact)
- Fundo: verde escuro `#0B3D22` com alpha 0.88
- Borda: verde `#2E7D32` com alpha 0.65, largura 1.5px
- Glow: `#2E7D32` alpha 0.25, blur 8px, offset (0, 2)
- Texto: Nunito (Google Fonts), peso 700-800, cor `#F0FDF4`
- Ícones: tamanho 22px (wide) / 16px (compact), cores por função (amarelo para score, verde para conexões)

**Botões e cards:**
- Consistência visual entre telas (gradientes verdes, bordas verdes, fundo escuro)
- `HoverButton` com animação de scale — polido
- `PhaseCard` com ícone por bioma e fade para bloqueado — funcional

### 9.2 Sugestões visuais

1. **Unificar estilo artístico:** ou sprites pixel art + background pixel art, ou sprites ilustrados + background ilustrado
2. **Adicionar glow nos níveis tróficos:** borda colorida ao redor do sprite conforme o nível trófico (código já existe, só não é aplicado)
3. **Melhorar partículas:** usar sprites de folhas/estrelas/animais em vez de círculos genéricos
4. **Reduzir delay das partículas:** de 2.8s para 0.5-1.0s para feedback mais imediato
5. **Tornar nomes mais lúdicos:** usar fonte mais amigável (Nunito já está sendo usado no GameTopHud via Google Fonts — estender para o jogo)
6. **Animar background:** movimento parallax sutil no cenário de fundo
7. **Ícone do jogo:** criar um ícone personalizado (atualmente usa `Icons.eco`)
8. **Paleta mais vibrante:** o tema escuro é elegante mas pode parecer "sério" demais para crianças

---

## 10. Recomendações de remodelagem

### 10.1 Melhorias já implementadas (da análise anterior)

As seguintes recomendações da análise anterior foram implementadas:

| # | Melhoria | Status | Observação |
|---|----------|--------|------------|
| R1 | Mostrar nível trófico nos organismos | ⚠️ Parcial | Cores definidas no código mas não aplicadas visualmente |
| **R2** | **Adicionar seta nas linhas de conexão** | ✅ **COMPLETO** | Seta em ~68% da linha, tamanho 22px (correta) / 14px (erro), com glow |
| R3 | Conteúdo educativo no modal de conclusão | ❌ Não implementado | Ainda sem conteúdo pós-fase |
| R4 | Extrair textos para arquivo de constantes | ❌ Não implementado | Textos ainda hardcoded |
| R5 | Unificar ParticleOverlay como widget compartilhado | ❌ Não implementado | Partículas ainda duplicadas em 4 telas |
| R6 | Aumentar fonte dos nomes dos organismos | ❌ Não implementado | Ainda 14px |
| R7 | Reduzir delay das partículas de 2.8s para 0.5s | ❌ Não implementado | Delay ainda é 2.8s |
| R8 | Adicionar botão "Jogar novamente" no modal | ❌ Não implementado | Apenas "Voltar às fases" |
| — | **HUD superior reformulado (GameTopHud)** | ✅ **COMPLETO** | Biome card, score, progress bar animada, timer, back, audio toggle, responsivo |
| — | **Feedback visual de erro melhorado** | ✅ **COMPLETO** | Linha temporária, glow suave, mensagens instrutivas, tom não-punitivo |
| — | **Destaque do organismo selecionado** | ✅ **COMPLETO** | Glow multi-camada, borda luminosa, label pill |
| — | **Modo foco automático** | ✅ **COMPLETO** | Ativado no drag, dimming de conexões não relacionadas |
| — | **Áudio com contexto** | ✅ **COMPLETO** | AudioContext para retomada inteligente, toggle na Home e GameTopHud |

### 10.2 Melhorias rápidas (baixo risco, alto impacto)

| # | Melhoria | Problema que resolve | Impacto criança | Impacto pedagógico | Risco técnico | Arquivos afetados |
|---|----------|---------------------|-----------------|-------------------|---------------|-------------------|
| R1b | **Aplicar cores de nível trófico como badge/borda nos organismos** | Nível trófico invisível | Entende quem é produtor/consumidor/predador | Alto — ensina classificação | Baixo | `organism_component.dart` |
| R2b | **Conteúdo educativo no modal de conclusão** | Sem aprendizado pós-fase | Leva um conhecimento para casa | Alto — reforça aprendizado | Baixo | `game_screen.dart` |
| R3b | **Extrair textos para arquivo de constantes** | Strings hardcoded | — | — | Baixo | `biome_intro_screen.dart`, novo `lib/core/biome_texts.dart` |
| R4b | **Unificar ParticleOverlay como widget compartilhado** | Código duplicado em 4 telas | — | — | Baixo | Criar `widgets/particle_overlay.dart`, editar 4 screens |
| R5b | **Aumentar fonte dos nomes dos organismos** | Legibilidade em mobile | Consegue ler os nomes | — | Baixo | `organism_component.dart` |
| R6b | **Reduzir delay das partículas de 2.8s para 0.5-1.0s** | Feedback demorado | Resposta mais imediata | — | Baixo | `food_web_game.dart`, `tutorial_game.dart` |
| R7b | **Adicionar botão "Jogar novamente" no modal** | Falta de replay imediato | Pode tentar de novo sem voltar | — | Baixo | `game_screen.dart` |
| R8b | **Restaurar instrução "Conecte o predador à presa" no GameTopHud** | Jogador sem orientação | Sabe o que fazer ao entrar | Médio | Baixo | `game_top_hud.dart` |
| R9b | **Remover ProgressCard duplicado ou unificar com _ConnectionCard** | Código morto/duplicado | — | — | Baixo | `progress_card.dart`, `game_top_hud.dart` |

### 10.3 Remodelagem média (mais tempo, grande melhoria)

| # | Melhoria | Problema que resolve | Impacto criança | Impacto pedagógico | Risco técnico | Arquivos afetados |
|---|----------|---------------------|-----------------|-------------------|---------------|-------------------|
| M1 | **Repensar fluxo de conexão e nomenclatura** | Direção confusa no código e no jogo | Menos confusão ao arrastar | Médio | Médio | `connection_system.dart`, `food_web_game.dart`, `game_service.dart` |
| M2 | **Refatorar FoodWebGame (extrair grid positioning)** | Arquivo grande (483 linhas) | — | — | Médio | Extrair `positioning_helper.dart` |
| M3 | **Refatorar GameService em serviços menores** | Responsabilidade única violada | — | — | Alto | Quebrar em 3-4 serviços |
| M4 | **Criar arquivo de configuração externo para textos** | Dificuldade de editar conteúdo | — | Alto — conteúdos editáveis sem código | Médio | JSON de textos, biomas, descrições |
| M5 | **Adicionar animação de "teia completa"** | Falta de celebração visual | Sensação de recompensa e realização | Médio | Médio | `food_web_game.dart`, `game_screen.dart` |
| M6 | **Adicionar indicador de progresso qualitativo** | Barra mostra número mas não "sensação de avanço" | Menos ansiedade, mais clareza | — | Baixo | `game_top_hud.dart` |
| M7 | **Criar modo "exploração" sem timer** | Timer estressa crianças | Pode aprender no próprio ritmo | Alto | Baixo | `game_service.dart`, `game_screen.dart` |
| M8 | **Melhorar o tutorial com 2-3 conexões** | Tutorial raso | Aprende melhor antes do jogo real | Alto | Médio | `tutorial_game.dart`, `tutorial_screen.dart` |
| M9 | **Adicionar modo Classificação por Níveis Tróficos** | Falta modo pedagógico estruturado | Aprende classificação ecológica | Alto | Alto | Novo modo (ver seção 15) |

### 10.4 Evolução grande (transformação do projeto)

| # | Melhoria | Problema que resolve | Impacto criança | Impacto pedagógico | Risco técnico | Arquivos afetados |
|---|----------|---------------------|-----------------|-------------------|---------------|-------------------|
| G1 | **Sistema de progressão narrativa** | Jogo sem história | Engajamento emocional | Médio — pode contextualizar | Alto | Múltiplos screens |
| G2 | **Card de organismos (colecionável)** | Falta de recompensa duradoura | Quer jogar para colecionar todos | Alto — aprende sobre cada espécie | Alto | Novo model + tela de coleção |
| G3 | **Sistema de dicas visuais** | Erro sem aprendizado | Recebe ajuda contextual | Alto | Médio | `game_service.dart`, `game_screen.dart` |
| G4 | **Glossário de ecologia** | Sem consulta de conceitos | Aprende termos no jogo | Alto | Médio | Nova tela + widget |
| G5 | **Modo livre (montar teia sem validação)** | Foco na exploração | Experimenta sem medo de errar | Alto | Alto | Novo modo em `food_web_game.dart` |
| G6 | **Sistema de conquistas/logros** | Falta de motivo para rejogar | Volta para desbloquear conquistas | Médio | Médio | Novo model + achievement_system |
| G7 | **Suporte a mais biomas via configuração** | Dificuldade de escalar | Mais conteúdo | Alto | Alto | Sistema de fases configurável via JSON |
| G8 | **Áudio com narração educativa** | Conteúdo apenas textual | Aprende ouvindo (inclusão) | Alto | Alto | `audio_service.dart`, novos assets |

---

## 11. Possíveis novos fluxos de jogo

### 11.1 Fluxo A — Jogo atual polido (evolução do atual)

```
Home → Seleção de Fases → Introdução do Bioma → Jogo (com GameTopHud) 
→ Modal "O que você descobriu?" → Volta às fases

Home → Tutorial (melhorado, 3 conexões)
Home → Ranking
Home → Glossário de Ecologia
```

**Vantagens:**
- Mínima mudança estrutural
- Baixo risco técnico
- Rápido de implementar

**Desvantagens:**
- Não resolve problemas de engajamento de longo prazo
- Ainda linear e previsível

**Complexidade:** Baixa

### 11.2 Fluxo B — Modo Investigação (detetive ecológico)

```
Home → Missão: "Descubra quem está comendo quem na floresta!"
→ Bioma aparece com pergunta: "Qual animal está no topo da cadeia?"
→ Jogador monta conexões → Cada acerto revela uma curiosidade
→ Ao final: "Você descobriu que..."
→ Modal com infográfico da teia + curiosidades
```

**Vantagens:**
- Engajamento por curiosidade (o que vem depois?)
- Conteúdo educativo integrado à recompensa
- Sensação de descoberta real

**Desvantagens:**
- Requer redesenho parcial do fluxo de jogo
- Precisa de roteiro de conteúdo para cada bioma
- Pode ser mais complexo de implementar

**Complexidade:** Média-Alta

### 11.3 Fluxo C — Modo Aventura (personagem guia)

```
Home → Personagem guia (ex: "Tuco, o Tucano") aparece
→ "Vamos explorar os biomas do Brasil!"
→ Bioma 1: Campo → Tuco explica o que é uma cadeia alimentar
→ Mini-jogo 1: Arraste 3 conexões para formar a primeira cadeia
→ Bioma 1 concluído: Tuco dá um "selo de explorador"
→ Bioma 2: Floresta → Tuco explica teia alimentar
→ Mini-jogo 2: Monte a teia completa (mais conexões)
→ Progressão: cada bioma adiciona um conceito novo
→ Final: "Parabéns, você é um explorador dos ecossistemas!"
```

**Vantagens:**
- Narrativa envolvente para crianças
- Progressão pedagógica clara
- Cada bioma tem um objetivo de aprendizado específico
- Sensação de jornada e recompensa

**Desvantagens:**
- Requer personagem, ilustrações, animações e/ou diálogos
- Maior esforço de desenvolvimento
- Pode engessar a experiência se for muito linear

**Complexidade:** Alta

### 11.4 Fluxo D — Híbrido (recomendado para próxima iteração)

```
Home → Personagem guia (ilustração estática + texto)
→ "Vamos descobrir os segredos da natureza!"
→ Seleção de Fases (igual ao atual, mas com estrelas visíveis)
→ Introdução do Bioma (com pergunta investigativa + glossário)
→ Jogo (modo padrão SEM timer / COM timer opcional)
→ Cada conexão correta: mini card educativo ("Você sabia?")
→ Teia completa: animação de celebração
→ Modal: "O que você descobriu?" + pontos + estrelas + curiosidade
→ Libera próximo bioma + card de organismo especial
```

**Vantagens:**
- Mantém a estrutura existente
- Adiciona camada pedagógica sem quebrar fluxo
- Baixo risco, alto impacto

**Desvantagens:**
- Não é uma revolução, é evolução
- Ainda pode não ser "aventuresco" o suficiente

**Complexidade:** Média

---

## 12. Roadmap sugerido

### Fase 1 — Consolidar e polir o jogo atual *(1-2 semanas)*

**Objetivo:** resolver problemas críticos e melhorar a experiência imediata.

- [ ] **R1b:** Aplicar cores de nível trófico como badge/borda nos organismos (ativar `_colorForTrophicLevel`)
- [ ] **R2b:** Inserir conteúdo educativo no modal de conclusão
- [ ] **R3b:** Extrair textos para arquivo de constantes (`biome_texts.dart`)
- [ ] **R4b:** Unificar `ParticleOverlay` como widget compartilhado
- [ ] **R5b:** Aumentar fonte dos nomes dos organismos para 16-18px
- [ ] **R6b:** Reduzir delay das partículas para 0.5-1.0s
- [ ] **R7b:** Adicionar botão "Jogar novamente" e "Próxima fase" no modal
- [ ] **R8b:** Restaurar instrução textual no GameTopHud
- [ ] **R9b:** Remover ProgressCard duplicado ou unificar
- [ ] **Bugfix:** Revisar posicionamento para evitar sobreposição em telas pequenas

### Fase 2 — Melhorar a experiência pedagógica *(2-3 semanas)*

**Objetivo:** transformar o jogo em uma ferramenta de aprendizado de verdade.

- [ ] **M8:** Expandir tutorial com 2-3 conexões e explicação conceitual
- [ ] **M7:** Criar modo "exploração" sem timer (alternativo)
- [ ] **M6:** Adicionar indicador de progresso qualitativo
- [ ] Criar cards educativos que aparecem ao fazer cada conexão
- [ ] Adicionar "O que você descobriu?" no modal com conteúdo por bioma
- [ ] Criar glossário básico de ecologia (tela acessível de qualquer lugar)
- [ ] Melhorar descrições dos biomas com fatos curiosos

### Fase 3 — Refatorar arquitetura *(2-3 semanas)*

**Objetivo:** preparar o código para escalar.

- [ ] **M1:** Repensar nomenclatura de direção de conexão (source→target)
- [ ] **M2:** Extrair lógica de grid positioning para arquivo separado
- [ ] **M3:** Refatorar GameService (separar timer, validação, score)
- [ ] **M8:** Refatorar TutorialGame (usar composição em vez de herança)
- [ ] Extrair textos e configurações para arquivos JSON ou Dart constants
- [ ] Adicionar testes unitários para ScoringService e ConnectionSystem
- [ ] Criar base para carregamento dinâmico de fases (preparar para JSON)

### Fase 4 — Evoluir game design e identidade visual *(3-4 semanas)*

**Objetivo:** tornar o jogo mais divertido e visualmente atrativo.

- [ ] **M5:** Adicionar animação de "teia completa" com celebração
- [ ] **M9:** Implementar modo Classificação por Níveis Tróficos (ver seção 15)
- [ ] **G2:** Implementar sistema de cards de organismos colecionáveis
- [ ] **G4:** Glossário completo com ilustrações e definições infantis
- [ ] Redesenhar sprites ou backgrounds para estilo unificado
- [ ] Adicionar fonte mais lúdica (usar google_fonts já importado — consistência)
- [ ] Melhorar partículas (folhas, estrelas, animações temáticas)
- [ ] Adicionar parallax sutil no background do jogo
- [ ] Criar ícone personalizado do jogo

### Fase 5 — Preparar para portfólio e apresentação *(1-2 semanas)*

**Objetivo:** garantir que o projeto esteja apresentável e documentado.

- [ ] Revisar README e AGENTS.md com informações atualizadas
- [ ] Adicionar capturas de tela e GIF do gameplay
- [ ] Escrever resumo de aprendizado e desafios técnicos
- [ ] Garantir builds funcionais para Web, Android e Windows
- [ ] Testar em diferentes tamanhos de tela
- [ ] Adicionar testes de widget para telas principais
- [ ] Verificar acessibilidade (contraste, tamanho de fonte, labels)

---

## 13. Perguntas em aberto

1. **O jogo deve focar em cadeia alimentar ou teia alimentar?** O título diz "Teia Alimentar", mas atualmente o jogo permite construir relações que formam mais cadeias do que teias. A diferença precisa ser mais clara.

2. **A criança deve poder errar livremente ou receber dicas ativamente?** Hoje o erro é penalizado com -10 pontos e a linha desaparece. Um modo "aprendizado" poderia dar dicas antes do erro.

3. **O jogo deve ter um personagem guia (mascote)?** Um mascote como "Tuco o Tucano" ou "Lina a Lagartixa" poderia guiar a criança, explicar conceitos e celebrar conquistas.

4. **O posicionamento dos organismos deve ser manual por fase ou automático?** Atualmente é automático por quadrantes. O automático é mais escalável, mas o manual permitiria layouts mais intencionais.

5. **O jogo deve ter progressão narrativa?** Uma história que liga os biomas (ex: "um animal está perdendo seu habitat") poderia dar propósito à jornada.

6. **O ranking é importante ou secundário?** Para crianças pequenas, ranking pode ser desmotivador. Talvez um sistema de conquistas individuais seja melhor.

7. **A tela Sobre deve virar uma área de aprendizagem?** Atualmente é institucional. Poderia ser um "Museu de Ecologia" com glossário, curiosidades e cards colecionados.

8. **Timer deve ser padrão ou opcional?** O timer estressa algumas crianças. Um toggle "Modo tranquilo / Modo desafio" poderia atender ambos os perfis.

9. **Deve haver conteúdo após completar todas as fases?** Atualmente o jogo termina após o Pantanal. Conteúdo pós-jogo (modo livre, biomas extras, desafios) aumentaria a longevidade.

10. **O jogo deve ter localização (inglês/espanhol)?** Para portfólio e alcance, internacionalização seria um diferencial.

11. **GameTopHud deve incorporar badges de nível trófico?** Com a ativação das cores de nível trófico, o HUD poderia mostrar uma legenda ou mini-ícones indicando os níveis.

12. **Modo Classificação por Níveis Tróficos deve ser um modo separado ou integrado ao fluxo principal?** Ver seção 15 para análise detalhada.

---

## 14. Conclusão

### Diagnóstico geral

O **ECOnnect: Teia Alimentar** é um projeto sólido em termos de arquitetura e engenharia, com boas práticas de separação de camadas, uso de padrões como Repository e Provider, e uma base de código organizada. A mecânica principal (arrastar para conectar) está funcional e o fluxo de telas é coerente.

**Desde a análise anterior, melhorias significativas foram implementadas:**
- **GameTopHud reformulado** — HUD superior completo com biome card, score, barra de progresso animada, timer, back e audio toggle
- **Conexões visuais avançadas** — curvas bezier com glow pulsante, setas direcionais em ~68%, partículas de folha, modo foco
- **Destaque do organismo selecionado** — glow multi-camada com 3 layers, borda luminosa, label com pill
- **Modo foco automático** — ativado no drag, dimming inteligente
- **Feedback de erro melhorado** — linha temporária, glow suave, mensagens instrutivas, tom não-punitivo
- **Áudio com contexto** — AudioContext para retomada inteligente, toggle na Home e GameTopHud

No entanto, o projeto **ainda prioriza a infraestrutura técnica em detrimento da experiência do usuário e do conteúdo pedagógico** em áreas importantes. O jogo melhorou tecnicamente e visualmente, mas ainda não encanta, não ensina de forma explícita e não motiva a criança a continuar jogando além da primeira sessão.

### Maiores forças

- **Arquitetura limpa e em camadas** — fácil de navegar e manter
- **Mecânica de drag & drop funcional e validada** — o core game loop existe e funciona
- **Dados bem estruturados no banco** — seed completo com 29 organismos e 36 conexões
- **Design visual consistente** — tema escuro com verde, gradientes e bordas coerentes
- **Sistema de áudio por bioma** — ambiente imersivo com sons distintos e contexto inteligente
- **Código comentado e organizado** — boa legibilidade
- **Suporte multiplataforma** — Android, Web, Windows
- **GameTopHud bem projetado** — responsivo, design system claro, componentes separados
- **Conexões visuais avançadas** — bezier curves, glow, arrows, particles, focus mode
- **Feedback visual rico** — partículas temáticas, glow multi-camada, animações de lunge

### Maiores fragilidades

- **Conteúdo pedagógico quase ausente** — o jogo não explica os conceitos que deveria ensinar
- **Níveis tróficos invisíveis** — cores definidas no código mas não aplicadas visualmente
- **UX/UI sem apelo infantil** — design sério e escuro, sem mascote, cores vibrantes ou elementos lúdicos
- **Direção de drag contra-intuitiva** — nomenclatura confusa no código (source/target invertidos)
- **Código duplicado (partículas, ProgressCard)** — widgets não compartilhados
- **GameService inchado** — faz tudo, viola responsabilidade única
- **Sem testes** — zero cobertura de testes automatizados
- **Tutorial limitado** — não prepara a criança conceitualmente para o jogo
- **ProgressCard duplicado** — widget standalone não utilizado vs. implementação interna no GameTopHud

### Principal oportunidade de evolução

**Transformar o jogo de "app funcional com visuais melhorados" para "experiência de aprendizado encantadora".**

O projeto tem uma base técnica excelente e agora também tem visuais melhorados (conexões, HUD, highlights). O que falta não é reescrever — é **adicionar camadas de significado, diversão e pedagogia** sobre a estrutura existente. Com mudanças relativamente pequenas (ativar as cores de nível trófico que já existem, adicionar conteúdo educativo, melhorar o tutorial), o jogo pode sair de "funciona mas não ensina" para "ensina enquanto diverte".

### Recomendação do próximo passo

**Seguir a Fase 1 do roadmap: consolidar e polir.** Implementar as melhorias rápidas identificadas (R1b-R9b) resolve os problemas mais críticos de UX e pedagogia com baixo risco técnico. A prioridade imediata deve ser:

1. **Aplicar cores de nível trófico visualmente** (R1b) — código já existe, só precisa ser ativado. Impacto pedagógico máximo com mínimo esforço.
2. **Conteúdo educativo no modal de conclusão** (R2b) — fecha o ciclo de aprendizado
3. **Restaurar instrução no GameTopHud** (R8b) — orienta o jogador
4. **Unificar partículas** (R4b) — prepara código para evolução futura

---

## 15. Modo planejado: Classificação por Níveis Tróficos

### 15.1 Visão geral

Este modo é um **modo de jogo separado** (não substitui o modo "Teia Alimentar" existente). Enquanto o modo atual foca em descobrir relações de predação (quem come quem), o modo Classificação foca em **identificar e classificar organismos por seu nível trófico** (produtor, consumidor primário, secundário, terciário, predador de topo).

### 15.2 Objetivos do modo

- Arrastar cada organismo para a zona/nível trófico correto
- Completar a classificação de todos os organismos do bioma
- Receber feedback imediato sobre acerto/erro
- Aprender visualmente a pirâmide trófica

### 15.3 Diferenças do modo atual (Teia Alimentar)

| Aspecto | Modo Teia Alimentar (atual) | Modo Classificação (planejado) |
|---------|----------------------------|-------------------------------|
| Objetivo | Conectar predador → presa | Classificar organismo por nível trófico |
| Mecânica | Arrastar entre organismos | Arrastar organismo para zona alvo |
| Validação | Par source-target existe no grafo? | trophicLevel do organismo coincide com zona? |
| Feedback | Linha verde/vermelha entre dois organismos | Organismo "encaixa" na zona correta/errada |
| Visual | Teia de conexões | Pirâmide trófica com zonas coloridas |
| Progresso | N conexões de N total | N organismos classificados de N total |
| Conceito ensinado | Relações de predação | Níveis tróficos e fluxo de energia |

### 15.4 Por que como modo separado?

1. **Experiência de jogo fundamentalmente diferente:** a mecânica de arrastar para zonas é diferente de arrastar entre organismos. Misturá-las confundiria o jogador.
2. **Não há sobreposição de regras:** no modo atual, uma conexão válida depende do par predador-presa. No modo classificação, a validação é por atributo do organismo (nível trófico). São lógicas distintas.
3. **Público e dificuldade diferentes:** o modo classificação é mais simples e adequado para crianças menores ou como introdução conceitual antes do modo teia.
4. **Reaproveitamento de assets:** ambos os modos compartilham os mesmos organismos, sprites, biomas e dados de seed — apenas a lógica de jogo muda.
5. **Progressão pedagógica natural:** Classificação → Teia (aprender os níveis antes de entender as relações).

### 15.5 Arquivos sugeridos

```
lib/
├── game/
│   ├── classification_game.dart       — Novo: FlameGame para o modo classificação
│   ├── components/
│   │   ├── trophic_zone_component.dart — Novo: zona alvo para cada nível trófico
│   │   └── organism_draggable.dart     — Novo: organismo arrastável para zona (pode reutilizar OrganismComponent)
│   └── systems/
│       └── classification_system.dart  — Novo: lógica de validação de classificação
├── screens/
│   └── classification_screen.dart      — Novo: tela do modo classificação (similar à GameScreen)
└── widgets/
    └── trophic_legend.dart             — Novo: legenda visual dos níveis tróficos
```

### 15.6 Componentes reutilizáveis do modo atual

- `OrganismComponent` — pode ser reutilizado (com modificações) para os organismos arrastáveis
- `AudioService` — reuso direto (sons de acerto/erro, áudio ambiente)
- `GameService` — requer extensão ou novo service para lógica de classificação
- `ScoringService` — reuso com novos parâmetros
- `ScoreRepository` — reuso (new score type or phase type)
- `DatabaseSeed` — reuso direto (os dados de organismo com trophicLevel já existem)
- `ConnectionEffect` — reuso para feedback de acerto/erro
- `StarsDisplay` — reuso direto
- `GameTopHud` — reuso com modificações (precisa remover/adicionar cards)
- `AudioToggleButton` — reuso direto
- `HoverButton` — reuso direto

### 15.7 Acoplamento e riscos

- **Baixo acoplamento com o modo atual** — o modo classificação é independente e não deve modificar arquivos existentes do modo teia. A separação em novos arquivos (classification_game.dart, etc.) garante isso.
- **Compartilhamento seguro:** models, database, repositories, audio service e scoring service são compartilhados sem risco.
- **Risco médio no OrganismComponent:** se o componente for muito acoplado à lógica de drag entre organismos, pode precisar de refatoração para suportar drag para zonas. Ideal é criar um wrapper ou componente separado (`OrganismDraggable`).
- **GameTopHud:** pode precisar de parâmetros de configuração para esconder/mostrar cards específicos de cada modo.

### 15.8 Recomendação de implementação

1. **Fase 1** (1-2 semanas): Implementar o modo básico para um bioma (Campo) como prova de conceito
   - Criar `classification_game.dart` com zonas tróficas verticais
   - Reutilizar `OrganismComponent` com modo de drag para zona
   - Feedback visual de acerto/erro (reutilizar `ConnectionEffect`)
   - Pontuação simples (+100 por acerto)
2. **Fase 2** (1 semana): Integrar com GameTopHud (reutilizar), AudioService, ScoringService
3. **Fase 3** (1 semana): Adicionar aos 4 biomas, refinar animações e feedback
4. **Fase 4** (opcional): Adicionar variantes (arrastar na ordem da cadeia, preencher lacunas, etc.)

---

> **Documento gerado em:** Julho de 2026  
> **Baseado na análise do código-fonte em:** `/lib/`, `pubspec.yaml`, `AGENTS.md`, `README.md`  
> **Ferramentas utilizadas:** análise estática de código com codegraph, leitura de arquivos-fonte  
> **Última revisão:** Esta é uma versão atualizada que reflete as melhorias implementadas (GameTopHud, conexões avançadas, highlights, modo foco, áudio com contexto) e adiciona a seção 15 sobre o modo Classificação por Níveis Tróficos.
