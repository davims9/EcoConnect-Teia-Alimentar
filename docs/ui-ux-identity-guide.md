# Direção Visual — EcoConnect

## Objetivo

Transformar o EcoConnect em uma experiência visualmente mais infantil, divertida e clara, sem alterar a mecânica principal de ligar predador e presa.

O jogo deve parecer uma aventura ecológica, não apenas uma tela funcional com animais e linhas.

## Referência visual

A referência desejada é um jogo infantil com:

- HUD mais chamativa;
- botões arredondados;
- brilho suave;
- conexões coloridas;
- feedback visual claro;
- sensação de descoberta;
- interface amigável para crianças.

Não precisamos copiar a referência inteira agora. O objetivo é adaptar a linguagem visual ao EcoConnect.

## Identidade visual

### Estilo

- Aventura ecológica infantil.
- Visual alegre, natural e mágico.
- Interface simples, mas com cara de jogo.

## Paleta de Cores — EcoConnect

### Cores principais

| Nome             |     HEX | Uso                                       |
| ---------------- | ------: | ----------------------------------------- |
| Verde Floresta   | #0B3D22 | Fundo principal, AppBar, overlays escuros |
| Verde Musgo      | #14532D | Cards, painéis, HUD                       |
| Verde Folha      | #2E7D32 | Botões principais, ações positivas        |
| Verde Luz        | #7ED957 | Glow, destaque, hover, feedback correto   |
| Verde Néon Suave | #A8FF60 | Conexões corretas, partículas mágicas     |

### Recompensa / progresso

| Nome            |     HEX | Uso                                    |
| --------------- | ------: | -------------------------------------- |
| Dourado Estrela | #FFD43B | Estrelas, pontuação, recompensa        |
| Amarelo Mel     | #FBBF24 | Ícones de bônus, pequenos destaques    |
| Laranja Sol     | #F97316 | Atenção leve, consumidor intermediário |

### Informação / dica

| Nome          |     HEX | Uso                               |
| ------------- | ------: | --------------------------------- |
| Azul Rio      | #38BDF8 | Dicas, modo foco, informação      |
| Azul Profundo | #075985 | Cards informativos escuros        |
| Azul Claro    | #BAE6FD | Texto secundário sobre fundo azul |

### Erro / alerta

| Nome            |     HEX | Uso                                          |
| --------------- | ------: | -------------------------------------------- |
| Vermelho Fruta  | #EF4444 | Erro de conexão                              |
| Vermelho Escuro | #7F1D1D | Fundo de card de erro                        |
| Laranja Alerta  | #FB923C | Erro leve, partículas de tentativa incorreta |

### Neutros

| Nome         |     HEX | Uso                        |
| ------------ | ------: | -------------------------- |
| Branco Folha | #F0FDF4 | Texto principal            |
| Verde Névoa  | #BBF7D0 | Texto secundário           |
| Verde Cinza  | #6B8F71 | Texto apagado/desabilitado |
| Preto Sombra | #04130A | Sombras, overlay escuro    |

### **Paleta Infantil ** (Substituição)

#### Usar em:
* glow
* partículas
* estrelas
* linhas corretas
* hover
* botão pressionado
* celebrações

| Verde Floresta | #0B3D22
| Verde Folha | #37B24D
| Verde Brilho | #A3E635
| Dourado | #FACC15
| Azul Dica | #38BDF8
| Roxo Topo | #A78BFA
Vermelho Erro: #F87171
Laranja Alerta: #FDBA74
Branco Texto: #F8FAFC

## Regras de uso

### Botão principal
- fundo: #2E7D32
- hover/glow: #7ED957
- texto: #F0FDF4
- borda: #A8FF60

### HUD / cards
- fundo: #0B3D22 com 80–90% de opacidade
- borda: #2E7D32
- texto principal: #F0FDF4
- texto secundário: #BBF7D0

### Conexão correta
- linha: #7ED957
- glow: #A8FF60
- partículas: #A8FF60, #FFD43B, #F0FDF4

### Conexão errada
- linha: #EF4444
- glow: #FB923C
- partículas: #EF4444, #FB923C, #7F1D1D

### Pontuação e estrelas
- estrela/pontos: #FFD43B
- brilho: #FBBF24

### Dicas
- card: #075985
- destaque: #38BDF8
- texto: #F0FDF4

## Cores dos níveis tróficos

| Nível                 | Cor            |     HEX |
| --------------------- | -------------- | ------: |
| Produtor              | Verde Folha    | #2E7D32 |
| Consumidor primário   | Amarelo Mel    | #FBBF24 |
| Consumidor secundário | Laranja Sol    | #F97316 |
| Consumidor terciário  | Vermelho Fruta | #EF4444 |
| Predador de topo      | Roxo Jaguar    | #8B5CF6 |

### Formas

- Cantos arredondados.
- Cards semitransparentes.
- Bordas suaves.
- Sombras leves.
- Glow discreto em elementos importantes.

### Textos

- Curtos.
- Grandes o suficiente para crianças.
- Linguagem simples.
- Evitar blocos longos.

## Prioridades visuais

### 1. Tela de jogo

A tela de jogo é a prioridade principal.

Melhorias desejadas:

- HUD superior com mais cara de jogo.
- Pontuação com estrela.
- Progresso de conexões mais visível.
- Timer em card próprio.
- Linhas de conexão mais bonitas, com brilho e seta.
- Modo foco ao selecionar um animal.

### 2. Conexões

As conexões devem parecer mágicas e vivas.

Desejado:

- linha mais espessa;
- glow suave;
- seta indicando direção;
- cor mais vibrante;
- pequenas partículas ou folhas se for simples.

### 3. Feedback

Acerto deve parecer recompensa.

Erro deve parecer orientação.

Evitar feedback seco ou punitivo demais.

### 4. Telas secundárias

Home, biomas, tutorial e sobre devem seguir a mesma identidade, mas não são prioridade antes da tela de jogo.

## O que NÃO fazer agora

- Não refazer toda a arquitetura.
- Não trocar todos os sprites.
- Não trocar todos os backgrounds.
- Não criar novas mecânicas grandes.
- Não criar muitas telas novas.
- Não mexer em ranking agora.
- Não gastar tempo tentando algoritmo perfeito de posicionamento.

## Prioridade para amanhã

1. Melhorar HUD da tela de jogo.
2. Melhorar visual das conexões.
3. Criar modo foco simples.
4. Ajustar feedback visual.
5. Corrigir apenas sobreposições gritantes.

## Papéis sugeridos

### UX/UI

Responsável por:
- HUD;
- botões;
- cards;
- cores;
- hierarquia visual;
- consistência entre telas.

### Flutter/Flame

Responsável por:
- implementar sem quebrar mecânica;
- manter performance;
- reaproveitar componentes;
- evitar refatoração grande.

### Conteúdo/Biologia

Responsável por:
- validar relações predador/presa;
- revisar textos educativos;
- garantir clareza sobre teia alimentar, cadeia alimentar e níveis tróficos.

## Regra principal

Toda alteração deve responder a uma pergunta:

"Isso deixa o jogo mais claro, mais bonito ou mais divertido para uma criança?"