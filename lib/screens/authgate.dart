import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TimeCheckpoint {
  final DateTime timestamp;
  final int monotonicSeconds;

  TimeCheckpoint({
    required this.timestamp,
    required this.monotonicSeconds,
  });

  Map<String, dynamic> toJson() => {
        'timestamp': timestamp.toIso8601String(),
        'monotonicSeconds': monotonicSeconds,
      };

  factory TimeCheckpoint.fromJson(Map<String, dynamic> json) => TimeCheckpoint(
        timestamp: DateTime.parse(json['timestamp']),
        monotonicSeconds: json['monotonicSeconds'],
      );
}

class AuthCode {
  final String deviceId;
  final String technicianId;
  final DateTime timestamp;
  final int validDays;
  final String hash;

  AuthCode({
    required this.deviceId,
    required this.technicianId,
    required this.timestamp,
    required this.validDays,
    required this.hash,
  });

  factory AuthCode.fromString(String code) {
    final parts = code.split(':');
    if (parts.length != 5) throw FormatException('Invalid auth code format');

    return AuthCode(
      deviceId: parts[0],
      technicianId: parts[1],
      timestamp: DateTime.parse(parts[2]),
      validDays: int.parse(parts[3]),
      hash: parts[4],
    );
  }

  @override
  String toString() {
    return '$deviceId:$technicianId:${timestamp.toIso8601String()}:$validDays:$hash';
  }
}

class TimeValidationService {
  static const _timeCheckpointKey = 'time_checkpoint';
  DateTime? _lastValidatedTime;
  int _monotonicSeconds = 0;

  // Maximum allowed time jump in seconds (2 hours)
  static const _maxTimeJumpSeconds = 7200;

  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    final checkpointJson = prefs.getString(_timeCheckpointKey);

    if (checkpointJson != null) {
      final checkpoint = TimeCheckpoint.fromJson(json.decode(checkpointJson));
      _lastValidatedTime = checkpoint.timestamp;
      _monotonicSeconds = checkpoint.monotonicSeconds;
    } else {
      _lastValidatedTime = DateTime.now();
      await _saveCheckpoint();
    }
  }

  Future<void> _saveCheckpoint() async {
    final prefs = await SharedPreferences.getInstance();
    final checkpoint = TimeCheckpoint(
      timestamp: _lastValidatedTime!,
      monotonicSeconds: _monotonicSeconds,
    );
    await prefs.setString(_timeCheckpointKey, json.encode(checkpoint.toJson()));
  }

  Future<bool> validateTime(DateTime currentTime) async {
    if (_lastValidatedTime == null) {
      await initialize();
      return true;
    }

    final timeDiff = currentTime.difference(_lastValidatedTime!).inSeconds;

    // Allow backwards time changes up to 2 hours (for DST)
    if (timeDiff < 0 && timeDiff.abs() <= _maxTimeJumpSeconds) {
      _lastValidatedTime = currentTime;
      await _saveCheckpoint();
      return true;
    }

    // Detect suspicious forward time jumps
    if (timeDiff > _maxTimeJumpSeconds) {
      return false;
    }

    _monotonicSeconds += timeDiff;
    _lastValidatedTime = currentTime;
    await _saveCheckpoint();
    return true;
  }
}

class AuthGateConfig {
  final String deviceId;
  final String secretKey;

  AuthGateConfig({
    required this.deviceId,
    required this.secretKey,
  });
}

class AuthState {
  final DateTime loginTime;
  final DateTime expiryTime;
  final String technicianId;
  final String authCode;

  AuthState({
    required this.loginTime,
    required this.expiryTime,
    required this.technicianId,
    required this.authCode,
  });

  Map<String, dynamic> toJson() => {
        'loginTime': loginTime.toIso8601String(),
        'expiryTime': expiryTime.toIso8601String(),
        'technicianId': technicianId,
        'authCode': authCode,
      };

  factory AuthState.fromJson(Map<String, dynamic> json) => AuthState(
        loginTime: DateTime.parse(json['loginTime']),
        expiryTime: DateTime.parse(json['expiryTime']),
        technicianId: json['technicianId'],
        authCode: json['authCode'],
      );
}

class AuthGate extends StatefulWidget {
  final Widget child;
  final Widget loginScreen;
  final AuthGateConfig config;

  const AuthGate({
    Key? key,
    required this.child,
    required this.loginScreen,
    required this.config,
  }) : super(key: key);

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  AuthState? _authState;
  final String _authStateKey = 'auth_state';
  final _timeValidationService = TimeValidationService();

  @override
  void initState() {
    super.initState();
    _timeValidationService.initialize();
    _loadAuthState();
  }

  Future<void> _loadAuthState() async {
    final prefs = await SharedPreferences.getInstance();
    final stateJson = prefs.getString(_authStateKey);
    if (stateJson != null) {
      setState(() {
        _authState = AuthState.fromJson(json.decode(stateJson));
      });
    }
  }

  Future<void> _saveAuthState(AuthState state) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_authStateKey, json.encode(state.toJson()));
    setState(() {
      _authState = state;
    });
  }

  bool _verifyAuthCode(String code, String secretKey) {
    try {
      final authCode = AuthCode.fromString(code);

      // Verify device ID
      if (authCode.deviceId != widget.config.deviceId) return false;

      // Verify hash
      final message =
          '${authCode.deviceId}:${authCode.technicianId}:${authCode.timestamp.toIso8601String()}:${authCode.validDays}';
      final computedHash =
          sha256.convert(utf8.encode('$message:$secretKey')).toString();

      if (computedHash != authCode.hash) return false;

      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> login(String authCode) async {
    if (!_verifyAuthCode(authCode, widget.config.secretKey)) {
      return false;
    }

    final code = AuthCode.fromString(authCode);
    final now = DateTime.now();

    // Validate time
    if (!await _timeValidationService.validateTime(now)) {
      return false;
    }

    final authState = AuthState(
      loginTime: now,
      expiryTime: code.timestamp.add(Duration(days: code.validDays)),
      technicianId: code.technicianId,
      authCode: authCode,
    );

    await _saveAuthState(authState);
    return true;
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_authStateKey);
    setState(() {
      _authState = null;
    });
  }

  Future<bool> _isAuthValid() async {
    if (_authState == null) return false;

    final now = DateTime.now();
    if (!await _timeValidationService.validateTime(now)) {
      await logout();
      return false;
    }

    if (_authState!.expiryTime.isBefore(now)) {
      await logout();
      return false;
    }

    return true;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _isAuthValid(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const CircularProgressIndicator();
        }

        if (!snapshot.data!) {
          return LoginScreen(
            onLogin: (code) => login(code),
            deviceId: widget.config.deviceId,
          );
        }

        return widget.child;
      },
    );
  }
}

class LoginScreen extends StatefulWidget {
  final Future<bool> Function(String authCode) onLogin;
  final String deviceId;

  const LoginScreen({
    Key? key,
    required this.onLogin,
    required this.deviceId,
  }) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _authCodeController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _handleLogin() async {
    if (_authCodeController.text.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter an authentication code';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final success = await widget.onLogin(_authCodeController.text);

      if (!success) {
        setState(() {
          _errorMessage = 'Invalid authentication code';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'An error occurred. Please try again.';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Device ID: ${widget.deviceId}'),
            const SizedBox(height: 24),
            TextField(
              controller: _authCodeController,
              decoration: const InputDecoration(
                labelText: 'Authentication Code',
              ),
            ),
            const SizedBox(height: 24),
            if (_errorMessage != null)
              Text(
                _errorMessage!,
                style: const TextStyle(color: Colors.red),
              ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _isLoading ? null : _handleLogin,
              child: _isLoading
                  ? const CircularProgressIndicator()
                  : const Text('Login'),
            ),
          ],
        ),
      ),
    );
  }
}
