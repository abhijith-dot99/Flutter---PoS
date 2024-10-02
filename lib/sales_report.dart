import 'package:flutter/material.dart';
import 'package:flutter_pos_app/database/database_helper.dart';
import 'package:flutter_pos_app/model/SaleItem.dart';

class SalesReport extends StatefulWidget {
  const SalesReport({super.key});

  @override
  _SalesReportState createState() => _SalesReportState();
}

class _SalesReportState extends State<SalesReport> {
  List<SalesItem> salesItems = [];  // Change Item to SalesItem

  @override
  void initState() {
    super.initState();
    _fetchSalesItems();
  }

  Future<void> _fetchSalesItems() async {
    final dbHelper = DatabaseHelper();
    final items = await dbHelper.fetchSalesItems();  // Ensure this returns List<SalesItem>
    setState(() {
      salesItems = items;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sales Report'),
      ),
      body: salesItems.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,  // Enable vertical scrolling
                child: DataTable(
                  columnSpacing: 10,  // Reduce spacing between columns
                  dataRowMinHeight: 40,  // Reduce row height
                  dataRowMaxHeight: 50,  // Set max row height
                  border: const TableBorder(
                    horizontalInside: BorderSide(width: 1, color: Colors.grey),  // Horizontal lines
                    verticalInside: BorderSide(width: 1, color: Colors.grey),  // Vertical lines
                  ),
                  columns: const [
                    DataColumn(label: Text('ID')),
                    DataColumn(label: Text('Item Code')),
                    DataColumn(label: Text('Item Name')),
                    DataColumn(label: Text('Description')),
                    DataColumn(label: Text('Group')),
                    DataColumn(label: Text('Image')),
                    DataColumn(label: Text('UOM')),
                    DataColumn(label: Text('Base Rate')),
                    DataColumn(label: Text('Base Amount')),
                    DataColumn(label: Text('Net Rate')),
                    DataColumn(label: Text('Net Amount')),
                    DataColumn(label: Text('Pricing Rules')),
                    DataColumn(label: Text('Is Free Item')),
                    DataColumn(label: Text('Tax Rate')),
                    DataColumn(label: Text('Invoice No')),
                    DataColumn(label: Text('Customer Name')),
                    DataColumn(label: Text('Count')),
                  ],
                  rows: salesItems.map((item) {
                    return DataRow(cells: [
                      DataCell(Text(item.id.toString())),
                      DataCell(Text(item.itemCode)),
                      DataCell(Text(item.itemName)),
                      DataCell(Text(item.itemDescription)),
                      DataCell(Text(item.itemGroup)),
                      DataCell(Text(item.itemImage)),
                      DataCell(Text(item.itemUom)),
                      DataCell(Text(item.baseRate.toString())),
                      DataCell(Text(item.baseAmount.toString())),
                      DataCell(Text(item.netRate.toString())),
                      DataCell(Text(item.netAmount.toString())),
                      DataCell(Text(item.pricingRules)),
                      DataCell(Text(item.isFreeItem ? 'Yes' : 'No')),
                      DataCell(Text(item.itemTaxRate.toString())),
                      DataCell(Text(item.invoiceNo)),
                      DataCell(Text(item.customerName)),
                      DataCell(Text(item.itemCount.toString())),
                    ]);
                  }).toList(),
                ),
              ),
            ),
    );
  }
}
