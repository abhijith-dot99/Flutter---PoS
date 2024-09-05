import 'package:meta/meta.dart';

class Supplier {
  final String supplierName;
  final String type;
  final String companyName;
  final String? supplierGroup;
  final String? vatNumber;
  final String phoneNo;
  final String email;
  final String country;

  Supplier({
    required this.supplierName,
    required this.type,
    required this.companyName,
    this.supplierGroup,
    this.vatNumber,
    required this.phoneNo,
    required this.email,
    required this.country,
  });

  // Convert a Supplier into a Map.
  Map<String, dynamic> toMap() {
    return {
      'supplier_name': supplierName,
      'type': type,
      'company_name': companyName,
      'supplier_group': supplierGroup,
      'vat_number': vatNumber,
      'phone_no': phoneNo,
      'email': email,
      'country': country,
    };
  }

  // Extract a Supplier object from a Map.
  factory Supplier.fromMap(Map<String, dynamic> map) {
    return Supplier(
      supplierName: map['supplier_name'],
      type: map['type'],
      companyName: map['company_name'],
      supplierGroup: map['supplier_group'],
      vatNumber: map['vat_number'],
      phoneNo: map['phone_no'],
      email: map['email'],
      country: map['country'],
    );
  }
}
