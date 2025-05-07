import 'package:flutter/cupertino.dart';
import 'package:online_reservation/Core/Data/Models/paginated.model.dart';
import 'package:online_reservation/Features/MedicalRecords/Data/Model/medicalRecord.model.dart';
import 'package:online_reservation/Features/MedicalRecords/Data/Service/medicalRecord.service.dart';

class MedicalRecordProvider with ChangeNotifier {
  final MedicalRecordApiService _apiService;
  PaginatedResults<MedicalRecord>? _paginatedRecords;
  List<MedicalRecord> _records = [];
  bool _isLoading = false;
  String? _error;

  MedicalRecordProvider(this._apiService);

  List<MedicalRecord> get records => _records;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasNext => _paginatedRecords?.next != null;
  bool get hasPrevious => _paginatedRecords?.previous != null;

  Future<void> getRecords(
      {int page = 1, String query = "", String category = ""}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _paginatedRecords = await _apiService.getRecords(
          page: page, query: query, category: category);
      _records = _paginatedRecords?.results ?? [];
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> getRecord(int id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final record = await _apiService.getRecord(id);
      final index = _records.indexWhere((v) => v.id == record.id);
      _records[index] = _records[index].copyWith(
          id : record.id,
          patient : record.patient,
          patientDetails : record.patientDetails,
          visitDate : record.visitDate,
          diagnosisCategory : record.diagnosisCategory,
          diagnosisDetails : record.diagnosisDetails,
          treatment : record.treatment,
          attendingDoctor : record.attendingDoctor,
          doctorName : record.doctorName,
          notes : record.notes,
          followUpDate : record.followUpDate,
      );
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> updateApplication(MedicalRecord record) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      await _apiService.updateApplication(record: record);
      final index = _records.indexWhere((v) => v.id == record.id);
      _records[index] = _records[index].copyWith(
        id : record.id,
        patient : record.patient,
        patientDetails : record.patientDetails,
        visitDate : record.visitDate,
        diagnosisCategory : record.diagnosisCategory,
        diagnosisDetails : record.diagnosisDetails,
        treatment : record.treatment,
        attendingDoctor : record.attendingDoctor,
        doctorName : record.doctorName,
        notes : record.notes,
        followUpDate : record.followUpDate,
      );
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> createRecord(MedicalRecord record) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      await _apiService.createRecord(record: record);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> deleteRecord(int recordId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      bool success = await _apiService.deleteRecord(recordId);
      if (success) {
        _records.removeWhere((issue) => issue.id == recordId);
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
      final nextPage = _getPageFromUrl(_paginatedRecords!.next!);
      await getRecords(page: nextPage);
    }
  }

  Future<void> loadPreviousPage() async {
    if (hasPrevious) {
      final prevPage = _getPageFromUrl(_paginatedRecords!.previous!);
      await getRecords(page: prevPage);
    }
  }

  int _getPageFromUrl(String url) {
    final uri = Uri.parse(url);
    return int.parse(uri.queryParameters['page'] ?? '1');
  }
}
