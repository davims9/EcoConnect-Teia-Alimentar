# Relatório: Melhoria das Telas de Apresentação dos Biomas

## Objetivo

Adicionar uma seção "Observe e descubra" nas telas de introdução de cada bioma,
transformando a apresentação em uma introdução investigativa que prepara a
criança para observar a teia alimentar durante a fase.

## Arquivo alterado

- `lib/screens/biome_intro_screen.dart`

Nenhum outro arquivo foi alterado. A arquitetura, o fluxo do jogo e as demais
telas permanecem intactas.

## O que mudou

### 1. `_BiomeInfo` — novo campo `observeText`

A classe `_BiomeInfo` (linha ~339) ganhou um campo `String observeText` com
valor padrão `''`. Isso permite que cada bioma tenha seu próprio texto
investigativo sem quebrar a estrutura existente.

### 2. Textos de cada bioma no mapa `_biomeInfo`

Cada entrada do mapa `_biomeInfo` agora inclui `observeText`:

| Bioma    | Texto |
|----------|-------|
| Campo    | "Observe como a energia começa nas plantas. Será que um animal pode ser caçador e também presa?" |
| Floresta | "Na floresta, muitas relações alimentares se cruzam. Observe como diferentes animais dependem uns dos outros." |
| Oceano   | "Alguns dos menores seres do oceano sustentam animais muito maiores. Consegue descobrir como a energia chega até os grandes predadores?" |
| Pantanal | "No Pantanal, a diversidade de seres vivos cria muitas conexões. Observe como a vida na água, na terra e no ar se relaciona." |

Os textos são:
- poucas palavras;
- cientificamente corretos;
- tom infantil;
- criam curiosidade sem entregar respostas.

### 3. Novo widget `_buildObserveCard()`

Card semitransparente com:
- Ícone de lupa (`Icons.search_rounded`);
- Título "OBSERVE E DESCUBRA";
- Texto investigativo centralizado;
- Fundo verde escuro com 55% de opacidade (`Color(0xFF1A3A24).withValues(alpha: 0.55)`);
- Borda verde discreta (`Color(0xFF4CAF50).withValues(alpha: 0.30)`, 1.5px);
- Bordas arredondadas (16px).

O card aparece entre a descrição do bioma e a seção "ORGANISMOS ENCONTRADOS".

### 4. Ajustes nos cards de organismos

- Largura do card: 72px → 88px (mais espaço para nomes)
- Container do sprite: 60px → 64px
- Fonte do nome: 11px → 12px (melhor legibilidade)
- Borda do container: mais visível (1px → 1.5px)
- Espaçamento: 6px → 8px entre sprite e nome

### 5. Espaçamento ajustado

- Entre descrição e card "Observe e descubra": 28px → 24px
- Entre card e seção de organismos: 28px → 24px
- Demais espaçamentos mantidos

## Como editar os textos futuramente

Os textos estão em `lib/screens/biome_intro_screen.dart` no mapa
`_BiomeIntroScreenState._biomeInfo` (linha ~26).

Para alterar o texto "Observe e descubra" de um bioma:

1. Abra `lib/screens/biome_intro_screen.dart`
2. Localize o mapa `_biomeInfo`:
   ```dart
   static const Map<String, _BiomeInfo> _biomeInfo = {
     'campo': _BiomeInfo(
       ...
       observeText: '...',
     ),
     ...
   };
   ```
3. Edite o valor de `observeText` para o bioma desejado.
4. Salve — a alteração é imediata (hot reload).

## Como testar cada bioma

1. Execute o app (`flutter run` ou pelo web).
2. Na tela inicial, clique **Jogar**.
3. Na tela de fases, clique em um card de fase:
   - **Campo** → fase 1
   - **Floresta** → fase 2
   - **Oceano** → fase 3
   - **Pantanal** → fase 4
4. A tela de introdução do bioma abrirá com o novo card "Observe e descubra".
5. Verifique:
   - O card aparece entre a descrição e os organismos;
   - O ícone de lupa está visível;
   - O texto está legível e sem quebras estranhas;
   - O botão "Explorar" continua funcionando.

## Cuidados com overflow e responsividade

- Todo o conteúdo está dentro de um `SingleChildScrollView`, evitando
  overflow vertical em qualquer tamanho de tela.
- A grade de organismos usa `Wrap` com `alignment: WrapAlignment.center`,
  quebrando linhas automaticamente em janelas estreitas.
- Os nomes dos organismos usam `maxLines: 2` + `TextOverflow.ellipsis`.
- O card "Observe e descubra" usa `width: double.infinity` e padding
  responsivo.
- O botão "Explorar" está na parte inferior, conforme solicitado.

## Validação

`flutter analyze` reportou **0 novos issues**. Todos os 12 issues
existentes são prévios e em outros arquivos (`connection_line.dart`,
`organism_component.dart`, `food_web_game.dart`, `game_screen.dart`,
`test_eagle_animation.dart`).

## Sugestão de mensagem de commit (Conventional Commit)

```
feat(biome-intro): add "Observe e descubra" investigative section to biome screens
```

Ou, em português:

```
feat(tela-bioma): adiciona seção "Observe e descubra" nas introduções dos biomas
```
