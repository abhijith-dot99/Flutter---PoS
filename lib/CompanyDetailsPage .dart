import 'package:flutter/material.dart';
import 'package:flutter_pos_app/database/database_helper.dart';
import 'package:flutter_pos_app/fetch_details.dart';
import 'package:flutter_pos_app/main.dart';
import 'package:flutter_pos_app/model/company.dart';

class CompanyDetailsPage extends StatefulWidget {
  final Company company;
  final TextEditingController usernameController;
  final TextEditingController passwordController;
  final TextEditingController companyNameController;

  const CompanyDetailsPage({
    Key? key,
    required this.company,
    required this.usernameController,
    required this.passwordController,
    required this.companyNameController,
  }) : super(key: key);

  @override
  _CompanyDetailsPageState createState() => _CompanyDetailsPageState();
}

class _CompanyDetailsPageState extends State<CompanyDetailsPage> {
  bool isOnline = true;

  @override
  void initState() {
    super.initState();
    _loadOnlineStatus();
  }

  Future<void> _loadOnlineStatus() async {
    final dbHelper = DatabaseHelper();

    // Assuming company name is unique for each company
    String companyName = widget.company.companyName;

    // Fetch online status from the database
    int onlineStatus = await dbHelper.getOnlineStatus(companyName);

    // Update isOnline based on the fetched onlineStatus
    setState(() {
      isOnline = onlineStatus == 1; // Assuming 1 means online
    });
    print("online in loadonline status$isOnline");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Company Details'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Demo Heading',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            _buildDetailRow('Company Name:', widget.company.companyName),
            const SizedBox(height: 10),
            _buildDetailRow('Phone Number:', widget.company.phoneNo),
            const SizedBox(height: 10),
            _buildDetailRow('Email:', widget.company.email),
            const SizedBox(height: 10),
            _buildDetailRow('Branch:', widget.company.companyBranch),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                if (isOnline) {
                  print("isonlineinif$isOnline");
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          FetchDetailsPage(company: widget.company),
                    ),
                  );
                } else {
                  print("isonlineinif$isOnline");
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const MainPage(),
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                foregroundColor: Colors.white,
              ),
              child: const Text(
                'Save',
                style: TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          flex: 2,
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.brown,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          flex: 3,
          child: TextField(
            decoration: InputDecoration(
              hintText: value,
              fillColor: Colors.white,
              filled: true,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: const BorderSide(
                  color: Colors.brown,
                  width: 2.0,
                ),
              ),
              hintStyle: const TextStyle(
                color: Colors.black,
              ),
            ),
            style: const TextStyle(
              color: Color.fromARGB(255, 15, 1, 1),
            ),
            readOnly: true,
          ),
        ),
      ],
    );
  }
}
