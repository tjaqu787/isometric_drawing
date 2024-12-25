import 'package:flutter/material.dart';
import './quick_settings_button_bar.dart';
import '../data_and_state/isometric_state.dart';
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

class _BendCard extends StatefulWidget {
  final int index;
  final Bend bend;
  final bool isSelected;

  const _BendCard({
    required this.index,
    required this.bend,
    required this.isSelected,
  });

  @override
  State<_BendCard> createState() => _BendCardState();
}

class _BendCardState extends State<_BendCard> {
  bool isExpanded = true;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8),
      elevation: widget.isSelected ? 8 : 1,
      color: widget.isSelected
          ? Theme.of(context).colorScheme.primaryContainer
          : null,
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row with toggle
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Bend ${widget.index + 1} (${_getBendTypeName(widget.bend.type)})',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                IconButton(
                  icon:
                      Icon(isExpanded ? Icons.expand_less : Icons.expand_more),
                  onPressed: () {
                    setState(() {
                      isExpanded = !isExpanded;
                    });
                  },
                ),
              ],
            ),
            // Collapsible content
            if (isExpanded) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _NumberField(
                      label: 'Distance',
                      value: widget.bend.distance,
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
                      value: widget.bend.inclination,
                      onChanged: (value) => _updateBendProperty(
                        context,
                        'inclination',
                        value,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _NumberField(
                      label: 'X',
                      value: widget.bend.x,
                      onChanged: (value) => _updateBendProperty(
                        context,
                        'x',
                        value,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _NumberField(
                      label: 'Y',
                      value: widget.bend.y,
                      onChanged: (value) => _updateBendProperty(
                        context,
                        'y',
                        value,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _AngleDropdown(
                      value: widget.bend.angle,
                      onChanged: (value) => _updateBendProperty(
                        context,
                        'angle',
                        value,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _MeasurementPointDropdown(
                      value: widget.bend.measurementPoint,
                      onChanged: (value) => _updateBendProperty(
                        context,
                        'measurementPoint',
                        value,
                      ),
                    ),
                  ),
                ],
              ),
              if (widget.isSelected) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Length: ${_calculateTotalLength(widget.bend)}',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                  ],
                ),
              ],
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
      case BendType.kick:
        return 'Kick';
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
      BuildContext context, String property, dynamic value) {
    context.read<AppState>().updateBendProperties(
      widget.index,
      {property: value},
    );
  }
}

class _MeasurementPointDropdown extends StatelessWidget {
  final String value;
  final ValueChanged<String> onChanged;

  const _MeasurementPointDropdown({
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      decoration: const InputDecoration(
        labelText: 'Measurement Point',
        border: OutlineInputBorder(),
      ),
      value: value,
      items: ['start', 'end'].map((point) {
        return DropdownMenuItem<String>(
          value: point,
          child: Text(point.capitalize()),
        );
      }).toList(),
      onChanged: (newValue) {
        if (newValue != null) {
          onChanged(newValue);
        }
      },
    );
  }
}

class _AngleDropdown extends StatelessWidget {
  final double value;
  final ValueChanged<double> onChanged;

  const _AngleDropdown({
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<double>(
      decoration: const InputDecoration(
        labelText: 'Angle',
        border: OutlineInputBorder(),
      ),
      value: value,
      items: [10, 22.5, 30, 45, 60, 90].map((angle) {
        return DropdownMenuItem<double>(
          value: angle.toDouble(),
          child: Text('${angle.toStringAsFixed(1)}°'),
        );
      }).toList(),
      onChanged: (newValue) {
        if (newValue != null) {
          onChanged(newValue);
        }
      },
    );
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

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}
