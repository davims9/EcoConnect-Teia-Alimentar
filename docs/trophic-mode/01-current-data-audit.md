# Auditoria de Dados Atuais — Modo Classificação por Níveis Tróficos

> **Data:** Julho de 2026  
> **Escopo:** Estado atual do EcoConnect relevante ao planejamento do modo “Classificação por Níveis Tróficos”.  
> **Fontes auditadas:** `lib/`, `docs/project-current-state-analysis.md`, `docs/ui-ux-identity-guide.md`, `AGENTS.md` e `README.md`.

---

## 1. Arquitetura e navegação atuais

### 1.1 Fluxo de navegação identificado

```text
main.dart → FoodWebApp (ChangeNotifierProvider<GameService>)
  → HomeScreen
      ├─ JOGAR → PhasesScreen
      │     ├─ fase bloqueada → SnackBar
      │     └─ fase liberada → BiomeIntroScreen
      │           └─ EXPLORAR → GameService.loadPhase(phase)
      │                 → GameScreen
      ├─ RANKING → RankingScreen
      ├─ COMO JOGAR → TutorialScreen
      └─ SOBRE → AboutScreen
```

**Arquivos e símbolos localizados:**

- `lib/main.dart` — inicialização do aplicativo e provider global do `GameService`;
- `lib/screens/home_screen.dart` — entradas atuais da home;
- `lib/screens/phases_screen.dart` — seleção e desbloqueio de fases;
- `lib/screens/biome_intro_screen.dart` — introdução do bioma;
- `lib/screens/game_screen.dart` — instanciação do jogo atual;
- `lib/services/game_service.dart` — estado e regras do modo Teia Alimentar.

### 1.2 Gerenciamento de estado

O projeto usa `Provider` com `ChangeNotifier`.

- **`GameService`** concentra carregamento de fase, organismos, conexões, timer, pontuação, erros, estrelas e persistência do modo atual.
- **`AudioService`** é singleton e possui contexto de áudio global.
- **`ScoringService`** calcula pontuação e estrelas do modo atual.

**Conclusão:** o novo modo não deve ampliar o `GameService`. Deve possuir estado e regras próprios.

---

## 2. Modelos, banco e seed

### 2.1 Modelos localizados

| Arquivo | Classe | Campos relevantes |
|---|---|---|
| `lib/models/organism.dart` | `Organism` | `id`, `phaseId`, `name`, `emoji`, `trophicLevel`, posições |
| `lib/models/phase.dart` | `Phase` | `id`, `name`, `description`, `biome`, `sortOrder` |
| `lib/models/correct_connection.dart` | `CorrectConnection` | `phaseId`, `sourceId`, `targetId`, `key` |
| `lib/models/score.dart` | `Score` | `phaseId`, `playerName`, `score`, `stars`, `errors`, `completedAt` |

### 2.2 Schema SQLite atual

```sql
phases (
  id,
  name,
  description,
  biome,
  sort_order
)

organisms (
  id,
  phase_id,
  name,
  emoji,
  trophic_level,
  position_x,
  position_y
)

correct_connections (
  id,
  phase_id,
  source_id,
  target_id
)

scores (
  id,
  phase_id,
  player_name,
  score,
  stars,
  errors,
  completed_at
)
```

No modo atual:

```text
source_id = presa/alimento
target_id = predador/consumidor
```

Essa direção precisa ser preservada em qualquer cálculo derivado das relações.

### 2.3 Conteúdo do seed

Foram identificados:

- 4 biomas/fases;
- 29 organismos;
- 36 conexões;
- `trophic_level` preenchido em todos os organismos listados na auditoria.

---

## 3. Valores atuais de `trophicLevel`

### 3.1 Distribuição encontrada

| Valor no seed | Quantidade | Exemplos |
|---|---:|---|
| `produtor` | 5 | Capim, Arbusto, Fitoplâncton, Alga, Planta aquática |
| `consumidor_primario` | 6 | Gafanhoto, Coelho, Lagarta, Veado, Camarão, Caramujo |
| `consumidor_secundario` | 5 | Sapo, Aranha, Sardinha, Peixe |
| `consumidor_terciario` | 7 | Cobra, Polvo, Atum, Garça, Jacaré, Cobra sucuri |
| `predador_topo` | 6 | Raposa, Águia, Gavião, Onça-pintada, Tubarão |

### 3.2 Interpretação pedagógica

O seed mistura duas naturezas distintas:

- `produtor`, `consumidor_primario`, `consumidor_secundario` e `consumidor_terciario` representam categorias tróficas;
- `predador_topo` representa uma condição relacional: não possuir predador dentro da teia considerada.

Para o novo modo, `predador_topo` não deve criar automaticamente uma quinta zona. A recomendação é mapear o organismo para uma das quatro zonas pedagógicas e exibir “Predador de topo desta teia” como selo contextual.

### 3.3 Cores atuais

O guia de identidade possui cores para os cinco rótulos existentes. O código também contém um método `_colorForTrophicLevel`, mas essa diferenciação não aparece de forma significativa na experiência principal atual.

As cores do novo modo devem ser obtidas por tokens centralizados de tema. O enum ou modelo de domínio não deve armazenar valores HEX.

---

## 4. Relações por bioma

> A seta abaixo mantém o sentido do banco: **alimento/presa → consumidor/predador**.

### 4.1 Campo

```text
Capim → Gafanhoto
Capim → Coelho
Gafanhoto → Sapo
Coelho → Cobra
Coelho → Raposa
Coelho → Águia
Sapo → Cobra
Cobra → Águia
```

Classificação pedagógica preliminar:

- Produtor: Capim
- Consumidores primários: Gafanhoto, Coelho
- Consumidor secundário: Sapo
- Consumidor terciário: Cobra
- Predadores de topo contextuais: Raposa, Águia

### 4.2 Floresta

```text
Arbusto → Lagarta
Arbusto → Veado
Lagarta → Aranha
Lagarta → Sapo
Aranha → Sapo
Sapo → Cobra
Cobra → Gavião
Cobra → Onça-pintada
Veado → Onça-pintada
```

Classificação pedagógica preliminar:

- Produtor: Arbusto
- Consumidores primários: Lagarta, Veado
- Consumidores secundários: Aranha, Sapo
- Consumidor terciário: Cobra
- Predadores de topo contextuais: Gavião, Onça-pintada

### 4.3 Oceano

```text
Fitoplâncton → Camarão
Alga → Camarão
Camarão → Sardinha
Camarão → Polvo
Sardinha → Atum
Sardinha → Polvo
Atum → Tubarão
Polvo → Tubarão
```

Classificação pedagógica preliminar:

- Produtores: Fitoplâncton, Alga
- Consumidor primário: Camarão
- Consumidores secundários: Sardinha, Polvo
- Consumidor terciário: Atum
- Predador de topo contextual: Tubarão

### 4.4 Pantanal — pendência de confirmação

A transcrição anterior apresentou inconsistência entre IDs e nomes em pelo menos uma conexão. Antes de usar o Pantanal no novo modo, deve-se conferir diretamente `database_seed.dart` e montar uma tabela exata:

| source_id | Nome da presa/alimento | target_id | Nome do predador |
|---:|---|---:|---|
| a confirmar | a confirmar | a confirmar | a confirmar |

A fase Pantanal não deve entrar no MVP nem ter `isTopPredator` calculado até essa conferência ser concluída.

---

## 5. Ambiguidades e correções pedagógicas

### 5.1 Sapo

O sapo do Campo come um consumidor primário. Portanto, no recorte atual, ele é consumidor secundário.

O fato de ser comido por Cobra ou Águia não o transforma em consumidor primário. Quem o consome ocupa um nível acima; isso não altera a fonte de energia do sapo.

### 5.2 Cobra do Campo

A Cobra come:

- Coelho, consumidor primário;
- Sapo, consumidor secundário.

Assim, ela pode ocupar nível secundário ou terciário conforme a cadeia observada. Para o MVP, deve-se adotar uma classificação contextual explícita na configuração da fase, e não inferir cegamente pelo valor global do seed.

### 5.3 Onívoros e níveis múltiplos

O modelo atual armazena apenas uma string de `trophicLevel`. Ele não representa:

- onivoria;
- múltiplos níveis;
- nível dependente da cadeia;
- justificativa pedagógica da classificação.

Por isso, o novo modo deve admitir `expectedLevel` por fase.

### 5.4 Predador de topo

Com `source_id = presa` e `target_id = predador`, um organismo é candidato a predador de topo contextual quando:

1. é consumidor;
2. não aparece como `source_id` nas relações incluídas naquela fase.

Pseudorregra:

```text
preyIds = conjunto de todos os source_id da fase
isTopPredator = organismo é consumidor E organismo.id não pertence a preyIds
```

Essa regra deve usar somente os organismos e relações incluídos na fase de classificação.

---

## 6. Reaproveitamento de componentes

| Componente/serviço | Decisão | Motivo |
|---|---|---|
| `AudioService` | Reutilização direta | Agnóstico à regra de gameplay |
| `ScoringService` | Referência, não reuso automático | O cálculo atual de estrelas não serve diretamente ao novo fluxo |
| `ScoreRepository` | Não reutilizar diretamente | Persistência atual pertence ao modo Teia |
| `DatabaseSeed` | Reutilização de leitura | Fonte de organismos e relações |
| `StarsDisplay` | Reutilização direta | Widget visual |
| `GameTopHud` | Reuso por extração segura de átomos | O HUD completo é específico do modo atual |
| `AudioToggleButton` | Reutilização direta | Independente de modo |
| `HoverButton` | Reutilização direta | Botão genérico |
| `ConnectionEffect` | Não reutilizar | Acoplado a linhas/conexões Flame |
| `OrganismComponent` | Não reutilizar | Acoplado ao drag entre organismos no Flame |
| `OrganismWidget` | Referência visual/composição | Pode orientar o novo card Flutter |

---

## 7. Persistência atual e impacto futuro

A persistência do modo atual usa `scores.phase_id` e o fluxo de desbloqueio existente.

O novo modo deverá ter:

- repositório próprio;
- identificador próprio de fase de classificação;
- estrelas e desbloqueio independentes;
- nenhuma reinterpretação das linhas existentes em `scores`.

Uma nova tabela reduz o risco de mistura entre modos, mas exige migration aditiva e idempotente em instalações existentes.

---

## 8. Inconsistências confirmadas

| # | Item | Impacto |
|---:|---|---|
| 1 | `predador_topo` mistura categoria trófica e condição relacional | Pode ensinar um “quinto nível” incorreto |
| 2 | `GameService` concentra responsabilidades demais | Não deve receber lógica do novo modo |
| 3 | `OrganismComponent` está acoplado à mecânica atual | Criar card próprio |
| 4 | O cálculo de topo precisa respeitar `source = presa` | Evita resultado invertido |
| 5 | A análise anterior do sapo estava incorreta | Corrigida nesta versão |
| 6 | Há relação do Pantanal com IDs/nomes inconsistentes na transcrição | Exige conferência no seed |
| 7 | O seed oferece nível único mesmo quando o organismo ocupa mais de um nível | Exige configuração contextual por fase |

---

## 9. Itens ainda não confirmados

- relação exata inconsistente no Pantanal;
- validade biológica de todos os níveis do seed;
- melhor classificação contextual para organismos que consomem presas de níveis diferentes;
- ponto final de entrada do novo modo na Home;
- necessidade real de migration já no primeiro protótipo;
- contraste WCAG das combinações de cores na tela final.

---

## 10. Conclusão da auditoria

O projeto possui base suficiente para o modo novo, mas o `trophicLevel` global não deve ser a única fonte de verdade.

A configuração de cada fase deve indicar explicitamente:

- organismos participantes;
- nível esperado naquele recorte;
- justificativa pedagógica;
- selo contextual de topo;
- mensagem de dica;
- mensagem de aprendizagem.

A fase Campo é a melhor candidata ao MVP, desde que a Cobra seja tratada como decisão contextual documentada.
