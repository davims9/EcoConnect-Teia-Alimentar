# Relatório: Correção de Overflow no `_ConnectionCard`

## Problema

O card de conexões do HUD (`_ConnectionCard`) apresentava overflow vertical
após alterações anteriores. A correção anterior aumentou a altura do card para
56 px (vs. 48 px dos demais cards), quebrando a uniformidade visual do HUD.

## Causa Raiz

O `_ConnectionCard` usava um `Container` próprio com altura fixa de 56 px
(wide) / 36 px (compact), enquanto todos os outros cards
(`_BiomeCard`, `_ScoreCard`, `_TimerCard`) usavam `_HudCard` com altura de
48 px (wide) / 36 px (compact). A diferença de 8 px no modo wide fazia o card
de conexões destoar visualmente.

Além disso, o `Container` duplicava toda a decoração (cores, bordas, sombras)
idêntica à do `_HudCard`, gerando código redundante e risco de deriva visual.

## Correção Aplicada

Arquivo alterado: **`lib/widgets/game_top_hud.dart`** — apenas o widget
`_ConnectionCard` (linhas 391–508).

### Mudanças específicas

| Item | Antes | Depois |
|------|-------|--------|
| **Container externo** | `Container` próprio (altura: 56/36) | `_HudCard` (altura: 48/36) |
| **Decoração** | Duplicada (cópia do `_HudCard`) | Herdada do `_HudCard` |
| **Padding vertical (wide)** | 8 px | 6 px |
| **Padding vertical (compact)** | 4 px | 4 px (inalterado) |
| **FontSize do número (wide)** | 26 | 22 |
| **FontSize do número (compact)** | 16 | 16 (inalterado) |
| **FontSize do "/total" (wide)** | 15 | 13 |
| **FontSize do "/total" (compact)** | 12 | 12 (inalterado) |
| **FontSize "conexões" (wide)** | 12 | 11 |
| **Espaço texto → barra (wide)** | 4 px | 3 px |
| **Espaço texto → barra (compact)** | 2 px | 2 px (inalterado) |
| **Altura da barra (wide)** | 6 px | 5 px |
| **Altura da barra (compact)** | 5 px | 5 px (inalterado) |
| **`FittedBox`** | Já existia | Mantido (`BoxFit.scaleDown`) |
| **`height` dos `TextStyle`** | 1.0 | 1.0 (inalterado) |

### Verificação de dimensões — modo wide (altura: 48 px)

```
Padding vertical:        6 + 6  = 12 px
FittedBox (font 22):            ≈ 22 px
SizedBox:                         3 px
Barra:                            5 px
─────────────────────────────────────
Total:                           42 px  ✓  (folga de 6 px em 48)
```

### Verificação de dimensões — modo compact (altura: 36 px)

```
Padding vertical:        4 + 4  =  8 px
FittedBox (font 16):            ≈ 16 px
SizedBox:                         2 px
Barra:                            5 px
─────────────────────────────────────
Total:                           31 px  ✓  (folga de 5 px em 36)
```

## O que NÃO foi alterado

- `_BiomeCard` — **não modificado**
- `_ScoreCard` — **não modificado**
- `_TimerCard` — **não modificado**
- `_BackButton` — **não modificado**
- `_HudCard` — **não modificado**
- `_hudText` — **não modificado**
- `GameTopHud._buildRow` — **não modificado** (distribuição horizontal intacta)
- `GameTopHud.build` — **não modificado**
- Tokens de layout (`_cardHeight`, `_compactCardHeight`, `_gap`, etc.) — **não modificados**
- Breakpoint de 600 dp — **não modificado**
- Lógica do jogo — **não modificada**

## Resultado

- ✅ `_ConnectionCard` agora usa a mesma altura (48 px / 36 px) dos demais cards
- ✅ Cards visualmente uniformes entre si
- ✅ Sem overflow vertical (conteúdo ocupa 42 px dos 48 px disponíveis)
- ✅ Texto e barra de progresso visíveis e funcionais
- ✅ `TweenAnimationBuilder` mantido — animação contínua funcionando
- ✅ Código duplicado de decoração removido (reuso do `_HudCard`)
- ✅ Análise estática (`dart analyze`) — sem issues
