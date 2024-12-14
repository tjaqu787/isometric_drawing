import 'package:flutter/material.dart';
import 'dart:math';
import './isometric_state.dart';

// single_axis_painter.dart
class SingleAxisPainter extends CustomPainter {
  final IsometricState state;
  final ViewAxis axis;
  static const double scale = 50.0;

  SingleAxisPainter(this.state, this.axis);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blue
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    _drawGrid(canvas, size, paint);
    _drawPoints(canvas, paint);
    _drawLines(canvas, paint);
  }

  void _drawGrid(Canvas canvas, Size size, Paint paint) {
    paint.color = Colors.grey.withOpacity(0.3);

    // Draw basic 2D grid based on axis
    for (double i = 0; i < max(size.width, size.height); i += scale) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), paint);
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), paint);
    }
  }

  void _drawPoints(Canvas canvas, Paint paint) {
    paint.color = Colors.red;

    for (var point in state.points) {
      final projected = _projectPoint(point);
      canvas.drawCircle(projected, 4.0, paint);
    }
  }

  void _drawLines(Canvas canvas, Paint paint) {
    for (var line in state.lines) {
      paint.color = line.isPreview ? Colors.grey : Colors.blue;
      final start = _projectPoint(line.start);
      final end = _projectPoint(line.end);
      canvas.drawLine(start, end, paint);
    }
  }

  Offset _projectPoint(Point3D point) {
    // Project 3D point to 2D based on axis
    switch (axis) {
      case ViewAxis.front:
        return Offset(point.y, point.z) * scale;
      case ViewAxis.side:
        return Offset(point.x, point.z) * scale;
      case ViewAxis.top:
        return Offset(point.x, point.y) * scale;
    }
  }

  @override
  bool shouldRepaint(SingleAxisPainter oldDelegate) => true;
}
