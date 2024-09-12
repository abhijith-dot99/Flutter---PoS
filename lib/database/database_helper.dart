import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter_pos_app/model/company.dart';
import 'package:flutter_pos_app/model/companyy.dart';
import 'package:flutter_pos_app/model/customer.dart';
import 'package:flutter_pos_app/model/form_data.dart';
import 'package:flutter_pos_app/model/item.dart';
import 'package:flutter_pos_app/model/itemData.dart';
import 'package:flutter_pos_app/model/supplier.dart';
import 'package:flutter_pos_app/model/users.dart';
import 'package:flutter_pos_app/model/userss.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:crypto/crypto.dart';
import 'package:collection/collection.dart';
import 'package:http/http.dart' as http;

import 'dart:convert'; // for utf8 encoding
// ignore: depend_on_referenced_packages

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();

  factory DatabaseHelper() {
    return _instance;
  }

  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

/////
  Future<Database> _initDatabase() async {
    String path = 'Db_bizdot.db';

    try {
      final db = await openDatabase(
        path,
        version: 1,
        onCreate: _onCreate, // Called only if the database is being created
      );
      // print("Database opened successfully: $db");
      return db;
    } catch (e) {
      print("Error opening database: $e");
      throw e;
    }
  }

  Future<List<String>> getCompanyNames() async {
    print("insde getcompany");
    final db = await database;
    final List<Map<String, dynamic>> result = await db.query(
      'DB_company',
      columns: ['company_name'],
      where:
          'company_name IS NOT NULL AND company_name != ""', // Filter condition
    );
    return result.map((row) => row['company_name'] as String).toList();
  }

  Future<List<String>> getUserCredintials() async {
    final db = await database;
    final List<Map<String, dynamic>> result = await db.query(
      'DB_company',
      columns: ['username, password'],
    );
    return result.map((row) => row['companyName, password'] as String).toList();
  }

  Future<void> _onCreate(Database db, int version) async {
    print("inside oncreate");
    // Create the DB_company table
    await db.execute('''
    CREATE TABLE IF NOT EXISTS DB_company (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      companyName TEXT,
      owner TEXT,
        abbr TEXT,
        country TEXT,
        vat_number TEXT,
        phone_no TEXT,
        email TEXT,
        website TEXT
    )
  ''');

    // Create the DB_users table
    await db.execute('''
CREATE TABLE IF NOT EXISTS DB_users (
        id INTEGER PRIMARY KEY,
        emp_name TEXT,
        phone_no TEXT,
        email TEXT,
        company_name TEXT,
        company_branch TEXT,
        emp_status TEXT,
        username TEXT,
        password TEXT
      )
  ''');

    await db.execute('''
    CREATE TABLE IF NOT EXISTS invoice_counter (
      id INTEGER PRIMARY KEY,
      current_invoice_number INTEGER
    );
  ''');

    // Initialize the invoice counter if it's empty
    var result = await db.query('invoice_counter');
    if (result.isEmpty) {
      await db
          .insert('invoice_counter', {'id': 1, 'current_invoice_number': 1});
    }
  }

  Future<int> insertOfflineData(FormData formData) async {
    print("Inside insertOfflineData");
    try {
      final db = await database;
      print("Database initialized: $db");

      Map<String, dynamic> companyData = {
        // 'company_name': formData.companyName,
        // 'owner':
        //     formData.owner, // Assuming you have this field in your formData
        // 'abbr':
        //     formData.abbr, // Assuming you have this field in your formData
        // 'country':
        //     formData.country, // Assuming you have this field in your formData
        // 'vat_number': formData
        //     .vatNumber, // Assuming you have this field in your formData
        // 'phone_no': formData.contactNumber,
        // 'email': formData.emailId,
        // 'website':
        //     formData.website, // Assuming you have this field in your formData
        'apikey': formData.apikey,
        'secretkey': formData.secretkey,
        'url': formData.url,
        'companyId': formData.companyId,
      };

      print("Company data: $companyData");
      int companyId = await db.insert('DB_company', companyData);

      // Insert data into DB_users
      Map<String, dynamic> userData = {
        'username': formData.username,
        'password': formData.password,
        'company_name': formData.companyName,
      };

      print("User data: $userData");
      int userId = await db.insert('DB_users', userData);

      return companyId != -1 && userId != -1
          ? 1
          : -1; // Indicate success or failure
    } catch (e) {
      print("Error accessing database: $e");
      return -1; // Indicate failure
    }
  }

  Future<List<Map<String, dynamic>>> getAllOfflineData() async {
    final db = await database;
    return await db.query('DB_company');
  }

  Future<void> printAllData() async {
    final db = await database;
    final List<Map<String, dynamic>> result = await db.query('DB_company');
    print("All rows in DB_company: $result");
  }

  Future<List<Item>> getItems(String selectedCompanyName) async {
    try {
      final db = await database;

      // Query the database for items that match the selected company name
      final List<Map<String, dynamic>> result = await db.query(
        'DB_items',
        where: 'company_name = ?', // SQL WHERE clause
        whereArgs: [
          selectedCompanyName
        ], // Passing the company name argument safely
      );

      print("Items fetched: $result");

      // Convert the result into a list of Item objects
      return result.map((map) => Item.fromMap(map)).toList();
    } catch (e) {
      print("Error fetching items: $e");
      return [];
    }
  }

  Future<List<Company>> getLatestCompany() async {
    try {
      final db = await database;
      print('Database instance obtained: $db');

      // Perform the query
      final List<Map<String, dynamic>> maps =
          await db.query('DB_company', orderBy: 'id DESC');

      print('Query result: $maps');

      if (maps.isNotEmpty) {
        print('Data found in database: ${maps.first}');
        // Convert the first map to a Company object
        final companies = maps.map((map) => Company.fromMap(map)).toList();
        // print('Company object created: $company');
        return companies;
      } else {
        print('No data found in DB_company table');
        return [];
      }
    } catch (e) {
      // Handle the error here
      print('Error fetching latest company: $e');
      return [];
    }
  }

  Future<List<Users>> getAllUsers() async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query('DB_users');

      return List.generate(maps.length, (i) {
        return Users.fromMap(maps[i]);
      });
    } catch (e) {
      // Handle the error here, such as logging it or returning an empty list
      print('Error fetching users: $e');
      return []; // Return an empty list in case of error
    }
  }

  Future<List<Item>> getAllItems() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('DB_items');
    return List.generate(maps.length, (i) {
      return Item.fromMap(maps[i]);
    });
  }

  // Fetch company details by company name
  Future<List<Map<String, dynamic>>> fetchCompanyDetails(
      String companyName) async {
    final db = await database;
    return await db.query(
      'DB_company',
      where: 'company_name = ?',
      whereArgs: [companyName],
    );
  }

  // Fetch users by company name
  Future<List<Map<String, dynamic>>> fetchUsersByCompanyName(
      String companyName) async {
    final db = await database;
    return await db.query(
      'DB_users',
      where: 'company_name = ?',
      whereArgs: [companyName],
    );
  }

  // Fetch items by company name
  Future<List<Map<String, dynamic>>> fetchItemsByCompanyName(
      String companyName) async {
    final db = await database;
    return await db.query(
      'DB_items',
      where: 'company_name = ?',
      whereArgs: [companyName],
    );
  }

  Future<List<Map<String, dynamic>>> fetchCustomersByCompanyName(
      String companyName) async {
    final db = await database;
    return await db.query(
      'DB_customer',
      where: 'company_name = ?',
      whereArgs: [companyName],
    );
  }

  Future<List<Map<String, dynamic>>> fetchSuppliersByCompanyName(
      String companyName) async {
    final db = await database;
    return await db.query(
      'DB_suppliers',
      where: 'company_name = ?',
      whereArgs: [companyName],
    );
  }

  Future<int> insertItem(ItemData item) async {
    print("insdie iteminsert");
    final db = await database;
    return await db.insert('DB_items', item.toJson(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<int> insertUser(User user) async {
    final db = await database;
    return await db.insert(
      'DB_users',
      user.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Insert a company into the database
  Future<int> insertCompany(Companyy company) async {
    final db = await database;
    return await db.insert(
      'DB_company',
      company.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Insert a supplier into the database
  Future<void> insertSupplier(Supplier supplier) async {
    final db = await database; // Obtain your database instance

    await db.insert(
      'Db_suppliers', // Table name
      supplier.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Method to fetch all suppliers
  Future<List<Supplier>> getSuppliers() async {
    final db = await database; // Obtain your database instance

    final List<Map<String, dynamic>> maps = await db.query('suppliers');

    return List.generate(maps.length, (i) {
      return Supplier.fromMap(maps[i]);
    });
  }

  Future<void> insertCustomer(Customer customer) async {
    print("inside insertcustomer");
    final db = await database;
    await db.insert(
      'DB_customer',
      customer.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<String>> getCustomerByCompany(String companyName) async {
    print("getcustomers");
    final db = await database;
    final List<Map<String, dynamic>> result = await db.query(
      'DB_customer', // Your table name
      columns: ['customer_name'], // Specify the columns you need
      where: 'company_name = ?', // Filter by company name
      whereArgs: [companyName], // The argument for the filter
    );
    print("empnameee$result");

    // Convert result to a list of employee names
    return result.map((row) => row['customer_name'] as String).toList();
  }

  Future<void> clearItems() async {
    final db = await database;
    await db.delete('DB_items');
    print('Items table cleared.');
  }

  // Similarly, add methods for other tables
  Future<void> clearCustomers() async {
    final db = await database;
    await db.delete('DB_customer');
    print('Customers table cleared.');
  }

  Future<void> clearSuppliers() async {
    final db = await database;
    await db.delete('DB_suppliers');
    print('Suppliers table cleared.');
  }

  Future<void> clearUsers() async {
    final db = await database;
    await db.delete('DB_users');
    print('Users table cleared.');
  }

  Future<void> clearCompanies() async {
    final db = await database;
    await db.delete('DB_company');
    print('Companies table cleared.');
  }

  ///newchanges
  Future<bool> validateUser(
      String username, String password, String company) async {
    print("inside validateUser function");
    print("username $username");
    print("company $company");

    // Retrieve the stored password hash from the database
    final db = await database;
    final List<Map<String, dynamic>> result = await db.query(
      'DB_users',
      where: 'username = ? AND company_name = ?',
      whereArgs: [username, company],
    );

    if (result.isNotEmpty) {
      String storedHash = result
          .first['password']; // Stored hash in the format $pbkdf2-sha256$...
      print("Stored hash: $storedHash");

      // Parse the stored hash into components
      final parts = storedHash.split(r'$');
      if (parts.length != 5) {
        print("Invalid hash format");
        return false;
      }

      final iterations = int.parse(parts[2]); // Number of iterations
      final salt = _fixBase64(parts[3]); // Decode salt after fixing the padding
      final storedKey = _fixBase64(parts[4]); // Decode the stored password hash

      // Derive the key from the provided password using the same parameters
      final derivedKey =
          _pbkdf2Sha256(password, salt, iterations, storedKey.length);

      // Compare the derived key to the stored key
      if (const ListEquality().equals(derivedKey, storedKey)) {
        print("Valid user found");
        return true;
      } else {
        print("No valid user found");
        return false;
      }
    } else {
      print("No valid user found");
      return false;
    }
  }

// Function to perform PBKDF2-HMAC-SHA256 key derivation
  Uint8List _pbkdf2Sha256(
      String password, Uint8List salt, int iterations, int keyLength) {
    final hmac = Hmac(sha256, utf8.encode(password)); // HMAC-SHA256
    Uint8List output = Uint8List(keyLength);
    List<int> buffer = [];

    int blockNum = 1;
    int numBlocks = (keyLength + sha256.blockSize - 1) ~/ sha256.blockSize;

    for (int i = 0; i < numBlocks; i++) {
      buffer = _pbkdf2F(hmac, salt, iterations, blockNum);
      for (int j = 0;
          j < buffer.length && j < output.length - (i * sha256.blockSize);
          j++) {
        output[i * sha256.blockSize + j] = buffer[j];
      }
      blockNum++;
    }
    return output;
  }

  List<int> _pbkdf2F(
      Hmac hmac, Uint8List salt, int iterations, int blockIndex) {
    var block = hmac.convert(salt + _int32ToBytes(blockIndex)).bytes;

    List<int> xorResult = block.toList();

    for (int i = 1; i < iterations; i++) {
      block = hmac.convert(block).bytes;
      for (int j = 0; j < xorResult.length; j++) {
        xorResult[j] ^= block[j];
      }
    }

    return xorResult;
  }

  Uint8List _int32ToBytes(int value) {
    var bytes = Uint8List(4);
    bytes[0] = (value >> 24) & 0xff;
    bytes[1] = (value >> 16) & 0xff;
    bytes[2] = (value >> 8) & 0xff;
    bytes[3] = value & 0xff;
    return bytes;
  }

// Helper function to fix base64 padding
  Uint8List _fixBase64(String base64String) {
    base64String = base64String.replaceAll('.', '+');
    // Only keep valid Base64 characters (A-Z, a-z, 0-9, +, /)
    base64String = base64String.replaceAll(RegExp(r'[^A-Za-z0-9+/=]'), '');

    // Ensure the length is a multiple of 4 by adding '=' padding if necessary
    switch (base64String.length % 4) {
      case 1:
        base64String += '===';
        break;
      case 2:
        base64String += '==';
        break;
      case 3:
        base64String += '=';
        break;
    }
    print("base64s${base64.decode(base64String)}");
    return base64.decode(base64String);
  }

  Future<void> insertSalesItems(List<Map<String, dynamic>> orderedItems,
      String invoiceNo, String customerName) async {
    print("Inside insertSalesItems for customer: $customerName");

    final db = await database;

    // Iterate over each ordered item and insert into the DB_sales_items table
    for (var item in orderedItems) {
      await db.insert(
        'DB_sales_items',
        {
          'item_code': item['item_code'],
          'item_name': item['item_name'],
          'item_description': item['item_description'],
          'item_group': item['item_group'],
          'item_image': item['item_image'],
          'item_uom': item['item_uom'],
          'base_rate': item['base_rate'],
          'base_amount': item['base_amount'],
          'net_rate': item['net_rate'],
          'net_amount': item['net_amount'],
          'pricing_rules': item['pricing_rules'],
          'is_free_item': item['is_free_item'] == true ? 1 : 0,
          'item_tax_rate': item['item_tax_rate'].toString(),
          'invoice_no': invoiceNo, // Invoice number for tracking the sale
          'customer_name':
              customerName, // Add customer name to track sale by customer
        },
        conflictAlgorithm:
            ConflictAlgorithm.abort, // Replace if a conflict occurs
      );
    }

    print("Items inserted into DB_sales_items for invoice: $invoiceNo");
  }

// Define your API URL
  // String apiUrl =
  //     'http://143.110.187.133:82/api/method/duplex_dev.api.sales_invoice_item.get_invoice_item_details';
  String apiUrl =
      "http://143.110.187.133:82/api/resource/Sales%20Invoice?fields=[%22*%22]";

  // Future<void> postSalesItemsToApi(
  //   List<Map<String, dynamic>> items,
  //   String apiKey,
  //   String secretKey,
  // ) async {
  //   print("solditemsmap inpost $items");
  //   // Create Basic Authentication header
  //   String basicAuth =
  //       'Basic ' + base64Encode(utf8.encode('$apiKey:$secretKey'));

  //   print("basicAuth$basicAuth");

  //   try {
  //     final response = await http.post(
  //       Uri.parse(apiUrl),
  //       headers: {
  //         'Authorization': basicAuth, // Set Basic Auth header
  //         'Content-Type': 'application/json',
  //       },
  //       body:
  //           jsonEncode({'message': items}), // Convert the list of maps to JSON
  //     );
  //     print("url$apiUrl");
  //     print(jsonEncode({'messaged': items}));

  //     if (response.statusCode == 200) {
  //       print("response${response.body}");
  //       print('Sales items posted to API successfully.');
  //     } else {
  //       print('Failed to post sales items to API. ${response.statusCode}');
  //     }
  //   } catch (e) {
  //     print('Error posting sales items to API: $e');
  //   }
  // }

  Future<String> getNextInvoiceNumber() async {
    final db = await database;

    // Retrieve current invoice number
    var result =
        await db.query('invoice_counter', where: 'id = ?', whereArgs: [1]);
    if (result.isEmpty) {
      // Initialize if not present
      await db
          .insert('invoice_counter', {'id': 1, 'current_invoice_number': 1});
      result =
          await db.query('invoice_counter', where: 'id = ?', whereArgs: [1]);
    }

    int currentNumber = result.first['current_invoice_number'] as int;
    int nextNumber = currentNumber + 1;

    // Update the counter in the database
    await db.update(
      'invoice_counter',
      {'current_invoice_number': nextNumber},
      where: 'id = ?',
      whereArgs: [1],
    );

    // Return the new invoice number formatted
    return 'ACC-SINV-2024-${nextNumber.toString().padLeft(5, '0')}';
  }

  Future<void> postSalesItemsToApi(
    List<Map<String, dynamic>> items,
    String apiKey,
    String secretKey,
  ) async {
    print("=== Initiating Sales Items Post to API ===");

    // Step 1: Verify the API URL
    if (!apiUrl.startsWith("http")) {
      print("Error: Invalid API URL. The URL should start with http or https.");
      return;
    }
    print("API URL: $apiUrl");

    // Step 2: Create Basic Authentication header
    String basicAuth =
        'Basic ' + base64Encode(utf8.encode('$apiKey:$secretKey'));
    print("Basic Authentication Header: $basicAuth");

    // Step 3: Prepare the payload
    // String payload;
    String payload = jsonEncode({
      'message': items.map((item) {
        return {
          ...item,
          'base_write_off_amount': 0.0, // Default value
        };
      }).toList()
    });
    try {
      payload = jsonEncode({'message': items});
      print("Payload to be sent: $payload");
    } catch (e) {
      print("Error encoding payload: $e");
      return;
    }

    // Step 4: Measure the response time
    final stopwatch = Stopwatch()..start();

    try {
      // Step 5: Make the API request
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Authorization': basicAuth, // Set Basic Auth header
          'Content-Type': 'application/json',
        },
        body: payload,
      );

      stopwatch.stop();
      print("API request completed in ${stopwatch.elapsedMilliseconds} ms");

      // Step 6: Check for status code and response
      if (response.statusCode == 200) {
        print("Success: API returned status code 200");
        try {
          final responseBody = jsonDecode(response.body);
          print("Response Body: ${jsonEncode(responseBody)}");
        } catch (e) {
          print("Error parsing API response: $e");
        }

        // Step 7: Check for expected data in response (customize based on API)
        if (response.body.contains('item_code')) {
          print("Item details found in the API response.");
        } else {
          print("Warning: Item details are missing in the API response.");
        }
      } else {
        print("Error: API returned status code ${response.statusCode}");
        print("Response Body: ${response.body}");
      }
    } catch (e) {
      print("Error during API request: $e");
    }

    // Step 8: Check if the request was too slow
    if (stopwatch.elapsedMilliseconds > 2000) {
      print("Warning: The API request took more than 2 seconds.");
    }

    print("=== Sales Items Post to API Complete ===");
  }
}
