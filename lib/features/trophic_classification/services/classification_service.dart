import 'package:flutter/foundation.dart';
import '../models/classification_card_status.dart';
import '../models/classification_hint.dart';
import '../models/classification_phase_config.dart';
import '../models/classification_score.dart';
import '../models/classification_verification_result.dart';
import '../models/trophic_level.dart';
import 'classification_scoring.dart';

/// State and rules for the Trophic Classification game flow.
///
/// Manages card positions, placement zones, batch verification,
/// gradual hints, and score calculation.
///
/// Does **not** import GameService, know colours, know widgets,
/// control a timer, or access SQL directly.
class ClassificationService extends ChangeNotifier {
  ClassificationPhaseConfig? _config;
  bool _isComplete = false;

  // -- Per-organism tracking ------------------------------------------------

  /// Current status of each organism card.
  final Map<int, ClassificationCardStatus> _statuses = {};

  /// Which zone each placed card occupies (organismId → zone).
  final Map<int, TrophicLevel> _placements = {};

  /// How many times each organism has been verified as incorrect.
  final Map<int, int> _wrongVerifications = {};

  /// How many hints have been requested per organism (cumulative).
  final Map<int, int> _hintCounters = {};

  /// Highest hint level used per organism.
  final Map<int, HintLevel> _highestHints = {};

  ClassificationVerificationResult? _lastResult;

  /// The trophic level being highlighted after a directional hint.
  /// Cleared on the next place/move/verify action.
  TrophicLevel? _highlightedLevel;

  /// How many verify calls had incorrect results.
  int _attempts = 0;

  // -- Scorer ---------------------------------------------------------------

  final ClassificationScoring _scoring = const ClassificationScoring();

  // -------------------------------------------------------------------------
  // Getters
  // -------------------------------------------------------------------------

  bool get hasConfig => _config != null;

  int get totalOrganisms => _config?.totalOrganisms ?? 0;

  /// Number of cards that are NOT in the shelf (placed or locked).
  int get placedCount =>
      _statuses.values.where((s) => s != ClassificationCardStatus.shelf).length;

  /// All cards must be placed (none in shelf) to verify.
  bool get canVerify =>
      hasConfig && !_isComplete && placedCount == totalOrganisms;

  /// Number of locked-correct cards.
  int get correctCount => _statuses.values
      .where((s) => s == ClassificationCardStatus.lockedCorrect)
      .length;

  bool get isComplete => _isComplete;

  ClassificationVerificationResult? get lastResult => _lastResult;

  ClassificationPhaseConfig? get config => _config;

  /// The trophic level highlighted by the last directional hint, if any.
  /// Cleared automatically on place / return / verify / reset.
  TrophicLevel? get highlightedLevel => _highlightedLevel;

  // -- Status queries -------------------------------------------------------

  /// Returns the current status of an organism card, or `shelf` if unknown.
  ClassificationCardStatus statusOf(int organismId) =>
      _statuses[organismId] ?? ClassificationCardStatus.shelf;

  /// Returns the zone where an organism is placed, or `null` if in shelf.
  TrophicLevel? placementOf(int organismId) => _placements[organismId];

  /// IDs of all organisms placed in the given zone.
  List<int> organismIdsInZone(TrophicLevel zone) =>
      _placements.entries
          .where((e) => e.value == zone)
          .map((e) => e.key)
          .toList();

  /// IDs of all organisms currently in the shelf (not placed).
  List<int> get unplacedOrganismIds =>
      _statuses.entries
          .where((e) => e.value == ClassificationCardStatus.shelf)
          .map((e) => e.key)
          .toList();

  // -------------------------------------------------------------------------
  // Phase lifecycle
  // -------------------------------------------------------------------------

  /// Loads a phase configuration and resets all state.
  void loadPhase(ClassificationPhaseConfig config) {
    _config = config;
    _isComplete = false;
    _highlightedLevel = null;
    _attempts = 0;
    _statuses.clear();
    _placements.clear();
    _wrongVerifications.clear();
    _hintCounters.clear();
    _highestHints.clear();
    _lastResult = null;

    for (final org in config.organisms) {
      _statuses[org.organismId] = ClassificationCardStatus.shelf;
    }

    notifyListeners();
  }

  /// Resets all cards to shelf, keeping the same config loaded.
  void resetCards() {
    if (_config == null) return;
    _isComplete = false;
    _highlightedLevel = null;
    _attempts = 0;
    _statuses.clear();
    _placements.clear();
    _wrongVerifications.clear();
    _hintCounters.clear();
    _highestHints.clear();
    _lastResult = null;

    for (final org in _config!.organisms) {
      _statuses[org.organismId] = ClassificationCardStatus.shelf;
    }

    notifyListeners();
  }

  // -------------------------------------------------------------------------
  // Card actions
  // -------------------------------------------------------------------------

  /// Places (or moves) a card into a trophic zone.
  ///
  /// No-op if the card is locked correct.
  void placeCard(int organismId, TrophicLevel zone) {
    if (_isComplete) return;
    if (!_statuses.containsKey(organismId)) return;
    if (_statuses[organismId] == ClassificationCardStatus.lockedCorrect) return;

    _highlightedLevel = null;
    _statuses[organismId] = ClassificationCardStatus.placed;
    _placements[organismId] = zone;
    _lastResult = null;
    notifyListeners();
  }

  /// Returns a card from a zone back to the shelf.
  ///
  /// No-op if the card is locked correct or already in shelf.
  void returnCardToShelf(int organismId) {
    if (_isComplete) return;
    if (!_statuses.containsKey(organismId)) return;
    if (_statuses[organismId] == ClassificationCardStatus.lockedCorrect) return;
    if (_statuses[organismId] == ClassificationCardStatus.shelf) return;

    _highlightedLevel = null;
    _statuses[organismId] = ClassificationCardStatus.shelf;
    _placements.remove(organismId);
    _lastResult = null;
    notifyListeners();
  }

  // -------------------------------------------------------------------------
  // Hint system
  // -------------------------------------------------------------------------

  /// Returns the next gradual hint for an organism, or `null` if the card is
  /// locked correct or all 3 hint levels have been exhausted.
  ClassificationHint? getHint(int organismId) {
    if (_config == null) return null;
    if (_statuses[organismId] == ClassificationCardStatus.lockedCorrect) {
      return null;
    }

    final org = _config!.organisms.firstWhere(
      (o) => o.organismId == organismId,
      orElse: () =>
          throw ArgumentError('Organism $organismId not found in phase'),
    );

    final hintIndex = _hintCounters[organismId] ?? 0;
    if (hintIndex >= org.hintMessages.length) return null;

    const levels = [
      HintLevel.conceptual,
      HintLevel.relational,
      HintLevel.directional,
    ];
    final level = levels[hintIndex];
    final message = org.hintMessages[hintIndex];

    _hintCounters[organismId] = hintIndex + 1;
    _highestHints[organismId] = level;

    final hint = ClassificationHint(
      organismId: organismId,
      level: level,
      message: message,
      highlightedLevel: level == HintLevel.directional
          ? org.expectedLevel
          : null,
    );

    _highlightedLevel = hint.highlightedLevel;
    notifyListeners();

    return hint;
  }

  // -------------------------------------------------------------------------
  // Batch verification
  // -------------------------------------------------------------------------

  /// Validates all placed cards against the expected levels.
  ///
  /// Returns an empty result if [canVerify] is false.
  /// Correct cards become [ClassificationCardStatus.lockedCorrect].
  /// Incorrect cards become [ClassificationCardStatus.verifiedIncorrect].
  ClassificationVerificationResult verify() {
    if (!canVerify || _config == null) {
      return const ClassificationVerificationResult(
        correctIds: {},
        incorrectIds: {},
        isComplete: false,
      );
    }

    _highlightedLevel = null;
    final correctIds = <int>{};
    final incorrectIds = <int>{};

    for (final org in _config!.organisms) {
      final id = org.organismId;
      final status = _statuses[id] ?? ClassificationCardStatus.shelf;

      // Already locked — carry forward.
      if (status == ClassificationCardStatus.lockedCorrect) {
        correctIds.add(id);
        continue;
      }

      final placedZone = _placements[id];
      // In shelf — should not happen when canVerify, but guard anyway.
      if (placedZone == null) continue;

      if (placedZone == org.expectedLevel) {
        _statuses[id] = ClassificationCardStatus.lockedCorrect;
        correctIds.add(id);
      } else {
        _statuses[id] = ClassificationCardStatus.verifiedIncorrect;
        _wrongVerifications[id] = (_wrongVerifications[id] ?? 0) + 1;
        incorrectIds.add(id);
      }
    }

    if (incorrectIds.isNotEmpty) _attempts++;

    final complete = incorrectIds.isEmpty;
    _isComplete = complete;

    _lastResult = ClassificationVerificationResult(
      correctIds: correctIds,
      incorrectIds: incorrectIds,
      isComplete: complete,
    );

    notifyListeners();
    return _lastResult!;
  }

  // -------------------------------------------------------------------------
  // Scoring
  // -------------------------------------------------------------------------

  /// Maximum possible score for the current phase (all correct first try,
  /// no hints, no penalties).
  int get maxScore => totalOrganisms * ClassificationScoring.firstTryPoints;

  /// Calculates the current score based on tracking data.
  int get score => _computeScore();

  /// Calculates stars (1-3) based on [score] / [maxScore].
  int get stars => _scoring.calculateStars(score: score, maxScore: maxScore);

  int _computeScore() {
    if (_config == null) return 0;

    int firstTryCorrect = 0;
    int laterTryCorrect = 0;

    for (final org in _config!.organisms) {
      final id = org.organismId;
      final isCorrect = _statuses[id] == ClassificationCardStatus.lockedCorrect;
      if (!isCorrect) continue;

      final wrongCount = _wrongVerifications[id] ?? 0;
      if (wrongCount == 0) {
        firstTryCorrect++;
      } else {
        laterTryCorrect++;
      }
    }

    int conceptual = 0, relational = 0, directional = 0;
    for (final count in _hintCounters.values) {
      if (count >= 1) conceptual++;
      if (count >= 2) relational++;
      if (count >= 3) directional++;
    }

    final totalWrong = _wrongVerifications.values.fold(0, (a, b) => a + b);

    return _scoring.calculateScore(
      firstTryCorrectCount: firstTryCorrect,
      laterTryCorrectCount: laterTryCorrect,
      wrongPlacements: totalWrong,
      conceptualHints: conceptual,
      relationalHints: relational,
      directionalHints: directional,
    );
  }

  // -------------------------------------------------------------------------
  // Persistence helpers
  // -------------------------------------------------------------------------

  /// Number of organisms that used at least one hint.
  int get hintsUsed =>
      _hintCounters.values.where((c) => c > 0).length;

  /// Total wrong-placement count across all verify calls.
  int get wrongPlacements =>
      _wrongVerifications.values.fold(0, (a, b) => a + b);

  /// Builds a [ClassificationScore] from the current service state.
  ///
  /// The caller provides [playerName]; defaults to 'Jogador'.
  /// Returns `null` if no config is loaded or the game is not complete.
  ClassificationScore? buildScore({String playerName = 'Jogador'}) {
    if (_config == null || !_isComplete) return null;

    return ClassificationScore(
      classificationPhaseKey: _config!.key,
      biomePhaseId: _config!.biomePhaseId,
      playerName: playerName,
      score: score,
      maxScore: maxScore,
      stars: stars,
      wrongPlacements: wrongPlacements,
      hintsUsed: hintsUsed,
      attempts: _attempts,
      completedAt: DateTime.now().toIso8601String(),
    );
  }
}
