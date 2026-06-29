# AGENTS.md

## Projeto

Food Web Builder

Jogo educacional desenvolvido em Flutter utilizando Flame Engine e SQLite.

## Objetivo

Permitir que o jogador construa teias alimentares através da criação de conexões entre organismos de diferentes ecossistemas.

## Tecnologias

* Flutter
* Dart
* Flame Engine
* SQLite (sqflite)
* Material Design 3

## Arquitetura

Arquitetura em camadas:

* UI Layer
* Game Layer
* Service Layer
* Repository Layer
* Database Layer

## Estrutura

lib/
├── core/
├── database/
├── game/
├── models/
├── repositories/
├── services/
├── screens/
├── widgets/
└── main.dart

## Regras

* Utilizar SOLID
* Utilizar Repository Pattern
* Evitar lógica de negócio nas telas
* Separar persistência da camada de jogo
* Componentes Flame devem possuir responsabilidade única
* Não utilizar código duplicado

## Banco de Dados

SQLite utilizando sqflite.

Tabelas:

* phases
* organisms
* connections
* scores

## Flame

Utilizar:

* FlameGame
* PositionComponent
* SpriteComponent
* DragCallbacks
* TapCallbacks

## Convenções

* Classes em PascalCase
* Variáveis em camelCase
* Arquivos em snake_case

## Qualidade

* Código limpo
* Responsabilidade única
* Baixo acoplamento
* Alta coesão

## Objetivo Acadêmico

Demonstrar utilização conjunta de:

* Flutter
* Flame Engine
* SQLite
* Estruturas de grafos
* Persistência local
* Desenvolvimento de jogos educacionais
