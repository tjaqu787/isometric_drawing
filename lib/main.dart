import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'components/authgate.dart';
import 'screens/isometric_view.dart';

// State management
class AuthState extends ChangeNotifier {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  final LocalAuthentication _localAuth = LocalAuthentication();
  bool _isLoading = false;
  String? _error;

  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _storage.delete(key: 'auth_state');
      // Clear any other secure storage items
      await _storage.delete(key: 'last_session');
      await _storage.delete(key: 'biometric_enabled');
    } catch (e) {
      _error = 'Error during logout: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> authenticateWithBiometrics() async {
    try {
      final canCheckBiometrics = await _localAuth.canCheckBiometrics;
      if (!canCheckBiometrics) return false;

      return await _localAuth.authenticate(
        localizedReason: 'Please authenticate to access the application',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
        ),
      );
    } catch (e) {
      _error = 'Biometric authentication failed: $e';
      return false;
    }
  }
}

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => AuthState(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Isometric Game',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: FutureBuilder(
        future: SharedPreferences.getInstance(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const EnhancedLoadingScreen();
          }

          return AuthGate(
            config: AuthGateConfig(
              validityDays: 30,
              secretKey: const String.fromEnvironment('AUTH_SECRET_KEY',
                  defaultValue: 'default-key-do-not-use-in-production'),
            ),
            loginScreen: LoginScreen(
              onLogin: (username, password) async {
                final authState = context.read<AuthState>();

                // First try biometric authentication if available
                if (await authState.authenticateWithBiometrics()) {
                  return true;
                }

                // Proceed with regular login if biometrics fails or isn't available
                // The actual login logic is handled by AuthGate
                return true;
              },
              validityDays: 30,
            ),
            child: const IsometricView(),
          );
        },
      ),
    );
  }
}

class EnhancedLoadingScreen extends StatefulWidget {
  const EnhancedLoadingScreen({super.key});

  @override
  State<EnhancedLoadingScreen> createState() => _EnhancedLoadingScreenState();
}

class _EnhancedLoadingScreenState extends State<EnhancedLoadingScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ScaleTransition(
              scale: _animation,
              child: Icon(
                Icons.gamepad,
                size: 64,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 24),
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(
              'Loading...',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ],
        ),
      ),
    );
  }
}
