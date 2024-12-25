import 'dart:math';

import 'bend_math.dart';
import '../../connection/api.dart';

class ValidationError {
  final String message;
  final int? bendIndex;

  ValidationError(this.message, [this.bendIndex]);

  @override
  String toString() {
    if (bendIndex != null) {
      return 'Error at bend $bendIndex: $message';
    }
    return message;
  }
}

class ConduitValidator {
  // Validates all bends and returns list of errors if any
  static List<ValidationError> validateBends(
    List<Bend> bends,
    ConduitSize conduitSize,
  ) {
    final List<ValidationError> errors = [];
    final minRadius = getMinBendRadius(conduitSize);

    for (int i = 0; i < bends.length; i++) {
      final bend = bends[i];

      // Check if bend angle is too sharp given the conduit size
      final bendRadius = bend.distance / (2 * sin(bend.degrees * pi / 360));
      if (bendRadius < minRadius) {
        errors.add(
          ValidationError(
            'Bend radius ($bendRadius) is less than minimum allowed radius ($minRadius)',
            i,
          ),
        );
      }

      // Check if bend angle is physically possible (less than 180 degrees)
      if (bend.degrees >= 100) {
        errors.add(
          ValidationError(
            'Bend angle (${bend.degrees}°) exceeds maximum possible angle of 180°',
            i,
          ),
        );
      }

      // Check if inclination is within valid range (-90 to 90 degrees)
      if (bend.inclination < -90 || bend.inclination > 90) {
        errors.add(
          ValidationError(
            'Inclination (${bend.inclination}°) must be between -90° and 90°',
            i,
          ),
        );
      }
    }

    return errors;
  }

  // Prepares data for API by applying physical adjustments
  static ConduitData prepareForApi(
    List<Bend> bends,
    int pieceNumber,
    ConduitSize conduitSize,
  ) {
    final adjustedBends = bends.map((bend) {
      // Apply spring back adjustment
      final springBack = getSpringBackAngle(conduitSize);
      final adjustedDegrees = bend.degrees + springBack;

      // Calculate shrinkage based on bend angle
      final shrinkage = getShrinkage(conduitSize, 1);
      final adjustedDistance = bend.distance - shrinkage;

      return Bend(
        distance: adjustedDistance,
        degrees: adjustedDegrees,
        inclination: bend.inclination,
      );
    }).toList();

    return ConduitData(
      pieceNumber: pieceNumber,
      conduitSize: _conduitSizeToString(conduitSize),
      bends: adjustedBends,
    );
  }

  // Converts ConduitSize enum to string format expected by API
  static String _conduitSizeToString(ConduitSize size) {
    switch (size) {
      case ConduitSize.half:
        return '1/2"';
      case ConduitSize.threeFourth:
        return '3/4"';
      case ConduitSize.one:
        return '1"';
      case ConduitSize.oneAndQuarter:
        return '1-1/4"';
      case ConduitSize.oneAndHalf:
        return '1-1/2"';
      case ConduitSize.two:
        return '2"';
      case ConduitSize.twoAndHalf:
        return '2-1/2"';
      case ConduitSize.three:
        return '3"';
      case ConduitSize.threeAndHalf:
        return '3-1/2"';
      case ConduitSize.four:
        return '4"';
    }
  }
}

// Example usage:
// final bends = [Bend(distance: 10, degrees: 45, inclination: 30)];
// final errors = ConduitValidator.validateBends(bends, ConduitSize.half);
// if (errors.isEmpty) {
//   final apiData = ConduitValidator.prepareForApi(bends, 1, ConduitSize.half);
//   // Send apiData to API
// } else {
//   // Handle validation errors
//   errors.forEach(print);
// }
