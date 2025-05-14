import 'package:flutter/cupertino.dart';
import 'package:online_reservation/Core/Data/Models/paginated.model.dart';
import 'package:online_reservation/Features/MedicalInventory/Data/Model/category.model.dart';
import 'package:online_reservation/Features/MedicalInventory/Data/Model/inventory.model.dart';
import 'package:online_reservation/Features/MedicalInventory/Data/Model/supplier.model.dart';
import 'package:online_reservation/Features/MedicalInventory/Data/Service/inventory.service.dart';

class InventoryProvider with ChangeNotifier {
  final InventoryApiService _apiService;
  InventoryProvider(this._apiService);

  PaginatedResults<Medicine>? _paginatedMedicines;
  List<Medicine> _medicines = [];
  bool _isLoading = false;
  String? _error;

  List<Medicine> get medicines => _medicines;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasNext => _paginatedMedicines?.next != null;
  bool get hasPrevious => _paginatedMedicines?.previous != null;

  Future<void> getMedicines({int page = 1, String query = ""}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _paginatedMedicines =
          await _apiService.getMedicines(page: page, query: query);
      _medicines = _paginatedMedicines?.results ?? [];
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> getMedicine(int id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final medicine = await _apiService.getMedicine(id);
      final index = _medicines.indexWhere((v) => v.id == medicine.id);
      _medicines[index] = _medicines[index].copyWith(
        id: medicine.id,
        category: medicine.category,
        description: medicine.description,
        lastRestockDate: medicine.lastRestockDate,
        name: medicine.name,
        quantity: medicine.quantity,
        quantityUnit: medicine.quantityUnit,
        supplier: medicine.supplier,
      );
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> updateMedicine(Medicine medicine) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final newInventory = await _apiService.updateMedicine(medicine: medicine);
      final index = _medicines.indexWhere((v) => v.id == medicine.id);
      _medicines[index] = _medicines[index].copyWith(
        id: newInventory.id,
        category: newInventory.category,
        description: newInventory.description,
        lastRestockDate: newInventory.lastRestockDate,
        name: newInventory.name,
        quantity: newInventory.quantity,
        quantityUnit: newInventory.quantityUnit,
        supplier: newInventory.supplier,
      );
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> createMedicine(Medicine medicine) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      await _apiService.createMedicine(medicine: medicine);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> deleteMedicine(int medicineId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      bool success = await _apiService.deleteMedicine(medicineId);
      if (success) {
        _medicines.removeWhere((medicine) => medicine.id == medicineId);
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
