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
  IsometricLine3D? selectedLine;

  Point3D get startingPoint => Point3D(-5, 0, 0);

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

  void clearAll() {
    points.clear();
    lines.clear();
    notifyListeners();
  }

  void selectLineNearPoint(Offset point, ViewAxis axis) {
    // Find the closest line to the given point
    selectedLine = lines.cast<IsometricLine3D?>().firstWhere(
          (line) => _isPointNearLine(point, line!, axis),
          orElse: () => null,
        );
    notifyListeners();
  }

  bool _isPointNearLine(Offset point, IsometricLine3D line, ViewAxis axis) {
    // Implement hit testing based on the current view axis
    // You can reuse the logic from SingleAxisPainter's isPointNearLine method
    return true; // Implement proper hit testing
  }

  void updateSelectedLineAngle(double angle) {
    if (selectedLine == null) return;

    // Update the end point of the selected line based on the angle
    final start = selectedLine!.start;
    final length = selectedLine!.calculateActualLength();

    // Calculate new end point based on angle and current axis
    final end = _calculateNewEndPoint(start, length, angle);

    // Replace the selected line with the rotated version
    final index = lines.indexOf(selectedLine!);
    if (index != -1) {
      lines[index] = IsometricLine3D(start, end, false, length);
      selectedLine = lines[index];
      notifyListeners();
    }
  }

  Point3D _calculateNewEndPoint(Point3D start, double length, double angle) {
    // Calculate new end point based on rotation angle
    // This will depend on your specific requirements for how lines should rotate
    return Point3D(
      start.x + length * cos(angle * pi / 180),
      start.y,
      start.z + length * sin(angle * pi / 180),
    );
  }

  void addBoxOffset() {
    final lastPoint = points.isEmpty ? startingPoint : points.last;

    // Create symbolic box shape
    final point1 = Point3D(lastPoint.x + 1, lastPoint.y, lastPoint.z);
    final point2 = Point3D(lastPoint.x + 1, lastPoint.y + 1, lastPoint.z);
    final point3 = Point3D(lastPoint.x + 2, lastPoint.y + 1, lastPoint.z);

    // Add points
    points.addAll([point1, point2, point3]);

    // Add lines with symbolic measurements
    lines.add(IsometricLine3D(lastPoint, point1, false,
        1.0)); // Length can be modified from measurements
    lines.add(IsometricLine3D(point1, point2, false, 1.0));
    lines.add(IsometricLine3D(point2, point3, false, 1.0));

    notifyListeners();
  }

  void addOffset() {
    final lastPoint = points.isEmpty ? startingPoint : points.last;

    // Create symbolic offset
    final point1 = Point3D(lastPoint.x + 1, lastPoint.y + 1, lastPoint.z);
    points.add(point1);

    // Add line with symbolic measurement
    lines.add(IsometricLine3D(
        lastPoint, point1, false, 1.4)); // Approximate length for display

    notifyListeners();
  }

  void add90Degree() {
    final lastPoint = points.isEmpty ? startingPoint : points.last;

    // Create 90-degree bend
    final point1 = Point3D(lastPoint.x, lastPoint.y + 1, lastPoint.z);
    points.add(point1);

    // Add line with symbolic measurement and 90-degree angle
    lines.add(IsometricLine3D(lastPoint, point1, false, 1.0));

    notifyListeners();
  }

  void updateLineMeasurement(int lineIndex, double newLength) {
    if (lineIndex >= 0 && lineIndex < lines.length) {
      final line = lines[lineIndex];
      lines[lineIndex] =
          IsometricLine3D(line.start, line.end, line.isPreview, newLength);
      notifyListeners();
    }
  }
}
