import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'model/item.dart';
import 'package:intl/intl.dart';
import 'print_service.dart';


class HomePage extends StatefulWidget {
  final bool showImages; // Add this parameter

  const HomePage({Key? key, required this.showImages}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>  with TickerProviderStateMixin {

  String selectedCategory = 'All'; // Track the selected category
  List<Item> searchResults = [];
  List<Item> orderedItems = []; // Track ordered items

  String? _selectedCustomer;
  List<String> _customers = ['Alice', 'Bob', 'Charlie', 'David'];
  late List<String> _filteredCustomers;

  late PageController _pageController; // Add a PageController
  int _selectedPage = 0; // Track the selected page
  Map<int, List<Item>> pageOrderedItems = {};
  int currentPageIndex = 0;
  int pageIndex = 0;


  void _openPage(int pageIndex) {
    print("insdide open page");

    pageOrderedItems[currentPageIndex] = orderedItems;

    // Clear the current ordered items list
    orderedItems = [];

    // Switch to the new page
    currentPageIndex = pageIndex;
    print("current page index $currentPageIndex");

    // Load the ordered items for the new page if available
    if (pageOrderedItems.containsKey(currentPageIndex)) {
      orderedItems = pageOrderedItems[currentPageIndex]!;
    } else {
      orderedItems = [];
    }
    _selectedPage = pageIndex;

    // Update the UI
    setState(() {});
  }


  final List<Item> items = [
    Item(
        image: 'assets/items/1.png',
        title: 'Original Burger',
        price: '\$5.99',
        tax: 'tax',
        itemCount: '1 item',
        category: 'Burger'),
    Item(
        image: 'assets/items/2.png',
        title: 'Double Burger',
        price: '\$10.99',
        tax: 'tax',
        itemCount: '1 item',
        category: 'Burger'),
    Item(
      image: 'assets/items/3.png',
      title: 'Cheese Burger',
      price: '\$6.99',
      tax: '1.50',
      itemCount: '1 Item',
      category: 'Burger',
    ),
    Item(
      image: 'assets/items/4.png',
      title: 'Double Cheese Burger',
      price: '\$12.99',
      tax: 'tax',
      itemCount: '1 item',
      category: 'Burger',
    ),
    Item(
      image: 'assets/items/5.png',
      title: 'Spicy Burger',
      price: '\$7.39',
      tax: '100',
      itemCount: '1 item',
      category: 'Burger',
    ),
    Item(
      image: 'assets/items/6.png',
      title: 'Special Black Burger',
      price: '\$7.39',
      tax: 'tax',
      itemCount: '1 item',
      category: 'Burger',
    ),
    Item(
      image: 'assets/items/9.png',
      title: 'Noodles',
      price: '\$8.99',
      tax: 'tax',
      itemCount: '1 item',
      category: 'Noodles',
    ),
  ];

  @override
  void initState() {
    super.initState();
    searchResults = items;
    _filteredCustomers = _customers; //newchange

    _pageController = PageController(initialPage: _selectedPage); // Initialize the PageController
  }


  void filterItems(String category) {
    setState(() {
      selectedCategory = category;
      searchResults = category == 'All'
          ? items
          : items.where((item) => item.category == category).toList();
    });
  }

  void _filterCustomers(String query) {
    setState(() {
      _filteredCustomers = _customers
          .where((customer) =>
          customer.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  void addItemToOrder(Item item) {
    setState(() {
      orderedItems.add(item); // Add item to the order
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    if (screenWidth < 1405) {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeRight,
        DeviceOrientation.landscapeLeft,
      ]);
    } else {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
      ]);
    }

    return Scaffold(
      backgroundColor: Color(0xff1f2021),
      body: PageView.builder(
        controller: _pageController, // Connect the PageController
        itemCount: 3, // Number of pages
        itemBuilder: (context, pageIndex) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 14,
                child: Column(
                  children: [
                    _topMenu(
                      title: 'Lorem Restaurant',
                      action: _search(),
                    ),
                    Container(
                      height: 70,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: [
                          _itemTab(
                            icon: 'assets/samplepic.jpg',
                            title: 'All',
                            isActive: selectedCategory == 'All',
                            onTap: () => filterItems('All'),
                          ),
                          _itemTab(
                            icon: 'assets/items/1.png',
                            title: 'Burger',
                            isActive: selectedCategory == 'burger',
                            onTap: () => filterItems('Burger'),
                          ),
                          _itemTab(
                            icon: 'assets/icons/icon-noodles.png',
                            title: 'Noodles',
                            isActive: selectedCategory == 'burger',
                            onTap: () => filterItems('Noodles'),
                          ),
                          // Add more item tabs here
                        ],
                      ),
                    ),
                    Expanded(
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          int crossAxisCount = constraints.maxWidth < 600 ? 3 : 5;
                          double childAspectRatio = constraints.maxWidth < 600
                              ? 1 / 0.8
                              : 1 / 0.85;

                          return GridView.builder(
                            gridDelegate:
                            SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: crossAxisCount,
                              childAspectRatio: childAspectRatio,
                            ),
                            itemCount: searchResults.length,
                            itemBuilder: (context, index) {
                              final item = searchResults[index];
                              return _item(
                                image: widget.showImages ? item.image : null,
                                title: item.title,
                                price: item.price,
                                item: item.itemCount,
                                onTap: () => addItemToOrder(item),
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(flex: 1, child: Container()),
              Expanded(
                flex: 4,
                child: Column(
                  children: [
                    _viewCustomerList(context),
                    const SizedBox(height: 10),
                    Expanded(
                      child: _buildOrderedItemsSection(),
                    ),
                    const SizedBox(height: 2),
                    _calculateAndPrintSection()
                  ],
                ),
              ),
            ],
          );
        },
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildNavButton(0),
            SizedBox(width: 10),
            _buildNavButton(1),
            SizedBox(width: 10),
            _buildNavButton(2),
          ],
        ),
      ),
    );

  }


  ElevatedButton _buildNavButton(int page) {
    return ElevatedButton(
      onPressed: () => _openPage(page),
      style: ElevatedButton.styleFrom(
        shape: const CircleBorder(),
        backgroundColor: _selectedPage == page
            ? Colors.white
            : Colors.lightGreen,
        // padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 25),
        padding: const EdgeInsets.all(20),
        foregroundColor: Colors.redAccent,
      ),
      child: Text('$page'),
    );
  }

  Widget _search() {
    return Expanded(
      child: TextField(
        decoration: const InputDecoration(
          filled: true,
          fillColor: Color(0xff1f2029),
          hintText: 'Search item...',
          hintStyle: TextStyle(color: Colors.white54),
          prefixIcon: Icon(Icons.search, color: Colors.white54),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(15.0))),
        ),
        style: const TextStyle(color: Colors.white),
        onChanged: (query) {
          setState(() {
            searchResults = items
                .where((item) =>
                item.title.toLowerCase().contains(query.toLowerCase()))
                .toList();
          });
        },
      ),
    );
  }

  Widget _itemTab(
      {required String icon,
        required String title,
        required bool isActive,
        required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        // width: 150,
        margin: const EdgeInsets.only(right: 16),
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: isActive ? const Color(0xfffd8f27) : const Color(0xff1f2029),
          border: Border.all(
            color: isActive ? Colors.deepOrangeAccent : const Color(0xff1f2029),
            width: 3,
          ),
        ),
        child: Row(
          children: [
            Image.asset(icon,
                width: 25,
                errorBuilder: (context, error, stackTrace) =>
                const Icon(Icons.error, color: Colors.red)),
            const SizedBox(width: 8),
            Text(title,
                style: TextStyle(
                    fontSize: 13,
                    color: isActive ? Colors.white : Colors.white,
                    fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _topMenu({
    required String title,
    // required String subTitle,
    required Widget action,
  }) {
    final String currentDate =
    DateFormat('dd MMMM yyyy').format(DateTime.now());

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1, horizontal: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.date_range,
                    size: 18,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 8), // Space between icon and date
                  Text(
                    currentDate,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 20),
                ],
              ),
            ],
          ),
          action,
        ],
      ),
    );
  }

  Widget _item(
      {String? image,
        required String title,
        required String price,
        required String item,
        required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
        decoration: BoxDecoration(
          color: const Color(0xff1f2029),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
                color: Colors.grey.withOpacity(0.3),
                spreadRadius: 1,
                blurRadius: 5,
                offset: const Offset(0, 3)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (image != null)
              Image.asset(image,
                  fit: BoxFit.cover, height: 30, width: double.infinity),
            const SizedBox(height: 8),
            Text(title,
                style: const TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(price,
                style: const TextStyle(fontSize: 14, color: Colors.grey)),
            const SizedBox(height: 4),
            Text(item,
                style: const TextStyle(fontSize: 14, color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  Widget _itemOrder({
    String? image,
    required String title,
    required String itemCount, // Change to itemCount
    required String price,
    required int index, // Add index to identify the item in the list
  }) {
    return GestureDetector(
      onTap: () {
        _showEditDialog(context, index);
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: const Color(0xff1f2029),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(color: Colors.grey.withOpacity(0.3)),
          ],
        ),
        child: Row(
          children: [
            if (image != null)
            // Image.asset(image, width: 60, height: 60, fit: BoxFit.cover),
              const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text('Total: $itemCount',
                      style: TextStyle(fontSize: 14, color: Colors.grey)),
                  Text('Price: $price',
                      style: const TextStyle(fontSize: 14, color: Colors.grey)),
                ],
              ),
            ),
            IconButton(
              icon: Icon(Icons.edit, color: Colors.white),
              onPressed: () {
                _showEditDialog(context, index);
              },
            ),
            IconButton(
              icon: Icon(Icons.delete, color: Colors.red),
              onPressed: () {
                _removeItem(index);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _removeItem(int index) {
    setState(() {
      orderedItems.removeAt(index); // Remove the item from the list
    });
    print(orderedItems);
  }

  void _showEditDialog(BuildContext context, int index) {
    final item = orderedItems[index];

    TextEditingController quantityController =
    TextEditingController(text: item.itemCount);
    TextEditingController priceController =
    TextEditingController(text: item.price);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Color(0xff1f2029),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            'Edit Item',
            style: TextStyle(color: Colors.white),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: quantityController,
                style: TextStyle(color: Colors.white),
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                ],
                decoration: InputDecoration(
                  hintText: 'Enter Valid Quantity',
                  hintStyle: TextStyle(color: Colors.white54),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Color(0xff1f2029),
                ),
              ),
              SizedBox(height: 10),
              TextField(
                controller: priceController,
                style: TextStyle(color: Colors.white),
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                ],
                decoration: InputDecoration(
                  hintText: 'Enter Valid Price',
                  hintStyle: TextStyle(color: Colors.white54),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Color(0xff1f2029),
                ),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              child: Text('Save'),
              onPressed: () {
                setState(() {
                  orderedItems[index] = Item(
                    image: item.image,
                    title: item.title,
                    price: priceController.text,
                    tax: item.tax,
                    itemCount: quantityController.text,
                    category: item.category,
                  );
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  // Calculate the subtotal of the order
  double calculateSubtotal() {
    double subtotal = 0.0;
    for (var item in orderedItems) {
      double price = double.parse(item.price.replaceAll('\$', ''));
      int quantity = int.parse(item.itemCount.split(' ')[0]);
      subtotal += price * quantity;
    }
    return subtotal;
  }

  // Calculate the total tax based on tax type
  double calculateTax() {
    double totalTax = 0.0;
    for (var item in orderedItems) {
      double price = double.parse(item.price.replaceAll('\$', ''));
      int quantity = int.parse(item.itemCount.split(' ')[0]);
      double itemTotal = price * quantity;

      if (item.tax.toLowerCase() == 'tax') {
        totalTax += itemTotal * 0.10; // 10% tax
      } else {
        try {
          // Parse GST amount as double
          double gstAmount = double.parse(item.tax);
          totalTax += gstAmount * quantity;
        } catch (e) {
          print("Invalid GST amount: ${item.tax}");
        }
      }
    }
    return totalTax;
  }

  // Calculate the total amount including tax
  double calculateTotal() {
    return calculateSubtotal() + calculateTax();
  }



  Widget _calculateAndPrintSection() {
    double subtotal = calculateSubtotal();
    double tax = calculateTax();
    double total = calculateTotal();

    return Flexible(
      fit: FlexFit.loose,
      child: Container(
        padding: const EdgeInsets.all(15),
        margin: const EdgeInsets.symmetric(vertical: 1),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          color: const Color(0xff1f2029),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Sub Total',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white)),
                Text('\$${subtotal.toStringAsFixed(2)}',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white)),
              ],
            ),
            const SizedBox(height: 0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Tax',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white)),
                Text('\$${tax.toStringAsFixed(2)}',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white)),
              ],
            ),
            Container(
              margin: const EdgeInsets.symmetric(vertical: 10),
              height: 2,
              width: double.infinity,
              color: Colors.white,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Total',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white)),
                Text(
                    '\$${(total * 1.1).toStringAsFixed(2)}',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white)),
              ],
            ),
            const SizedBox(height: 6),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.deepOrange,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
              onPressed: () async {
                print(orderedItems);
                try {
                  final printService = PrintService();
                  await printService.printBill(orderedItems);
                  print("Print job started.");
                } catch (e) {
                  print("Error occurred while printing: $e");
                }
              },
              child: Container(
                alignment: Alignment.center,
                padding: const EdgeInsets.all(12),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.print, size: 13),
                    SizedBox(width: 6),
                    Text('Print Bills')
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildOrderedItemsSection() {
    print("called ");
    return Container(
      decoration: BoxDecoration(
        color: Colors.blueGrey[900],
        borderRadius: BorderRadius.circular(12),
      ),
      child: orderedItems.isEmpty
          ? const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.shopping_cart_outlined,
              size: 50,
              color: Colors.white70,
            ),
            SizedBox(height: 10),
            Text(
              'Selected items will appear here',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 16,
              ),
            ),
          ],
        ),
      )
          : ListView.builder(
        itemCount: orderedItems.length,
        itemBuilder: (context, index) {
          final item = orderedItems[index];
          return _itemOrder(
            image: item.image,
            title: item.title,
            price: item.price,
            itemCount: item.itemCount,
            index: index,
          );
        },
      ),
    );
  }


  Widget _viewCustomerList(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.deepOrange,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      onPressed: () {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return Stack(
              children: [
                // Add a BackdropFilter to blur the background
                BackdropFilter(
                  filter: ImageFilter.blur(
                      sigmaX: 5.0, sigmaY: 5.0), // Adjust blur intensity
                  child: Container(
                    color: Colors.black.withOpacity(
                        0), // Just to make the BackdropFilter visible
                  ),
                ),
                AlertDialog(
                  backgroundColor:
                  Color(0xff1f2029), // Set background color here
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  title: const Text(
                    'Customer',
                    style: TextStyle(color: Colors.white54), // Title color
                  ),
                  content: Container(
                    width: MediaQuery.of(context).size.width *
                        0.8, // Adjust the width as needed
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextField(
                          onChanged: _filterCustomers,
                          style: TextStyle(
                              color: Colors.white), // Text field text color
                          decoration: InputDecoration(
                            hintText: 'Search',
                            hintStyle: TextStyle(
                                color: Colors.white), // Hint text color
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            prefixIcon: Icon(
                              Icons.search,
                              color: Colors.white, // Icon color
                            ),
                          ),
                        ),
                        SizedBox(height: 10),
                        DropdownButton<String>(
                          value: _selectedCustomer,
                          hint: const Text(
                            'Select a customer',
                            style: TextStyle(
                                color: Colors
                                    .white), // Hint text color for dropdown
                          ),
                          isExpanded: true,
                          dropdownColor: Color(0xff1f2029),
                          items: _filteredCustomers.map((String customer) {
                            return DropdownMenuItem<String>(
                              value: customer,
                              child: Text(
                                customer,
                                style: const TextStyle(
                                    color: Colors
                                        .white54), // Dropdown item text color
                              ),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            setState(() {
                              _selectedCustomer = newValue;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                  actions: <Widget>[
                    Row(
                      mainAxisSize: MainAxisSize
                          .min, // Use min size for the row to wrap its children
                      children: [
                        TextButton(
                          child: const Text(
                            'Close',
                            style: TextStyle(
                                color: Colors
                                    .redAccent), // Close button text color
                          ),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                        // const SizedBox(width: 8), // Adjust the width as needed to control spacing
                        // const Icon(Icons.close, color: Colors.redAccent, size: 16),
                      ],
                    ),
                  ],
                ),
              ],
            );
          },
        );
      },
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.person,
              color: Colors.white, size: 16), // Add list icon here
          SizedBox(width: 8), // Space between icon and text
          FittedBox(
            child: Text(
              'Customer',
              style:
              TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

}

