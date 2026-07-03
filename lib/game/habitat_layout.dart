import 'dart:ui';

/// Visual layers for organism positioning by habitat.
///
/// Each organism is classified into one of these layers per biome.
/// The layer determines the vertical region of the screen where
/// the organism will appear.
enum VisualLayer {
  /// Birds and flying organisms — top region of the screen.
  sky,

  /// Canopy / tree-dwelling organisms in Forest biome.
  canopy,

  /// Terrestrial animals and plants — bottom region.
  ground,

  /// Aquatic organisms in Pantanal biome.
  water,

  /// Elevated position (not sky) for organisms like onça in Pantanal.
  elevated,
}

/// Per-biome explicit slot positions for natural organism layout.
///
/// Normalized coordinates (0.0–1.0) mapped to the safe screen area
/// (between top/bottom/side margins). Values represent the center
/// of the organism's sprite.
///
/// Layout zones per biome (fraction of safe area):
///
/// [[campo]]
///   sky:     Y 0.00–0.22  (Águia)
///   ground:  Y 0.60–1.00  (all terrestrial)
///
/// [[floresta]]
///   canopy:  Y 0.00–0.30  (Gavião, Aranha, Lagarta)
///   ground:  Y 0.60–1.00  (Arbusto, Sapo, Cobra, Veado, Onça)
///
/// [[pantanal]]
///   water:   Y 0.30–0.60  (Peixe, Jacaré, Garça, Cobra sucuri)
///   ground:  Y 0.65–1.00  (Planta aquática, Caramujo)
///   elevated: Y 0.25–0.35 (Onça-pintada on riverbank)
class HabitatLayout {
  /// Returns explicit normalized (x, y) positions keyed by organism ID
  /// for the given biome. Returns null if no explicit layout exists
  /// (the zone-based fallback is used instead, e.g. for Oceano).
  static Map<int, Offset>? getPositions(String biome) {
    return _layouts[biome];
  }

  /// Returns the visual layer for [organismId] in [biome].
  static VisualLayer getLayer(String biome, int organismId) {
    return _layerMaps[biome]?[organismId] ?? VisualLayer.ground;
  }

  static final Map<String, Map<int, Offset>> _layouts = {
    'campo': _campoPositions,
    'floresta': _florestaPositions,
    'pantanal': _pantanalPositions,
  };

  static final Map<String, Map<int, VisualLayer>> _layerMaps = {
    'campo': _campoLayers,
    'floresta': _florestaLayers,
    'pantanal': _pantanalLayers,
  };

  // ═══════════════════════ Campo ═══════════════════════
  //
  //   Sky:   Águia (0.50, 0.10)
  //   Ground: Capim at far-left, Gafanhoto near capim,
  //           Sapo center, Coelho right, Cobra far-right,
  //           Raposa lower-left near where prey roam.
  //
  //  Connections: Águia ← Cobra ← Sapo ← Gafanhoto ← Capim
  //               Águia ← Cobra ← Coelho ← Capim
  //               Raposa ← Coelho ← Capim
  //               Cobra ← Sapo ← Gafanhoto ← Capim
  //

  static const _campoLayers = <int, VisualLayer>{
    7: VisualLayer.sky,    // Águia
    1: VisualLayer.ground, // Capim
    2: VisualLayer.ground, // Gafanhoto
    3: VisualLayer.ground, // Coelho
    4: VisualLayer.ground, // Sapo
    5: VisualLayer.ground, // Cobra
    6: VisualLayer.ground, // Raposa
  };

  static const _campoPositions = <int, Offset>{
    7: Offset(0.50, 0.10),  // Águia — sky centered
    1: Offset(0.12, 0.88),  // Capim — far left, very bottom
    2: Offset(0.28, 0.78),  // Gafanhoto — near capim, slightly above
    4: Offset(0.48, 0.82),  // Sapo — center ground
    3: Offset(0.65, 0.74),  // Coelho — right of center
    5: Offset(0.85, 0.80),  // Cobra — far right ground
    6: Offset(0.30, 0.92),  // Raposa — left lower ground
  };

  // ═══════════════════════ Floresta ═══════════════════════
  //
  //   Canopy: Gavião (left), Aranha (center), Lagarta (right on leaves)
  //   Ground: Arbusto far-left, Sapo left-center, Cobra center,
  //           Veado right, Onça center-low
  //
  //  Connections: Gavião ← Cobra ← Sapo ← Lagarta ← Arbusto
  //               Gavião ← Cobra ← Sapo ← Aranha ← Lagarta ← Arbusto
  //               Onça ← Cobra ← Sapo ← Lagarta ← Arbusto
  //               Onça ← Veado ← Arbusto
  //               Cobra ← Sapo ← Aranha ← Lagarta ← Arbusto
  //               Sapo ← Aranha ← Lagarta ← Arbusto
  //

  static const _florestaLayers = <int, VisualLayer>{
    13: VisualLayer.canopy, // Gavião
    10: VisualLayer.canopy, // Aranha
    9: VisualLayer.canopy,  // Lagarta
    8: VisualLayer.ground,  // Arbusto
    11: VisualLayer.ground, // Sapo
    12: VisualLayer.ground, // Cobra
    14: VisualLayer.ground, // Veado
    15: VisualLayer.ground, // Onça-pintada
  };

  static const _florestaPositions = <int, Offset>{
    13: Offset(0.20, 0.14),  // Gavião — canopy left
    10: Offset(0.52, 0.22),  // Aranha — canopy center (web)
    9: Offset(0.80, 0.18),   // Lagarta — canopy right (on leaves)
    8: Offset(0.12, 0.72),   // Arbusto — ground far left (plant)
    11: Offset(0.35, 0.80),  // Sapo — ground left-center
    12: Offset(0.58, 0.74),  // Cobra — ground center
    14: Offset(0.78, 0.82),  // Veado — ground right
    15: Offset(0.50, 0.92),  // Onça-pintada — ground center-low
  };

  // ═══════════════════════ Pantanal ═══════════════════════
  //
  //   Elevated: Onça-pintada (riverbank, not sky)
  //   Water:    Cobra sucuri, Garça (wading), Jacaré, Peixe
  //   Ground:   Caramujo, Planta aquática
  //
  //  Connections: Onça ← Garça ← Peixe ← Caramujo ← Planta aquática
  //               Onça ← Jacaré ← Peixe ← Caramujo ← Planta aquática
  //               Cobra sucuri ← Jacaré ← Peixe ← Caramujo ← Planta aquática
  //               Garça ← Peixe ← Planta aquática
  //               Onça ← Jacaré ← Peixe ← Planta aquática
  //               Cobra sucuri ← Peixe ← Planta aquática
  //               Jacaré ← Peixe ← Planta aquática
  //

  static const _pantanalLayers = <int, VisualLayer>{
    29: VisualLayer.elevated, // Onça-pintada
    28: VisualLayer.water,    // Cobra sucuri
    26: VisualLayer.water,    // Garça (wading bird — on water, not sky)
    27: VisualLayer.water,    // Jacaré
    25: VisualLayer.water,    // Peixe
    24: VisualLayer.ground,   // Caramujo
    23: VisualLayer.ground,   // Planta aquática
  };

  static const _pantanalPositions = <int, Offset>{
    29: Offset(0.72, 0.30),  // Onça-pintada — elevated (riverbank)
    28: Offset(0.35, 0.42),  // Cobra sucuri — water mid-left
    26: Offset(0.15, 0.55),  // Garça — water far left (wading)
    27: Offset(0.80, 0.48),  // Jacaré — water right
    25: Offset(0.55, 0.62),  // Peixe — water center
    24: Offset(0.30, 0.75),  // Caramujo — ground left
    23: Offset(0.65, 0.82),  // Planta aquática — ground right
  };
}
