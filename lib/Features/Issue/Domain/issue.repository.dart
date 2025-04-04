import 'package:flutter/material.dart';
import 'package:online_reservation/Core/Data/Models/paginated.model.dart';
import 'package:online_reservation/Features/Issue/Data/Model/issue.model.dart';
import 'package:online_reservation/Features/Issue/Data/Service/issue.service.dart';

class IssueProvider with ChangeNotifier {
  final IssueApiService _apiService;
  List<Issue> _issues = [];
  bool _isLoading = false;
  String? _error;

  IssueProvider(this._apiService);

  List<Issue> get issues => _issues;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> getIssues({int page = 1, String query = ""}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final PaginatedResults<Issue> paginatedIssues = await _apiService.getIssues(page: page, query: query);
      _issues = paginatedIssues.results;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> updateIssue(Issue issue) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      await _apiService.updateIssue(issue: issue);
      final index = _issues.indexWhere((v) => v.id == issue.id);
      _issues[index] = _issues[index].copyWith(issue);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> createIssue(Issue issue) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      await _apiService.createIssue(issue: issue);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> deleteIssue(int issueId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      bool success = await _apiService.deleteIssue(issueId);
      if (success) {
        _issues.removeWhere((issue) => issue.id == issueId);
        notifyListeners();
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> resolveIssue(int issueId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      bool success = await _apiService.resolveIssue(issueId);
      if (success) {
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
