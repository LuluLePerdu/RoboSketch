import 'package:flutter/material.dart';
import 'package:robus_mobile_app/views/drawing_page.dart';
import 'package:robus_mobile_app/views/remote_page.dart';

void main() {
  runApp(const AutomatismApp());
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
        title: const Text('Automatism Project'),
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
          ],
        ),
      ),
    );
  }
}