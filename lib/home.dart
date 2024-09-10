import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_pos_app/database/database_helper.dart';
import 'model/item.dart';
import 'package:intl/intl.dart';
import 'print_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  final bool showImages; // Add this parameter

  const HomePage({Key? key, required this.showImages}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  String selectedCategory = 'All'; // Track the selected category
  List<Item> searchResults = [];
  List<Item> orderedItems = [];

  List<Item> orderedItemsPage1 = [];
  List<Item> orderedItemsPage2 = [];
  List<Item> orderedItemsPage3 = [];

  String? _selectedCustomer;

  String? _selectedCustomerPage1;
  String? _selectedCustomerPage2;
  String? _selectedCustomerPage3;

  List<String> customers = [];
  List<String> _filteredCustomers = [];
  List<Item> items = [];

  late PageController _pageController; // Add a PageController

  TextEditingController _discountController = TextEditingController();

  int _selectedPage = 1; // Track the selected page
  Map<int, List<Item>> pageOrderedItems = {};
  int currentPageIndex = 1;
  int pageIndex = 1;

  double itemWidth = 180;
  double itemHeight = 150;

  String input = '';
  int selectedItemIndex = -1;

  int? editingItemIndex; // Track the index of the item being edited
  bool isEditing = false;
  late String selectedCompanyName;

  @override
  void initState() {
    super.initState();
    searchResults = items;

    _pageController = PageController(
        initialPage: _selectedPage); // Initialize the PageController

    _loadPreferences().then((_) {
      // Ensure preferences are loaded before fetching items
      _loadItemsFromDatabase();
      _loadCustomerForSelectedCompany();
    });
  }

  String? _getSelectedCustomerForCurrentPage() {
    if (currentPageIndex == 1) {
      print("getcust$_selectedCustomerPage1");

      return _selectedCustomerPage1;
    } else if (currentPageIndex == 2) {
      return _selectedCustomerPage2;
    } else if (currentPageIndex == 3) {
      print("getcust$_selectedCustomerPage3");
      return _selectedCustomerPage3;
    }
    return null;
  }

  void _setSelectedCustomerForCurrentPage(String? newValue) {
    if (currentPageIndex == 1) {
      _selectedCustomerPage1 = newValue;
      print(
          "newvalue and currentPageIndex $_selectedCustomerPage1 $currentPageIndex");
    } else if (currentPageIndex == 2) {
      _selectedCustomerPage2 = newValue;
      print(
          "newvalue and currentPageIndex $_selectedCustomerPage2 $currentPageIndex");
    } else if (currentPageIndex == 3) {
      _selectedCustomerPage3 = newValue;
      print(
          "newvalue and currentPageIndex $_selectedCustomerPage3 $currentPageIndex");
    }
  }

  void _openPage(int pageIndex) {
    setState(() {
      // Save the current page's ordered items before switching
      if (currentPageIndex == 1) {
        orderedItemsPage1 = List.from(orderedItems);
        _selectedCustomer = _selectedCustomerPage1;
        print("Saved selected customer for Page 1: $_selectedCustomerPage1");
      } else if (currentPageIndex == 2) {
        orderedItemsPage2 = List.from(orderedItems);
        _selectedCustomer = _selectedCustomerPage2;
        print("Saved selected customer for Page 2: $_selectedCustomerPage2");
      } else if (currentPageIndex == 3) {
        orderedItemsPage3 = List.from(orderedItems);
        _selectedCustomer = _selectedCustomerPage1;
        print("Saved selected customer for Page 3: $_selectedCustomerPage3");
      }

      // Switch to the new page and load its items
      currentPageIndex = pageIndex;

      if (currentPageIndex == 1) {
        orderedItems = List.from(orderedItemsPage1);
        _selectedCustomer = _selectedCustomerPage1;
        print("Loaded selected customer for Page 1: $_selectedCustomer");
      } else if (currentPageIndex == 2) {
        orderedItems = List.from(orderedItemsPage2);
        _selectedCustomer = _selectedCustomerPage2;
        print("Loaded selected customer for Page 2: $_selectedCustomer");
      } else if (currentPageIndex == 3) {
        orderedItems = List.from(orderedItemsPage3);
        _selectedCustomer = _selectedCustomerPage3;
        print("Loaded selected customer for Page 3: $_selectedCustomer");
      }
      _selectedPage = pageIndex; // Update the selected page
    });
  }

  Future<void> _loadCustomerForSelectedCompany() async {
    print("loadcustomer");
    if (selectedCompanyName.isNotEmpty) {
      final dbHelper = DatabaseHelper();

      // Fetch employees from the database
      List<String> customers =
          await dbHelper.getCustomerByCompany(selectedCompanyName);

      setState(() {
        _filteredCustomers = customers.toSet().toList();
      });
    }
  }

  void _updateItemCount(String value) {
    print("Inside updateItemCount, value: $value");

    if (editingItemIndex != null && editingItemIndex! < orderedItems.length) {
      setState(() {
        // Replace the initial count if it's 1 and this is the first input (i.e., isEditing is false)
        if (isEditing && orderedItems[editingItemIndex!].itemCount == 1) {
          // Set the count to the new input value and mark as editing
          print("inside first if $isEditing");

          print(orderedItems[editingItemIndex!].itemCount);

          String currentCount =
              orderedItems[editingItemIndex!].itemCount.toString();
          orderedItems[editingItemIndex!].itemCount =
              int.parse(currentCount + value);
          isEditing = false; // Mark that we're now editing the count
        } else if (!isEditing &&
            orderedItems[editingItemIndex!].itemCount == 1) {
          print("isediting $isEditing");
          print(orderedItems[editingItemIndex!].itemCount);
          orderedItems[editingItemIndex!].itemCount = int.parse(value);
          isEditing = true;
        } else {
          print("inside else $isEditing");
          // If already editing, append the new value
          String currentCount =
              orderedItems[editingItemIndex!].itemCount.toString();
          print("currentcount $currentCount");
          orderedItems[editingItemIndex!].itemCount =
              int.parse(currentCount + value);
        }
        // print("Updated item count for item at index $editingItemIndex to ${orderedItems[editingItemIndex!].itemCount}");
      });
    } else {
      print("Editing index is null or out of bounds");
    }
  }

  @override
  void dispose() {
    _discountController.dispose();
    super.dispose();
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      selectedCompanyName = prefs.getString('selectedCompanyName') ?? '';
    });
    print("selectedcoinhomee$selectedCompanyName");
  }

  Future<void> _loadItemsFromDatabase() async {
    print("inside load items");
    final dbHelper = DatabaseHelper();
    final fetchedItems = await dbHelper.getItems(selectedCompanyName);
    setState(() {
      items = fetchedItems;
      searchResults = items;
    });
  }

  void _filterCustomers(String query) {
    setState(() {
      _filteredCustomers = customers
          .where((customer) =>
              customer.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
    print("filteredcust$_filteredCustomers");
  }

// Function to add an item to the order
  void addItemToOrder(Item item) {
    setState(() {
      // Check if the item is already in the orderedItems list for the current page
      int existingItemIndex = orderedItems
          .indexWhere((orderedItem) => orderedItem.itemName == item.itemName);

      if (existingItemIndex != -1) {
        // If the item exists, increase the item count for the selected page
        orderedItems[existingItemIndex].itemCount += 1;
      } else {
        item = Item(
          // Create a new instance of the item for this page
          itemName: item.itemName,
          image: item.image,
          price: item.price,
          itemCount: 1,
          tax: item.tax,
          itemCode: item.itemCode,
          itemtaxtype: item.itemtaxtype, // Fresh count for new item
        );
        orderedItems.add(item);
      }

      // Save the updated list for the current page
      if (currentPageIndex == 1) {
        orderedItemsPage1 = List.from(orderedItems);
      } else if (currentPageIndex == 2) {
        orderedItemsPage2 = List.from(orderedItems);
      } else if (currentPageIndex == 3) {
        orderedItemsPage3 = List.from(orderedItems);
      }
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
      // backgroundColor: Color.fromARGB(255, 243, 239, 239),
      backgroundColor: Colors.white,
      body: PageView.builder(
        controller: _pageController,
        itemCount: 3,
        itemBuilder: (context, pageIndex) {
          return Stack(
            children: [
              Row(
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
                            children: const [
                              // _itemTab(
                              //   icon: 'assets/icons/samplepic.jpg',
                              //   title: 'All',
                              //   isActive: selectedCategory == 'All',
                              //   // onTap: () => filterItems('All'),
                              // ),
                              // _itemTab(
                              //   icon: 'assets/items/1.png',
                              //   title: 'Burger',
                              //   isActive: selectedCategory == 'Burger',
                              //   onTap: () => filterItems('Burger'),
                              // ),
                              // _itemTab(
                              //   icon: 'assets/icons/icon-noodles.png',
                              //   title: 'Noodles',
                              //   isActive: selectedCategory == 'Noodles',
                              //   onTap: () => filterItems('Noodles'),
                              // ),
                              // Add more item tabs here
                            ],
                          ),
                        ),
                        Expanded(
                          child: LayoutBuilder(
                            key: ValueKey('$itemWidth-$itemHeight'),
                            builder: (context, constraints) {
                              return GridView.builder(
                                gridDelegate:
                                    SliverGridDelegateWithMaxCrossAxisExtent(
                                  maxCrossAxisExtent:
                                      itemWidth, // Use the updated width
                                  childAspectRatio: itemWidth /
                                      itemHeight, // Use the updated height and width
                                  mainAxisSpacing: 5, // Spacing between rows
                                  crossAxisSpacing:
                                      5, // Spacing between columns
                                ),
                                itemCount: searchResults.length,
                                itemBuilder: (context, index) {
                                  final item = searchResults[index];
                                  return _item(
                                    image:
                                        widget.showImages ? item.image : null,
                                    itemName: item.itemName,
                                    price: item.price,
                                    itemCount: item.itemCount,
                                    tax: item.tax,
                                    onTap: () => addItemToOrder(item),
                                  );
                                },
                              );
                            },
                          ),
                        )
                      ],
                    ),
                  ),
                  Expanded(
                    flex: 4,
                    child: Column(
                      children: [
                        _viewCustomerList(context),
                        const SizedBox(height: 2),
                        Expanded(
                          flex: 2, // Equivalent to Flexible
                          child: _buildOrderedItemsSection(),
                        ),
                        const SizedBox(height: 2),
                        Expanded(
                          flex:
                              1, // Equivalent to Flexible for the print section
                          child: _calculateAndPrintSection(),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Positioned(
                bottom: 45, // Position the buttons at the bottom
                left: 0, // Align them to the left
                right: -280, // Align them to the right
                child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment:
                        MainAxisAlignment.center, // Center the buttons
                    children: [
                      _buildNavButton(1),
                      const Icon(Icons.more_horiz,
                          color: Colors.black38), // Dots icon
                      _buildNavButton(2),
                      const Icon(Icons.more_horiz,
                          color: Colors.black38), // Dots icon
                      _buildNavButton(3),
                    ],
                  ),
                ),
              ),
              Positioned(
                left: 0,
                bottom: 10,
                child: Row(
                  children: [
                    ...List.generate(10, (index) {
                      return Padding(
                        padding: const EdgeInsets.all(1.0),
                        child: ElevatedButton(
                          onPressed: () {
                            setState(() {
                              if (isEditing) {
                                input = index
                                    .toString(); // Start fresh if not editing
                                isEditing = true; // Mark as editing
                              } else {
                                input += index
                                    .toString(); // Append if already editing
                              }
                            });
                            _updateItemCount(input);
                          },
                          style: ButtonStyle(
                            backgroundColor: WidgetStateProperty.all<Color>(
                              // Choose your desired color here
                              Colors.deepOrangeAccent, // Example: blue
                            ),
                            foregroundColor: WidgetStateProperty.all<Color>(
                              Colors.black, // Text color
                            ),
                          ),
                          child: Text(
                            index.toString(),
                            style: TextStyle(fontSize: 10),
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  ElevatedButton _buildNavButton(int page) {
    return ElevatedButton(
      onPressed: () => _openPage(page),
      style: ElevatedButton.styleFrom(
        shape: const CircleBorder(),
        backgroundColor:
            _selectedPage == page ? Colors.black26 : Colors.deepOrangeAccent,
        padding: const EdgeInsets.all(15),
        foregroundColor: _selectedPage == page
            ? Colors.white // Text color for selected page
            : Colors.black, // Text color for non-selected pages
      ),
      child: Text('$page'),
    );
  }

  Widget _search() {
    return Expanded(
      child: TextField(
        decoration: const InputDecoration(
          filled: true,
          fillColor: Color.fromARGB(105, 225, 231, 231),
          hintText: 'Search item...',
          hintStyle: TextStyle(color: Color.fromARGB(137, 20, 12, 12)),
          prefixIcon:
              Icon(Icons.search, color: Color.fromARGB(137, 20, 12, 12)),
          border: OutlineInputBorder(
              borderSide: BorderSide.none,
              borderRadius: BorderRadius.all(Radius.circular(15.0))),
        ),
        style: const TextStyle(color: Colors.black),
        onChanged: (query) {
          setState(() {
            searchResults = items
                .where((item) =>
                    item.itemName.toLowerCase().contains(query.toLowerCase()))
                .toList();
          });
        },
      ),
    );
  }

  // Widget _itemTab(
  //     {required String icon,
  //     required String title,
  //     required bool isActive,
  //     required VoidCallback onTap}) {
  //   return GestureDetector(
  //     onTap: onTap,
  //     child: Container(
  //       // width: 150,
  //       margin: const EdgeInsets.only(right: 16),
  //       padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 24),
  //       decoration: BoxDecoration(
  //         borderRadius: BorderRadius.circular(10),
  //         color: isActive
  //             ? const Color(0xfffd8f27)
  //             : Color.fromARGB(255, 223, 230, 227),
  //         border: Border.all(
  //           color: isActive
  //               ? Colors.deepOrangeAccent
  //               : const Color.fromARGB(255, 224, 201, 201),
  //           width: 2,
  //         ),
  //       ),
  //       child: Row(
  //         children: [
  //           Image.asset(icon,
  //               width: 25,
  //               errorBuilder: (context, error, stackTrace) =>
  //                   const Icon(Icons.error, color: Colors.red)),
  //           const SizedBox(width: 4),
  //           Text(itemName,
  //               style: TextStyle(
  //                   fontSize: 13,
  //                   color: isActive ? Colors.white : Colors.black,
  //                   fontWeight: FontWeight.bold)),
  //         ],
  //       ),
  //     ),
  //   );
  // }

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
                    color: Colors.black,
                  ),
                  const SizedBox(width: 8), // Space between icon and date
                  Text(
                    currentDate,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black,
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
      required String itemName,
      required String price,
      required int itemCount,
      required VoidCallback onTap,
      required String tax}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
        height: 50,
        decoration: BoxDecoration(
          color: Color.fromARGB(155, 222, 229, 231),
          borderRadius: BorderRadius.circular(9),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (image != null)
              Image.asset(image,
                  fit: BoxFit.cover, height: 30, width: double.infinity),
            const SizedBox(height: 8),
            Text(itemName,
                style: const TextStyle(
                    fontSize: 16,
                    color: Colors.black,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(price,
                style: const TextStyle(fontSize: 14, color: Colors.brown)),
            const SizedBox(height: 4),
          ],
        ),
      ),
    );
  }

  Widget _itemOrder({
    String? image,
    required String itemName,
    required int itemCount,
    required String price,
    required int index, // Add index to identify the item in the list
  }) {
    double itemPrice = double.parse(price.replaceAll(' ', ''));

    // int quantity = itemCount;
    int quantity =
        itemCount > 0 ? itemCount : 1; // Ensure quantity starts at 1 if not set

    double total = itemPrice * quantity;
    editingItemIndex = index; // Set the index of the item being edited
    input = ''; //initialized the input
    return GestureDetector(
      onTap: () {
        _showEditDialog(context, index);
      },
      child: Container(
          margin: const EdgeInsets.symmetric(vertical: 3, horizontal: 3),
          padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 6),
          decoration: BoxDecoration(
            color: const Color.fromARGB(155, 205, 212, 214),
            borderRadius: BorderRadius.circular(13),
            boxShadow: [
              BoxShadow(color: Colors.grey.withOpacity(0.3)),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Row for Title and Delete icon
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Title taking full width
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Text(
                        itemName,
                        style: const TextStyle(
                          fontSize: 15,
                          color: Colors.black87,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  // Delete icon
                  IconButton(
                    icon: const Icon(Icons.close, size: 15, color: Colors.red),
                    onPressed: () {
                      _removeItem(index);
                    },
                  ),
                ],
              ),

              Row(
                children: [
                  // Item count taking full width
                  Expanded(
                    child: Text(
                      itemCount.toString(),
                      style: const TextStyle(fontSize: 14, color: Colors.black),
                    ),
                  ),
                  // Price taking full width
                  Expanded(
                    child: Text(
                      price,
                      style: const TextStyle(fontSize: 14, color: Colors.black),
                    ),
                  ),
                  const SizedBox(width: 30),
                  // Total taking full width
                  Expanded(
                    child: Text(
                      total.toStringAsFixed(2),
                      style: const TextStyle(fontSize: 14, color: Colors.black),
                      textAlign: TextAlign.center, // Center the text if needed
                    ),
                  ),
                ],
              )
            ],
          )),
    );
  }

  void _removeItem(int index) {
    setState(() {
      // Reset the item count to 1 before removing (or any desired behavior)
      orderedItems[index].itemCount = 1;
      orderedItems.removeAt(index);

      // Save the updated list for the current page
      if (currentPageIndex == 1) {
        orderedItemsPage1 = List.from(orderedItems);
      } else if (currentPageIndex == 2) {
        orderedItemsPage2 = List.from(orderedItems);
      } else if (currentPageIndex == 3) {
        orderedItemsPage3 = List.from(orderedItems);
      }
    });
  }

  void _showEditDialog(BuildContext context, int index) {
    final item = orderedItems[index];

    TextEditingController quantityController =
        TextEditingController(text: item.itemCount.toString());

    TextEditingController priceController =
        TextEditingController(text: item.price);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          // backgroundColor: Color(0xff1f2029),
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            'Edit Item',
            style: TextStyle(color: Colors.black),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: quantityController,
                style: const TextStyle(color: Colors.black),
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
                  fillColor: Colors.white,
                ),
              ),
              SizedBox(height: 10),
              TextField(
                controller: priceController,
                style: TextStyle(color: Colors.black),
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
                  fillColor: Colors.white,
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
                    itemName: item.itemName,
                    itemCode: item.itemCode,
                    price: priceController.text,
                    tax: item.tax,
                    itemCount: int.parse(quantityController.text),
                    itemtaxtype: item.itemtaxtype,
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
      double price = double.parse(item.price.replaceAll(' ', ''));
      // int quantity = int.parse(item.itemCount.split(' ')[0]);
      int quantity = item.itemCount;

      subtotal += price * quantity;
    }
    return subtotal;
  }

  // Calculate the total tax based on tax type
  double calculateTax() {
    double totalTax = 0.0;
    for (var item in orderedItems) {
      double price = double.parse(item.price.replaceAll(' ', ''));
      // int quantity = int.parse(item.itemCount.split(' ')[0]);
      int quantity = item.itemCount;

      double itemTotal = price * quantity;

      if (item.tax.toLowerCase() == '') {
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
    double total = calculateSubtotal() + calculateTax();
    double discount = 0.0;

    // Check if discount is not empty and parse it
    if (_discountController.text.isNotEmpty) {
      discount = double.parse(_discountController.text);
    }

    // Subtract the discount from the total
    total = total - discount;

    if (total < 0) {
      total = 0;
    }
    return total;
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
          color: Color.fromARGB(155, 222, 229, 231),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Sub Total',
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.black)),
                Text(' ${subtotal.toStringAsFixed(2)}',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.black)),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Tax',
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.black87)),
                Text(' ${tax.toStringAsFixed(2)}',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.black87)),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Discount',
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.black87)),
                SizedBox(
                  width: 50, // Adjust the width as needed
                  child: TextField(
                    controller:
                        _discountController, // Replace with your TextEditingController
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: Colors.black87),
                    textAlign: TextAlign.end,
                    decoration: const InputDecoration(
                      // border: InputBorder.none, // Remove the underline
                      contentPadding:
                          EdgeInsets.all(0), // Adjust padding as needed
                      hintText: '0.00', // Hint text
                      hintStyle: TextStyle(
                        color:
                            Colors.grey, // Light grey color for the hint text
                        fontWeight:
                            FontWeight.normal, // You can adjust the font weight
                      ),
                    ),
                    keyboardType:
                        TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      // FilteringTextInputFormatter.digitsOnly, // Allow only digits
                      FilteringTextInputFormatter.allow(
                          RegExp(r'^\d*\.?\d*')), // Allow decimal numbers
                    ],
                    onChanged: (value) {
                      // Handle the input change if needed
                      setState(() {
                        total = calculateTotal();
                      });
                    },
                  ),
                ),
              ],
            ),
            Container(
              margin: const EdgeInsets.symmetric(vertical: 1),
              height: 2,
              width: double.infinity,
              color: Colors.black12,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Total',
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.black87)),
                Text('${(total * 1.1).toStringAsFixed(2)}',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.black87)),
              ],
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.deepOrange,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              // onPressed: () async {
              //   double subtotal = calculateSubtotal();
              //   double tax = calculateTax();
              //   double total = calculateTotal();
              //   print(
              //       "ordereditemss$orderedItems$subtotal $tax $total,$_selectedCustomer");
              //   try {
              //     final printService = PrintService();
              //     await printService.printBill(
              //         orderedItems, subtotal, tax, total, _selectedCustomer!);
              //     print("Print job started.");
              //   } catch (e) {
              //     print("Error occurred while printing: $e");
              //   }
              // },
              onPressed: () async {
                double subtotal = calculateSubtotal();
                double tax = calculateTax();
                double total = calculateTotal();

                print(
                    "ordereditemss$orderedItems $subtotal $tax $total, $_selectedCustomer");

                // Check if _selectedCustomer is null
                if (_selectedCustomer == null) {
                  print("Error: No customer selected.");
                  // You can show a dialog or a Snackbar to notify the user
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content:
                          Text("Please select a customer before printing."),
                    ),
                  );
                  return; // Stop the execution
                }

                try {
                  final printService = PrintService();
                  await printService.printBill(
                      orderedItems, subtotal, tax, total, _selectedCustomer!);
                  print("Print job started.");
                } catch (e) {
                  print("Error occurred while printing: $e");
                }
              },

              child: Container(
                alignment: Alignment.center,
                padding: const EdgeInsets.all(2),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.print, size: 15),
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
    return Container(
      decoration: BoxDecoration(
        color: Color.fromARGB(155, 239, 241, 241),
        borderRadius: BorderRadius.circular(12),
      ),
      child: orderedItems.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(
                    Icons.shopping_cart_outlined,
                    size: 50,
                    color: Colors.black26,
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Cart',
                    style: TextStyle(
                      color: Colors.black26,
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
                // Print the itemCount and its datatype
                return _itemOrder(
                  image: item.image,
                  itemName: item.itemName,
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
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
                    color: Colors.white.withOpacity(
                        0), // Just to make the BackdropFilter visible
                  ),
                ),
                AlertDialog(
                  backgroundColor: const Color.fromARGB(
                      255, 255, 255, 255), // Set background color here
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  title: const Text(
                    'Select Customer',
                    style: TextStyle(color: Colors.black87), // Title color
                  ),
                  content: Container(
                    width: MediaQuery.of(context).size.width *
                        0.8, // Adjust the width as needed
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // TextField(
                        //   onChanged: _filterCustomers,
                        //   style: const TextStyle(
                        //       color: Colors.black87), // Text field text color
                        //   decoration: InputDecoration(
                        //     hintText: 'Search',
                        //     hintStyle: const TextStyle(
                        //         color: Colors.black26), // Hint text color
                        //     border: OutlineInputBorder(
                        //       borderRadius: BorderRadius.circular(12),
                        //     ),
                        //     prefixIcon: const Icon(
                        //       Icons.search,
                        //       color: Colors.black38, // Icon color
                        //     ),
                        //   ),
                        // ),
                        // SizedBox(height: 10),
                        DropdownButton<String>(
                          value: _filteredCustomers.contains(
                                  _getSelectedCustomerForCurrentPage())
                              ? _getSelectedCustomerForCurrentPage()
                              : null,
                          hint: const Text(
                            'Select a customer',
                            style: TextStyle(color: Colors.black38),
                          ),
                          isExpanded: true,
                          dropdownColor: Color.fromARGB(255, 226, 226, 233),
                          items: _filteredCustomers.map((String customer) {
                            return DropdownMenuItem<String>(
                              value: customer,
                              child: Text(
                                customer,
                                style: const TextStyle(color: Colors.black87),
                              ),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            setState(() {
                              _setSelectedCustomerForCurrentPage(newValue);
                            });
                            Navigator.of(context).pop();
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
                      ],
                    ),
                  ],
                ),
              ],
            );
          },
        );
      },
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.person,
              color: Colors.white, size: 16), // Icon stays constant
          const SizedBox(width: 8), // Add some space between the icon and text

          FittedBox(
            child: Text(
              _getSelectedCustomerForCurrentPage() ?? 'Customer',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
