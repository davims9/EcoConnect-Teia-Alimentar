/// Scoring logic for the Trophic Classification mode.
///
/// The phase always ends with 100 % correct placements, so stars are
/// based on the ratio of obtained score to maximum possible score —
/// NOT on the percentage of correct answers.
class ClassificationScoring {
  const ClassificationScoring();

  // -- Point values -----------------------------------------------------------

  /// Points awarded for an organism placed correctly on the first verify.
  static const int firstTryPoints = 100;

  /// Points awarded for an organism placed correctly on later attempts.
  static const int laterTryPoints = 50;

  /// Penalty per wrong placement on a verify attempt.
  static const int wrongPlacementPenalty = 10;

  /// Penalty per conceptual hint used.
  static const int conceptualHintPenalty = 2;

  /// Penalty per relational hint used.
  static const int relationalHintPenalty = 5;

  /// Penalty per directional hint used.
  static const int directionalHintPenalty = 10;

  // -- Score calculation ------------------------------------------------------

  /// Calculates the final score for a completed phase.
  ///
  /// Never returns a negative value.
  int calculateScore({
    required int firstTryCorrectCount,
    required int laterTryCorrectCount,
    required int wrongPlacements,
    required int conceptualHints,
    required int relationalHints,
    required int directionalHints,
  }) {
    final rawScore =
        firstTryCorrectCount * firstTryPoints +
        laterTryCorrectCount * laterTryPoints -
        wrongPlacements * wrongPlacementPenalty -
        conceptualHints * conceptualHintPenalty -
        relationalHints * relationalHintPenalty -
        directionalHints * directionalHintPenalty;

    return rawScore < 0 ? 0 : rawScore;
  }

  // -- Stars ------------------------------------------------------------------

  /// Calculates stars (1-3) based on the score / maxScore ratio.
  ///
  /// Returns 1 star when [maxScore] <= 0.
  int calculateStars({required int score, required int maxScore}) {
    if (maxScore <= 0) return 1;

    final ratio = score / maxScore;

    if (ratio >= 0.85) return 3;
    if (ratio >= 0.60) return 2;
    return 1;
  }
}
