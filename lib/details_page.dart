import 'package:flutter/material.dart';
import 'package:flutter_pos_app/database/database_helper.dart';
import 'model/company.dart';
import 'model/item.dart';

class DetailsPage extends StatefulWidget {
  const DetailsPage({Key? key}) : super(key: key);

  @override
  _DetailsPageState createState() => _DetailsPageState();
}

class _DetailsPageState extends State<DetailsPage> {
  String _selectedCategory = '';
  dynamic _details;
  late Future<void> _fetchDetailsFuture;

  @override
  void initState() {
    super.initState();
    _fetchDetailsFuture = Future.value();
  }

  Future<void> _fetchDetails(String category) async {
    print("cat$category");
    final dbHelper = DatabaseHelper();

    switch (category) {
      case 'Company':
        _details = await dbHelper
            .getLatestCompany(); // Assuming getAllCompanies fetches a list of companies
        break;
      case 'Items':
        _details = await dbHelper.getAllItems();
        break;
      case 'Users':
        _details = await dbHelper.getAllUsers();
    }
  }

  void _onCategorySelected(String category) {
    setState(() {
      _selectedCategory = category;
      _fetchDetailsFuture = _fetchDetails(category);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () => _onCategorySelected('Company'),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.blue, // Text color
                    padding: const EdgeInsets.symmetric(
                        horizontal: 32.0, vertical: 12.0), // Padding
                    textStyle: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ), // Text style
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(20.0), // Rounded corners
                    ),
                  ),
                  child: const Text('Company'),
                ),
                ElevatedButton(
                    onPressed: () => _onCategorySelected('Users'),
                    child: const Text('users')),
                ElevatedButton(
                  onPressed: () => _onCategorySelected('Items'),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.blue, // Text color
                    padding: const EdgeInsets.symmetric(
                        horizontal: 32.0, vertical: 12.0), // Padding
                    textStyle: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ), // Text style
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(20.0), // Rounded corners
                    ),
                  ),
                  child: const Text('Items'),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Expanded(
              child: FutureBuilder<void>(
                future: _fetchDetailsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return const Center(child: Text('Error fetching data'));
                  } else if (_selectedCategory.isEmpty) {
                    return const Center(
                        child: Text('Select a category to view details'));
                  } else {
                    return _buildDetailsDisplay();
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailsDisplay() {
    if (_selectedCategory == 'Company' && _details is List<Company>) {
      final List<Company> companies = _details as List<Company>;
      print('Company list: $companies');
      print('_details: $_details');
      print("selected cat$_selectedCategory");

      // Wrap Column with SingleChildScrollView and Padding to make it scrollable
      return SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: companies.map((company) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Company Name: ${company.companyName}'),
                    const SizedBox(height: 10),
                    Text('Phone Number: ${company.phoneNo}'),
                    const SizedBox(height: 10),
                    Text('Email: ${company.email}'),
                    const SizedBox(height: 10),
                    Text('Branch: ${company.companyBranch}'),
                    const Divider(), // Divider between each company
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      );
    } else if (_selectedCategory == 'Items' && _details is List<Item>) {
      final List<Item> items = _details as List<Item>;
      return ListView.separated(
        itemCount: items.length,
        separatorBuilder: (context, index) =>
            const Divider(), // Add a divider between items
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(items[index].itemName),
            subtitle: Text('Price: \$${items[index].price}'),
          );
        },
      );
    } else {
      return const Center(child: Text('No data available'));
    }
  }
}
