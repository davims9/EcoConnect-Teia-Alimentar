import 'package:flutter/material.dart';
import '../services/audio_service.dart';

/// A circular toggle button that controls global mute state.
///
/// Reads and writes [AudioService.instance.isMuted] directly via the
/// singleton. The state persists across screens without any Provider or
/// InheritedWidget wiring.
///
/// To add separate controls (e.g. music vs SFX) later, replace the
/// single boolean with a small config object inside [AudioService] and
/// add a second button that reads/writes a different field.
class AudioToggleButton extends StatefulWidget {
  const AudioToggleButton({super.key});

  @override
  State<AudioToggleButton> createState() => _AudioToggleButtonState();
}

class _AudioToggleButtonState extends State<AudioToggleButton>
    with SingleTickerProviderStateMixin {
  bool _isPressed = false;
  late AnimationController _toggleAnimController;
  late Animation<double> _toggleAnim;

  @override
  void initState() {
    super.initState();
    _toggleAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
      value: 1.0,
    );
    _toggleAnim = CurvedAnimation(
      parent: _toggleAnimController,
      curve: Curves.easeInOutBack,
    );
  }

  @override
  void dispose() {
    _toggleAnimController.dispose();
    super.dispose();
  }

  void _handleToggle() {
    final audio = AudioService.instance;
    audio.toggleMute();
    _toggleAnimController.forward(from: 0);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final isMuted = AudioService.instance.isMuted;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) => setState(() => _isPressed = false),
        onTapCancel: () => setState(() => _isPressed = false),
        onTap: _handleToggle,
        child: AnimatedScale(
        scale: _isPressed ? 0.88 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: ScaleTransition(
          scale: _toggleAnim,
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF1A3A24).withValues(alpha: 0.8),
              border: Border.all(
                color: const Color(0xFF2E7D32).withValues(alpha: 0.4),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF4CAF50).withValues(alpha: 0.15),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              transitionBuilder: (child, anim) => ScaleTransition(
                scale: anim,
                child: FadeTransition(opacity: anim, child: child),
              ),
              child: Icon(
                isMuted ? Icons.volume_off_rounded : Icons.volume_up_rounded,
                key: ValueKey(isMuted),
                size: 20,
                color: const Color(0xFF81C784),
              ),
            ),
          ),
        ),
        ),
      ),
    );
  }
}
