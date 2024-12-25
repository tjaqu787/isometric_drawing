// This is a pretty big state file, have fun maintaining this
import 'package:flutter/material.dart';
import 'dart:math';

// meant for the isometric rendering process
enum ViewAxis {
  front,
  side,
  top,
}

// helper type
enum BendType { boxOffset, offset, degree90, kick }

// meant to be used internally for rendering
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
        return Offset(y, z);
      case ViewAxis.side:
        return Offset(x, z);
      case ViewAxis.top:
        return Offset(x, y);
    }
  }
}

// meant to be used internally for rendering
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

// Meant to be used internally and externally
// internally we use this primarily for state
// Externally we are going to change this type a bit
//  and use it as an API
class Bend {
  final double distance;
  final double degrees; // degrees and angle might be the same thing
  double inclination;
  double x;
  double y;
  double angle;
  String measurementPoint;
  final List<IsometricLine3D> lines;
  final BendType type;

  Bend({
    required this.distance,
    required this.degrees,
    this.inclination = 0,
    this.x = 0,
    this.y = 0,
    this.angle = 22.5,
    this.measurementPoint = 'start',
    required this.lines,
    required this.type,
  });
}

// meant to be a container for everything
class AppState extends ChangeNotifier {
  // Isometric state
  final List<Point3D> points = [];
  final List<Bend> bends = [];
  Bend? selectedBend;
  Point3D get startingPoint => Point3D(-5, 0, 0);

  // Settings state
  String _pipeSize = '1/2"';
  double _boxOffset = 0.5;
  double _boxOffsetAngle = 10.0;
  double _offsetAngle = 30.0;
  double _offsetSize = 6.0;
  num _index = 1;
  final List<Map<String, dynamic>> _undoHistory = [];

  // Settings getters
  String get pipeSize => _pipeSize;
  double get defaultBoxAngle => _boxOffsetAngle;
  double get defaultBoxOffset => _boxOffset;
  double get defaultOffsetAngle => _offsetAngle;
  double get defaultOffsetSize => _offsetSize;
  num get index => _index;
  bool canUndo() => _undoHistory.length > 1;

  // Settings update methods
  void updatePipeSize(String size) {
    _pipeSize = size;
    _saveToHistory();
    _updateGeometryWithSettings();
    notifyListeners();
  }

  void updateBoxOffset(double offset) {
    _boxOffset = offset;
    _saveToHistory();
    _updateGeometryWithSettings();
    notifyListeners();
  }

  // New methods for default values
  void updateDefaultBoxAngle(double angle) {
    _boxOffsetAngle = angle;
    _saveToHistory();
    _updateGeometryWithSettings();
    notifyListeners();
  }

  void updateDefaultBoxOffset(double offset) {
    _offsetSize = offset;
    _saveToHistory();
    _updateGeometryWithSettings();
    notifyListeners();
  }

  void updateDefaultOffsetAngle(double angle) {
    _offsetAngle = angle;
    _saveToHistory();
    _updateGeometryWithSettings();
    notifyListeners();
  }

  void updateDefaultOffsetSize(double size) {
    _offsetSize = size;
    _saveToHistory();
    _updateGeometryWithSettings();
    notifyListeners();
  }

  void updateIndex(num newIndex) {
    _index = newIndex;
    _saveToHistory();
    _updateGeometryWithSettings();
    notifyListeners();
  }

  void _updateGeometryWithSettings() {
    // Update all bends with current settings
    for (var bend in bends) {
      _updateBendGeometry(bend);
    }
  }

  void _saveToHistory() {
    _undoHistory.add({
      'pipeSize': _pipeSize,
      'boxOffset': _boxOffset,
      'boxAngle': _boxOffsetAngle,
      'offsetAngle': _offsetAngle,
      'offsetSize': _offsetSize,
      'index': _index,
    });
  }

  // Add method to restore from history
  void undo() {
    if (_undoHistory.isNotEmpty) {
      final previousState = _undoHistory.removeLast();
      _pipeSize = previousState['pipeSize'];
      _boxOffset = previousState['boxOffset'];
      _boxOffsetAngle = previousState['boxAngle'];
      _offsetAngle = previousState['offsetAngle'];
      _offsetSize = previousState['offsetSize'];
      _index = previousState['index'];
      _updateGeometryWithSettings();
      notifyListeners();
    }
  }

  void addBoxOffset() {
    final lastPoint = points.isEmpty ? startingPoint : points.last;
    final distance = _boxOffset; // Using the default box offset
    final angleRad = _boxOffsetAngle * pi / 180; // Convert angle to radians

    // Calculate points using the angle
    final point1 = Point3D(lastPoint.x + distance * cos(angleRad),
        lastPoint.y + distance * sin(angleRad), lastPoint.z);
    final point2 = Point3D(point1.x, point1.y + distance, point1.z);
    final point3 = Point3D(point2.x + distance, point2.y, point2.z);

    points.addAll([point1, point2, point3]);

    final lines = [
      IsometricLine3D(lastPoint, point1, false, distance),
      IsometricLine3D(point1, point2, false, distance),
      IsometricLine3D(point2, point3, false, distance),
    ];

    final bend = Bend(
      distance: distance,
      degrees: _boxOffsetAngle, // Using the default angle
      x: 0,
      y: 0,
      angle: _boxOffsetAngle,
      measurementPoint: 'start',
      lines: lines,
      type: BendType.boxOffset,
    );

    bends.add(bend);
    _saveToHistory();
    notifyListeners();
  }

  void addOffset() {
    final lastPoint = points.isEmpty ? startingPoint : points.last;
    final distance = _offsetSize; // Using the default offset size
    final angleRad = _offsetAngle * pi / 180; // Convert angle to radians

    // Calculate points using the angle
    final point1 = Point3D(lastPoint.x + distance * cos(angleRad),
        lastPoint.y + distance * sin(angleRad), lastPoint.z);
    final point2 = Point3D(point1.x, point1.y + distance, point1.z);
    final point3 = Point3D(point2.x + distance, point2.y, point2.z);

    points.addAll([point1, point2, point3]);

    final lines = [
      IsometricLine3D(lastPoint, point1, false, distance),
      IsometricLine3D(point1, point2, false, distance),
      IsometricLine3D(point2, point3, false, distance),
    ];

    final bend = Bend(
      distance: distance,
      degrees: _offsetAngle, // Using the default angle
      x: 0,
      y: 0,
      angle: _offsetAngle,
      measurementPoint: 'start',
      lines: lines,
      type: BendType.offset,
    );

    bends.add(bend);
    _saveToHistory();
    notifyListeners();
  }

  void addKick() {
    final lastPoint = points.isEmpty ? startingPoint : points.last;
    final distance = sqrt(2);

    final point1 = Point3D(lastPoint.x + distance, lastPoint.y, lastPoint.z);
    final point2 = Point3D(point1.x, point1.y + distance, point1.z);

    points.addAll([point1, point2]);

    final lines = [
      IsometricLine3D(lastPoint, point1, false, distance),
      IsometricLine3D(point1, point2, false, distance),
    ];

    final bend = Bend(
      distance: distance,
      degrees: 22.5,
      x: 0,
      y: 0,
      angle: 22.5,
      measurementPoint: 'start',
      lines: lines,
      type: BendType.kick,
    );

    bends.add(bend);
    _saveToHistory();
    notifyListeners();
  }

  void add90Degree() {
    final lastPoint = points.isEmpty ? startingPoint : points.last;
    final distance = 1.0;

    final point1 = Point3D(lastPoint.x + distance, lastPoint.y, lastPoint.z);
    final point2 = Point3D(point1.x, point1.y + distance, point1.z);

    points.addAll([point1, point2]);

    final lines = [
      IsometricLine3D(lastPoint, point1, false, distance),
      IsometricLine3D(point1, point2, false, distance),
    ];

    final bend = Bend(
      distance: distance,
      degrees: 90,
      x: 0,
      y: 0,
      angle: 90,
      measurementPoint: 'start',
      lines: lines,
      type: BendType.degree90,
    );

    bends.add(bend);
    _saveToHistory();
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

  void clearAll() {
    points.clear();
    bends.clear();
    selectedBend = null;
    _saveToHistory();
    notifyListeners();
  }

  bool _isLineNearPoint(IsometricLine3D line, Offset point, ViewAxis axis) {
    const double threshold = 10.0;
    final start = _projectPoint(line.start, axis);
    final end = _projectPoint(line.end, axis);
    return _distanceToLineSegment(point, start, end) < threshold;
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
      case BendType.kick:
        _updateOffsetGeometry(bend);
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

    // Update points in the points list
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

// Add these methods to the AppState class

  void updateBendProperties(int index, Map<String, dynamic> properties) {
    if (index < 0 || index >= bends.length) return;

    final bend = bends[index];
    bool needsUpdate = false;

    if (properties.containsKey('inclination')) {
      bend.inclination = properties['inclination']!;
      needsUpdate = true;
    }
    if (properties.containsKey('x')) {
      bend.x = properties['x']!;
      needsUpdate = true;
    }
    if (properties.containsKey('y')) {
      bend.y = properties['y']!;
      needsUpdate = true;
    }
    if (properties.containsKey('angle')) {
      bend.angle = properties['angle']!;
      needsUpdate = true;
    }
    if (properties.containsKey('measurementPoint')) {
      bend.measurementPoint = properties['measurementPoint']!;
      needsUpdate = true;
    }

    if (needsUpdate) {
      // Update this bend and all subsequent bends
      _updateBendsFromIndex(index);
    }

    _saveToHistory();
    notifyListeners();
  }

  void _updateBendsFromIndex(int startIndex) {
    if (startIndex >= bends.length) return;

    Point3D currentPoint;
    if (startIndex == 0) {
      currentPoint = startingPoint;
    } else {
      // Get the end point of the previous bend
      final prevBend = bends[startIndex - 1];
      currentPoint = prevBend.lines.last.end;
    }

    // Update each bend from the starting index
    for (int i = startIndex; i < bends.length; i++) {
      final bend = bends[i];
      _updateBendGeometryWithStartPoint(bend, currentPoint);
      // The end point of this bend becomes the start point for the next bend
      currentPoint = bend.lines.last.end;
    }
  }

  void _updateBendGeometryWithStartPoint(Bend bend, Point3D startPoint) {
    switch (bend.type) {
      case BendType.boxOffset:
        _updateBoxOffsetGeometryWithStartPoint(bend, startPoint);
        break;
      case BendType.offset:
        _updateOffsetGeometryWithStartPoint(bend, startPoint);
        break;
      case BendType.degree90:
        _update90DegreeGeometryWithStartPoint(bend, startPoint);
        break;
      case BendType.kick:
        _updateKickGeometryWithStartPoint(bend, startPoint);
        break;
    }
  }

  void _updateBoxOffsetGeometryWithStartPoint(Bend bend, Point3D startPoint) {
    final distance = bend.distance;
    final inclinationRad = bend.inclination * pi / 180;

    // First segment - straight to the corner point
    final cornerPoint = Point3D(
      startPoint.x + distance,
      startPoint.y,
      startPoint.z,
    );

    // Second segment - rotates around the corner point
    final point2 = Point3D(
      cornerPoint.x,
      cornerPoint.y + distance * cos(inclinationRad),
      cornerPoint.z + distance * sin(inclinationRad),
    );

    // Third segment - maintains the same direction as original
    final point3 = Point3D(
      point2.x + distance,
      point2.y,
      point2.z,
    );

    // Update the lines with new points
    bend.lines.clear();
    bend.lines.addAll([
      IsometricLine3D(startPoint, cornerPoint, false, distance),
      IsometricLine3D(cornerPoint, point2, false, distance),
      IsometricLine3D(point2, point3, false, distance),
    ]);

    // Update points in the points list
    _updatePointsForBend(bend, [cornerPoint, point2, point3]);
  }

  void _updateOffsetGeometryWithStartPoint(Bend bend, Point3D startPoint) {
    final distance = bend.distance;
    final inclinationRad = bend.inclination * pi / 180;

    // Corner point (pivot point)
    final cornerPoint = Point3D(
      startPoint.x + distance,
      startPoint.y,
      startPoint.z,
    );

    // End point rotated around corner
    final endPoint = Point3D(
      cornerPoint.x,
      cornerPoint.y + distance * cos(inclinationRad),
      cornerPoint.z + distance * sin(inclinationRad),
    );

    // Update the lines
    bend.lines.clear();
    bend.lines.addAll([
      IsometricLine3D(startPoint, cornerPoint, false, distance),
      IsometricLine3D(cornerPoint, endPoint, false, distance),
    ]);

    // Update points in the points list
    _updatePointsForBend(bend, [cornerPoint, endPoint]);
  }

  void _update90DegreeGeometryWithStartPoint(Bend bend, Point3D startPoint) {
    final distance = bend.distance;
    final inclinationRad = bend.inclination * pi / 180;

    // Corner point (pivot point)
    final cornerPoint = Point3D(
      startPoint.x + distance,
      startPoint.y,
      startPoint.z,
    );

    // End point - always 90 degrees from the start, but can rotate in YZ plane
    final endPoint = Point3D(
      cornerPoint.x,
      cornerPoint.y + distance * cos(inclinationRad),
      cornerPoint.z + distance * sin(inclinationRad),
    );

    // Update the lines
    bend.lines.clear();
    bend.lines.addAll([
      IsometricLine3D(startPoint, cornerPoint, false, distance),
      IsometricLine3D(cornerPoint, endPoint, false, distance),
    ]);

    // Update points in the points list
    _updatePointsForBend(bend, [cornerPoint, endPoint]);
  }

  void _updateKickGeometryWithStartPoint(Bend bend, Point3D startPoint) {
    final distance = bend.distance;
    final inclinationRad = bend.inclination * pi / 180;

    // Corner point (pivot point)
    final cornerPoint = Point3D(
      startPoint.x + distance,
      startPoint.y,
      startPoint.z,
    );

    // End point - maintains kick angle but can rotate in YZ plane
    final endPoint = Point3D(
      cornerPoint.x + distance * cos(22.5 * pi / 180),
      cornerPoint.y + distance * cos(inclinationRad),
      cornerPoint.z + distance * sin(inclinationRad),
    );

    // Update the lines
    bend.lines.clear();
    bend.lines.addAll([
      IsometricLine3D(startPoint, cornerPoint, false, distance),
      IsometricLine3D(cornerPoint, endPoint, false, distance),
    ]);

    // Update points in the points list
    _updatePointsForBend(bend, [cornerPoint, endPoint]);
  }

  void _updatePointsForBend(Bend bend, List<Point3D> newPoints) {
    // Find the start point index
    final startPointIndex = points.indexOf(bend.lines.first.start);
    if (startPointIndex != -1) {
      // Remove old points for this bend
      points.removeRange(
          startPointIndex + 1, startPointIndex + 1 + newPoints.length);
      // Insert new points
      points.insertAll(startPointIndex + 1, newPoints);
    }
  }
}
