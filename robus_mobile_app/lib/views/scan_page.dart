import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class ScanPage extends StatelessWidget {
  final Function(BluetoothDevice) onDeviceSelected;

  ScanPage({required this.onDeviceSelected});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<ScanResult>>(
      stream: FlutterBluePlus.scanResults,
      initialData: [],
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return const Center(child: Text('Erreur de connexion'));
        }

        if (snapshot.data!.isEmpty) {
          return const Center(child: Text('Aucun périphérique trouvé'));
        }

        return ListView(
          children: snapshot.data!.map((r) {
            if (r.device.platformName.isNotEmpty) {
              return ListTile(
                title: Text(r.device.platformName),
                trailing: ElevatedButton(
                  onPressed: () => onDeviceSelected(r.device),
                  child: const Text("Connect"),
                ),
              );
            } else {
              // Si le périphérique n'a pas de nom valide, ne rien afficher
              return Container();
            }
          }).toList(),
        );
      },
    );
  }
}
