import 'package:flutter/material.dart';
import './isometric_state.dart';
import './single_axis_painter.dart';

class IsometricWindow extends StatelessWidget {
  final AppState state;
  final ViewAxis axis;

  const IsometricWindow({
    super.key,
    required this.state,
    required this.axis,
  });

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: state,
      builder: (context, _) {
        return LayoutBuilder(
          builder: (context, constraints) {
            return GestureDetector(
              onPanStart: (details) => _handleRotationStart(details, context),
              onPanUpdate: (details) => _handleRotationUpdate(details, context),
              child: CustomPaint(
                painter: SingleAxisPainter(
                  state,
                  axis,
                ),
                size: Size(constraints.maxWidth, constraints.maxHeight),
              ),
            );
          },
        );
      },
    );
  }

  void _handleRotationStart(DragStartDetails details, BuildContext context) {
    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final size = renderBox.size;
    final center = Offset(size.width / 2, size.height / 2);
    final localPosition = details.localPosition - center;

    state.selectBendNearPoint(localPosition, axis);
  }

  void _handleRotationUpdate(DragUpdateDetails details, BuildContext context) {
    if (state.selectedBend == null) return;

    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final size = renderBox.size;
    final center = Offset(size.width / 2, size.height / 2);
    final localPosition = details.localPosition - center;

    // Calculate new inclination based on drag position
    final newInclination = _calculateInclination(localPosition, axis);
    state.rotateBend(newInclination);
  }

  double _calculateInclination(Offset position, ViewAxis axis) {
    // Calculate inclination based on current axis and position
    switch (axis) {
      case ViewAxis.front:
        return -((position.dy / SingleAxisPainter.scale) * 5);
      case ViewAxis.side:
        return -((position.dy / SingleAxisPainter.scale) * 5);
      case ViewAxis.top:
        return ((position.dx / SingleAxisPainter.scale) * 5);
    }
  }
}
