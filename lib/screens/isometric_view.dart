import 'package:flutter/material.dart';
import '../components/isometric_state.dart';
import '../components/isometric_components/isometric_window.dart';
import '../components/quick_settings_components/quick_settings.dart';

class IsometricView extends StatefulWidget {
  const IsometricView({super.key});

  @override
  State createState() => _IsometricViewState();
}

class _IsometricViewState extends State {
  late final AppState state;
  bool _isQuickSettingsFullScreen = false;

  @override
  void initState() {
    super.initState();
    state = AppState();
  }

  void _toggleQuickSettingsFullScreen() {
    setState(() {
      _isQuickSettingsFullScreen = !_isQuickSettingsFullScreen;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          if (_isQuickSettingsFullScreen) {
            return Stack(
              children: [
                QuickSettingsWindow(),
                Positioned(
                  top: 16,
                  right: 16,
                  child: IconButton(
                    icon: const Icon(Icons.fullscreen_exit),
                    onPressed: _toggleQuickSettingsFullScreen,
                    tooltip: 'Exit fullscreen',
                  ),
                ),
              ],
            );
          }

          final cellWidth = constraints.maxWidth / 2;
          final cellHeight = constraints.maxHeight / 2;

          return Column(
            children: [
              Row(
                children: [
                  SizedBox(
                    width: cellWidth,
                    height: cellHeight,
                    child: IsometricWindow(state: state, axis: ViewAxis.front),
                  ),
                  SizedBox(
                    width: cellWidth,
                    height: cellHeight,
                    child: IsometricWindow(state: state, axis: ViewAxis.side),
                  ),
                ],
              ),
              Row(
                children: [
                  SizedBox(
                    width: cellWidth,
                    height: cellHeight,
                    child: IsometricWindow(state: state, axis: ViewAxis.top),
                  ),
                  SizedBox(
                    width: cellWidth,
                    height: cellHeight,
                    child: Stack(
                      children: [
                        QuickSettingsWindow(),
                        Positioned(
                          top: 16,
                          right: 16,
                          child: IconButton(
                            icon: const Icon(Icons.fullscreen),
                            onPressed: _toggleQuickSettingsFullScreen,
                            tooltip: 'Enter fullscreen',
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}
