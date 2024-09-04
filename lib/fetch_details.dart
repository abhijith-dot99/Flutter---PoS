// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:flutter_pos_app/home.dart';
// import 'package:flutter_pos_app/main.dart';
// import 'package:http/http.dart' as http;
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:flutter_pos_app/database/database_helper.dart';
// import 'package:flutter_pos_app/model/company.dart';
// import 'package:flutter_pos_app/model/form_data.dart';

// class FetchDetailsPage extends StatefulWidget {
//   final Company company;

//   const FetchDetailsPage({Key? key, required this.company}) : super(key: key);

//   @override
//   _FetchDetailsPageState createState() => _FetchDetailsPageState();
// }

// class _FetchDetailsPageState extends State<FetchDetailsPage> {
//   late String apiKey;
//   late String secretKey;
//   late String url;
//   late String selectedCompanyName;
//   late String selectedCompanyId;

//   Map<String, dynamic>? fetchedData;

//   @override
//   void initState() {
//     super.initState();
//     _loadPreferences();
//   }

//   Future<void> _loadPreferences() async {
//     final prefs = await SharedPreferences.getInstance();
//     setState(() {
//       apiKey = prefs.getString('apiKey') ?? '';
//       secretKey = prefs.getString('secretKey') ?? '';
//       url = prefs.getString('url') ?? '';
//       selectedCompanyName = prefs.getString('selectedCompanyName') ?? '';
//       selectedCompanyId = prefs.getString('selectedCompanyId') ?? '';
//     });
//     print('apiKey: $apiKey');
//     print('secretKey: $secretKey');
//     print('url$url');
//     print('scompanyname$selectedCompanyName');
//     print('selectdcompnayid$selectedCompanyId');
//     _fetchCompanyDetails(); // Fetch company details after loading preferences
//   }

//   Future<void> _fetchCompanyDetails() async {
//     print("Selectedcompan$selectedCompanyName");
//     final detailsUrl = '$url/company_details?company_name=$selectedCompanyName';
//     String basicAuth =
//         'Basic ' + base64Encode(utf8.encode('$apiKey:$secretKey'));
//     print('Full URL: $detailsUrl');

//     try {
//       final response = await http.get(
//         Uri.parse(detailsUrl),
//         headers: <String, String>{
//           'Authorization': basicAuth,
//           'Content-Type': 'application/json',
//         },
//       );

//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         // Check if the response contains a "message" key
//         if (data.containsKey('message') && data['message'] is List) {
//           fetchedData = {'entries': data['message']};
//           print("insdide iffff");
//         } else {
//           print('Unexpected data format: $data');
//           fetchedData = null;
//         }
//       } else {
//         print('Failed to fetch company details. Response: ${response.body}');
//       }
//     } catch (e, stacktrace) {
//       print('Error fetching company details: $e');
//       print('Stacktrace: $stacktrace');
//     }
//   }

//   Future<void> _saveData() async {
//     print("fetcheddd $fetchedData");
//     if (fetchedData == null || !fetchedData!.containsKey('entries')) {
//       print("No data fetched to save.");
//       return;
//     }

//     final dbHelper = DatabaseHelper();
//     final entries = fetchedData!['entries'] as List;

//     // Filter entries to include only those with the selected company name
//     final filteredEntries = entries
//         .where((entry) => entry['company_name'] == selectedCompanyName)
//         .toList();

//     if (filteredEntries.isEmpty) {
//       print(
//           "No matching entries found for the selected company: $selectedCompanyName");
//       return;
//     }

//     print(
//         "Total entries to save for $selectedCompanyName: ${filteredEntries.length}");

//     for (var i = 0; i < filteredEntries.length; i++) {
//       try {
//         var entry = filteredEntries[i];
//         FormData formData = FormData(
//           companyName: entry['company_name'] ?? widget.company.companyName,
//           companyId: entry['company_id'] ?? selectedCompanyId,
//           contactNumber: entry['phone_no'] ?? '',
//           company: entry['company_branch'] ?? '',
//           emailId: entry['email'] ?? '',
//           online: true,
//           apikey: apiKey,
//           secretkey: secretKey,
//           url: url,
//           username: entry['emp_name'] ?? '',
//           password: entry['phone_no'], // Replace with actual password
//         );

//         print(
//             "Attempting to save entry ${i + 1} of ${filteredEntries.length}: $formData");
//         int result = await dbHelper.insertOfflineData(formData);
//         print("Database insert result for entry ${i + 1}: $result");

//         if (result == 1) {
//           print("result is 1");
//         } else {
//           print("Failed to save entry ${i + 1}.");
//         }
//       } catch (e, stacktrace) {
//         print('Error saving entry ${i + 1}: $e');
//         print('Stacktrace: $stacktrace');
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Details Page'),
//       ),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             ElevatedButton(
//               onPressed: _saveData,
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: Colors.green,
//                 padding:
//                     const EdgeInsets.symmetric(horizontal: 50, vertical: 20),
//                 textStyle:
//                     const TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
//                 foregroundColor: Colors.white,
//               ),
//               child: const Text('Save Data'),
//             ),
//             const SizedBox(height: 10),
//             ElevatedButton(
//               onPressed: () => {},
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: Colors.yellow,
//                 padding:
//                     const EdgeInsets.symmetric(horizontal: 50, vertical: 20),
//                 textStyle:
//                     const TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
//                 foregroundColor: Colors.white,
//               ),
//               child: const Text('D'),
//             ),
//             const SizedBox(height: 10),
//             ElevatedButton(
//               onPressed: () => {},
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: Colors.blue,
//                 padding:
//                     const EdgeInsets.symmetric(horizontal: 50, vertical: 20),
//                 textStyle:
//                     const TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
//                 foregroundColor: Colors.white,
//               ),
//               child: const Text('Update '),
//             ),
//             const SizedBox(height: 10),
//             ElevatedButton(
//               onPressed: () => {},
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: Colors.orange,
//                 padding:
//                     const EdgeInsets.symmetric(horizontal: 50, vertical: 20),
//                 textStyle:
//                     const TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
//                 foregroundColor: Colors.white,
//               ),
//               child: const Text('Load '),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_pos_app/database/database_helper.dart';
import 'package:flutter_pos_app/model/company.dart';
import 'package:flutter_pos_app/model/form_data.dart';

class FetchDetailsPage extends StatefulWidget {
  final Company company;

  const FetchDetailsPage({Key? key, required this.company}) : super(key: key);

  @override
  _FetchDetailsPageState createState() => _FetchDetailsPageState();
}

class _FetchDetailsPageState extends State<FetchDetailsPage> {
  late String apiKey;
  late String secretKey;
  late String url;
  late String selectedCompanyName;
  late String selectedCompanyId;

  Map<String, dynamic>? fetchedData;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      apiKey = prefs.getString('apiKey') ?? '';
      secretKey = prefs.getString('secretKey') ?? '';
      url = prefs.getString('url') ?? '';
      selectedCompanyName = prefs.getString('selectedCompanyName') ?? '';
      selectedCompanyId = prefs.getString('selectedCompanyId') ?? '';
    });
    _fetchCompanyDetails(); // Fetch company details after loading preferences
  }

  Future<void> _fetchCompanyDetails() async {
    final detailsUrl = '$url/company_details?company_name=$selectedCompanyName';
    String basicAuth =
        'Basic ' + base64Encode(utf8.encode('$apiKey:$secretKey'));

    try {
      final response = await http.get(
        Uri.parse(detailsUrl),
        headers: <String, String>{
          'Authorization': basicAuth,
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data.containsKey('message') && data['message'] is List) {
          fetchedData = {'entries': data['message']};
        } else {
          fetchedData = null;
        }
      } else {
        print('Failed to fetch company details. Response: ${response.body}');
      }
    } catch (e, stacktrace) {
      print('Error fetching company details: $e');
      print('Stacktrace: $stacktrace');
    }
  }

  Future<void> saveCompany() async {
    print("inside saveCompany");
    await _saveData('company_name', 'company_branch');
  }

  Future<void> saveUser() async {
    print("inside user");
    await _saveData('emp_name', 'user');
  }

  Future<void> saveItems() async {
    print("inside item");
    await _saveData('item_name', 'items');
  }

  Future<void> _saveData(String keyField, String category) async {
    if (fetchedData == null || !fetchedData!.containsKey('entries')) {
      print("No data fetched to save.");
      return;
    }

    final dbHelper = DatabaseHelper();
    final entries = fetchedData!['entries'] as List;

    final filteredEntries = entries
        .where((entry) => entry[keyField] == selectedCompanyName)
        .toList();

    if (filteredEntries.isEmpty) {
      print("No matching entries found for the selected $category.");
      return;
    }

    for (var i = 0; i < filteredEntries.length; i++) {
      try {
        var entry = filteredEntries[i];
        FormData formData = FormData(
          companyName: entry['company_name'] ?? widget.company.companyName,
          companyId: entry['company_id'] ?? selectedCompanyId,
          contactNumber: entry['phone_no'] ?? '',
          company: entry[keyField] ?? '',
          emailId: entry['email'] ?? '',
          online: true,
          apikey: apiKey,
          secretkey: secretKey,
          url: url,
          username: entry['emp_name'] ?? '',
          password: entry['phone_no'], // Replace with actual password
        );

        int result = await dbHelper.insertOfflineData(formData);
        if (result != 1) {
          print("Failed to save entry ${i + 1}.");
        }
      } catch (e, stacktrace) {
        print('Error saving entry ${i + 1}: $e');
        print('Stacktrace: $stacktrace');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Details Page'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: saveCompany,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding:
                    const EdgeInsets.symmetric(horizontal: 50, vertical: 20),
                textStyle:
                    const TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                foregroundColor: Colors.white,
              ),
              child: const Text('Sync Company'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: saveUser,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.yellow,
                padding:
                    const EdgeInsets.symmetric(horizontal: 50, vertical: 20),
                textStyle:
                    const TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                foregroundColor: Colors.white,
              ),
              child: const Text('Sync User'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: saveItems,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                padding:
                    const EdgeInsets.symmetric(horizontal: 50, vertical: 20),
                textStyle:
                    const TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                foregroundColor: Colors.white,
              ),
              child: const Text('Sync Items'),
            ),
          ],
        ),
      ),
    );
  }
}
