# Controle de Áudio (Mudo/Ativo)

## Objetivo

Adicionar um botão na HomeScreen para ativar/desativar o áudio do jogo
globalmente, persistindo o estado durante toda a execução.

## Arquivos Alterados

| Arquivo | Tipo de Alteração | Descrição |
|---|---|---|
| `lib/services/audio_service.dart` | Modificado | Adicionado mute global, cache do bioma atual, e toggle |
| `lib/widgets/audio_toggle_button.dart` | Criado | Widget reutilizável do botão circular |
| `lib/screens/home_screen.dart` | Modificado | Botão posicionado no canto superior direito |

## Onde o Estado Global de Áudio Ficou Armazenado

O estado de mute está no **singleton `AudioService`**, na propriedade privada
`_muted`, acessível publicamente via getter `isMuted`.

```dart
AudioService.instance.isMuted;   // ler estado
AudioService.instance.toggleMute(); // alternar
```

Como `AudioService` é um singleton com `static final _instance`, ele vive
durante todo o ciclo de vida do aplicativo (não é recriado ao navegar entre
telas). Nenhum Provider, InheritedWidget ou armazenamento persistente foi
necessário — o estado morre quando o app é encerrado, conforme requisito.

## Como Adicionar Facilmente Outras Configurações de Áudio no Futuro

A estrutura atual usa um único booleano `_muted`. Para suportar controles
separados de música e efeitos sonoros (SFX):

1. Substitua `_muted` por um pequeno objeto de configuração:

```dart
class AudioConfig {
  bool musicEnabled = true;
  bool sfxEnabled = true;
}
```

2. Adicione getters `isMusicEnabled` / `isSfxEnabled` e métodos
   `toggleMusic()` / `toggleSfx()` no `AudioService`.

3. Crie botões específicos (ex.: `MusicToggleButton`, `SfxToggleButton`)
   que leem/escrevem as respectivas flags — ou generalize o
   `AudioToggleButton` atual para receber um `IconData` e um `VoidCallback`.

4. Nos métodos `playAmbient` e futuros `playSfx`, verifique a flag
   correspondente antes de executar.

## Como Testar o Funcionamento

### Teste Manual

1. Inicie o app — a HomeScreen exibe o botão de áudio (ícone de alto-falante)
   no canto superior direito.
2. Toque no botão — o ícone muda para `volume_off` (sem som) e a borda fica
   levemente avermelhada.
3. Navegue para a Tela de Fases e entre em uma fase — o áudio ambiente **não**
   deve tocar enquanto o mute estiver ativo.
4. Volte para a HomeScreen e toque novamente no botão — o ícone volta para
   `volume_up` e o áudio ambiente deve ser retomado ao entrar em uma fase.
5. Navegue entre HomeScreen → Fases → Jogo → HomeScreen — o estado do mute
   permanece o mesmo em todas as telas.
6. Verifique a animação: ao tocar, o botão escala levemente (press) e o ícone
   faz uma transição suave com fade + scale.

### Teste Automatizado (sugestão)

```dart
void main() {
  test('AudioService toggleMute alterna estado corretamente', () {
    final audio = AudioService.instance;
    final initial = audio.isMuted;

    audio.toggleMute();
    expect(audio.isMuted, !initial);

    audio.toggleMute();
    expect(audio.isMuted, initial);
  });
}
```

## Mensagem de Commit Sugerida

```
feat(audio): add global mute toggle button on HomeScreen

- Add _muted flag and _currentBiome cache to AudioService
- Create reusable AudioToggleButton widget with scale/fade transitions
- Position button in top-right corner of HomeScreen stack
- Mute persists across screens via singleton lifetime
```
