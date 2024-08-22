import 'dart:io';

import 'package:flutter_pos_app/model/form_data.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

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

    // Directory documentsDirectory = await getApplicationDocumentsDirectory();
    // String path = join(documentsDirectory.path, 'Db_bizdot.db'); // Proper path

    print('Database path: $path');

    try {
      final db = await openDatabase(
        path,
        version: 1,
        onCreate: _onCreate, // Called only if the database is being created
      );
      print("Database opened successfully: $db");
      return db;
    } catch (e) {
      print("Error opening database: $e");
      throw e;
    }
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE DB_company (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        companyName TEXT,
        companyId TEXT,
        contactNumber TEXT,
        company TEXT,
        emailId TEXT,
        online BOOLEAN
      )
    ''');
  }

  Future<int> insertOfflineData(FormData formData) async {
    print("Inside insertOfflineData");
    try {
      final db = await database;
      if (db != null) {
        print("Database initialized: $db");
        print("formdataa ${formData.toMap()}");
        return await db.insert('DB_company', formData.toMap());
      } else {
        print("Database is null");
        return -1; // Indicate failure
      }
    } catch (e) {
      print("Error accessing database: $e");
      return -1; // Indicate failure
    }
  }

  // Future<int> insertOfflineData(FormData formData) async {
  //   print("Inside insertOfflineData");
  //   try {
  //     final db = await database;
  //     if (db != null) {
  //       print("Database initialized: $db");
  //       print("formdataa ${formData.toMap()}");
  //       int result = await db.insert('DB_company', formData.toMap());
  //       print("Insert result: $result");

  //       // Fetch and print all data after insertion
  //       await printAllData();

  //       return result;
  //     } else {
  //       print("Database is null");
  //       return -1; // Indicate failure
  //     }
  //   } catch (e) {
  //     print("Error accessing database: $e");
  //     return -1; // Indicate failure
  //   }
  // }

  Future<List<Map<String, dynamic>>> getAllOfflineData() async {
    final db = await database;
    return await db.query('DB_company');
  }

  Future<void> printAllData() async {
    final db = await database;
    final List<Map<String, dynamic>> result = await db.query('DB_company');
    print("All rows in DB_company: $result");
  }
}
