import 'package:flutter/material.dart';
import 'package:flutter_pos_app/home.dart';
import 'package:flutter_pos_app/login_page.dart';
import 'package:flutter_pos_app/shop_config.dart';

import 'customer_list_page.dart';
import 'sales_report.dart'; // Import the login page
import 'package:flutter/services.dart';

void main() {
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
      return const LoginPage(); // Show the login page if not logged in
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

  _pageView() {
    switch (pageActive) {
      case 'Home':
        return const HomePage();
      case 'Menu':
        return Container();
      case 'History':
        return Container();
      case 'Promos':
        return Container();
      case 'Settings':
        return Container();
      default:
        return const HomePage();
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
      backgroundColor: const Color(0xff1f2029),
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
              margin: const EdgeInsets.only(top: 24, right: 12),
              padding: const EdgeInsets.only(top: 12, right: 12, left: 12),
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12)),
                color: Color(0xff17181f),
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
      const SizedBox(height: 20),
      Expanded(
        child: ListView(
          children: [
            _itemMenu(
              menu: 'Home',
              icon: Icons.rocket_sharp,
              onTap: () {  },
            ),
            _itemMenu(
              menu: 'Menu',
              icon: Icons.format_list_bulleted_rounded,
              onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (context) => const ShopConfigPage())),
            ),
            _itemMenu(
              menu: 'History',
              icon: Icons.history_toggle_off_rounded, onTap: () {  },
            ),
            _itemMenu(
              menu: 'Promos',
              icon: Icons.discount_outlined,
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const CustomerListPage()),
              ),
            ),
            _itemMenu(
              menu: 'Settings',
              icon: Icons.sports_soccer_outlined, onTap: () {  },
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
            color: Colors.white,
            fontSize: 8,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  // Widget _itemMenu({required String menu, required IconData icon}) {
  //   return Padding(
  //     padding: const EdgeInsets.symmetric(vertical: 9),
  //     child: GestureDetector(
  //       onTap: () => _setPage(menu),
  //       child: MouseRegion(
  //           cursor: SystemMouseCursors.click,
  //           child: AnimatedContainer(
  //             padding: const EdgeInsets.symmetric(vertical: 12),
  //             decoration: BoxDecoration(
  //               borderRadius: BorderRadius.circular(8),
  //               color: pageActive == menu
  //                   ? Colors.deepOrangeAccent
  //                   : Colors.transparent,
  //             ),
  //             duration: const Duration(milliseconds: 300),
  //             curve: Curves.slowMiddle,
  //             child: Column(
  //               children: [
  //                 Icon(
  //                   icon,
  //                   color: Colors.white,
  //                 ),
  //                 const SizedBox(height: 5),
  //                 Text(
  //                   menu,
  //                   style: const TextStyle(color: Colors.white, fontSize: 10),
  //                 ),
  //               ],
  //             ),
  //           )),
  //     ),
  //   );
  // }



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
                  color: Colors.white,
                ),
                const SizedBox(height: 5),
                Text(
                  menu,
                  style: const TextStyle(color: Colors.white, fontSize: 10),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

}

