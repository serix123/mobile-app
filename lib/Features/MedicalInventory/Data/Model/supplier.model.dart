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

  factory Supplier.fromJson(Map<String, dynamic> json) {
    return Supplier(
      id: json['id'],
      name: json['name'] ?? "N/A",
      contactPerson: json['contact_person']?? "N/A",
      email: json['email']?? "N/A"  ,
      phoneNumber: json['phone_number'] ?? "N/A",
      address: json['address'] ?? "N/A",
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

  @override
  String toString() {
    return 'Supplier(id: $id, name: $name, contactPerson: $contactPerson, email: $email, phoneNumber: $phoneNumber, address: $address)';
  }
}