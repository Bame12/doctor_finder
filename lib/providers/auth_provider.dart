import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:doctor_finder_flutter/models/user_model.dart';
import 'package:doctor_finder_flutter/services/auth_service.dart';
import 'package:doctor_finder_flutter/services/firebase_service.dart';

class AuthProvider extends ChangeNotifier {
  UserModel? _currentUser;
  bool _isLoading = false;
  String? _error;

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isLoggedIn => _currentUser != null;

  AuthProvider() {
    _initialize();
  }

  void _initialize() {
    // Check if Firebase is initialized before setting up listener
    if (FirebaseService.isInitialized) {
      _setupAuthListener();
    } else {
      print('Firebase not initialized. Auth state listener not set up.');
    }
  }

  void _setupAuthListener() {
    try {
      // Listen for auth state changes
      FirebaseService.auth.authStateChanges().listen(
            (User? user) async {
          if (user != null) {
            await _fetchUserData();
          } else {
            _currentUser = null;
            notifyListeners();
          }
        },
        onError: (error) {
          print('Auth state change error: $error');
          _error = error.toString();
          notifyListeners();
        },
      );
    } catch (e) {
      print('Error setting up auth listener: $e');
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> _fetchUserData() async {
    try {
      _currentUser = await AuthService.getCurrentUserData();
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<bool> signUp({
    required String email,
    required String password,
    required String name,
    String? phone,
  }) async {
    try {
      _setLoading(true);
      _error = null;

      await AuthService.signUpWithEmailAndPassword(
        email: email,
        password: password,
        name: name,
        phone: phone,
      );

      await _fetchUserData();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> signIn({
    required String email,
    required String password,
  }) async {
    try {
      _setLoading(true);
      _error = null;

      await AuthService.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      await _fetchUserData();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> signOut() async {
    try {
      _setLoading(true);
      await AuthService.signOut();
      _currentUser = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> resetPassword(String email) async {
    try {
      _setLoading(true);
      _error = null;

      await AuthService.resetPassword(email);
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}