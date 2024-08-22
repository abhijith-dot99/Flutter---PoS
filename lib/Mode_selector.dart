// ignore: file_names
import 'package:flutter/material.dart';
import 'package:flutter_pos_app/database/database_helper.dart';
import 'package:flutter_pos_app/login_page.dart';
import 'package:flutter_pos_app/model/form_data.dart';
import 'package:sqflite/sqflite.dart';

void main() {
  // Initialize the sqflite FFI for desktop
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
  // ignore: library_private_types_in_public_api
  _SoftwareModePageState createState() => _SoftwareModePageState();
}

class _SoftwareModePageState extends State<SoftwareModePage> {
  bool isOnline = true; // Default state is Online

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff1f2029),
      body: Center(
        child: Container(
          width: 700,
          // height: 500,
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const Text(
                'Software Mode',
                style: TextStyle(
                  fontSize: 28,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 30),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 176, 193, 201),
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
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: isOnline
                                ? const Color.fromARGB(255, 111, 218, 85)
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
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: !isOnline
                                ? const Color.fromARGB(255, 191, 216, 52)
                                : const Color.fromARGB(0, 92, 30, 30),
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
              if (isOnline) const OnlineForm() else OfflineForm(),
              const SizedBox(height: 30),
              SizedBox(
                width: double
                    .infinity, // Makes the button take the full width of its parent
                child: ElevatedButton(
                  onPressed: () {
                    // Handle next button action
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                          builder: (context) => const LoginPage()),
                    );
                    print("isonline $isOnline");
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepOrange[400],
                    foregroundColor: const Color.fromARGB(255, 17, 17, 17),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 20),
                  ),
                  child: const Text(
                    'Next',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class OnlineForm extends StatelessWidget {
  const OnlineForm({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        _buildTextField('API Key'),
        const SizedBox(height: 10),
        _buildTextField('Secret Key', obscureText: true),
      ],
    );
  }

  Widget _buildTextField(String label, {bool obscureText = false}) {
    return TextField(
      obscureText: obscureText,
      decoration: InputDecoration(
        hintText: label,
        fillColor: Colors.white,
        filled: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30), // Rounded border
        ),
        hintStyle: const TextStyle(
          color: Colors.grey, // Ensure hint text is distinct
        ),
      ),
      style: const TextStyle(
        color: Colors.black, // Input text color
      ),
    );
  }
}

class OfflineForm extends StatelessWidget {
  final TextEditingController companyNameController = TextEditingController();
  final TextEditingController companyIdController = TextEditingController();
  final TextEditingController contactNumberController = TextEditingController();
  final TextEditingController companyController = TextEditingController();
  final TextEditingController emailIdController = TextEditingController();

  // OfflineFormWidget({super.key});

  void _saveFormData() async {
    print("inside save");

    // Create FormData instance
    FormData formData = FormData(
      companyName: companyNameController.text,
      companyId: companyIdController.text,
      contactNumber: contactNumberController.text,
      company: companyController.text,
      emailId: emailIdController.text,
      online: false, // Set to false for offline login
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

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        _buildTextField('Company Name', controller: companyNameController),
        const SizedBox(height: 10),
        _buildTextField('Company ID', controller: companyIdController),
        const SizedBox(height: 10),
        _buildTextField('Contact Number', controller: contactNumberController),
        const SizedBox(height: 10),
        _buildTextField('Company', controller: companyController),
        const SizedBox(height: 10),
        _buildTextField('Email ID', controller: emailIdController),
        ElevatedButton(
          onPressed: _saveFormData,
          child: Text('Save Offline Data'),
        ),
      ],
    );
  }

  Widget _buildTextField(String label,
      {required TextEditingController controller}) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        hintText: label,
        fillColor: const Color.fromARGB(255, 247, 243, 243),
        filled: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
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
}
