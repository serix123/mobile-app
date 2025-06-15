import 'package:flutter/cupertino.dart';
import 'package:online_reservation/Core/Data/Models/paginated.model.dart';
import 'package:online_reservation/Features/Users/Data/Model/user.model.dart';
import 'package:online_reservation/Features/Users/Data/Service/user.service.dart';

class UserProvider with ChangeNotifier {
  final UserApiService _apiService;
  PaginatedResults<User>? _paginatedUsers;
  bool _isLoading = false;
  String? _error;
  User? _userInfo;

  UserProvider(this._apiService);

  User? get userInfo => _userInfo;
  List<User> get users => _paginatedUsers?.results ?? [];
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasNext => _paginatedUsers?.next != null;
  bool get hasPrevious => _paginatedUsers?.previous != null;

  Future<void> getUsers({int page = 1, String query = ""}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _paginatedUsers = await _apiService.getUsers(page: page, query: query);
      _error = null;
    } catch (e) {
      _error = e.toString();
      _paginatedUsers = null;
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> getUserInfo() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _userInfo = await _apiService.getUserInfo();
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> deleteUser(int issueId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      bool success = await _apiService.deleteUser(issueId);
      if (success) {
        _paginatedUsers?.results.removeWhere((issue) => issue.id == issueId);
        notifyListeners();
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> updateUser(User user) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      await _apiService.updatePermission(user: user);
      final index = _paginatedUsers!.results.indexWhere((v) => v.id == user.id);
      _paginatedUsers!.results[index] = _paginatedUsers!.results[index]
          .copyWith(
              email: user.email,
              id: user.id,
              lastName: user.lastName,
              firstName: user.firstName,
              group: user.group);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> updateUserRole(User user) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      await _apiService.updateUserRole(user: user);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadNextPage() async {
    if (hasNext) {
      final nextPage = _getPageFromUrl(_paginatedUsers!.next!);
      await getUsers(page: nextPage);
    }
  }

  Future<void> loadPreviousPage() async {
    if (hasPrevious) {
      final prevPage = _getPageFromUrl(_paginatedUsers!.previous!);
      await getUsers(page: prevPage);
    }
  }

  int _getPageFromUrl(String url) {
    final uri = Uri.parse(url);
    return int.parse(uri.queryParameters['page'] ?? '1');
  }
}
