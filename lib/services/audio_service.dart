import 'package:flame_audio/flame_audio.dart';

class AudioService {
  static final AudioService _instance = AudioService._();
  static AudioService get instance => _instance;
  AudioService._();

  bool _initialized = false;
  bool _muted = false;
  String? _currentBiome;

  static const Map<String, String> _ambientFiles = {
    'campo': 'sound_campo.mp3',
    'floresta': 'sound_floresta.mp3',
    'oceano': 'sound_oceano.mp3',
    'pantanal': 'sound_pantanal.mp3',
  };

  bool get isMuted => _muted;

  Future<void> init() async {
    if (_initialized) return;
    _initialized = true;
  }

  /// Toggles the global mute state.
  ///
  /// When muting, all ambient audio is stopped immediately.
  /// When unmuting, the last played biome ambient is resumed.
  void toggleMute() {
    _muted = !_muted;
    if (_muted) {
      stopAmbient();
    } else {
      if (_currentBiome != null) {
        _playBiome(_currentBiome!);
      }
    }
  }

  void playAmbient(String biome) {
    _currentBiome = biome.toLowerCase();
    if (_muted) return;
    _playBiome(biome);
  }

  void _playBiome(String biome) {
    final file = _ambientFiles[biome.toLowerCase()];
    if (file == null) return;
    try {
      FlameAudio.bgm.play('${biome.toLowerCase()}/$file', volume: 1.0);
    } catch (_) {}
  }

  void stopAmbient() {
    try {
      FlameAudio.bgm.stop();
    } catch (_) {}
  }

  void playCorrect() {
    try {
      FlameAudio.play('geral/acertou.mp3', volume: 1.0);
    } catch (_) {}
  }

  void playWrong() {
    try {
      FlameAudio.play('geral/errou.mp3', volume: 1.0);
    } catch (_) {}
  }

  void playComplete() {
    try {
      FlameAudio.play('geral/terminou.mp3', volume: 1.0);
    } catch (_) {}
  }

  void dispose() {
    stopAmbient();
    _initialized = false;
    _muted = false;
    _currentBiome = null;
  }
}
