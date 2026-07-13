/// Status of a classification card during the gameplay flow.
///
/// ```text
/// shelf                  — card is in the shelf, waiting to be placed
/// placed                 — card has been placed in a zone (not yet verified)
/// verifiedCorrect        — card was correct in the last verification
/// verifiedIncorrect      — card was wrong in the last verification (can be moved)
/// lockedCorrect          — card is correctly placed and locked (end state)
/// ```
enum ClassificationCardStatus {
  shelf,
  placed,
  verifiedCorrect,
  verifiedIncorrect,
  lockedCorrect,
}
