# Habitat Layout Report

## Resumo

Implementação de posicionamento visual por habitat/camada para os biomas Campo, Floresta e Pantanal, substituindo a distribuição em grade uniforme por slots explícitos posicionados manualmente.

---

## Arquivos Alterados

### 1. `lib/game/habitat_layout.dart` (novo)

Contém:

- **`VisualLayer`** enum — classifica cada organismo em: `sky`, `canopy`, `ground`, `water`, `elevated`
- **`HabitatLayout.getPositions(biome)`** — retorna mapa de posições normalizadas (0–1) por `organismId` para o bioma
- **`HabitatLayout.getLayer(biome, organismId)`** — retorna a camada visual do organismo em cada bioma

### 2. `lib/game/food_web_game.dart` (modificado)

- Adicionado `import 'habitat_layout.dart'`
- `loadPhase()` agora obtém `biome` do `gameService.currentPhase` e passa para `_generateZonedPositions`
- `_generateZonedPositions()` agora aceita parâmetro `biome`:
  - Se `HabitatLayout.getPositions(biome)` retorna dados → delega para `_applyHabitatLayout()`
  - Caso contrário (Oceano) → delega para `_generateGridPositions()` (lógica original inalterada)
- Novo método `_applyHabitatLayout()` — mapeia coordenadas normalizadas dos slots para a área segura da tela com clamp
- Método original renomeado para `_generateGridPositions()` — código idêntico ao anterior

---

## Como os Organismos Foram Classificados por Camada Visual

### Campo

| Organismo | ID | Camada | Posição (normalizada) |
|-----------|----|--------|----------------------|
| Águia     | 7  | `sky`    | (0.50, 0.10) |
| Capim     | 1  | `ground` | (0.12, 0.88) |
| Gafanhoto | 2  | `ground` | (0.28, 0.78) |
| Sapo      | 4  | `ground` | (0.48, 0.82) |
| Coelho    | 3  | `ground` | (0.65, 0.74) |
| Cobra     | 5  | `ground` | (0.85, 0.80) |
| Raposa    | 6  | `ground` | (0.30, 0.92) |

A Águia (predador de topo) está no centro do céu. Animais terrestres distribuídos horizontalmente com pequenas variações verticais. Presas (Capim, Gafanhoto, Coelho) próximas de seus predadores naturais.

### Floresta

| Organismo    | ID | Camada    | Posição (normalizada) |
|--------------|----|-----------|----------------------|
| Gavião       | 13 | `canopy`  | (0.20, 0.14) |
| Aranha       | 10 | `canopy`  | (0.52, 0.22) |
| Lagarta      | 9  | `canopy`  | (0.80, 0.18) |
| Arbusto      | 8  | `ground`  | (0.12, 0.72) |
| Sapo         | 11 | `ground`  | (0.35, 0.80) |
| Cobra        | 12 | `ground`  | (0.58, 0.74) |
| Veado        | 14 | `ground`  | (0.78, 0.82) |
| Onça-pintada | 15 | `ground`  | (0.50, 0.92) |

Organismos arborícolas (Gavião, Aranha, Lagarta) na copa (região superior). Animais terrestres no solo com ampla distribuição horizontal.

### Pantanal

| Organismo      | ID | Camada     | Posição (normalizada) |
|----------------|----|------------|----------------------|
| Onça-pintada   | 29 | `elevated` | (0.72, 0.30) |
| Cobra sucuri   | 28 | `water`    | (0.35, 0.42) |
| Garça          | 26 | `water`    | (0.15, 0.55) |
| Jacaré         | 27 | `water`    | (0.80, 0.48) |
| Peixe          | 25 | `water`    | (0.55, 0.62) |
| Caramujo       | 24 | `ground`   | (0.30, 0.75) |
| Planta aquática| 23 | `ground`   | (0.65, 0.82) |

Garça (ave) posicionada na água como ave pernalta, não no céu. Onça-pintada em posição elevada (margem do rio), mas sem ocupar o céu.

---

## Onde Ajustar Zonas de Céu/Solo/Copa no Futuro

### Zonas (na tela, em fração da área segura)

Em `_applyHabitatLayout()` em `food_web_game.dart`:

- **Zona segura**: entre `topMargin` (15% da tela, clamp 60–120px) e `bottomMargin` (10%, clamp 50–100px)
- **Mapa de coordenadas**: as posições normalizadas (0–1) mapeiam linearmente para a área segura

### Ajuste de posições individuais

Em `habitat_layout.dart`:

- Cada posição é um `Offset(dx, dy)` normalizado (0–1)
- dx = 0 (borda esquerda segura), 1 (borda direita segura)
- dy = 0 (topo seguro), 1 (base segura)
- Para mover um organismo: altere seu `Offset` no mapa correspondente

### Ajuste de margens

Em `_applyHabitatLayout()`:

- `sideMargin`: 5% da largura (clamp 15–60px)
- `topMargin`: 15% da altura (clamp 60–120px) — espaço para HUD superior
- `bottomMargin`: 10% da altura (clamp 50–100px)

---

## Biomas Alterados

1. **Campo** — ✅ Substituído para layout por habitat
2. **Floresta** — ✅ Substituído para layout por habitat (copa + solo)
3. **Pantanal** — ✅ Substituído para layout por habitat (água + elevado)

## Bioma Não Alterado

4. **Oceano** — ❌ Mantém o sistema de grade por zonas (`_VerticalZone`) original, sem qualquer modificação

---

## Verificação do Oceano

Para garantir que o Oceano não foi alterado:

1. `HabitatLayout.getPositions('oceano')` retorna `null` (não consta em `_layouts`)
2. Portanto `_generateZonedPositions` cai no fallback `_generateGridPositions`
3. `_generateGridPositions` é o código original extraído sem modificações
4. O mapa `_zoneMap` para IDs 16–22 permanece idêntico

---

## Como Testar

### Campo

1. Abrir fase Campo
2. Verificar: Águia visível no céu (terço superior)
3. Verificar: Capim, Gafanhoto, Sapo, Coelho, Cobra, Raposa distribuídos no solo
4. Verificar: sem sobreposição de sprites ou nomes
5. Testar conexões Águia → Cobra → Sapo → Gafanhoto → Capim

### Pantanal

1. Abrir fase Pantanal
2. Verificar: Onça-pintada em posição elevada (margem)
3. Verificar: Garça na água (não no céu)
4. Verificar: Jacaré, Cobra sucuri, Peixe, Caramujo, Planta aquática distribuídos
5. Testar conexões

### Floresta

1. Abrir fase Floresta
2. Verificar: Gavião, Aranha, Lagarta na copa (terço superior)
3. Verificar: Arbusto, Sapo, Cobra, Veado, Onça-pintada no solo
4. Verificar: distribuição lateral ampla sem aglomeração
5. Testar conexões

### Oceano

1. Abrir fase Oceano
2. Confirmar: posicionamento idêntico ao anterior (grade por zonas)
3. Testar conexões normais

---

## Conventional Commit

```
feat(game): add habitat-based organism positioning for campo, floresta, pantanal

Replace the uniform grid distribution with explicit slot positions by visual layer
(sky, canopy, ground, water, elevated). Aves now appear in the sky, arboreal
organisms in the canopy, and terrestrial animals spread across the ground with
natural variation. Oceano remains unchanged.
```
