import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_pos_app/database/database_helper.dart';
import 'package:flutter_pos_app/login_page.dart';
import 'package:flutter_pos_app/model/form_data.dart';
import 'package:sqflite/sqflite.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: SoftwareModePage(),
    );
  }
}

class SoftwareModePage extends StatefulWidget {
  const SoftwareModePage({super.key});

  @override
  _SoftwareModePageState createState() => _SoftwareModePageState();
}

class _SoftwareModePageState extends State<SoftwareModePage> {
  bool isOnline = true; // Default state is Online

  // Define the TextEditingControllers here to access them in _saveFormData
  final TextEditingController companyNameController = TextEditingController();
  final TextEditingController companyIdController = TextEditingController();
  final TextEditingController contactNumberController = TextEditingController();
  final TextEditingController companyController = TextEditingController();
  final TextEditingController emailIdController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  final TextEditingController apiKeyController = TextEditingController();
  final TextEditingController secretKeyController = TextEditingController();
  final TextEditingController urlController = TextEditingController();

  List<String> _companyNames = [];
  String? _selectedCompany;

  void _saveFormData() async {
    print("inside save");
    // Create FormData instance
    FormData formData = FormData(
      companyName: companyNameController.text,
      companyId: companyIdController.text,
      contactNumber: contactNumberController.text,
      company: companyController.text,
      emailId: emailIdController.text,
      username: usernameController.text,
      password: passwordController.text,
      online: false, // Set to false for offline login
      apikey: apiKeyController.text,
      secretkey: secretKeyController.text,
      url: urlController.text,
    );

    print("FormData created: ${formData.toMap()}");

    // Insert into database
    try {
      int result = await DatabaseHelper().insertOfflineData(formData);
      print("Insert result: $result");
    } catch (e) {
      print("Error inserting data: $e");
    }
  }

  void _fetchCompanyNames() async {
    final apiKey = apiKeyController.text;
    final secretKey = secretKeyController.text;
    final url = urlController.text;

    // Encode API key and secret key for Basic Auth
    String basicAuth =
        'Basic ' + base64Encode(utf8.encode('$apiKey:$secretKey'));

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: <String, String>{
          'Authorization': basicAuth, // Set Basic Auth header
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // Check if the 'data' key exists and is a list
        if (data['data'] != null && data['data'] is List) {
          setState(() {
            // Map through the list and extract company names
            _companyNames = List<String>.from((data['data'] as List)
                .map((item) => item['company_name'] ?? ''));
            _selectedCompany =
                _companyNames.isNotEmpty ? _companyNames[0] : null;
          });
          print("Names: $_companyNames");
        } else {
          print('Key "data" is missing or not a list in the response');
          print(response.statusCode);
        }
      } else {
        print('Failed to load company names');
        print('Response body: ${response.body}');
      }
    } catch (e) {
      print('Error fetching company names: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: const Color(0xff1f2029),
      backgroundColor: Colors.white,
      body: Center(
        child: Container(
          width: 700,
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: newMethod,
          ),
        ),
      ),
    );
  }

  List<Widget> get newMethod {
    return <Widget>[
      const Text(
        'Software Mode',
        style: TextStyle(
          fontSize: 28,
          color: Colors.black,
          fontWeight: FontWeight.bold,
        ),
      ),
      const SizedBox(height: 30),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
        decoration: BoxDecoration(
          color: const Color.fromARGB(209, 211, 212, 154),
          borderRadius: BorderRadius.circular(30),
        ),
        child: Row(
          children: <Widget>[
            Expanded(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    isOnline = true;
                  });
                  print("isonline $isOnline");
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 400),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: isOnline
                        ? Color.fromARGB(255, 87, 212, 124)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Center(
                    child: Text(
                      'Online',
                      style: TextStyle(
                        color: isOnline ? Colors.white : Colors.black,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    isOnline = false;
                  });
                  print("isonline $isOnline");
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 400),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: !isOnline
                        ? Color.fromARGB(255, 221, 67, 170)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Center(
                    child: Text(
                      'Offline',
                      style: TextStyle(
                        color: !isOnline ? Colors.white : Colors.black,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      const SizedBox(height: 30),
      if (isOnline)
        Column(
          children: <Widget>[
            OnlineForm(
              apiKeyController: apiKeyController,
              secretKeyController: secretKeyController,
              urlController: urlController,
            ),
            const SizedBox(height: 30),
            Row(
              children: <Widget>[
                Expanded(
                  flex: 9,
                  child: DropdownButtonFormField<String>(
                    isExpanded: true,
                    value: _selectedCompany,
                    hint: const Text(
                      'Select Your Company',
                      style: TextStyle(color: Colors.grey),
                    ),
                    items: _companyNames.map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (newValue) {
                      setState(() {
                        _selectedCompany = newValue!;
                      });
                    },
                    decoration: InputDecoration(
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 12.0),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30.0),
                        borderSide: const BorderSide(
                          color: Colors.brown,
                          width: 2.0,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30.0),
                        borderSide: const BorderSide(
                          color: Colors.brown,
                          width: 2.0,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  flex: 1,
                  child: IconButton(
                    icon: const Icon(
                      Icons.sync,
                      color: Colors.blue,
                      size: 30,
                    ),
                    onPressed: _fetchCompanyNames,
                  ),
                ),
              ],
            ),
          ],
        )
      else
        OfflineForm(
            companyNameController: companyNameController,
            companyIdController: companyIdController,
            contactNumberController: contactNumberController,
            companyController: companyController,
            emailIdController: emailIdController,
            usernameController: usernameController,
            passwordController: passwordController),
      const SizedBox(height: 30),
      SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () async {
            _saveFormData();
            // Navigator.of(context).pushReplacement(
            //   MaterialPageRoute(builder: (context) => const LoginPage()),
            // );
          },
          style: ElevatedButton.styleFrom(
            // backgroundColor: Colors.deepOrange[400],
            backgroundColor: const Color(0xff4285f4),
            foregroundColor: const Color.fromARGB(255, 17, 17, 17),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          ),
          child: const Text(
            'Next',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
          ),
        ),
      ),
    ];
  }
}

class OnlineForm extends StatelessWidget {
  final TextEditingController apiKeyController;
  final TextEditingController secretKeyController;
  final TextEditingController urlController;
  final _formKey = GlobalKey<FormState>();

  OnlineForm({
    required this.apiKeyController,
    required this.secretKeyController,
    required this.urlController,
  });

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey, // Add this line
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          _buildTextField('Url', controller: urlController, obscureText: false),
          const SizedBox(height: 10),
          _buildTextField('API Key',
              controller: apiKeyController, obscureText: false),
          const SizedBox(height: 10),
          _buildTextField('Secret Key',
              controller: secretKeyController, obscureText: true),
        ],
      ),
    );
  }

  Widget _buildTextField(String label,
      {required TextEditingController controller, bool obscureText = false}) {
    return TextField(
      controller: controller, // <-- Add this line
      obscureText: obscureText,
      decoration: InputDecoration(
        hintText: label,
        fillColor: Colors.white,
        filled: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: const BorderSide(
            color: Colors.brown, // Set the border color here
            width: 2.0, // Set the border width here
          ),
        ),
        hintStyle: const TextStyle(
          color: Colors.grey,
        ),
      ),
      style: const TextStyle(
        color: Color.fromARGB(255, 15, 1, 1),
      ),
    );
  }
}

class OfflineForm extends StatelessWidget {
  final TextEditingController companyNameController;
  final TextEditingController companyIdController;
  final TextEditingController contactNumberController;
  final TextEditingController companyController;
  final TextEditingController emailIdController;
  final TextEditingController usernameController;
  final TextEditingController passwordController;

  final _formKey = GlobalKey<FormState>(); // Add this line

  OfflineForm({
    // super.key,
    required this.companyNameController,
    required this.companyIdController,
    required this.contactNumberController,
    required this.companyController,
    required this.emailIdController,
    required this.usernameController,
    required this.passwordController,
  });

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey, // Add this line
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          _buildTextField('Company Name', controller: companyNameController),
          const SizedBox(height: 10),
          _buildTextField('Company ID',
              controller: companyIdController, isNumeric: true),
          const SizedBox(height: 10),
          _buildTextField('Contact Number',
              controller: contactNumberController, isNumeric: true),
          const SizedBox(height: 10),
          _buildTextField('Company', controller: companyController),
          const SizedBox(height: 10),
          _buildTextField('Email ID',
              controller: emailIdController, isEmail: true),
          const SizedBox(height: 10),
          _buildTextField('User Name', controller: usernameController),
          const SizedBox(height: 10),
          _buildTextField('Password',
              controller: passwordController, isPassword: true),
        ],
      ),
    );
  }

  Widget _buildTextField(String label,
      {required TextEditingController controller,
      bool isEmail = false,
      bool isPassword = false,
      bool isNumeric = false}) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword,
      keyboardType: isNumeric ? TextInputType.number : TextInputType.text,
      inputFormatters: isNumeric
          ? <TextInputFormatter>[FilteringTextInputFormatter.digitsOnly]
          : null,
      decoration: InputDecoration(
        hintText: label,
        fillColor: const Color.fromARGB(255, 247, 243, 243),
        filled: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: const BorderSide(
            color: Colors.brown, // Set the border color here
            width: 2.0, // Set the border width here
          ),
        ),
        hintStyle: const TextStyle(
          color: Colors.grey,
        ),
      ),
      style: const TextStyle(
        color: Colors.black,
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter $label';
        }
        if (isEmail && !RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
          return 'Please enter a valid email address';
        }
        return null;
      },
    );
  }
}
