# Especificação de Game Design — Modo Classificação por Níveis Tróficos

> **Data:** Julho de 2026  
> **Versão:** 1.1 — MVP revisado  
> **Base:** `01-current-data-audit.md`

---

## 1. Objetivo pedagógico

| Modo Teia Alimentar | Modo Classificação Trófica |
|---|---|
| “Quem se alimenta de quem?” | “Qual papel este organismo ocupa no fluxo de energia?” |
| Ensina relações | Ensina categorias |
| Valida pares presa-predador | Valida organismo-zona |
| Produz uma teia | Produz uma classificação |

Os modos compartilham biomas, organismos e identidade visual, mas possuem regras, estado, progresso, pontuação e feedback próprios.

---

## 2. Público, dispositivo e progressão

- Público-alvo: crianças de 8 a 12 anos;
- prioridade: celular em orientação vertical;
- MVP: uma fase no bioma Campo;
- quantidade inicial: 7 organismos;
- categorias: **4 zonas**;
- progresso separado do modo Teia Alimentar;
- sem cronômetro no MVP;
- fases Floresta, Oceano e Pantanal ficam marcadas como pós-MVP.

As quatro zonas são:

1. Produtores;
2. Consumidores primários;
3. Consumidores secundários;
4. Consumidores terciários.

“Predador de topo” aparece como selo contextual, não como quinta zona.

---

## 3. Fluxo de telas

```text
HomeScreen
  → Escolha de modo
      ├─ Teia Alimentar → fluxo atual
      └─ Classificação Trófica
            → ClassificationPhasesScreen
                  → introdução do bioma
                        → ClassificationGameScreen
                              → organizar todos os cards
                              → Verificar
                              → corrigir, se necessário
                              → concluir
                              → modal “O que você descobriu?”
```

### 3.1 Entrada recomendada

A Home deve apresentar duas escolhas claramente distintas:

- **Teia Alimentar** — conectar quem come quem;
- **Níveis Tróficos** — organizar os seres vivos por função.

A forma exata do componente da Home será decidida após validar o espaço disponível em 320dp.

---

## 4. Estrutura da tela principal

```text
┌──────────────────────────────────┐
│ Voltar | Bioma | Pontos | Áudio │
│ 5 de 7 organismos posicionados   │
├──────────────────────────────────┤
│ 1. PRODUTORES                    │
│ [cards posicionados]             │
├──────────────────────────────────┤
│ 2. CONSUMIDORES PRIMÁRIOS        │
│ [cards posicionados]             │
├──────────────────────────────────┤
│ 3. CONSUMIDORES SECUNDÁRIOS      │
│ [cards posicionados]             │
├──────────────────────────────────┤
│ 4. CONSUMIDORES TERCIÁRIOS       │
│ [cards posicionados]             │
├──────────────────────────────────┤
│ Prateleira horizontal            │
│ [card] [card] [card]             │
├──────────────────────────────────┤
│ DICA                 VERIFICAR   │
└──────────────────────────────────┘
```

### 4.1 Organização responsiva

- `SafeArea`;
- zonas em área rolável vertical caso a altura não seja suficiente;
- prateleira horizontal fixa ou ancorada próxima ao rodapé;
- botões com área mínima de toque de 48dp;
- suporte prioritário a 320–480dp de largura;
- alternativa de interação por toque, além do arraste.

---

## 5. Regras de gameplay

### 5.1 Estados dos cards

```text
shelf
dragging
placed(zone)
verifiedCorrect
verifiedIncorrect
lockedCorrect
```

### 5.2 Arraste e reorganização

- O card pode ser arrastado da prateleira para qualquer zona.
- O encaixe apenas registra a hipótese; não confirma acerto.
- Cards posicionados podem mudar de zona.
- Cards posicionados podem voltar à prateleira.
- Tocar em um card e depois tocar em uma zona deve funcionar como alternativa acessível ao arraste.

### 5.3 Botão `Verificar`

O botão fica habilitado somente quando **todos os organismos estiverem posicionados**.

Enquanto houver cards na prateleira:

```text
Organize todos os seres vivos antes de verificar.
```

Essa regra evita descobrir respostas card por card por tentativa e erro.

### 5.4 Validação

Ao pressionar `Verificar`:

- acertos recebem check, borda/glow verde e permanecem bloqueados;
- erros recebem destaque âmbar/laranja suave;
- a mensagem explica o raciocínio sem revelar imediatamente todas as respostas;
- cards errados podem voltar à prateleira após a leitura do feedback;
- a criança tenta novamente até completar a fase.

### 5.5 Conclusão

A fase termina somente quando todos os cards estão classificados corretamente.

A conclusão não deve depender de tempo no MVP.

---

## 6. Dicas graduais

Cada card pode receber até três níveis de ajuda.

### Nível 1 — pergunta conceitual

> Este organismo produz o próprio alimento ou precisa comer outro ser vivo?

### Nível 2 — relação observável

> O gafanhoto se alimenta diretamente de plantas.

### Nível 3 — orientação de categoria

> Procure a zona dos consumidores primários.

Somente o nível 3 pode destacar diretamente uma zona.

Modelo conceitual:

```dart
class ClassificationHint {
  final int organismId;
  final HintLevel level;
  final String message;
  final TrophicLevel? highlightedLevel;
}
```

A dica deve apoiar raciocínio, não apenas fornecer a resposta.

---

## 7. Pontuação

### 7.1 Eventos

| Evento | Pontos |
|---|---:|
| Acerto confirmado na primeira verificação | +100 |
| Acerto confirmado em tentativa posterior | +50 |
| Classificação incorreta em uma verificação | -10 |
| Dica nível 1 | -2 |
| Dica nível 2 | -5 |
| Dica nível 3 | -10 |

A pontuação nunca fica negativa.

### 7.2 Estrelas

Como a fase só termina em 100% de acertos, as estrelas não podem ser calculadas pela porcentagem final de respostas corretas.

Elas devem ser baseadas na razão entre a pontuação obtida e a pontuação máxima da fase:

```text
3 estrelas = pelo menos 85% da pontuação máxima
2 estrelas = pelo menos 60%
1 estrela  = concluiu a fase abaixo de 60%
```

A pontuação máxima do Campo, com 7 organismos, é:

```text
7 × 100 = 700 pontos
```

Os limites devem ser calculados pelo `ClassificationScoring`, sem reutilizar cegamente `ScoringService.calculateStars()`.

---

## 8. Predador de topo

### 8.1 Regra

“Predador de topo” não é uma zona.

É um selo exibido após a verificação ou conclusão quando o organismo:

- é consumidor;
- não aparece como presa (`source_id`) nas relações incluídas naquela fase.

Texto recomendado:

> Predador de topo desta teia

### 8.2 Uso pedagógico

O selo deve aparecer sobre o card já classificado em uma das quatro zonas. Ele não altera a zona esperada.

---

## 9. Ambiguidades

### 9.1 Classificação contextual

A validação não deve depender exclusivamente de `Organism.trophicLevel`.

Cada fase deve declarar:

```text
organismId
expectedLevel
isTopPredator
justification
hintMessages
```

### 9.2 Campo

Classificação inicial proposta:

| Organismo | Zona esperada | Observação |
|---|---|---|
| Capim | Produtor | Produz seu próprio alimento |
| Gafanhoto | Consumidor primário | Alimenta-se de planta |
| Coelho | Consumidor primário | Alimenta-se de planta |
| Sapo | Consumidor secundário | Alimenta-se de gafanhoto |
| Cobra | Consumidor terciário no recorte | Também come coelho; requer justificativa contextual |
| Raposa | Consumidor terciário | Badge de topo contextual |
| Águia | Consumidor terciário | Badge de topo contextual |

A Cobra deve trazer mensagem específica explicando que uma mesma espécie pode ocupar posições diferentes conforme a cadeia considerada.

---

## 10. Feedback e linguagem

### 10.1 Acerto

> Muito bem! O gafanhoto se alimenta diretamente de plantas, por isso é consumidor primário.

### 10.2 Erro

> Quase! Observe de onde vem o alimento deste organismo.

Evitar:

- “Errado!”;
- punição forte;
- vermelho intenso;
- revelar toda a resposta na primeira tentativa.

### 10.3 Conclusão

O modal deve incluir:

- estrelas;
- pontuação;
- número de verificações;
- dicas utilizadas;
- selo de topo encontrado;
- seção “O que você descobriu?”.

Exemplo:

> A energia começa nos produtores e passa para os consumidores. Um predador de topo é aquele que não possui predador dentro da teia observada.

---

## 11. Acessibilidade e responsividade

- nomes com no mínimo 14sp quando possível;
- botões e alvos com pelo menos 48dp;
- nenhuma informação dependente apenas de cor;
- ícone + texto para sucesso e revisão;
- alternativa tocar-card → tocar-zona;
- leitura sem áudio;
- suporte a fontes maiores;
- validação manual de contraste antes de declarar conformidade WCAG;
- rolagem vertical quando quatro zonas não couberem;
- sem partículas obrigatórias no MVP.

---

## 12. Identidade visual

- HUD verde-escuro translúcido;
- botões arredondados;
- glow suave;
- dourado para recompensa;
- azul para informação e dica;
- âmbar/laranja suave para revisão;
- evitar vermelho permanente como cor dominante de uma zona;
- usar tokens centralizados do guia;
- não armazenar cor no enum `TrophicLevel`.

A cor final das quatro zonas será definida na implementação a partir dos tokens existentes e validada contra o significado semântico de erro.

---

## 13. Escopo do MVP

| Item | MVP |
|---|---|
| Escolha de modo | Sim |
| Fase Campo | Sim |
| 7 organismos | Sim |
| 4 zonas | Sim |
| Drag and drop | Sim |
| Alternativa por toque | Sim |
| Verificação em lote | Sim |
| Dicas graduais | Sim |
| Nova tentativa mantendo acertos | Sim |
| Pontuação e estrelas próprias | Sim |
| Progresso independente | Sim |
| Modal pedagógico | Sim |
| Badge de topo contextual | Sim |
| Timer | Não |
| Partículas elaboradas | Não |
| Floresta/Oceano/Pantanal | Pós-MVP |
| Variantes adicionais | Possível evolução futura, fora deste plano |

---

## 14. Critérios pedagógicos de pronto

O MVP estará pedagogicamente pronto quando:

- a criança precisar classificar todos os cards antes de verificar;
- a primeira dica não entregar a resposta;
- o sistema explicar por que uma resposta está correta;
- predador de topo não aparecer como quinta zona;
- a Cobra do Campo possuir justificativa contextual;
- o resultado final reforçar fluxo de energia;
- nenhum erro bloquear a conclusão.
