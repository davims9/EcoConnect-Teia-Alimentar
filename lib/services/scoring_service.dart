import '../core/app_constants.dart';

class ScoringService {
  int getPhaseTimeLimit(int phaseId) {
    return AppConstants.phaseTimeLimits[phaseId] ?? 120;
  }

  int calculateSubmitScore(
    int correctCount,
    int totalConnections,
    int remainingSeconds,
  ) {
    final base = correctCount * AppConstants.basePointsPerCorrect;
    final bonus = remainingSeconds * AppConstants.timeBonusMultiplier;
    return base + bonus;
  }

  int calculateStars(int correctCount, int totalConnections, int errors) {
    if (correctCount == 0) return 0;
    
    int stars = 0;
    double percentage = correctCount / totalConnections;
    
    // Divisão por terços (3/3 = 100%, 2/3 = ~66.6%, 1/3 = ~33.3%)
    if (percentage >= 1.0) {
      stars = 3;
    } else if (percentage >= (2.0 / 3.0)) {
      stars = 2;
    } else {
      stars = 1;
    }
    
    // Cada erro faz perder uma estrela
    stars -= errors;
    
    // O mínimo é 1 estrela, a não ser que não tenha acertado nada (que já retorna 0 no começo)
    if (stars < 1) {
      stars = 1;
    }
    
    return stars;
  }
}
