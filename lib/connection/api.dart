// Define a class for the bend data
class Bend {
  final double distance;
  final double degrees;
  final double inclination;

  Bend({
    required this.distance,
    required this.degrees,
    required this.inclination,
  });

  // Convert Bend instance to JSON
  Map<String, dynamic> toJson() {
    return {
      'distance': distance,
      'degrees': degrees,
      'inclination': inclination,
    };
  }

  // Create Bend instance from JSON
  factory Bend.fromJson(Map<String, dynamic> json) {
    return Bend(
      distance: json['distance']?.toDouble() ?? 0.0,
      degrees: json['degrees']?.toDouble() ?? 0.0,
      inclination: json['inclination']?.toDouble() ?? 0.0,
    );
  }
}

// Define the main conduit data class
class ConduitData {
  final int pieceNumber;
  final String conduitSize;
  final List<Bend> bends;

  ConduitData({
    required this.pieceNumber,
    required this.conduitSize,
    required this.bends,
  });

  // Convert ConduitData instance to JSON
  Map<String, dynamic> toJson() {
    return {
      'piece_number': pieceNumber,
      'conduit_size': conduitSize,
      'bends': bends.map((bend) => bend.toJson()).toList(),
    };
  }

  // Create ConduitData instance from JSON
  factory ConduitData.fromJson(Map<String, dynamic> json) {
    return ConduitData(
      pieceNumber: json['piece_number'] ?? 0,
      conduitSize: json['conduit_size'] ?? '',
      bends: (json['bends'] as List<dynamic>?)
              ?.map((bendJson) => Bend.fromJson(bendJson))
              .toList() ??
          [],
    );
  }
}
