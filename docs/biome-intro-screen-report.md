# Biome Intro Screen - Implementation Report

## Overview

Added a biome introduction screen that appears after selecting a phase and before the game starts. The screen contextualizes the biome with a scenic background, educational description, organism sprites, and an "EXPLORAR" button to begin the phase.

---

## Files Created

### `lib/screens/biome_intro_screen.dart` (new)

The main intro screen containing:

- **BiomeIntroScreen** (StatefulWidget) — accepts a `Phase` and displays:
  - Full-screen biome background image (same `cenarios/{bioma}.png` used in-game) with a dark overlay (`#191C1B` at 45% opacity) for readability.
  - Back button (same style as `PhasesScreen` and `GameScreen`).
  - Biome name as uppercase title with green glow + dark drop shadow.
  - 2-3 sentence educational description in child-friendly Portuguese, specific to each biome.
  - "ORGANISMOS ENCONTRADOS" section label.
  - Centered `Wrap` grid of organism sprite cards — each card shows the actual PNG sprite (`Image.asset` via `OrganismAssetPath.getPath`) inside a dark rounded container with the organism name below (no emojis).
  - "EXPLORAR" button.

- **_BiomeInfo** — private data class holding biome name and description.

- **_GradientButton** — reusable stateful widget with smooth press animation:
  - `AnimatedScale` (0.94 on press) + `AnimatedContainer` (darker gradient on press).
  - Green gradient (`#2E7D32` → `#1B5E20`), pill shape, green border, green box shadow.
  - Follows the game's existing button identity (`GameScreen` submit/return buttons).

Biome descriptions (translated to proper Portuguese with accents):

| Biome | Description |
|-------|-------------|
| Campo | O campo é um ambiente aberto e ensolarado, com muita vegetação rasteira. Aqui, diferentes animais e plantas dependem uns dos outros para se alimentar. |
| Floresta | A floresta é cheia de árvores altas e sombra, abrigando uma grande variedade de seres vivos. Cada organismo tem seu papel na teia alimentar. |
| Oceano | O oceano é um mundo azul e profundo, cheio de vida. Das algas aos grandes tubarões, todos estão conectados na cadeia alimentar. |
| Pantanal | O pantanal é uma grande planície alagada, com uma das maiores biodiversidades do planeta. Plantas, peixes e jacarés convivem em equilíbrio. |

---

## Files Modified

### `lib/services/game_service.dart`

Added a public method `getOrganismsForPhase(int phaseId)` that loads organisms from the repository without starting the game timer or modifying any game state. This allows the intro screen to display organisms without triggering game logic.

```dart
Future<List<Organism>> getOrganismsForPhase(int phaseId) async {
  return _organismRepository.getByPhaseId(phaseId);
}
```

### `lib/screens/phases_screen.dart`

**Navigation change:** The `_onPhaseTap` method now navigates to `BiomeIntroScreen` instead of directly to `GameScreen`. The `loadPhase()` call (which starts the timer) was removed from here — it now happens inside `BiomeIntroScreen._onExplore()` when the user taps "EXPLORAR".

**Unused imports removed:** `app_colors.dart` and `game_screen.dart` were removed (no longer directly referenced).

**Unused variable removed:** `final size = MediaQuery.of(context).size` — was declared but never used.

---

## Navigation Flow

**Before:**

```
Selecionar Fase → GameScreen
```

**After:**

```
Selecionar Fase → BiomeIntroScreen → (EXPLORAR) → GameScreen
```

Detailed flow:

1. User taps a phase card in `PhasesScreen`
2. Unlock check happens (unchanged)
3. If locked, snackbar shown (unchanged)
4. If unlocked, `Navigator.push(BiomeIntroScreen(phase: phase))`
5. Intro screen loads organisms for display via `getOrganismsForPhase()` — no timer starts
6. User reads about the biome, sees the organisms
7. User taps "EXPLORAR" → calls `service.loadPhase(phase)` (starts timer) → `Navigator.push(GameScreen)`
8. On returning from GameScreen, `PhasesScreen` still refreshes unlock status

---

## How to Add New Biomas

1. **Database seed** (`lib/database/database_seed.dart`): Add a new phase entry with a unique `biome` identifier (e.g., `'deserto'`).

2. **Asset paths** (`lib/core/asset_paths.dart`): Update `_biomeMap` with the new phase ID mapping, and if needed add organism sprite paths to `_fileMap`.

3. **Background images**: Place `cenarios/{bioma}.png` (and `{bioma}Svelt.png` for web) in `assets/images/cenarios/`.

4. **Organism sprites**: Place PNG files in `assets/images/animais/{bioma}/`.

5. **This file** (`lib/screens/biome_intro_screen.dart`): Add a new entry to the `_biomeInfo` map:

```dart
'deserto': _BiomeInfo(
  name: 'Deserto',
  description:
      'O deserto \u00e9 um ambiente seco e quente, com pouca \u00e1gua. '
      'Mesmo assim, animais e plantas encontram formas de sobreviver '
      'e dependem uns dos outros.',
),
```

No other changes needed — everything else (organism loading, background path resolution, sprite display) works automatically from the `phase.biome` field.

---

## Conventional Commit Message

```
feat: add biome introduction screen before phase start

Insert a BiomeIntroScreen between phase selection and gameplay,
showing the biome background, educational description, organism
sprites, and an "EXPLORAR" button that triggers phase loading.

- New: lib/screens/biome_intro_screen.dart
- Modified: lib/services/game_service.dart (getOrganismsForPhase)
- Modified: lib/screens/phases_screen.dart (navigation flow)
```
