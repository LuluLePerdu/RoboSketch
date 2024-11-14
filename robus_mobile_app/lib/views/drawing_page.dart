import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:robus_mobile_app/views/theme/app_theme.dart';

import '../components/canvas_side_bar.dart';
import '../components/drawing_canvas.dart';
import '../components/hot_key_listener.dart';
import '../models/drawing_canvas_options.dart';
import '../models/drawing_tool.dart';
import '../models/stroke.dart';
import '../models/undo_redo_stack.dart';
import 'notifiers/current_stroke_value_notifier.dart';

class DrawingPage extends StatefulWidget {
  final BluetoothDevice? conenctedDevice;
  const DrawingPage({super.key, this.conenctedDevice});

  @override
  State<DrawingPage> createState() => _DrawingPageState();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Drawing'),
      ),
      body: Center(
        child: Text(conenctedDevice != null
            ? 'Connecté à ${conenctedDevice!.platformName}'
            : 'Aucun appareil connecté'),
      ),
    );
  }
}

class _DrawingPageState extends State<DrawingPage> with SingleTickerProviderStateMixin {
  late final AnimationController animationController;

  final ValueNotifier<Color> selectedColor = ValueNotifier(Colors.black);
  final ValueNotifier<double> strokeSize = ValueNotifier(10.0);
  final ValueNotifier<double> eraserSize = ValueNotifier(30.0);
  final ValueNotifier<DrawingTool> drawingTool = ValueNotifier(DrawingTool.pencil);
  final GlobalKey canvasGlobalKey = GlobalKey();
  final ValueNotifier<bool> filled = ValueNotifier(false);
  final ValueNotifier<int> polygonSides = ValueNotifier(3);
  final ValueNotifier<ui.Image?> backgroundImage = ValueNotifier(null);
  final CurrentStrokeValueNotifier currentStroke = CurrentStrokeValueNotifier();
  final ValueNotifier<List<Stroke>> allStrokes = ValueNotifier([]);
  late final UndoRedoStack undoRedoStack;
  final ValueNotifier<bool> showGrid = ValueNotifier(false);

  BluetoothDevice? device;
  BluetoothCharacteristic? characteristic;

  @override
  void initState() {
    super.initState();
    animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    if (widget.conenctedDevice != null) {
      device = widget.conenctedDevice;
      _discoverServices();
    }

    undoRedoStack = UndoRedoStack(
      currentStrokeNotifier: currentStroke,
      strokesNotifier: allStrokes,
    );
  }

  Future<void> _discoverServices() async {
    final services = await device!.discoverServices();
    for (final service in services) {
      for (final characteristic in service.characteristics) {
        if (characteristic.properties.notify) {
          await characteristic.setNotifyValue(true);
          characteristic.lastValueStream.listen((value) {
            print('Received: $value');
          });
        }
      }
    }
  }

  Future<void> _sendDrawingData() async {
    if (characteristic != null) {
      List<int> drawingData = _serializeStrokes(allStrokes.value);
      await characteristic!.write(drawingData);
      print('Drawing data sent');
    }
  }

  List<int> _serializeStrokes(List<Stroke> strokes) {
    List<int> data = [];
    for (final stroke in strokes) {
      data.add(stroke.color.value);
      data.add(stroke.size.toInt());
      data.add(stroke.points.length);
      for (final point in stroke.points) {
        data.add(point.dx.toInt());
        data.add(point.dy.toInt());
      }
    }
    return data;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kCanvasColor,
      body: HotkeyListener(
        onRedo: undoRedoStack.redo,
        onUndo: undoRedoStack.undo,
        child: Stack(
          children: [
            AnimatedBuilder(
              animation: Listenable.merge([currentStroke, allStrokes, selectedColor, strokeSize, eraserSize, drawingTool, polygonSides, showGrid]),
              builder: (context, _) {
                return DrawingCanvas(
                  options: DrawingCanvasOptions(
                    currentTool: drawingTool.value,
                    size: strokeSize.value,
                    strokeColor: selectedColor.value,
                    backgroundColor: kCanvasColor,
                    polygonSides: polygonSides.value,
                    showGrid: showGrid.value,
                  ),
                  canvasKey: canvasGlobalKey,
                  currentStrokeListenable: currentStroke,
                  strokesListenable: allStrokes,
                );
              },
            ),
            Positioned(
              top: kToolbarHeight + 10,
              child: SlideTransition(
                position: Tween<Offset>(begin: const Offset(-1, 0), end: Offset.zero).animate(animationController),
                child: CanvasSideBar(
                  drawingTool: drawingTool,
                  selectedColor: selectedColor,
                  strokeSize: strokeSize,
                  eraserSize: eraserSize,
                  currentSketch: currentStroke,
                  allSketches: allStrokes,
                  canvasGlobalKey: canvasGlobalKey,
                  polygonSides: polygonSides,
                  undoRedoStack: undoRedoStack,
                  showGrid: showGrid,
                ),
              ),
            ),
            _CustomAppBar(animationController: animationController),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _sendDrawingData,
        child: Icon(Icons.bluetooth),
        tooltip: 'Send drawing via Bluetooth',
      ),
    );
  }
}

class _CustomAppBar extends StatelessWidget {
  final AnimationController animationController;

  const _CustomAppBar({Key? key, required this.animationController}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 70,
      width: double.maxFinite,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              onPressed: () {
                if (animationController.value == 0) {
                  animationController.forward();
                } else {
                  animationController.reverse();
                }
              },
              icon: const Icon(Icons.menu),
            ),
            const Text(
              'Drawing',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 19,
              ),
            ),
            const SizedBox.shrink(),
          ],
        ),
      ),
    );
  }
}
