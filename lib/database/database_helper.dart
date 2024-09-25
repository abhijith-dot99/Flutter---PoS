import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter_pos_app/model/company.dart';
import 'package:flutter_pos_app/model/companyy.dart';
import 'package:flutter_pos_app/model/customer.dart';
import 'package:flutter_pos_app/model/form_data.dart';
import 'package:flutter_pos_app/model/item.dart';
import 'package:flutter_pos_app/model/itemData.dart';
import 'package:flutter_pos_app/model/supplier.dart';
import 'package:flutter_pos_app/model/tax.dart';
import 'package:flutter_pos_app/model/users.dart';
import 'package:flutter_pos_app/model/userss.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:crypto/crypto.dart';
import 'package:collection/collection.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
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

  Future<Database> _initDatabase() async {
    String path;

    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      print("insde windows");
      // Desktop: Use sqflite_common_ffi for database initialization

      sqfliteFfiInit();
      var databaseFactory = databaseFactoryFfi;

      // Get path to the documents directory for desktop platforms
      final directory = await getApplicationDocumentsDirectory();
      path = join(directory.path, 'DB_My.db');
      print("Database Path windows: $path");

      // Open the database and create tables
      var db = await databaseFactory.openDatabase(path);

      await _onCreate(db, 1);
      return db;
    } else if (Platform.isAndroid || Platform.isIOS) {
      print("insde android");
      // Mobile: Use regular sqflit
      path = join(await getDatabasesPath(), 'DB_My.db');
      print("Database Path android: $path");
      return await openDatabase(path, version: 1, onCreate: _onCreate);
    } else {
      throw Exception('Platform not supported');
    }
  }

  Future<void> _onCreate(Database db, int version) async {
    print("inside oncreate");
    // Create the DB_company table
    // Create DB_company table
    await db.execute('''
    CREATE TABLE IF NOT EXISTS DB_company (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
      company_name TEXT ,
      owner TEXT,
      abbr TEXT,
      country TEXT,
      vat_number TEXT,
      phone_no TEXT,
      email TEXT,
      website TEXT,
      apikey TEXT,
      secretkey TEXT,
      url TEXT,
      companyId TEXT,
      online INTEGER DEFAULT 0
    )
  ''');

    // Create DB_users table
    await db.execute('''
    CREATE TABLE IF NOT EXISTS DB_users (
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

    // Create DB_sales_invoice table
    await db.execute('''
    CREATE TABLE IF NOT EXISTS DB_sales_invoice (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT,
      owner TEXT,
      creation TEXT,
      modified TEXT,
      modified_by TEXT,
      docstatus INTEGER,
      idx INTEGER,
      ksa_einv_qr TEXT,
      title TEXT,
      custom_invoice_type TEXT,
      naming_series TEXT,
      customer TEXT,
      customer_name TEXT,
      customer_name_in_arabic TEXT,
      tax_id TEXT,
      company TEXT,
      company_tax_id TEXT,
      posting_date TEXT,
      posting_time TEXT,
      set_posting_time INTEGER,
      due_date TEXT,
      is_pos INTEGER,
      pos_profile TEXT,
      is_consolidated INTEGER,
      is_return INTEGER,
      return_against TEXT,
      update_outstanding_for_self INTEGER,
      update_billed_amount_in_sales_order INTEGER,
      update_billed_amount_in_delivery_note INTEGER,
      is_debit_note INTEGER,
      amended_from TEXT,
      cost_center TEXT,
      project TEXT,
      currency TEXT,
      conversion_rate REAL,
      selling_price_list TEXT,
      price_list_currency TEXT,
      plc_conversion_rate REAL,
      ignore_pricing_rule INTEGER,
      scan_barcode TEXT,
      update_stock INTEGER,
      set_warehouse TEXT,
      set_target_warehouse TEXT,
      total_qty INTEGER,
      total_net_weight REAL,
      base_total REAL,
      base_net_total REAL,
      total REAL,
      net_total REAL,
      tax_category TEXT,
      taxes_and_charges TEXT,
      shipping_rule TEXT,
      incoterm TEXT,
      named_place TEXT,
      base_total_taxes_and_charges REAL,
      total_taxes_and_charges REAL,
      base_grand_total REAL,
      base_rounding_adjustment REAL,
      base_rounded_total REAL,
      base_in_words TEXT,
      grand_total REAL,
      rounding_adjustment REAL,
      use_company_roundoff_cost_center INTEGER,
      rounded_total REAL,
      in_words TEXT,
      total_advance REAL,
      outstanding_amount REAL,
      disable_rounded_total INTEGER,
      apply_discount_on TEXT,
      base_discount_amount REAL,
      is_cash_or_non_trade_discount INTEGER,
      additional_discount_account TEXT,
      additional_discount_percentage REAL,
      discount_amount REAL,
      other_charges_calculation TEXT,
      total_billing_hours REAL,
      total_billing_amount REAL,
      cash_bank_account TEXT,
      base_paid_amount REAL,
      paid_amount REAL,
      base_change_amount REAL,
      change_amount REAL,
      account_for_change_amount TEXT,
      allocate_advances_automatically INTEGER,
      only_include_allocated_payments INTEGER,
      write_off_amount REAL,
      base_write_off_amount REAL,
      write_off_outstanding_amount_automatically INTEGER,
      write_off_account TEXT,
      write_off_cost_center TEXT,
      redeem_loyalty_points INTEGER,
      loyalty_points REAL,
      loyalty_amount REAL,
      loyalty_program TEXT,
      loyalty_redemption_account TEXT,
      loyalty_redemption_cost_center TEXT,
      customer_address TEXT,
      address_display TEXT,
      contact_person TEXT,
      contact_display TEXT,
      contact_mobile TEXT,
      contact_email TEXT,
      territory TEXT,
      shipping_address_name TEXT,
      shipping_address TEXT,
      dispatch_address_name TEXT,
      dispatch_address TEXT,
      company_address TEXT,
      company_trn TEXT,
      company_address_display TEXT,
      ignore_default_payment_terms_template INTEGER,
      payment_terms_template TEXT,
      tc_name TEXT,
      terms TEXT,
      po_no TEXT,
      po_date TEXT,
      debit_to TEXT,
      party_account_currency TEXT,
      is_opening TEXT,
      unrealized_profit_loss_account TEXT,
      against_income_account TEXT,
      sales_partner TEXT,
      amount_eligible_for_commission REAL,
      commission_rate REAL,
      total_commission REAL,
      letter_head TEXT,
      group_same_items INTEGER,
      select_print_heading TEXT,
      language TEXT,
      subscription TEXT,
      from_date TEXT,
      auto_repeat TEXT,
      to_date TEXT,
      status TEXT,
      inter_company_invoice_reference TEXT,
      campaign TEXT,
      represents_company TEXT,
      source TEXT,
      customer_group TEXT,
      is_internal_customer INTEGER,
      is_discounted INTEGER,
      remarks TEXT
    )
  ''');

    // Create DB_suppliers table
    await db.execute('''
    CREATE TABLE IF NOT EXISTS DB_suppliers (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      supplier_name TEXT NOT NULL,
      type TEXT NOT NULL,
      company_name TEXT NOT NULL,
      supplier_group TEXT,
      vat_number TEXT,
      phone_no TEXT,
      email TEXT,
      country TEXT
    )
  ''');

    // Create DB_customer table
    await db.execute('''
    CREATE TABLE IF NOT EXISTS DB_customer (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      customer_name TEXT NOT NULL,
      type TEXT NOT NULL,
      company_name TEXT NOT NULL,
      customer_group TEXT,
      vat_number TEXT,
      phone_no TEXT,
      email TEXT
    )
  ''');

    // Create DB_sales_items table
    await db.execute('''
    CREATE TABLE IF NOT EXISTS DB_sales_items (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      item_code TEXT,
      item_name TEXT,
      item_description TEXT,
      item_group TEXT,
      item_image TEXT,
      item_uom TEXT,
      base_rate REAL,
      base_amount REAL,
      net_rate REAL,
      net_amount REAL,
      pricing_rules TEXT,
      is_free_item INTEGER DEFAULT 0,
      item_tax_rate TEXT,
      invoice_no TEXT,
      customer_name TEXT,
      item_count INTEGER
    )
  ''');

    // Create DB_items table
    await db.execute('''
    CREATE TABLE IF NOT EXISTS DB_items (
      item_code TEXT PRIMARY KEY,
      item_name TEXT,
      item_price TEXT,
      item_tax TEXT,
      item_group TEXT,
      company_name TEXT,
      warehouse TEXT,
      item_price_list TEXT,
      uom TEXT,
      item_tax_type TEXT
    )
  ''');

    // Create DB_sales_tax table
    await db.execute('''
    CREATE TABLE IF NOT EXISTS DB_sales_tax (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      tax_name TEXT NOT NULL,
      title TEXT NOT NULL,
      company_name TEXT NOT NULL,
      charge_type TEXT NOT NULL,
      account_head TEXT NOT NULL,
      description TEXT,
      rate REAL NOT NULL,
      is_inclusive INTEGER DEFAULT 0
    )
  ''');

    // Create invoice_counter table
    await db.execute('''
    CREATE TABLE IF NOT EXISTS invoice_counter (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      current_invoice_number INTEGER
    )
  ''');

    // Initialize the invoice counter if it's empty
    var result = await db.query('invoice_counter');
    if (result.isEmpty) {
      await db
          .insert('invoice_counter', {'id': 1, 'current_invoice_number': 1});
    }

    var tables =
        await db.rawQuery('SELECT name FROM sqlite_master WHERE type="table"');
    print('Tables created: $tables');
  }

  Future<int> insertOfflineData(FormData formData) async {
    print("Inside insertOfflineData");
    try {
      final db = await database;
      print("Database initialized: $db");

      Map<String, dynamic> companyData = {
        'company_name': formData.companyName,
        'owner':
            formData.owner, // Assuming you have this field in your formData
        'abbr': formData.abbr, // Assuming you have this field in your formData
        'country':
            formData.country, // Assuming you have this field in your formData
        'vat_number':
            formData.vatNumber, // Assuming you have this field in your formData
        'phone_no': formData.contactNumber,
        'email': formData.emailId,
        'website':
            formData.website, // Assuming you have this field in your formData
        'online': formData.online ? 1 : 0,
        'apikey': formData.apikey,
        'secretkey': formData.secretkey,
        'url': formData.url,
        'companyId': formData.companyId,
      };
      print("FormData online value: ${formData.online}");

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

  Future<List<String>> getCompanyNames() async {
    print("inside getCompany");

    final db = await database;
    // Query to fetch distinct company names
    final List<Map<String, dynamic>> result = await db.rawQuery(
      'SELECT DISTINCT company_name FROM DB_company WHERE company_name IS NOT NULL AND company_name != ""',
    );

    // Map the result to a list of company names
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

  Future<void> printAllData() async {
    final db = await database;
    final List<Map<String, dynamic>> result = await db.query('DB_company');
    print("All rows in DB_company: $result");
  }

  Future<List<Item>> getItems(String selectedCompanyName) async {
    try {
      final db = await database;
      double companyTax = await getCompanyTax(selectedCompanyName);

      print("companytax$companyTax");
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

  // Future<void> getTax(Tax tax) async {
  //   print("insde gettax");
  //   final db = await database;
  //   await db.insert(
  //     'DB_sales_tax',
  //     tax.toMap(),
  //     conflictAlgorithm: ConflictAlgorithm.replace,
  //   );
  // }

  Future<void> getTax(Tax tax) async {
    print("inside getTax");
    final db = await database;

    // Check if the tax record with the same company name already exists
    var result = await db.query(
      'DB_sales_tax',
      where: 'company_name = ?',
      whereArgs: [
        tax.companyName
      ], // assuming 'companyName' is a field in your Tax object
    );

    if (result.isEmpty) {
      // Insert only if the company name doesn't exist
      await db.insert(
        'DB_sales_tax',
        tax.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      print('New tax data inserted for company: ${tax.companyName}');
    } else {
      print('Tax data for this company already exists: ${tax.companyName}');
    }
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

//   ///newchanges
  Future<bool> validateUser(
      String username, String password, String company) async {
    print("inside validateUser function");
    print("username $username");
    print("company $company");
    print("password $password");

    if (username.isEmpty) {
      print("Username is null or empty");
      return false;
    }
    if (password.isEmpty) {
      print("Password is null or empty");
      return false;
    }
    if (company.isEmpty) {
      print("Company is null or empty");
      return false;
    }

    // Retrieve the stored password from the database
    final db = await database;
    final List<Map<String, dynamic>> result = await db.query(
      'DB_users',
      where: 'username = ? AND company_name = ?',
      whereArgs: [username, company],
    );

    if (result.isNotEmpty) {
      String storedPassword =
          result.first['password']; // Stored password or hash
      print("Stored password: $storedPassword");

      // Check if the stored password is hashed (starts with "$pbkdf2-sha256$")
      if (storedPassword.startsWith(r'$pbkdf2-sha256$')) {
        // Perform PBKDF2 hash comparison
        print("Performing hash-based validation");

        // Parse the stored hash into components
        final parts = storedPassword.split(r'$');
        if (parts.length != 5) {
          print("Invalid hash format");
          return false;
        }

        final iterations = int.parse(parts[2]); // Number of iterations
        final salt =
            _fixBase64(parts[3]); // Decode salt after fixing the padding
        final storedKey =
            _fixBase64(parts[4]); // Decode the stored password hash

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
        // Perform direct string comparison (non-hashed password)
        print("Performing direct string validation");
        if (storedPassword == password) {
          print("Valid user found");
          return true;
        } else {
          print("No valid user found");
          return false;
        }
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
    base64String = base64String.replaceAll(RegExp(r'[^A-Za-z0-9+/=]'), '');

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
    return base64.decode(base64String);
  }

  Future<void> insertSalesItems(List<Map<String, dynamic>> orderedItems,
      String invoiceNo, String customerName) async {
    print("Inside insertSalesItems for customer: $customerName");

    final db = await database;
    print("itemsss$orderedItems");

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
          'item_count': item['item_count'],
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

  Future<int> getOnlineStatus(String companyName) async {
    try {
      final db = await database;

      // Query to check if the company_name exists in the DB_company table
      var result = await db.rawQuery('''
      SELECT online FROM DB_company WHERE company_name = ?
    ''', [companyName]);

      if (result.isNotEmpty) {
        return result.first['online'] as int;
      } else {
        return 2; // Default to offline if no result
      }
    } catch (e, stacktrace) {
      print('Error querying online status: $e');
      print('Stacktrace: $stacktrace');
      return 2; // Return default value in case of error
    }
  }

  Future<Map<String, String?>> getApiKeysByCompanyName(
      String companyName) async {
    final db = await database;
    // Query to fetch API Key and Secret Key based on company_name
    List<Map<String, dynamic>> result = await db.query(
      'DB_company',
      columns: ['apikey', 'secretkey'],
      where: 'company_name = ?',
      whereArgs: [companyName],
    );

    // Check if any result was found
    if (result.isNotEmpty) {
      // Extract the API key and Secret key from the result
      String? apiKey = result[0]['apikey'] as String?;
      String? secretKey = result[0]['secretkey'] as String?;
      print('apikeyy$apiKey');
      print('secretKeyy$secretKey');
      return {'apiKey': apiKey, 'secretKey': secretKey};
    } else {
      // If no result is found, return null values
      print('Error: No API keys found for the given company name.');
      return {'apiKey': null, 'secretKey': null};
    }
  }

  // Function to get API Key and Secret Key from DB_company using company_name

  get taxes => [];

  Future<List<Map<String, dynamic>>> fetchTaxesFromDB(
      String companyName) async {
    final db = await DatabaseHelper._instance.database;

    // Query the DB_sales_tax table for the selected company
    List<Map<String, dynamic>> result = await db.query(
      'DB_sales_tax',
      where: 'company_name = ?',
      whereArgs: [companyName],
    );

    // Return the list of tax details
    return result;
  }

  String apiUrl =
      "http://143.110.187.133:80/api/method/duplex_dev.api.make_sales_invoice.create_sales_invoice";

  Future<void> postSalesItemsToApi(
      List<Map<String, dynamic>> soldItemsMap,
      String apiKey,
      String secretKey,
      String customername, // Pass customername as parameter
      String companyname // Pass companyname as parameter
      ) async {
    // Step 1: Create Basic Authentication header
    String basicAuth =
        'Basic ' + base64Encode(utf8.encode('$apiKey:$secretKey'));

    // Step 2: Transform soldItemsMap into the API expected format
    List<Map<String, dynamic>> items = soldItemsMap.map((item) {
      return {
        'item_code': item['item_code'],
        'qty': item['item_count'],
        'rate': item['net_rate'],
      };
    }).toList();

    // Step 3: Fetch taxes for the selected company from the database
    List<Map<String, dynamic>> taxData = await fetchTaxesFromDB(companyname);

    // Format the taxes into the required structure
    List<Map<String, dynamic>> taxes = taxData.map((tax) {
      return {
        'tax_name': tax['tax_name'],
        'charge_type': tax['charge_type'],
        'account_head': tax['account_head'],
        'description': tax['description'],
        'rate': tax['rate'],
        'included_in_print_rate': tax['is_inclusive'],
      };
    }).toList();

// Extract 'tax_name' for the 'tax_template'
    String taxTemplate =
        taxes.isNotEmpty ? taxes[0]['tax_name'].toString() : '';

    // Step 4: Prepare the final payload
    Map<String, dynamic> payloadMap = {
      'naming_series': 'ACC-SINV-.YYYY.-',
      'customer': customername, // Use customername from parameter
      'items': items,
      'taxes': taxes, // Use taxes fetched from DB
      'tax_template': taxTemplate,
      'company': companyname, // Use companyname from parameter
    };

    String payload = jsonEncode(payloadMap);
    print("Payload to be sent: $payload");
    print("tax_template$taxTemplate");

    try {
      // Step 6: Make the API request
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Authorization': basicAuth, // Set Basic Auth header
          'Content-Type': 'application/json',
        },
        body: payload,
      );

      // Step 7: Check for status code and response
      if (response.statusCode == 200) {
        print("Success: API returned status code 200");
        try {
          final responseBody = jsonDecode(response.body);
          print("Response Body: ${jsonEncode(responseBody)}");
        } catch (e) {
          print("Error parsing API response: $e");
        }

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
    print("=== Sales Items Post to API Complete ===");
  }

  Future<double> fetchCompanyTax(String companyName) async {
    final db = await database;
    final List<Map<String, dynamic>> taxRecords = await db.rawQuery(
        'SELECT rate FROM DB_sales_tax WHERE company_name = ?',
        [companyName] // Replace with the correct tax name
        );

    if (taxRecords.isNotEmpty) {
      return taxRecords.first['rate'] as double;
    } else {
      return 0.0; // Default to 0 if no tax found
    }
  }

  Future<double> getCompanyTax(String companyName) async {
    print("getcompanytax$companyName");
    try {
      final db = await database;

      // Query the database for the tax associated with the company
      final List<Map<String, dynamic>> result = await db.query(
        'DB_sales_tax',
        where: 'company_name = ?',
        whereArgs: [companyName],
      );
      print("result$result");
      if (result.isNotEmpty) {
        // Get the tax rate (assuming the first result is correct)
        print("resultt${result.first['rate']}");
        return result.first['rate'] ?? 0.0;
      } else {
        return 0.0; // No tax for this company
      }
    } catch (e) {
      print("Error fetching company tax: $e");
      return 0.0; // Default to 0.0 in case of error
    }
  }
}
