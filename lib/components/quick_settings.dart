import 'package:flutter/material.dart';
import './isometric_state.dart';

// quick_settings_window.dart
class QuickSettingsWindow extends StatelessWidget {
  final IsometricState state;

  const QuickSettingsWindow({
    super.key,
    required this.state,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 16),
            // Add your quick settings controls here
            ElevatedButton(
              onPressed: () {
                // Add clear functionality
                state.points.clear();
                state.lines.clear();
                state.notifyListeners();
              },
              child: const Text('Clear All'),
            ),
          ],
        ),
      ),
    );
  }
}
