import 'dart:async'; // For Timer
import 'package:flutter/material.dart';
import 'package:flutter_pos_app/database/database_helper.dart';
import 'package:flutter_pos_app/model/SaleItem.dart';
import 'package:intl/intl.dart'; // For date formatting

class SalesReport extends StatefulWidget {
  const SalesReport({super.key});

  @override
  _SalesReportState createState() => _SalesReportState();
}

class _SalesReportState extends State<SalesReport> {
  List<SalesItem> salesItems = []; // List to hold all sales items
  List<SalesItem> filteredSalesItems = []; // List to hold filtered sales items
  DateTime? fromDate; // Holds the selected 'From Date'
  DateTime? toDate; // Holds the selected 'To Date'
  bool isLoading = true; // Flag to control loading state
  bool showNothingHere = false; // Flag to show "Nothing here" after 5 seconds

  final TextEditingController searchController =
      TextEditingController(); // Search bar controller

  @override
  void initState() {
    super.initState();
    _fetchSalesItems(); // Fetch all items initially

    // Start the 5-second timer
    Timer(const Duration(seconds: 5), () {
      // After 5 seconds, check if we should show "Nothing here"
      if (mounted) {
        setState(() {
          isLoading = false; // Stop showing the CircularProgressIndicator
          if (filteredSalesItems.isEmpty) {
            showNothingHere = true; // Show "Nothing here" if no data is found
          }
        });
      }
    });
  }

  // Function to fetch sales items from the database
  Future<void> _fetchSalesItems() async {
    final dbHelper = DatabaseHelper();
    final items = await dbHelper.fetchSalesItems(); // Fetch all sales items
    if (mounted) {
      setState(() {
        salesItems = items;
        filteredSalesItems = items; // Initially, show all items
        isLoading = false; // Data loading is done
        showNothingHere =
            items.isEmpty; // If no items, prepare to show "Nothing here"
      });
    }
  }

  // Function to open Date Picker and select the 'From Date'
  Future<void> _selectFromDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: fromDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != fromDate) {
      setState(() {
        fromDate = picked;
      });
      _filterSalesItems(); // Trigger filtering after date selection
    }
  }

  // Function to open Date Picker and select the 'To Date'
  Future<void> _selectToDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: toDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != toDate) {
      setState(() {
        toDate = picked;
      });
      _filterSalesItems(); // Trigger filtering after date selection
    }
  }

  // Function to filter sales items between fromDate and toDate
  void _filterSalesItems() {
    setState(() {
      filteredSalesItems = salesItems.where((item) {
        final DateTime saleDate = DateTime.parse(item.date);
        final bool isInRange = fromDate != null && toDate != null
            ? saleDate.isAfter(fromDate!.subtract(const Duration(days: 1))) &&
                saleDate.isBefore(toDate!.add(const Duration(days: 1)))
            : true;

        final bool matchesSearch = item.customerName
            .toLowerCase()
            .contains(searchController.text.toLowerCase());

        return isInRange && matchesSearch;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sales Report'),
      ),
      body: Column(
        children: [
          // Row for the "From Date" and "To Date" buttons
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton(
                  onPressed: () => _selectFromDate(context),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.blue, // Text color
                    side: const BorderSide(
                        color: Colors.black, width: 1), // Border
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(10), // Rounded corners
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 10), // Padding
                  ),
                  child: Text(
                    fromDate == null
                        ? 'Select From'
                        : 'From: ${DateFormat('yyyy-MM-dd').format(fromDate!)}',
                    style: const TextStyle(
                      fontSize: 16, // Font size
                      fontWeight: FontWeight.bold, // Font weight
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () => _selectToDate(context),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.green, // Text color
                    side: const BorderSide(color: Colors.black, width: 1),
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(10), // Rounded corners
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 10), // Padding
                  ),
                  child: Text(
                    toDate == null
                        ? 'Select To'
                        : 'To: ${DateFormat('yyyy-MM-dd').format(toDate!)}',
                    style: const TextStyle(
                      fontSize: 16, // Font size
                      fontWeight: FontWeight.bold, // Font weight
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Search Bar with Padding and Adjustable Width
          Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: 8.0,
                vertical: 16.0), // Add vertical padding to create space
            child: SizedBox(
              width: MediaQuery.of(context).size.width *
                  0.92, // Adjust the width (90% of screen width)
              child: TextField(
                controller: searchController,
                decoration: InputDecoration(
                  labelText: 'Search by Customer Name',
                  labelStyle: const TextStyle(color: Colors.grey),
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                onChanged: (value) {
                  _filterSalesItems(); // Filter the table when search text changes
                },
              ),
            ),
          ),

          // Sales report table or message
          Expanded(
            child: isLoading
                ? const Center(
                    child:
                        CircularProgressIndicator()) // Show CircularProgressIndicator for 5 seconds
                : showNothingHere
                    ? const Center(
                        child: Text('Nothing here',
                            style: TextStyle(
                                fontSize:
                                    18))) // Show "Nothing here" if no data
                    : SingleChildScrollView(
                        scrollDirection:
                            Axis.horizontal, // Enable horizontal scrolling
                        child: SingleChildScrollView(
                          scrollDirection:
                              Axis.vertical, // Enable vertical scrolling
                          child: DataTable(
                            columnSpacing: 10, // Adjust spacing between columns
                            dataRowMinHeight: 40, // Adjust row height
                            dataRowMaxHeight: 50, // Set max row height
                            border: const TableBorder(
                              top: BorderSide(color: Colors.black, width: 1),
                              bottom: BorderSide(color: Colors.black, width: 1),
                              left: BorderSide(color: Colors.black, width: 1),
                              right: BorderSide(color: Colors.black, width: 1),
                              horizontalInside: BorderSide(
                                  color: Colors.grey,
                                  width: 1), // Horizontal borders
                              verticalInside: BorderSide(
                                  color: Colors.grey,
                                  width: 1), // Vertical borders
                            ),
                            columns: const [
                              DataColumn(
                                  label: Text('Item Code',
                                      textAlign: TextAlign.center)),
                              DataColumn(
                                  label: Text('Item Name',
                                      textAlign: TextAlign.center)),
                              DataColumn(
                                  label: Text('Description',
                                      textAlign: TextAlign.center)),
                              // DataColumn(
                              //     label: Text('Group',
                              //         textAlign: TextAlign.center)),
                                         DataColumn(
                                  label: Text('Count',
                                      textAlign: TextAlign.center)),
                              DataColumn(
                                  label: Text('Base Rate',
                                      textAlign: TextAlign.center)),
                              DataColumn(
                                  label: Text('Base Amount',
                                      textAlign: TextAlign.center)),
                              DataColumn(
                                  label: Text('Net Rate',
                                      textAlign: TextAlign.center)),
                              DataColumn(
                                  label: Text('Net Amount',
                                      textAlign: TextAlign.center)),
                              DataColumn(
                                  label: Text('Is Free Item',
                                      textAlign: TextAlign.center)),
                              DataColumn(
                                  label: Text('Tax Rate',
                                      textAlign: TextAlign.center)),
                              DataColumn(
                                  label: Text('Invoice No',
                                      textAlign: TextAlign.center)),
                              DataColumn(
                                  label: Text('Customer Name',
                                      textAlign: TextAlign.center)),
                              DataColumn(
                                  label: Text('Date',
                                      textAlign: TextAlign.center)),
                                          DataColumn(
                                  label: Text('Discount',
                                      textAlign: TextAlign.center))
                            ],
                            rows: filteredSalesItems
                                .map(
                                  (item) => DataRow(
                                    cells: [
                                      DataCell(Text(item.itemCode)),
                                      DataCell(Text(item.itemName)),
                                      DataCell(Text(item.itemDescription)),
                                      // DataCell(Text(item.itemGroup)),
                                      DataCell(Text(item.itemCount.toString())),
                                      DataCell(Text(item.baseRate.toString())),
                                      DataCell(
                                          Text(item.baseAmount.toString())),
                                      DataCell(Text(item.netRate.toString())),
                                      DataCell(Text(item.netAmount.toString())),
                                      DataCell(
                                          Text(item.isFreeItem ? 'Yes' : 'No')),
                                      DataCell(
                                          Text(item.itemTaxRate.toString())),
                                      DataCell(Text(item.invoiceNo)),
                                      DataCell(Text(item.customerName)),
                                      DataCell(Text(item.date)),
                                       DataCell(Text(item.discount.toString())),
                                    ],
                                  ),
                                )
                                .toList(),
                          ),
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}
