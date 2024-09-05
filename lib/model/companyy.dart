// company.dart
class Companyy {
  final String companyName;
  final String owner;
  final String abbr;
  final String country;
  final String vatNumber;
  final String phoneNo;
  final String email;
  final String website;

  Companyy({
    required this.companyName,
    required this.owner,
    required this.abbr,
    required this.country,
    required this.vatNumber,
    required this.phoneNo,
    required this.email,
    required this.website,
  });

  // Method to convert a Company object into a map for database storage
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
    };
  }

  // Method to create a Company object from a map (e.g., when fetching from the database)
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
    );
  }
}
