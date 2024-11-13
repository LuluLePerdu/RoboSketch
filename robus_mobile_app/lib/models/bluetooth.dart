import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';

import '../views/chat_screen.dart';
import '../views/scan_page.dart';
import 'message.dart';

class BluetoothApp extends StatefulWidget {
  @override
  _BluetoothAppState createState() => _BluetoothAppState();
}

class _BluetoothAppState extends State<BluetoothApp> {
  bool bluetoothState = false;
  BluetoothDevice? selectedDevice;
  bool connectionStatus = false;
  List<Message> buffer = [];
  final TextEditingController controller = TextEditingController();
  String lastSentMessage = "";
  bool isMessageSending = false;

  @override
  void initState() {
    super.initState();
    getPermissions();
  }

  Future<void> getPermissions() async {
    if (Platform.isAndroid || Platform.isIOS) {
      await Permission.bluetooth.request();
      await Permission.bluetoothConnect.request();
    }
  }

  void toggleBluetooth() {
    setState(() {
      bluetoothState = !bluetoothState;
      bluetoothState ? FlutterBluePlus.turnOn() : FlutterBluePlus.turnOff();
    });
  }

  Future<void> connectDevice(BluetoothDevice device) async {
    try {
      await device.connect();
      setState(() {
        connectionStatus = true;
        selectedDevice = device;
      });
      startListening();
    } catch (e) {
      print("Connection Error: $e");
    }
  }

  void disconnectDevice() async {
    await selectedDevice?.disconnect();
    setState(() {
      connectionStatus = false;
      selectedDevice = null;
    });
  }

  Future<void> startScan() async {
    FlutterBluePlus.startScan(timeout: Duration(seconds: 4));
  }

  Future<void> stopScan() async {
    FlutterBluePlus.stopScan();
  }

  Future<void> sendMessage() async {
    String text = controller.text;
    if (text.isEmpty || selectedDevice == null) return;

    if (text == lastSentMessage) {
      return;
    }

    lastSentMessage = text;
    isMessageSending = true;

    List<BluetoothService> services = await selectedDevice!.discoverServices();
    BluetoothService serviceFFE0 = services.firstWhere(
          (service) => service.uuid.toString().toUpperCase() == 'FFE0',
      orElse: () => throw Exception('Service FFE0 non trouvé'),
    );

    BluetoothCharacteristic characteristic = serviceFFE0.characteristics.firstWhere(
          (char) => char.uuid.toString().toUpperCase() == 'FFE1' && char.properties.writeWithoutResponse,
      orElse: () => throw Exception('Caractéristique FFE1 avec écriture sans réponse non trouvée'),
    );

    // Convertir le message entier en bytes
    List<int> bytes = utf8.encode(text);
    Uint8List byteArray = Uint8List.fromList(bytes);

    // Limiter la taille à 20 octets (maximum pour l'envoi sans réponse)
    int chunkSize = 20;

    // Envoyer les morceaux un par un
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
      buffer.add(Message(text, 1));  // 1 pour l'expéditeur
      controller.clear();
    });
  }

  Future<void> startListening() async {
    if (selectedDevice == null) return;

    try {
      List<BluetoothService> services = await selectedDevice!.discoverServices();
      BluetoothService? lastService;
      BluetoothCharacteristic? characteristic;

      for (var service in services) {
        for (var chr in service.characteristics) {
          if (chr.uuid.toString().toUpperCase() == 'FFE1') {
            lastService = service;
            characteristic = chr;
            break;
          }
        }
      }

      if (lastService != null && characteristic != null) {
        await characteristic.setNotifyValue(true);
        characteristic.lastValueStream.listen((value) {
          String receivedText = utf8.decode(value);

          // Vérifier si le message reçu est celui que l'on vient d'envoyer
          if (isMessageSending) {
            isMessageSending = false; // Réinitialiser le flag
            return; // Ne pas ajouter ce message à l'affichage
          }

          setState(() {
            buffer.add(Message(receivedText, 0)); // Indiquer que c'est un message reçu
          });
        });
      } else {
        print("Caractéristique FFE1 non trouvée.");
      }
    } catch (e) {
      print("Erreur lors de l'écoute des notifications : $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Bluetooth BLE App"),
        actions: [
          IconButton(
            icon: Icon(connectionStatus ? Icons.link_off : Icons.search),
            onPressed: connectionStatus ? disconnectDevice : startScan,
          ),
        ],
      ),
      body: Column(
        children: [
          StreamBuilder(
            stream: FlutterBluePlus.adapterState,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                bluetoothState = (snapshot.data == BluetoothAdapterState.on);
                return SwitchListTile(
                  title: Text('Activate Bluetooth'),
                  value: bluetoothState,
                  onChanged: (value) => toggleBluetooth(),
                );
              }
              return Container();
            },
          ),
          Expanded(
            child: connectionStatus
                ? ChatScreen(buffer: buffer)
                : ScanPage(onDeviceSelected: connectDevice),
          ),
          if (connectionStatus)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: controller,
                      decoration: InputDecoration(
                        labelText: 'Écrire un message',
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.send),
                    onPressed: sendMessage,
                  ),
                ],
              ),
            ),
          if (connectionStatus)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton(
                onPressed: disconnectDevice,
                child: Text('Disconnect'),
              ),
            ),
        ],
      ),
    );
  }
}