import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:online_reservation/Features/Authentication/Data/Model/auth.model.dart';
import 'package:online_reservation/Features/Authentication/Data/Service/auth.service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService;
  bool _isLoading = false;
  bool _isLoggedIn = false;
  String? _error;

  AuthProvider(this._authService) {
    // init();
    _startRefreshTimer();
  }

  static const Duration _refreshInterval = Duration(minutes: 5);
  Timer? _timer;
  void _startRefreshTimer() {
    _timer = Timer.periodic(_refreshInterval, (timer) {
      refreshAccessToken();
    });
  }


  Future<void> init() async {
    _isLoading = false;
    _error = '';
    bool validToken = await _authService.getAccToken();
    if (!validToken) {
      await refreshAccessToken();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  bool get isLoggedIn => _isLoggedIn;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      UserUpdateDetails userUpdateDetails = UserUpdateDetails(email: email, password: password);
      final success = await _authService.login(userUpdateDetails);
      _isLoggedIn = true;
      if (!success) {
        _error = 'Invalid credentials';
        _isLoggedIn = false;
      }
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> logout() async {
    _error = null;
    try {
      await _authService.logout();
      _isLoggedIn = false;
    } catch (e) {
      _error = e.toString();
    }
    notifyListeners();
  }

  Future<void> refreshAccessToken() async {
    bool refreshed = await _authService.refreshToken();
    if (refreshed) {
      _isLoggedIn = true;
    } else {
      _isLoggedIn = false;
      await logout();
    }
    notifyListeners();
  }
}
