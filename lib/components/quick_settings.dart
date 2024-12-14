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
    _tabController = TabController(length: 2, vsync: this);
    // Store initial state in undo history
    _saveState();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _saveState() {
    undoHistory.add({
      'points': List.from(widget.state.points),
      'lines': List.from(widget.state.lines),
    });
  }

  void _undo() {
    if (undoHistory.length > 1) {
      // Remove current state
      undoHistory.removeLast();
      // Get previous state
      final previousState = undoHistory.last;

      widget.state.points = List.from(previousState['points']);
      widget.state.lines = List.from(previousState['lines']);
      widget.state.notifyListeners();
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
                Tab(text: 'Quick Settings'),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 300, // Adjust height as needed
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
                            Text('Length: ${line.length.toStringAsFixed(2)}'),
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
                              widget.state.points.clear();
                              widget.state.lines.clear();
                              widget.state.notifyListeners();
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
