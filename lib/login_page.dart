import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_pos_app/Mode_selector.dart';
import 'package:flutter_pos_app/database/database_helper.dart';
import 'package:flutter_pos_app/main.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  String? selectedCompany; // Updated to handle dynamic
  List<String> companyNames = []; // List to hold company names

  @override
  void initState() {
    super.initState();
    _fetchCompanyNames();
  }

  void _login() async {
    String username = _usernameController.text;
    String password = _passwordController.text;

    if (selectedCompany == null || selectedCompany!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Please Select A Company',
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.all(10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          duration: Duration(seconds: 3),
        ),
      );
      return;
    }

    SharedPreferences prefs = await SharedPreferences.getInstance();
    var checkOnline = await prefs.getBool('isOnline');
    print("checkOnline$checkOnline");

    bool isValidUser = await DatabaseHelper()
        .validateUser(username, password, selectedCompany!);
    print("isvalide$isValidUser");

    await prefs.setBool('isValidUser', isValidUser);
    await prefs.setString('selectedCompanyName', selectedCompany!);

    if (isValidUser) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const MainPage()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Invalid username, password, or company',
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.all(10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  Future<void> _fetchCompanyNames() async {
    List<String> names = await DatabaseHelper().getCompanyNames();
    setState(() {
      companyNames = names;
      selectedCompany = null; // No default selection
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 35,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back), // Back arrow icon
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => SoftwareModePage()),
            );
          },
        ),
      ),
      // backgroundColor: const Color(0xff1f2029),
      backgroundColor: Colors.white,
      body: LayoutBuilder(
        builder: (context, constraints) {
          // Check if the screen width is larger than 600 (or any value you consider for desktop)
          final bool isDesktop = constraints.maxWidth > 600;

          return Row(
            children: [
              if (isDesktop) // Display only on desktop
                Expanded(
                  child: Container(
                    // color: const Color(0xff2c2f36),
                    color: Color.fromARGB(209, 211, 212, 154),
                    child: const Center(
                      child: Text(
                        ' POSFood!\nWhere Taste Meets Quality',
                        style: TextStyle(
                          color: Colors.black,
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
                      color: const Color.fromARGB(255, 224, 201, 201),
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
                                    vertical: 10, horizontal: 12),
                                hintText: 'Select your company',
                                hintStyle: const TextStyle(
                                    color: Colors.grey, height: 2.2),
                              ),
                            ),
                            const SizedBox(height: 20),
                            TextField(
                              controller: _usernameController,
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: Colors.white,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(20),
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
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                hintText: 'Password',
                              ),
                            ),
                            const SizedBox(height: 40),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF4285F4),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                    vertical: 20, horizontal: 20),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              onPressed: () {
                                _login();
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
