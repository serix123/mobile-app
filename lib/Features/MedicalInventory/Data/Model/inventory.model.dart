import 'package:online_reservation/Features/MedicalInventory/Data/Model/category.model.dart';
import 'package:online_reservation/Features/MedicalInventory/Data/Model/supplier.model.dart';

enum MedicineUnit {
  units('UN', 'Units'),
  packs('PC', 'Packs'),
  bottles('BT', 'Bottles'),
  boxes('BX', 'Boxes'),
  vials('VL', 'Vials');

  final String code;
  final String displayName;

  const MedicineUnit(this.code, this.displayName);

  static MedicineUnit? fromCode(String code) {
    try {
      return MedicineUnit.values.firstWhere((unit) => unit.code == code);
    } catch (e) {
      return null;
    }
  }

  static MedicineUnit? fromDisplayName(String displayName) {
    try {
      return MedicineUnit.values.firstWhere(
              (unit) => unit.displayName == displayName);
    } catch (e) {
      return null;
    }
  }

  static List<String> get displayNames {
    return MedicineUnit.values.map((unit) => unit.displayName).toList();
  }

  static List<String> get codes {
    return MedicineUnit.values.map((unit) => unit.code).toList();
  }
}


class Medicine {
  final int id;
  final String name;
  final String description;
  final int quantity;
  final MedicineUnit quantityUnit;
  final Category category;
  final Supplier supplier;
  final DateTime? lastRestockDate;

  Medicine({
    required this.id,
    required this.name,
    required this.description,
    required this.quantity,
    required this.quantityUnit,
    required this.category,
    required this.supplier,
    this.lastRestockDate,
  });

  Medicine copyWith({
    int? id,
    String? name,
    String? description,
    int? quantity,
    MedicineUnit? quantityUnit,
    Category? category,
    Supplier? supplier,
    DateTime? lastRestockDate,
  }) {
    return Medicine(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      quantity: quantity ?? this.quantity,
      quantityUnit: quantityUnit ?? this.quantityUnit,
      category: category ?? this.category,
      supplier: supplier ?? this.supplier,
      lastRestockDate: lastRestockDate ?? this.lastRestockDate,
    );
  }

  factory Medicine.fromJson(Map<String, dynamic> json) {
    return Medicine(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      quantity: json['quantity'],
      quantityUnit: MedicineUnit.fromCode(json['quantity_unit']) ?? MedicineUnit.units,
      category: Category.fromJson(json['category']),
      supplier: Supplier.fromJson(json['supplier']),
      lastRestockDate: json['last_restock_date'] != null
          ? DateTime.parse(json['last_restock_date'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'quantity': quantity,
      'quantity_unit': quantityUnit.code,
      'category_id': category.id,
      'supplier_id': supplier.id,
      // 'category': category.toJson(),
      // 'supplier': supplier.toJson(),
      'last_restock_date': lastRestockDate?.toIso8601String(),
    };
  }
}

// Usage example:
// Medicine medicine = Medicine.fromJson(json.decode(jsonString));
// String json = jsonEncode(medicine.toJson());