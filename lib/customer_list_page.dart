import 'package:flutter/material.dart';

class CustomerListPage extends StatefulWidget {
  const CustomerListPage({Key? key}) : super(key: key);

  @override
  State<CustomerListPage> createState() => _CustomerListPageState();
}

class _CustomerListPageState extends State<CustomerListPage> {
  final TextEditingController _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff1f2029),
      appBar: AppBar(
        backgroundColor: const Color(0xff2c2f36),
        elevation: 0,
        title: const Text('Customer List',
          style: TextStyle(
            color: Colors.white, // Set text color to white
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search...',
                hintStyle: TextStyle(color: Colors.white54),
                filled: true,
                fillColor: Color(0xff1f2029),
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Your customer list content goes here
            const Expanded(
              child: Center(
                child: Text(
                  'List of Customers',
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
