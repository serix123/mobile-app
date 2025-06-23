import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:online_reservation/Core/Data/Models/paginated.model.dart';
import 'package:online_reservation/Features/Issue/Data/Model/issue.model.dart';
import 'package:online_reservation/Features/Issue/Data/Service/issue.service.dart';
import 'package:online_reservation/Utils/utils.dart';

class IssueProvider with ChangeNotifier {
  final IssueApiService _apiService;
  PaginatedResults<Issue>? _paginatedIssues;
  List<Issue> _issues = [];
  bool _isLoading = false;
  String? _error;
  int page_count = 0;

  IssueProvider(this._apiService);

  List<Issue> get issues => _issues;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasNext => _paginatedIssues?.next != null;
  bool get hasPrevious => _paginatedIssues?.previous != null;

  Future<void> getIssues({int page = 1, String query = "",String status = "",String priority = ""}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final PaginatedResults<Issue> paginatedIssues = await _apiService.getIssues(page: page, query: query, status: status, priority: priority);
      _paginatedIssues = paginatedIssues;
      _issues = paginatedIssues.results;
      page_count = Utils.calculateTotalPages(paginatedIssues.count, 10);
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
      _issues[index] = _issues[index].copyWith(
        id: issue.id,
        title: issue.title,
        description: issue.description,
        status: issue.status,
        priority: issue.priority,
        imageUrl: issue.imageUrl,
        userFullName: issue.userFullName,
        userId: issue.userId,
        assigneeFullName: issue.assigneeFullName,
        assigneeId: issue.assigneeId,
        reportedDate: issue.reportedDate,
        resolvedDate: issue.resolvedDate,
      );
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<Issue?> createIssue(Issue issue) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    final Issue newIssue;
    try {
      newIssue = await _apiService.createIssue(issue: issue);
      _isLoading = false;
      notifyListeners();
      return newIssue;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
    _isLoading = false;
    notifyListeners();
    return null;
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

  Future<void> uploadFile(int issueId, PlatformFile file, bool isWeb) async {
    _isLoading = true;
    // _error = null;
    notifyListeners();
    try {
      await _apiService.uploadFileAdaptive(issueId, file, isWeb);
      notifyListeners();
    } catch (e) {
      if(_error != null) {
        _error = "$_error ${e.toString()}";
      }else{
        _error = e.toString();
      }
      notifyListeners();
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadNextPage() async {
    if (hasNext) {
      final nextPage = _getPageFromUrl(_paginatedIssues!.next!);
      await getIssues(page: nextPage);
    }
  }

  Future<void> loadPreviousPage() async {
    if (hasPrevious) {
      final prevPage = _getPageFromUrl(_paginatedIssues!.previous!);
      await getIssues(page: prevPage);
    }
  }

  int _getPageFromUrl(String url) {
    final uri = Uri.parse(url);
    return int.parse(uri.queryParameters['page'] ?? '1');
  }
}
