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
  bool _isLoggedIn = false; // Change this based on actual login state

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    // Simulate a delay for checking login status
    await Future.delayed(const Duration(seconds: 2));

    // Here you would typically check the actual login status from storage
    setState(() {
      _isLoggedIn = false; // Set to true if user is logged in
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoggedIn) {
      return const MainPage(); // Show the main page if logged in
    } else {
      // return const SoftwareModePage(); // Show the login page if not logged in
      return MainPage();
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

  final List<Item> items = [
    Item(
        image: 'assets/items/1.png',
        title: 'Original Burger',
        price: '\$5.99',
        itemCount: 1,
        category: 'Burger',
        tax: ''),
    Item(
        image: 'assets/items/2.png',
        title: 'Double Burger',
        price: '\$10.99',
        itemCount: 1,
        category: 'Burger',
        tax: ''),
  ];

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: const Color(0xff1f2029),
      // backgroundColor: Color.fromARGB(255, 240, 231, 231),
      backgroundColor: Colors.white,
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
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => SalesReport(
                            items: items,
                          )),
                );
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
