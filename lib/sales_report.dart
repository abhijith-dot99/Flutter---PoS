import 'package:flutter/material.dart';
import 'model/item.dart';

class SalesReport extends StatefulWidget {
  final List<Item> items;

  const SalesReport({Key? key, required this.items}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
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
      // backgroundColor: Colors.blueGrey,
      backgroundColor: Color.fromARGB(255, 255, 255, 255),
      appBar: AppBar(
        // backgroundColor: Colors.grey,
        backgroundColor: Color.fromARGB(155, 239, 241, 241),
        elevation: 0,
        title: const Text(
          'Sales Report',
          style: TextStyle(
            color: Colors.black87,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.black87),
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
                    style: const TextStyle(color: Colors.black54),
                    decoration: const InputDecoration(
                      hintText: 'Search...',
                      hintStyle: TextStyle(color: Colors.black38),
                      prefixIcon: Icon(Icons.search, color: Colors.black54),
                      filled: true,
                      fillColor: Color.fromARGB(255, 225, 229, 238),
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
                      foregroundColor: Colors.black,
                      backgroundColor: Colors.white, // Text color
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
                      foregroundColor: Colors.black,
                      backgroundColor: Colors.white, // Text color
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
        // DataColumn(
        //   label: Center(
        //     child: Text(
        //       'Image',
        //       style: TextStyle(color: Colors.black87),
        //     ),
        //   ),
        // ),
        DataColumn(
          label: Center(
            child: Text(
              'Title',
              style: TextStyle(color: Colors.black87),
            ),
          ),
        ),
        DataColumn(
          label: Center(
            child: Text(
              'Price',
              style: TextStyle(color: Colors.black87),
            ),
          ),
        ),
      ],
      rows: widget.items.map((item) {
        return DataRow(
          cells: [
            // const DataCell(
            //   Center(
            //       child: Image.asset(item.image, height: 30, width: 30),
            //       ),
            // ),
            // DataCell(
            //   Center(
            //     child: Text(item.title,
            //         style: const TextStyle(color: Colors.black87)),
            //   ),
            // ),
            // DataCell(
            //   Center(
            //     child: Text(item.price,
            //         style: const TextStyle(color: Colors.black87)),
            //   ),
            // ),
          ],
        );
      }).toList(),
    );
  }
}
