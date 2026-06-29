import 'dart:ui';

import 'package:flame/components.dart';
import '../components/organism_component.dart';

class ConnectionSystem {
  OrganismComponent? _dragSource;
  Offset _dragEnd = Offset.zero;
  bool _isDragging = false;

  OrganismComponent? get dragSource => _dragSource;
  Offset get dragEnd => _dragEnd;
  bool get isDragging => _isDragging;

  void startDrag(OrganismComponent source) {
    _dragSource = source;
    _isDragging = true;
  }

  void updateDrag(Offset position) {
    _dragEnd = position;
  }

  OrganismComponent? endDrag(List<OrganismComponent> organisms) {
    _isDragging = false;
    final source = _dragSource;
    if (source == null) return null;
    final dragPoint = Vector2(_dragEnd.dx, _dragEnd.dy);
    for (final target in organisms) {
      if (target == source) continue;
      if (target.containsPoint(dragPoint)) {
        return target;
      }
    }
    return null;
  }

  void cancelDrag() {
    _isDragging = false;
    _dragSource = null;
  }
}
