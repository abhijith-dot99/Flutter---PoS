class FormData {
  final int? id;
  final String? companyName;
  final String? companyId;
  final String? contactNumber;
  // final String? owner;
  final String? emailId;
  final String? username;
  final String? password;
  final String? owner;
  String abbr; // New field
  String country; // New field
  String vatNumber; // New field
  final bool online;
  String website;
  final String? apikey;
  final String? secretkey;
  final String? url;

  FormData({
    this.id,
    this.companyName,
    this.companyId,
    this.contactNumber,
    // this.company,
    required this.owner,
    required this.abbr,
    required this.country,
    required this.vatNumber,
    this.emailId,
    required this.username,
    required this.password,
    required this.website,
    required this.online,
    required this.apikey,
    required this.secretkey,
    required this.url,
  });

  // Convert a FormData into a Map.
  // Map<String, dynamic> toMap() {
  //   return {
  //     'id': id,
  //     'companyName': companyName,
  //     'companyId': companyId,
  //     'contactNumber': contactNumber,
  //     'company': company,
  //     'emailId': emailId,
  //     'username': username,
  //     'password': password,
  //     'online': online ? 1 : 0,
  //   };
  // }

  @override
  String toString() {
    return 'FormData(company_name: $companyName, companyId: $companyId, contactNumber: $contactNumber, '
        'emailId: $emailId, online: $online, apikey: $apikey, '
        'secretkey: $secretkey, url: $url, username: $username, password: $password)';
  }
}
