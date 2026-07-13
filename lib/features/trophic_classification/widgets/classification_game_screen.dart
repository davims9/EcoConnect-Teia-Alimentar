import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/classification_card_status.dart';
import '../models/classification_phase_config.dart';
import '../models/classification_verification_result.dart';
import '../models/organism_classification.dart';
import '../models/trophic_level.dart';
import '../repositories/classification_score_repository.dart';
import '../services/classification_service.dart';
import 'classification_action_bar.dart';
import 'classification_hud.dart';
import 'classification_shelf.dart';
import 'classification_zone.dart';
import 'classification_zone_colors.dart';

/// Main game screen for the Trophic Classification mode.
///
/// Architecture (Stack):
/// 1. Biome background image
/// 2. Dark overlay so content remains readable
/// 3. Game content: HUD → zones → shelf
/// 4. Floating "Verificar" CTA button
///
/// Progress counter and Dica live inside the HUD — no separate lines.
class ClassificationGameScreen extends StatelessWidget {
  final ClassificationPhaseConfig config;

  const ClassificationGameScreen({super.key, required this.config});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ClassificationService()..loadPhase(config),
      child: const _GameBody(),
    );
  }
}

class _GameBody extends StatefulWidget {
  const _GameBody();

  @override
  State<_GameBody> createState() => _GameBodyState();
}

class _GameBodyState extends State<_GameBody> {
  /// The organism card currently selected via tap (null = none selected).
  int? _selectedOrganismId;

  void _selectCard(int organismId) {
    setState(() {
      _selectedOrganismId = _selectedOrganismId == organismId
          ? null
          : organismId;
    });
  }

  void _clearSelection() {
    setState(() => _selectedOrganismId = null);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<ClassificationService>(
        builder: (context, service, _) {
          if (!service.hasConfig) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF7ED957)),
            );
          }
          return _buildLayout(context, service);
        },
      ),
    );
  }

  /// Maps a biome name to its background asset path.
  String _backgroundAsset(String biomeName) {
    switch (biomeName) {
      case 'Campo':
        return 'assets/images/trophic_mode/cenarios/campo_v2.png';
      case 'Floresta':
        return 'assets/images/trophic_mode/cenarios/floresta_v2.png';
      case 'Oceano':
        return 'assets/images/trophic_mode/cenarios/oceano_v2.png';
      case 'Pantanal':
        return 'assets/images/trophic_mode/cenarios/pantanal_v2.png';
      default:
        return 'assets/images/trophic_mode/cenarios/campo_v2.png';
    }
  }

  Widget _buildLayout(BuildContext context, ClassificationService service) {
    final config = service.config!;
    final isComplete = service.isComplete;

    return Stack(
      fit: StackFit.expand,
      children: [
        // 1. Biome background
        Image.asset(_backgroundAsset(config.biomeName), fit: BoxFit.cover),
        // 2. Dark overlay
        Container(color: const Color(0xFF001A0A).withValues(alpha: 0.55)),
        // 3. Game content
        SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // HUD (Teia style — includes progress and Dica)
              ClassificationHud(
                service: service,
                onHint: _selectedOrganismId != null && !isComplete
                    ? () => _showHint(context, service)
                    : null,
              ),
              // Zones (content-based height, scrollable)
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: ListView(
                    children: TrophicLevel.values.reversed.map((level) {
                      final zoneOrgs = _organismsInZone(service, level);
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: ClassificationZone(
                          level: level,
                          organisms: zoneOrgs,
                          statuses: _buildStatusMap(service),
                          isHighlighted: service.highlightedLevel == level,
                          selectedOrganismId: _selectedOrganismId,
                          onCardTap: _selectCard,
                          onAccept: (org) {
                            service.placeCard(org.organismId, level);
                            _clearSelection();
                          },
                          onZoneTap: _selectedOrganismId != null
                              ? () {
                                  service.placeCard(
                                    _selectedOrganismId!,
                                    level,
                                  );
                                  _clearSelection();
                                }
                              : null,
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
              // Shelf (compact — shrinks when empty)
              ClassificationShelf(
                unplacedOrganisms: _unplacedOrganisms(service),
                selectedOrganismId: _selectedOrganismId,
                onCardTap: _selectCard,
                onReturnToShelf: (org) {
                  service.returnCardToShelf(org.organismId);
                  _clearSelection();
                },
              ),
            ],
          ),
        ),
        // 4. Floating Verificar CTA
        Positioned(
          left: 0,
          right: 0,
          bottom: 12,
          child: Center(
            child: ClassificationActionBar(
              service: service,
              onVerify: () => _handleVerify(context, service),
            ),
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Data helpers
  // ---------------------------------------------------------------------------

  List<OrganismClassification> _organismsInZone(
    ClassificationService service,
    TrophicLevel zone,
  ) {
    final ids = service.organismIdsInZone(zone);
    return service.config!.organisms
        .where((o) => ids.contains(o.organismId))
        .toList();
  }

  List<OrganismClassification> _unplacedOrganisms(
    ClassificationService service,
  ) {
    final ids = service.unplacedOrganismIds;
    return service.config!.organisms
        .where((o) => ids.contains(o.organismId))
        .toList()
      ..sort((a, b) => a.organismId.compareTo(b.organismId));
  }

  Map<int, ClassificationCardStatus> _buildStatusMap(
    ClassificationService service,
  ) {
    final map = <int, ClassificationCardStatus>{};
    for (final org in service.config!.organisms) {
      map[org.organismId] = service.statusOf(org.organismId);
    }
    return map;
  }

  // ---------------------------------------------------------------------------
  // Hint dialog
  // ---------------------------------------------------------------------------

  void _showHint(BuildContext context, ClassificationService service) {
    final id = _selectedOrganismId;
    if (id == null) return;

    final hint = service.getHint(id);
    if (hint == null) {
      _showInfoDialog(
        context,
        title: 'Dica',
        message:
            'N\u00E3o h\u00E1 mais dicas dispon\u00EDveis para este organismo.',
      );
      return;
    }

    final zoneColor = hint.highlightedLevel != null
        ? ClassificationZoneColors.colorOf(hint.highlightedLevel!)
        : null;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF0B3D22),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: zoneColor ?? const Color(0xFF2E7D32),
            width: 1.5,
          ),
        ),
        title: Row(
          children: [
            Icon(Icons.lightbulb, size: 22, color: const Color(0xFFFFC107)),
            const SizedBox(width: 8),
            const Text(
              'Dica',
              style: TextStyle(color: Color(0xFFF0FDF4), fontSize: 18),
            ),
          ],
        ),
        content: Text(
          hint.message,
          style: const TextStyle(
            color: Color(0xFFD4EDDA),
            fontSize: 15,
            height: 1.4,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(
              'Entendi',
              style: TextStyle(
                color: Color(0xFF7ED957),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Verify
  // ---------------------------------------------------------------------------

  void _handleVerify(BuildContext context, ClassificationService service) {
    if (!service.canVerify) return;

    final result = service.verify();

    if (result.isComplete) {
      _showCompletionDialog(context, service);
    } else {
      _showVerifyResult(context, result, service);
    }
  }

  void _showVerifyResult(
    BuildContext context,
    ClassificationVerificationResult result,
    ClassificationService service,
  ) {
    final correct = result.correctIds.length;
    final incorrect = result.incorrectIds.length;
    final total = service.totalOrganisms;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF0B3D22),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Color(0xFFFDBA74), width: 1.5),
        ),
        title: Row(
          children: [
            const Icon(
              Icons.rate_review_outlined,
              size: 22,
              color: Color(0xFFFDBA74),
            ),
            const SizedBox(width: 8),
            const Text(
              'Verifica\u00E7\u00E3o',
              style: TextStyle(color: Color(0xFFF0FDF4), fontSize: 18),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$correct de $total organismo(s) correto(s)!',
              style: const TextStyle(
                color: Color(0xFF7ED957),
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (incorrect > 0) ...[
              const SizedBox(height: 8),
              Text(
                '$incorrect organismo(s) em zona errada. '
                'Tente mov\u00EA-los para outra zona.',
                style: const TextStyle(color: Color(0xFFFDBA74), fontSize: 14),
              ),
            ],
            const SizedBox(height: 8),
            Text(
              'Pontua\u00E7\u00E3o: ${service.score}',
              style: const TextStyle(
                color: Color(0xFFFFC107),
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(
              'Continuar',
              style: TextStyle(
                color: Color(0xFF7ED957),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showCompletionDialog(
    BuildContext context,
    ClassificationService service,
  ) async {
    // Save score to database.
    final scoreData = service.buildScore();
    if (scoreData != null) {
      try {
        await ClassificationScoreRepository().insert(scoreData);
      } catch (_) {
        // Non-critical — score survives in memory for this session.
      }
    }

    final stars = service.stars;
    final score = service.score;

    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF0B3D22),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Color(0xFF7ED957), width: 2),
        ),
        title: const Row(
          children: [
            Icon(Icons.emoji_events, size: 24, color: Color(0xFFFFC107)),
            SizedBox(width: 8),
            Text(
              'Fase Completa!',
              style: TextStyle(color: Color(0xFFF0FDF4), fontSize: 18),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(3, (i) {
                final filled = i < stars;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Icon(
                    filled ? Icons.star : Icons.star_border,
                    size: 36,
                    color: filled
                        ? const Color(0xFFFFC107)
                        : const Color(0xFFFFC107).withValues(alpha: 0.30),
                  ),
                );
              }),
            ),
            const SizedBox(height: 12),
            Text(
              'Pontua\u00E7\u00E3o final: $score',
              style: const TextStyle(
                color: Color(0xFFFFC107),
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _completionMessage(stars),
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFFD4EDDA),
                fontSize: 14,
                height: 1.4,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pop(context);
            },
            child: const Text(
              'Voltar',
              style: TextStyle(
                color: Color(0xFF7ED957),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 8),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              setState(() {
                _selectedOrganismId = null;
              });
              service.resetCards();
            },
            child: const Text(
              'Tentar Novamente',
              style: TextStyle(
                color: Color(0xFFFBBF24),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _completionMessage(int stars) {
    switch (stars) {
      case 3:
        return 'Perfeito! Voc\u00EA classificou todos os organismos '
            'corretamente sem erros!';
      case 2:
        return 'Muito bom! Voc\u00EA classificou a maioria dos '
            'organismos corretamente.';
      default:
        return 'Voc\u00EA completou a fase! Tente novamente para '
            'melhorar sua pontua\u00E7\u00E3o.';
    }
  }

  void _showInfoDialog(
    BuildContext context, {
    required String title,
    required String message,
  }) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF0B3D22),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Color(0xFF2E7D32), width: 1.5),
        ),
        title: Text(
          title,
          style: const TextStyle(color: Color(0xFFF0FDF4), fontSize: 18),
        ),
        content: Text(
          message,
          style: const TextStyle(color: Color(0xFFD4EDDA), fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(
              'OK',
              style: TextStyle(
                color: Color(0xFF7ED957),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
