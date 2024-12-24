import 'dart:math';

// EMT (Electrical Metallic Tubing) conduit bending properties
// All measurements are in inches unless otherwise specified

enum ConduitSize {
  half, // 1/2"
  threeFourth, // 3/4"
  one, // 1"
  oneAndQuarter, // 1-1/4"
  oneAndHalf, // 1-1/2"
  two, // 2"
  twoAndHalf, // 2-1/2"
  three, // 3"
  threeAndHalf, // 3-1/2"
  four, // 4"
}

class BendProperties {
  final double outerDiameter;
  final double minBendRadius;
  final double bendDeduction; // Distance to the back of a 90-degree bend
  final double springBack; // Degrees to overbend to account for spring back
  final double centerLineRadius; // Radius to centerline of conduit
  final double
      shrinkPerBend; // Amount of length lost per bend due to stretching

  const BendProperties({
    required this.outerDiameter,
    required this.minBendRadius,
    required this.bendDeduction,
    required this.springBack,
    required this.centerLineRadius,
    required this.shrinkPerBend,
  });
}

final Map<ConduitSize, BendProperties> conduitProperties = {
  ConduitSize.half: BendProperties(
    outerDiameter: 0.706,
    minBendRadius: 4.0,
    bendDeduction: 5.0,
    springBack: 2.0,
    centerLineRadius: 2.5,
    shrinkPerBend: 0.125,
  ),
  ConduitSize.threeFourth: BendProperties(
    outerDiameter: 0.922,
    minBendRadius: 4.5,
    bendDeduction: 6.0,
    springBack: 2.5,
    centerLineRadius: 3.0,
    shrinkPerBend: 0.25,
  ),
  ConduitSize.one: BendProperties(
    outerDiameter: 1.163,
    minBendRadius: 5.75,
    bendDeduction: 8.0,
    springBack: 3.0,
    centerLineRadius: 4.0,
    shrinkPerBend: 0.375,
  ),
  ConduitSize.oneAndQuarter: BendProperties(
    outerDiameter: 1.510,
    minBendRadius: 7.25,
    bendDeduction: 11.0,
    springBack: 3.5,
    centerLineRadius: 5.5,
    shrinkPerBend: 0.5,
  ),
  ConduitSize.oneAndHalf: BendProperties(
    outerDiameter: 1.740,
    minBendRadius: 8.25,
    bendDeduction: 13.0,
    springBack: 4.0,
    centerLineRadius: 6.5,
    shrinkPerBend: 0.625,
  ),
  ConduitSize.two: BendProperties(
    outerDiameter: 2.197,
    minBendRadius: 9.5,
    bendDeduction: 15.0,
    springBack: 4.5,
    centerLineRadius: 8.0,
    shrinkPerBend: 0.75,
  ),
  ConduitSize.twoAndHalf: BendProperties(
    outerDiameter: 2.875,
    minBendRadius: 10.5,
    bendDeduction: 18.0,
    springBack: 5.0,
    centerLineRadius: 9.5,
    shrinkPerBend: 0.875,
  ),
  ConduitSize.three: BendProperties(
    outerDiameter: 3.500,
    minBendRadius: 13.0,
    bendDeduction: 21.0,
    springBack: 5.5,
    centerLineRadius: 11.0,
    shrinkPerBend: 1.0,
  ),
  ConduitSize.threeAndHalf: BendProperties(
    outerDiameter: 4.000,
    minBendRadius: 15.0,
    bendDeduction: 24.0,
    springBack: 6.0,
    centerLineRadius: 12.5,
    shrinkPerBend: 1.125,
  ),
  ConduitSize.four: BendProperties(
    outerDiameter: 4.500,
    minBendRadius: 16.0,
    bendDeduction: 27.0,
    springBack: 6.5,
    centerLineRadius: 14.0,
    shrinkPerBend: 1.25,
  ),
};

// Helper functions for common calculations
double calculateBendDeduction(ConduitSize size, double angle) {
  final properties = conduitProperties[size]!;
  return (angle / 90) * properties.bendDeduction;
}

double calculateArcLength(ConduitSize size, double angle) {
  final properties = conduitProperties[size]!;
  return (angle / 360) * 2 * pi * properties.centerLineRadius;
}

double getSpringBackAngle(ConduitSize size) {
  return conduitProperties[size]!.springBack;
}

double getMinBendRadius(ConduitSize size) {
  return conduitProperties[size]!.minBendRadius;
}

double getShrinkage(ConduitSize size, int numberOfBends) {
  return conduitProperties[size]!.shrinkPerBend * numberOfBends;
}
