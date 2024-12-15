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
  List<Map<String, dynamic>> undoHistory = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this); // Updated to 4 tabs
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
                Tab(text: 'Quick Add'),
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
                        subtitle:
                            Text('Length: ${line.length!.toStringAsFixed(2)}'),
                      );
                    },
                  ),

                  // Quick Settings Tab
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      DropdownButton<String>(
                        value: selectedPipeSize,
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
                      const SizedBox(height: 8),
                      DropdownButton<String>(
                        value: selectedAngle,
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
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              widget.state
                                  .clearAll(); // Assuming you have this method
                              _saveState();
                            },
                            child: const Text('Clear All'),
                          ),
                          ElevatedButton(
                            onPressed: undoHistory.length > 1 ? _undo : null,
                            child: const Text('Undo'),
                          ),
                        ],
                      ),
                    ],
                  ),

                  // Add Tab (existing)
                  const Center(
                    child: Text('Add Tab Content'),
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
                              widget.state
                                  .addBoxOffset(); // Implement this method
                              _saveState();
                            },
                            child: const Text('Box Offset'),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              widget.state.addOffset(); // Implement this method
                              _saveState();
                            },
                            child: const Text('Offset'),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              widget.state
                                  .add90Degree(); // Implement this method
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
