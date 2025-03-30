import 'package:flutter/material.dart';
import 'package:online_reservation/Core/Data/Models/paginated.model.dart';
import 'package:online_reservation/Features/Resident/Data/Model/resident.model.dart';
import 'package:online_reservation/Features/Resident/Data/Service/resident.service.dart';

class ResidentProvider with ChangeNotifier {

  final ResidentApiService _apiService;
  PaginatedResults<Resident>? _paginatedResidents;
  bool _isLoading = false;
  String? _error;

  ResidentProvider(this._apiService);

  List<Resident> get residents => _paginatedResidents?.results ?? [];
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasNext => _paginatedResidents?.next != null;
  bool get hasPrevious => _paginatedResidents?.previous != null;

  Future<void> getResidents({int page = 1}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _paginatedResidents = await _apiService.getResidents(page: page);
      _error = null;
    } catch (e) {
      _error = e.toString();
      _paginatedResidents = null;
    }
    _error = null;
    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadNextPage() async {
    if (hasNext) {
      final nextPage = _getPageFromUrl(_paginatedResidents!.next!);
      await getResidents(page: nextPage);
    }
  }

  Future<void> loadPreviousPage() async {
    if (hasPrevious) {
      final prevPage = _getPageFromUrl(_paginatedResidents!.previous!);
      await getResidents(page: prevPage);
    }
  }

  int _getPageFromUrl(String url) {
    final uri = Uri.parse(url);
    return int.parse(uri.queryParameters['page'] ?? '1');
  }

}