# 01 — Diagnóstico e Plano de Melhorias

## EcoConnect: Teia Alimentar

> **Data:** 30/06/2026
> **Branch analisada:** `development` (único commit `9a34048`)
> **Propósito:** Análise completa de UX, pedagogia, código e organização, com plano
>   de implementação em commits pequenos.

---

## Resumo Executivo

A branch `development` contém todo o código do projeto num único commit. Não há
branch `main` para comparação. O jogo está funcional e bem estruturado em
camadas (UI → Game → Services → Repositories → Database), com visual escuro
consistente e mecânica de arrastar-linha entre organismos.

**Principais descobertas:**

- Arquitetura em camadas **bem definida** (SOLID, Repository Pattern)
- Visual escuro consistente com identidade própria
- **Sistema de dicas (`HintButton`) e widgets (`OrganismWidget`, `ScoreDisplay`)
  existem mas não são usados** em lugar nenhum
- **Posicionamento aleatório dos organismos** ignora as `positionX`/`positionY`
  cuidadosamente definidas no seed do banco
- **Níveis tróficos estão no DB mas nunca são exibidos** — perda pedagógica
- **Não há feedback imediato por conexão** — tudo é validado apenas no "Submeter"
- **Timer decrescente gera ansiedade** desnecessária para um jogo educativo
- **"Game over" mencionado no README mas não implementado** no código
- **Zero testes efetivos** + `print()` de debug em produção
- **Código de partículas duplicado em 4 telas** (cópia idêntica)

---

## Estrutura Atual do Jogo

### Fluxo do Jogador

```
HomeScreen ──→ PhasesScreen ──→ GameScreen (Flame) ──→ Modal conclusão
    │                │                                       │
    ↓                ↓                                       ↓
RankingScreen    AboutScreen                           Volta às Fases
```

### Telas

| Tela | Função |
|---|---|
| `HomeScreen` | Título + "JOGAR" + Ranking + Sobre + nome editável |
| `PhasesScreen` | Lista de 4 fases (Campo, Floresta, Oceano, Pantanal) com bloqueio |
| `GameScreen` | Core do jogo: AppBar (fase+ timer+score), Flame widget, HUD inferior |
| `RankingScreen` | Pontuações por fase com seletor |
| `AboutScreen` | Info do jogo + biomas + tecnologias + reset de progresso |

### Componentes Flame

| Componente | Responsabilidade |
|---|---|
| `FoodWebGame` | Game loop, load/reset, coordena drag & drop, submissão |
| `OrganismComponent` | Sprite + nome + hit circle + idle bob + drag callbacks + highlight |
| `ConnectionLine` | Linha animada + seta entre source e target |
| `DragIndicator` | Linha pontilhada animada durante o arrasto |
| `BackgroundComponent` | Fundo do bioma com scale cover + overlay escuro |
| `ConnectionSystem` | Estado do drag (source, target, posição do ponteiro) |

### Arquivos Mais Importantes

| Arquivo | Papel | Linhas |
|---|---|---|
| `lib/game/food_web_game.dart` | Core do jogo | 228 |
| `lib/services/game_service.dart` | Estado central (Provider) | 208 |
| `lib/screens/game_screen.dart` | UI do jogo + HUD + modal | 674 |
| `lib/database/database_seed.dart` | Dados de fases/organismos/conexões | 346 |
| `lib/game/components/organism_component.dart` | Drag + render organismo | 134 |
| `lib/game/components/connection_line.dart` | Linha + seta | 94 |
| `lib/repositories/score_repository.dart` | Persistência + desbloqueio | 58 |
| `lib/services/scoring_service.dart` | Cálculo de pontos/estrelas | 21 |

### Modelos

| Modelo | Campos |
|---|---|
| `Phase` | id, name, description, biome, sortOrder |
| `Organism` | id, phaseId, name, emoji, trophicLevel, **positionX/Y** (⚠️ ignorados) |
| `CorrectConnection` | id, phaseId, sourceId, targetId |
| `Score` | id, phaseId, playerName, score, stars, errors, completedAt |

---

## Comparação Branch vs Main

**Não há branch `main`.** O repositório contém apenas o commit inicial
(`9a34048`) na branch `development`. Não é possível comparar com `main`.

---

## Diagnóstico Detalhado

### UX

| # | Problema | Gravidade | Detalhes |
|---|---|---|---|
| 1 | **Sem feedback por conexão** | 🔴 | O jogador faz N conexões mas só descobre se acertou/errou ao clicar "Submeter" |
| 2 | **Sem tutorial onboarding** | 🔴 | Primeira vez: zero instruções. README explica as regras, o app não |
| 3 | **Posições aleatórias dos organismos** | 🔴 | `_generateRandomPositions()` ignora `positionX/Y` do DB. Cada reload muda tudo |
| 4 | **Label dos organismos muito pequeno** | 🟡 | 11px, sem borda/sombra — difícil de ler, especialmente em mobile |
| 5 | **Direção do drag confusa** | 🟡 | Arrastar presa→predador só é detectado como erro no submit |
| 6 | **Botão Submeter pouco visível** | 🟡 | Aparece só no HUD inferior, pode passar despercebido |
| 7 | **Timer causa ansiedade** | 🟡 | Fase 4: 60s — pressão desnecessária em jogo educativo |
| 8 | **Modal não mostra quais conexões errou** | 🟡 | Mostra "3 erros" mas não quais — sem aprendizado |
| 9 | **Dicas existem no código mas não na tela** | 🟡 | `HintButton` em `widgets/` nunca importado na `game_screen.dart` |
| 10 | **Game over não implementado** | 🟡 | README menciona, mas `_score` só é calculado no submit |

### Pedagogia

| # | Problema | Gravidade | Detalhes |
|---|---|---|---|
| 1 | **Nível trófico invisível** | 🔴 | DB tem `trophic_level` mas nunca é exibido — perda pedagógica gigante |
| 2 | **Sem explicação educativa** | 🔴 | Nada explica o que é teia alimentar, níveis tróficos, ou por que cada conexão está certa |
| 3 | **Dificuldade = menos tempo, não mais conteúdo** | 🟡 | Progressão é apenas timer mais curto, sem novos conceitos |
| 4 | **Não organiza por nível trófico visualmente** | 🟡 | Posições aleatórias impedem aprendizagem espacial da hierarquia ecológica |
| 5 | **Sem reforço positivo imediato** | 🟡 | Acertar conexão não dá feedback instantâneo claro |

### Código

| # | Problema | Gravidade | Detalhes |
|---|---|---|---|
| 1 | **Código morto** | 🔴 | `HintButton`, `OrganismWidget`, `ScoreDisplay` — criados, nunca usados |
| 2 | **`print()` de debug em produção** | 🟡 | `phase_repository.dart` linhas 10 e 13 |
| 3 | **ParticlePainter duplicado em 4 telas** | 🟡 | Home, Phases, Ranking, About — cópia idêntica |
| 4 | **Teste unitário quebrado** | 🟡 | Busca "Food Web Builder", título real é "EcoConnect: Teia Alimentar" |
| 5 | **Model positionX/Y ignorados** | 🟡 | DB guarda posições, jogo usa aleatório — inconsistência arquitetural |
| 6 | **GameService inchado** | 🟡 | 208 linhas — timer, DB, score, nome — muitas responsabilidades |
| 7 | **GameScreen inchada** | 🟡 | 674 linhas — layout, HUD, modal, confirmação — deveria ser extraída |
| 8 | **AudioService: `catch (_) {}` silencia tudo** | 🟡 | Erros de áudio invisíveis |
| 9 | **Zero testes unitários** | 🔴 | Nenhum teste para services, repositories, ou game logic |
| 10 | **Asset paths hardcoded por ID** | 🟡 | `asset_paths.dart` mapeia IDs para nomes de arquivo — frágil |

### Organização

| # | Problema | Gravidade | Detalhes |
|---|---|---|---|
| 1 | **Widgets não utilizados poluem o projeto** | 🟡 | 3 widgets que ninguém importa |
| 2 | **Partículas duplicadas** | 🟡 | `_ParticlePainter` + `_ParticleOverlay` em 4 telas |
| 3 | **Campo `emoji` do modelo confuso** | 🟢 | Emoji no DB mas jogo usa sprites — só serviria para OrganismWidget (não usado) |

---

## Sugestões Priorizadas

### 🚨 Obrigatórias para MVP

| # | Sugestão | Problemas que resolve |
|---|---|---|
| MVP-1 | **Feedback imediato por conexão**: validar ao soltar, mostrar verde/vermelho + toast explicativo | UX#1, Ped#1, Ped#5 |
| MVP-2 | **Posicionamento fixo por nível trófico**: usar `positionX/Y` do DB com produtores embaixo, predadores no topo | UX#3, Ped#1, Ped#4 |
| MVP-3 | **Tutorial onboarding**: 3 slides rápidos na primeira vez | UX#2, Ped#2 |
| MVP-4 | **Mostrar nível trófico**: badge ou cor de borda por nível (produtor, primário, etc.) | Ped#1, Ped#2 |
| MVP-5 | **Remover código morto**: deletar ou conectar HintButton, OrganismWidget, ScoreDisplay | Cód#1 |
| MVP-6 | **Extrair ParticlePainter para `core/`** | Cód#3, Org#2 |
| MVP-7 | **Remover `print()` de debug** | Cód#2 |

### ✨ Boas Melhorias

| # | Sugestão | Problemas que resolve |
|---|---|---|
| BOM-1 | **Tutorial interativo na primeira fase**: setas guiando o primeiro drag | UX#2, UX#5 |
| BOM-2 | **Explicação educativa no modal de conclusão** sobre a teia montada | Ped#2, Ped#5 |
| BOM-3 | **Estrelas visíveis no card da fase** (melhor pontuação) | UX#8, Ped#5 |
| BOM-4 | **Conectar HintButton à GameScreen** (já existe, só integrar) | UX#9 |
| BOM-5 | **Aumentar label dos organismos para 14px com sombra** | UX#4 |
| BOM-6 | **Indicador visual de direção ao arrastar**: seta/gradiente na linha | UX#5 |
| BOM-7 | **Game over real**: implementar a lógica de perda mencionada no README | UX#10 |

### 🔮 Ideias Futuras

| # | Ideia |
|---|---|
| FUT-1 | Modo "Explorar" sem penalidade para testar conexões |
| FUT-2 | Animações educativas ao completar uma conexão |
| FUT-3 | Mais biomas (Caatinga, Pampa, Amazônia) |
| FUT-4 | Modo "Desafio" com tempo reduzido para revisão |
| FUT-5 | Tradução EN/ES |
| FUT-6 | Compartilhar print da teia em redes sociais |
| FUT-7 | Gráfico interativo da teia completa após a fase |
| FUT-8 | Efeitos sonoros de acerto/erro (FlameAudio já incluso) |

---

## Plano de Commits Pequenos

### Fase 1 — Limpeza e Correções (MVP)

| # | Branch | Mensagem | Arquivos |
|---|---|---|---|
| 1 | `fix/cleanup-dead-code` | `refactor: remove unused widgets and debug prints` | `lib/widgets/organism_widget.dart` (remover), `lib/widgets/score_display.dart` (remover), `lib/repositories/phase_repository.dart` (remover prints), `lib/widgets/hint_button.dart` (manter) |
| 2 | `refactor/extract-particle-painter` | `refactor: extract duplicated ParticlePainter to shared core widget` | `lib/core/particle_overlay.dart` (novo), `lib/screens/home_screen.dart`, `lib/screens/phases_screen.dart`, `lib/screens/ranking_screen.dart`, `lib/screens/about_screen.dart` (remover duplicatas) |
| 3 | `fix/use-fixed-positions` | `fix: use DB positionX/positionY instead of random placement` | `lib/game/food_web_game.dart` (substituir `_generateRandomPositions()`), `lib/models/organism.dart` (opcional) |
| 4 | `feat/immediate-connection-feedback` | `feat: validate connections in real-time on drop` | `lib/game/food_web_game.dart` (validar no onDragEnd), `lib/services/game_service.dart` (método validateConnection), `lib/screens/game_screen.dart` (snackbar), `lib/game/components/connection_line.dart` (cor imediata) |
| 5 | `feat/onboarding-tutorial` | `feat: add quick onboarding tutorial for first-time players` | `lib/screens/game_screen.dart` (overlay 3 slides), `lib/services/game_service.dart` (flag hasSeenTutorial) |
| 6 | `feat/show-trophic-level` | `feat: display trophic level badges on organism components` | `lib/game/components/organism_component.dart` (badge/cor), `lib/core/app_colors.dart` (cores por nível) |
| 7 | `fix/unit-test` | `test: fix widget test to match actual app title` | `test/widget_test.dart` |

### Fase 2 — Melhorias (BOM)

| # | Branch | Mensagem | Arquivos |
|---|---|---|---|
| 8 | `feat/connect-hints` | `feat: integrate hint button into game screen` | `lib/screens/game_screen.dart` (adicionar HintButton), `lib/services/game_service.dart` (lógica de dica), `lib/game/food_web_game.dart` (highlight) |
| 9 | `feat/improve-organism-labels` | `feat: increase organism label size and add drag direction indicator` | `lib/game/components/organism_component.dart` (14px + sombra), `lib/game/components/drag_indicator.dart` (seta/gradiente) |
| 10 | `feat/educational-result` | `feat: enhance completion modal with educational content` | `lib/screens/game_screen.dart` (texto explicativo), `lib/services/game_service.dart` (estatísticas) |
| 11 | `feat/phase-card-stars` | `feat: show best score stars on phase cards` | `lib/widgets/phase_card.dart` (estrelas), `lib/services/game_service.dart` (getBestByPhaseId) |
| 12 | `feat/game-over` | `feat: implement game-over when score reaches zero` | `lib/services/game_service.dart` (handleGameOver), `lib/game/food_web_game.dart` (checar), `lib/screens/game_screen.dart` (tela game over) |

---

## Convenções de Commit

O plano segue **Conventional Commits** (Angular):

| Tipo | Uso |
|---|---|
| `feat:` | Nova funcionalidade |
| `fix:` | Correção de bug |
| `refactor:` | Refatoração sem mudança de comportamento |
| `test:` | Adição/correção de testes |
| `docs:` | Documentação |

Todas as branches partem de `development` com prefixo `tipo/descricao-curta`.

---

## Riscos e Cuidados

| Risco | Gravidade | Mitigação |
|---|---|---|
| Mudar de randômico para fixo pode quebrar layouts em telas pequenas | 🔴 | Usar `positionX/Y` como proporção (%) e ajustar ao `size` do game |
| Feedback imediato vs fluxo "Submeter" — submit passa a ser "finalizar" | 🔴 | Submeter vira "Ver resumo da teia", não validação. Conexões já validadas em tempo real |
| Tutorial pode ser chato para quem já conhece | 🟡 | Mostrar apenas na primeira vez (flag `hasSeenTutorial`) |
| Sistema de dicas pode desbalancear | 🟡 | Manter custo de -5 pts e limite 3 (já previsto no `HintButton`) |
| Posições fixas do DB não consideram aspect ratio | 🟡 | Converter 0.0-1.0 para coordenadas reais baseadas no `size` do game |
| Áudio pode falhar em web sem visibilidade | 🟢 | Melhorar logging no `AudioService` |
| Modal recalcula estrelas do zero em vez de usar `ScoringService` | 🟡 | Refatorar `_showCompletionModal` para usar `ScoringService.calculateStars()` |

---

## Checklist de Verificação Pós-Implementação

- [ ] Cada conexão acertada mostra verde + toast explicativo
- [ ] Cada conexão errada mostra vermelho + mensagem de erro
- [ ] Organismos aparecem sempre nas mesmas posições (por nível trófico)
- [ ] Primeira vez que joga: tutorial de 3 slides aparece
- [ ] Nível trófico visível em cada organismo
- [ ] Nenhum `print()` de debug em produção
- [ ] `HintButton` funcional na GameScreen
- [ ] Partículas num arquivo compartilhado apenas
- [ ] Widgets mortos removidos
- [ ] Teste unitário corrigido e passando
- [ ] Game over funcional (0 pontos → tela de tentar novamente)
- [ ] Modal de conclusão mostra explicação educativa

---

*Documento gerado por Prometheus. Nenhum código foi alterado.*
