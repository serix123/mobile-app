import 'package:flutter/foundation.dart';
import 'package:online_reservation/Features/Visitor/Data/Model/visitor.model.dart';
import 'package:online_reservation/Features/Visitor/Data/Service/visitor.service.dart';

class VisitProvider with ChangeNotifier {
  final VisitApiService apiService;
  List<Visitor> _visits = [];
  bool _isLoading = false;
  String? _error;

  VisitProvider(this.apiService);

  List<Visitor> get visits => _visits;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadVisitors() async {
    _isLoading = true;
    notifyListeners();

    try {
      final PaginatedVisitors paginatedVisits = await apiService.getVisitors();
      _visits = paginatedVisits.results;
      _error = null;
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> updateVisitStatus(int visitId, String newStatus) async {
    try {
      await apiService.updateStatus(visitId, newStatus);
      final index = _visits.indexWhere((v) => v.id == visitId);
      _visits[index] = _visits[index].copyWith(status: newStatus);
      notifyListeners();
    } catch (e) {
      throw Exception('Failed to update status: $e');
    }
  }

  Future<void> createVisitor(VisitorDTO visitor) async {
    _isLoading = true;
    notifyListeners();
    try {
      await apiService.createVisitor(visitor);
      notifyListeners();
    } catch (e) {
      throw Exception('Failed to update status: $e');
    }
    _isLoading = false;
    notifyListeners();
  }
}