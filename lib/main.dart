import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Add this import
import 'screens/isometric_view.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized(); // Add this line

  // Force landscape mode
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]).then((_) {
    runApp(const MyApp());
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Isometric View Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const IsometricView(),
    );
  }
}
