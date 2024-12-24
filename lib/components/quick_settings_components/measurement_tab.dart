import 'package:flutter/material.dart';
import './quick_settings_button_bar.dart';
import '../isometric_state.dart';
import 'package:provider/provider.dart';

class MeasurementsTab extends StatelessWidget {
  const MeasurementsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();

    return Column(
      children: [
        const QuickSettingsButtonBar(),
        const Divider(),
        Expanded(
          child: ListView.builder(
            itemCount: appState.bends.length,
            itemBuilder: (context, index) {
              final bend = appState.bends[index];
              return _BendCard(
                index: index,
                bend: bend,
                isSelected: bend == appState.selectedBend,
              );
            },
          ),
        ),
      ],
    );
  }
}

class _BendCard extends StatelessWidget {
  final int index;
  final Bend bend;
  final bool isSelected;

  const _BendCard({
    required this.index,
    required this.bend,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8),
      elevation: isSelected ? 8 : 1,
      color: isSelected ? Theme.of(context).colorScheme.primaryContainer : null,
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Bend ${index + 1} (${_getBendTypeName(bend.type)})',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _NumberField(
                    label: 'Distance',
                    value: bend.distance,
                    onChanged: (value) => _updateBendProperty(
                      context,
                      'distance',
                      value,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _NumberField(
                    label: 'Inclination',
                    value: bend.inclination,
                    onChanged: (value) => _updateBendProperty(
                      context,
                      'inclination',
                      value,
                    ),
                  ),
                ),
              ],
            ),
            if (isSelected) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Length: ${_calculateTotalLength(bend)}',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline),
                    onPressed: () => _deleteBend(context),
                    tooltip: 'Delete bend',
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _getBendTypeName(BendType type) {
    switch (type) {
      case BendType.boxOffset:
        return 'Box Offset';
      case BendType.offset:
        return 'Offset';
      case BendType.degree90:
        return '90°';
    }
  }

  String _calculateTotalLength(Bend bend) {
    double totalLength = 0;
    for (var line in bend.lines) {
      totalLength += line.calculateActualLength();
    }
    return totalLength.toStringAsFixed(2);
  }

  void _updateBendProperty(
      BuildContext context, String property, double value) {
    context.read<AppState>().updateBendProperties(
      index,
      {property: value},
    );
  }

  void _deleteBend(BuildContext context) {
    // Add delete functionality to AppState if needed
    // context.read<AppState>().deleteBend(index);
  }
}

class _NumberField extends StatelessWidget {
  final String label;
  final double value;
  final Function(double) onChanged;

  const _NumberField({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      keyboardType: TextInputType.number,
      controller: TextEditingController(text: value.toStringAsFixed(2)),
      onSubmitted: (text) {
        final newValue = double.tryParse(text);
        if (newValue != null) {
          onChanged(newValue);
        }
      },
    );
  }
}
