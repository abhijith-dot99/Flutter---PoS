import 'package:flutter/material.dart';
import 'model/item.dart';

class HoldingBillPage extends StatefulWidget {
  final List<HeldBill> heldBills; // List of held bills
  final VoidCallback storeOrderedItems;
  final VoidCallback clearOrderedItems;
  final VoidCallback fetchStoredItems;

  const HoldingBillPage({
    Key? key,
    required this.heldBills,
    required this.storeOrderedItems,
    required this.clearOrderedItems,
    required this.fetchStoredItems,
  }) : super(key: key);

  @override
  _HoldingBillPageState createState() => _HoldingBillPageState();
}

class _HoldingBillPageState extends State<HoldingBillPage> {
  void _restoreBill(HeldBill bill) {
    widget.clearOrderedItems(); // Clear current items
    setState(() {
      // Restore the selected bill's items
      for (var item in bill.items) {
        widget.fetchStoredItems(); // Restore the items
      }
    });
    Navigator.pop(context); // Go back to previous screen
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Held Bills'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: () {
              widget.storeOrderedItems(); // Store the current ordered items
              widget.clearOrderedItems(); // Clear the ordered items
            },
          ),
          IconButton(
            icon: const Icon(Icons.restore),
            onPressed: () {
              widget.fetchStoredItems(); // Fetch the stored ordered items
            },
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: widget.heldBills.length,
        itemBuilder: (context, index) {
          final bill = widget.heldBills[index];
          return Card(
            margin: const EdgeInsets.all(10),
            child: ListTile(
              title: Text('Bill #${bill.number}'),
              subtitle: Text('Items: ${bill.items.length}'),
              onTap: () => _restoreBill(bill),
            ),
          );
        },
      ),
    );
  }
}