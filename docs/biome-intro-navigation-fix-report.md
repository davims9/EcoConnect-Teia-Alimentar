# Biome Intro Screen - Navigation Fix Report

## Problem

After completing a phase, pressing "Voltar as fases" in the completion overlay returned the player to the **BiomeIntroScreen** instead of the **PhasesScreen**.

### Root cause

The navigation stack was:

```
PhasesScreen → BiomeIntroScreen (push) → GameScreen (push)
```

When `Navigator.pop()` was called from GameScreen (either via completion overlay or exit confirmation), it removed GameScreen from the stack, revealing BiomeIntroScreen underneath — because GameScreen had been **pushed on top** of BiomeIntroScreen.

### Relevant code (before)

In `biome_intro_screen.dart`, line 344:

```dart
navigator.push(
  MaterialPageRoute(builder: (_) => const GameScreen()),
);
```

---

## Fix

Changed `push` to `pushReplacement` when navigating from BiomeIntroScreen to GameScreen.

### Navigation stack (after)

```
PhasesScreen → BiomeIntroScreen (push) → GameScreen (pushReplacement)
```

`pushReplacement` **replaces** BiomeIntroScreen with GameScreen in the stack. The stack becomes:

```
PhasesScreen → GameScreen
```

When GameScreen pops (completion overlay "Voltar as fases" or back button confirmation), it goes directly to **PhasesScreen** — the BiomeIntroScreen is no longer in the stack.

### Relevant code (after)

In `biome_intro_screen.dart`, line 344:

```dart
navigator.pushReplacement(
  MaterialPageRoute(builder: (_) => const GameScreen()),
);
```

---

## Side effects verified

| Scenario | Behavior | Correct? |
|----------|----------|----------|
| Press "EXPLORAR" → GameScreen loads | GameScreen replaces BiomeIntroScreen in stack | Yes |
| Complete phase → "Voltar as fases" | Goes directly to PhasesScreen | Yes |
| Press back in GameScreen → confirm exit | Goes directly to PhasesScreen | Yes |
| Press back in BiomeIntroScreen | Goes directly to PhasesScreen | Yes |
| `refreshUnlockStatus` on return | Future from `push(BiomeIntroScreen)` resolves when replacement (GameScreen) pops | Yes |
| Phase unlock logic | Unchanged | Yes |

---

## Files altered

| File | Change |
|------|--------|
| `lib/screens/biome_intro_screen.dart` | `push` → `pushReplacement` on line 344 |

No other files were touched. `PhasesScreen`, `GameScreen`, and `GameService` are unchanged.

---

## Conventional Commit Message

```
fix: replace biome intro route instead of pushing game on top

Change Navigator.push to Navigator.pushReplacement when navigating
from BiomeIntroScreen to GameScreen so that popping GameScreen
returns directly to PhasesScreen instead of revealing the intro
screen underneath.
```
