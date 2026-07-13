import '../models/classification_phase_config.dart';
import '../models/organism_classification.dart';
import '../models/trophic_level.dart';

/// Builds [ClassificationPhaseConfig] instances.
///
/// Encapsulates the contextual decisions:
/// - expected trophic level per organism (may differ from seed value)
/// - top predator badge (absence in `source_id`)
/// - contextual justifications for ambiguous organisms
class ClassificationPhaseBuilder {
  const ClassificationPhaseBuilder();

  /// Creates the configuration for the Campo (field) biome.
  ///
  /// Uses the same direction rule as the database:
  /// `source_id = prey`, `target_id = predator`.
  ClassificationPhaseConfig buildCampo() {
    const organisms = <OrganismClassification>[
      // -- Capim (id 1) -------------------------------------------------------
      OrganismClassification(
        organismId: 1,
        expectedLevel: TrophicLevel.producer,
        isTopPredator: false,
        emoji: '🌿',
        displayName: 'Capim',
        justification:
            'O capim produz seu próprio alimento pela '
            'fotossíntese. Por isso, é a base da cadeia alimentar.',
        hintMessages: [
          'Este organismo produz o próprio alimento ou precisa comer '
              'outro ser vivo?',
          'O capim utiliza a luz do sol para produzir energia.',
          'Procure a zona dos produtores.',
        ],
      ),
      // -- Gafanhoto (id 2) --------------------------------------------------
      OrganismClassification(
        organismId: 2,
        expectedLevel: TrophicLevel.primaryConsumer,
        isTopPredator: false,
        emoji: '🦗',
        displayName: 'Gafanhoto',
        justification:
            'O gafanhoto se alimenta diretamente de plantas. '
            'Por isso, é um consumidor primário.',
        hintMessages: [
          'Este organismo come plantas ou come outros animais?',
          'O gafanhoto se alimenta diretamente de capim.',
          'Procure a zona dos consumidores primários.',
        ],
      ),
      // -- Coelho (id 3) ------------------------------------------------------
      OrganismClassification(
        organismId: 3,
        expectedLevel: TrophicLevel.primaryConsumer,
        isTopPredator: false,
        emoji: '🐇',
        displayName: 'Coelho',
        justification:
            'O coelho se alimenta de capim. Por isso, '
            'é um consumidor primário.',
        hintMessages: [
          'Este organismo come plantas ou come outros animais?',
          'O coelho se alimenta diretamente de capim.',
          'Procure a zona dos consumidores primários.',
        ],
      ),
      // -- Sapo (id 4) --------------------------------------------------------
      OrganismClassification(
        organismId: 4,
        expectedLevel: TrophicLevel.secondaryConsumer,
        isTopPredator: false,
        emoji: '🐸',
        displayName: 'Sapo',
        justification:
            'O sapo se alimenta de gafanhotos, que são '
            'consumidores primários. Por isso, é um consumidor secundário.',
        hintMessages: [
          'Do que este organismo se alimenta? E o que o animal que '
              'ele come, come?',
          'O sapo se alimenta de gafanhoto, que come capim.',
          'Procure a zona dos consumidores secundários.',
        ],
      ),
      // -- Cobra (id 5) -- contextual classification --------------------------
      OrganismClassification(
        organismId: 5,
        expectedLevel: TrophicLevel.tertiaryConsumer,
        isTopPredator: false,
        emoji: '🐍',
        displayName: 'Cobra',
        justification:
            'Nesta teia, a cobra come o sapo (consumidor '
            'secundário) e o coelho (consumidor primário). A classificação '
            'é contextual: em outra teia, a cobra poderia ocupar um nível '
            'diferente.',
        hintMessages: [
          'Observe o que a cobra come nesta teia do Campo.',
          'A cobra se alimenta de sapo e de coelho.',
          'Procure a zona dos consumidores terciários.',
        ],
      ),
      // -- Raposa (id 6) ------------------------------------------------------
      OrganismClassification(
        organismId: 6,
        expectedLevel: TrophicLevel.tertiaryConsumer,
        isTopPredator: true,
        emoji: '🦊',
        displayName: 'Raposa',
        justification:
            'A raposa come coelho (consumidor primário) e '
            'não é comida por nenhum outro organismo nesta teia. '
            'Por isso, é um predador de topo.',
        hintMessages: [
          'A raposa come plantas ou outros animais?',
          'A raposa se alimenta de coelho.',
          'Procure a zona dos consumidores terciários.',
        ],
      ),
      // -- Águia (id 7) -------------------------------------------------------
      OrganismClassification(
        organismId: 7,
        expectedLevel: TrophicLevel.tertiaryConsumer,
        isTopPredator: true,
        emoji: '🦅',
        displayName: 'Águia',
        justification:
            'A águia come coelho (consumidor primário) e '
            'cobra (consumidor terciário). Nenhum organismo nesta teia '
            'come a águia. Por isso, é um predador de topo.',
        hintMessages: [
          'A águia come plantas ou outros animais?',
          'A águia se alimenta de coelho e de cobra.',
          'Procure a zona dos consumidores terciários.',
        ],
      ),
    ];

    return ClassificationPhaseConfig(
      key: 'classification_field_01',
      biomePhaseId: 1,
      biomeName: 'Campo',
      organisms: organisms,
      learningMessages: [
        'A energia começa nos produtores, que fabricam seu próprio '
            'alimento usando a luz do sol.',
        'Os consumidores primários comem os produtores.',
        'Os consumidores secundários comem os primários.',
        'Os consumidores terciários estão no topo da cadeia alimentar '
            'desta teia.',
        'Um predador de topo é aquele que não possui predador '
            'dentro da teia observada.',
      ],
    );
  }

  /// Creates the configuration for the Floresta (forest) biome.
  ClassificationPhaseConfig buildFloresta() {
    const organisms = <OrganismClassification>[
      // -- Arbusto (id 8) ------------------------------------------------------
      OrganismClassification(
        organismId: 8,
        expectedLevel: TrophicLevel.producer,
        isTopPredator: false,
        emoji: '🌿',
        displayName: 'Arbusto',
        justification:
            'O arbusto produz seu próprio alimento pela '
            'fotossíntese. É a base da cadeia alimentar da floresta.',
        hintMessages: [
          'Este organismo produz o próprio alimento ou precisa '
              'comer outro ser vivo?',
          'O arbusto utiliza a luz do sol para produzir energia.',
          'Procure a zona dos produtores.',
        ],
      ),
      // -- Lagarta (id 9) ------------------------------------------------------
      OrganismClassification(
        organismId: 9,
        expectedLevel: TrophicLevel.primaryConsumer,
        isTopPredator: false,
        emoji: '🐛',
        displayName: 'Lagarta',
        justification:
            'A lagarta se alimenta diretamente de folhas do '
            'arbusto. Por isso, é um consumidor primário.',
        hintMessages: [
          'Este organismo come plantas ou come outros animais?',
          'A lagarta se alimenta de folhas do arbusto.',
          'Procure a zona dos consumidores primários.',
        ],
      ),
      // -- Veado (id 14) -------------------------------------------------------
      OrganismClassification(
        organismId: 14,
        expectedLevel: TrophicLevel.primaryConsumer,
        isTopPredator: false,
        emoji: '🦌',
        displayName: 'Veado',
        justification:
            'O veado se alimenta de arbustos e plantas. '
            'Por isso, é um consumidor primário.',
        hintMessages: [
          'Este organismo come plantas ou come outros animais?',
          'O veado se alimenta de plantas e arbustos.',
          'Procure a zona dos consumidores primários.',
        ],
      ),
      // -- Aranha (id 10) ------------------------------------------------------
      OrganismClassification(
        organismId: 10,
        expectedLevel: TrophicLevel.secondaryConsumer,
        isTopPredator: false,
        emoji: '🕷️',
        displayName: 'Aranha',
        justification:
            'A aranha se alimenta de lagartas, que são '
            'consumidores primários. Por isso, é um consumidor secundário.',
        hintMessages: [
          'Do que este organismo se alimenta?',
          'A aranha se alimenta de lagartas.',
          'Procure a zona dos consumidores secundários.',
        ],
      ),
      // -- Sapo (id 11) --------------------------------------------------------
      OrganismClassification(
        organismId: 11,
        expectedLevel: TrophicLevel.secondaryConsumer,
        isTopPredator: false,
        emoji: '🐸',
        displayName: 'Sapo',
        justification:
            'O sapo se alimenta de lagartas e aranhas, '
            'que são consumidores primários e secundários. '
            'Por isso, é um consumidor secundário.',
        hintMessages: [
          'Do que este organismo se alimenta?',
          'O sapo se alimenta de lagartas e aranhas.',
          'Procure a zona dos consumidores secundários.',
        ],
      ),
      // -- Cobra (id 12) -------------------------------------------------------
      OrganismClassification(
        organismId: 12,
        expectedLevel: TrophicLevel.tertiaryConsumer,
        isTopPredator: false,
        emoji: '🐍',
        displayName: 'Cobra',
        justification:
            'A cobra se alimenta do sapo (consumidor '
            'secundário). Por isso, é um consumidor terciário.',
        hintMessages: [
          'Observe o que a cobra come nesta teia da Floresta.',
          'A cobra se alimenta de sapo.',
          'Procure a zona dos consumidores terciários.',
        ],
      ),
      // -- Gavião (id 13) ------------------------------------------------------
      OrganismClassification(
        organismId: 13,
        expectedLevel: TrophicLevel.tertiaryConsumer,
        isTopPredator: true,
        emoji: '🦅',
        displayName: 'Gavião',
        justification:
            'O gavião come cobras e não é comido por '
            'nenhum outro organismo nesta teia. '
            'Por isso, é um predador de topo.',
        hintMessages: [
          'O gavião come plantas ou outros animais?',
          'O gavião se alimenta de cobras.',
          'Procure a zona dos consumidores terciários.',
        ],
      ),
      // -- Onça-pintada (id 15) ------------------------------------------------
      OrganismClassification(
        organismId: 15,
        expectedLevel: TrophicLevel.tertiaryConsumer,
        isTopPredator: true,
        emoji: '🐆',
        displayName: 'Onça-pintada',
        justification:
            'A onça-pintada come cobras e veados. '
            'Nenhum organismo nesta teia come a onça. '
            'Por isso, é um predador de topo.',
        hintMessages: [
          'A onça-pintada come plantas ou outros animais?',
          'A onça se alimenta de cobras e de veados.',
          'Procure a zona dos consumidores terciários.',
        ],
      ),
    ];

    return ClassificationPhaseConfig(
      key: 'classification_forest_01',
      biomePhaseId: 2,
      biomeName: 'Floresta',
      organisms: organisms,
      learningMessages: [
        'A energia começa nos produtores, que fabricam seu próprio '
            'alimento usando a luz do sol.',
        'Os consumidores primários comem os produtores.',
        'Os consumidores secundários comem os primários.',
        'Os consumidores terciários estão no topo da cadeia alimentar '
            'desta teia.',
        'Um predador de topo é aquele que não possui predador '
            'dentro da teia observada.',
      ],
    );
  }

  /// Creates the configuration for the Oceano (ocean) biome.
  ClassificationPhaseConfig buildOceano() {
    const organisms = <OrganismClassification>[
      // -- Fitoplâncton (id 16) ------------------------------------------------
      OrganismClassification(
        organismId: 16,
        expectedLevel: TrophicLevel.producer,
        isTopPredator: false,
        emoji: '🦠',
        displayName: 'Fitoplâncton',
        justification:
            'O fitoplâncton produz seu próprio alimento '
            'através da fotossíntese. É a base da cadeia alimentar '
            'marinha.',
        hintMessages: [
          'Este organismo produz o próprio alimento ou '
              'precisa comer outro ser vivo?',
          'O fitoplâncton utiliza a luz do sol para produzir energia.',
          'Procure a zona dos produtores.',
        ],
      ),
      // -- Alga (id 17) --------------------------------------------------------
      OrganismClassification(
        organismId: 17,
        expectedLevel: TrophicLevel.producer,
        isTopPredator: false,
        emoji: '🌿',
        displayName: 'Alga',
        justification:
            'A alga produz seu próprio alimento pela '
            'fotossíntese. É uma produtora na cadeia marinha.',
        hintMessages: [
          'Este organismo produz o próprio alimento ou '
              'precisa comer outro ser vivo?',
          'A alga utiliza a luz do sol para produzir energia.',
          'Procure a zona dos produtores.',
        ],
      ),
      // -- Camarão (id 18) -----------------------------------------------------
      OrganismClassification(
        organismId: 18,
        expectedLevel: TrophicLevel.primaryConsumer,
        isTopPredator: false,
        emoji: '🦐',
        displayName: 'Camarão',
        justification:
            'O camarão se alimenta de fitoplâncton e '
            'algas. Por isso, é um consumidor primário.',
        hintMessages: [
          'Este organismo come plantas ou come outros animais?',
          'O camarão se alimenta de fitoplâncton e algas.',
          'Procure a zona dos consumidores primários.',
        ],
      ),
      // -- Sardinha (id 19) ----------------------------------------------------
      OrganismClassification(
        organismId: 19,
        expectedLevel: TrophicLevel.secondaryConsumer,
        isTopPredator: false,
        emoji: '🐟',
        displayName: 'Sardinha',
        justification:
            'A sardinha se alimenta de camarão, que é um '
            'consumidor primário. Por isso, é um consumidor secundário.',
        hintMessages: [
          'Do que este organismo se alimenta?',
          'A sardinha se alimenta de camarão.',
          'Procure a zona dos consumidores secundários.',
        ],
      ),
      // -- Polvo (id 20) -------------------------------------------------------
      OrganismClassification(
        organismId: 20,
        expectedLevel: TrophicLevel.tertiaryConsumer,
        isTopPredator: false,
        emoji: '🐙',
        displayName: 'Polvo',
        justification:
            'O polvo se alimenta de camarão e sardinha. '
            'Por isso, é um consumidor terciário.',
        hintMessages: [
          'Do que este organismo se alimenta?',
          'O polvo se alimenta de camarão e sardinha.',
          'Procure a zona dos consumidores terciários.',
        ],
      ),
      // -- Atum (id 21) --------------------------------------------------------
      OrganismClassification(
        organismId: 21,
        expectedLevel: TrophicLevel.tertiaryConsumer,
        isTopPredator: false,
        emoji: '🐠',
        displayName: 'Atum',
        justification:
            'O atum se alimenta de sardinha, que é um '
            'consumidor secundário. Por isso, é um consumidor terciário.',
        hintMessages: [
          'Do que este organismo se alimenta?',
          'O atum se alimenta de sardinha.',
          'Procure a zona dos consumidores terciários.',
        ],
      ),
      // -- Tubarão (id 22) -----------------------------------------------------
      OrganismClassification(
        organismId: 22,
        expectedLevel: TrophicLevel.tertiaryConsumer,
        isTopPredator: true,
        emoji: '🦈',
        displayName: 'Tubarão',
        justification:
            'O tubarão come atum e polvo. Nenhum '
            'organismo nesta teia come o tubarão. '
            'Por isso, é um predador de topo.',
        hintMessages: [
          'O tubarão come plantas ou outros animais?',
          'O tubarão se alimenta de atum e de polvo.',
          'Procure a zona dos consumidores terciários.',
        ],
      ),
    ];

    return ClassificationPhaseConfig(
      key: 'classification_ocean_01',
      biomePhaseId: 3,
      biomeName: 'Oceano',
      organisms: organisms,
      learningMessages: [
        'A energia começa nos produtores, que fabricam seu próprio '
            'alimento usando a luz do sol.',
        'Os consumidores primários comem os produtores.',
        'Os consumidores secundários comem os primários.',
        'Os consumidores terciários estão no topo da cadeia alimentar '
            'desta teia.',
        'Um predador de topo é aquele que não possui predador '
            'dentro da teia observada.',
      ],
    );
  }

  /// Creates the configuration for the Pantanal biome.
  ClassificationPhaseConfig buildPantanal() {
    const organisms = <OrganismClassification>[
      // -- Planta aquática (id 23) ---------------------------------------------
      OrganismClassification(
        organismId: 23,
        expectedLevel: TrophicLevel.producer,
        isTopPredator: false,
        emoji: '🌱',
        displayName: 'Planta aquática',
        justification:
            'A planta aquática produz seu próprio alimento '
            'pela fotossíntese. É a base da cadeia alimentar do pantanal.',
        hintMessages: [
          'Este organismo produz o próprio alimento ou '
              'precisa comer outro ser vivo?',
          'A planta aquática utiliza a luz do sol para produzir energia.',
          'Procure a zona dos produtores.',
        ],
      ),
      // -- Caramujo (id 24) ----------------------------------------------------
      OrganismClassification(
        organismId: 24,
        expectedLevel: TrophicLevel.primaryConsumer,
        isTopPredator: false,
        emoji: '🐌',
        displayName: 'Caramujo',
        justification:
            'O caramujo se alimenta de plantas aquáticas. '
            'Por isso, é um consumidor primário.',
        hintMessages: [
          'Este organismo come plantas ou come outros animais?',
          'O caramujo se alimenta de plantas aquáticas.',
          'Procure a zona dos consumidores primários.',
        ],
      ),
      // -- Peixe (id 25) -------------------------------------------------------
      OrganismClassification(
        organismId: 25,
        expectedLevel: TrophicLevel.secondaryConsumer,
        isTopPredator: false,
        emoji: '🐟',
        displayName: 'Peixe',
        justification:
            'O peixe se alimenta de plantas aquáticas e '
            'caramujos. Por isso, é um consumidor secundário.',
        hintMessages: [
          'Do que este organismo se alimenta?',
          'O peixe se alimenta de plantas e de caramujos.',
          'Procure a zona dos consumidores secundários.',
        ],
      ),
      // -- Garça (id 26) -------------------------------------------------------
      OrganismClassification(
        organismId: 26,
        expectedLevel: TrophicLevel.tertiaryConsumer,
        isTopPredator: false,
        emoji: '🦅',
        displayName: 'Garça',
        justification:
            'A garça se alimenta de peixes, que são '
            'consumidores secundários. Por isso, é um consumidor terciário.',
        hintMessages: [
          'Do que este organismo se alimenta?',
          'A garça se alimenta de peixes.',
          'Procure a zona dos consumidores terciários.',
        ],
      ),
      // -- Jacaré (id 27) ------------------------------------------------------
      OrganismClassification(
        organismId: 27,
        expectedLevel: TrophicLevel.tertiaryConsumer,
        isTopPredator: false,
        emoji: '🐊',
        displayName: 'Jacaré',
        justification:
            'O jacaré se alimenta de peixes, que são '
            'consumidores secundários. Por isso, é um consumidor terciário.',
        hintMessages: [
          'Do que este organismo se alimenta?',
          'O jacaré se alimenta de peixes.',
          'Procure a zona dos consumidores terciários.',
        ],
      ),
      // -- Cobra sucuri (id 28) ------------------------------------------------
      OrganismClassification(
        organismId: 28,
        expectedLevel: TrophicLevel.tertiaryConsumer,
        isTopPredator: true,
        emoji: '🐍',
        displayName: 'Cobra sucuri',
        justification:
            'A cobra sucuri come peixes e jacarés. '
            'Nenhum organismo nesta teia come a sucuri. '
            'Por isso, é um predador de topo.',
        hintMessages: [
          'A cobra sucuri come plantas ou outros animais?',
          'A cobra sucuri se alimenta de peixes e jacarés.',
          'Procure a zona dos consumidores terciários.',
        ],
      ),
      // -- Onça-pintada (id 29) ------------------------------------------------
      OrganismClassification(
        organismId: 29,
        expectedLevel: TrophicLevel.tertiaryConsumer,
        isTopPredator: true,
        emoji: '🐆',
        displayName: 'Onça-pintada',
        justification:
            'A onça-pintada come garças e jacarés. '
            'Nenhum organismo nesta teia come a onça. '
            'Por isso, é um predador de topo.',
        hintMessages: [
          'A onça-pintada come plantas ou outros animais?',
          'A onça se alimenta de garças e jacarés.',
          'Procure a zona dos consumidores terciários.',
        ],
      ),
    ];

    return ClassificationPhaseConfig(
      key: 'classification_pantanal_01',
      biomePhaseId: 4,
      biomeName: 'Pantanal',
      organisms: organisms,
      learningMessages: [
        'A energia começa nos produtores, que fabricam seu próprio '
            'alimento usando a luz do sol.',
        'Os consumidores primários comem os produtores.',
        'Os consumidores secundários comem os primários.',
        'Os consumidores terciários estão no topo da cadeia alimentar '
            'desta teia.',
        'Um predador de topo é aquele que não possui predador '
            'dentro da teia observada.',
      ],
    );
  }

  /// Calculates top predator status from phase connections.
  ///
  /// A top predator is a consumer that never appears as prey
  /// (absence in `source_id`) within the given connections.
  /// Producers never receive the badge.
  ///
  /// [organismIdsConsumed] = set of `source_id` values from the phase
  /// connections (the organisms that are eaten).
  /// [organismId] = the organism being evaluated.
  /// [isConsumer] = whether the organism is a consumer (not a producer).
  bool computeTopPredator({
    required Set<int> organismIdsConsumed,
    required int organismId,
    required bool isConsumer,
  }) {
    if (!isConsumer) return false;
    return !organismIdsConsumed.contains(organismId);
  }
}
