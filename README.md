# EcoConnect: Teia Alimentar

Jogo educacional onde o jogador constrói teias alimentares conectando organismos de diferentes biomas. Desenvolvido em **Flutter** com **Flame Engine** e **SQLite**, com wrapper web em **Svelte**.

---
## Como Jogar

1. **Escolha um bioma** na tela de fases (Campo, Floresta, Oceano ou Pantanal)
2. **Arraste do predador para a presa** — ex: Gafanhoto → Capim (quem come → quem é comido)
3. Se a conexão estiver **correta**, a linha fica verde e você ganha +10 pontos
4. Se estiver **errada**, a linha vermelha some e você perde -10 pontos
5. Complete **todas as conexões** do bioma para finalizar a fase
6. Quanto menos erros, mais estrelas (1 a 3) e bônus de pontuação
7. Se a pontuação chegar a **0**, é game over — tente novamente
### Regras

- **Conexão repetida** (já feita) — ignorada sem penalidade
- **Auto-conexão** (arrastar sobre si mesmo) — ignorada sem penalidade
- **Direção reversa** (arrastar presa → predador) — erro (-10 pts)
- **Soltar fora de um organismo** — cancelado sem penalidade
- **Desbloqueio**: fase seguinte libera ao concluir a anterior com pelo menos 1⭐

## Tecnologias

- **Flutter** (3.41.6) + **Dart** 3.x
- **Flame Engine** — renderização do jogo, componentes com drag & drop
- **SQLite** (`sqflite` / `sqflite_common_ffi_web`) — persistência local
- **Provider** — gerenciamento de estado
- **Flame Audio** — sons ambientes por bioma (CC0)
- **Svelte** + **Vite** — página web que embarca o Flutter via iframe
- **serve** — servidor de produção (porta 3000)

## Estrutura

```
lib/
├── core/              # Constantes, tema, asset paths
├── database/          # SQLite helper, seed, factories (web/io/stub)
├── game/
│   ├── food_web_game.dart
│   └── components/
│       ├── background_component.dart
│       ├── organism_component.dart
│       ├── connection_line.dart
│       └── drag_indicator.dart
├── models/            # phase, organism, connection, score
├── repositories/      # phase, organism, connection, score
├── services/          # game_service, scoring_service, audio_service
├── screens/           # home, phases, game, ranking, about
├── widgets/           # phase_card, stars_display, hint_button
└── main.dart

web/
├── src/App.svelte     # Página Svelte com hero + iframe do jogo
├── dist/              # Build de produção (Svelte + Flutter)
└── public/flutter-app/ # Build do Flutter web
```

## Funcionalidades

- 4 biomas: Campo, Floresta, Oceano, Pantanal
- Organismos posicionados com algoritmo de rejeição (sem sobreposição)
- Arrastar para conectar (source → target) com linha pontilhada animada
- Validação contra grafo de conexões corretas por fase
- Pontuação (+10 acerto, -10 erro), estrelas (1-3), game over
- Sistema de dicas (revela conexão por -5 pts, max 3)
- Áudio ambiente por bioma
- Persistência de progresso (SQLite)
- Versões para **Android**, **Web**, **Windows**

## Como Executar

### Android (emulador)

```bash
flutter run -d emulator-5554
```

### Web (desenvolvimento)

```bash
cd web
npm install
npm run dev
```

### Web (produção)

```bash
cd web
npm install
npm run build
npx serve dist -p 3000
```

### Windows (desktop)

```bash
flutter run -d windows
```



## Banco de Dados (SQLite)

Tabelas: `phases`, `organisms`, `connections`, `scores`.

Acesso via platform-conditional exports:

- **Mobile**: `sqflite` nativo
- **Desktop**: `sqflite_common_ffi`
- **Web**: `sqflite_common_ffi_web` (sqlite3.wasm)

## Arquitetura

```
UI Layer (Screens)
      ↓
Game Layer (Flame Engine)
      ↓
Service Layer (Game, Scoring, Audio)
      ↓
Repository Layer
      ↓
Database Layer (SQLite)
```

## Biomas e Imagens

- **Flutter app (Android/desktop)**: imagens originais `cenarios/{bioma}.png` (1376×3072)
- **Flutter web (iframe)**: imagens `cenarios/{bioma}Svelt.png` (2720×1568)
- Fundo renderizado com escala uniforme (cover) + overlay escuro
