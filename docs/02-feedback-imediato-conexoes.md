# 02 — Feedback Imediato ao Conectar

## Melhoria visual: validação em tempo real com efeitos

> **Data da implementação:** 30/06/2026
> **Tempo estimado:** 1 dia
> **Foco:** Feedback visual imediato ao conectar predador e presa

---

## O que foi feito

Implementação de **validação instantânea** das conexões no momento em que o
jogador solta o drag, com feedback visual rico:

### ✅ Acerto
- Linha pisca branco → verde (`flashThenColor`)
- Partículas verdes explodindo do ponto médio da linha
- Predador dá um bote na presa (já existia, mantido)
- SnackBar verde com mensagem educativa: *"Correto! Águia se alimenta de Cobra."*

### ❌ Erro (direção errada)
- Linha muda para vermelho (`animateColor(AppColors.connectionError)`)
- Predador treme (`addShakeEffect()`)
- Partículas vermelhas no ponto médio
- SnackBar vermelha: *"Direção incorreta! Arraste o predador para a presa."*

### ❌ Erro (combinação errada)
- Linha vermelha
- Predador treme
- Partículas vermelhas
- SnackBar: *"Ops! Cobra não se alimenta de Capim. Tente outra combinação!"*

### Mecânica de Submeter preservada
- O botão "SUBMETER" continua funcionando
- Agora ele serve para **finalizar a fase e ver o resumo**, já que as conexões
  foram validadas individualmente em tempo real

---

## Arquivos alterados

| Arquivo | O que mudou | Linhas |
|---|---|---|
| `lib/game/effects/connection_effect.dart` | **NOVO** — Componente de partículas (estouro verde/vermelho) | 73 |
| `lib/game/food_web_game.dart` | Validação imediata em `onDragEnd()`, 3 casos (correto/direção errada/combinação errada), dispara partículas + lunge + shake + callback | +48 |
| `lib/game/components/connection_line.dart` | Novo método `flashThenColor()` — flash branco → cor final | +7 |
| `lib/game/components/organism_component.dart` | Novo método `addShakeEffect()` — tremor lateral com amplitude decrescente | +36 |
| `lib/screens/game_screen.dart` | Callback `onConnectionResult`, SnackBar flutuante verde/vermelha com mensagem | +29 |
| `lib/services/game_service.dart` | `isConnectionCorrect()`, `isConnectionReversed()`, `getOrganismById()` | +19 |
| | **Total de linhas novas (sem contar whitespace/comentários):** | ~140 |

---

## Como testar

```bash
# Android (emulador)
flutter run -d emulator-5554

# Web (desenvolvimento)
cd web && npm run dev

# Windows (desktop)
flutter run -d windows
```

### Cenários de teste
1. Arraste um predador para uma presa **correta** → linha flash branco-verde,
   partículas verdes, predador avança, snackbar "Correto! ..."
2. Arraste uma **presa para um predador** (direção inversa) → linha vermelha,
   tremor, partículas vermelhas, snackbar "Direção incorreta!"
3. Arraste um predador para uma **presa errada** → linha vermelha, tremor,
   partículas vermelhas, snackbar "Ops! ... não se alimenta de ..."
4. Conexão repetida → ignorada (comportamento original preservado)
5. Botão "SUBMETER" ainda funciona após fazer todas as conexões

---

## Sugestão de commit

**Branch:**
```
feat/immediate-connection-feedback
```

**Mensagem (Conventional Commits):**
```
feat: validate connections on drop with particles, shake and educational messages

- Add ConnectionEffect component with green/red particle burst
- Validate connection immediately in onDragEnd (correct / wrong direction / wrong combination)
- Flash line white→green on correct, red on error
- Shake organism on wrong connection
- Show floating SnackBar with organism names (e.g. "Correto! Águia se alimenta de Cobra.")
- Preserve existing Submit mechanic (now purely for phase summary)
```

---

## Efeitos e assets utilizados

Nenhum asset novo foi adicionado. Todos os efeitos são:
- **Partículas**: desenhadas via Canvas (`canvas.drawCircle`) — sem sprite necessário
- **Shake**: `MoveToEffect` reutilizando o sistema de animação do Flame
- **Flash**: `Color.lerp` (já existente em `ConnectionLine`)
- **SnackBar**: Widget nativo do Flutter (`ScaffoldMessenger`)
- **Lunge**: `MoveToEffect` (já existente)

Isso garante compatibilidade total com futura integração de assets animados por
outras pessoas da equipe.

---

## Integridade do projeto

- ✅ Nenhum arquivo de asset foi modificado
- ✅ `pubspec.yaml` não foi alterado
- ✅ Estrutura de diretórios preservada (apenas `lib/game/effects/` adicionado)
- ✅ Mecânica principal (arrastar linha predador→presa) intacta
- ✅ Botão "Submeter" preservado
- ✅ Todos os componentes Flame mantêm responsabilidade única
- ✅ `dart analyze` — zero erros, zero novos warnings
