import 'package:flutter/material.dart';
import 'package:flutter_pos_app/login_page.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: SoftwareModePage(),
    );
  }
}

class SoftwareModePage extends StatefulWidget {
  @override
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
              SizedBox(height: 30),
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
                                ? Color.fromARGB(255, 111, 218, 85)
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
                                ? Color.fromARGB(255, 191, 216, 52)
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
              SizedBox(height: 30),
              if (isOnline) OnlineForm() else OfflineForm(),
              SizedBox(height: 30),
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
                  child: Text(
                    'Next',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepOrange[400],
                    foregroundColor: Color.fromARGB(255, 17, 17, 17),
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
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
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        _buildTextField('API Key'),
        SizedBox(height: 10),
        _buildTextField('Secret Key'),
      ],
    );
  }

  Widget _buildTextField(String label, {bool obscureText = false}) {
    return TextField(
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: label,
        fillColor: const Color.fromARGB(255, 182, 167, 167),
        filled: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30), // Rounded border
        ),
      ),
    );
  }
}

class OfflineForm extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        _buildTextField('Company Name'),
        SizedBox(height: 10),
        _buildTextField('Company ID'),
        SizedBox(height: 10),
        _buildTextField('Contact Number'),
        SizedBox(height: 10),
        _buildTextField('Company'),
        SizedBox(height: 10),
        _buildTextField('Email ID'),
      ],
    );
  }

  Widget _buildTextField(String label) {
    return TextField(
      readOnly: true,
      decoration: InputDecoration(
        labelText: label,
        fillColor: Color.fromARGB(255, 182, 167, 167),
        filled: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30), // Rounded border
        ),
      ),
    );
  }
}
