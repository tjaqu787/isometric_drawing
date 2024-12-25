// This is the setup tab of the settings window

import 'package:flutter/material.dart';
import './quick_settings_button_bar.dart';
import '../isometric_state.dart';
import 'package:provider/provider.dart';

class SettingsTab extends StatelessWidget {
  const SettingsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const QuickSettingsButtonBar(),
        const Divider(),

        // Top Row with Conduit Size and Quantity
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            children: [
              Expanded(
                child: _SettingSection(
                  title: 'Conduit Size:',
                  child: _buildPipeSizeDropdown(appState),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _SettingSection(
                  title: 'Quantity:',
                  child: _buildQuantityDropdown(appState),
                ),
              ),
            ],
          ),
        ),

        // First Card - Box Offset and Angle
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Expanded(
                    child: _SettingSection(
                      title: 'Box Offset:',
                      child: _BoxOffsetInput(
                        value: appState.defaultBoxOffset,
                        onChanged: appState.updateDefaultBoxOffset,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _SettingSection(
                      title: 'Angle:',
                      child: _buildBoxOffsetAngleDropdown(appState),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        // Second Card - Default Settings
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Expanded(
                    child: _SettingSection(
                      title: 'Default Offset:',
                      child: _BoxOffsetInput(
                        value: appState
                            .defaultOffsetSize, // Changed to use defaultOffset
                        onChanged: appState
                            .updateDefaultOffsetSize, // New method needed
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _SettingSection(
                      title: 'Default Angle:',
                      child: _buildDefaultAngleDropdown(appState),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        const Spacer(), // Push bottom action bar to the bottom
        const _BottomActionBar(),
      ],
    );
  }

  Widget _buildPipeSizeDropdown(AppState appState) {
    return DropdownButton<String>(
      value: appState.pipeSize,
      isExpanded: true,
      items: ['1/2"', '3/4"', '1"'].map((size) {
        return DropdownMenuItem(value: size, child: Text(size));
      }).toList(),
      onChanged: (value) => appState.updatePipeSize(value!),
    );
  }

  Widget _buildQuantityDropdown(AppState appState) {
    return DropdownButton<num>(
      value: appState.index,
      isExpanded: true,
      items: [1, 2, 3, 4, 5, 6].map((quantity) {
        return DropdownMenuItem(
            value: quantity, child: Text(quantity.toString()));
      }).toList(),
      onChanged: (value) => appState.updateIndex(value!),
    );
  }

  Widget _buildBoxOffsetAngleDropdown(AppState appState) {
    return DropdownButton<double>(
      value: appState.defaultBoxAngle,
      isExpanded: true,
      items: [10, 22.5, 30, 45, 60].map((angle) {
        return DropdownMenuItem(
          value: angle.toDouble(),
          child: Text('${angle.toStringAsFixed(1)}°'),
        );
      }).toList(),
      onChanged: (value) => appState.updateDefaultBoxAngle(value!),
    );
  }

  Widget _buildDefaultAngleDropdown(AppState appState) {
    return DropdownButton<double>(
      value: appState.defaultOffsetAngle,
      isExpanded: true,
      items: [10, 22.5, 30, 45, 60].map((angle) {
        return DropdownMenuItem(
          value: angle.toDouble(),
          child: Text('${angle.toStringAsFixed(1)}°'),
        );
      }).toList(),
      onChanged: (value) => appState.updateDefaultOffsetAngle(value!),
    );
  }
}

class _BoxOffsetInput extends StatelessWidget {
  final double value;
  final ValueChanged<double> onChanged;

  const _BoxOffsetInput({
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      decoration: const InputDecoration(
        border: OutlineInputBorder(),
        suffixText: 'inches',
      ),
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
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

class _SettingSection extends StatelessWidget {
  final String title;
  final Widget child;

  const _SettingSection({
    required this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
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
    );
  }
}

class _BottomActionBar extends StatelessWidget {
  const _BottomActionBar();

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          onPressed: appState.canUndo() ? () => appState.undo() : null,
          icon: const Icon(Icons.undo),
        ),
        ElevatedButton(
          onPressed: () => _handleSend(context),
          child: const Text('Send'),
        ),
      ],
    );
  }

  void _handleSend(BuildContext context) {
    final appState = context.read<AppState>();
    debugPrint('Sending data...');
    debugPrint('Pipe Size: ${appState.pipeSize}');
    debugPrint('Quantity: ${appState.index}');

    debugPrint('\nBends:');
    for (var i = 0; i < appState.bends.length; i++) {
      final bend = appState.bends[i];
      debugPrint('Bend $i: $bend');
    }
  }
}
