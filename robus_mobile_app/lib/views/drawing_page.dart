import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:robus_mobile_app/views/theme/app_theme.dart';

import '../components/canvas_side_bar.dart';
import '../components/drawing_canvas.dart';
import '../components/hot_key_listener.dart';
import '../models/drawing_canvas_options.dart';
import '../models/drawing_tool.dart';
import '../models/message.dart';
import '../models/stroke.dart';
import '../models/undo_redo_stack.dart';
import 'notifiers/current_stroke_value_notifier.dart';

class DrawingPage extends StatefulWidget {
  final BluetoothDevice? connectedDevice;

  const DrawingPage({super.key, required this.connectedDevice});

  @override
  State<DrawingPage> createState() => _DrawingPageState();
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

  List<Message> buffer = [];
  final TextEditingController controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    if (widget.connectedDevice != null) {
      device = widget.connectedDevice;
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

  Future<void> sendDrawingData(List<Stroke> strokes) async {
    if (device == null) return;

    String drawingData = _serializeStrokesToString(strokes);

    try {
      List<BluetoothService> services = await device!.discoverServices();
      BluetoothService serviceFFE0 = services.firstWhere(
            (service) => service.uuid.toString().toUpperCase() == 'FFE0',
        orElse: () => throw Exception('Service FFE0 non trouvé'),
      );

      BluetoothCharacteristic characteristic = serviceFFE0.characteristics.firstWhere(
            (char) => char.uuid.toString().toUpperCase() == 'FFE1' &&
            char.properties.writeWithoutResponse,
        orElse: () => throw Exception('Caractéristique FFE1 avec écriture sans réponse non trouvée'),
      );

      List<int> bytes = utf8.encode(drawingData);
      Uint8List byteArray = Uint8List.fromList(bytes);

      int chunkSize = 20;

      for (int i = 0; i < byteArray.length; i += chunkSize) {
        int end = (i + chunkSize < byteArray.length) ? i + chunkSize : byteArray.length;
        List<int> chunk = byteArray.sublist(i, end);

        try {
          await characteristic.write(chunk, withoutResponse: true);
          print("Morceau envoyé : ${utf8.decode(chunk)}");
        } catch (e) {
          print("Erreur d'envoi du morceau : $e");
        }
      }

      setState(() {
        buffer.add(Message(drawingData, 1));
        controller.clear();
      });
    } catch (e) {
      print("Erreur lors de la découverte des services ou de l'envoi : $e");
    }
  }

  String _serializeStrokesToString(List<Stroke> strokes) {
    StringBuffer data = StringBuffer();
    for (final stroke in strokes) {
      if (stroke is SquareStroke) {
        data.write('Square: (${stroke.points.first.dx} | ${stroke.points.first.dy}),(${stroke.points.last.dx} | ${stroke.points.last.dy}) | ${stroke.points.length}; ');
      } else if (stroke is LineStroke) {
        data.write('Line: (${stroke.points.first.dx} | ${stroke.points.first.dy}),(${stroke.points.last.dx} | ${stroke.points.last.dy}) | ${stroke.points.length}; ');
      } else if (stroke is CircleStroke) {
        data.write('Circle: ${stroke.points.first.dx} | ${stroke.points.first.dy} | ${stroke.points.length}; ');
      } else if (stroke is PolygonStroke) {
        data.write('Polygon: ${stroke.sides} | ');
        for (final point in stroke.points) {
          data.write('(${point.dx} | ${point.dy}), ');
        }
        data.write('| ${stroke.points.length}; ');
      } else {
        data.write('Normal: ');
        for (final point in stroke.points) {
          data.write('(${point.dx} | ${point.dy}), ');
        }
        data.write('| ${stroke.points.length}; ');
      }

    }
    return data.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kCanvasColor,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(widget.connectedDevice != null
            ? 'Connecté à ${widget.connectedDevice!.platformName}'
            : 'Aucun appareil connecté'
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.send),
            tooltip: 'Envoyer les données via Bluetooth',
            onPressed: () async {
              if (allStrokes.value.isEmpty) {
                print("Aucun dessin à envoyer");
              } else {
                await sendDrawingData(allStrokes.value);
              }
            },
          ),
        ],
      ),
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
              top: kToolbarHeight + 50,
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
    );
  }
}
class _CustomAppBar extends StatelessWidget {
  final AnimationController animationController;

  const _CustomAppBar({super.key, required this.animationController});

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
              'Paint étudiant',
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
