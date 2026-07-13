# Plano Técnico — Modo Classificação por Níveis Tróficos

> **Data:** Julho de 2026  
> **Versão:** 1.1 — Revisado  
> **Base:** `01-current-data-audit.md` e `02-game-design-spec.md`

---

## 1. Decisões principais

| Tema | Decisão |
|---|---|
| Arquitetura | Feature isolada em `lib/features/trophic_classification/` |
| Renderização | Flutter puro |
| Estado | `ClassificationService` dedicado e escopado ao fluxo |
| Validação | Em lote, após todos os cards serem posicionados |
| Persistência | Repositório e tabela próprios |
| Identidade da fase | Chave própria de classificação, além do bioma compartilhado |
| Predador de topo | Selo contextual calculado por ausência em `source_id` |
| Organismos ambíguos | `expectedLevel` definido por fase |
| Timer | Fora do MVP |
| Partículas | Fora do MVP inicial |

---

## 2. Comparação arquitetural

### Opção A — Feature isolada

```text
lib/features/trophic_classification/
  models/
  repositories/
  services/
  screens/
  widgets/
```

**Prós**

- separação clara;
- reduz risco de condicionais no modo atual;
- facilita testes;
- estado e persistência independentes;
- crescimento futuro controlado.

**Contras**

- introduz uma convenção nova no repositório;
- widgets compartilhados precisam ser extraídos de forma explícita.

### Opção B — Integração nas pastas atuais

```text
lib/screens/
lib/widgets/
lib/services/
lib/models/
```

**Prós**

- mantém a organização atual;
- descoberta imediata para quem já conhece o projeto.

**Contras**

- mistura dois domínios;
- aumenta risco de ampliar `GameService` e `GameScreen`;
- dificulta distinguir componentes compartilhados dos exclusivos.

### Recomendação

Adotar a **Opção A**. O novo modo possui regras, estado, pontuação e persistência próprios, o que justifica isolamento por feature.

---

## 3. Flutter puro, Flame ou híbrido

| Abordagem | Avaliação |
|---|---|
| Flame puro | Não recomendado: não há necessidade de game loop, câmera ou física |
| Híbrido | Complexidade sem benefício claro para o MVP |
| Flutter puro | Recomendado: melhor para layout, rolagem, acessibilidade e testes |

Tecnologias previstas:

- `Draggable`;
- `DragTarget`;
- `AnimatedContainer`;
- `AnimatedSwitcher`;
- `ListView`;
- `CustomScrollView` ou `SingleChildScrollView`;
- `Provider`/`ChangeNotifier`;
- sem dependência nova.

`AnimatedPositioned` só deve ser usado caso a tela adote explicitamente um `Stack`.

---

## 4. Estrutura proposta

```text
lib/
└── features/
    └── trophic_classification/
        ├── models/
        │   ├── trophic_level.dart
        │   ├── classification_phase_config.dart
        │   ├── organism_classification.dart
        │   ├── classification_hint.dart
        │   ├── classification_result.dart
        │   └── classification_score.dart
        ├── repositories/
        │   └── classification_score_repository.dart
        ├── services/
        │   ├── classification_service.dart
        │   ├── classification_scoring.dart
        │   └── classification_phase_builder.dart
        ├── screens/
        │   ├── classification_phases_screen.dart
        │   ├── classification_intro_screen.dart
        │   └── classification_game_screen.dart
        ├── widgets/
        │   ├── classification_zone.dart
        │   ├── classification_organism_card.dart
        │   ├── classification_shelf.dart
        │   ├── classification_hud.dart
        │   ├── classification_result_modal.dart
        │   ├── classification_hint_panel.dart
        │   └── classification_action_bar.dart
        └── trophic_classification_feature.dart
```

Compartilhados fora da feature:

```text
lib/widgets/shared/
  hud_card.dart
  eco_back_button.dart
```

A extração de átomos do HUD deve ocorrer em etapa própria e preservar integralmente o modo Teia.

---

## 5. Modelos

### 5.1 `TrophicLevel`

```dart
enum TrophicLevel {
  producer,
  primaryConsumer,
  secondaryConsumer,
  tertiaryConsumer,
}
```

O enum não armazena:

- cores;
- textos de UI;
- ícones;
- valores HEX.

Mapeamentos visuais ficam na camada de tema/apresentação.

### 5.2 Configuração de fase

```dart
class ClassificationPhaseConfig {
  final String key;
  final int biomePhaseId;
  final String biomeName;
  final List<OrganismClassification> organisms;
  final List<String> learningMessages;
}
```

### 5.3 Organismo contextual

```dart
class OrganismClassification {
  final int organismId;
  final TrophicLevel expectedLevel;
  final bool isTopPredator;
  final String justification;
  final List<String> hintMessages;
}
```

O nível esperado é contextual à fase e não precisa coincidir automaticamente com a string global do seed.

### 5.4 Estado do card

```dart
enum ClassificationCardStatus {
  shelf,
  placed,
  verifiedCorrect,
  verifiedIncorrect,
  lockedCorrect,
}
```

---

## 6. Cálculo de predador de topo

Como o banco usa:

```text
source_id = presa/alimento
target_id = predador/consumidor
```

o cálculo correto é:

```dart
final preyIds = phaseConnections
    .map((connection) => connection.sourceId)
    .toSet();

final isTopPredator =
    organismIsConsumer &&
    !preyIds.contains(organism.id);
```

Restrições:

- considerar somente relações incluídas na configuração da fase;
- nunca aplicar o selo a produtores;
- não usar ausência em `target_id`;
- permitir override explícito na configuração da fase em caso de ambiguidade pedagógica.

Testes obrigatórios:

- Raposa e Águia do Campo resultam em topo;
- Coelho não resulta em topo;
- Cobra não resulta em topo porque aparece como presa da Águia;
- produtor nunca resulta em topo.

---

## 7. Serviço de classificação

### `ClassificationService`

Responsabilidades:

- carregar configuração da fase;
- manter posições dos cards;
- mover card para zona;
- devolver card à prateleira;
- informar se todos estão posicionados;
- validar em lote;
- bloquear acertos;
- gerar dica gradual;
- controlar tentativas;
- calcular pontuação;
- produzir resultado final;
- persistir somente por meio do repositório dedicado.

Não deve:

- importar `GameService`;
- alterar conexões do modo Teia;
- controlar timer no MVP;
- conhecer cores;
- conhecer widgets;
- fazer acesso SQL diretamente.

Escopo recomendado:

```dart
ChangeNotifierProvider(
  create: (_) => ClassificationService(...),
  child: const ClassificationFlow(),
)
```

O provider deve ser criado no início do fluxo de classificação, não globalmente em `main.dart`, salvo necessidade concreta futura.

---

## 8. Validação

### 8.1 Condição do botão

```dart
bool get canVerify => placedCount == totalOrganisms;
```

O botão não deve ficar ativo com apenas um card posicionado.

### 8.2 Resultado

```dart
class ClassificationVerificationResult {
  final Set<int> correctIds;
  final Set<int> incorrectIds;
  final bool isComplete;
}
```

O resultado não precisa revelar a zona correta de todos os erros na primeira verificação.

### 8.3 Nova tentativa

- corretos ficam bloqueados;
- incorretos voltam à prateleira ou permanecem editáveis, conforme teste de UX;
- pontuação considera a tentativa em que cada organismo foi confirmado;
- a fase termina em 100%.

---

## 9. Dicas graduais

```dart
enum HintLevel {
  conceptual,
  relational,
  directional,
}
```

```dart
class ClassificationHint {
  final int organismId;
  final HintLevel level;
  final String message;
  final TrophicLevel? highlightedLevel;
}
```

Regras:

- nível 1 não destaca zona;
- nível 2 explica uma relação alimentar;
- nível 3 pode destacar zona;
- o serviço registra o maior nível de dica usado por organismo;
- a pontuação aplica penalidade proporcional.

---

## 10. Pontuação e estrelas

### 10.1 Implementação corrigida

```dart
class ClassificationScoring {
  static const int firstTryPoints = 100;
  static const int laterTryPoints = 50;
  static const int wrongPlacementPenalty = 10;
  static const int conceptualHintPenalty = 2;
  static const int relationalHintPenalty = 5;
  static const int directionalHintPenalty = 10;

  int calculateScore({
    required int firstTryCorrectCount,
    required int laterTryCorrectCount,
    required int wrongPlacements,
    required int conceptualHints,
    required int relationalHints,
    required int directionalHints,
  }) {
    final rawScore =
        firstTryCorrectCount * firstTryPoints +
        laterTryCorrectCount * laterTryPoints -
        wrongPlacements * wrongPlacementPenalty -
        conceptualHints * conceptualHintPenalty -
        relationalHints * relationalHintPenalty -
        directionalHints * directionalHintPenalty;

    return rawScore < 0 ? 0 : rawScore;
  }

  int calculateStars({
    required int score,
    required int maxScore,
  }) {
    if (maxScore <= 0) return 1;

    final ratio = score / maxScore;

    if (ratio >= 0.85) return 3;
    if (ratio >= 0.60) return 2;
    return 1;
  }
}
```

Não reutilizar `ScoringService.calculateStars()` sem adaptação, pois a fase sempre termina com 100% dos cards corretos.

---

## 11. Persistência

### 11.1 Identidade da fase

Não usar apenas `phases.id` como identidade eterna do modo classificação.

Cada configuração deve possuir uma chave própria:

```text
classification_field_01
classification_forest_01
```

O `biome_phase_id` serve apenas para relacionar o conteúdo compartilhado ao bioma existente.

### 11.2 Tabela proposta

```sql
CREATE TABLE classification_scores (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  classification_phase_key TEXT NOT NULL,
  biome_phase_id INTEGER NOT NULL,
  player_name TEXT NOT NULL,
  score INTEGER NOT NULL,
  max_score INTEGER NOT NULL,
  stars INTEGER NOT NULL,
  wrong_placements INTEGER NOT NULL,
  hints_used INTEGER NOT NULL DEFAULT 0,
  attempts INTEGER NOT NULL,
  completed_at TEXT NOT NULL,
  FOREIGN KEY (biome_phase_id)
    REFERENCES phases(id)
    ON DELETE CASCADE
);
```

### 11.3 Migration

A nova tabela exige:

- incremento da versão do banco;
- `onUpgrade` idempotente;
- teste de instalação nova;
- teste de upgrade de banco existente;
- nenhuma alteração destrutiva em `scores`;
- nenhuma renomeação de valores do seed.

Uma tabela separada reduz mistura de dados, mas não elimina risco de migration.

---

## 12. Repositório

### `ClassificationScoreRepository`

Operações:

- `insert`;
- `getByClassificationPhaseKey`;
- `getBestByClassificationPhaseKey`;
- `isUnlocked`;
- `deleteClassificationProgress`.

O desbloqueio deve consultar apenas `classification_scores`.

---

## 13. HUD compartilhado

### Etapa de refatoração segura

Antes da UI do novo modo:

1. criar testes/snapshots do HUD atual;
2. extrair `_HudCard` e botão de voltar para `lib/widgets/shared/`;
3. atualizar `GameTopHud` para usar os componentes extraídos;
4. verificar que não houve alteração visual ou funcional;
5. somente então criar `ClassificationHud`.

Evitar copiar componentes privados.

---

## 14. Cores e tema

A camada de domínio não contém cor.

A camada visual usa tokens, por exemplo:

```dart
Color trophicLevelColor(
  BuildContext context,
  TrophicLevel level,
)
```

Os tokens devem vir do tema/guia existente.

Antes de fechar a paleta:

- verificar contraste real;
- evitar que uma zona vermelha pareça estado de erro;
- manter âmbar/laranja suave para revisão;
- usar texto e ícones junto da cor.

---

## 15. Acessibilidade

Além do drag and drop:

```text
tocar no card → selecionar
tocar na zona → posicionar
```

Também prever:

- `Semantics`;
- foco de teclado quando aplicável;
- nomes dos organismos;
- estado do card lido por leitor de tela;
- feedback que não dependa apenas de áudio ou cor;
- fonte ampliada;
- zonas roláveis em alturas pequenas.

`LongPressDraggable` pode ser avaliado, mas não é solução suficiente de acessibilidade.

---

## 16. Etapas de implementação

### Etapa 0 — Confirmar dados e extrair HUD compartilhado

**Objetivo**

- confirmar a relação inconsistente do Pantanal;
- criar proteção visual do HUD atual;
- extrair átomos compartilháveis sem regressão.

**Critério de pronto**

- tabela Pantanal confirmada por ID/nome;
- testes do HUD atual passando;
- comparação visual sem mudança perceptível;
- nenhum código do novo gameplay ainda.

**Rollback**

- reverter somente a extração dos widgets compartilhados.

---

### Etapa 1 — Domínio e testes puros

**Arquivos**

- `trophic_level.dart`;
- `classification_phase_config.dart`;
- `organism_classification.dart`;
- `classification_hint.dart`;
- `classification_scoring.dart`;
- `classification_phase_builder.dart`.

**Testes**

- mapeamento contextual do Campo;
- cálculo correto de topo;
- pontuação;
- estrelas;
- dicas;
- Cobra documentada como decisão contextual.

**Critério de pronto**

- todos os testes unitários passam;
- nenhum widget ou banco alterado;
- `flutter analyze` sem novos problemas.

---

### Etapa 2 — Estado do fluxo

**Arquivos**

- `classification_service.dart`;
- testes do serviço.

**Funcionalidades**

- carregar fase;
- posicionar e mover cards;
- `canVerify`;
- validar;
- bloquear acertos;
- nova tentativa;
- dicas graduais;
- resultado final.

**Critério de pronto**

- `canVerify == false` até todos os cards estarem posicionados;
- fluxo completo coberto por testes unitários;
- serviço não importa `GameService`.

---

### Etapa 3 — UI básica do Campo

**Arquivos**

- `classification_game_screen.dart`;
- `classification_zone.dart`;
- `classification_organism_card.dart`;
- `classification_shelf.dart`;
- `classification_action_bar.dart`;
- `classification_hud.dart`.

**Escopo**

- sem partículas elaboradas;
- sem persistência;
- sem demais biomas.

**Critério de pronto**

- drag entre prateleira e zonas;
- reorganização;
- alternativa por toque;
- tela utilizável em 320, 360, 393, 412 e 430dp;
- `Verificar` só ativo com todos posicionados;
- testes de widget passando.

---

### Etapa 4 — Feedback, dicas e conclusão

**Arquivos**

- `classification_hint_panel.dart`;
- `classification_result_modal.dart`;
- ajustes no serviço e áudio.

**Critério de pronto**

- primeira dica não revela a zona;
- acertos e erros usam ícone, texto e cor;
- conclusão apresenta aprendizagem;
- nenhuma informação depende somente de áudio;
- testes de widget e integração passam.

---

### Etapa 5 — Persistência e entrada no aplicativo

**Arquivos**

- migration;
- `classification_score_repository.dart`;
- `classification_phases_screen.dart`;
- `classification_intro_screen.dart`;
- integração com Home.

**Critério de pronto**

- banco novo cria tabela;
- banco existente faz upgrade;
- progresso da Teia permanece intacto;
- classificação salva e recupera estrelas próprias;
- provider fica escopado ao fluxo;
- Home funciona em 320dp.

---

### Etapa 6 — Pós-MVP

Somente após validação humana do Campo:

- Floresta;
- Oceano;
- Pantanal;
- refinamentos visuais;
- efeitos adicionais;
- possível evolução futura de mecânicas.

Esses itens não fazem parte da implementação inicial.

---

## 17. Testes necessários

### Unitários

- `ClassificationScoring`;
- `ClassificationPhaseBuilder`;
- cálculo de topo por `source_id`;
- `ClassificationService`;
- progressão das dicas;
- `canVerify`;
- persistência e desbloqueio.

### Widgets

- zona aceita card;
- card retorna à prateleira;
- mover entre zonas;
- alternativa tocar-card → tocar-zona;
- botão `Verificar`;
- feedback de erro e acerto;
- HUD;
- modal final.

### Integração

```text
abrir modo
→ abrir Campo
→ posicionar todos
→ verificar
→ corrigir
→ concluir
→ salvar
→ voltar
→ visualizar estrelas
```

### Banco

- instalação nova;
- upgrade da versão anterior;
- tabela `scores` intacta;
- tabela nova criada uma única vez.

### Manual

- larguras 320–480dp;
- fonte ampliada;
- mute/unmute;
- retorno de rota;
- desempenho do drag;
- contraste;
- leitores de tela quando disponíveis.

---

## 18. Riscos e mitigação

| Risco | Mitigação |
|---|---|
| Cálculo de topo invertido | Testes explícitos com `source_id` |
| Mistura de progresso | Tabela e repositório próprios |
| `GameService` crescer | Proibição de import no serviço novo |
| Migration falhar | Upgrade idempotente + testes |
| Home ficar densa | protótipo responsivo antes da integração |
| HUD atual regredir | etapa própria de extração e comparação |
| Dica entregar resposta | três níveis graduais |
| Estrelas sempre iguais | usar pontuação/maxScore |
| Cor de zona parecer erro | tokens revisados e teste visual |
| Drag inacessível | alternativa por toque |

---

## 19. Critérios globais de pronto do MVP

- modo atual permanece funcional;
- nenhum `if (mode)` é adicionado ao `GameService`;
- Campo contém 7 organismos e 4 zonas;
- `Verificar` exige todos posicionados;
- predador de topo é selo;
- cálculo de topo usa ausência em `source_id`;
- pontuação e estrelas são próprias;
- dicas são graduais;
- provider é local ao fluxo;
- progresso é separado;
- banco anterior faz upgrade sem perda;
- `flutter analyze` não apresenta novos problemas;
- todos os testes previstos passam;
- UI funciona a partir de 320dp;
- conclusão explica o fluxo de energia.

---

## 20. Ordem de aprovação recomendada

Antes de iniciar cada marco:

1. aprovar domínio e regras;
2. aprovar protótipo visual do Campo;
3. aprovar feedback e dicas;
4. aprovar migration;
5. aprovar entrada na Home;
6. somente depois expandir para outros biomas.
