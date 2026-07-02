# Relatório — Refinamento da Interface Visual dos Níveis Tróficos

## Data
2026-07-01

## Problemas Corrigidos

1. **Linhas horizontais cortavam os animais** — estavam renderizadas *sobre* os organismos (pós `super.render`)
2. **Textos da legenda saíam parcialmente da tela** — posicionamento `sideMargin - 16 - painter.width` podia resultar em X negativo
3. **Tudo na mesma cor (branco)** — labels e linhas usando branco, sem distinção de zona
4. **Bolinhas como ruído visual** — círculo de 3.5px pouco claro como indicador trófico

---

## Arquivos Alterados

| Arquivo | Mudança |
|---|---|
| `lib/game/food_web_game.dart` | Criado `_TrophicLegendComponent` (renderizado entre background e organismos); removido `_renderTrophicLegend` do `render()` |
| `lib/game/components/organism_component.dart` | Substituído `drawCircle` por `drawRRect` (barra horizontal arredondada 22×3px) |

Banco de dados, sprites, animações, pontuação, mecânica — **inalterados**.

---

## Mudança 1 — Linhas atrás dos animais

### Como foi resolvido

Antes: `_renderTrophicLegend()` era chamado no `render()` do `FoodWebGame` **após** `super.render()`, desenhando linhas e textos **por cima** de todos os organismos.

Depois: Criado o componente `_TrophicLegendComponent` que é adicionado no `loadPhase()` **entre** o background e os organismos:

```
loadPhase():
  1. add(_background!)           ← fundo da cena
  2. add(_TrophicLegendComponent) ← linhas + labels (ATRÁS dos animais)
  3. for organism: add(component) ← organismos (SOBRE as linhas)
  4. ... conexões, drag, etc.
```

### Ordem de renderização resultante

1. Background (imagem do cenário + overlay escuro)
2. **LegendComponent** (linhas horizontais + textos — atrás dos sprites)
3. OrganismComponents (sprites + nomes + barras indicadoras)
4. ConnectionLines
5. DragIndicator

As linhas não cortam mais nenhum animal porque ficam atrás dos sprites.

---

## Mudança 2 — Legenda sempre visível

### Como foi resolvido

Os labels agora são posicionados a **8px da borda esquerda** (`labelLeft = 8.0`), sempre dentro da tela:

```dart
const labelLeft = 8.0;
painter.paint(canvas, Offset(labelLeft, dbYToPixel(dbY) - painter.height / 2));
```

- Fonte reduzida para **9px** com **letter-spacing 1.5** para caber confortavelmente na margem
- Sombra no texto (`blurRadius: 4`, alpha 0.6) garante legibilidade sobre qualquer fundo de cenário
- Labels usam a margem esquerda (0–60px), onde não há organismos

---

## Mudança 3 — Cores por zona trófica

### Cores da legenda

| Zona | Cor | Alpha | Equivalente |
|---|---|---|---|
| PREDADORES | `#EF5350` (vermelho) | 55% | `AppColors.connectionError` |
| CONSUMIDORES | `#FFC107` (âmbar) | 55% | — |
| PRODUTORES | `#4CAF50` (verde) | 55% | `AppColors.correct` |

### Linhas horizontais

Permanecem brancas com alpha **10%** (mais sutis que antes) — servem apenas como referência de zona, sem poluir.

### Como ajustar as cores

No arquivo `lib/game/food_web_game.dart`, classe `_TrophicLegendComponent`, método `render()`, linhas das constantes de cor (~linha 302):

```dart
const predColor = Color(0xFFEF5350);  // ← cor da zona PREDADORES
const consColor = Color(0xFFFFC107);  // ← cor da zona CONSUMIDORES
const prodColor = Color(0xFF4CAF50);  // ← cor da zona PRODUTORES
```

E no método `color.withValues(alpha: 0.55)` — altere o `0.55` para mais/menos intensidade.

---

## Mudança 4 — Indicador: bolinha → barra arredondada

### Como foi resolvido

Substituído `drawCircle` por `drawRRect` com:

| Parâmetro | Valor |
|---|---|
| Largura | 22px |
| Altura | 3px |
| Raio do canto | 1.5px |
| Opacidade | 80% |

### Como ajustar

Em `lib/game/components/organism_component.dart`, no método `render()`:

```dart
const barWidth = 22.0;    // ← largura da barra
const barHeight = 3.0;    // ← altura da barra
// ...
Radius.circular(1.5),     // ← arredondamento dos cantos
// ...
color: indicatorColor.withValues(alpha: 0.80)  // ← opacidade
```

---

## Como Testar

1. Abra **Campo** — verifique:
   - Legendas `PREDADORES` (vermelho), `CONSUMIDORES` (âmbar), `PRODUTORES` (verde) na lateral esquerda
   - Nenhum texto cortado na borda esquerda
   - Linhas horizontais finas atrás dos animais (não cortam sprites)
   - Barrinha colorida (22×3px) abaixo do nome de cada organismo

2. Abra **Floresta** (mais organismos) — verifique:
   - Mesma consistência visual
   - Linhas não atravessam sprites

3. Redimensione a janela (web/desktop) — verifique:
   - Legendas continuam visíveis e dentro da tela
   - Linhas e labels se reposicionam proporcionalmente

4. Mobile landscape — verifique:
   - Nada sai da tela
   - Layout se adapta

5. Arraste conexões — mecânica inalterada

---

## Mensagem de Commit

```
refactor: move trophic legend behind organisms, fix label clipping, add zone colors, replace dots with bars
```
