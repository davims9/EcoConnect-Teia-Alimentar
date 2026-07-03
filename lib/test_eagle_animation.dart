import 'package:flutter/material.dart';
import 'package:flame/game.dart';

import 'models/organism.dart';
import 'game/components/organism_component.dart';

void main() {
  // Captura erros de renderização do Flutter para mostrar na tela em vez de tela branca
  ErrorWidget.builder = (FlutterErrorDetails details) {
    return Material(
      color: Colors.red,
      child: Center(
        child: Text(
          details.exceptionAsString(),
          style: const TextStyle(color: Colors.white, fontSize: 16),
          textAlign: TextAlign.center,
        ),
      ),
    );
  };

  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: const Color(0xFF2C3E50),
        appBar: AppBar(
          title: const Text('Teste de Animação: Águia'),
          backgroundColor: const Color(0xFF1A252F),
        ),
        body: Center(
          child: Container(
            width: 300,
            height: 300,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white24),
            ),
            child: GameWidget(
              game: TestEagleGame(),
              // Caso o erro aconteça dentro do ciclo do Flame:
              errorBuilder: (context, ex) {
                return Center(
                  child: Text(
                    'Erro no Flame: $ex',
                    style: const TextStyle(color: Colors.white),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    ),
  );
}

class TestEagleGame extends FlameGame {
  @override
  Future<void> onLoad() async {
    await super.onLoad();

    const eagle = Organism(
      id: 7,
      phaseId: 1,
      name: 'Águia',
      emoji: '🦅',
      trophicLevel: 'predador',
      positionX: 0,
      positionY: 0,
    );

    final eagleComponent = OrganismComponent(organism: eagle)
      ..position = Vector2(150, 150);

    add(eagleComponent);
  }
}
