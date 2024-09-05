import 'dart:io';

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
    final db = await database;
    final List<Map<String, dynamic>> result = await db.query(
      'DB_company',
      columns: ['companyName'],
    );
    return result.map((row) => row['companyName'] as String).toList();
  }

  Future<bool> validateUser(
      String username, String password, String company) async {
    print("insdie validateuer function");
    print("username $username");
    print("password $password");
    print("company$company");
    final db = await database;
    final List<Map<String, dynamic>> result = await db.query(
      'DB_users',
      where: 'username = ? AND password = ? AND companyName = ?',
      whereArgs: [username, password, company],
    );
    if (result.isNotEmpty) {
      print("Valid user found");
      return true;
    } else {
      print("No valid user found");
      return false;
    }
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
  }

  Future<int> insertOfflineData(FormData formData) async {
    print("Inside insertOfflineData");
    try {
      final db = await database;
      if (db != null) {
        print("Database initialized: $db");

        Map<String, dynamic> companyData = {
          'company_name': formData.companyName,
          'owner':
              formData.owner, // Assuming you have this field in your formData
          'abbr':
              formData.abbr, // Assuming you have this field in your formData
          'country':
              formData.country, // Assuming you have this field in your formData
          'vat_number': formData
              .vatNumber, // Assuming you have this field in your formData
          'phone_no': formData.contactNumber,
          'email': formData.emailId,
          'website':
              formData.website, // Assuming you have this field in your formData
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
      } else {
        print("Database is null");
        return -1; // Indicate failure
      }
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

  Future<List<Item>> getItems() async {
    try {
      final db = await database;
      // print("Database accessed: $db");
      final List<Map<String, dynamic>> result = await db.query('DB_items');
      print("Items fetched: $result");
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
    final db = await database;
    await db.insert(
      'DB_customer',
      customer.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
}
