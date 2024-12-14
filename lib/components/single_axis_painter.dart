import 'package:flutter/material.dart';
import 'dart:math';
import './isometric_state.dart';

class SingleAxisPainter extends CustomPainter {
  final IsometricState state;
  final ViewAxis axis;
  static const double scale = 50.0;

  SingleAxisPainter(this.state, this.axis);

  @override
  void paint(Canvas canvas, Size size) {
    // Translate canvas to center of the view
    canvas.translate(size.width / 2, size.height / 2);

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

    final halfWidth = size.width / 2;
    final halfHeight = size.height / 2;

    // Draw horizontal lines
    for (double i = -halfHeight; i <= halfHeight; i += scale) {
      canvas.drawLine(Offset(-halfWidth, i), Offset(halfWidth, i), paint);
    }

    // Draw vertical lines
    for (double i = -halfWidth; i <= halfWidth; i += scale) {
      canvas.drawLine(Offset(i, -halfHeight), Offset(i, halfHeight), paint);
    }
  }

  void _drawPoints(Canvas canvas, Paint paint) {
    paint.color = Colors.red;
    paint.style = PaintingStyle.fill;

    for (var point in state.points) {
      final projected = _projectPoint(point);
      canvas.drawCircle(projected, 4.0, paint);
    }
  }

  void _drawLines(Canvas canvas, Paint paint) {
    paint.style = PaintingStyle.stroke;

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
        return Offset(point.y * scale, -point.z * scale);
      case ViewAxis.side:
        return Offset(point.x * scale, -point.z * scale);
      case ViewAxis.top:
        return Offset(point.x * scale, point.y * scale);
    }
  }

  @override
  bool shouldRepaint(SingleAxisPainter oldDelegate) =>
      oldDelegate.state != state || oldDelegate.axis != axis;
}
