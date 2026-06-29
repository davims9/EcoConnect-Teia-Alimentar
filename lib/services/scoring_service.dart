import '../core/app_constants.dart';

class ScoringService {
  int getPhaseTimeLimit(int phaseId) {
    return AppConstants.phaseTimeLimits[phaseId] ?? 120;
  }

  int calculateSubmitScore(int correctCount, int totalConnections, int remainingSeconds) {
    final base = correctCount * AppConstants.basePointsPerCorrect;
    final bonus = remainingSeconds * AppConstants.timeBonusMultiplier;
    return base + bonus;
  }

  int calculateStars(int correctCount, int totalConnections) {
    if (totalConnections == 0) return 0;
    final ratio = correctCount / totalConnections;
    if (ratio >= 0.9) return 3;
    if (ratio >= 0.6) return 2;
    return 1;
  }
}
