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

  Point3D(this.x, this.y, this.z);

  Offset toIsometric() {
    final isoX = (x - z) * cos(pi / 6);
    final isoY = y + (x + z) * sin(pi / 6);
    return Offset(isoX, isoY);
  }

  // Add method to project point based on view
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

  IsometricLine3D(this.start, this.end, this.isPreview);
}

class IsometricState extends ChangeNotifier {
  final List<Point3D> points = [];
  final List<IsometricLine3D> lines = [];
  Point3D? startPoint;

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
    lines.add(IsometricLine3D(previewLine.start, previewLine.end, false));
    notifyListeners();
  }

  // Helper method to convert 2D point to 3D based on view
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
