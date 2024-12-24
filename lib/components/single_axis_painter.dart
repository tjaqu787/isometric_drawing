import 'package:flutter/material.dart';
import 'dart:math';
import './isometric_state.dart';

class SingleAxisPainter extends CustomPainter {
  final AppState state;
  final ViewAxis axis;
  static const double scale = 50.0;
  static const double hitTestThreshold = 10.0;

  SingleAxisPainter(this.state, this.axis) : super(repaint: state);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.translate(size.width / 2, size.height / 2);

    final paint = Paint()
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    _drawGrid(canvas, size, paint);
    _drawBends(canvas, paint);
    _drawPoints(canvas, paint);
  }

  void _drawBends(Canvas canvas, Paint paint) {
    for (var bend in state.bends) {
      final isSelected = bend == state.selectedBend;

      paint.color = isSelected ? Colors.orange : Colors.blue;
      paint.strokeWidth = isSelected ? 3.0 : 2.0;

      // Draw all lines in the bend
      for (var line in bend.lines) {
        final start = _projectPoint(line.start);
        final end = _projectPoint(line.end);

        canvas.drawLine(start, end, paint);

        // Draw connection points
        _drawBendPoints(canvas, start, end, paint);
      }

      // If selected, draw rotation handle
      if (isSelected) {
        _drawRotationHandle(canvas, bend, paint);
      }
    }
  }

  void _drawRotationHandle(Canvas canvas, Bend bend, Paint paint) {
    // Draw a handle at the midpoint of the first line
    if (bend.lines.isNotEmpty) {
      final line = bend.lines.first;
      final start = _projectPoint(line.start);
      final end = _projectPoint(line.end);
      final midpoint = Offset(
        (start.dx + end.dx) / 2,
        (start.dy + end.dy) / 2,
      );

      paint.style = PaintingStyle.fill;
      canvas.drawCircle(midpoint, 6.0, paint);

      // Draw rotation indicator
      paint.style = PaintingStyle.stroke;
      paint.strokeWidth = 1.0;
      _drawRotationIndicator(canvas, midpoint, bend.inclination, paint);
    }
  }

  void _drawRotationIndicator(
      Canvas canvas, Offset center, double angle, Paint paint) {
    final radius = 15.0;
    final startAngle = -pi / 4;
    final endAngle = pi / 4;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      endAngle - startAngle,
      false,
      paint,
    );

    // Draw current rotation indicator
    final angleRad = angle * pi / 180;
    final indicatorPoint = Offset(
      center.dx + radius * cos(angleRad),
      center.dy + radius * sin(angleRad),
    );

    canvas.drawLine(center, indicatorPoint, paint);
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
      // Draw connection points with emphasis
      canvas.drawCircle(projected, 4.0, paint);
    }
  }

  void _drawBendPoints(Canvas canvas, Offset start, Offset end, Paint paint) {
    paint.style = PaintingStyle.fill;
    paint.color = Colors.blue.withOpacity(0.5);

    // Draw smaller circles at bendable points
    canvas.drawCircle(start, 3.0, paint);
    canvas.drawCircle(end, 3.0, paint);
  }

  Offset _projectPoint(Point3D point) {
    switch (axis) {
      case ViewAxis.front:
        return Offset(point.y * scale, -point.z * scale);
      case ViewAxis.side:
        return Offset(point.x * scale, -point.z * scale);
      case ViewAxis.top:
        return Offset(point.x * scale, point.y * scale);
    }
  }

  // Add method to help with hit testing
  bool isPointNearLine(Offset point, IsometricLine3D line) {
    final start = _projectPoint(line.start);
    final end = _projectPoint(line.end);

    return _distanceToLineSegment(point, start, end) < hitTestThreshold;
  }

  double _distanceToLineSegment(Offset p, Offset start, Offset end) {
    final a = p - start;
    final b = end - start;
    final bLen = b.distance;

    if (bLen == 0) return a.distance;

    final t = (a.dx * b.dx + a.dy * b.dy) / (bLen * bLen);

    if (t < 0) return a.distance;
    if (t > 1) return (p - end).distance;

    return (p - (start + b * t)).distance;
  }

  @override
  bool shouldRepaint(SingleAxisPainter oldDelegate) =>
      oldDelegate.state != state || oldDelegate.axis != axis;
}
