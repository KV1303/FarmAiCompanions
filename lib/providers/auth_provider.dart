import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;

import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../services/local_storage_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final LocalStorageService _localStorageService = LocalStorageService();
  
  User? _user;
  bool _isLoading = true;
  bool _isAuthenticated = false;
  bool _isFirstTime = false;
  String _error = '';
  
  User? get user => _user;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _isAuthenticated;
  bool get isFirstTime => _isFirstTime;
  String get error => _error;
  
  AuthProvider() {
    checkAuthStatus();
  }
  
  Future<void> checkAuthStatus() async {
    try {
      _isLoading = true;
      notifyListeners();
      
      // Check if it's first time opening the app
      _isFirstTime = await _localStorageService.isFirstTime();
      
      // Check if user is logged in
      final firebaseUser = firebase_auth.FirebaseAuth.instance.currentUser;
      
      if (firebaseUser != null) {
        // Get user data from local storage or server
        _user = await _localStorageService.getUser(firebaseUser.uid);
        
        if (_user == null) {
          // If not in local storage, try to get from server
          _user = await _authService.getUserData(firebaseUser.uid);
          
          // Save to local storage
          if (_user != null) {
            await _localStorageService.saveUser(_user!);
          }
        }
        
        _isAuthenticated = _user != null;
      } else {
        _isAuthenticated = false;
        _user = null;
      }
    } catch (e) {
      _error = e.toString();
      _isAuthenticated = false;
      _user = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  Future<bool> login(String email, String password) async {
    try {
      _isLoading = true;
      _error = '';
      notifyListeners();
      
      final firebaseUser = await _authService.signIn(email, password);
      
      if (firebaseUser != null) {
        _user = await _authService.getUserData(firebaseUser.uid);
        
        if (_user != null) {
          await _localStorageService.saveUser(_user!);
          _isAuthenticated = true;
          return true;
        }
      }
      
      _error = 'Failed to login. Please check your credentials.';
      return false;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  Future<bool> register(String name, String email, String password, String phone, String location) async {
    try {
      _isLoading = true;
      _error = '';
      notifyListeners();
      
      // Register with firebase
      final firebaseUser = await _authService.signUp(email, password);
      
      if (firebaseUser != null) {
        // Create user in database
        _user = await _authService.createUser(
          firebaseUser.uid,
          name,
          email,
          phone,
          location,
        );
        
        if (_user != null) {
          await _localStorageService.saveUser(_user!);
          _isAuthenticated = true;
          await _localStorageService.setFirstTime(false);
          _isFirstTime = false;
          return true;
        }
      }
      
      _error = 'Failed to register. Please try again.';
      return false;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  Future<void> logout() async {
    try {
      _isLoading = true;
      notifyListeners();
      
      await _authService.signOut();
      await _localStorageService.clearSession();
      
      _isAuthenticated = false;
      _user = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  Future<void> updateUserProfile(String name, String phone, String location) async {
    try {
      _isLoading = true;
      _error = '';
      notifyListeners();
      
      if (_user != null) {
        final updatedUser = await _authService.updateUserProfile(
          _user!.id,
          name,
          phone,
          location,
        );
        
        if (updatedUser != null) {
          _user = updatedUser;
          await _localStorageService.saveUser(_user!);
        } else {
          _error = 'Failed to update profile. Please try again.';
        }
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  Future<void> resetPassword(String email) async {
    try {
      _isLoading = true;
      _error = '';
      notifyListeners();
      
      await _authService.resetPassword(email);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  Future<void> completeOnboarding() async {
    await _localStorageService.setFirstTime(false);
    _isFirstTime = false;
    notifyListeners();
  }
}
