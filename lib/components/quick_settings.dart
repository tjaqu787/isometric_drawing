import 'package:flutter/material.dart';
import './isometric_state.dart';

class QuickSettingsWindow extends StatefulWidget {
  final IsometricState state;

  const QuickSettingsWindow({
    super.key,
    required this.state,
  });

  @override
  State<QuickSettingsWindow> createState() => _QuickSettingsWindowState();
}

class _QuickSettingsWindowState extends State<QuickSettingsWindow>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String selectedPipeSize = '1/2"';
  String selectedAngle = '45';
  double selectedBoxOffset = .5;
  List<Map<String, dynamic>> undoHistory = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this); // Updated to 4 tabs
    _saveState();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _saveState() {
    // Update this based on your actual state structure
    undoHistory.add({
      'currentState':
          widget.state.getCurrentState(), // Assuming you have this method
    });
  }

  void _undo() {
    if (undoHistory.length > 1) {
      undoHistory.removeLast();
      final previousState = undoHistory.last;
      widget.state.restoreState(
          previousState['currentState']); // Assuming you have this method
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
                Tab(text: 'Add'),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 300,
              child: TabBarView(
                controller: _tabController,
                children: [
                  // Measurements Tab
                  ListView.builder(
                    itemCount: widget.state.lines.length,
                    itemBuilder: (context, index) {
                      final line = widget.state.lines[index];
                      return ListTile(
                        title: Text('Line ${index + 1}'),
                        subtitle: Text(
                          // Handle null case with null-aware operator and provide default value
                          'Length: ${line.length?.toStringAsFixed(2) ?? 'N/A'}',
                        ),
                      );
                    },
                  ),

                  // Quick Settings Tab
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Conduit Size:',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      DropdownButton<String>(
                        value: selectedPipeSize,
                        hint: const Text('Select conduit size'),
                        items: ['1/2"', '3/4"', '1"'].map((size) {
                          return DropdownMenuItem(
                            value: size,
                            child: Text(size),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedPipeSize = value!;
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Default Angle:',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      DropdownButton<String>(
                        value: selectedAngle,
                        hint: const Text('Default angle'),
                        items: ['10', '22', '30', '45', '60'].map((angle) {
                          return DropdownMenuItem(
                            value: angle,
                            child: Text('$angle°'),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedAngle = value!;
                          });
                        },
                      ),
                      const Text(
                        'Box Offset:',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'Box Offset',
                          hintText: 'Enter fraction (1/2) or decimal (0.5)',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.text,
                        onChanged: (value) {
                          if (value.isEmpty) return;

                          // Handle fraction input
                          if (value.contains('/')) {
                            try {
                              final parts = value.split('/');
                              if (parts.length == 2) {
                                final numerator = double.parse(parts[0]);
                                final denominator = double.parse(parts[1]);
                                final decimalValue = numerator / denominator;
                                setState(() {
                                  selectedBoxOffset = decimalValue;
                                });
                              }
                            } catch (e) {
                              // Handle invalid fraction input
                              print('Invalid fraction format');
                            }
                          }
                          // Handle decimal input
                          else {
                            try {
                              final decimalValue = double.parse(value);
                              setState(() {
                                selectedBoxOffset = decimalValue;
                              });
                            } catch (e) {
                              // Handle invalid decimal input
                              print('Invalid decimal format');
                            }
                          }
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a value';
                          }

                          // Validate fraction format
                          if (value.contains('/')) {
                            final parts = value.split('/');
                            if (parts.length != 2)
                              return 'Invalid fraction format';
                            try {
                              double.parse(parts[0]);
                              double.parse(parts[1]);
                            } catch (e) {
                              return 'Invalid fraction numbers';
                            }
                            return null;
                          }

                          // Validate decimal format
                          try {
                            double.parse(value);
                            return null;
                          } catch (e) {
                            return 'Invalid number format';
                          }
                        },
                      )
                    ],
                  ),

                  // Quick Add Tab (new)
                  Column(
                    children: [
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              widget.state.addBoxOffset();
                              _saveState();
                            },
                            child: const Text('Box Offset'),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              widget.state.addOffset();
                              _saveState();
                            },
                            child: const Text('Offset'),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              widget.state.add90Degree();
                              _saveState();
                            },
                            child: const Text('90°'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // Add send functionality here
                print('Sending data...');
                print('Pipe Size: $selectedPipeSize');
                print('Bend Angle: $selectedAngle°');
              },
              child: const Text('Send'),
            ),
          ],
        ),
      ),
    );
  }
}
