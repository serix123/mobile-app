import 'package:flutter/material.dart';
import 'package:online_reservation/Core/Data/Models/paginated.model.dart';
import 'package:online_reservation/Features/Issue/Data/Model/issue.comment.model.dart';
import 'package:online_reservation/Features/Issue/Data/Service/issue.comment.service.dart';
import 'package:online_reservation/Utils/utils.dart';

class CommentProvider with ChangeNotifier{
  final IssueCommentApiService _apiService;

  PaginatedResults<Comment>? _paginatedComments;
  List<Comment> _comments = [];
  bool _isLoading = false;
  String? _error;
  int page_count = 0;

  CommentProvider(this._apiService);

  List<Comment> get comments => _comments;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasNext => _paginatedComments?.next != null;
  bool get hasPrevious => _paginatedComments?.previous != null;

  Future<void> getComments({int page = 1, required int issueId }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final PaginatedResults<Comment> paginatedIssues = await _apiService.getComments(page: page, issue: issueId);
      _paginatedComments = paginatedIssues;
      _comments = paginatedIssues.results;
      page_count = Utils.calculateTotalPages(paginatedIssues.count, 10);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<Comment?> createComment(Comment comment) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    final Comment newComment;
    try {
      newComment = await _apiService.createComment(comment: comment);
      _isLoading = false;
      notifyListeners();
      return newComment;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
    _isLoading = false;
    notifyListeners();
    return null;
  }

}