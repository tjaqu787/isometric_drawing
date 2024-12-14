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
              onPanDown: (details) => _handlePanDown(details, context),
              onPanUpdate: (details) => _handlePanUpdate(details, context),
              onPanEnd: (details) => _handlePanEnd(context),
              child: CustomPaint(
                painter: SingleAxisPainter(state, axis),
                size: Size(constraints.maxWidth, constraints.maxHeight),
              ),
            );
          },
        );
      },
    );
  }

  void _handlePanDown(DragDownDetails details, BuildContext context) {
    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final size = renderBox.size;
    final center = Offset(size.width / 2, size.height / 2);
    final localPosition = details.localPosition - center;

    final point = _convertToPoint3D(localPosition);
    state.startPoint = point;
    state.addPoint(point);
  }

  void _handlePanUpdate(DragUpdateDetails details, BuildContext context) {
    if (state.startPoint != null) {
      final RenderBox renderBox = context.findRenderObject() as RenderBox;
      final size = renderBox.size;
      final center = Offset(size.width / 2, size.height / 2);
      final localPosition = details.localPosition - center;

      final endPoint = _convertToPoint3D(localPosition);
      state.updatePreviewLine(
          IsometricLine3D(state.startPoint!, endPoint, true));
    }
  }

  void _handlePanEnd(BuildContext context) {
    if (state.startPoint != null) {
      state.commitPreviewLine();
      state.startPoint = null;
    }
  }

  Point3D _convertToPoint3D(Offset position) {
    // Convert to grid coordinates
    final gridX = position.dx / SingleAxisPainter.scale;
    final gridY = position.dy / SingleAxisPainter.scale;

    // Round to nearest grid point
    final roundedX = (gridX).round().toDouble();
    final roundedY = (gridY).round().toDouble();

    // Convert 2D position to 3D based on axis
    switch (axis) {
      case ViewAxis.front:
        return Point3D(0, roundedX, -roundedY);
      case ViewAxis.side:
        return Point3D(roundedX, 0, -roundedY);
      case ViewAxis.top:
        return Point3D(roundedX, roundedY, 0);
    }
  }
}
