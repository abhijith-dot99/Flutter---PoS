class User {
  final String empName;
  final String? phoneNo;
  final String email;
  final String companyName;
  final String? companyBranch;
  final String empStatus;
  final String username;
  final String password;

  User({
    required this.empName,
    this.phoneNo,
    required this.email,
    required this.companyName,
    this.companyBranch,
    required this.empStatus,
    required this.username,
    required this.password,
  });

  Map<String, dynamic> toMap() {
    return {
      'emp_name': empName,
      'phone_no': phoneNo,
      'email': email,
      'company_name': companyName,
      'company_branch': companyBranch,
      'emp_status': empStatus,
      'username': username,
      'password': password,
    };
  }
}
