# Relatório — Margem Segura para Posicionamento de Organismos

## Data
2026-07-01

## Problema
Após a reorganização dos organismos por nível trófico (relatório #06), os `positionY` dos predadores de topo (0.06) posicionavam o centro do componente a ~6% do topo da tela — atrás da AppBar (64px) ou com metade do sprite cortado.

**Causa raiz:** A conversão `organism.positionY * size.y` mapeava o valor proporcional do banco diretamente para pixels absolutos, ignorando:
- A AppBar de 64px sobreposta ao jogo
- O HUD inferior (~60px)
- O semi-tamanho do sprite (55px) + label de nome (~20px)

---

## Solução Aplicada

**Tipo:** Clamp via remapeamento proporcional para área segura (**sem alteração nos valores do banco**).

### Arquivo alterado

**`lib/game/food_web_game.dart`** — método `loadPhase()`, laço de criação dos componentes.

### O que mudou

**Antes (causava corte):**
```dart
component.position = Vector2(
  organism.positionX * size.x,
  organism.positionY * size.y,
);
```

**Depois (com margem segura):**
```dart
const topMargin = 120.0;
const bottomMargin = 100.0;
const sideMargin = 60.0;

final safeWidth = (size.x - 2 * sideMargin).clamp(200.0, double.infinity);
final safeHeight = (size.y - topMargin - bottomMargin).clamp(200.0, double.infinity);

component.position = Vector2(
  sideMargin + organism.positionX * safeWidth,
  topMargin + organism.positionY * safeHeight,
);
```

### Como funciona

As coordenadas proporcionais do banco (0.0–1.0) continuam sendo a única fonte de posicionamento. O que muda é como elas são convertidas para pixels:

1. Define-se uma **área segura** (safe area) recuada das bordas da tela:
   - **120px no topo:** comporta AppBar (64px) + semi-sprite (55px) + folga (~1px)
   - **100px embaixo:** comporta semi-sprite (55px) + label nome (~20px) + HUD (~60px) com sobreposição mínima
   - **60px nas laterais:** comporta semi-sprite (55px) + folga (~5px)

2. Mapeia-se o intervalo [0, 1] do banco **dentro dessa área segura**:
   - `positionY = 0.0` → topo da área segura (120px do topo da tela)
   - `positionY = 1.0` → base da área segura (100px acima da base da tela)
   - `positionX = 0.0` → borda esquerda da área segura (60px da borda)
   - `positionX = 1.0` → borda direita da área segura (60px da borda)

3. **Clamp de segurança:** `safeWidth` e `safeHeight` têm mínimo de 200px para evitar áreas negativas em telas muito pequenas.

### Valores do banco de dados

**Não foram alterados.** Os valores definidos no relatório #06 continuam válidos:

| Nível | Y (DB) | Posição na área segura (tela 800×600) |
|---|---|---|
| predador_topo | 0.06 | 120 + 0.06×380 = **142.8px** do topo |
| consumidor_terciario | 0.28 | 120 + 0.28×380 = **226.4px** |
| consumidor_secundario | 0.48 | 120 + 0.48×380 = **302.4px** |
| consumidor_primario | 0.66 | 120 + 0.66×380 = **370.8px** |
| produtor | 0.85 | 120 + 0.85×380 = **443.0px** |

---

## Verificação de Não-Corte (diversas resoluções)

### 800×600 (desktop típico)
| Organismo | Y real (px) | Topo sprite (px) | Abaixo AppBar? | Base nome (px) | Acima HUD? |
|---|---|---|---|---|---|
| Águia (Y=0.06) | 142.8 | 87.8 | ✅ (23.8px) | — | — |
| Capim (Y=0.85) | 443.0 | — | — | 518.0 | ✅ (82px da borda) |

### 360×640 (mobile pequeno)
| Organismo | Y real (px) | Topo sprite (px) | Abaixo AppBar? | Base nome (px) | Acima HUD? |
|---|---|---|---|---|---|
| Águia (Y=0.06) | 145.2 | 90.2 | ✅ (26.2px) | — | — |
| Capim (Y=0.85) | 477.0 | — | — | 552.0 | ✅ (88px da borda) |

### 1920×1080 (desktop grande)
| Organismo | Y real (px) | Topo sprite (px) | Abaixo AppBar? | Base nome (px) | Acima HUD? |
|---|---|---|---|---|---|
| Águia (Y=0.06) | 171.6 | 116.6 | ✅ (52.6px) | — | — |
| Capim (Y=0.85) | 851.0 | — | — | 926.0 | ✅ (154px da borda) |

---

## Como Ajustar a Margem Superior Futuramente

No arquivo **`lib/game/food_web_game.dart`**, método `loadPhase()`, linhas ~64–66:

```dart
const topMargin = 120.0;    // ← Aumente para mais espaço no topo
const bottomMargin = 100.0;  // ← Aumente para mais espaço embaixo
const sideMargin = 60.0;     // ← Aumente para mais espaço nas laterais
```

- `topMargin` controla o espaço a partir do topo da tela (deve ser ≥ AppBar + semi-sprite ≈ 119px)
- `bottomMargin` controla o espaço a partir da base (deve ser ≥ semi-sprite + nome + HUD ≈ 135px... mas 100px funciona porque o HUD é overlay e aceita sobreposição parcial)
- `sideMargin` controla o espaço nas laterais (deve ser ≥ semi-sprite ≈ 55px)

## Como Testar

1. Abra o **Campo** ou **Floresta** (fases com mais organismos)
2. Verifique se **Águia, Gavião, Onça** (predadores de topo) estão totalmente visíveis, sem corte no topo
3. Verifique se **Capim, Arbusto** (produtores) estão visíveis, sem corte na base
4. Redimensione a janela (web/desktop) para testar diferentes proporções
5. Teste em mobile landscape se possível (proporção mais alongada)
6. Confira se a hierarquia visual ainda está clara: predadores no topo, produtores embaixo

## Mensagem de Commit

```
fix: add safe-area margins to organism positioning to prevent clipping under HUD
```

A correção garante que os valores proporcionais do banco (0.0–1.0) sejam remapeados para uma área segura, evitando cortes independentemente da resolução da tela, sem perder a organização por nível trófico e sem alterar os dados do banco.
