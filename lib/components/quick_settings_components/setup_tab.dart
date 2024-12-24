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
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _LeftColumn(appState: appState),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _RightColumn(appState: appState),
              ),
            ],
          ),
        ),
        const _BottomActionBar(),
      ],
    );
  }
}

class _LeftColumn extends StatelessWidget {
  final AppState appState;

  const _LeftColumn({required this.appState});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _SettingSection(
          title: 'Conduit Size:',
          child: _buildPipeSizeDropdown(),
        ),
        _SettingSection(
          title: 'Index:',
          child: _buildIndexDropdown(),
        ),
      ],
    );
  }

  Widget _buildPipeSizeDropdown() {
    return DropdownButton<String>(
      value: appState.pipeSize,
      isExpanded: true,
      items: ['1/2"', '3/4"', '1"'].map((size) {
        return DropdownMenuItem(value: size, child: Text(size));
      }).toList(),
      onChanged: (value) => appState.updatePipeSize(value!),
    );
  }

  Widget _buildIndexDropdown() {
    return DropdownButton<String>(
      value: appState.index,
      isExpanded: true,
      items: ['1', '2', '3', '4', '5'].map((index) {
        return DropdownMenuItem(value: index, child: Text(index));
      }).toList(),
      onChanged: (value) => appState.updateIndex(value!),
    );
  }
}

class _RightColumn extends StatelessWidget {
  final AppState appState;

  const _RightColumn({required this.appState});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _SettingSection(
          title: 'Angle:',
          child: _buildAngleDropdown(),
        ),
        _SettingSection(
          title: 'Box Offset:',
          child: _BoxOffsetInput(
            value: appState.boxOffset,
            onChanged: appState.updateBoxOffset,
          ),
        ),
      ],
    );
  }

  Widget _buildAngleDropdown() {
    return DropdownButton<String>(
      value: appState.angle,
      isExpanded: true,
      items: ['10', '22', '30', '45', '60'].map((angle) {
        return DropdownMenuItem(
          value: angle,
          child: Text('$angle°'),
        );
      }).toList(),
      onChanged: (value) => appState.updateAngle(value!),
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
    debugPrint('Bend Angle: ${appState.angle}°');
  }
}
