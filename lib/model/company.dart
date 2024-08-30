// lib/company.dart
class Company {
  final String companyName;
  final String phoneNo;
  final String email;
  final String companyBranch;
  final String empName;
  final String companyId;

  Company({
    required this.companyName,
    required this.phoneNo,
    required this.email,
    required this.companyBranch,
    required this.empName,
    required this.companyId,
  });

  // Factory constructor to create a Company object from a Map
  factory Company.fromMap(Map<String, dynamic> map) {
    // print('Mapping values: companyName: ${map['companyName']}, name: ${map['empName']}, phoneNo: ${map['contactNumber']}, email: ${map['emailId']}, company_branch: ${map['company']}');
    return Company(
      companyName: map['companyName'] ?? '', // Use default empty string if null
      companyId: map['companyId'] ?? '',
      empName: map['name'],
      phoneNo: map['contactNumber'] ?? '',
      email: map['emailId'] ?? '',
      companyBranch: map['company'] ?? '',
    );
  }
  @override
  String toString() {
    return 'Company(companyName: $companyName,  phoneNo: $phoneNo, email: $email, company_branch: $companyBranch)';
  }
}
