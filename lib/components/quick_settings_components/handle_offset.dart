import 'package:flutter/material.dart';

// box_offset_input.dart
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
