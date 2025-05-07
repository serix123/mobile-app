import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:online_reservation/Core/Data/Models/paginated.model.dart';
import 'package:online_reservation/Features/MedApplication/Data/Model/application.model.dart';
import 'package:online_reservation/Features/MedApplication/Data/Service/application.service.dart';

class ApplicationProvider with ChangeNotifier {
  final ApplicationApiService _apiService;
  PaginatedResults<PatientProfile>? _paginatedApplications;
  List<PatientProfile> _applications = [];
  bool _isLoading = false;
  String? _error;

  // ApplicationProvider({required ResourceApiService apiService}) : _apiService = apiService;
  ApplicationProvider(this._apiService);

  List<PatientProfile> get applications => _applications;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasNext => _paginatedApplications?.next != null;
  bool get hasPrevious => _paginatedApplications?.previous != null;

  Future<void> getProfiles(
      {int page = 1,
      String query = "",
      String status = "",
      String gender = ""}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _paginatedApplications = await _apiService.getProfiles(
          page: page, query: query, status: status, gender: gender);
      _applications = _paginatedApplications?.results ?? [];
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> getProfile(int id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final profile = await _apiService.getProfile(id);
      final index = _applications.indexWhere((v) => v.id == profile.id);
      _applications[index] = _applications[index].copyWith(profile);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> updateApplication(PatientProfile profile) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      await _apiService.updateApplication(profile: profile);
      final index = _applications.indexWhere((v) => v.id == profile.id);
      _applications[index] = _applications[index].copyWith(profile);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> uploadFile(int profileId, PlatformFile file, bool isWeb) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      await _apiService.uploadFileAdaptive(profileId, file, isWeb);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> deleteApplication(int id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      bool success = await _apiService.deleteApplication(id);
      if (success) {
        _applications.removeWhere((resource) => resource.id == id);
        notifyListeners();
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> verifyApplication(int id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      await _apiService.verifyProfile(id);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> rejectApplication(int id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      await _apiService.rejectProfile(id);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> resetApplication(int id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      await _apiService.resetProfile(id);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadNextPage() async {
    if (hasNext) {
      final nextPage = _getPageFromUrl(_paginatedApplications!.next!);
      await getProfiles(page: nextPage);
    }
  }

  Future<void> loadPreviousPage() async {
    if (hasPrevious) {
      final prevPage = _getPageFromUrl(_paginatedApplications!.previous!);
      await getProfiles(page: prevPage);
    }
  }

  int _getPageFromUrl(String url) {
    final uri = Uri.parse(url);
    return int.parse(uri.queryParameters['page'] ?? '1');
  }
}
