import 'package:flutter/material.dart' hide Image;
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../models/drawing_tool.dart';
import '../models/stroke.dart';
import '../models/undo_redo_stack.dart';
import '../views/notifiers/current_stroke_value_notifier.dart';

class CanvasSideBar extends StatefulWidget {
  final ValueNotifier<Color> selectedColor;
  final ValueNotifier<double> strokeSize;
  final ValueNotifier<double> eraserSize;
  final ValueNotifier<DrawingTool> drawingTool;
  final CurrentStrokeValueNotifier currentSketch;
  final ValueNotifier<List<Stroke>> allSketches;
  final GlobalKey canvasGlobalKey;
  final ValueNotifier<int> polygonSides;
  final UndoRedoStack undoRedoStack;
  final ValueNotifier<bool> showGrid;

  const CanvasSideBar({
    super.key,
    required this.selectedColor,
    required this.strokeSize,
    required this.eraserSize,
    required this.drawingTool,
    required this.currentSketch,
    required this.allSketches,
    required this.canvasGlobalKey,
    required this.polygonSides,
    required this.undoRedoStack,
    required this.showGrid,
  });

  @override
  State<CanvasSideBar> createState() => _CanvasSideBarState();
}

class _CanvasSideBarState extends State<CanvasSideBar> {
  UndoRedoStack get undoRedoStack => widget.undoRedoStack;

  final scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300,
      height: MediaQuery.of(context).size.height < 680 ? 450 : 610,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.horizontal(right: Radius.circular(10)),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 3,
            offset: const Offset(3, 3),
          ),
        ],
      ),
      child: AnimatedBuilder(
        animation: Listenable.merge([
          widget.selectedColor,
          widget.strokeSize,
          widget.eraserSize,
          widget.drawingTool,
          widget.polygonSides,
          widget.showGrid,
        ]),
        builder: (context, _) {
          return Scrollbar(
            controller: scrollController,
            thumbVisibility: true,
            trackVisibility: true,
            child: ListView(
              padding: const EdgeInsets.all(10.0),
              controller: scrollController,
              children: [
                const SizedBox(height: 10),
                const Text(
                  'Shapes',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const Divider(),
                Wrap(
                  alignment: WrapAlignment.start,
                  spacing: 5,
                  runSpacing: 5,
                  children: [
                    _IconBox(
                      iconData: FontAwesomeIcons.pencil,
                      selected: widget.drawingTool.value == DrawingTool.pencil,
                      onTap: () =>
                          widget.drawingTool.value = DrawingTool.pencil,
                      tooltip: 'Pencil',
                    ),
                    _IconBox(
                      selected: widget.drawingTool.value == DrawingTool.line,
                      onTap: () => widget.drawingTool.value = DrawingTool.line,
                      tooltip: 'Line',
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 22,
                            height: 2,
                            color: widget.drawingTool.value == DrawingTool.line
                                ? Colors.grey[900]
                                : Colors.grey,
                          ),
                        ],
                      ),
                    ),
                    _IconBox(
                      iconData: Icons.hexagon_outlined,
                      selected: widget.drawingTool.value == DrawingTool.polygon,
                      onTap: () =>
                          widget.drawingTool.value = DrawingTool.polygon,
                      tooltip: 'Polygon',
                    ),
                    _IconBox(
                      iconData: FontAwesomeIcons.eraser,
                      selected: widget.drawingTool.value == DrawingTool.eraser,
                      onTap: () =>
                          widget.drawingTool.value = DrawingTool.eraser,
                      tooltip: 'Eraser',
                    ),
                    _IconBox(
                      iconData: FontAwesomeIcons.square,
                      selected: widget.drawingTool.value == DrawingTool.square,
                      onTap: () =>
                          widget.drawingTool.value = DrawingTool.square,
                      tooltip: 'Square',
                    ),
                    _IconBox(
                      iconData: FontAwesomeIcons.circle,
                      selected: widget.drawingTool.value == DrawingTool.circle,
                      onTap: () =>
                          widget.drawingTool.value = DrawingTool.circle,
                      tooltip: 'Circle',
                    ),
                    _IconBox(
                      iconData: FontAwesomeIcons.ruler,
                      selected: widget.showGrid.value,
                      onTap: () =>
                          widget.showGrid.value = !widget.showGrid.value,
                      tooltip: 'Guide Lines',
                    ),
                  ],
                ),

                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 150),
                  child: widget.drawingTool.value == DrawingTool.polygon
                      ? Row(
                          children: [
                            const Text(
                              'Polygon Sides: ',
                              style: TextStyle(fontSize: 12),
                            ),
                            Slider(
                              value: widget.polygonSides.value.toDouble(),
                              min: 3,
                              max: 8,
                              onChanged: (val) {
                                widget.polygonSides.value = val.toInt();
                              },
                              label: '${widget.polygonSides.value}',
                              divisions: 5,
                            ),
                          ],
                        )
                      : const SizedBox.shrink(),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Colors',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                const Divider(),
                Row(
                  children: [
                    const Text(
                      'Stroke Size: ',
                      style: TextStyle(fontSize: 12),
                    ),
                    Slider(
                      value: widget.strokeSize.value,
                      min: 0,
                      max: 50,
                      onChanged: (val) {
                        widget.strokeSize.value = val;
                      },
                    ),
                  ],
                ),
                Row(
                  children: [
                    const Text(
                      'Eraser Size: ',
                      style: TextStyle(fontSize: 12),
                    ),
                    Slider(
                      value: widget.eraserSize.value,
                      min: 0,
                      max: 80,
                      onChanged: (val) {
                        widget.eraserSize.value = val;
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                const Text(
                  'Actions',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const Divider(),
                Wrap(
                  children: [
                    TextButton(
                      onPressed: widget.allSketches.value.isNotEmpty
                          ? () => undoRedoStack.undo()
                          : null,
                      child: const Text('Undo'),
                    ),
                    ValueListenableBuilder<bool>(
                      valueListenable: undoRedoStack.canRedo,
                      builder: (_, canRedo, __) {
                        return TextButton(
                          onPressed:
                              canRedo ? () => undoRedoStack.redo() : null,
                          child: const Text('Redo'),
                        );
                      },
                    ),
                    TextButton(
                      child: const Text('Clear'),
                      onPressed: () => undoRedoStack.clear(),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _IconBox extends StatelessWidget {
  final IconData? iconData;
  final Widget? child;
  final bool selected;
  final VoidCallback onTap;
  final String? tooltip;

  const _IconBox({
    super.key,
    this.iconData,
    this.child,
    this.tooltip,
    required this.selected,
    required this.onTap,
  })  : assert(child != null || iconData != null);

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 35,
          width: 35,
          decoration: BoxDecoration(
            border: Border.all(
              color: selected ? Colors.grey[900]! : Colors.grey,
              width: 1.5,
            ),
            borderRadius: const BorderRadius.all(Radius.circular(5)),
          ),
          child: Tooltip(
            message: tooltip,
            preferBelow: false,
            child: child ??
                Icon(
                  iconData,
                  color: selected ? Colors.grey[900] : Colors.grey,
                  size: 20,
                ),
          ),
        ),
      ),
    );
  }
}
