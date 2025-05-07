import 'package:flutter/cupertino.dart';
import 'package:online_reservation/Core/Data/Models/paginated.model.dart';
import 'package:online_reservation/Features/MedicalInventory/Data/Model/inventory.model.dart';
import 'package:online_reservation/Features/MedicalInventory/Data/Service/inventory.service.dart';

class InventoryProvider with ChangeNotifier{
  final InventoryApiService _apiService;
  InventoryProvider(this._apiService);

  PaginatedResults<Supplier>? _paginatedSuppliers;
  List<Supplier> _suppliers = [];
  PaginatedResults<Category>? _paginatedCategories;
  List<Category> _categories = [];
  PaginatedResults<Medicine>? _paginatedMedicines;
  List<Medicine> _medicines = [];
  bool _isLoading = false;
  String? _error;

  List<Supplier> get suppliers => _suppliers;
  List<Category> get categories => _categories;
  List<Medicine> get records => _medicines;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasNext => _paginatedMedicines?.next != null;
  bool get hasPrevious => _paginatedMedicines?.previous != null;

  Future<void> getMedicines(
      {int page = 1, String query = ""}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _paginatedMedicines = await _apiService.getMedicines(
          page: page, query: query);
      _medicines = _paginatedMedicines?.results ?? [];
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
    _isLoading = false;
    notifyListeners();
  }

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

  Future<void> getSuppliers(
      {int page = 1, String query = ""}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _paginatedSuppliers = await _apiService.getSuppliers(
          page: page, query: query);
      _suppliers = _paginatedSuppliers?.results ?? [];
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadNextPage() async {
    if (hasNext) {
      final nextPage = _getPageFromUrl(_paginatedMedicines!.next!);
      await getMedicines(page: nextPage);
    }
  }

  Future<void> loadPreviousPage() async {
    if (hasPrevious) {
      final prevPage = _getPageFromUrl(_paginatedMedicines!.previous!);
      await getMedicines(page: prevPage);
    }
  }

  int _getPageFromUrl(String url) {
    final uri = Uri.parse(url);
    return int.parse(uri.queryParameters['page'] ?? '1');
  }

}