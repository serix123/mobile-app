import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:online_reservation/Core/Data/Models/paginated.model.dart';
import 'package:online_reservation/Features/Documents/Data/Model/document.model.dart';
import 'package:online_reservation/Features/Documents/Data/Service/document.service.dart';
import 'package:online_reservation/Utils/utils.dart';

class DocumentProvider with ChangeNotifier{
  final DocumentApiService _apiService;
  PaginatedResults<Document>? _paginatedDocuments;
  List<Document> _documents = [];
  bool _isLoading = false;
  String? _error;
  int page_count = 0;

  DocumentProvider(this._apiService);

  List<Document> get documents => _documents;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasNext => _paginatedDocuments?.next != null;
  bool get hasPrevious => _paginatedDocuments?.previous != null;

  Future<void> getDocuments({int page = 1, String query = ""}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final PaginatedResults<Document> paginatedDocuments = await _apiService.getDocuments(page: page, query: query);
      _paginatedDocuments = paginatedDocuments;
      _documents = paginatedDocuments.results;
      page_count = Utils.calculateTotalPages(paginatedDocuments.count, 10);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> updateDocument(Document document) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      await _apiService.updateDocument(document: document);
      final index = _documents.indexWhere((v) => v.id == document.id);
      _documents[index] = _documents[index].copyWith(
        id: document.id,
        title: document.title,
        category: document.category,
        documentUrl: document.documentUrl

      );
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<Document?> createDocument(Document document) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    final Document newDocument;
    try {
      newDocument = await _apiService.createDocument(document: document);
      _isLoading = false;
      notifyListeners();
      return newDocument;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
    _isLoading = false;
    notifyListeners();
    return null;
  }

  Future<void> deleteDocument(int documentId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      bool success = await _apiService.deleteDocument(documentId);
      if (success) {
        _documents.removeWhere((document) => document.id == documentId);
        notifyListeners();
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> uploadFile(int documentId, PlatformFile file, bool isWeb) async {
    _isLoading = true;
    // _error = null;
    notifyListeners();
    try {
      await _apiService.uploadFileAdaptive(documentId, file, isWeb);
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
      final nextPage = _getPageFromUrl(_paginatedDocuments!.next!);
      await getDocuments(page: nextPage);
    }
  }

  Future<void> loadPreviousPage() async {
    if (hasPrevious) {
      final prevPage = _getPageFromUrl(_paginatedDocuments!.previous!);
      await getDocuments(page: prevPage);
    }
  }

  int _getPageFromUrl(String url) {
    final uri = Uri.parse(url);
    return int.parse(uri.queryParameters['page'] ?? '1');
  }
}