import 'package:flutter/material.dart';
import 'package:online_reservation/Core/Data/Models/paginated.model.dart';
import 'package:online_reservation/Features/MedicalInventory/Data/Model/supplier.model.dart';
import 'package:online_reservation/Features/MedicalInventory/Data/Service/inventory.service.dart';

class SupplierProvider with ChangeNotifier {
  final InventoryApiService _apiService;
  SupplierProvider(this._apiService);

  PaginatedResults<Supplier>? _paginatedSuppliers;
  List<Supplier> _suppliers = [];
  bool _isLoading = false;
  String? _error;

  List<Supplier> get suppliers => _suppliers;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasNext => _paginatedSuppliers?.next != null;
  bool get hasPrevious => _paginatedSuppliers?.previous != null;

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

  Future<void> getSupplier(int id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final newSupplier = await _apiService.getSupplier(id);
      final index = _suppliers.indexWhere((v) => v.id == newSupplier.id);
      _suppliers[index] = _suppliers[index].copyWith(
        id: newSupplier.id,
        name: newSupplier.name,
        email: newSupplier.email,
        address: newSupplier.address,
        contactPerson: newSupplier.contactPerson,
        phoneNumber: newSupplier.phoneNumber,
      );
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> updateSupplier(Supplier supplier) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final newSupplier = await _apiService.updateSupplier(supplier: supplier);
      final index = _suppliers.indexWhere((v) => v.id == supplier.id);
      _suppliers[index] = _suppliers[index].copyWith(
        id: newSupplier.id,
        name: newSupplier.name,
        email: newSupplier.email,
        address: newSupplier.address,
        contactPerson: newSupplier.contactPerson,
        phoneNumber: newSupplier.phoneNumber,
      );
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> createSupplier(Supplier supplier) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      await _apiService.createSupplier(supplier: supplier);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> deleteSupplier(int supplierId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      bool success = await _apiService.deleteSupplier(supplierId);
      if (success) {
        _suppliers.removeWhere((supplier) => supplier.id == supplierId);
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
      final nextPage = _getPageFromUrl(_paginatedSuppliers!.next!);
      await getSuppliers(page: nextPage);
    }
  }

  Future<void> loadPreviousPage() async {
    if (hasPrevious) {
      final prevPage = _getPageFromUrl(_paginatedSuppliers!.previous!);
      await getSuppliers(page: prevPage);
    }
  }

  int _getPageFromUrl(String url) {
    final uri = Uri.parse(url);
    return int.parse(uri.queryParameters['page'] ?? '1');
  }

}
