import 'package:flutter/material.dart';
import 'package:online_reservation/Core/Data/Models/paginated.model.dart';
import 'package:online_reservation/Features/CommunityResources/Data/Model/community_resources.model.dart';
import 'package:online_reservation/Features/CommunityResources/Data/Service/community_resource.service.dart';

class ResourceProvider with ChangeNotifier{
  final ResourceApiService _apiService;
  PaginatedResults<Resource>? _paginatedResources;
  List<Resource> _resources = [];
  bool _isLoading = false;
  String? _error;

  ResourceProvider(this._apiService);

  List<Resource> get resources => _resources;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasNext => _paginatedResources?.next != null;
  bool get hasPrevious => _paginatedResources?.previous != null;


  Future<void> getResources({int page = 1, String query = ""}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _paginatedResources = await _apiService.getResources(page: page, query: query);
      _resources = _paginatedResources?.results ?? [];
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> updateResource(Resource resource) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      await _apiService.updateResource(resource: resource);
      final index = _resources.indexWhere((v) => v.id == resource.id);
      _resources[index] = _resources[index].copyWith(resource);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> createResource(Resource resource) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      await _apiService.createResource(resource: resource);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> deleteResource(int id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      bool success = await _apiService.deleteResource(id);
      if (success) {
        _resources.removeWhere((resource) => resource.id == id);
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
      final nextPage = _getPageFromUrl(_paginatedResources!.next!);
      await getResources(page: nextPage);
    }
  }

  Future<void> loadPreviousPage() async {
    if (hasPrevious) {
      final prevPage = _getPageFromUrl(_paginatedResources!.previous!);
      await getResources(page: prevPage);
    }
  }

  int _getPageFromUrl(String url) {
    final uri = Uri.parse(url);
    return int.parse(uri.queryParameters['page'] ?? '1');
  }

}