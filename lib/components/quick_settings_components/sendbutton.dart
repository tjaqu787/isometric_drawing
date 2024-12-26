import 'package:flutter/material.dart';
import '../data_and_state/bend_math.dart';
import '../data_and_state/validate.dart';
import '../data_and_state/isometric_state.dart';

class BottomActionBar extends StatelessWidget {
  final AppState state;

  const BottomActionBar({
    super.key,
    required this.state,
  });

  ConduitSize _getPipeSizeEnum(String pipeSize) {
    switch (pipeSize) {
      case '1/2"':
        return ConduitSize.half;
      case '3/4"':
        return ConduitSize.threeFourth;
      case '1"':
        return ConduitSize.one;
      case '1-1/4"':
        return ConduitSize.oneAndQuarter;
      case '1-1/2"':
        return ConduitSize.oneAndHalf;
      case '2"':
        return ConduitSize.two;
      case '2-1/2"':
        return ConduitSize.twoAndHalf;
      case '3"':
        return ConduitSize.three;
      case '3-1/2"':
        return ConduitSize.threeAndHalf;
      case '4"':
        return ConduitSize.four;
      default:
        throw ArgumentError('Invalid pipe size: $pipeSize');
    }
  }

  void _handleSend(BuildContext context) {
    try {
      final conduitSize = _getPipeSizeEnum(state.pipeSize);

      // Map AppState bends to validator's Bend type
      final bends = state.bends
          .map((stateBend) => Bend(
                distance: stateBend.distance,
                degrees: stateBend.degrees,
                inclination: stateBend.inclination,
                lines: stateBend.lines,
                type: stateBend.type,
                x: stateBend.x,
                y: stateBend.y,
                angle: stateBend.angle,
                measurementPoint: stateBend.measurementPoint,
              ))
          .toList();

      // Validate bends
      final errors = ConduitValidator.validateBends(bends, conduitSize);

      if (errors.isEmpty) {
        // Map to API Bend type and prepare data for API
        final apiBends = bends
            .map((bend) => Bend(
                  distance: bend.distance,
                  degrees: bend.degrees,
                  inclination: bend.inclination,
                  lines: [], // Since we don't need lines for API
                  type: BendType.simple,
                ))
            .toList();

        final apiData = ConduitValidator.prepareForApi(
          apiBends,
          state.index.toInt(),
          conduitSize,
        );

        // Log success
        debugPrint('Validation passed. Sending data to API...');
        debugPrint('Pipe Size: ${apiData.conduitSize}');
        debugPrint('Piece Number: ${apiData.pieceNumber}');
        debugPrint('\nBends:');
        for (var i = 0; i < apiData.bends.length; i++) {
          final bend = apiData.bends[i];
          debugPrint(
              'Bend $i: {distance: ${bend.distance}, degrees: ${bend.degrees}, inclination: ${bend.inclination}}');
        }

        // TODO: Send apiData to your API endpoint
      } else {
        // Show validation errors in a dialog
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Validation Errors'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: errors
                    .map((error) => Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: Text(error.toString()),
                        ))
                    .toList(),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      // Show error dialog for any other errors
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Error'),
          content: Text('An error occurred: $e'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          onPressed: state.canUndo() ? () => state.undo() : null,
          icon: const Icon(Icons.undo),
        ),
        ElevatedButton(
          onPressed: state.bends.isEmpty ? null : () => _handleSend(context),
          child: const Text('Send'),
        ),
      ],
    );
  }
}
