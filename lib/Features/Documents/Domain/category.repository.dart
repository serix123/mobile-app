
import 'package:flutter/material.dart';
import 'package:online_reservation/Core/Data/Models/paginated.model.dart';
import 'package:online_reservation/Features/Documents/Data/Model/category.model.dart';
import 'package:online_reservation/Features/Documents/Data/Service/category.service.dart';
import 'package:online_reservation/Utils/utils.dart';

class CategoryProvider with ChangeNotifier{
  final CategoryApiService _apiService;
  PaginatedResults<Category>? _paginatedCategories;
  List<Category> _categories = [];
  bool _isLoading = false;
  String? _error;
  int page_count = 0;

  CategoryProvider(this._apiService);

  List<Category> get categories => _categories;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasNext => _paginatedCategories?.next != null;
  bool get hasPrevious => _paginatedCategories?.previous != null;

  Future<void> getCategories({int page = 1, String query = ""}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final PaginatedResults<Category> paginatedCategories = await _apiService.getCategories(page: page, query: query);
      _paginatedCategories = paginatedCategories;
      _categories = paginatedCategories.results;
      page_count = Utils.calculateTotalPages(paginatedCategories.count, 10);
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
      await _apiService.updateCategory(category: category);
      final index = _categories.indexWhere((v) => v.id == category.id);
      _categories[index] = _categories[index].copyWith(
          id: category.id,
          name: category.name,
          parent: category.parent,
          subcategories: category.subcategories
      );
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<Category?> createCategory(Category category) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    final Category newCategory;
    try {
      newCategory = await _apiService.createCategory(category: category);
      _isLoading = false;
      notifyListeners();
      return newCategory;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
    _isLoading = false;
    notifyListeners();
    return null;
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