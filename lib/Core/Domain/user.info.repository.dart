

import 'package:flutter/material.dart';
import 'package:online_reservation/Core/Data/API_Services/user.info.service.dart';
import 'package:online_reservation/Core/Data/Models/user.info.model.dart';

class UserInfoProvider with ChangeNotifier {
  final UserInfoApiService _userInfoApiService;
  late User _user;
  bool _isLoading = false;
  String? _error;

  UserInfoProvider(this._userInfoApiService);

  User get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> getUserInfo() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _user = await _userInfoApiService.getUserInfo();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
    _isLoading = false;
    notifyListeners();
  }

}

