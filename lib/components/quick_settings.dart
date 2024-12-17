import 'package:flutter/material.dart';
import './isometric_state.dart';

class MeasurementsTab extends StatelessWidget {
  final List<Bend> bends;
  final Function() onAddBoxOffset;
  final Function() onAddOffset;
  final Function() onAdd90Degree;
  final Function() onSave;
  final Function(int, Map<String, double>)? onUpdateBend;

  const MeasurementsTab({
    super.key,
    required this.bends,
    required this.onAddBoxOffset,
    required this.onAddOffset,
    required this.onAdd90Degree,
    required this.onSave,
    this.onUpdateBend,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: () {
                  onAddBoxOffset();
                  onSave();
                },
                child: const Text('Box Offset'),
              ),
              ElevatedButton(
                onPressed: () {
                  onAddOffset();
                  onSave();
                },
                child: const Text('Offset'),
              ),
              ElevatedButton(
                onPressed: () {
                  onAdd90Degree();
                  onSave();
                },
                child: const Text('90°'),
              ),
            ],
          ),
        ),
        const Divider(),
        Expanded(
          child: ListView.builder(
            itemCount: bends.length,
            itemBuilder: (context, index) {
              final bend = bends[index];
              return Card(
                margin: const EdgeInsets.all(8),
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
                            child: _buildNumberField(
                              'Distance',
                              bend.distance,
                              (value) =>
                                  _updateBendProperty(index, 'distance', value),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _buildNumberField(
                              'Inclination',
                              bend.inclination,
                              (value) => _updateBendProperty(
                                  index, 'inclination', value),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
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

  Widget _buildNumberField(
      String label, double value, Function(double) onChanged) {
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
          onSave();
        }
      },
    );
  }

  void _updateBendProperty(int index, String property, double value) {
    if (onUpdateBend != null) {
      onUpdateBend!(index, {property: value});
    }
  }
}

// Settings Tab Component
class SettingsTab extends StatelessWidget {
  final Function(String) onPipeSizeChanged;
  final Function(String) onAngleChanged;
  final Function(double) onBoxOffsetChanged;
  final String selectedPipeSize;
  final String selectedAngle;
  final VoidCallback onUndo;
  final VoidCallback onClear;
  final VoidCallback onSend;
  final Function(String) onIndexChanged;
  final String selectedIndex;

  const SettingsTab({
    super.key,
    required this.onPipeSizeChanged,
    required this.onAngleChanged,
    required this.onBoxOffsetChanged,
    required this.selectedPipeSize,
    required this.selectedAngle,
    required this.onUndo,
    required this.onClear,
    required this.onSend,
    required this.onIndexChanged,
    required this.selectedIndex,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Top buttons row
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 2.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: onUndo,
                child: const Text('Undo'),
              ),
              ElevatedButton(
                onPressed: onClear,
                child: const Text('Clear'),
              ),
              ElevatedButton(
                onPressed: onSend,
                child: const Text('Send'),
              ),
            ],
          ),
        ),
        const Divider(),
        // Two-column layout for settings
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left column
              Expanded(
                child: Column(
                  children: [
                    _buildSettingSection(
                      title: 'Conduit Size:',
                      child: DropdownButton<String>(
                        value: selectedPipeSize,
                        hint: const Text('Select size'),
                        isExpanded: true,
                        items: ['1/2"', '3/4"', '1"'].map((size) {
                          return DropdownMenuItem(
                              value: size, child: Text(size));
                        }).toList(),
                        onChanged: (value) => onPipeSizeChanged(value!),
                      ),
                    ),
                    _buildSettingSection(
                      title: 'Index:',
                      child: DropdownButton<String>(
                        value: selectedIndex,
                        hint: const Text('Select index'),
                        isExpanded: true,
                        items: ['1', '2', '3', '4', '5'].map((index) {
                          return DropdownMenuItem(
                              value: index, child: Text(index));
                        }).toList(),
                        onChanged: (value) => onIndexChanged(value!),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              // Right column
              Expanded(
                child: Column(
                  children: [
                    _buildSettingSection(
                      title: 'Angle:',
                      child: DropdownButton<String>(
                        value: selectedAngle,
                        hint: const Text('Select angle'),
                        isExpanded: true,
                        items: ['10', '22', '30', '45', '60'].map((angle) {
                          return DropdownMenuItem(
                            value: angle,
                            child: Text('$angle°'),
                          );
                        }).toList(),
                        onChanged: (value) => onAngleChanged(value!),
                      ),
                    ),
                    _buildSettingSection(
                      title: 'Box Offset:',
                      child: BoxOffsetInput(onChanged: onBoxOffsetChanged),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSettingSection({
    required String title,
    required Widget child,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2.0, vertical: 2.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 2),
          SizedBox(
            width: double.infinity,
            child: child,
          ),
        ],
      ),
    );
  }
}

// BoxOffsetInput Component
class BoxOffsetInput extends StatelessWidget {
  final Function(double) onChanged;

  const BoxOffsetInput({
    super.key,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      decoration: const InputDecoration(
        labelText: 'Box Offset',
        hintText: 'Enter fraction (1/2) or decimal (0.5)',
        border: OutlineInputBorder(),
      ),
      keyboardType: TextInputType.text,
      onChanged: _handleInputChange,
      validator: _validateInput,
    );
  }

  void _handleInputChange(String value) {
    if (value.isEmpty) return;

    if (value.contains('/')) {
      _handleFractionInput(value);
    } else {
      _handleDecimalInput(value);
    }
  }

  void _handleFractionInput(String value) {
    try {
      final parts = value.split('/');
      if (parts.length == 2) {
        final numerator = double.parse(parts[0]);
        final denominator = double.parse(parts[1]);
        onChanged(numerator / denominator);
      }
    } catch (e) {
      debugPrint('Invalid fraction format');
    }
  }

  void _handleDecimalInput(String value) {
    try {
      final decimalValue = double.parse(value);
      onChanged(decimalValue);
    } catch (e) {
      debugPrint('Invalid decimal format');
    }
  }

  String? _validateInput(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a value';
    }

    if (value.contains('/')) {
      return _validateFraction(value);
    }

    return _validateDecimal(value);
  }

  String? _validateFraction(String value) {
    final parts = value.split('/');
    if (parts.length != 2) return 'Invalid fraction format';

    try {
      double.parse(parts[0]);
      double.parse(parts[1]);
      return null;
    } catch (e) {
      return 'Invalid fraction numbers';
    }
  }

  String? _validateDecimal(String value) {
    try {
      double.parse(value);
      return null;
    } catch (e) {
      return 'Invalid number format';
    }
  }
}

// Main QuickSettingsWindow Widget
class QuickSettingsWindow extends StatefulWidget {
  final IsometricState state;

  const QuickSettingsWindow({
    super.key,
    required this.state,
  });

  @override
  State<QuickSettingsWindow> createState() => QuickSettingsWindowState();
}

class QuickSettingsWindowState extends State<QuickSettingsWindow>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String selectedPipeSize = '1/2"';
  String selectedAngle = '45';
  double selectedBoxOffset = 0.5;
  String selectedIndex = '1';
  final List<Map<String, dynamic>> undoHistory = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _saveState();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _saveState() {
    setState(() {
      undoHistory.add({
        'currentState': widget.state.getCurrentState(),
      });
    });
  }

  void _undo() {
    if (undoHistory.length > 1) {
      setState(() {
        undoHistory.removeLast();
        final previousState = undoHistory.last;
        widget.state.restoreState(previousState['currentState']);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TabBar(
              controller: _tabController,
              tabs: const [
                Tab(text: 'Measurements'),
                Tab(text: 'Settings'),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 300,
              child: TabBarView(
                controller: _tabController,
                children: [
                  MeasurementsTab(
                    bends: widget.state.bends,
                    onAddBoxOffset: () {
                      widget.state.addBoxOffset();
                      _saveState();
                    },
                    onAddOffset: () {
                      widget.state.addOffset();
                      _saveState();
                    },
                    onAdd90Degree: () {
                      widget.state.add90Degree();
                      _saveState();
                    },
                    onSave: _saveState,
                    onUpdateBend: (index, properties) {
                      widget.state.updateBendProperties(index, properties);
                      _saveState();
                    },
                  ),
                  SettingsTab(
                    selectedPipeSize: selectedPipeSize,
                    selectedAngle: selectedAngle,
                    selectedIndex: selectedIndex,
                    onPipeSizeChanged: (value) =>
                        setState(() => selectedPipeSize = value),
                    onAngleChanged: (value) =>
                        setState(() => selectedAngle = value),
                    onBoxOffsetChanged: (value) =>
                        setState(() => selectedBoxOffset = value),
                    onIndexChanged: (value) =>
                        setState(() => selectedIndex = value),
                    onUndo: _undo,
                    onClear: () => widget.state.clearAll(),
                    onSend: () {
                      debugPrint('Sending data...');
                      debugPrint('Pipe Size: $selectedPipeSize');
                      debugPrint('Bend Angle: $selectedAngle°');
                    },
                  )
                ],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  onPressed: undoHistory.length > 1 ? _undo : null,
                  icon: const Icon(Icons.undo),
                ),
                ElevatedButton(
                  onPressed: () {
                    debugPrint('Sending data...');
                    debugPrint('Pipe Size: $selectedPipeSize');
                    debugPrint('Bend Angle: $selectedAngle°');
                  },
                  child: const Text('Send'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
