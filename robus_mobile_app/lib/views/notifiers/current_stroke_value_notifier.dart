import 'package:flutter/material.dart';
import '../../models/stroke.dart';

class CurrentStrokeValueNotifier extends ValueNotifier<Stroke?> {
  CurrentStrokeValueNotifier() : super(null);

  bool get hasStroke => value != null;

  void startStroke(
    Offset point, {
    Color color = Colors.blueAccent,
    double size = 10,
    double opacity = 1,
    StrokeType type = StrokeType.normal,
    int? sides,
  }) {
    value = () {
      if (type == StrokeType.eraser) {
        return EraserStroke(
          points: [point],
          color: color,
          size: size,
          opacity: opacity,
        );
      }

      if (type == StrokeType.line) {
        return LineStroke(
          points: [point],
          color: color,
          size: size,
          opacity: opacity,
        );
      }

      if (type == StrokeType.polygon) {
        return PolygonStroke(
          points: [point],
          color: color,
          size: size,
          opacity: opacity,
          sides: sides ?? 3,
        );
      }

      if (type == StrokeType.circle) {
        return CircleStroke(
          points: [point],
          color: color,
          size: size,
          opacity: opacity,
        );
      }

      if (type == StrokeType.square) {
        return SquareStroke(
          points: [point],
          color: color,
          size: size,
          opacity: opacity,
        );
      }

      return NormalStroke(
        points: [point],
        color: color,
        size: size,
        opacity: opacity,
      );
    }();
  }

  void addPoint(Offset point) {
    final points = List<Offset>.from(value?.points ?? [])..add(point);
    value = value?.copyWith(points: points);
  }

  void clear() {
    value = null;
  }
}
