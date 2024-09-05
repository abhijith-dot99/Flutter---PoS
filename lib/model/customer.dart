class Customer {
  final String customerName;
  final String customerType;
  final String companyName;
  final String? customerGroup;
  final String? vatNumber;
  final String phoneNo;
  final String email;

  Customer({
    required this.customerName,
    required this.customerType,
    required this.companyName,
    this.customerGroup,
    this.vatNumber,
    required this.phoneNo,
    required this.email,
  });

  // Convert a Customer object into a Map object
  Map<String, dynamic> toMap() {
    return {
      'customer_name': customerName,
      'companytype': customerType,
      'company_name': companyName,
      'customer_group': customerGroup,
      'vat_number': vatNumber,
      'phone_no': phoneNo,
      'email': email,
    };
  }
}
