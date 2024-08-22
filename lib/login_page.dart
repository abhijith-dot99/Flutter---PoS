import 'package:flutter/material.dart';
import 'package:flutter_pos_app/database/database_helper.dart';
import 'package:flutter_pos_app/main.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  String? selectedCompany; // Updated to handle dynamic selection
  List<String> companyNames = []; // List to hold company names

  @override
  void initState() {
    super.initState();
    _fetchCompanyNames();
  }

  Future<void> _fetchCompanyNames() async {
    List<String> names = await DatabaseHelper().getCompanyNames();
    setState(() {
      companyNames = names;
      if (companyNames.isNotEmpty) {
        selectedCompany = companyNames[0]; // Set default selection
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff1f2029),
      body: LayoutBuilder(
        builder: (context, constraints) {
          // Check if the screen width is larger than 600 (or any value you consider for desktop)
          final bool isDesktop = constraints.maxWidth > 600;

          return Row(
            children: [
              if (isDesktop) // Display only on desktop
                Expanded(
                  child: Container(
                    color: const Color(0xff2c2f36),
                    child: const Center(
                      child: Text(
                        'Welcome to POSFood!\nWhere Taste Meets Quality',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
              Expanded(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Card(
                      color: const Color(0xff2c2f36),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                      elevation: 6,
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text(
                              'Login',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 20),
                            DropdownButtonFormField<String>(
                              value: selectedCompany,
                              items: companyNames
                                  .map((name) => DropdownMenuItem<String>(
                                        value: name,
                                        child: Text(
                                          name,
                                          style: const TextStyle(
                                              color: Colors.black),
                                        ),
                                      ))
                                  .toList(),
                              onChanged: (value) {
                                setState(() {
                                  selectedCompany = value!;
                                });
                              },
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: Colors.white,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                    vertical: 10, horizontal: 15),
                              ),
                            ),
                            const SizedBox(height: 20),
                            TextField(
                              controller: _usernameController,
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: Colors.white,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(18),
                                ),
                                hintText: 'Username',
                              ),
                            ),
                            const SizedBox(height: 20),
                            TextField(
                              controller: _passwordController,
                              obscureText: true,
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: Colors.white,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                hintText: 'Password',
                              ),
                            ),
                            const SizedBox(height: 40),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.deepOrange,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                    vertical: 20, horizontal: 20),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              onPressed: () {
                                // Validate login and navigate to MainPage
                                Navigator.of(context).pushReplacement(
                                  MaterialPageRoute(
                                      builder: (context) => const MainPage()),
                                );
                              },
                              child: const Text('Login',
                                  style: TextStyle(fontSize: 18)),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
