import 'package:flame_audio/flame_audio.dart';

/// Represents the current screen context for audio decisions.
///
/// Used by [AudioService] to determine which ambient sound (if any) should
/// play when the user unmutes the game.
enum AudioContext {
  /// No specific screen active (initial state, or transitional).
  none,

  /// Home screen — no biome ambient should play here.
  home,

  /// Inside a game phase with a biome ambient.
  game,
}

class AudioService {
  static final AudioService _instance = AudioService._();
  static AudioService get instance => _instance;
  AudioService._();

  bool _initialized = false;
  bool _muted = false;
  String? _currentBiome;
  AudioContext _currentContext = AudioContext.none;

  static const Map<String, String> _ambientFiles = {
    'campo': 'sound_campo.mp3',
    'floresta': 'sound_floresta.mp3',
    'oceano': 'sound_oceano.mp3',
    'pantanal': 'sound_pantanal.mp3',
  };

  bool get isMuted => _muted;

  /// The current screen context used to decide ambient behaviour on unmute.
  AudioContext get currentContext => _currentContext;

  Future<void> init() async {
    if (_initialized) return;
    _initialized = true;
  }

  /// Toggles the global mute state.
  ///
  /// When muting, all ambient audio is stopped immediately.
  /// When unmuting, ambient is resumed **only** if we are inside a game
  /// screen ([AudioContext.game]) with a known biome.  On other screens
  /// (home, phases, ranking, …) no ambient is restarted automatically.
  void toggleMute() {
    _muted = !_muted;
    if (_muted) {
      stopAmbient();
    } else {
      if (_currentContext == AudioContext.game && _currentBiome != null) {
        _playBiome(_currentBiome!);
      }
      // On any other context stay silent — no ambient to resume.
    }
  }

  /// Sets the current screen [context].
  ///
  /// Screens should call this when they become active so that
  /// [toggleMute] knows which ambient (if any) to resume.
  void setContext(AudioContext context) {
    _currentContext = context;
  }

  /// Starts ambient audio for [biome] and marks the context as [AudioContext.game].
  ///
  /// If the game is currently muted the call is a no-op, but the biome
  /// is still remembered so that unmuting later can resume it.
  void playAmbient(String biome) {
    _currentBiome = biome.toLowerCase();
    _currentContext = AudioContext.game;
    if (_muted) return;
    _playBiome(biome);
  }

  /// Called when leaving a game screen.
  ///
  /// Stops the ambient, clears the biome reference and resets the context
  /// so that unmuting on a non-game screen (e.g. Home) does *not* resume
  /// the last biome.
  void leaveGame() {
    stopAmbient();
    _currentBiome = null;
    _currentContext = AudioContext.none;
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

  /// Plays the "correct connection" SFX.
  /// Respects the global mute state — no audio when muted.
  void playCorrect() {
    if (_muted) return;
    try {
      FlameAudio.play('geral/acertou.mp3', volume: 1.0);
    } catch (_) {}
  }

  /// Plays the "wrong connection" SFX.
  /// Respects the global mute state — no audio when muted.
  void playWrong() {
    if (_muted) return;
    try {
      FlameAudio.play('geral/errou.mp3', volume: 1.0);
    } catch (_) {}
  }

  /// Plays the "phase complete" SFX.
  /// Respects the global mute state — no audio when muted.
  void playComplete() {
    if (_muted) return;
    try {
      FlameAudio.play('geral/terminou.mp3', volume: 1.0);
    } catch (_) {}
  }

  void dispose() {
    stopAmbient();
    _initialized = false;
    _muted = false;
    _currentBiome = null;
    _currentContext = AudioContext.none;
  }
}
