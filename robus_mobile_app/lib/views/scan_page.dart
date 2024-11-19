import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class ScanPage extends StatelessWidget {
  final Function(BluetoothDevice) onDeviceSelected;

  ScanPage({required this.onDeviceSelected});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Scan Bluetooth'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              FlutterBluePlus.startScan(timeout: const Duration(seconds: 4));
            },
          ),
        ],
      ),
      body: StreamBuilder<List<ScanResult>>(
        stream: FlutterBluePlus.scanResults,
        initialData: const [],
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(
              child: Text(
                'Erreur lors de la recherche des périphériques',
                style: TextStyle(color: Colors.red),
              ),
            );
          }

          final devices = snapshot.data ?? [];
          if (devices.isEmpty) {
            return Center(
              child: ElevatedButton.icon(
                onPressed: () {
                  FlutterBluePlus.startScan(timeout: const Duration(seconds: 4));
                },
                icon: const Icon(Icons.refresh),
                label: const Text('Rechercher des périphériques'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  textStyle: const TextStyle(fontSize: 16),
                ),
              ),
            );
          }

          return ListView.builder(
            itemCount: devices.length,
            itemBuilder: (context, index) {
              final result = devices[index];
              final device = result.device;

              return Card(
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                child: ListTile(
                  leading: Icon(Icons.bluetooth, color: Colors.blue.shade700),
                  title: Text(
                    device.platformName.isNotEmpty
                        ? device.platformName
                        : 'Nom inconnu',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text('ID: ${device.id.toString()}'),
                  trailing: ElevatedButton.icon(
                    onPressed: () => onDeviceSelected(device),
                    icon: const Icon(Icons.link),
                    label: const Text("Connecter"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.lightBlueAccent,
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
