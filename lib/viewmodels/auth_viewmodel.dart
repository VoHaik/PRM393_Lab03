import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import '../services/analytics_service.dart';

class AuthViewModel extends ChangeNotifier {
  final AuthService authService;
  final AnalyticsService analyticsService;
  StreamSubscription<User?>? _authSubscription;

  AuthViewModel({
    required this.authService,
    required this.analyticsService,
  }) {
    _user = authService.currentUser;
    _authSubscription = authService.authStateChanges.listen((User? user) {
      _user = user;
      notifyListeners();
    });
  }

  bool _isLoading = false;
  String? _errorMessage;
  User? _user;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  User? get user => _user;
  bool get isAuthenticated => _user != null;

  Future<bool> signIn() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final credential = await authService.signInWithGoogle();
      if (credential != null) {
        // Log successful login event
        await analyticsService.logLogin();
      }
      _isLoading = false;
      notifyListeners();
      return credential != null; // return true if login succeeded, false if user cancelled
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> signOut() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await authService.signOut();
      // Log logout event
      await analyticsService.logLogout();
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }
}
