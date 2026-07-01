# Relatório — Posicionamento de Organismos pelo Banco

## Data
2026-07-01

## Objetivo
Substituir o posicionamento aleatório dos organismos por posições determinadas exclusivamente pelos dados do banco SQLite, organizando-os visualmente como uma pirâmide alimentar (produtores na base, predadores no topo).

---

## Arquivos Alterados

### 1. `lib/database/database_seed.dart`
Responsável pelos dados iniciais do banco. Todos os valores de `position_x` e `position_y` foram reorganizados para refletir a hierarquia trófica.

### 2. `lib/game/food_web_game.dart`
- Método `loadPhase()`: agora lê `positionX` e `positionY` diretamente do modelo `Organism`, convertendo as coordenadas proporcionais (0.0–1.0) para pixels absolutos com base no tamanho da tela.
- Método `_generateRandomPositions()`: **removido** — não é mais necessário.

---

## Novos Valores de Posição

As faixas de `positionY` por nível trófico:

| Nível Trófico               | Y (proporcional) | Faixa         |
|-----------------------------|------------------|---------------|
| produtor                    | 0.85             | base          |
| consumidor_primario         | 0.66             | meio-baixo    |
| consumidor_secundario       | 0.48             | meio          |
| consumidor_terciario        | 0.28             | meio-alto     |
| predador_topo               | 0.06             | topo          |

### Fase 1 — Campo (7 organismos)

| ID | Nome       | Nível Trófico           | position_x | position_y |
|----|------------|-------------------------|------------|------------|
| 1  | Capim      | produtor                | 0.50       | 0.85       |
| 2  | Gafanhoto  | consumidor_primario     | 0.25       | 0.66       |
| 3  | Coelho     | consumidor_primario     | 0.75       | 0.66       |
| 4  | Sapo       | consumidor_secundario   | 0.50       | 0.48       |
| 5  | Cobra      | consumidor_terciario    | 0.50       | 0.28       |
| 6  | Raposa     | predador_topo           | 0.25       | 0.06       |
| 7  | Águia      | predador_topo           | 0.75       | 0.06       |

### Fase 2 — Floresta (8 organismos)

| ID | Nome            | Nível Trófico           | position_x | position_y |
|----|-----------------|-------------------------|------------|------------|
| 8  | Arbusto         | produtor                | 0.50       | 0.85       |
| 9  | Lagarta         | consumidor_primario     | 0.25       | 0.66       |
| 10 | Aranha          | consumidor_secundario   | 0.25       | 0.48       |
| 11 | Sapo            | consumidor_secundario   | 0.75       | 0.48       |
| 12 | Cobra           | consumidor_terciario    | 0.50       | 0.28       |
| 13 | Gavião          | predador_topo           | 0.25       | 0.06       |
| 14 | Veado           | consumidor_primario     | 0.75       | 0.66       |
| 15 | Onça-pintada    | predador_topo           | 0.75       | 0.06       |

### Fase 3 — Oceano (7 organismos)

| ID | Nome          | Nível Trófico           | position_x | position_y |
|----|---------------|-------------------------|------------|------------|
| 16 | Fitoplâncton  | produtor                | 0.30       | 0.85       |
| 17 | Alga          | produtor                | 0.70       | 0.85       |
| 18 | Camarão       | consumidor_primario     | 0.50       | 0.66       |
| 19 | Sardinha      | consumidor_secundario   | 0.50       | 0.48       |
| 20 | Polvo         | consumidor_terciario    | 0.30       | 0.28       |
| 21 | Atum          | consumidor_terciario    | 0.70       | 0.28       |
| 22 | Tubarão       | predador_topo           | 0.50       | 0.06       |

### Fase 4 — Pantanal (7 organismos)

| ID | Nome            | Nível Trófico           | position_x | position_y |
|----|-----------------|-------------------------|------------|------------|
| 23 | Planta aquática | produtor                | 0.50       | 0.85       |
| 24 | Caramujo        | consumidor_primario     | 0.50       | 0.66       |
| 25 | Peixe           | consumidor_secundario   | 0.50       | 0.48       |
| 26 | Garça           | consumidor_terciario    | 0.30       | 0.28       |
| 27 | Jacaré          | consumidor_terciario    | 0.70       | 0.28       |
| 28 | Cobra sucuri    | predador_topo           | 0.30       | 0.06       |
| 29 | Onça-pintada    | predador_topo           | 0.70       | 0.06       |

---

## Onde Ajustar a Posição de um Organismo no Futuro

**Arquivo:** `lib/database/database_seed.dart`
**Método:** `_insertOrganisms()`

Cada organismo é inserido com um mapa contendo as chaves `position_x` e `position_y`. Basta alterar os valores numéricos (entre 0.0 e 1.0) e reinstalar o app (ou limpar os dados) para que o novo seed seja executado.

> **Atenção:** O seed só roda na primeira execução (`onCreate` do SQLite). Para testar alterações, é necessário:
> - Desinstalar e reinstalar o app; ou
> - Alterar a versão do banco em `AppConstants.dbVersion` para disparar `onUpgrade`; ou
> - Limpar os dados do app nas configurações do dispositivo.

---

## Como Testar o Posicionamento

1. **Execute o app** em qualquer plataforma (web, Android, desktop).
2. **Selecione uma fase** (Campo, Floresta, Oceano ou Pantanal).
3. **Observe a tela do jogo**: os organismos devem aparecer organizados verticalmente:
   - Produtores (plantas) na parte inferior
   - Consumidores primários acima
   - Consumidores secundários no meio
   - Consumidores terciários mais acima
   - Predadores de topo no topo
4. **Verifique conexões**: arraste um predador para uma presa — a mecânica deve funcionar exatamente como antes.
5. **Redimensione a janela** (web/desktop): as posições devem escalar proporcionalmente.
6. **Mude para outra fase**: verifique se a organização por nível trófico se mantém.

---

## Mensagem de Commit Sugerida

```
feat: posiciona organismos por dados do banco em pirâmide trófica
```

---

## Resumo Técnico

- `positionX` e `positionY` sempre existiram no modelo e no banco, mas eram ignorados pelo jogo, que usava posições aleatórias.
- O método `_generateRandomPositions()` em `food_web_game.dart` foi removido.
- O método `loadPhase()` agora converte as coordenadas proporcionais do banco para pixels:  
  `positionX * size.x` e `positionY * size.y`.
- Nenhuma outra parte do jogo foi alterada — mecânica, pontuação, animações, HUD permanecem idênticos.
- A organização visual segue uma pirâmide alimentar educacional, onde a posição vertical (Y) indica o nível trófico.
