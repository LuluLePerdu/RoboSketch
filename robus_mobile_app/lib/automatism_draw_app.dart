import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:robus_mobile_app/views/drawing_page.dart';

class AutomatismApp extends StatelessWidget {
  const AutomatismApp({super.key});

  get lightTheme => null;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Special drawing app for special people",
      theme: lightTheme,
      home: const DrawingPage(connectedDevice: null,),
    );
  }
}
