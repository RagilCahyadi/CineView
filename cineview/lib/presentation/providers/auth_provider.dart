import 'package:flutter/material.dart';
import 'package:cineview/data/services/auth_service.dart';
import 'package:cineview/data/services/storage_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final StorageService _storageService = StorageService();

  bool _isLoading = false;
  bool _isLoggedIn = false;
  String? _errorMessage;
  Map<String, dynamic>? _user;

  bool get isLoading => _isLoading;
  bool get isLoggedIn => _isLoggedIn;
  String? get errorMessage => _errorMessage;
  Map<String, dynamic>? get user => _user;

  Future<void> checkLoginStatus() async {
    _isLoggedIn = await _storageService.isLoggedIn();
    notifyListeners();
  }

  Future<bool> register({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
  }) async{
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _authService.register(
      name: name,
      email: email,
      password: password,
      passwordConfirmation: passwordConfirmation,
    );

    _isLoading = false;

    if (result['success']){
      _isLoggedIn = true;
      _user = result['user'];
      notifyListeners();
      return true;
    } else {
      _errorMessage = result['message'];
      notifyListeners();
      return false;
    }
  }

  Future<bool> login({
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    
    final result = await _authService.login(
      email: email,
      password: password,
    );

    _isLoading = false;

    if (result['success']){
      _isLoggedIn = true;
      _user = result['user'];
      notifyListeners();
      return true;
    } else {
      _errorMessage = result['message'];
      notifyListeners();
      return false;
    }
  }

  Future<void> logout () async{
    _isLoading = true;
    notifyListeners();
    
    await _authService.logout();
    
    _isLoading = false;
    _isLoggedIn = false;
    _user = null;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}