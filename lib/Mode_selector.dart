// ignore: file_names
import 'package:flutter/material.dart';
import 'package:flutter_pos_app/login_page.dart';

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
                  boxShadow: [
                    BoxShadow(
                      color: const Color.fromARGB(141, 211, 204, 193)
                          .withOpacity(0.2), // Shadow color
                      spreadRadius: 10, // Spread radius
                      blurRadius: 10, // Blur radius
                      offset: const Offset(5, 5), // Changes position of shadow
                    ),
                  ],
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
              if (isOnline) const OnlineForm() else const OfflineForm(),
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
  const OfflineForm({super.key});
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        _buildTextField('Company Name'),
        const SizedBox(height: 10),
        _buildTextField('Company ID'),
        const SizedBox(height: 10),
        _buildTextField('Contact Number'),
        const SizedBox(height: 10),
        _buildTextField('Company'),
        const SizedBox(height: 10),
        _buildTextField('Email ID'),
      ],
    );
  }

  Widget _buildTextField(String label) {
    return TextField(
      // readOnly: true,
      decoration: InputDecoration(
        hintText: label,
        fillColor: const Color.fromARGB(255, 247, 243, 243),
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
