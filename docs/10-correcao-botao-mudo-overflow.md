# Correção: Botão de Mudo e Overflows na HomeScreen

## Problemas Identificados

### 1. Botão de áudio invisível

**Causa raiz**: O `AnimationController` do `AudioToggleButton` era inicializado com
`value: 0` (padrão do Flutter). O botão estava inteiramente dentro de um
`ScaleTransition(scale: _toggleAnim)`, e `_toggleAnim` começava em 0 — escala
zero = invisível. O método `forward(from: 0)` só era chamado no `_handleToggle`,
então o botão só aparecia **após o primeiro toque**.

**Correção**: `AnimationController` inicializado com `value: 1.0`. Agora o botão
nasce visível em escala normal e aplica a animação de "pop" apenas no toggle.

### 2. RenderFlex overflow (direita) nos botões Ranking/Sobre

**Causa raiz**: `_buildSecondaryButton` usava uma `Row` com `Icon` + `SizedBox` +
`Text` sem `Flexible` nem `TextOverflow`. O texto com `letterSpacing: 2` e
`fontSize: 13` estourava o container em viewports estreitas.

**Correção**: Texto envolvido em `Flexible` com `overflow: TextOverflow.ellipsis`.
Ícone reduzido de 18→16, espaçamento de 8→6, fonte de 13→12, letterSpacing de
2→1.5 — visualmente equivalente, mas sem overflow.

### 3. RenderFlex overflow (inferior) no conteúdo principal

**Causa raiz**: `SizedBox(height: h)` forçava altura exata da tela. Em viewports
onde o conteúdo da `Column` excedia `h` (soma dos espaçamentos proporcionais +
widgets), o `SizedBox` impunha constraint tight → overflow vertical.

**Correção**: Substituído por `ConstrainedBox(minHeight: h)`, que permite ao
conteúdo crescer além da tela quando necessário (o `SingleChildScrollView`
externo já cuida da rolagem).

## Arquivos Alterados

| Arquivo | O que mudou |
|---|---|
| `lib/widgets/audio_toggle_button.dart` | `AnimationController` agora com `value: 1.0`; fundo/borda verdes consistentes (sem vermelho no mute) |
| `lib/screens/home_screen.dart` | `Positioned` com `top: 24, right: 24`; `Row` dos botões com `Flexible` + `ellipsis`; `SizedBox` → `ConstrainedBox(minHeight:)` |

## Como Testar

1. Abra o app no Chrome com largura reduzida (~320px):
   - Botão de áudio visível no canto superior direito
   - Botões Ranking/Sobre não estouram
   - Rolagem vertical funciona sem overflow
2. Toque no botão de áudio:
   - Ícone alterna entre `volume_up` e `volume_off`
   - Pequena animação de escala (efeito "pop")
   - Navegue entre telas → estado preservado
3. Entre em uma fase com o mute ativo → nenhum som ambiente toca
4. Verifique o console do navegador: sem mensagens de `RenderFlex overflow`

## Mensagem de Commit (Conventional Commit)

```
fix(home): resolve audio button invisibility and layout overflows

- Initialize AnimationController at value 1.0 so ScaleTransition
  renders the button visible from the start, not at scale 0
- Wrap secondary button text in Flexible with ellipsis to prevent
  horizontal RenderFlex overflow on narrow viewports
- Replace SizedBox(height:) with ConstrainedBox(minHeight:) to
  avoid bottom overflow when content exceeds viewport height
- Simplify AudioToggleButton visuals: consistent green border,
  remove redundant animations
```
