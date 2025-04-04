import 'package:flutter/foundation.dart';
import 'package:online_reservation/Core/Data/Models/paginated.model.dart';
import 'package:online_reservation/Features/Visitor/Data/Model/visitor.model.dart';
import 'package:online_reservation/Features/Visitor/Data/Service/visitor.service.dart';

class VisitProvider with ChangeNotifier {
  final VisitApiService _apiService;
  PaginatedResults<Visitor>? _paginatedVisits;
  List<Visitor> _visits = [];
  bool _isLoading = false;
  String? _error;

  VisitProvider(this._apiService);

  List<Visitor> get visits => _visits;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasNext => _paginatedVisits?.next != null;
  bool get hasPrevious => _paginatedVisits?.previous != null;

  Future<void> loadVisitors({int page = 1, String query = ""}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _paginatedVisits = await _apiService.getVisitors(page: page, query: query);
      _visits = _paginatedVisits?.results ?? [];
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> updateVisitor(VisitorDTO visitor) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      await _apiService.updateVisitor(visitor);
      final index = _visits.indexWhere((v) => v.id == visitor.id);
      _visits[index] = _visits[index].copyWith(visitor);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> createVisitor(VisitorDTO visitor) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      await _apiService.createVisitor(visitor);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> deleteVisitor(int visitId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      bool success = await _apiService.deleteVisitor(visitId);
      if (success) {
        _visits.removeWhere((visit) => visit.id == visitId);
        notifyListeners();
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadNextPage() async {
    if (hasNext) {
      final nextPage = _getPageFromUrl(_paginatedVisits!.next!);
      await loadVisitors(page: nextPage);
    }
  }

  Future<void> loadPreviousPage() async {
    if (hasPrevious) {
      final prevPage = _getPageFromUrl(_paginatedVisits!.previous!);
      await loadVisitors(page: prevPage);
    }
  }

  int _getPageFromUrl(String url) {
    final uri = Uri.parse(url);
    return int.parse(uri.queryParameters['page'] ?? '1');
  }

  Future<void> checkInVisitorOfficer(VisitorDTO visitor) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      await _apiService.checkInVisitorOfficer(visitor);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> checkInVisitor(int visitId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      bool success = await _apiService.checkInVisitor(visitId);
      if (success) {

      }else{

      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> checkOutVisitor(int visitId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      bool success = await _apiService.checkOutVisitor(visitId);
      if (success) {

      }else{

      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
    _isLoading = false;
    notifyListeners();
  }
}
