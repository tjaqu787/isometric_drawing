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
        return GestureDetector(
          onPanDown: (details) => _handlePanDown(details, context),
          onPanUpdate: (details) => _handlePanUpdate(details, context),
          onPanEnd: (details) => _handlePanEnd(context),
          child: CustomPaint(
            painter: SingleAxisPainter(state, axis),
            size: Size.infinite,
          ),
        );
      },
    );
  }

  void _handlePanDown(DragDownDetails details, BuildContext context) {
    final point = _convertToPoint3D(details.localPosition);
    state.startPoint = point;
    state.addPoint(point);
  }

  void _handlePanUpdate(DragUpdateDetails details, BuildContext context) {
    if (state.startPoint != null) {
      final endPoint = _convertToPoint3D(details.localPosition);
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
    // Convert 2D position to 3D based on axis
    switch (axis) {
      case ViewAxis.front:
        return Point3D(0, position.dx, position.dy);
      case ViewAxis.side:
        return Point3D(position.dx, 0, position.dy);
      case ViewAxis.top:
        return Point3D(position.dx, position.dy, 0);
    }
  }
}
