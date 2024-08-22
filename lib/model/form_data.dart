class FormData {
  final int? id;
  final String? companyName;
  final String? companyId;
  final String? contactNumber;
  final String? company;
  final String? emailId;
  final String? username;
  final String? password;
  final bool online;

  FormData({
    this.id,
    this.companyName,
    this.companyId,
    this.contactNumber,
    this.company,
    this.emailId,
    required this.username,
    required this.password,
    required this.online,
  });

  // Convert a FormData into a Map.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'companyName': companyName,
      'companyId': companyId,
      'contactNumber': contactNumber,
      'company': company,
      'emailId': emailId,
      'username': username,
      'password': password,
      'online': online ? 1 : 0,
    };
  }
}
