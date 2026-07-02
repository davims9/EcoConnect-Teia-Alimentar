# Melhorias no Feedback Visual das Conexões

## Resumo

Substituição do SnackBar por overlay animado + partículas multicoloridas + mensagens infantis + remoção automática de linhas erradas + fade suave.

## Arquivos Modificados

### `lib/game/effects/connection_effect.dart` — Rees crito completamente
- **Antes**: componente básico com 12 partículas verdes/vermelhas de tamanho fixo
- **Depois**: 24 partículas para acerto (verde+ouro+branco) ou 16 para erro (vermelho+laranja+cinza)
- Partículas corretas fazem explosão (expansão + fade gradual)
- Partículas erradas dissipam (encolhem + somem rápido)
- Atraso escalonado (`i * 0.012`) evita explosão todas-no-mesmo-frame

### `lib/services/game_service.dart` — Novo método
- `removeConnection(sourceId, targetId)`: remove uma conexão do `_playerConnections` para permitir retentativa sem travar o estado de jogo

### `lib/game/components/connection_line.dart` — Novo método
- `fadeOut()`: marca a linha para fade → transparente em ~0.25s, depois `removeFromParent()` automaticamente
- `_isFading` previne que `animateColor`/`flashThenColor` interrompam o fade se chamados acidentalmente

### `lib/game/food_web_game.dart` — Mensagens + remoção agendada
- **Mensagens**: 3 variantes por cenário (acerto/direção errada/combo errado), escolhidas aleatoriamente, com emojis e tom educacional
  - Acerto: 🎉 ✅ 🌟
  - Direção: 🌿 🔄 🤔
  - Combinação: ❌ 🤔 🔍
- **Remoção**: `_scheduleWrongLineRemoval()` → após 1.8s chama `line.fadeOut()` + `connectionLines.remove()` + `gameService.removeConnection()`
- `isLoaded` check previne chamadas após dispose

### `lib/screens/game_screen.dart` — Overlay animado
- **Antes**: SnackBar flutuante (ScaffoldMessenger)
- **Depois**: `AnimatedSwitcher` com `FadeTransition` (300ms) no `Stack` do jogo
- Posicionado a 6% do topo, centralizado horizontalmente, com 24px de margem lateral
- Card com fundo semi-transparente (92% opacidade), borda colorida, sombra glow
- Auto-dismiss após 2s via `Future.delayed`
- Estado gerenciado via `_connectionMessage`, `_connectionIsCorrect`, `_connectionKey` (força rebuild do AnimatedSwitcher)

## Análise

```
$ dart analyze lib/
9 issues found (0 new)
```

Todos os 9 issues são pré-existentes (warnings de código não modificado: `must_call_super`, `unused_local_variable`, `unused_import`, `deprecated_member_use`).

## Constantes Ajustáveis

Em `connection_effect.dart`:
| Constante | Valor | Efeito |
|---|---|---|
| `_duration` | 1.2 s | tempo de vida das partículas |
| count (correct) | 24 | número de partículas no acerto |
| count (wrong) | 16 | número de partículas no erro |
| speed range | 40–130 | velocidade de dispersão |
| radius range | 1.5–4.0 | tamanho das partículas |

Em `food_web_game.dart`:
| Constante | Valor | Efeito |
|---|---|---|
| `Duration(milliseconds: 1800)` | 1.8 s | tempo que linha errada fica visível |

Em `game_screen.dart`:
| Constante | Valor | Efeito |
|---|---|---|
| `Duration(seconds: 2)` | 2 s | tempo que overlay de mensagem fica visível |
| `Duration(milliseconds: 300)` | 300 ms | duração da transição fade |

## Mudanças na Experiência do Jogador

1. Conexão correta → explosão verde+ouro+branco + card verde com fade
2. Conexão errada → partículas vermelhas+alaranjadas + card vermelho + linha some após 1.8s
3. Mensagens com emojis e tom positivo/educativo, sem "Ops!" acusatório
4. Linhas erradas desaparecem suavemente (fade out) em vez de ficarem para sempre
5. Jogador pode retentar imediatamente após o fade (1.8s)

## Próximos Passos Sugeridos

- Adicionar som de acerto/erro no `AudioService`
- Animar o card de mensagem com slide (entrada por cima)
- Adicionar contagem visual de tentativas restantes
