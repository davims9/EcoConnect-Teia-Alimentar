class AppConstants {
  AppConstants._();

  static const String appName = 'EcoConnect: Teia Alimentar';
  static const int initialScore = 0;
  static const int basePointsPerCorrect = 100;
  static const int timeBonusMultiplier = 10;
  static const int maxPlayerNameLength = 20;
  static const int dbTimeoutSeconds = 5;
  static const int dbVersion = 1;
  static const String dbName = 'food_web.db';
  static const double organismSize = 90.0;
  static const double lineStrokeWidth = 3.0;

  static const Map<int, int> phaseTimeLimits = {1: 120, 2: 100, 3: 80, 4: 60};
}
