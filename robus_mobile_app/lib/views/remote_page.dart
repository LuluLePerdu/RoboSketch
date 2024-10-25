import 'package:flutter/material.dart';

class RobotControlPage extends StatelessWidget {
  const RobotControlPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Robot Control"),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            "Test mouvement bluethoot",
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_upward),
                iconSize: 50,
                onPressed: () {
                  // Placeholder for forward action
                },
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back),
                iconSize: 50,
                onPressed: () {
                  // Placeholder for left action
                },
              ),
              IconButton(
                icon: const Icon(Icons.stop),
                iconSize: 50,
                onPressed: () {
                  // Placeholder for stop action
                },
              ),
              IconButton(
                icon: const Icon(Icons.arrow_forward),
                iconSize: 50,
                onPressed: () {
                  // Placeholder for right action
                },
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_downward),
                iconSize: 50,
                onPressed: () {
                  // Placeholder for backward action
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}