import 'package:flutter/material.dart';
import 'dart:math';

enum ViewAxis {
  front,
  side,
  top,
}

class Point3D {
  final double x;
  final double y;
  final double z;
  double? angle;

  Point3D(this.x, this.y, this.z, [this.angle]);

  Offset toIsometric() {
    final isoX = (x - z) * cos(pi / 6);
    final isoY = y + (x + z) * sin(pi / 6);
    return Offset(isoX, isoY);
  }

  Offset projectToView(ViewAxis viewAxis) {
    switch (viewAxis) {
      case ViewAxis.front:
        return Offset(y, z); // YZ plane
      case ViewAxis.side:
        return Offset(x, z); // XZ plane
      case ViewAxis.top:
        return Offset(x, y); // XY plane
    }
  }
}

class IsometricLine3D {
  final Point3D start;
  final Point3D end;
  final bool isPreview;
  double? length;

  IsometricLine3D(this.start, this.end, this.isPreview, [this.length]);

  // Helper method to calculate actual length if needed
  double calculateActualLength() {
    final dx = end.x - start.x;
    final dy = end.y - start.y;
    final dz = end.z - start.z;
    return sqrt(dx * dx + dy * dy + dz * dz);
  }
}

class IsometricState extends ChangeNotifier {
  final List<Point3D> points = [];
  final List<IsometricLine3D> lines = [];
  Point3D? startPoint;

  // Get current state for undo/redo functionality
  Map<String, dynamic> getCurrentState() {
    return {
      'points': points
          .map((p) => {
                'x': p.x,
                'y': p.y,
                'z': p.z,
                'angle': p.angle,
              })
          .toList(),
      'lines': lines
          .map((l) => {
                'start': {
                  'x': l.start.x,
                  'y': l.start.y,
                  'z': l.start.z,
                  'angle': l.start.angle,
                },
                'end': {
                  'x': l.end.x,
                  'y': l.end.y,
                  'z': l.end.z,
                  'angle': l.end.angle,
                },
                'isPreview': l.isPreview,
                'length': l.length,
              })
          .toList(),
    };
  }

  // Restore state from saved state
  void restoreState(Map<String, dynamic> state) {
    points.clear();
    lines.clear();

    final pointsList = state['points'] as List;
    final linesList = state['lines'] as List;

    for (var p in pointsList) {
      points.add(Point3D(
        p['x'] as double,
        p['y'] as double,
        p['z'] as double,
        p['angle'] as double?,
      ));
    }

    for (var l in linesList) {
      final start = l['start'];
      final end = l['end'];
      lines.add(IsometricLine3D(
        Point3D(
          start['x'] as double,
          start['y'] as double,
          start['z'] as double,
          start['angle'] as double?,
        ),
        Point3D(
          end['x'] as double,
          end['y'] as double,
          end['z'] as double,
          end['angle'] as double?,
        ),
        l['isPreview'] as bool,
        l['length'] as double?,
      ));
    }

    notifyListeners();
  }

  // Clear all points and lines
  void clearAll() {
    points.clear();
    lines.clear();
    startPoint = null;
    notifyListeners();
  }

  // Add a box offset (creates a box-shaped bend)
  void addBoxOffset() {
    if (points.isEmpty) return;

    final lastPoint = points.last;
    final offsetDistance = 1.0; // You can adjust this value

    // Create points for box offset
    final point1 =
        Point3D(lastPoint.x + offsetDistance, lastPoint.y, lastPoint.z);
    final point2 = Point3D(lastPoint.x + offsetDistance,
        lastPoint.y + offsetDistance, lastPoint.z);
    final point3 = Point3D(lastPoint.x + offsetDistance * 2,
        lastPoint.y + offsetDistance, lastPoint.z);

    // Add points
    points.addAll([point1, point2, point3]);

    // Add lines connecting the points
    lines.add(IsometricLine3D(lastPoint, point1, false, offsetDistance));
    lines.add(IsometricLine3D(point1, point2, false, offsetDistance));
    lines.add(IsometricLine3D(point2, point3, false, offsetDistance));

    notifyListeners();
  }

  // Add a simple offset (diagonal bend)
  void addOffset() {
    if (points.isEmpty) return;

    final lastPoint = points.last;
    final offsetDistance = 1.0; // You can adjust this value

    // Create points for offset
    final point1 = Point3D(lastPoint.x + offsetDistance,
        lastPoint.y + offsetDistance, lastPoint.z);

    // Add point
    points.add(point1);

    // Add line connecting the points
    lines.add(IsometricLine3D(
      lastPoint,
      point1,
      false,
      offsetDistance * sqrt(2), // Diagonal length
    ));

    notifyListeners();
  }

  // Add a 90-degree bend
  void add90Degree() {
    if (points.isEmpty) return;

    final lastPoint = points.last;
    final bendRadius = 1.0; // You can adjust this value

    // Create point for 90-degree bend
    final point1 = Point3D(
      lastPoint.x,
      lastPoint.y + bendRadius,
      lastPoint.z,
      90.0, // Store the angle
    );

    // Add point
    points.add(point1);

    // Add line connecting the points
    lines.add(IsometricLine3D(lastPoint, point1, false, bendRadius));

    notifyListeners();
  }

  void addPoint(Point3D point) {
    points.add(point);
    notifyListeners();
  }

  void addLine(IsometricLine3D line) {
    lines.add(line);
    notifyListeners();
  }

  void updatePreviewLine(IsometricLine3D line) {
    lines.removeWhere((l) => l.isPreview);
    lines.add(line);
    notifyListeners();
  }

  void commitPreviewLine() {
    final previewLine = lines.lastWhere((l) => l.isPreview);
    lines.removeLast();
    lines.add(IsometricLine3D(
        previewLine.start, previewLine.end, false, previewLine.length));
    notifyListeners();
  }

  // Helper method to update a point's angle
  void updatePointAngle(Point3D point, double angle) {
    final index = points.indexOf(point);
    if (index != -1) {
      points[index] = Point3D(point.x, point.y, point.z, angle);
      notifyListeners();
    }
  }

  // Helper method to update a line's length
  void updateLineLength(IsometricLine3D line, double length) {
    final index = lines.indexOf(line);
    if (index != -1) {
      lines[index] =
          IsometricLine3D(line.start, line.end, line.isPreview, length);
      notifyListeners();
    }
  }

  Point3D convertToPoint3D(Offset position, ViewAxis viewAxis,
      [double scale = 50.0]) {
    final scaledX = position.dx / scale;
    final scaledY = position.dy / scale;
    switch (viewAxis) {
      case ViewAxis.front:
        return Point3D(0, scaledX, scaledY); // YZ plane
      case ViewAxis.side:
        return Point3D(scaledX, 0, scaledY); // XZ plane
      case ViewAxis.top:
        return Point3D(scaledX, scaledY, 0); // XY plane
    }
  }
}
