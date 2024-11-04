import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart' as bluePlus;
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart' as serial;
import 'package:robus_mobile_app/views/BluetoothConnectionsPage.dart';
import 'package:robus_mobile_app/views/drawing_page.dart';
import 'package:robus_mobile_app/views/remote_page.dart';

void main() {
  runApp(const AutomatismApp());
}

class BluetoothSetupPage extends StatefulWidget {
  const BluetoothSetupPage({Key? key}) : super(key: key);

  @override
  _BluetoothSetupPageState createState() => _BluetoothSetupPageState();
}

class _BluetoothSetupPageState extends State<BluetoothSetupPage> {
  late serial.BluetoothConnection _connection;

  @override
  void initState() {
    super.initState();
    _connectToDevice();
  }

  Future<void> _connectToDevice() async {
    List<serial.BluetoothDevice> devices = await serial.FlutterBluetoothSerial.instance.getBondedDevices();

    String deviceAddress = 'XX:XX:XX:XX:XX:XX';
    serial.BluetoothDevice device = devices.firstWhere((d) => d.address == deviceAddress);

    try {
      _connection = await serial.BluetoothConnection.toAddress(device.address);
      print('Connected to ${device.name}');
    } catch (error) {
      print('Error connecting to device: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Bluetooth Setup'),
      ),
      body: Center(
        child: Text('Connecting to Bluetooth device...'),
      ),
    );
  }
}

class AutomatismApp extends StatelessWidget {
  const AutomatismApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Automatism Project',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MainMenu(),
    );
  }
}

class MainMenu extends StatelessWidget {
  const MainMenu({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('S1 Project'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const DrawingPage(),
                  ),
                );
              },
              child: const Text('Drawing Section'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const RobotControlPage(),
                  ),
                );
              },
              child: const Text('Robot Control Section'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const BluetoothConnectionsPage(),
                  ),
                );
              },
              child: const Text('Bluetooth Connections'),
            ),
          ],
        ),
      ),
    );
  }
}
