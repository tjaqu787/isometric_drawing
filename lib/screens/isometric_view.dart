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
    state = IsometricState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
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
                    child: QuickSettingsWindow(state: state),
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
