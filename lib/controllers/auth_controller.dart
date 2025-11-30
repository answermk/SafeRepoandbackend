import 'package:flutter/foundation.dart';
import '../services/auth_service.dart';
import '../services/token_manager.dart';
import '../core/models/user_model.dart';

/// Authentication Controller
/// Manages authentication state and operations
class AuthController extends ChangeNotifier {
  bool _isAuthenticated = false;
  bool _isLoading = false;
  String? _error;
  UserModel? _currentUser;

  bool get isAuthenticated => _isAuthenticated;
  bool get isLoading => _isLoading;
  String? get error => _error;
  UserModel? get currentUser => _currentUser;

  AuthController() {
    _checkAuthStatus();
  }

  /// Check if user is already authenticated
  Future<void> _checkAuthStatus() async {
    _isAuthenticated = await TokenManager.isAuthenticated();
    notifyListeners();
  }

  /// Login user
  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await AuthService.login(email, password);

      if (result['success'] == true) {
        await TokenManager.saveToken(
          token: result['token'],
          email: result['email'],
          username: result['username'],
        );
        _isAuthenticated = true;
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = result['error'] ?? 'Login failed';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'An error occurred: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Register new user
  Future<bool> register({
    required String email,
    required String password,
    required String fullName,
    String? phone,
    String? location,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await AuthService.register(
        email: email,
        password: password,
        fullName: fullName,
        phone: phone,
        location: location,
      );

      if (result['success'] == true) {
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = result['error'] ?? 'Registration failed';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'An error occurred: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Logout user
  Future<void> logout() async {
    await AuthService.logout();
    await TokenManager.clearToken();
    _isAuthenticated = false;
    _currentUser = null;
    notifyListeners();
  }

  /// Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}

