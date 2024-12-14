import 'package:flutter/material.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'package:flutter/services.dart';

class AuthCodeGenerator extends StatefulWidget {
  final String secretKey;

  const AuthCodeGenerator({
    Key? key,
    required this.secretKey,
  }) : super(key: key);

  @override
  State<AuthCodeGenerator> createState() => _AuthCodeGeneratorState();
}

class _AuthCodeGeneratorState extends State<AuthCodeGenerator> {
  final _deviceIdController = TextEditingController();
  final _technicianIdController = TextEditingController();
  final _validDaysController = TextEditingController(text: '30');
  String? _generatedCode;
  String? _error;

  String _generateAuthCode() {
    try {
      if (_deviceIdController.text.isEmpty ||
          _technicianIdController.text.isEmpty ||
          _validDaysController.text.isEmpty) {
        throw Exception('All fields are required');
      }

      final deviceId = _deviceIdController.text;
      final technicianId = _technicianIdController.text;
      final validDays = int.parse(_validDaysController.text);

      if (validDays <= 0 || validDays > 365) {
        throw Exception('Valid days must be between 1 and 365');
      }

      final timestamp = DateTime.now();
      final message =
          '$deviceId:$technicianId:${timestamp.toIso8601String()}:$validDays';
      final hash = sha256
          .convert(utf8.encode('$message:${widget.secretKey}'))
          .toString();

      return '$message:$hash';
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
      return '';
    }
  }

  void _copyToClipboard() {
    if (_generatedCode != null) {
      Clipboard.setData(ClipboardData(text: _generatedCode!));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Code copied to clipboard'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Auth Code Generator'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _deviceIdController,
              decoration: const InputDecoration(
                labelText: 'Device ID',
                helperText: 'Enter the target device ID',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _technicianIdController,
              decoration: const InputDecoration(
                labelText: 'Technician ID',
                helperText: 'Enter the technician\'s identifier',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _validDaysController,
              decoration: const InputDecoration(
                labelText: 'Valid Days',
                helperText: 'Enter number of days (1-365)',
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
              ],
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _error = null;
                  _generatedCode = _generateAuthCode();
                });
              },
              child: const Text('Generate Code'),
            ),
            if (_error != null)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: Text(
                  _error!,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.error,
                  ),
                ),
              ),
            if (_generatedCode != null && _generatedCode!.isNotEmpty) ...[
              const SizedBox(height: 24),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Generated Code:',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.copy),
                            onPressed: _copyToClipboard,
                            tooltip: 'Copy to clipboard',
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      SelectableText(
                        _generatedCode!,
                        style: const TextStyle(
                          fontFamily: 'monospace',
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Generated at: ${DateTime.now().toLocal()}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _deviceIdController.dispose();
    _technicianIdController.dispose();
    _validDaysController.dispose();
    super.dispose();
  }
}
