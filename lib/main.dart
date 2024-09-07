import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_pos_app/Mode_selector.dart';
import 'package:flutter_pos_app/home.dart';
import 'package:flutter_pos_app/login_page.dart';
import 'package:flutter_pos_app/sales_report.dart';
import 'package:flutter_pos_app/shop_config.dart';
import 'model/item.dart';
import 'settings.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  // sqfliteFfiInit();
  // databaseFactory = databaseFactoryFfi;

  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'POS Food',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const AppInitializer(), // Use a widget to initialize the app state
      debugShowCheckedModeBanner: false,
    );
  }
}

class AppInitializer extends StatefulWidget {
  const AppInitializer({Key? key}) : super(key: key);

  @override
  State<AppInitializer> createState() => _AppInitializerState();
}

class _AppInitializerState extends State<AppInitializer> {
  bool _isLoggedIn = false;
  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<bool> _checkLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isValidUser = prefs.getBool('isValidUser') ?? false;
    print("isvalidedmain$isValidUser");

    // Use setState before returning to update the UI
    setState(() {
      _isLoggedIn =
          isValidUser; // Update _isLoggedIn based on stored login status
    });

    print("isloginmain$_isLoggedIn");

    return isValidUser;
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoggedIn) {
      return const MainPage(); // Show the main page if logged in
    } else {
      return const SoftwareModePage(); // Show the login page if not logged in
      // return MainPage();
    }
  }
}

class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  String pageActive = 'Home';
  bool showImages = false;
  double itemHeight = 250; // Default height
  double itemWidth = 120;

  _pageView() {
    switch (pageActive) {
      case 'Home':
        return HomePage(showImages: showImages);
      case 'Menu':
        return Container();
      case 'History':
        return Container();
      case 'Promos':
        return Container();
      case 'Settings':
        return Container();
      default:
        return HomePage(showImages: showImages);
    }
  }

  _setPage(String page) {
    setState(() {
      pageActive = page;
    });
  }

  Future<void> _logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    // Set the login status to false
    await prefs.setBool('isValidUser', false);
    // print("insde logiut$isValidUser");

    // After setting isLoggedIn to false, navigate to the login page
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
          builder: (context) =>
              const SoftwareModePage()), // Replace with your login page
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          Container(
            width: 70,
            padding: const EdgeInsets.only(top: 24, right: 12, left: 12),
            height: MediaQuery.of(context).size.height,
            child: _sideMenu(),
          ),
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(top: 34),
              padding: const EdgeInsets.only(top: 3, left: 3, right: 2),
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(2), topRight: Radius.circular(2)),
                color: Color.fromARGB(255, 230, 203, 203),
              ),
              child: _pageView(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sideMenu() {
    return Column(children: [
      _logo(),
      // const SizedBox(height: 5),
      Expanded(
        child: ListView(
          children: [
            _itemMenu(
              menu: 'Home',
              icon: Icons.rocket_sharp,
              onTap: () {
                _setPage('Home');
              },
            ),
            _itemMenu(
              menu: 'Sales',
              icon: Icons.assignment,
              onTap: () {
                // Navigator.push(
                //   context,
                //   MaterialPageRoute(
                //       builder: (context) => SalesReport(
                //             items: items,
                //           )),
                // );
              },
            ),
            _itemMenu(
              menu: 'Menu',
              icon: Icons.format_list_bulleted_rounded,
              onTap: () => Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => const ShopConfigPage())),
            ),
            _itemMenu(
              menu: 'Settings',
              icon: Icons.settings,
              onTap: () {
                Navigator.of(context)
                    .push(
                  MaterialPageRoute(
                    builder: (context) => SettingsPage(
                      showImages: showImages,
                      onShowImagesChanged: (value) {
                        setState(() {
                          showImages = value;
                        });
                      },
                    ),
                  ),
                )
                    .then((_) {
                  // Refresh the page to reflect updated settings
                  setState(() {});
                });
              },
            ),
            const SizedBox(height: 10),
            IconButton(
              icon: const Column(
                mainAxisSize: MainAxisSize
                    .min, // This ensures the column doesn't take more space than necessary
                children: [
                  Icon(
                    Icons.logout,
                    size: 28,
                    color: Colors.red, // Set the icon color to red
                  ),
                  SizedBox(height: 4), // Space between the icon and text
                ],
              ),
              onPressed: _logout, // Call the logout function when clicked
            )
          ],
        ),
      ),
    ]);
  }

  Widget _logo() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: Colors.deepOrangeAccent,
          ),
          child: const Icon(
            Icons.fastfood,
            color: Colors.white,
            size: 14,
          ),
        ),
        const SizedBox(height: 10),
        const Text(
          'POSFood',
          style: TextStyle(
            color: Colors.black,
            fontSize: 8,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _itemMenu({
    required String menu,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 9),
      child: GestureDetector(
        onTap: onTap, // Use the onTap parameter
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          child: AnimatedContainer(
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: pageActive == menu
                  ? Colors.deepOrangeAccent
                  : Colors.transparent,
            ),
            duration: const Duration(milliseconds: 300),
            curve: Curves.slowMiddle,
            child: Column(
              children: [
                Icon(
                  icon,
                  color: Colors.black54,
                ),
                const SizedBox(height: 5),
                Text(
                  menu,
                  style: const TextStyle(color: Colors.black54, fontSize: 10),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
