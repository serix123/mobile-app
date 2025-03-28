import 'package:flutter/material.dart';
import 'package:online_reservation/Core/Data/Models/paginated.model.dart';
import 'package:online_reservation/Features/Issue/Data/Model/issue.model.dart';
import 'package:online_reservation/Features/Issue/Data/Service/issue.service.dart';

class IssueProvider with ChangeNotifier {
  final IssueApiService apiService;
  List<Issue> _issues = [];
  bool _isLoading = false;
  String? _error;

  IssueProvider(this.apiService);

  List<Issue> get issues => _issues;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> getIssues({int page = 1}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final PaginatedResults<Issue> paginatedIssues = await apiService.getIssues(page: page);
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
      final issueId = issue.id;
      await apiService.updateIssue(issue: issue);
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
      await apiService.createIssue(issue: issue);
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
      bool success = await apiService.deleteIssue(issueId);
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
}
