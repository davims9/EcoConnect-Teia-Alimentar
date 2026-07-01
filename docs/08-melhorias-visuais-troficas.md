# Relatório — Melhorias Visuais para Compreensão da Cadeia Alimentar

## Data
2026-07-01

## Alterações

### Arquivos modificados

| Arquivo | O que mudou |
|---|---|
| `lib/game/components/organism_component.dart` | Adicionado indicador circular colorido do nível trófico abaixo do nome de cada organismo |
| `lib/game/food_web_game.dart` | Adicionado método `_renderTrophicLegend()` para desenhar legenda lateral com faixas e rótulos |

Nenhum outro arquivo foi alterado. Mecânica, pontuação, sprites, animações, banco de dados — tudo permanece intacto.

---

## Melhoria 1 — Indicador Visual do Nível Trófico

### Implementação

No método `render()` de `OrganismComponent`, após desenhar o nome do organismo, um pequeno círculo colorido (3.5px de raio) é desenhado 5px abaixo do nome.

### Cores por nível

| Nível Trófico | Cor | Código |
|---|---|---|
| produtor | Verde | `AppColors.correct` (#4CAF50) |
| consumidor_primario | Amarelo | #FFC107 |
| consumidor_secundario | Laranja | #FF9800 |
| consumidor_terciario | Laranja escuro | #F57C00 |
| predador_topo | Vermelho | `AppColors.connectionError` (#EF5350) |

### Parâmetros ajustáveis

No arquivo `lib/game/components/organism_component.dart`:

- **Raio do ponto** (linha ~185): `3.5` — aumentar para ponto maior
- **Opacidade** (linha ~181): `0.85` — diminuir para mais discreto
- **Distância do nome** (linha ~183): `nameBottom + 5` — alterar o `+5` para mais/menos espaçamento
- **Cores** (método `_colorForTrophicLevel`, linhas 190-205): trocar os `Color` values

---

## Melhoria 2 — Legenda Lateral dos Níveis Tróficos

### Implementação

Novo método `_renderTrophicLegend(Canvas canvas)` em `FoodWebGame`, chamado no `render()` após os filhos (background + organismos) e antes do `dragIndicator`.

A legenda contém:

1. **Duas linhas horizontais sutis** (1px, 12% opacidade) delimitando as três zonas:
   - Entre Predadores e Consumidores (Y ~0.38 em coordenadas do banco)
   - Entre Consumidores e Produtores (Y ~0.755 em coordenadas do banco)
   - As linhas vão da margem esquerda até a margem direita da área segura

2. **Rótulos de texto** à esquerda (10px, 30% opacidade, letter-spacing 2px):
   - `PREDADORES` — na zona superior
   - `CONSUMIDORES` — na zona média
   - `PRODUTORES` — na zona inferior

### Posicionamento

Os Y das linhas e rótulos são calculados dinamicamente com base nos mesmos valores de `topMargin`, `bottomMargin` e `safeHeight` usados no `loadPhase()`, garantindo alinhamento perfeito com os organismos.

As zonas agrupam os níveis tróficos do banco:

| Zona | Níveis do Banco |
|---|---|
| PREDADORES | predador_topo + consumidor_terciario |
| CONSUMIDORES | consumidor_secundario + consumidor_primario |
| PRODUTORES | produtor |

### Parâmetros ajustáveis

No método `_renderTrophicLegend()` em `lib/game/food_web_game.dart`:

- **Opacidade das linhas** (linha ~127): `0.12` — aumentar para linhas mais visíveis
- **Opacidade dos textos** (linha ~140): `0.30` — aumentar para textos mais legíveis
- **Tamanho da fonte** (linha ~141): `10` — aumentar para letras maiores
- **Letter-spacing** (linha ~143): `2.0` — aproximar ou afastar letras
- **Espessura da linha** (linha ~128): `1.0` — aumentar para linhas mais grossas
- **Posição horizontal dos rótulos** (linha ~160): `sideMargin - 16 - painter.width` — ajustar o `-16` para deslocar os textos
- **Posição inicial das linhas** (linha ~130): `sideMargin - 16.0` — alterar para encurtar/esticar as linhas

---

## Como Testar

1. **Indicador trófico**: Abra qualquer fase. Abaixo do nome de cada organismo deve haver um pequeno ponto colorido:
   - Plantas (Capim, Arbusto) → ponto **verde**
   - Herbívoros (Gafanhoto, Coelho) → ponto **amarelo**
   - Carnívoros médios (Sapo, Sardinha) → ponto **laranja**
   - Topo (Águia, Tubarão) → ponto **vermelho**

2. **Legenda lateral**: Na lateral esquerda do jogo, devem aparecer discretamente os dizeres `PREDADORES`, `CONSUMIDORES` e `PRODUTORES`, com linhas horizontais finas separando as zonas. A opacidade baixa não deve atrapalhar a visualização dos organismos.

3. **Alinhamento**: Verifique se as linhas da legenda estão razoavelmente alinhadas com os espaços entre os níveis tróficos dos organismos.

4. **Redimensione a janela**: A legenda deve se ajustar proporcionalmente.

5. **Conexões**: A mecânica de arrastar predador → presa deve continuar funcionando exatamente como antes.

---

## Mensagem de Commit

```
feat: add trophic level indicators and side legend to visualize food chain hierarchy
```
