
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:online_reservation/Core/Data/Models/paginated.model.dart';
import 'package:online_reservation/Features/Notice/Data/Model/notice.model.dart';
import 'package:online_reservation/Features/Notice/Data/Service/notice.service.dart';
import 'package:online_reservation/Utils/utils.dart';

class NoticeProvider with ChangeNotifier{
  final NoticeApiService _apiService;
  PaginatedResults<Notice>? _paginatedNotices;
  List<Notice> _notices = [];
  bool _isLoading = false;
  String? _error;
  int page_count = 0;

  NoticeProvider(this._apiService);

  List<Notice> get notices => _notices;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasNext => _paginatedNotices?.next != null;
  bool get hasPrevious => _paginatedNotices?.previous != null;

  Future<void> getNotices({int page = 1, String query = ""}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final PaginatedResults<Notice> paginatedNotices = await _apiService.getNotices(page: page, query: query);
      _paginatedNotices = paginatedNotices;
      _notices = paginatedNotices.results;
      page_count = Utils.calculateTotalPages(paginatedNotices.count, 10);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> updateNotice(Notice notice) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      await _apiService.updateNotice(notice: notice);
      final index = _notices.indexWhere((v) => v.id == notice.id);
      _notices[index] = _notices[index].copyWith(
        id: notice.id,
        title: notice.title,
        details: notice.details,
        imageUrl: notice.imageUrl,
        createdDate: notice.createdDate,
        updatedDate: notice.updatedDate,
      );
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<Notice?> createNotice(Notice notice) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    final Notice newNotice;
    try {
      newNotice = await _apiService.createNotice(notice: notice);
      _isLoading = false;
      notifyListeners();
      return newNotice;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
    _isLoading = false;
    notifyListeners();
    return null;
  }

  Future<void> deleteNotice(int noticeId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      bool success = await _apiService.deleteNotice(noticeId);
      if (success) {
        _notices.removeWhere((notice) => notice.id == noticeId);
        notifyListeners();
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> uploadFile(int noticeId, PlatformFile file, bool isWeb) async {
    _isLoading = true;
    // _error = null;
    notifyListeners();
    try {
      await _apiService.uploadFileAdaptive(noticeId, file, isWeb);
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
      final nextPage = _getPageFromUrl(_paginatedNotices!.next!);
      await getNotices(page: nextPage);
    }
  }

  Future<void> loadPreviousPage() async {
    if (hasPrevious) {
      final prevPage = _getPageFromUrl(_paginatedNotices!.previous!);
      await getNotices(page: prevPage);
    }
  }

  int _getPageFromUrl(String url) {
    final uri = Uri.parse(url);
    return int.parse(uri.queryParameters['page'] ?? '1');
  }
}