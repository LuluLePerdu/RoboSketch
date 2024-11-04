import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

class BluetoothConnectionsPage extends StatefulWidget {
  const BluetoothConnectionsPage({Key? key}) : super(key: key);

  @override
  _BluetoothConnectionsPageState createState() => _BluetoothConnectionsPageState();
}

class _BluetoothConnectionsPageState extends State<BluetoothConnectionsPage> {
  List<BluetoothDevice> devices = [];
  bool isScanning = false;

  @override
  void initState() {
    super.initState();
    _startScan();
  }

  void _startScan() async {
    setState(() => isScanning = true);
    try {
      List<BluetoothDevice> bondedDevices = await FlutterBluetoothSerial.instance.getBondedDevices();
      setState(() {
        devices = bondedDevices;
        isScanning = false;
      });
    } catch (e) {
      print("Error while scanning for devices: $e");
      setState(() => isScanning = false);
    }
  }

  Future<void> _connectToDevice(BluetoothDevice device) async {
    try {
      BluetoothConnection connection = await BluetoothConnection.toAddress(device.address);
      print("Connected to ${device.name}");
      Navigator.pop(context, connection); // Return to previous page with the connection
    } catch (e) {
      print("Error connecting to ${device.name}: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Available Bluetooth Devices'),
      ),
      body: isScanning
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: devices.length,
        itemBuilder: (context, index) {
          BluetoothDevice device = devices[index];
          return ListTile(
            title: Text(device.name ?? "Unknown Device"),
            subtitle: Text(device.address),
            onTap: () => _connectToDevice(device),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _startScan,
        child: const Icon(Icons.refresh),
      ),
    );
  }
}