import 'package:flutter/material.dart';
import '../data_and_state/isometric_state.dart';
import 'package:provider/provider.dart';

class QuickSettingsButtonBar extends StatelessWidget {
  const QuickSettingsButtonBar({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          ElevatedButton(
            onPressed: appState.canUndo() ? () => appState.undo() : null,
            child: const Text('Undo'),
          ),
          ElevatedButton(
            onPressed: () => appState.addBoxOffset(),
            child: const Text('Box Offset'),
          ),
          ElevatedButton(
            onPressed: () => appState.addOffset(),
            child: const Text('Offset'),
          ),
          ElevatedButton(
            onPressed: () => appState.add90Degree(),
            child: const Text('90°'),
          ),
          ElevatedButton(
            onPressed: () => appState.addKick(),
            child: const Text('Kick'),
          ),
          ElevatedButton(
            onPressed: () => appState.clearAll(),
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }
}
