import 'package:flutter_test/flutter_test.dart';
import 'package:food_web_builder/features/trophic_classification/services/classification_phase_builder.dart';

/// Campo phase 1 connections (source_id = prey, target_id = predator):
///   Capim(1) → Gafanhoto(2)
///   Capim(1) → Coelho(3)
///   Gafanhoto(2) → Sapo(4)
///   Coelho(3) → Cobra(5)
///   Coelho(3) → Raposa(6)
///   Coelho(3) → Águia(7)
///   Sapo(4) → Cobra(5)
///   Cobra(5) → Águia(7)
///
/// preyIds (source_id) = {1, 2, 3, 4, 5}
/// consumer ids: 2(Gafanhoto), 3(Coelho), 4(Sapo), 5(Cobra), 6(Raposa), 7(Águia)
/// producer ids: 1(Capim)
///
/// Top predators = consumers NOT in preyIds → 6(Raposa), 7(Águia)
void main() {
  final builder = ClassificationPhaseBuilder();

  // All source_id values from Campo connections.
  final campoPreyIds = <int>{1, 2, 3, 4, 5};

  group('Top predator calculation — Campo phase', () {
    test('Raposa (id 6) is top predator (consumer, not in preyIds)', () {
      expect(
        builder.computeTopPredator(
          organismIdsConsumed: campoPreyIds,
          organismId: 6,
          isConsumer: true,
        ),
        isTrue,
      );
    });

    test('Águia (id 7) is top predator (consumer, not in preyIds)', () {
      expect(
        builder.computeTopPredator(
          organismIdsConsumed: campoPreyIds,
          organismId: 7,
          isConsumer: true,
        ),
        isTrue,
      );
    });

    test('Coelho (id 3) is NOT top predator (appears in preyIds)', () {
      expect(
        builder.computeTopPredator(
          organismIdsConsumed: campoPreyIds,
          organismId: 3,
          isConsumer: true,
        ),
        isFalse,
      );
    });

    test('Cobra (id 5) is NOT top predator (appears as prey of Águia)', () {
      expect(
        builder.computeTopPredator(
          organismIdsConsumed: campoPreyIds,
          organismId: 5,
          isConsumer: true,
        ),
        isFalse,
      );
    });

    test('Capim (id 1) is never top predator (producer)', () {
      expect(
        builder.computeTopPredator(
          organismIdsConsumed: campoPreyIds,
          organismId: 1,
          isConsumer: false,
        ),
        isFalse,
      );
    });

    test('Gafanhoto (id 2) is NOT top predator (appears in preyIds)', () {
      expect(
        builder.computeTopPredator(
          organismIdsConsumed: campoPreyIds,
          organismId: 2,
          isConsumer: true,
        ),
        isFalse,
      );
    });

    test('Sapo (id 4) is NOT top predator (appears in preyIds)', () {
      expect(
        builder.computeTopPredator(
          organismIdsConsumed: campoPreyIds,
          organismId: 4,
          isConsumer: true,
        ),
        isFalse,
      );
    });

    test('Consumer not in preyIds is top predator (edge case)', () {
      expect(
        builder.computeTopPredator(
          organismIdsConsumed: <int>{1, 2, 3},
          organismId: 99,
          isConsumer: true,
        ),
        isTrue,
      );
    });

    test('Empty preyIds makes all consumers top predators', () {
      expect(
        builder.computeTopPredator(
          organismIdsConsumed: <int>{},
          organismId: 6,
          isConsumer: true,
        ),
        isTrue,
      );
    });
  });
}
