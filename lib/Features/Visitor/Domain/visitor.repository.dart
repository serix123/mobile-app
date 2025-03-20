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
    _error = null;
    notifyListeners();
    try {
      final PaginatedVisitors paginatedVisits = await apiService.getVisitors();
      _visits = paginatedVisits.results;
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
      // final visitorDTO = VisitorDTO(id:visitor.id, name: visitor.name, visitDate: visitor.visitDate, visitPurpose: visitor.visitPurpose);
      final visitId = visitor.id;
      await apiService.updateVisitor(visitor);
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
      await apiService.createVisitor(visitor);
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
      bool success = await apiService.deleteVisitor(visitId);
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
}
