import 'package:flutter/material.dart';
import './isometric_state.dart';
import './single_axis_painter.dart';

class IsometricWindow extends StatelessWidget {
  final IsometricState state;
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
                  selectedLine: state.selectedLine,
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

    // Find the closest line to start rotating
    state.selectLineNearPoint(localPosition, axis);
  }

  void _handleRotationUpdate(DragUpdateDetails details, BuildContext context) {
    if (state.selectedLine == null) return;

    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final size = renderBox.size;
    final center = Offset(size.width / 2, size.height / 2);
    final localPosition = details.localPosition - center;

    // Calculate rotation based on drag position
    final angle = _calculateRotationAngle(localPosition);
    state.updateSelectedLineAngle(angle);
  }

  double _calculateRotationAngle(Offset position) {
    // Calculate angle based on current axis and position
    switch (axis) {
      case ViewAxis.front:
        return -((position.dy / SingleAxisPainter.scale) *
            5); // Adjust sensitivity
      case ViewAxis.side:
        return -((position.dy / SingleAxisPainter.scale) * 5);
      case ViewAxis.top:
        return ((position.dx / SingleAxisPainter.scale) * 5);
    }
  }
}
