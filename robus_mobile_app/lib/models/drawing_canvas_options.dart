import 'package:flutter/material.dart';
import '../views/theme/app_colors.dart';
import 'drawing_tool.dart';

class DrawingCanvasOptions {
  final Color strokeColor;
  final double size;
  final double opacity;
  final DrawingTool currentTool;
  final Color backgroundColor;
  final bool showGrid;
  final int polygonSides;

  const DrawingCanvasOptions({
    this.strokeColor = blackAccent,
    this.size = 10,
    this.opacity = 1,
    this.currentTool = DrawingTool.pencil,
    this.backgroundColor = lightAccent,
    this.showGrid = false,
    this.polygonSides = 3,
  });


  DrawingCanvasOptions copyWith({
    Color? strokeColor,
    double? size,
    double? opacity,
    DrawingTool? currentTool,
    Color? backgroundColor,
    bool? showGrid,
    int? polygonSides,
  }) {
    return DrawingCanvasOptions(
      strokeColor: strokeColor ?? this.strokeColor,
      size: size ?? this.size,
      opacity: opacity ?? this.opacity,
      currentTool: currentTool ?? this.currentTool,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      showGrid: showGrid ?? this.showGrid,
      polygonSides: polygonSides ?? this.polygonSides,
    );
  }
}
