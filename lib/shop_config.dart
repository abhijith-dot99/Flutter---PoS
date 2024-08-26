import 'package:flutter/material.dart';

class ShopConfigPage extends StatefulWidget {
  const ShopConfigPage({Key? key}) : super(key: key);

  @override
  State<ShopConfigPage> createState() => _ShopConfigPageState();
}

class _ShopConfigPageState extends State<ShopConfigPage> {
  final TextEditingController _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: const Color(0xff1f2029),
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      appBar: AppBar(
        // backgroundColor: const Color(0xff2c2f36),
        backgroundColor: Color.fromARGB(155, 239, 241, 241),
        elevation: 0,
        title: const Text(
          'Shop Config',
          style: TextStyle(
            color: Colors.black87, // Set text color to white
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.black54),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search...',
                hintStyle: const TextStyle(color: Colors.black38),
                filled: true,
                fillColor: const Color.fromARGB(255, 225, 229, 238),
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderSide: BorderSide.none,
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Your shop config content goes here
            const Expanded(
              child: Center(
                child: Text(
                  'Shop Configuration Settings',
                  style: TextStyle(color: Colors.white, fontSize: 20),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
