# Ajustes no Feedback Visual das Conexões

## 1. Partículas mais rápidas

**Arquivo:** `lib/game/effects/connection_effect.dart`

| Parâmetro | Antes | Depois |
|---|---|---|
| Velocidade (min–max) | 40–170 | 60–260 |
| Atraso entre partículas | 0.012 s | 0.008 s |
| Duração total | 1.2 s | 1.0 s |

- As partículas disparam mais rápido (menos delay entre elas) e viajam mais longe no mesmo tempo.
- A duração total caiu de 1.2 → 1.0 s, mantendo o impacto visual sem se arrastar.
- A diferença entre acerto (explosão com expansão) e erro (dissipação e encolhimento) foi preservada.

## 2. Mensagens centralizadas

**Arquivo:** `lib/screens/game_screen.dart`

- **Posição**: Moveu de `top: 6%` para `top: 25%` — aparece no terço superior da tela, sem obstruir o jogo.
- **Card**: 
  - `maxWidth: 340` para não ocupar a tela inteira
  - Padding aumentado (24×18) e bordas mais arredondadas (18 → 20)
  - Opacidade do fundo: 94%
  - Sombra glow mais forte (blur 20, alpha 0.3)
- **Título + Corpo**: O texto é dividido no `\n\n` — título em `FontWeight.w800` tamanho 18, corpo em `w500` tamanho 14.
  - Exemplo: **✅ Muito bem!** *(título)* + *A águia se alimenta do coelho.* *(corpo)*
- **Entrada/saída**: `AnimatedSwitcher` com `FadeTransition` de 300 ms (mantido)

## 3. Mensagens atualizadas

**Arquivo:** `lib/game/food_web_game.dart`

Todas as mensagens agora seguem o formato `EMOJI Título\n\nCorpo explicativo.`:

**Acerto (3 variantes):**
- ✅ Muito bem! → *$predator se alimenta de $prey!*
- 🎉 Correto! → *$predator → $prey*
- 🌟 Parabéns! → *$predator come $prey!*

**Direção errada (3 variantes):**
- 🌿 Quase! → *Arraste do predador para a presa.*
- 🔄 Atenção! → *Quem come vai para quem é comido.*
- 🤔 Ops! → *Pense na direção da cadeia alimentar.*

**Combinação errada (3 variantes):**
- ❌ Quase! → *$predator não come $prey. Tente outro!*
- 🤔 Não é esse! → *Quem será que $predator realmente come?*
- 🔍 Observe! → *$predator precisa de outra presa.*

## 4. Linha errada temporária

**Arquivo:** `lib/game/food_web_game.dart`

O temporizador de remoção da linha errada foi ajustado de 1.8 s → **1.6 s**, para que a linha desapareça (fade de ~0.25 s) *antes* da mensagem sumir (2 s):

```
t=0          t=1.6s         t=~1.85s        t=2.0s
|────Acerto────|────Linha────|───Fade line───|───Msg some───|
  (linha fica)   começa fade    linha some     mensagem fade
```

## 5. Como testar

1. Abrir qualquer fase do jogo
2. Fazer uma conexão **correta**:
   - ✅ Ver explosão verde+ouro+branco (partículas mais rápidas)
   - ✅ Card centralizado com título + descrição
   - ✅ Linha verde permanece
3. Fazer uma conexão **incorreta** (direção ou combinação):
   - ❌ Ver explosão vermelha+laranja+cinza
   - ✅ Card centralizado com título + descrição
   - ✅ Linha vermelha some após ~1.6 s
   - ✅ Jogador pode tentar novamente após linha sumir

## 6. Parâmetros ajustáveis

| Arquivo | Parâmetro | Local | Valor atual | Efeito |
|---|---|---|---|---|
| `connection_effect.dart` | `speed` base | `onLoad()` | `60 + rng.nextDouble() * 200` | Velocidade das partículas |
| `connection_effect.dart` | `_duration` | topo da classe | `1.0` | Tempo de vida das partículas (s) |
| `connection_effect.dart` | `delay` | loop `onLoad()` | `i * 0.008` | Espaçamento entre partículas |
| `connection_effect.dart` | `count` | `onLoad()` | `24` (acerto) / `16` (erro) | Quantidade de partículas |
| `food_web_game.dart` | remoção linha errada | `_scheduleWrongLineRemoval` | `1600` ms | Delay até linha começar a sumir |
| `game_screen.dart` | posição Y do card | `top:` na `Positioned` | `height * 0.25` | Quão abaixo do topo o card aparece |
| `game_screen.dart` | duração mensagem | `_onConnectionResult` | `2` s | Tempo que o card fica visível |
| `game_screen.dart` | `maxWidth` do card | `_buildConnectionMessage` | `340` px | Largura máxima do card flutuante |
| `game_screen.dart` | transição fade | `AnimatedSwitcher` | `300` ms | Duração da animação entrada/saída |

## 7. Análise

```
$ dart analyze lib/
9 issues found (0 novos)
```

Nenhum erro novo introduzido. Todos os 9 issues são pré-existentes.

## 8. Sugestões

**Branch:** `feat/adjust-visual-feedback`

**Commit message:**
```
feat: adjust visual feedback - faster particles, centered messages, title+body format

- Increase particle speed range (60-260) and reduce delay spread (0.008)
- Shorten particle duration from 1.2s to 1.0s for snappier effect
- Move message overlay from top (6%) to upper-center (25%) position
- Split messages into bold title + regular body with emoji prefix
- Reduce wrong-line removal delay from 1.8s to 1.6s for better timing
- Update card styling: maxWidth 340, larger padding, stronger glow
```

**Commit type:** `feat` (ajuste em funcionalidade existente)
