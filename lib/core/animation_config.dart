class AnimationConfig {
  static const _frameCounts = {
    1: 1,
    2: 7,
    3: 5,
    4: 4,
    5: 6,
    6: 6,
    7: 6,
    8: 1,
    9: 7,
    10: 5,
    11: 4,
    12: 6,
    13: 6,
    14: 4,
    15: 6,
    16: 6,
    17: 4,
    18: 6,
    19: 6,
    20: 6,
    21: 7,
    22: 6,
    23: 6,
    24: 6,
    25: 6,
    26: 6,
    27: 6,
    28: 5,
    29: 6,
  };

  static int frameCount(int organismId) {
    return _frameCounts[organismId] ?? 6;
  }
}
