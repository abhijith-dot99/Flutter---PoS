import 'package:flutter/material.dart';
import 'model/item.dart';

class SalesReport extends StatefulWidget {
  final List<Item> items;

  const SalesReport({Key? key, required this.items}) : super(key: key);

  @override
  _SalesReportState createState() => _SalesReportState();
}

class _SalesReportState extends State<SalesReport> {
  TextEditingController searchController = TextEditingController();
  DateTime? startDate;
  DateTime? endDate;

  @override
  Widget build(BuildContext context) {
    print('Items passed to ItemListPage: ${widget.items.length}');

    return Scaffold(
      backgroundColor: const Color(0xff1f2029),
      appBar: AppBar(
        backgroundColor: const Color(0xff2c2f36),
        elevation: 0,
        title: const Text(
          'Sales Report',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: TextField(
                    controller: searchController,
                    style: const TextStyle(color: Colors.white54),
                    decoration: const InputDecoration(
                      hintText: 'Search...',
                      hintStyle: TextStyle(color: Colors.white54),
                      prefixIcon: Icon(Icons.search, color: Colors.white54),
                      filled: true,
                      fillColor: Color(0xff2c2f36),
                      border: OutlineInputBorder(
                        borderSide: BorderSide.none,
                        borderRadius: BorderRadius.all(Radius.circular(12)),
                      ),
                    ),
                    onChanged: (value) {
                      setState(() {
                        // Update the search logic as needed
                      });
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: const Color(0xff2c2f36), // Text color
                      padding:
                          const EdgeInsets.symmetric(vertical: 21.5), // Padding
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(12), // Rounded corners
                      ),
                      elevation: 5, // Shadow effect
                    ),
                    onPressed: () async {
                      DateTime? picked = await showDatePicker(
                        context: context,
                        initialDate: startDate ?? DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2101),
                      );
                      if (picked != null && picked != startDate) {
                        setState(() {
                          startDate = picked;
                        });
                      }
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          startDate == null
                              ? 'Start Date'
                              : '${startDate!.day}/${startDate!.month}/${startDate!.year}',
                          style: const TextStyle(fontSize: 14), // Text style
                        ),
                        const SizedBox(width: 8),
                        const Icon(Icons.calendar_today,
                            size: 16), // Calendar icon
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: const Color(0xff2c2f36), // Text color
                      padding:
                          const EdgeInsets.symmetric(vertical: 21.6), // Padding
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(12), // Rounded corners
                      ),
                      elevation: 5, // Shadow effect
                    ),
                    onPressed: () async {
                      DateTime? picked = await showDatePicker(
                        context: context,
                        initialDate: endDate ?? DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2101),
                      );
                      if (picked != null && picked != endDate) {
                        setState(() {
                          endDate = picked;
                        });
                      }
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          endDate == null
                              ? 'End Date'
                              : '${endDate!.day}/${endDate!.month}/${endDate!.year}',
                          style: const TextStyle(fontSize: 14), // Text style
                        ),
                        const SizedBox(width: 8),
                        const Icon(Icons.calendar_today,
                            size: 16), // Calendar icon
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: OrientationBuilder(
              builder: (context, orientation) {
                if (MediaQuery.of(context).size.width < 1200) {
                  return _buildHorizontalLayout();
                } else {
                  return _buildVerticalLayout();
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVerticalLayout() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        children: [
          const SizedBox(height: 20),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: _buildDataTable(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHorizontalLayout() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Row(
        children: [
          const SizedBox(width: 20),
          Expanded(
            flex: 8,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: _buildDataTable(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDataTable() {
    return DataTable(
      columnSpacing: 40.0,
      columns: const [
        DataColumn(
          label: Center(
            child: Text(
              'Image',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ),
        DataColumn(
          label: Center(
            child: Text(
              'Title',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ),
        DataColumn(
          label: Center(
            child: Text(
              'Price',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ),
      ],
      rows: widget.items.map((item) {
        return DataRow(
          cells: [
            const DataCell(
              Center(
                // child: Image.asset(item.image, height: 30, width: 30),
              ),
            ),
            DataCell(
              Center(
                child: Text(item.title,
                    style: const TextStyle(color: Colors.white)),
              ),
            ),
            DataCell(
              Center(
                child: Text(item.price,
                    style: const TextStyle(color: Colors.white54)),
              ),
            ),
          ],
        );
      }).toList(),
    );
  }
}
