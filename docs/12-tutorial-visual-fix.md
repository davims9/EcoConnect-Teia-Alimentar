# Relatório de Alterações — Correção Visual da TutorialScreen

## Problemas Identificados

### 1. Fundo preto
**Causa raiz**: `TutorialGame` sobrescrevia `loadPhase()` como no-op, impedindo o `FoodWebGame` de carregar o `BackgroundComponent` com o cenário do bioma. O `GameWidget` do Flame renderiza canvas preto por padrão.

### 2. Sprites cortados
**Causa raiz dupla**:
- `_reposition()` era chamado em `onGameResize()`, mas na primeira chamada a lista `organismComponents` estava vazia (retorno antecipado por `length < 2`). Quando `onLoad()` adicionava os componentes, `_reposition()` **não era chamado novamente**, deixando os sprites na posição padrão (0,0) — no canto superior esquerdo.
- O `ClipRRect` com `borderRadius` provocava _visual clipping_ que, combinado com o fundo preto, dava a impressão de sprites cortados.

### 3. Retângulo preto vazio
Consequência direta do ponto 1 — sem background nem fallback de cor.

## Arquivos Alterados

### `lib/game/tutorial_game.dart`

| Mudança | Detalhe |
|---|---|
| `backgroundColor()` override | Retorna `Color(0xFF0D2B1A)` — verde escuro como fallback imediato |
| `BackgroundComponent` carregado em `onLoad()` | Usa `cenarios/campo.png` — mesmo cenário do Campo usado nas fases, com overlay escuro do próprio componente (35% preto) |
| `_reposition()` chamado ao final de `onLoad()` | Garante posicionamento correto logo após adição dos componentes |
| Import adicionado | `background_component.dart` |

### `lib/screens/tutorial_screen.dart`

| Mudança | Detalhe |
|---|---|
| `ClipRRect` removido | Substituído por `Container` com `Border`, `borderRadius`, `boxShadow` e `clipBehavior: Clip.antiAlias` |
| Container com borda verde | `Border.all(color: Color(0xFF2E7D32).withValues(alpha: 0.35))` — mesma paleta do jogo |
| Sombra sutil | `BoxShadow` preto com 30% opacidade |
| Padding do instruction ajustado | `fromLTRB(32, 12, 32, 16)` — mais espaço inferior antes do game area |

## Como o Fundo Foi Corrigido

1. `backgroundColor()` override → retorna verde escuro `#0D2B1A` (fallback instantâneo)
2. `BackgroundComponent` carregado em `onLoad()` com `cenarios/campo.png`
3. O próprio componente já aplica overlay escuro de 35% (`Color(0xFF191C1B).withValues(alpha: 0.35)`)

Isso garante:
- Enquanto a imagem do Campo carrega → fundo verde escuro
- Após carregar → cenário do Campo com overlay escuro
- Consistência visual com a tela de jogo real

## Como os Sprites Foram Corrigidos do Corte

- `_reposition()` agora é chamado **dentro** de `onLoad()`, após `add()` dos `OrganismComponent`
- Posições: 28% e 72% da largura, 48% da altura — centralizados verticalmente
- O `Container` com `clipBehavior: Clip.antiAlias` substitui o `ClipRRect` que causava clipping visual

## Sugestão de Commit

```
fix(tutorial): repair black background and clipped sprites in TutorialScreen

- Load Campo biome background via BackgroundComponent for visual consistency
- Add backgroundColor() fallback override for instant dark green canvas
- Call _reposition() inside onLoad() to fix initial sprite positioning
- Replace ClipRRect with styled Container (border, shadow, anti-alias clip)
- Adjust instruction padding for better vertical rhythm
```
