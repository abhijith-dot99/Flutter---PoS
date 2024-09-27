class Customer {
  final String customerName;
  final String customerType;
  final String companyName;
  final String? customerGroup;
  final String? vatNumber;
  final String phoneNo;
  final String email;
  final String crno;
  final String addressType;
  final String addressTitle;
  final String addressLine1;
  final String? addressLine2;
  final String? buildingNo;
  final String? plotNo;
  final String city;
  final String state;
  final String addressCountry;
  final String? pincode;

  Customer({
    required this.customerName,
    required this.customerType,
    required this.companyName,
    this.customerGroup,
    this.vatNumber,
    required this.crno,
    required this.phoneNo,
    required this.email,
    required this.addressType,
    required this.addressTitle,
    required this.addressLine1,
    this.addressLine2,
    this.buildingNo,
    this.plotNo,
    required this.city,
    required this.state,
    required this.addressCountry,
    this.pincode,
  });

  // Convert a Customer object into a Map object
  Map<String, dynamic> toMap() {
    return {
      'customer_name': customerName,
      'type': customerType,
      'company_name': companyName,
      'customer_group': customerGroup,
      'vat_number': vatNumber,
      'cr_no': crno,
      'phone_no': phoneNo,
      'email': email,
      'address_type': addressType,
      'address_title': addressTitle,
      'address_line1': addressLine1,
      'address_line2': addressLine2,
      'building_no': buildingNo,
      'plot_no': plotNo,
      'city': city,
      'state': state,
      'address_country': addressCountry,
      'pincode': pincode,
    };
  }
}
