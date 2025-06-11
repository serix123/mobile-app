import 'package:flutter/material.dart';
import 'package:online_reservation/Features/Profile/Data/Model/profile.model.dart';
import 'package:online_reservation/Features/Profile/Data/Service/profile.service.dart';

class ProfileProvider with ChangeNotifier{

  final ProfileApiService _apiService;
  UserProfile? _user;
  bool _isLoading = false;
  String? _error;

  ProfileProvider(this._apiService);

  UserProfile? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> getProfile() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _user = await _apiService.getProfile();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
    _isLoading = false;
    notifyListeners();
  }

}