# Relatório de Alterações — Tutorial "Como Jogar"

## Arquivos Criados

### `lib/game/tutorial_game.dart`
Flame game dedicado ao tutorial. Estende `FoodWebGame` e sobrescreve:
- `onLoad()` — cria dois `OrganismComponent`: Águia (id:7) e Coelho (id:3) do bioma Campo
- `onDragEnd()` — valida apenas a conexão Águia → Coelho com os mesmos padrões de feedback do jogo real (linha verde com flash, lunge do predador, som de acerto/erro, partículas, shake)
- `loadPhase()` — no-op (não carrega fases do banco)
- `onGameResize()` — reposiciona os organismos proporcionalmente

Usa `_DummyGameService` (estende `GameService`) para satisfazer o construtor de `FoodWebGame` sem acessar banco de dados.

Reutiliza diretamente:
- `OrganismComponent` (drag, animação idle, highlight, shake)
- `ConnectionLine` (linha pontilhada com seta, flash verde/vermelho)
- `ConnectionEffect` (partículas de acerto/erro)
- `AudioService` (sons `playCorrect()` e `playWrong()`)
- `AppColors` (paleta verde do jogo)

### `lib/screens/tutorial_screen.dart`
Tela Flutter que embrulha o `TutorialGame` em um `GameWidget`.

Layout:
- Gradiente escuro/verde idêntico às outras telas
- Partículas animadas de fundo
- Header com botão voltar + título "COMO JOGAR"
- Instrução "Experimente ligar a águia ao coelho."
- Área do jogo com cantos arredondados
- Feedback de acerto/erro (mesmo estilo visual de `GameScreen._buildConnectionMessage`)
- Após acerto: dois botões "VOLTAR" (HomeScreen) e "COMEÇAR" (PhasesScreen)

Reutiliza:
- Mesmo gradiente de fundo das outras telas
- Mesmo estilo de botão de voltar
- Mesmo estilo de card de mensagem
- Mesmo `_ParticleOverlay`/`_ParticlePainter` das telas About/Phases

## Arquivos Alterados

### `lib/screens/home_screen.dart`
- Import adicionado: `tutorial_screen.dart`
- `_buildSecondaryButtons()`: alterado de 2 botões (RANKING, SOBRE) para 3 (RANKING, COMO JOGAR, SOBRE)
  - Espaçamento dinâmico: 10px (default) ou 8px (tela pequena)
  - Usei `Expanded` + `SizedBox` para evitar overflow
  - Ícone do botão: `Icons.school_rounded`
- Método `_navigateToTutorial()` adicionado

## Como Testar

### Botão "COMO JOGAR"
1. Executar o app (`flutter run -d <device>`)
2. Na HomeScreen, verificar se há 3 botões na fileira: RANKING, COMO JOGAR, SOBRE
3. Clicar em "COMO JOGAR"
4. Deve abrir a TutorialScreen

### Tutorial
1. Na TutorialScreen, ver os dois organismos: Águia (esquerda) e Coelho (direita)
2. Arrastar da Águia até o Coelho:
   - ✅ Deve mostrar linha verde com flash, som de acerto, mensagem "🎉 Muito bem! Agora você já sabe jogar."
   - Deve mostrar botões "VOLTAR" e "COMEÇAR"
3. Arrastar do Coelho até a Águia (conexão reversa):
   - ❌ Deve mostrar linha vermelha, som de erro, shake no Coelho
   - Mensagem: "Quase! A águia é o predador. Tente ligar Águia → Coelho."
   - Linha some após ~3s
4. Após acertar:
   - "VOLTAR" → volta para HomeScreen
   - "COMEÇAR" → vai para PhasesScreen (seleção de fases)

### Responsividade
- Redimensionar a janela em desktop ou usar mobile landscape
- Verificar que os 3 botões secundários não causam overflow
- Verificar que os organismos se reposicionam proporcionalmente

## Reúso de Componentes

| Componente | Reutilizado? | Onde |
|---|---|---|
| `OrganismComponent` | ✅ | Drag, animação, highlight, shake |
| `ConnectionLine` | ✅ | Linha + seta com animação |
| `DragIndicator` | ✅ (via FoodWebGame herdado) | Linha pontilhada durante drag |
| `ConnectionEffect` | ✅ | Partículas de acerto/erro |
| `AudioService` | ✅ | Sons de acerto/erro/terminou |
| `AppColors` | ✅ | Paleta verde e cores de conexão |
| `FoodWebGame` | ✅ (estendido) | Sistema de drag, posicionamento |
| `GameScreen._buildConnectionMessage` | ✅ (mesmo estilo) | Card de feedback |

**Não foram criados** novos sprites, componentes visuais diferentes, ou lógica de drag alternativa.

## Ajuste Futuro do Texto do Tutorial

Os textos estão em:

### Mensagens de conexão (`lib/game/tutorial_game.dart`)
- `'🎉 Muito bem!\n\nAgora você já sabe jogar.'` — acerto
- `'🌿 Quase!\n\nA águia é o predador. Tente ligar Águia → Coelho.'` — reverso
- `'❌ Não é essa conexão!\n\nLigue a Águia até o Coelho.'` — outra conexão inválida

### Instrução na tela (`lib/screens/tutorial_screen.dart`)
- `'Experimente ligar a águia ao coelho.'` — método `_buildInstruction()`

### Botões
- `'VOLTAR'` e `'COMEÇAR'` — método `_buildBottomButtons()`

## Sugestão de Commit

**Conventional Commit:**

```
feat(tutorial): add interactive "Como Jogar" tutorial screen

- Add TutorialGame extending FoodWebGame with Águia→Coelho drag validation
- Create TutorialScreen with game widget, feedback overlay, and completion buttons
- Add "COMO JOGAR" button to HomeScreen between RANKING and SOBRE
- Reuse OrganismComponent, ConnectionLine, ConnectionEffect, AudioService
- Adjust secondary button row spacing for 3-button layout
```
