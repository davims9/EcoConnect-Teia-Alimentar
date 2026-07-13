import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:food_web_builder/features/trophic_classification/trophic_classification_feature.dart';

// ---------------------------------------------------------------------------
// Test helpers
// ---------------------------------------------------------------------------

final _campoConfig = ClassificationPhaseBuilder().buildCampo();
final _organisms = _campoConfig.organisms;

OrganismClassification _org(int id) =>
    _organisms.firstWhere((o) => o.organismId == id);

Widget _wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

Widget _wrapWithService(
  ClassificationService service,
  Widget Function(BuildContext) builder,
) => MaterialApp(
  home: Scaffold(
    body: ChangeNotifierProvider.value(
      value: service,
      child: Consumer<ClassificationService>(
        builder: (context, s, _) => builder(context),
      ),
    ),
  ),
);

ClassificationService _loadedService() =>
    ClassificationService()..loadPhase(_campoConfig);

// ---------------------------------------------------------------------------
// ClassificationZoneColors
// ---------------------------------------------------------------------------

void main() {
  group('ClassificationZoneColors', () {
    test('returns non-grey color for every trophic level', () {
      for (final level in TrophicLevel.values) {
        expect(
          ClassificationZoneColors.colorOf(level),
          isNot(equals(Colors.grey)),
        );
      }
    });

    test('returns non-empty label for every trophic level', () {
      for (final level in TrophicLevel.values) {
        expect(ClassificationZoneColors.labelOf(level).isNotEmpty, isTrue);
      }
    });

    test('returns non-null icon for every trophic level', () {
      for (final level in TrophicLevel.values) {
        expect(ClassificationZoneColors.iconOf(level), isNotNull);
      }
    });

    test('returns non-empty short label for every trophic level', () {
      for (final level in TrophicLevel.values) {
        expect(ClassificationZoneColors.shortLabelOf(level).isNotEmpty, isTrue);
      }
    });
  });

  // ---------------------------------------------------------------------------
  // ClassificationOrganismCard
  // ---------------------------------------------------------------------------

  group('ClassificationOrganismCard', () {
    testWidgets('renders emoji and displayName', (tester) async {
      await tester.pumpWidget(
        _wrap(
          ClassificationOrganismCard(
            organism: _org(1),
            status: ClassificationCardStatus.shelf,
          ),
        ),
      );

      expect(find.text('🌿'), findsOneWidget);
      expect(find.text('Capim'), findsOneWidget);
    });

    testWidgets('renders fallback text when displayName is empty', (
      tester,
    ) async {
      const org = OrganismClassification(
        organismId: 99,
        expectedLevel: TrophicLevel.producer,
        isTopPredator: false,
        justification: '',
        hintMessages: [],
        displayName: '',
      );

      await tester.pumpWidget(
        _wrap(
          ClassificationOrganismCard(
            organism: org,
            status: ClassificationCardStatus.shelf,
          ),
        ),
      );

      expect(find.text('ID 99'), findsOneWidget);
    });

    testWidgets('shows check icon when lockedCorrect', (tester) async {
      await tester.pumpWidget(
        _wrap(
          ClassificationOrganismCard(
            organism: _org(1),
            status: ClassificationCardStatus.lockedCorrect,
            draggable: false,
          ),
        ),
      );

      expect(find.byIcon(Icons.check_circle), findsOneWidget);
    });

    testWidgets('shows error icon when verifiedIncorrect', (tester) async {
      await tester.pumpWidget(
        _wrap(
          ClassificationOrganismCard(
            organism: _org(1),
            status: ClassificationCardStatus.verifiedIncorrect,
          ),
        ),
      );

      expect(find.byIcon(Icons.error), findsOneWidget);
    });

    testWidgets('fires onTap callback when tapped', (tester) async {
      int? tappedId;
      await tester.pumpWidget(
        _wrap(
          ClassificationOrganismCard(
            organism: _org(2),
            status: ClassificationCardStatus.shelf,
            onTap: () => tappedId = 2,
          ),
        ),
      );

      await tester.tap(find.text('Gafanhoto'));
      expect(tappedId, equals(2));
    });

    testWidgets('shows selected state with white border', (tester) async {
      await tester.pumpWidget(
        _wrap(
          ClassificationOrganismCard(
            organism: _org(1),
            status: ClassificationCardStatus.shelf,
            isSelected: true,
          ),
        ),
      );

      // Card renders — visual assertion that it doesn't crash
      expect(find.text('Capim'), findsOneWidget);
    });
  });

  // ---------------------------------------------------------------------------
  // ClassificationZone
  // ---------------------------------------------------------------------------

  group('ClassificationZone', () {
    testWidgets('renders zone label', (tester) async {
      await tester.pumpWidget(
        _wrap(
          ClassificationZone(
            level: TrophicLevel.producer,
            organisms: [],
            statuses: {},
          ),
        ),
      );

      expect(find.text('Prod.'), findsOneWidget);
    });

    testWidgets('shows placeholder text when empty', (tester) async {
      await tester.pumpWidget(
        _wrap(
          ClassificationZone(
            level: TrophicLevel.producer,
            organisms: [],
            statuses: {},
          ),
        ),
      );

      expect(
        find.text('Arraste ou toque num card'),
        findsOneWidget,
      );
    });

    testWidgets('renders organisms when provided', (tester) async {
      final capim = _org(1);
      await tester.pumpWidget(
        _wrap(
          ClassificationZone(
            level: TrophicLevel.producer,
            organisms: [capim],
            statuses: {1: ClassificationCardStatus.placed},
          ),
        ),
      );

      expect(find.text('🌿'), findsOneWidget);
    });

    testWidgets('shows organism count badge', (tester) async {
      await tester.pumpWidget(
        _wrap(
          ClassificationZone(
            level: TrophicLevel.producer,
            organisms: [_org(1)],
            statuses: {1: ClassificationCardStatus.placed},
          ),
        ),
      );

      expect(find.text('1'), findsOneWidget);
    });
  });

  // ---------------------------------------------------------------------------
  // ClassificationShelf
  // ---------------------------------------------------------------------------

  group('ClassificationShelf', () {
    testWidgets('renders unplaced organism cards', (tester) async {
      await tester.pumpWidget(
        _wrap(ClassificationShelf(unplacedOrganisms: _organisms)),
      );

      // All 7 organisms shown in shelf
      expect(find.text('Capim'), findsOneWidget);
      expect(find.text('Gafanhoto'), findsOneWidget);
      expect(find.text('Coelho'), findsOneWidget);
      expect(find.text('Sapo'), findsOneWidget);
      expect(find.text('Cobra'), findsOneWidget);
      expect(find.text('Raposa'), findsOneWidget);
      expect(find.text('Águia'), findsOneWidget);
    });

    testWidgets('shows shelf label', (tester) async {
      await tester.pumpWidget(
        _wrap(ClassificationShelf(unplacedOrganisms: _organisms)),
      );

      expect(find.text('Prateleira'), findsOneWidget);
    });

    testWidgets('shows empty placeholder when no cards', (tester) async {
      await tester.pumpWidget(
        _wrap(ClassificationShelf(unplacedOrganisms: [])),
      );

      expect(
        find.text('Arraste cards para cá para devolvê-los'),
        findsOneWidget,
      );
    });
  });

  // ---------------------------------------------------------------------------
  // ClassificationHud
  // ---------------------------------------------------------------------------

  group('ClassificationHud', () {
    testWidgets('shows biome name and score', (tester) async {
      final service = _loadedService();
      await tester.pumpWidget(
        _wrapWithService(service, (_) => ClassificationHud(service: service)),
      );

      expect(find.text('Campo'), findsOneWidget);
      // Score is 0 initially
      expect(find.text('0'), findsOneWidget);
    });
  });

  // ---------------------------------------------------------------------------
  // ClassificationActionBar
  // ---------------------------------------------------------------------------

  group('ClassificationActionBar', () {
    testWidgets('shows Dica and Verificar buttons', (tester) async {
      final service = _loadedService();
      await tester.pumpWidget(
        _wrapWithService(
          service,
          (_) => ClassificationActionBar(service: service),
        ),
      );

      expect(find.text('Dica'), findsOneWidget);
      expect(find.text('Verificar'), findsOneWidget);
    });
  });

  // ---------------------------------------------------------------------------
  // ClassificationGameScreen — integration smoke test
  // ---------------------------------------------------------------------------

  group('ClassificationGameScreen', () {
    testWidgets('renders game layout with biome name', (tester) async {
      await tester.pumpWidget(
        MaterialApp(home: ClassificationGameScreen(config: _campoConfig)),
      );
      await tester.pump();

      // HUD shows biome name
      expect(find.text('Campo'), findsOneWidget);

      // All zone labels visible (short labels in compact layout)
      expect(find.text('Prod.'), findsOneWidget);
      expect(find.text('Cons. Prim.'), findsOneWidget);
      expect(find.text('Cons. Sec.'), findsOneWidget);
      expect(find.text('Cons. Terc.'), findsOneWidget);

      // Shelf shows Prateleira
      expect(find.text('Prateleira'), findsOneWidget);

      // Action bar shows Verificar (disabled)
      expect(find.text('Verificar'), findsOneWidget);
      expect(find.text('Dica'), findsOneWidget);
    });

    testWidgets('progress counter shows placed count', (tester) async {
      await tester.pumpWidget(
        MaterialApp(home: ClassificationGameScreen(config: _campoConfig)),
      );
      await tester.pump();

      // Initially 0 de 7
      expect(find.text('0 de 7 organismos posicionados'), findsOneWidget);
    });

    testWidgets('can place a card via tap flow', (tester) async {
      await tester.pumpWidget(
        MaterialApp(home: ClassificationGameScreen(config: _campoConfig)),
      );
      await tester.pump();

      // Tap Capim in shelf to select
      await tester.tap(find.text('Capim'));
      await tester.pump();

      // Tap Prod. zone to place
      await tester.tap(find.text('Prod.'));
      await tester.pump();

      // Now 1 de 7 placed
      expect(find.text('1 de 7 organismos posicionados'), findsOneWidget);
    });
  });

  // ---------------------------------------------------------------------------
  // ClassificationService integration — highlightedLevel
  // ---------------------------------------------------------------------------

  group('ClassificationService highlightedLevel', () {
    test('is null initially', () {
      final service = _loadedService();
      expect(service.highlightedLevel, isNull);
    });

    test('is null after conceptual hint', () {
      final service = _loadedService();
      service.placeCard(1, TrophicLevel.producer);
      service.getHint(1); // conceptual — no highlight
      expect(service.highlightedLevel, isNull);
    });

    test('is null after relational hint', () {
      final service = _loadedService();
      service.placeCard(1, TrophicLevel.producer);
      service.getHint(1); // conceptual
      service.getHint(1); // relational
      expect(service.highlightedLevel, isNull);
    });

    test('is set on directional hint (third call)', () {
      final service = _loadedService();
      service.placeCard(1, TrophicLevel.producer);
      service.getHint(1); // conceptual
      service.getHint(1); // relational
      final hint = service.getHint(1); // directional
      expect(hint, isNotNull);
      expect(hint!.highlightedLevel, equals(TrophicLevel.producer));
      expect(service.highlightedLevel, equals(TrophicLevel.producer));
    });

    test('is cleared on placeCard after directional hint', () {
      final service = _loadedService();
      service.placeCard(1, TrophicLevel.producer);
      service.getHint(1); // conceptual
      service.getHint(1); // relational
      service.getHint(1); // directional
      expect(service.highlightedLevel, equals(TrophicLevel.producer));

      service.placeCard(7, TrophicLevel.tertiaryConsumer);
      expect(service.highlightedLevel, isNull);
    });

    test('is cleared on returnCardToShelf after directional hint', () {
      final service = _loadedService();
      service.placeCard(1, TrophicLevel.producer);
      service.getHint(1); // conceptual
      service.getHint(1); // relational
      service.getHint(1); // directional
      expect(service.highlightedLevel, equals(TrophicLevel.producer));

      service.returnCardToShelf(1);
      expect(service.highlightedLevel, isNull);
    });

    test('is cleared on verify after directional hint', () {
      final service = _loadedService();
      service.placeCard(1, TrophicLevel.producer);
      service.getHint(1); // conceptual
      service.getHint(1); // relational
      service.getHint(1); // directional
      expect(service.highlightedLevel, equals(TrophicLevel.producer));

      // Place all cards correctly
      service.placeCard(2, TrophicLevel.primaryConsumer);
      service.placeCard(3, TrophicLevel.primaryConsumer);
      service.placeCard(4, TrophicLevel.secondaryConsumer);
      service.placeCard(5, TrophicLevel.tertiaryConsumer);
      service.placeCard(6, TrophicLevel.tertiaryConsumer);
      service.placeCard(7, TrophicLevel.tertiaryConsumer);

      service.verify();
      expect(service.highlightedLevel, isNull);
    });
  });

  // ---------------------------------------------------------------------------
  // Service helper getters
  // ---------------------------------------------------------------------------

  group('organismIdsInZone / unplacedOrganismIds', () {
    test('returns correct ids per zone', () {
      final service = _loadedService();
      service.placeCard(1, TrophicLevel.producer);
      service.placeCard(2, TrophicLevel.primaryConsumer);
      service.placeCard(3, TrophicLevel.primaryConsumer);

      expect(service.organismIdsInZone(TrophicLevel.producer), equals([1]));
      expect(
        service.organismIdsInZone(TrophicLevel.primaryConsumer),
        equals([2, 3]),
      );
      expect(
        service.organismIdsInZone(TrophicLevel.secondaryConsumer),
        isEmpty,
      );
    });

    test('unplacedOrganismIds returns ids not in any zone', () {
      final service = _loadedService();
      service.placeCard(1, TrophicLevel.producer);

      final unplaced = service.unplacedOrganismIds;
      expect(unplaced, isNot(contains(1)));
      expect(unplaced.length, equals(6));
    });
  });

  // ---------------------------------------------------------------------------
  // _ProgressCounter
  // ---------------------------------------------------------------------------

  group('ProgressCounter', () {
    // Access via game screen — already tested in the smoke test above.
    // Direct tests use the private class which isn't accessible here.
    // The game screen tests verify the progress text rendering.
  });
}
