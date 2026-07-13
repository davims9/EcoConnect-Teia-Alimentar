import 'trophic_level.dart';

/// The depth / intrusiveness of a hint.
///
/// 1. **conceptual** — a general question about how the organism obtains
///    energy (never highlights a zone).
/// 2. **relational** — explains a specific feeding relationship.
/// 3. **directional** — may point to or highlight a zone.
enum HintLevel { conceptual, relational, directional }

/// A hint for a specific organism at a specific level.
///
/// [highlightedLevel] is only set for [HintLevel.directional] hints.
/// No widget, BuildContext or colour dependency.
class ClassificationHint {
  final int organismId;
  final HintLevel level;
  final String message;

  /// The trophic zone highlighted by this hint (directional only).
  final TrophicLevel? highlightedLevel;

  const ClassificationHint({
    required this.organismId,
    required this.level,
    required this.message,
    this.highlightedLevel,
  });
}
