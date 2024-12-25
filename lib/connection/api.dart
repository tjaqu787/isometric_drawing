// Define a class for the bend data
import '../components/data_and_state/isometric_state.dart';

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
