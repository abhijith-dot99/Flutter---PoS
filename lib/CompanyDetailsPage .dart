import 'package:flutter/material.dart';
import 'package:flutter_pos_app/Mode_selector.dart';
import 'package:flutter_pos_app/database/database_helper.dart';
import 'package:flutter_pos_app/model/company.dart';
import 'package:flutter_pos_app/model/form_data.dart';

class CompanyDetailsPage extends StatelessWidget {
  final Company company;
  final TextEditingController usernameController;
  final TextEditingController passwordController;
  final TextEditingController companyNameController;
  // final Function saveFormData;

  const CompanyDetailsPage({
    Key? key,
    required this.company,
    required this.usernameController,
    required this.passwordController,
    required this.companyNameController,
    // required this.saveFormData,
  }) : super(key: key);

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
            const SizedBox(height: 10),
            _buildDetailRow('Employee Name:', company.emp_name),
            const SizedBox(height: 20),
            _buildDetailRow('Company Name:', company.companyName),
            const SizedBox(height: 10),
            _buildDetailRow('Phone Number:', company.phoneNo),
            const SizedBox(height: 10),
            _buildDetailRow('Email:', company.email),
            const SizedBox(height: 10),
            _buildDetailRow('Branch:', company.company_branch),
            const SizedBox(height: 10),
            _buildTextField('Username', controller: usernameController),
            const SizedBox(height: 10),
            _buildTextField('Password',
                controller: passwordController, obscureText: true),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () async {
                await saveFormData(
                  company: company,
                  username: usernameController.text,
                  password: passwordController.text,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    Colors.green, // Set the background color to green
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  // Add rounded corners
                ),
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
              color: Colors.brown, // Label color
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(width: 10), // Space between label and TextField
        Expanded(
          flex: 3,
          child: TextField(
            decoration: InputDecoration(
              hintText: value, // The value inside the TextField
              fillColor: Colors.white,
              filled: true,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: const BorderSide(
                  color: Colors.brown, // Border color
                  width: 2.0, // Border width
                ),
              ),
              hintStyle: const TextStyle(
                color: Colors
                    .black, // Color for the hint text (value inside the box)
              ),
            ),
            style: const TextStyle(
              color: Color.fromARGB(
                  255, 15, 1, 1), // Text color inside the TextField
            ),
            readOnly: true, // Makes the TextField read-only
          ),
        ),
      ],
    );
  }

  Widget _buildTextField(String label,
      {required TextEditingController controller, bool obscureText = false}) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(
          fontSize: 16,
          color: Colors.black,
          fontWeight: FontWeight.bold,
        ),
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
          color: Colors.grey,
        ),
      ),
      style: const TextStyle(
        color: Colors.black,
      ),
    );
  }

  Future<void> saveFormData({
    required Company company,
    required String username,
    required String password,
  }) async {
    final dbHelper = DatabaseHelper();

    FormData formData = FormData(
      companyName: company.companyName,
      // companyId: company.companyId,
      contactNumber: company.phoneNo,
      company: company.company_branch,
      emailId: company.email,
      online: true,
      apikey: '', // You can pass appropriate values here
      secretkey: '', // You can pass appropriate values here
      url: '', // You can pass appropriate values here
      username: username,
      password: password,
    );

    int result = await dbHelper.insertOfflineData(formData);

    if (result == 1) {
      print("Company details saved successfully.");
    } else {
      print("Failed to save company details.");
    }
  }
}
