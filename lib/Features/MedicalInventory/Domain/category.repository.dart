import 'package:flutter/material.dart';
import 'package:online_reservation/Core/Data/Models/paginated.model.dart';
import 'package:online_reservation/Features/MedicalInventory/Data/Model/category.model.dart';
import 'package:online_reservation/Features/MedicalInventory/Data/Service/inventory.service.dart';

class CategoryProvider with ChangeNotifier{
  final InventoryApiService _apiService;
  CategoryProvider(this._apiService);

  PaginatedResults<Category>? _paginatedCategories;
  List<Category> _categories = [];
  bool _isLoading = false;
  String? _error;

  List<Category> get categories => _categories;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasNext => _paginatedCategories?.next != null;
  bool get hasPrevious => _paginatedCategories?.previous != null;

  Future<void> getCategories(
      {int page = 1, String query = ""}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _paginatedCategories = await _apiService.getCategories(
          page: page, query: query);
      _categories = _paginatedCategories?.results ?? [];
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> getCategory(int id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final newCategory = await _apiService.getCategory(id);
      final index = _categories.indexWhere((v) => v.id == newCategory.id);
      _categories[index] = _categories[index].copyWith(
        name: newCategory.name,
        description: newCategory.description,
        id: newCategory.id,
      );
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> updateCategory(Category category) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final newCategory = await _apiService.updateCategory(category: category);
      final index = _categories.indexWhere((v) => v.id == category.id);
      _categories[index] = _categories[index].copyWith(
        name: newCategory.name,
        description: newCategory.description,
        id: newCategory.id,
      );
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> createCategory(Category category) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      await _apiService.createCategory(category: category);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> deleteCategory(int categoryId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      bool success = await _apiService.deleteCategory(categoryId);
      if (success) {
        _categories.removeWhere((category) => category.id == categoryId);
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
      final nextPage = _getPageFromUrl(_paginatedCategories!.next!);
      await getCategories(page: nextPage);
    }
  }

  Future<void> loadPreviousPage() async {
    if (hasPrevious) {
      final prevPage = _getPageFromUrl(_paginatedCategories!.previous!);
      await getCategories(page: prevPage);
    }
  }

  int _getPageFromUrl(String url) {
    final uri = Uri.parse(url);
    return int.parse(uri.queryParameters['page'] ?? '1');
  }

}