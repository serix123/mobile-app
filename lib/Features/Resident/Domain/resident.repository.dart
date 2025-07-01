import 'package:flutter/material.dart';
import 'package:online_reservation/Core/Data/Models/paginated.model.dart';
import 'package:online_reservation/Features/Resident/Data/Model/resident.model.dart';
import 'package:online_reservation/Features/Resident/Data/Service/resident.service.dart';

class ResidentProvider with ChangeNotifier {

  final ResidentApiService _apiService;
  PaginatedResults<Resident>? _paginatedResidents;
  Resident? _resident;
  bool _isLoading = false;
  String? _error;

  ResidentProvider(this._apiService);

  List<Resident> get residents => _paginatedResidents?.results ?? [];
  Resident? get resident => _resident;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasNext => _paginatedResidents?.next != null;
  bool get hasPrevious => _paginatedResidents?.previous != null;

  // For Dashboard
  int residentCount = 0;

  Future<void> getResidentSummary() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final summaryData = await _apiService.getResidentSummary();
      residentCount = summaryData['total_population'] ?? 0;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> updateResident(Resident resident) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      await _apiService.updateResident(resident: resident);
      final index = _paginatedResidents!.results.indexWhere((v) => v.id == resident.id);
      _paginatedResidents!.results[index] = _paginatedResidents!.results[index].copyWith(resident);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> getResidents({int page = 1, String query = "", RoleType role = RoleType.ALL}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _paginatedResidents = await _apiService.getResidents(page: page, query: query,role: role);
      _error = null;
    } catch (e) {
      _error = e.toString();
      _paginatedResidents = null;
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> getResident({required int residentId}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _resident = await _apiService.getResident(residentId);
      _error = null;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
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

  void filterByRole(RoleType? role) {
    getResidents(page: 1, role: role ?? RoleType.ALL);
  }

}