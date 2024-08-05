// item_list.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Import this for setting device orientations
import 'model/item.dart';

class SalesReport extends StatelessWidget {
  final List<Item> items;

  const SalesReport({Key? key, required this.items}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    print('Items passed to ItemListPage: ${items.length}');

    // Set the orientation to landscape when the widget is built
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
    ]);

    return WillPopScope(
      onWillPop: () async {
        // Reset the orientation when leaving this screen
        await SystemChrome.setPreferredOrientations(
          [
            DeviceOrientation.portraitUp,
            DeviceOrientation.portraitDown,
            DeviceOrientation.landscapeRight,
            DeviceOrientation.landscapeLeft,
          ],
        );
        return true;
      },
      child: Scaffold(
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
        body: OrientationBuilder(
          builder: (context, orientation) {
            // We don't need to check orientation here as we are forcing landscape
            if (MediaQuery.of(context).size.width < 1200) {
              return _buildHorizontalLayout();
            } else {
              return _buildVerticalLayout();
            }
          },
        ),
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
          label: Text(
            'Image',
            style: TextStyle(color: Colors.white),
          ),
        ),
        DataColumn(
          label: Text(
            'Title',
            style: TextStyle(color: Colors.white),
          ),
        ),
        DataColumn(
          label: Text(
            'Price',
            style: TextStyle(color: Colors.white),
          ),
        ),
      ],
      rows: items.map((item) {
        return DataRow(
          cells: [
            DataCell(Image.asset(item.image, height: 30, width: 30)),
            DataCell(Text(item.title, style: const TextStyle(color: Colors.white))),
            DataCell(Text(item.price, style: const TextStyle(color: Colors.white54))),
          ],
        );
      }).toList(),
    );
  }
}
