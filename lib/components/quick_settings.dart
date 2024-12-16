import 'package:flutter/material.dart';
import './isometric_state.dart';

class MeasurementsTab extends StatelessWidget {
  final List<IsometricLine3D> lines;
  final Function() onAddBoxOffset;
  final Function() onAddOffset;
  final Function() onAdd90Degree;
  final Function() onSave;
  final Function(int, double)? onUpdateMeasurement;

  const MeasurementsTab({
    super.key,
    required this.lines,
    required this.onAddBoxOffset,
    required this.onAddOffset,
    required this.onAdd90Degree,
    required this.onSave,
    this.onUpdateMeasurement,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 16),
        Row(
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
        const Divider(),
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(4),
            ),
            margin: const EdgeInsets.symmetric(horizontal: 8),
            child: ListView.separated(
              padding: const EdgeInsets.all(8),
              itemCount: lines.length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final line = lines[index];
                return ListTile(
                  dense: true,
                  title: Text(
                    'Line ${index + 1}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    'Length: ${line.length?.toStringAsFixed(2) ?? 'N/A'}',
                    style: const TextStyle(color: Colors.blue),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

// Settings Tab Component
class SettingsTab extends StatelessWidget {
  final Function(String) onPipeSizeChanged;
  final Function(String) onAngleChanged;
  final Function(double) onBoxOffsetChanged;
  final String selectedPipeSize;
  final String selectedAngle;

  const SettingsTab({
    super.key,
    required this.onPipeSizeChanged,
    required this.onAngleChanged,
    required this.onBoxOffsetChanged,
    required this.selectedPipeSize,
    required this.selectedAngle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSettingSection(
          title: 'Conduit Size:',
          child: DropdownButton<String>(
            value: selectedPipeSize,
            hint: const Text('Select conduit size'),
            items: ['1/2"', '3/4"', '1"'].map((size) {
              return DropdownMenuItem(value: size, child: Text(size));
            }).toList(),
            onChanged: (value) => onPipeSizeChanged(value!),
          ),
        ),
        _buildSettingSection(
          title: 'Default Angle:',
          child: DropdownButton<String>(
            value: selectedAngle,
            hint: const Text('Default angle'),
            items: ['10', '22', '30', '45', '60'].map((angle) {
              return DropdownMenuItem(value: angle, child: Text('$angle°'));
            }).toList(),
            onChanged: (value) => onAngleChanged(value!),
          ),
        ),
        _buildSettingSection(
          title: 'Box Offset:',
          child: BoxOffsetInput(onChanged: onBoxOffsetChanged),
        ),
      ],
    );
  }

  Widget _buildSettingSection({
    required String title,
    required Widget child,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 5),
          Expanded(
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
                    lines: widget.state.lines,
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
                    onUpdateMeasurement: (index, newLength) {
                      widget.state.updateLineMeasurement(index, newLength);
                      _saveState();
                    },
                  ),
                  SettingsTab(
                    selectedPipeSize: selectedPipeSize,
                    selectedAngle: selectedAngle,
                    onPipeSizeChanged: (value) =>
                        setState(() => selectedPipeSize = value),
                    onAngleChanged: (value) =>
                        setState(() => selectedAngle = value),
                    onBoxOffsetChanged: (value) =>
                        setState(() => selectedBoxOffset = value),
                  ),
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
