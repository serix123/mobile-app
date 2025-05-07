import 'dart:convert';

class Medicine {
  final int id;
  final String name;
  final String description;
  final int quantity;
  final String quantityUnit;
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
    String? quantityUnit,
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
      quantityUnit: json['quantity_unit'],
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
      'quantity_unit': quantityUnit,
      'category': category.toJson(),
      'supplier': supplier.toJson(),
      'last_restock_date': lastRestockDate?.toIso8601String(),
    };
  }
}

class Category {
  final int id;
  final String name;
  final String description;

  Category({
    required this.id,
    required this.name,
    required this.description,
  });

  Category copyWith({
    int? id,
    String? name,
    String? description,
  }) {
    return Category(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
    );
  }

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'],
      name: json['name'],
      description: json['description'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
    };
  }
}

class Supplier {
  final int id;
  final String name;
  final String contactPerson;
  final String email;
  final String phoneNumber;
  final String address;

  Supplier({
    required this.id,
    required this.name,
    required this.contactPerson,
    required this.email,
    required this.phoneNumber,
    required this.address,
  });

  Supplier copyWith({
    int? id,
    String? name,
    String? contactPerson,
    String? email,
    String? phoneNumber,
    String? address,
  }) {
    return Supplier(
      id: id ?? this.id,
      name: name ?? this.name,
      contactPerson: contactPerson ?? this.contactPerson,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      address: address ?? this.address,
    );
  }

  factory Supplier.fromJson(Map<String, dynamic> json) {
    return Supplier(
      id: json['id'],
      name: json['name'],
      contactPerson: json['contact_person'],
      email: json['email'],
      phoneNumber: json['phone_number'],
      address: json['address'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'contact_person': contactPerson,
      'email': email,
      'phone_number': phoneNumber,
      'address': address,
    };
  }
}

// Usage example:
// Medicine medicine = Medicine.fromJson(json.decode(jsonString));
// String json = jsonEncode(medicine.toJson());