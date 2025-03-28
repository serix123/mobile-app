import 'package:flutter/cupertino.dart';
import 'package:online_reservation/Core/Data/Models/paginated.model.dart';
import 'package:online_reservation/Features/Users/Data/Model/user.model.dart';
import 'package:online_reservation/Features/Users/Data/Service/user.service.dart';

class UserProvider with ChangeNotifier{

  final UserApiService apiService;
  PaginatedResults<User>? _paginatedUsers;
  bool _isLoading = false;
  String? _error;

  UserProvider(this.apiService);

  List<User> get users => _paginatedUsers?.results ?? [];
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasNext => _paginatedUsers?.next != null;
  bool get hasPrevious => _paginatedUsers?.previous != null;

  Future<void> getUsers({int page = 1}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _paginatedUsers = await apiService.getUsers(page: page);
      _error = null;
    } catch (e) {
      _error = e.toString();
      _paginatedUsers = null;
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