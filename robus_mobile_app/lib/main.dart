import 'package:flutter/material.dart';
import 'package:robus_mobile_app/models/bluetooth.dart';
import 'package:robus_mobile_app/views/drawing_page.dart';

void main() {
  runApp(const AutomatismApp());
}

class AutomatismApp extends StatelessWidget {
  const AutomatismApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pirus Project',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MainMenu(),
    );
  }
}

class MainMenu extends StatelessWidget {
  const MainMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pirus'),
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
                    builder: (context) => const DrawingPage(connectedDevice: null,),
                  ),
                );
              },
              child: const Text('Test Dessin'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => BluetoothApp(),
                  ),
                );
              },
              child: const Text('Pirus'),
            ),
          ],
        ),
      ),
    );
  }
}