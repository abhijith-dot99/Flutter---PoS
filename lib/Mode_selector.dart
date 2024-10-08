import 'dart:convert';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_pos_app/CompanyDetailsPage%20.dart';
import 'package:flutter_pos_app/database/database_helper.dart';
import 'package:flutter_pos_app/login_page.dart';
import 'package:flutter_pos_app/main.dart';
import 'package:flutter_pos_app/model/company.dart';
import 'package:flutter_pos_app/model/form_data.dart';
import 'package:sqflite/sqflite.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

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
  final TextEditingController ownerController = TextEditingController();
  final TextEditingController emailIdController = TextEditingController();
  final TextEditingController abbrController = TextEditingController();
  final TextEditingController countryController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  final TextEditingController apiKeyController = TextEditingController();
  final TextEditingController secretKeyController = TextEditingController();
  final TextEditingController urlController = TextEditingController();

  List<Company> _companies = [];

  Company? _selectedCompany;
  String? selectedCompanyName;

  void _saveFormData() async {
    print("inside save");

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('apiKey', apiKeyController.text);
    await prefs.setString('secretKey', secretKeyController.text);
    await prefs.setString('url', urlController.text);

    selectedCompanyName = companyNameController.text;

    if (isOnline) {
      // In online mode, get the selected company name from the dropdown
      if (_selectedCompany == null) {
        print("No company name selected.");
        return;
      } else {
        selectedCompanyName = _selectedCompany!.companyName;
      }
    } else {
      // In offline mode, use the text entered in the TextFormField
      selectedCompanyName = companyNameController.text;

      if (selectedCompanyName == null || selectedCompanyName!.isEmpty) {
        print("No company name entered.");
        return;
      }
    }

    print("companynaeminsaveform$selectedCompanyName");

    // // Create FormData instance
    // FormData formData = FormData(
    //   // companyName: companyNameController.text,
    //   companyName: selectedCompanyName,
    //   companyId: companyIdController.text,
    //   contactNumber: contactNumberController.text,
    //   owner: ownerController.text,
    //   abbr: abbrController.text, // New field
    //   country: countryController.text, // New field
    //   vatNumber: usernameController.text, // New field
    //   emailId: emailIdController.text,
    //   username: usernameController.text,
    //   password: passwordController.text,
    //   website: usernameController.text,
    //   online: isOnline,
    //   apikey: apiKeyController.text,
    //   secretkey: secretKeyController.text,
    //   url: urlController.text,
    // );
    // // Insert into database
    // try {
    //   int result = await DatabaseHelper().insertOfflineData(formData);
      
    //   print("Insert result: $result");
    // } catch (e) {
    //   print("Error inserting data: $e");
    // }
  }

  void _fetchCompanyNames() async {
    final apiKey = apiKeyController.text;
    final secretKey = secretKeyController.text;
    final url = urlController.text;

    if (apiKey.isEmpty || secretKey.isEmpty || url.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter API Key, Secret Key, and URL'),
        ),
      );
      return;
    }

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
        if (data['message'] != null && data['message'] is List) {
          setState(() {
            _companies = (data['message'] as List).map((item) {
              return Company(
                  companyName: item['company_name'] ?? '',
                  phoneNo: item['phone_no'] ?? '',
                  companyId: item[''] ?? '1',
                  email: item['email'] ?? '',
                  empName: item['emp_name'] ?? '',
                  companyBranch: item['company_branch'] ?? '');
            }).toList();

            _selectedCompany = _companies.isNotEmpty ? _companies[0] : null;
          });

          print(
              "Companies fetched and stored successfully: ${_selectedCompany.toString()}");
          print("Companies fetched successfully${_selectedCompany.toString()}");
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
        child: SingleChildScrollView(
          child: Container(
            width: 700,
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: newMethod,
            ),
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
                  print("isOnlineontoggle  $isOnline");
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 400),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: isOnline
                        ? const Color.fromARGB(255, 87, 212, 124)
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
                  print("isOnlineontoggle $isOnline");
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 400),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: !isOnline
                        ? const Color.fromARGB(255, 221, 67, 170)
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
                  child: DropdownButtonFormField<Company>(
                    isExpanded: true,
                    value: _selectedCompany,
                    hint: const Text(
                      'Select Your Company',
                      style: TextStyle(color: Colors.grey),
                    ),
                    items: _companies.map((Company company) {
                      return DropdownMenuItem<Company>(
                        value: company,
                        child: Text(company.companyName),
                      );
                    }).toList(),
                    onChanged: (newValue) async {
                      setState(() {
                        _selectedCompany = newValue;
                      });
                      if (newValue != null) {
                        // print('Selected Company Details:');
                        // print('Names: ${newValue.companyName}');
                        // print('Phone Number: ${newValue.phoneNo}');
                        // print('Email: ${newValue.email}');
                        final prefs = await SharedPreferences.getInstance();
                        await prefs.setString(
                            'selectedCompanyName', newValue.companyName);
                        await prefs.setString(
                            'selectedCompanyId', newValue.companyId);
                        await prefs.setBool('isOnline', isOnline);
                        print(
                            'Stored selected company name: ${newValue.companyName}');
                      }
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
                      focusedBorder: OutlineInputBorder(
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
          ownerController: ownerController,
          emailIdController: emailIdController,
          abbrController: abbrController,
          countryController: countryController,
          usernameController: usernameController,
          passwordController: passwordController,
        ),
      const SizedBox(height: 30),
      SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () async {
            print("Button pressed, isOnline: $isOnline");
            // print("selectedcompanyonpressed$selectedCompanyName");
            if (isOnline) {
              print("selectdcompany$_selectedCompany");
              final selectedCompanyName = _selectedCompany!;
              _saveFormData();
              print("insdie if");
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => CompanyDetailsPage(
                    company: selectedCompanyName,
                    usernameController: usernameController,
                    passwordController: passwordController,
                    companyNameController: companyNameController,
                  ),
                ),
              );
            } else {
              print("insdie else");
              // final selectedCompany = selectedCompanyName;
              _saveFormData();

              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const LoginPage(),
               
                ),
              );
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xff4285f4),
            foregroundColor: Color.fromARGB(255, 255, 255, 255),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          ),
          child: const Text(
            // 'Next',
            'Log In',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
          ),
        ),
      ),
      const SizedBox(height: 20),
      SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () async {
            _saveFormData();
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => const LoginPage()),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color.fromARGB(255, 204, 19, 19),
            foregroundColor: Color.fromARGB(255, 255, 255, 255),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          ),
          child: const Text(
            'Sign Up',
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
          _buildTextField('URL', controller: urlController, obscureText: false),
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
  final TextEditingController ownerController;
  final TextEditingController emailIdController;
  final TextEditingController usernameController;
  final TextEditingController passwordController;
  final TextEditingController abbrController;
  final TextEditingController countryController;

  final _formKey = GlobalKey<FormState>(); // Add this line

  OfflineForm({
    // super.key,
    required this.companyNameController,
    required this.companyIdController,
    required this.contactNumberController,
    required this.ownerController,
    required this.emailIdController,
    required this.usernameController,
    required this.passwordController,
    required this.abbrController,
    required this.countryController,
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
          _buildTextField('Owner', controller: ownerController),
          const SizedBox(height: 10),
          _buildTextField('abbr', controller: abbrController),
          const SizedBox(height: 10),
          _buildTextField('country', controller: countryController),
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
