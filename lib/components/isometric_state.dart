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

  double calculateActualLength() {
    final dx = end.x - start.x;
    final dy = end.y - start.y;
    final dz = end.z - start.z;
    return sqrt(dx * dx + dy * dy + dz * dz);
  }
}

class Bend {
  final double distance;
  final double degrees;
  double inclination;
  final List<IsometricLine3D> lines;
  final BendType type;

  Bend({
    required this.distance,
    required this.degrees,
    this.inclination = 0,
    required this.lines,
    required this.type,
  });
}

enum BendType { boxOffset, offset, degree90 }

class IsometricState extends ChangeNotifier {
  final List<Point3D> points = [];
  final List<Bend> bends = [];
  Bend? selectedBend;
  Point3D get startingPoint => Point3D(-5, 0, 0);

  void addBoxOffset() {
    final lastPoint = points.isEmpty ? startingPoint : points.last;
    final distance = 1.0;

    // Create points for box offset
    final point1 = Point3D(lastPoint.x + distance, lastPoint.y, lastPoint.z);
    final point2 =
        Point3D(lastPoint.x + distance, lastPoint.y + distance, lastPoint.z);
    final point3 = Point3D(
        lastPoint.x + distance * 2, lastPoint.y + distance, lastPoint.z);

    points.addAll([point1, point2, point3]);

    // Create lines for the box offset
    final lines = [
      IsometricLine3D(lastPoint, point1, false, distance),
      IsometricLine3D(point1, point2, false, distance),
      IsometricLine3D(point2, point3, false, distance),
    ];

    final bend = Bend(
      distance: distance,
      degrees: 90,
      lines: lines,
      type: BendType.boxOffset,
    );

    bends.add(bend);
    notifyListeners();
  }

  void addOffset() {
    final lastPoint = points.isEmpty ? startingPoint : points.last;
    final distance = 1.0;

    final point1 = Point3D(
      lastPoint.x + distance * cos(pi / 4),
      lastPoint.y + distance * sin(pi / 4),
      lastPoint.z,
    );
    points.add(point1);

    final lines = [
      IsometricLine3D(lastPoint, point1, false, distance),
    ];

    final bend = Bend(
      distance: distance,
      degrees: 45,
      lines: lines,
      type: BendType.offset,
    );

    bends.add(bend);
    notifyListeners();
  }

  void add90Degree() {
    final lastPoint = points.isEmpty ? startingPoint : points.last;
    final distance = 1.0;

    final point1 = Point3D(lastPoint.x, lastPoint.y + distance, lastPoint.z);
    points.add(point1);

    final lines = [
      IsometricLine3D(lastPoint, point1, false, distance),
    ];

    final bend = Bend(
      distance: distance,
      degrees: 90,
      lines: lines,
      type: BendType.degree90,
    );

    bends.add(bend);
    notifyListeners();
  }

  void selectBendNearPoint(Offset point, ViewAxis axis) {
    selectedBend = bends.cast<Bend?>().firstWhere(
          (bend) =>
              bend!.lines.any((line) => _isLineNearPoint(line, point, axis)),
          orElse: () => null,
        );
    notifyListeners();
  }

  bool _isLineNearPoint(IsometricLine3D line, Offset point, ViewAxis axis) {
    const double threshold = 10.0;
    final start = _projectPoint(line.start, axis);
    final end = _projectPoint(line.end, axis);

    return _distanceToLineSegment(point, start, end) < threshold;
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

  Offset _projectPoint(Point3D point, ViewAxis axis) {
    const double scale = 50.0;
    switch (axis) {
      case ViewAxis.front:
        return Offset(point.y * scale, -point.z * scale);
      case ViewAxis.side:
        return Offset(point.x * scale, -point.z * scale);
      case ViewAxis.top:
        return Offset(point.x * scale, point.y * scale);
    }
  }

  void rotateBend(double newInclination) {
    if (selectedBend == null) return;

    selectedBend!.inclination = newInclination;
    _updateBendGeometry(selectedBend!);
    notifyListeners();
  }

  void _updateBendGeometry(Bend bend) {
    switch (bend.type) {
      case BendType.boxOffset:
        _updateBoxOffsetGeometry(bend);
        break;
      case BendType.offset:
        _updateOffsetGeometry(bend);
        break;
      case BendType.degree90:
        _update90DegreeGeometry(bend);
        break;
    }
  }

  void _updateBoxOffsetGeometry(Bend bend) {
    if (bend.lines.isEmpty || points.isEmpty) return;

    final startPoint = bend.lines.first.start;
    final distance = bend.distance;
    final inclinationRad = bend.inclination * pi / 180;

    final point1 = Point3D(
      startPoint.x + distance * cos(inclinationRad),
      startPoint.y + distance * sin(inclinationRad),
      startPoint.z,
    );

    final point2 = Point3D(
      point1.x,
      point1.y + distance,
      point1.z,
    );

    final point3 = Point3D(
      point2.x + distance,
      point2.y,
      point2.z,
    );

    bend.lines[0] = IsometricLine3D(startPoint, point1, false, distance);
    bend.lines[1] = IsometricLine3D(point1, point2, false, distance);
    bend.lines[2] = IsometricLine3D(point2, point3, false, distance);

    final startIndex = points.indexOf(startPoint);
    if (startIndex != -1 && startIndex + 3 <= points.length) {
      points[startIndex + 1] = point1;
      points[startIndex + 2] = point2;
      points[startIndex + 3] = point3;
    }
  }

  void _updateOffsetGeometry(Bend bend) {
    if (bend.lines.isEmpty || points.isEmpty) return;

    final startPoint = bend.lines.first.start;
    final distance = bend.distance;
    final inclinationRad = bend.inclination * pi / 180;

    final endPoint = Point3D(
      startPoint.x + distance * cos(inclinationRad),
      startPoint.y + distance * sin(inclinationRad),
      startPoint.z,
    );

    bend.lines[0] = IsometricLine3D(startPoint, endPoint, false, distance);

    final startIndex = points.indexOf(startPoint);
    if (startIndex != -1 && startIndex + 1 < points.length) {
      points[startIndex + 1] = endPoint;
    }
  }

  void _update90DegreeGeometry(Bend bend) {
    if (bend.lines.isEmpty || points.isEmpty) return;

    final startPoint = bend.lines.first.start;
    final distance = bend.distance;
    final inclinationRad = bend.inclination * pi / 180;

    final endPoint = Point3D(
      startPoint.x + distance * cos(inclinationRad),
      startPoint.y + distance * sin(inclinationRad),
      startPoint.z,
    );

    bend.lines[0] = IsometricLine3D(startPoint, endPoint, false, distance);

    final startIndex = points.indexOf(startPoint);
    if (startIndex != -1 && startIndex + 1 < points.length) {
      points[startIndex + 1] = endPoint;
    }
  }

  void updateBendProperties(int index, Map<String, double> properties) {
    if (index < 0 || index >= bends.length) return;

    final bend = bends[index];
    if (properties.containsKey('distance')) {
      // Update distance logic
    }
    if (properties.containsKey('inclination')) {
      bend.inclination = properties['inclination']!;
      _updateBendGeometry(bend);
    }
    notifyListeners();
  }

  void clearAll() {
    points.clear();
    bends.clear();
    selectedBend = null;
    notifyListeners();
  }

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
      'bends': bends
          .map((b) => {
                'distance': b.distance,
                'degrees': b.degrees,
                'inclination': b.inclination,
                'type': b.type.toString(),
                'lines': b.lines
                    .map((l) => {
                          'start': {
                            'x': l.start.x,
                            'y': l.start.y,
                            'z': l.start.z
                          },
                          'end': {'x': l.end.x, 'y': l.end.y, 'z': l.end.z},
                          'length': l.length,
                        })
                    .toList(),
              })
          .toList(),
    };
  }

  void restoreState(Map<String, dynamic> state) {
    points.clear();
    bends.clear();

    final pointsList = state['points'] as List;
    for (var p in pointsList) {
      points.add(Point3D(
        p['x'] as double,
        p['y'] as double,
        p['z'] as double,
        p['angle'] as double?,
      ));
    }

    final bendsList = state['bends'] as List;
    for (var b in bendsList) {
      final linesList = b['lines'] as List;
      final lines = linesList.map((l) {
        final start = l['start'];
        final end = l['end'];
        return IsometricLine3D(
          Point3D(
              start['x'] as double, start['y'] as double, start['z'] as double),
          Point3D(end['x'] as double, end['y'] as double, end['z'] as double),
          false,
          l['length'] as double?,
        );
      }).toList();

      bends.add(Bend(
        distance: b['distance'] as double,
        degrees: b['degrees'] as double,
        inclination: b['inclination'] as double,
        lines: lines,
        type: BendType.values.firstWhere((e) => e.toString() == b['type']),
      ));
    }

    notifyListeners();
  }
}
