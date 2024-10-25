enum DrawingTool {
  pencil,
  line,
  eraser,
  polygon,
  square,
  circle;

  bool get isEraser => this == DrawingTool.eraser;
  bool get isLine => this == DrawingTool.line;
  bool get isPencil => this == DrawingTool.pencil;
  bool get isPolygon => this == DrawingTool.polygon;
  bool get isSquare => this == DrawingTool.square;
  bool get isCircle => this == DrawingTool.circle;
}
