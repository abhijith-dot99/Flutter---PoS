import 'package:flutter/material.dart';
import 'package:flutter_pos_app/database/database_helper.dart';

class ShopConfigPage extends StatefulWidget {
  const ShopConfigPage({Key? key}) : super(key: key);

  @override
  State<ShopConfigPage> createState() => _ShopConfigPageState();
}

class _ShopConfigPageState extends State<ShopConfigPage> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _salesItems = [];

  // Function to fetch data from DB_sales_items based on invoice_no from the search input
  Future<void> _fetchSalesItems() async {
    String invoiceNo = _searchController.text.trim();
    print("invoiceno$invoiceNo");
    if (invoiceNo.isEmpty) return;

    final dbHelper = DatabaseHelper();
    List<Map<String, dynamic>> items =
        await dbHelper.fetchSalesReturnItems(invoiceNo);
    print("items$items");

    setState(() {
      _salesItems = items;
    });
  }

  // Function to update item_count in the database (placeholder function)
  // Future<void> _updateItemCount(int id, int newCount , int baseRate, int baseAmount, int netRate, int netAmount) async {
  Future<void> _updateItemCount(int id, int newCount, double newBaseAmount) async {
    print("inside update");
    final dbHelper = DatabaseHelper();
    await dbHelper.updateItemCountinDb(id, newCount, newBaseAmount);
    _fetchSalesItems(); // Refresh data after update
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(155, 239, 241, 241),
        elevation: 0,
        title: const Text(
          'Shop Config',
          style: TextStyle(
            color: Colors.black87,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.black54),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Enter Invoice No...',
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
                ),
                IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: _fetchSalesItems, // Trigger search
                ),
              ],
            ),
            const SizedBox(height: 20),
            Expanded(
              child: _salesItems.isEmpty
                  ? const Center(child: Text('No items found'))
                  : ListView.builder(
                      itemCount: _salesItems.length,
                      itemBuilder: (context, index) {
                        final item = _salesItems[index];
                        return ListTile(
                          // title: Text(item['item_name']),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("id: ${item['id']}"),
                              Text("item: ${item['item_name']}"),
                              Text("Code: ${item['item_code']}"),
                              Text("Customer: ${item['customer_name']}"),
                              Text("Date: ${item['date']}"),
                            ],
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text('Count: ${item['item_count']}'),
                              IconButton(
                                icon: const Icon(Icons.edit),
                                onPressed: () async {
                                  final result = await _editItemCountDialog(
                                      item['item_count'], item['base_amount']);
                                  print("results$result");

                                  if (result != null) {
                                    int? newCount = result['newCount'];
                                    double? newBaseAmount =
                                        result['newBaseAmount'];

                                    print("newocunt$newCount");
                                    print("newbaseamount$newBaseAmount");

                                    if (newCount != null &&
                                        newBaseAmount != null) {
                                      await _updateItemCount(
                                          item['id'], newCount, newBaseAmount );
                                      print("New count: $newCount");
                                      print("New base amount: $newBaseAmount");
                                      print("id: ${item['id']}");
                                    }
                                  }
                                },
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  // Dialog to edit item count
  Future<Map<String, dynamic>?> _editItemCountDialog(
      int currentCount, double baseAmount) async {
    int? newCount = currentCount;
    double? newBaseAmount = baseAmount;

    return showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Item Count'),
          content: TextField(
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Enter new count',
            ),
            onChanged: (value) {
              newCount = int.tryParse(value);
              if (newCount != null && newCount! > 0) {
                newBaseAmount = baseAmount * newCount! / currentCount;
                // newBaseAmount = baseAmount / newCount!;
              }
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, null),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, {
                'newCount': newCount,
                'newBaseAmount': newBaseAmount,
              }),
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }
}
