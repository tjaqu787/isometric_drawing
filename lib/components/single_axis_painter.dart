import 'package:flutter/material.dart';
import 'dart:math';
import './isometric_state.dart';

class SingleAxisPainter extends CustomPainter {
  final IsometricState state;
  final ViewAxis axis;
  final IsometricLine3D? selectedLine;
  static const double scale = 50.0;
  static const double hitTestThreshold = 10.0; // Threshold for line selection

  SingleAxisPainter(this.state, this.axis, {this.selectedLine})
      : super(repaint: state);

  @override
  void paint(Canvas canvas, Size size) {
    // Translate canvas to center of the view
    canvas.translate(size.width / 2, size.height / 2);

    final paint = Paint()
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    _drawGrid(canvas, size, paint);
    _drawLines(canvas, paint);
    _drawPoints(canvas, paint);

    // Draw selected line with emphasis
    if (selectedLine != null) {
      _drawSelectedLine(canvas, paint, selectedLine!);
    }
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

  void _drawLines(Canvas canvas, Paint paint) {
    paint.style = PaintingStyle.stroke;

    for (var line in state.lines) {
      // Skip selected line as it will be drawn separately
      if (line == selectedLine) continue;

      paint.color = line.isPreview ? Colors.grey : Colors.blue;
      final start = _projectPoint(line.start);
      final end = _projectPoint(line.end);

      canvas.drawLine(start, end, paint);

      // Draw small circles at bendable points
      _drawBendPoints(canvas, start, end, paint);
    }
  }

  void _drawSelectedLine(Canvas canvas, Paint paint, IsometricLine3D line) {
    // Draw selected line with emphasis
    paint.color = Colors.orange;
    paint.strokeWidth = 3.0;

    final start = _projectPoint(line.start);
    final end = _projectPoint(line.end);

    // Draw the selected line
    canvas.drawLine(start, end, paint);

    // Draw manipulation handles
    _drawManipulationHandles(canvas, start, end, paint);
  }

  void _drawManipulationHandles(
      Canvas canvas, Offset start, Offset end, Paint paint) {
    paint.style = PaintingStyle.fill;
    paint.color = Colors.orange;

    // Draw handles at both ends
    canvas.drawCircle(start, 6.0, paint);
    canvas.drawCircle(end, 6.0, paint);

    // Draw direction indicators based on the current axis
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 1.0;

    // Draw manipulation guides based on the current view axis
    _drawAxisSpecificGuides(canvas, start, end, paint);
  }

  void _drawAxisSpecificGuides(
      Canvas canvas, Offset start, Offset end, Paint paint) {
    final guideLength = scale / 2;

    switch (axis) {
      case ViewAxis.front:
        // Show Y and Z manipulation guides
        _drawGuideLines(canvas, end, guideLength, [0, 90], paint);
        break;
      case ViewAxis.side:
        // Show X and Z manipulation guides
        _drawGuideLines(canvas, end, guideLength, [0, 90], paint);
        break;
      case ViewAxis.top:
        // Show X and Y manipulation guides
        _drawGuideLines(canvas, end, guideLength, [0, 90, 180, 270], paint);
        break;
    }
  }

  void _drawGuideLines(Canvas canvas, Offset center, double length,
      List<double> angles, Paint paint) {
    for (var angle in angles) {
      final radians = angle * pi / 180;
      final endPoint =
          center + Offset(cos(radians) * length, sin(radians) * length);
      canvas.drawLine(center, endPoint, paint);
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
      oldDelegate.state != state ||
      oldDelegate.axis != axis ||
      oldDelegate.selectedLine != selectedLine;
}
