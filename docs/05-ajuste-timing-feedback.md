# Ajuste de Timing do Feedback Visual

## Objetivo

Separar temporalmente a exibição da mensagem do efeito de partículas para que não haja competição visual.

## Sequência de Eventos

```
t=0s          Card + linha aparecem
                │ acerto: linha verde permanente
                │ erro:   linha vermelha + shake
                ▼
t=2,8s        Partículas disparam (acerto: comemoração / erro: dissipação)
              Linha errada começa a desvanecer (fade-out 0,25s)
                │
t=3,0s        Card começa a desvanecer (AnimatedSwitcher 0,3s)
                │
t=3,05s       Linha errada completamente removida
              Conexão removida do _playerConnections → retentativa permitida
                │
t=3,3s        Card completamente oculto
                │
t=3,8s        Partículas terminam (duração 1,0s)
```

## Arquivos Alterados

### `lib/game/food_web_game.dart`

| O quê | Antes | Depois |
|---|---|---|
| Partículas em acerto | Disparo imediato em `onDragEnd()` | `_scheduleParticles(midPoint, true)` — atraso 2,8 s |
| Partículas em erro | Disparo imediato em `onDragEnd()` | `_scheduleParticles(midPoint, false)` — atraso 2,8 s |
| Remoção da linha errada | 1,6 s | 2,8 s |
| Método novo | — | `_scheduleParticles(center, isCorrect)` |

O método `_scheduleParticles` usa `Future.delayed(2800)` e protege com `if (!isLoaded) return;` antes de adicionar o `ConnectionEffect`.

### `lib/screens/game_screen.dart`

| Parâmetro | Antes | Depois |
|---|---|---|
| Opacidade do fundo do card | 0,94 | 0,85 |
| Largura máxima do card | 340 px | 280 px |
| Padding vertical | 18 px | 14 px |
| Padding horizontal | 24 px | 20 px |
| Título: tamanho | 18 | 16 |
| Título: peso | w800 | w700 |
| Corpo: tamanho | 14 | 13 |
| Corpo: line-height | 1,4 | 1,3 |
| Espaço título-corpo | 6 px | 4 px |
| Sombra: blur | 20 | 16 |
| Sombra: offset Y | 4 | 3 |

O card ficou ~25% menor e mais transparente — não esconde os animais do jogo.

## Onde Ajustar

### Duração do card (quanto tempo a mensagem fica visível)

**Arquivo:** `lib/screens/game_screen.dart`
**Linha:** método `_onConnectionResult`, `Future.delayed(const Duration(seconds: 3), ...)`
**Aumentar** → mensagem fica mais tempo; **diminuir** → some mais rápido.
*Nota: o delay das partículas (2,8 s) deve ser ligeiramente menor que a duração do card para que comecem antes do fade-out.*

### Delay das partículas

**Arquivo:** `lib/game/food_web_game.dart`
**Linha:** método `_scheduleParticles`, `Future.delayed(const Duration(milliseconds: 2800), ...)`
**Aumentar** → partículas disparam mais tarde; **diminuir** → mais cedo.
*Regra: deve ser menor que a duração do card (3 s) para que as partículas estourem durante o fade-out.*

### Delay da remoção da linha errada

**Arquivo:** `lib/game/food_web_game.dart`
**Linha:** método `_scheduleWrongLineRemoval`, `Future.delayed(const Duration(milliseconds: 2800), ...)`
**Sincronizar** com o delay das partículas para que linha e partículas comecem a desaparecer juntas.

### Tamanho do card

**Arquivo:** `lib/screens/game_screen.dart`
**Método:** `_buildConnectionMessage`
- `maxWidth:` — largura máxima do card
- `padding:` — espaço interno
- `fontSize:` no título e corpo — tamanho do texto

### Quantidade de partículas

**Arquivo:** `lib/game/effects/connection_effect.dart`
**Linha:** `onLoad()`, `count = isCorrect ? 24 : 16`

### Velocidade das partículas

**Arquivo:** `lib/game/effects/connection_effect.dart`
**Linha:** `onLoad()`, `speed = 60 + rng.nextDouble() * 200`

## Como Testar

### Conexão correta
1. Arraste um predador até a presa certa
2. ✅ Card aparece imediatamente: título bold + corpo (ex: "✅ Muito bem! / A águia se alimenta do coelho.")
3. ✅ Após ~2,8 s: partículas verdes+ouro+brancas explodem no meio da linha
4. ✅ Por volta de 3 s: card começa a sumir com fade
5. ✅ Partículas continuam visíveis depois do card sumir
6. ✅ Linha permanece verde na tela

### Conexão errada (combinação ou direção)
1. Arraste um predador para a presa errada
2. ✅ Card aparece imediatamente (ex: "❌ Quase! / O gafanhoto não come a águia.")
3. ✅ Linha vermelha visível junto com o card
4. ✅ Após ~2,8 s: partículas vermelhas+laranjas+cinzas disparam + linha começa a desvanecer
5. ✅ Por volta de 3 s: card começa a sumir com fade
6. ✅ Linha já sumiu, jogador pode tentar novamente

## Análise

```
$ dart analyze lib/
9 issues found (0 novos)
```

Nenhum erro novo. Os 9 issues são pré-existentes no código não modificado.
