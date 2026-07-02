import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/organism.dart';
import '../models/phase.dart';
import '../models/score.dart';
import '../repositories/connection_repository.dart';
import '../repositories/organism_repository.dart';
import '../repositories/phase_repository.dart';
import '../repositories/score_repository.dart';
import 'scoring_service.dart';

class GameService extends ChangeNotifier {
  final PhaseRepository _phaseRepository = PhaseRepository();
  final OrganismRepository _organismRepository = OrganismRepository();
  final ConnectionRepository _connectionRepository = ConnectionRepository();
  final ScoreRepository _scoreRepository = ScoreRepository();
  final ScoringService _scoringService = ScoringService();

  List<Phase> _phases = [];
  Map<int, bool> _phaseUnlockStatus = {};
  Phase? _currentPhase;
  List<Organism> _organisms = [];
  Set<String> _correctConnections = {};
  Set<String> _playerConnections = {};
  Set<String> _wrongConnections = {};
  int _score = 0;
  int _errors = 0;
  bool _phaseComplete = false;
  bool _submitted = false;
  bool _isLoading = false;
  String? _errorMessage;
  int _remainingSeconds = 0;
  int _totalPhaseTime = 0;
  Timer? _timer;
  String _playerName = 'Jogador';

  List<Phase> get phases => _phases;
  Map<int, bool> get phaseUnlockStatus => _phaseUnlockStatus;
  Phase? get currentPhase => _currentPhase;
  String get playerName => _playerName;
  List<Organism> get organisms => _organisms;
  Set<String> get correctConnections => _correctConnections;
  Set<String> get playerConnections => _playerConnections;
  Set<String> get wrongConnections => _wrongConnections;
  int get score => _score;
  int get errors => _errors;
  bool get phaseComplete => _phaseComplete;
  bool get submitted => _submitted;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  int get remainingSeconds => _remainingSeconds;
  int get totalPhaseTime => _totalPhaseTime;

  Future<void> refreshUnlockStatus() async {
    _phaseUnlockStatus = {};
    for (final phase in _phases) {
      _phaseUnlockStatus[phase.id!] = await _scoreRepository.isPhaseUnlocked(phase.id!);
    }
    notifyListeners();
  }

  Future<void> loadPhases() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      _phases = await _phaseRepository.getAll();
      await refreshUnlockStatus();
    } catch (e) {
      _errorMessage = 'Erro ao carregar as fases.';
      // ignore: avoid_print
      print('[loadPhases] $e');
    }
    _isLoading = false;
    notifyListeners();
  }

  /// Loads only the organisms for a phase (display-only, no timer/game state).
  Future<List<Organism>> getOrganismsForPhase(int phaseId) async {
    return _organismRepository.getByPhaseId(phaseId);
  }

  Future<bool> loadPhase(Phase phase) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      _currentPhase = phase;
      _organisms = await _organismRepository.getByPhaseId(phase.id!);
      final keys = await _connectionRepository.getConnectionKeysByPhaseId(phase.id!);
      _correctConnections = keys;
      _playerConnections = {};
      _wrongConnections = {};
      _score = 0;
      _errors = 0;
      _phaseComplete = false;
      _submitted = false;
      _remainingSeconds = _scoringService.getPhaseTimeLimit(phase.id!);
      _totalPhaseTime = _remainingSeconds;
      _startTimer();
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Não foi possível carregar a fase.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  void addConnection(int sourceId, int targetId) {
    if (_submitted || _phaseComplete) return;
    if (sourceId == targetId) return;
    final key = '$sourceId-$targetId';
    _playerConnections.add(key);
    notifyListeners();
  }

  /// Removes a previously-added connection so the player can retry.
  void removeConnection(int sourceId, int targetId) {
    if (_submitted || _phaseComplete) return;
    final key = '$sourceId-$targetId';
    _playerConnections.remove(key);
    notifyListeners();
  }

  void submitPhase() {
    if (_submitted || _phaseComplete) return;
    _stopTimer();
    _submitted = true;

    int correctCount = 0;
    _wrongConnections = {};

    for (final key in _playerConnections) {
      if (_correctConnections.contains(key)) {
        correctCount++;
      } else {
        _wrongConnections.add(key);
      }
    }

    _errors = _correctConnections.length - correctCount;
    _score = _scoringService.calculateSubmitScore(
      correctCount,
      _correctConnections.length,
      _remainingSeconds,
    );
    _phaseComplete = true;
    notifyListeners();
  }

  void setPlayerName(String name) {
    _playerName = name.trim().isEmpty ? 'Jogador' : name.trim();
    notifyListeners();
  }

  Future<void> saveScore() async {
    if (_currentPhase == null || !_phaseComplete) return;
    try {
      final correctCount = _correctConnections.length - _errors;
      final score = Score(
        phaseId: _currentPhase!.id!,
        playerName: _playerName,
        score: _score,
        stars: _scoringService.calculateStars(correctCount, _correctConnections.length),
        errors: _errors,
        completedAt: DateTime.now().toIso8601String(),
      );
      await _scoreRepository.insert(score);
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Erro ao salvar pontuação.';
      notifyListeners();
    }
  }

  Future<bool> isPhaseUnlocked(int phaseId) async {
    return await _scoreRepository.isPhaseUnlocked(phaseId);
  }

  Future<void> resetAllScores() async {
    try {
      await _scoreRepository.deleteAll();
    } catch (_) {}
  }

  /// Returns true if the connection [sourceId]-[targetId] (prey-predator) is correct.
  bool isConnectionCorrect(int sourceId, int targetId) {
    return _correctConnections.contains('$sourceId-$targetId');
  }

  /// Returns true if the reversed key [targetId]-[sourceId] exists in correct
  /// connections (meaning the user dragged in the wrong direction).
  bool isConnectionReversed(int sourceId, int targetId) {
    return _correctConnections.contains('$targetId-$sourceId');
  }

  /// Looks up an organism by id in the current phase.
  Organism? getOrganismById(int id) {
    for (final o in _organisms) {
      if (o.id == id) return o;
    }
    return null;
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_remainingSeconds > 0) {
        _remainingSeconds--;
        notifyListeners();
      } else {
        _onTimerExpired();
      }
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    _timer = null;
  }

  void _onTimerExpired() {
    _stopTimer();
    submitPhase();
  }

  @override
  void dispose() {
    _stopTimer();
    super.dispose();
  }
}
