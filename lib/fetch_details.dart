import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_pos_app/main.dart';
import 'package:flutter_pos_app/model/customer.dart';
import 'package:flutter_pos_app/model/itemData.dart';
import 'package:flutter_pos_app/model/supplier.dart';
import 'package:flutter_pos_app/model/userss.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_pos_app/database/database_helper.dart';
import 'package:flutter_pos_app/model/company.dart';
import 'package:flutter_pos_app/model/form_data.dart';
import 'package:flutter_pos_app/model/companyy.dart';

class FetchDetailsPage extends StatefulWidget {
  final Company company;

  const FetchDetailsPage({Key? key, required this.company}) : super(key: key);

  @override
  _FetchDetailsPageState createState() => _FetchDetailsPageState();
}

class _FetchDetailsPageState extends State<FetchDetailsPage> {
  late String apiKey;
  late String secretKey;
  late String url;
  late String selectedCompanyName;
  late String selectedCompanyId;

  Map<String, dynamic>? fetchedData;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      apiKey = prefs.getString('apiKey') ?? '';
      secretKey = prefs.getString('secretKey') ?? '';
      url = prefs.getString('url') ?? '';
      selectedCompanyName = prefs.getString('selectedCompanyName') ?? '';
      selectedCompanyId = prefs.getString('selectedCompanyId') ?? '';
    });
    print(apiKey);
    print("selectedco$selectedCompanyName");
    print(secretKey);
    _fetchCompanyDetails(); // Fetch company details after loading preferences
  }

  Future<void> _fetchCompanyDetails() async {
    final detailsUrl = '$url/company_details?company_name=$selectedCompanyName';
    String basicAuth =
        'Basic ' + base64Encode(utf8.encode('$apiKey:$secretKey'));
    print("fdf$detailsUrl");

    try {
      final response = await http.get(
        Uri.parse(detailsUrl),
        headers: <String, String>{
          'Authorization': basicAuth,
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data.containsKey('message') && data['message'] is List) {
          fetchedData = {'entries': data['message']};
        } else {
          fetchedData = null;
        }
      } else {
        print('Failed to fetch company details. Response: ${response.body}');
      }
    } catch (e, stacktrace) {
      print('Error fetching company details: $e');
      print('Stacktrace: $stacktrace');
    }
  }

  Future<void> _saveItemsToDB(List<dynamic> itemsList) async {
    final dbHelper = DatabaseHelper();

    for (var item in itemsList) {
      if (item['company_name'] == selectedCompanyName) {
        final itemData = ItemData(
          itemCode: item['item_code'] ?? '',
          itemName: item['item_name'] ?? '',
          itemPrice: item['item_price'] != null
              ? (item['item_price'] as num).toDouble()
              : 0.0,
          itemTax: item['item_tax'] != null
              ? (item['item_tax'] as num).toDouble()
              : 0.0,
          itemGroup: item['item_group'] ?? '',
          companyName: item['company_name'] ?? '',
          warehouse: item['warehouse'] ?? '',
          itemPriceList: item['item_price_list'] ?? '',
          uom: item['uom'] ?? '',
          itemTaxType: item['item_tax_type'] ?? '',
        );

        await dbHelper.insertItem(itemData);
      }
    }
  }

  Future<void> fetchAndStoreItems() async {
    String newUrl = trimUrl(url);
    final String itemsUrl =
        '${newUrl}item_details.get_item_details?company_name=$selectedCompanyName';

    print("newurlddddd$newUrl");
    print("oldurll$itemsUrl");
    String basicAuth =
        'Basic ' + base64Encode(utf8.encode('$apiKey:$secretKey'));

    try {
      final response = await http.get(
        Uri.parse(itemsUrl),
        headers: <String, String>{
          'Authorization': basicAuth,
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> itemsList = jsonDecode(response.body)['message'];
        if (itemsList.isNotEmpty) {
          await _saveItemsToDB(itemsList);
        } else {
          print('No items found for the selected company.');
        }
      } else {
        print('Failed to fetch items. Response: ${response.body}');
      }
    } catch (e, stacktrace) {
      print('Error fetching items: $e');
      print('Stacktrace: $stacktrace');
    }
  }

  String trimUrl(String fullUrl) {
    String baseUrl = '';

    // Find the position of the 'duplex_dev.api.' part in the full URL
    int index = fullUrl.indexOf('duplex_dev.api.');

    if (index != -1) {
      // Trim the URL to include only up to 'duplex_dev.api.'
      baseUrl = fullUrl.substring(0, index + 'duplex_dev.api.'.length);
    } else {
      // If not found, return the original URL (or handle as needed)
      baseUrl = fullUrl;
    }
    return baseUrl;
  }

  Future<void> fetchAndStoreCompanies() async {
    String newUrl = trimUrl(url);
    final String companyUrl =
        '${newUrl}company_details.get_company_details?company_name=$selectedCompanyName';
    print("fetchcompany $companyUrl");

    String basicAuth =
        'Basic ' + base64Encode(utf8.encode('$apiKey:$secretKey'));

    try {
      final response = await http.get(
        Uri.parse(companyUrl),
        headers: <String, String>{
          'Authorization': basicAuth,
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> companyList = jsonDecode(response.body)['message'];
        if (companyList.isNotEmpty) {
          final dbHelper = DatabaseHelper();
          print("selected compa$selectedCompanyName");

          for (var company in companyList) {
            if (company['company_name'] == selectedCompanyName) {
              final companyData = Companyy(
                companyName: company['company_name'] ?? '',
                owner: company['owner'] ?? '',
                abbr: company['abbr'] ?? '',
                country: company['country'] ?? '',
                vatNumber: company['vat_number'] ?? '',
                phoneNo: company['phone_no'] ?? '',
                email: company['email'] ?? '',
                website: company['website'] ?? '',
              );
              // Insert into the database
              await dbHelper.insertCompany(companyData);
            }
          }
        } else {
          print('No companies found for the selected company.');
        }
      } else {
        print('Failed to fetch companies. Response: ${response.body}');
      }
    } catch (e, stacktrace) {
      print('Error fetching companies: $e');
      print('Stacktrace: $stacktrace');
    }
  }

  Future<void> fetchAndStoreUsers() async {
    String newUrl = trimUrl(url);
    final String itemsUrl =
        '${newUrl}user_details.get_employee_auth_details?company_name=$selectedCompanyName';
    String basicAuth =
        'Basic ' + base64Encode(utf8.encode('$apiKey:$secretKey'));
    print("userurl$itemsUrl");

    try {
      final response = await http.get(
        Uri.parse(itemsUrl),
        headers: <String, String>{
          'Authorization': basicAuth,
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> usersList = jsonDecode(response.body)['message'];
        if (usersList.isNotEmpty) {
          final dbHelper = DatabaseHelper();

          for (var user in usersList) {
            if (user['company_name'] == selectedCompanyName) {
              final userData = User(
                empName: user['emp_name'] ?? '',
                phoneNo: user['phone_no'] ?? '',
                email: user['email'] ?? '',
                companyName: user['company_name'] ?? '',
                companyBranch: user['company_branch'] ?? '',
                empStatus: user['emp_status'] ?? '',
                username: user['username'] ?? '',
                password: user['password'] ?? '',
              );

              await dbHelper.insertUser(userData);
            }
          }
        } else {
          print('No users found for the selected company.');
        }
      } else {
        print('Failed to fetch users. Response: ${response.body}');
      }
    } catch (e, stacktrace) {
      print('Error fetching users: $e');
      print('Stacktrace: $stacktrace');
    }
  }

  Future<void> fetchAndStoreSuppliers() async {
    String newUrl = trimUrl(url);
    final String itemsUrl =
        '${newUrl}supplier_details.get_supplier_details?company_name=$selectedCompanyName';
    print("fetchsupplie $itemsUrl");
    String basicAuth =
        'Basic ' + base64Encode(utf8.encode('$apiKey:$secretKey'));

    try {
      final response = await http.get(
        Uri.parse(itemsUrl),
        headers: <String, String>{
          'Authorization': basicAuth,
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> suppliersList =
            jsonDecode(response.body)['message'];
        if (suppliersList.isNotEmpty) {
          final dbHelper = DatabaseHelper();

          for (var supplier in suppliersList) {
            if (supplier['company_name'] == selectedCompanyName) {
              final supplierData = Supplier(
                supplierName: supplier['supplier_name'] ?? '',
                type: supplier['type'] ?? '',
                companyName: supplier['company_name'] ?? '',
                supplierGroup: supplier['supplier_group'] ?? '',
                vatNumber: supplier['vat_number'] ?? '',
                phoneNo: supplier['phone_no'] ?? '',
                email: supplier['email'] ?? '',
                country: supplier['country'] ?? '',
              );

              await dbHelper.insertSupplier(supplierData);
            }
          }
        } else {
          print('No suppliers found for the selected company.');
        }
      } else {
        print('Failed to fetch suppliers. Response: ${response.body}');
      }
    } catch (e, stacktrace) {
      print('Error fetching suppliers: $e');
      print('Stacktrace: $stacktrace');
    }
  }

  Future<void> fetchAndStoreCustomers() async {
    print("inside fetchandstorecustomer");
    String newUrl = trimUrl(url);
    final String itemsUrl =
        '${newUrl}customer_details.get_customer_details?company_name=$selectedCompanyName';
    String basicAuth =
        'Basic ' + base64Encode(utf8.encode('$apiKey:$secretKey'));
    print("itemurlcuddtomer$itemsUrl");

    try {
      final response = await http.get(
        Uri.parse(itemsUrl),
        headers: <String, String>{
          'Authorization': basicAuth,
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> customersList =
            jsonDecode(response.body)['message'];
        if (customersList.isNotEmpty) {
          final dbHelper = DatabaseHelper();

          for (var customer in customersList) {
            if (customer['company_name'] == selectedCompanyName) {
              final customerData = Customer(
                customerName: customer['customer_name'] ?? '',
                customerType: customer['type'] ?? '',
                companyName: customer['company_name'] ?? '',
                customerGroup: customer['customer_group'] ?? '',
                vatNumber: customer['vat_number'] ?? '',
                phoneNo: customer['phone_no'] ?? '',
                email: customer['email'] ?? '',
              );

              await dbHelper.insertCustomer(customerData);
            }
          }
        } else {
          print('No customers found for the selected company.');
        }
      } else {
        print('Failed to fetch customers. Response: ${response.body}');
      }
    } catch (e, stacktrace) {
      print('Error fetching customers: $e');
      print('Stacktrace: $stacktrace');
    }
  }

  @override
  Widget build(BuildContext context) {
    // final int numberOfButtons = 5; // Update this as needed
    final bool hasExtraButton = true;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Details Page'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ElevatedButton.icon(
                      onPressed: fetchAndStoreCompanies,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        textStyle: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                        foregroundColor: Colors.white,
                      ),
                      icon: const Icon(Icons.business, size: 20),
                      label: const Text('Sync Company'),
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ElevatedButton.icon(
                      onPressed: fetchAndStoreUsers,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        textStyle: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                        foregroundColor: Colors.white,
                      ),
                      icon: const Icon(Icons.person, size: 20),
                      label: const Text('Sync Users'),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ElevatedButton.icon(
                      onPressed: fetchAndStoreItems,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        textStyle: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                        foregroundColor: Colors.white,
                      ),
                      icon: const Icon(Icons.inventory, size: 20),
                      label: const Text('Sync Items'),
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ElevatedButton.icon(
                      onPressed: fetchAndStoreCustomers,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        textStyle: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                        foregroundColor: Colors.white,
                      ),
                      icon: const Icon(Icons.people, size: 20),
                      label: const Text('Sync Customers'),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ElevatedButton.icon(
                      onPressed: fetchAndStoreSuppliers,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        textStyle: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                        foregroundColor: Colors.white,
                      ),
                      icon: const Icon(Icons.local_shipping, size: 20),
                      label: const Text('Sync Suppliers'),
                    ),
                  ),
                ),
                // if (hasExtraButton) Expanded(child: Container()),
                if (hasExtraButton)
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      // child: ElevatedButton.icon(
                      //   onPressed: () {
                      //     Navigator.push(
                      //       context,
                      //       MaterialPageRoute(builder: (context) => MainPage()),
                      //     );
                      //   },
                      //   style: ElevatedButton.styleFrom(
                      //     backgroundColor:
                      //         Colors.green, // Customize the color if needed
                      //     padding: const EdgeInsets.symmetric(vertical: 20),
                      //     textStyle: const TextStyle(
                      //       fontSize: 16,
                      //       fontWeight: FontWeight.bold,
                      //     ),
                      //     foregroundColor: Colors.white,
                      //   ),
                      //   label: const Text('Go to MainPage'),
                      //   icon: const Icon(Icons.arrow_forward, size: 20),
                      // ),

                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => MainPage()),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              Colors.green, // Customize the color if needed
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          textStyle: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          foregroundColor: Colors.white,
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize
                              .min, // Ensures the button wraps tightly around the content
                          children: [
                            Text('Go to MainPage'),
                            SizedBox(
                                width:
                                    8), // Adds some space between the text and icon
                            Icon(Icons.arrow_forward, size: 20),
                          ],
                        ),
                      ),
                    ),
                  )
              ],
            ),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () async {
                    final dbHelper = DatabaseHelper();
                    await dbHelper.clearItems();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 30, vertical: 10),
                  ),
                  child: const Text(
                    'Clear Items',
                    style: TextStyle(
                      color: Colors.white, // Set your desired color here
                    ),
                  ),
                ),
                const SizedBox(width: 15),
                ElevatedButton(
                  onPressed: () async {
                    final dbHelper = DatabaseHelper();
                    await dbHelper.clearCustomers();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 30, vertical: 10),
                  ),
                  child: const Text(
                    'Clear Customers',
                    style: TextStyle(
                      color: Colors.white, // Set your desired color here
                    ),
                  ),
                ),
                const SizedBox(width: 15),
                ElevatedButton(
                  onPressed: () async {
                    final dbHelper = DatabaseHelper();
                    await dbHelper.clearSuppliers();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 30, vertical: 10),
                  ),
                  child: const Text(
                    'Clear Suppliers',
                    style: TextStyle(
                      color: Colors.white, // Set your desired color here
                    ),
                  ),
                ),
                const SizedBox(width: 15),
                ElevatedButton(
                  onPressed: () async {
                    final dbHelper = DatabaseHelper();
                    await dbHelper.clearUsers();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 30, vertical: 10),
                  ),
                  child: const Text(
                    'Clear Users',
                    style: TextStyle(
                      color: Colors.white, // Set your desired color here
                    ),
                  ),
                ),
                const SizedBox(width: 15),
                ElevatedButton(
                  onPressed: () async {
                    final dbHelper = DatabaseHelper();
                    await dbHelper.clearCompanies();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 30, vertical: 10),
                  ),
                  child: const Text(
                    'Clear Companies',
                    style: TextStyle(
                      color: Colors.white, // Set your desired color here
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
