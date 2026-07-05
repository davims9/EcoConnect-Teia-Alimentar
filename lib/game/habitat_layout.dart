import 'dart:ui' show Offset;

/// Per-biome manual positions for Campo, Floresta and Pantanal.
///
/// Every organism has its own explicit (X, Y) in normalized space
/// (0.0–1.0 within the safe screen area).  Positions were chosen
/// by hand to:
///
///   • respect habitat (sky, canopy, ground, water)
///   • keep good visual separation between sprites/labels
///   • avoid excessive connection crossing
///   • avoid uniform "shelf" alignment
///
/// The positions are stable (no random jitter) so the same phase always
/// looks the same — important for a consistent learning experience.
class HabitatLayout {
  /// Returns the manual normalized position for [organismId] in [biome],
  /// or `null` if the biome uses automatic layout (Oceano).
  static Offset? getPosition(String biome, int organismId) {
    return _positions[biome]?[organismId];
  }

  /// Returns `true` if [biome] has manual positions.
  static bool hasLayout(String biome) => _positions.containsKey(biome);

  static final Map<String, Map<int, Offset>> _positions = {
    'campo': _campo,
    'floresta': _floresta,
    'pantanal': _pantanal,
  };

  // ═══════════════════════ CAMPO ═══════════════════════
  //
  //   Águia (top-center) preys on Cobra and Coelho.
  //   Raposa (upper-left) preys on Coelho.
  //   Cobra (upper-right) preys on Coelho and Sapo.
  //   Sapo (center-left) preys on Gafanhoto.
  //   Coelho (center-right) preys on Capim.
  //   Gafanhoto (lower-left) preys on Capim.
  //   Capim (lower-center, produtor).
  //
  static const _campo = <int, Offset>{
    7: Offset(0.50, 0.08),   // Águia — céu centro
    6: Offset(0.15, 0.32),   // Raposa — superior esquerda
    5: Offset(0.85, 0.60),   // Cobra — superior direita
    4: Offset(0.40, 0.50),   // Sapo — centro-esquerda
    3: Offset(0.68, 0.54),   // Coelho — centro-direita
    2: Offset(0.24, 0.74),   // Gafanhoto — inferior esquerdo
    1: Offset(0.52, 0.84),   // Capim — centro inferior
  };

  // ═══════════════════════ FLORESTA ═══════════════════════
  //
  //   Gavião (canopy-left) and Onça (canopy-right) are top predators.
  //   Cobra (center) is preyed by both.
  //   Veado (right) is preyed by Onça.
  //   Sapo (left) preys on Aranha and Lagarta.
  //   Aranha and Lagarta prey on Arbusto.
  //   Arbusto (bottom-center, produtor).
  //
  static const _floresta = <int, Offset>{
    13: Offset(0.20, 0.08),  // Gavião — copa esquerda
    15: Offset(0.60, 0.65),  // Onça-pintada — copa direita
    12: Offset(0.85, 0.78),  // Cobra — centro
    14: Offset(0.40, 0.70),  // Veado — solo direito
    11: Offset(0.15, 0.80),  // Sapo — solo esquerdo
    10: Offset(0.80, 0.10),  // Aranha — inferior esquerda
    9: Offset(0.70, 0.80),   // Lagarta — inferior direita
    8: Offset(0.48, 0.90),   // Arbusto — centro inferior
  };

  // ═══════════════════════ PANTANAL ═══════════════════════
  //
  //   Onça (top-center) preys on Garça and Jacaré.
  //   Garça (upper-left) preys on Peixe.
  //   Jacaré (mid-right) preys on Peixe.
  //   Cobra sucuri (mid-left) preys on Peixe and Jacaré.
  //   Peixe (center) preys on Caramujo and Planta aquática.
  //   Caramujo (lower-left) preys on Planta aquática.
  //   Planta aquática (lower-right, produtor).
  //
  //   Garça is a wading bird — stays in the upper area, not sky.
  //
  static const _pantanal = <int, Offset>{
    29: Offset(0.78, 0.38),  // Onça-pintada — topo centro
    26: Offset(0.85, 0.6),  // Garça — meio direita
    28: Offset(0.30, 0.38),  // Cobra sucuri — meio esquerda
    27: Offset(0.85, 0.70),  // Jacaré — meio direita
    25: Offset(0.55, 0.56),  // Peixe — centro
    24: Offset(0.25, 0.74),  // Caramujo — inferior esquerdo
    23: Offset(0.65, 0.84),  // Planta aquática — inferior direita
  };
}
