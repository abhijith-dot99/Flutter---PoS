// // company.dart
// class Companyy {
//   final String companyName;
//   final String owner;
//   final String abbr;
//   final String country;
//   final String vatNumber;
//   final String phoneNo;
//   final String email;
//   final String website;

//   Companyy({
//     required this.companyName,
//     required this.owner,
//     required this.abbr,
//     required this.country,
//     required this.vatNumber,
//     required this.phoneNo,
//     required this.email,
//     required this.website,
//   });

//   // Method to convert a Company object into a map for database storage
  // Map<String, dynamic> toMap() {
  //   return {
  //     'company_name': companyName,
  //     'owner': owner,
  //     'abbr': abbr,
  //     'country': country,
  //     'vat_number': vatNumber,
  //     'phone_no': phoneNo,
  //     'email': email,
  //     'website': website,
  //   };
  // }

//   // Method to create a Company object from a map (e.g., when fetching from the database)
//   factory Companyy.fromMap(Map<String, dynamic> map) {
//     return Companyy(
//       companyName: map['company_name'] ?? '',
//       owner: map['owner'] ?? '',
//       abbr: map['abbr'] ?? '',
//       country: map['country'] ?? '',
//       vatNumber: map['vat_number'] ?? '',
//       phoneNo: map['phone_no'] ?? '',
//       email: map['email'] ?? '',
//       website: map['website'] ?? '',
//     );
//   }
// }


class Companyy {
  final String companyName;
  final String owner;
  final String abbr;
  final String country;
  final String vatNumber;
  final String phoneNo;
  final String email;
  final String website;
  final String apiKey;
  final String secretKey;
  final String url;
  final String companyId;
  final int online;
  final String crNo;
  final String addressType;
  final String addressTitle;
  final String addressLine1;
  final String addressLine2;
  final String buildingNo;
  final String plotNo;
  final String city;
  final String state;
  final String addressCountry;
  final String pincode;

  Companyy({
    required this.companyName,
    required this.owner,
    required this.abbr,
    required this.country,
    required this.vatNumber,
    required this.phoneNo,
    required this.email,
    required this.website,
    required this.apiKey,
    required this.secretKey,
    required this.url,
    required this.companyId,
    required this.online,
    required this.crNo,
    required this.addressType,
    required this.addressTitle,
    required this.addressLine1,
    required this.addressLine2,
    required this.buildingNo,
    required this.plotNo,
    required this.city,
    required this.state,
    required this.addressCountry,
    required this.pincode,
  });

  // Method to convert Company object to Map
  Map<String, dynamic> toMap() {
    return {
      'company_name': companyName,
      'owner': owner,
      'abbr': abbr,
      'country': country,
      'vat_number': vatNumber,
      'phone_no': phoneNo,
      'email': email,
      'website': website,
      'apikey': apiKey,
      'secretkey': secretKey,
      'url': url,
      'companyId': companyId,
      'online': 0, // Convert boolean to int for SQLite
      'cr_no': crNo,
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
  // Factory constructor to create a Company object from a Map
  factory Companyy.fromMap(Map<String, dynamic> map) {
    return Companyy(
      companyName: map['company_name'] ?? '',
      owner: map['owner'] ?? '',
      abbr: map['abbr'] ?? '',
      country: map['country'] ?? '',
      vatNumber: map['vat_number'] ?? '',
      phoneNo: map['phone_no'] ?? '',
      email: map['email'] ?? '',
      website: map['website'] ?? '',
      apiKey: map['apikey'] ?? '',
      secretKey: map['secretkey'] ?? '',
      url: map['url'] ?? '',
      companyId: map['companyId'] ?? '',
      online:  1, // assuming 'online' is stored as INTEGER (0 or 1)
      crNo: map['cr_no'] ?? '',
      addressType: map['address_type'] ?? '',
      addressTitle: map['address_title'] ?? '',
      addressLine1: map['address_line1'] ?? '',
      addressLine2: map['address_line2'] ?? '',
      buildingNo: map['building_no'] ?? '',
      plotNo: map['plot_no'] ?? '',
      city: map['city'] ?? '',
      state: map['state'] ?? '',
      addressCountry: map['address_country'] ?? '',
      pincode: map['pincode'] ?? '',
    );
  }

  // @override
  // String toString() {
  //   return 'Companyy(companyName: $companyName, owner: $owner, abbr: $abbr, country: $country, vatNumber: $vatNumber, phoneNo: $phoneNo, email: $email, website: $website, apiKey: $apiKey, secretKey: $secretKey, url: $url, companyId: $companyId, online: $online, crNo: $crNo, addressType: $addressType, addressTitle: $addressTitle, addressLine1: $addressLine1, addressLine2: $addressLine2, buildingNo: $buildingNo, plotNo: $plotNo, city: $city, state: $state, addressCountry: $addressCountry, pincode: $pincode)';
  // }
}
