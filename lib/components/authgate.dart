import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthGateConfig {
  final int validityDays;
  final String secretKey;

  AuthGateConfig({
    required this.validityDays,
    required this.secretKey,
  });
}

class AuthState {
  final DateTime loginTime;
  final DateTime expiryTime;
  final String authHash;

  AuthState({
    required this.loginTime,
    required this.expiryTime,
    required this.authHash,
  });

  Map<String, dynamic> toJson() => {
        'loginTime': loginTime.toIso8601String(),
        'expiryTime': expiryTime.toIso8601String(),
        'authHash': authHash,
      };

  factory AuthState.fromJson(Map<String, dynamic> json) => AuthState(
        loginTime: DateTime.parse(json['loginTime']),
        expiryTime: DateTime.parse(json['expiryTime']),
        authHash: json['authHash'],
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

  @override
  void initState() {
    super.initState();
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

  String _generateAuthHash(String username, String password) {
    final key = widget.config.secretKey;
    final bytes = utf8.encode('$username:$password:$key');
    return sha256.convert(bytes).toString();
  }

  Future<bool> login(String username, String password) async {
    // In a real app, you might want to validate credentials against a cached local database
    final now = DateTime.now();
    final authHash = _generateAuthHash(username, password);

    final authState = AuthState(
      loginTime: now,
      expiryTime: now.add(Duration(days: widget.config.validityDays)),
      authHash: authHash,
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

  bool _isAuthValid() {
    if (_authState == null) return false;
    return _authState!.expiryTime.isAfter(DateTime.now());
  }

  @override
  Widget build(BuildContext context) {
    if (!_isAuthValid()) {
      return LoginScreen(
        onLogin: login,
        validityDays: widget.config.validityDays,
      );
    }

    return widget.child;
  }
}

class LoginScreen extends StatefulWidget {
  final Future<bool> Function(String username, String password) onLogin;
  final int validityDays;

  const LoginScreen({
    Key? key,
    required this.onLogin,
    required this.validityDays,
  }) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _handleLogin() async {
    if (_usernameController.text.isEmpty || _passwordController.text.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter both username and password';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final success = await widget.onLogin(
        _usernameController.text,
        _passwordController.text,
      );

      if (!success) {
        setState(() {
          _errorMessage = 'Invalid credentials';
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
            TextField(
              controller: _usernameController,
              decoration: const InputDecoration(
                labelText: 'Username',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(
                labelText: 'Password',
              ),
              obscureText: true,
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
            const SizedBox(height: 16),
            Text(
              'Access will be valid for ${widget.validityDays} days',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}
