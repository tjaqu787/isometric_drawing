import 'package:flutter/material.dart';
import '../components/isometric_state.dart';
import '../components/isometric_window.dart';
import '../components/quick_settings.dart';

class IsometricView extends StatefulWidget {
  const IsometricView({super.key});

  @override
  State<IsometricView> createState() => _IsometricViewState();
}

class _IsometricViewState extends State<IsometricView> {
  late final IsometricState state;

  @override
  void initState() {
    super.initState();
    state = IsometricState(); // Initialize the state here
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GridView.count(
        crossAxisCount: 2,
        children: [
          IsometricWindow(state: state, axis: ViewAxis.front),
          IsometricWindow(state: state, axis: ViewAxis.side),
          IsometricWindow(state: state, axis: ViewAxis.top),
          QuickSettingsWindow(state: state),
        ],
      ),
    );
  }
}
