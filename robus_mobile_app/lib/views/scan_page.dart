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
        return ListView(
          children: snapshot.data!.map((r) {
            return ListTile(
              title: Text(r.device.name),
              trailing: ElevatedButton(
                onPressed: () => onDeviceSelected(r.device),
                child: Text("Connect"),
              ),
            );
          }).toList(),
        );
      },
    );
  }
}