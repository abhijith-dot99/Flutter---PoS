import 'dart:convert';
import 'dart:io';
import 'dart:ui';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_pos_app/database/database_helper.dart';
import 'generate_3_in.dart';
import 'model/item.dart';
import 'model/items.dart';
import 'package:intl/intl.dart';
import 'print_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:qr/qr.dart';
import 'package:path_provider/path_provider.dart';
// For UI and BuildContext

class HomePage extends StatefulWidget {
  final bool showImages; // Add this parameter

  const HomePage({Key? key, required this.showImages}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  final dbHelper = DatabaseHelper(); // Initialize dbHelper
  double companyTax = 0.0;
  double fetchedTax = 0.0;
  String fetchVat = '';
  // String qrData = 'afpc';

  String? selectedMode;
  double paidAmount = 0;
  double vatPercent = 0.15;

  String? selectedModePage1, selectedModePage2, selectedModePage3;
  double paidAmountPage1 = 0, paidAmountPage2 = 0, paidAmountPage3 = 0;

  String selectedCategory = 'All'; // Track the selected category
  List<Item> searchResults = [];
  List<Item> orderedItems = [];
  List<Items> soldItems = [];

  List<Item> orderedItemsPage1 = [];
  List<Item> orderedItemsPage2 = [];
  List<Item> orderedItemsPage3 = [];

  String? _selectedCustomer;
  Map<String, dynamic>? selectedCustomerforcompany;

  String? _selectedCustomerPage1;
  String? _selectedCustomerPage2;
  String? _selectedCustomerPage3;

  double discountPage1 = 0.0;
  double discountPage2 = 0.0;
  double discountPage3 = 0.0;

  List<String> customers = [];
  List<String?> _filteredCustomers = [];
  List<Item> items = [];

  late PageController _pageController; // Add a PageController

  final TextEditingController _discountController = TextEditingController();
  final TextEditingController paidAmountController = TextEditingController();

  int _selectedPage = 1; // Track the selected page
  Map<int, List<Item>> pageOrderedItems = {};

  List<Map<String, dynamic>> modesOfPayments = [];
  int currentPageIndex = 1;
  int pageIndex = 1;

  double itemWidth = 180;
  double itemHeight = 150;

  String input = '';
  int selectedItemIndex = -1;

  int? editingItemIndex; // Track the index of the item being edited
  bool isEditing = false;
  // late String selectedCompanyName;
  late String selectedCompanyName = ""; // Initialize to an empty string

  late String secretKey;
  late String apiKey;

  String?
      previousCustomer; // Keep track of previous customer outside the function.
  @override
  void initState() {
    super.initState();
    searchResults = items;

    _pageController = PageController(
        initialPage: _selectedPage); // Initialize the PageController

    _loadPreferences().then((_) {
      _loadItemsFromDatabase();
      _loadCustomerForSelectedCompany();
      _loadModesFromDB();
    });
  }

  void _clearFields() {
    setState(() {
      // Clear each widget's controller or variable
      _discountController.clear();
      paidAmountController.clear();
      // selectedMode = null;
      orderedItems.clear();
      // _selectedCustomer = null;
      // paidAmount = 0;
      _getSelectedCustomerForCurrentPage();
    });
  }

  void _clearSelectedCustomerForCurrentPage() {
    setState(() {
      if (currentPageIndex == 1) {
        _selectedCustomerPage1 = null;
      } else if (currentPageIndex == 2) {
        _selectedCustomerPage2 = null;
      } else if (currentPageIndex == 3) {
        _selectedCustomerPage3 = null;
      }
    });
  }

  String? _getSelectedCustomerForCurrentPage() {
    if (currentPageIndex == 1) {
      // print("getcust$_selectedCustomerPage1");

      return _selectedCustomerPage1;
    } else if (currentPageIndex == 2) {
      return _selectedCustomerPage2;
    } else if (currentPageIndex == 3) {
      // print("getcust$_selectedCustomerPage3");
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

// Getter for selectedMode
  String? _getSelectedModeForCurrentPage() {
    if (currentPageIndex == 1) {
      return selectedModePage1;
    } else if (currentPageIndex == 2) {
      return selectedModePage2;
    } else if (currentPageIndex == 3) {
      return selectedModePage3;
    }
    return null;
  }

// Setter for selectedMode
  void _setSelectedModeForCurrentPage(String? mode) {
    setState(() {
      if (currentPageIndex == 1) {
        selectedModePage1 = mode;
        selectedMode = selectedModePage1;
      } else if (currentPageIndex == 2) {
        selectedModePage2 = mode;
        selectedMode = selectedModePage2;
      } else if (currentPageIndex == 3) {
        selectedModePage3 = mode;
        selectedMode = selectedModePage3;
      }
    });
  }

// Getter for paidAmount
  double _getPaidAmountForCurrentPage() {
    if (currentPageIndex == 1) {
      // print("paidamount$paidAmountPage1");
      return paidAmountPage1;
    } else if (currentPageIndex == 2) {
      // print("paidamount$paidAmountPage1");
      return paidAmountPage2;
    } else if (currentPageIndex == 3) {
      // print("paidamount$paidAmountPage1");
      return paidAmountPage3;
    }
    return 0.0;
  }

// Setter for paidAmount
  void _setPaidAmountForCurrentPage(double amount) {
    setState(() {
      if (currentPageIndex == 1) {
        paidAmountPage1 = amount;
        paidAmount = paidAmountPage1;
      } else if (currentPageIndex == 2) {
        paidAmountPage2 = amount;
        paidAmount = paidAmountPage2;
      } else if (currentPageIndex == 3) {
        paidAmountPage3 = amount;
        paidAmount = paidAmountPage3;
      }
    });
  }

  double _getDiscountForCurrentPage() {
    if (currentPageIndex == 1) {
      return discountPage1;
    } else if (currentPageIndex == 2) {
      return discountPage2;
    } else if (currentPageIndex == 3) {
      return discountPage3;
    }
    return 0.0;
  }

  void _setDiscountForCurrentPage(double discount) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        if (currentPageIndex == 1) {
          discountPage1 = discount;
        } else if (currentPageIndex == 2) {
          discountPage2 = discount;
        } else if (currentPageIndex == 3) {
          discountPage3 = discount;
        }
      });
    });
  }

  void _openPage(int pageIndex) {
    setState(() {
      // Save the current page's ordered items and paidAmount before switching
      // if (currentPageIndex == 1) {
      //   orderedItemsPage1 = List.from(orderedItems);

      //   _selectedCustomer = _selectedCustomerPage1;
      //   paidAmountPage1 = double.tryParse(paidAmountController.text) ?? 0;
      //   print("Saved selected customer and paid amount for Page 1");
      // } else if (currentPageIndex == 2) {
      //   orderedItemsPage2 = List.from(orderedItems);
      //   _selectedCustomer = _selectedCustomerPage2;
      //   paidAmountPage2 = double.tryParse(paidAmountController.text) ?? 0;
      //   print("Saved selected customer and paid amount for Page 2");
      // } else if (currentPageIndex == 3) {
      //   orderedItemsPage3 = List.from(orderedItems);
      //   _selectedCustomer = _selectedCustomerPage3;
      //   paidAmountPage3 = double.tryParse(paidAmountController.text) ?? 0;
      //   print("Saved selected customer and paid amount for Page 3");
      // }

      // Switch to the new page and load its items
      currentPageIndex = pageIndex;

      if (currentPageIndex == 1) {
        orderedItems = List.from(orderedItemsPage1);
        _selectedCustomer = _selectedCustomerPage1;
        paidAmountController.text = paidAmountPage1.toString();
        _discountController.text = _getDiscountForCurrentPage().toString();
        print("Loaded selected customer and paid amount for Page 1");
      } else if (currentPageIndex == 2) {
        orderedItems = List.from(orderedItemsPage2);
        _selectedCustomer = _selectedCustomerPage2;
        paidAmountController.text = paidAmountPage2.toString();
        _discountController.text = _getDiscountForCurrentPage().toString();
        print("Loaded selected customer and paid amount for Page 2");
      } else if (currentPageIndex == 3) {
        orderedItems = List.from(orderedItemsPage3);
        _selectedCustomer = _selectedCustomerPage3;
        paidAmountController.text = paidAmountPage3.toString();
        _discountController.text = _getDiscountForCurrentPage().toString();
        print("Loaded selected customer and paid amount for Page 3");
      }

      _selectedPage = pageIndex; // Update the selected page
    });
  }

  Future<void> _loadModesFromDB() async {
    print("inside loadmode");
    final dbHelper = DatabaseHelper();

    List<Map<String, dynamic>> modes = await dbHelper.getModesPayment();

    print("modes $modes");

    // Store the fetched data in a state variable for displaying in the dropdown
    setState(() {
      modesOfPayments = modes;
      print("modesofpayment$modesOfPayments");
    });
  }

  Future<void> _loadCustomerForSelectedCompany() async {
    print("insdieloadcustomer");

    if (selectedCompanyName.isNotEmpty) {
      final dbHelper = DatabaseHelper();

      // Fetch customers from the database (all fields, not just names)
      List<Map<String, dynamic>> customers =
          (await dbHelper.getCustomerByCompany(selectedCompanyName))
              .cast<Map<String, dynamic>>();

      if (customers.isNotEmpty) {
        Map<String, dynamic> customerData = customers[0];

        // Now you can use the customerData map to access fields and print them in your bill
        print('Customer Name: ${customerData['customer_name']}');

        setState(() {
          // Assuming you want to filter based on customer_name
          _filteredCustomers = customers
              .map((customer) => customer['customer_name']?.toString())
              .toSet()
              .toList();
          // Store the selected customer data for future use
          selectedCustomerforcompany = customerData;
        });
      }
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
    // _discountController.dispose();
    // Reset the preferred orientation to allow normal orientation for other pages
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    super.dispose();
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      selectedCompanyName = prefs.getString('selectedCompanyName') ?? '';
      secretKey = prefs.getString('secretKey') ?? '';
      apiKey = prefs.getString('apiKey') ?? '';
    });
    print("apiinsideload$apiKey");
    print("secretinsideload$secretKey");
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
  Future<void> addItemToOrder(Item item) async {
    final dbHelper = DatabaseHelper();
    double companyTax = await dbHelper.fetchCompanyTax(selectedCompanyName);
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
          itemDesciption: item.itemDesciption,
          itemCount: item.itemCount,
          tax: item.tax,
          companyTax: companyTax,
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
    _fetchCompanyTax();
  }

  @override
  Widget build(BuildContext context) {
    // print("inide main widget");
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
                        // Container(
                        //   // height: 70,
                        //   padding: const EdgeInsets.symmetric(vertical: 8),
                        //   child: ListView(
                        //     scrollDirection: Axis.horizontal,
                        //     children: const [
                        //       // _itemTab(
                        //       //   icon: 'assets/icons/samplepic.jpg',
                        //       //   title: 'All',
                        //       //   isActive: selectedCategory == 'All',
                        //       //   // onTap: () => filterItems('All'),
                        //       // ),
                       
                         
                        //       // Add more item tabs here
                        //     ],
                        //   ),
                        // ),
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
                        const SizedBox(height: 5),
                        _modeSelector(),
                        const SizedBox(height: 5),
                        _paidAmount(),
                        const SizedBox(height: 5),
                        _calculateAndPrintSection(),
                        const SizedBox(height: 5),
                      ],
                    ),
                  ),
                ],
              ),
              Positioned(
                bottom: 8, // Position the buttons at the bottom
                left: 0, // Align them to the left
                right: -440, // Align them to the right
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
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
                        padding: const EdgeInsets.all(2.0),
                        child: SizedBox(
                          width: 40, // Set the desired width
                          height: 30, // Set the desired height
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
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  const Color(0xFF4285F4), // Set the color here
                              foregroundColor:
                                  Colors.white, // Button text color
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                    4.0), // Set border radius here
                              ),
                              padding: EdgeInsets.zero,
                            ),
                            child: Text(
                              index.toString(),
                              style: const TextStyle(fontSize: 7),
                            ),
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              )
            ],
          );
        },
      ),
    );
  }

  Widget _buildNavButton(int page) {
    return SizedBox(
      width: 40, // Set width of the button
      height: 30, // Set height of the button
      child: ElevatedButton(
        onPressed: () => _openPage(page),
        style: ElevatedButton.styleFrom(
          shape: const CircleBorder(),
          padding: EdgeInsets.zero,
          backgroundColor:
              _selectedPage == page ? Colors.black26 : const Color(0xFF4285F4),
          foregroundColor: _selectedPage == page
              ? Colors.white // Text color for selected page
              : Colors.black, // Text color for non-selected pages
        ),
        child: Text(
          '$page',
          style: const TextStyle(fontSize: 10), // Adjust font size
        ),
      ),
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
                    itemDesciption: item.itemDesciption,
                    price: priceController.text,
                    tax: item.tax,
                    companyTax: item.companyTax,
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

  // Fetch company tax asynchronously
  Future<void> _fetchCompanyTax() async {
    print("_fetchCompanyTax");
    print("FetchedselectedCompanyName: $selectedCompanyName");
    fetchedTax = await dbHelper.getCompanyTax(selectedCompanyName); // Fetch tax
    fetchVat = (await dbHelper.getCompanyVat(selectedCompanyName));
    setState(() {
      // Update the state after fetching the tax
      companyTax = fetchedTax;
      print("companytex$fetchedTax ");
    });
  }

  double calculateTax(double discount) {
    double totalTax = 0.0;

    for (var item in orderedItems) {
      double price = double.parse(item.price.replaceAll(' ', ''));
      int quantity = item.itemCount;
      double itemTotal = price * quantity;

      // Calculate company tax before discount
      double companyTaxAmount = itemTotal * (companyTax / 100);

      // Calculate the taxable amount after applying discount proportionally
      double discountProportion = discount / calculateSubtotal();
      double discountedCompanyTax = companyTaxAmount * (1 - discountProportion);

      // Add discounted tax to the total
      totalTax += discountedCompanyTax;
    }

    return totalTax;
  }

// Calculate the total amount including tax and discount
  double calculateTotal() {
    double subtotal = calculateSubtotal();
    double discount = 0.0;

    // Check if discount is not empty and parse it
    if (_discountController.text.isNotEmpty) {
      // discount = double.parse(_discountController.text);
      discount = double.tryParse(_discountController.text) ?? 0;
      _setDiscountForCurrentPage(discount);
    }

    double vatAmount =
        subtotal - discount * vatPercent;

    // Calculate tax after applying discount
    double totalTax = calculateTax(discount);

    // Subtract the discount from the subtotal
    double total =
        subtotal + totalTax - discount - _getPaidAmountForCurrentPage();

    // Ensure total doesn't go below zero
    if (total < 0) {
      total = 0;
    }

    return total;
  }

  double calculateVatAmount(){
    double subtotal = calculateSubtotal();
        double discount = 0.0;

    // Check if discount is not empty and parse it
    if (_discountController.text.isNotEmpty) {
      // discount = double.parse(_discountController.text);
      discount = double.tryParse(_discountController.text) ?? 0;
      _setDiscountForCurrentPage(discount);
    }
        double vatAmount =
        subtotal - discount * vatPercent;

        return vatAmount;
  }

  Future<PermissionStatus> requestStoragePermission() async {
    print("inside request storage");
    if (Platform.isAndroid) {
      if (await Permission.manageExternalStorage.isGranted) {
        print("Storage permission already granted.");
        return PermissionStatus.granted;
      } else {
        PermissionStatus status =
            await Permission.manageExternalStorage.request();
        if (status.isGranted) {
          print("Storage permission granted.");
        } else if (status.isDenied || status.isPermanentlyDenied) {
          print("Permission denied.");
          openAppSettings(); // For permanent denial, redirect to app settings.
        }
        return status; // Return the permission status
      }
    }
    return PermissionStatus.denied; // Default return in case it's not Android
  }

  Future<File> generateQR(String companyName, String vatRegNum) async {
    BytesBuilder bytesBuilder = BytesBuilder();

    // Seller name
    bytesBuilder.addByte(1);
    List<int> sellerNameBytes = utf8.encode(companyName);
    bytesBuilder.addByte(sellerNameBytes.length);
    bytesBuilder.add(sellerNameBytes);

    // VAT registration number
    bytesBuilder.addByte(2);
    List<int> vatRegNumBytes = utf8.encode(vatRegNum);
    bytesBuilder.addByte(vatRegNumBytes.length);
    bytesBuilder.add(vatRegNumBytes);

    // Timestamp
    bytesBuilder.addByte(3);
    List<int> timeStampBytes = utf8
        .encode(DateFormat('yyyy-MM-ddTHH:mm:ss').format(DateTime.now()) + 'Z');
    bytesBuilder.addByte(timeStampBytes.length);
    bytesBuilder.add(timeStampBytes);

    // Invoice total with VAT
    bytesBuilder.addByte(4);
    List<int> invTotalBytes = utf8.encode(calculateTotal.toString());
    bytesBuilder.addByte(invTotalBytes.length);
    bytesBuilder.add(invTotalBytes);

    // VAT total
    bytesBuilder.addByte(5);
    List<int> totalVatBytes =
        utf8.encode(calculateVatAmount.toString()); // Or update with VAT total
    bytesBuilder.addByte(totalVatBytes.length);
    bytesBuilder.add(totalVatBytes);

    // Generate QR code using QrPainter
    final qrCodeData = base64Encode(bytesBuilder.toBytes());
    final qrPainter = QrPainter(
      data: qrCodeData,
      version: QrVersions.auto,
      gapless: true,
      color: const Color(0xFF000000),
      emptyColor: const Color(0xFFFFFFFF),
    );

    // Convert QrPainter to Image
    final ui.Image image = await qrPainter.toImage(200); // 200x200 size
    final ByteData? byteData =
        await image.toByteData(format: ui.ImageByteFormat.png);
    final Uint8List pngBytes = byteData!.buffer.asUint8List();

    // Get the directory to store the image
    final directory = await getApplicationDocumentsDirectory();
    final filePath = '${directory.path}/qr_code.png';
    final file = File(filePath);

    // Write the bytes to a file
    await file.writeAsBytes(pngBytes);

    return file;
  }

  Widget _calculateAndPrintSection() {
    double discount = 0.0;
    if (_discountController.text.isNotEmpty) {
      // discount = double.parse(_discountController.text);
      discount = double.tryParse(_discountController.text) ?? 0;
      _setDiscountForCurrentPage(discount);
    }
    double subtotal = calculateSubtotal();
    double tax = calculateTax(discount);
    double total = calculateTotal();

    return Container(
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
              const Text('Paid Amount',
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.black87)),
              const SizedBox(
                width: 50, // Adjust the width as needed
              ),
              Text(
                // paidAmount.toStringAsFixed(2),
                _getPaidAmountForCurrentPage().toString(),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              )
            ],
          ),
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
                      color: Colors.grey, // Light grey color for the hint text
                      fontWeight:
                          FontWeight.normal, // You can adjust the font weight
                    ),
                  ),
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
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
              Text((total).toStringAsFixed(2),
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.black87)),
            ],
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: const Color(0xFF4285F4),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () async {
              PermissionStatus status = await requestStoragePermission();
              try {
                if (Platform.isAndroid) {
                  if (!status.isGranted) {
                    print(
                        "Storage permission still not granted after request.");
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                            "Please grant storage permission to print the bill."),
                      ),
                    );
                    return; // Exit early since permission is not granted
                  } else if (status.isGranted) {
                    print("Permission granted: ${status.isGranted}");
                  }
                }

                await Future.delayed(const Duration(milliseconds: 500));
                _selectedCustomer = _getSelectedCustomerForCurrentPage();

                // Check if _selectedCustomer is null
                if (_selectedCustomer == null) {
                  print("Error: No customer selected.");
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content:
                          Text("Please select a customer before printing."),
                    ),
                  );
                  return; // Stop the execution
                }

                final dbHelper = DatabaseHelper();
                List<Map<String, dynamic>> customers =
                    await dbHelper.getCustomerByCompany(selectedCompanyName);
                Map<String, dynamic>? customerData;

                if (customers.isNotEmpty) {
                  customerData = customers.firstWhere((customer) =>
                      customer['customer_name'] == _selectedCustomer);
                }

                if (customerData == null) {
                  print("Error: Customer data not found.");
                  return;
                }
                // Insert the sold items into the database

                // String invoiceNo = await dbHelper.getNextInvoiceNumber();

                try {
                  print("changed $previousCustomer to $_selectedCustomer");

                  // Transfer ordered items to soldItems after printing
                  soldItems = orderedItems
                      .map((item) => Items(
                            itemCode: item.itemCode,
                            itemName: item.itemName,
                            itemDescription: item.itemDesciption,
                            itemCount: item.itemCount,
                            itemGroup: '',
                            itemImage: item.image,
                            itemUom: '',
                            baseRate: double.parse(item.price),
                            baseAmount:
                                double.parse(item.price) * item.itemCount,
                            netRate: double.parse(item.price),
                            netAmount:
                                double.parse(item.price) * item.itemCount,
                            pricingRules: '',
                            isFreeItem: item.itemCount == 0,
                            itemTaxRate: item.tax,
                            // invoice: invoiceNo,
                            customername: _selectedCustomer!,
                          ))
                      .toList();

                  double discountamount = 0.0;

                  if (_discountController.text.isNotEmpty) {
                    // discountamount = double.parse(_discountController.text);
                    discountamount =
                        double.tryParse(_discountController.text) ?? 0;
                    _setDiscountForCurrentPage(discount);
                  }
                  List<Map<String, dynamic>> soldItemsMap =
                      soldItems.map((item) => item.toMap()).toList();
                  print("soldItems: $soldItemsMap");

                  int fullcount = soldItemsMap.fold(
                      0, (sum, item) => sum + (item['item_count'] as int));
                  print("fullcount$fullcount");

                  // Insert sales items into DB_sales_items with new customer name

                  // Declare responseBody here

                  Map<String, String?> keys = await dbHelper
                      .getApiKeysByCompanyName(selectedCompanyName);
                  // String? apiKey = keys['apiKey'];
                  // String? secretKey = keys['secretKey'];
                  String companyVatNo = keys['vat_number'] ?? '';
                  String companyAddress = keys['main_address'] ?? '';
                  String companyCrNo = keys['cr_no'] ?? '';
                  print("selectedCompany: $selectedCompanyName");
                  // print("selectmode$selectedMode");

                  Future prepareAndPostSalesItems(
                    List<Map<String, dynamic>> soldItemsMap,
                    String selectedCustomer,
                    String selectedCompanyName,
                    DatabaseHelper dbHelper,
                    double discount,
                  ) async {
                    print("selectedModeasync$selectedMode");
                    print("paidamountinasync$paidAmount");
                    // Call postSalesItemsToApi with the fetched keys
                    return await dbHelper.postSalesItemsToApi(
                      soldItemsMap,
                      apiKey,
                      secretKey,
                      selectedCustomer,
                      selectedCompanyName,
                      discount,
                      selectedMode!,
                      paidAmount,
                    );
                  }

                  Map<String, dynamic>? responseBody;
                  // Call the function and assign the result to responseBody
                  responseBody = await prepareAndPostSalesItems(
                      soldItemsMap,
                      _selectedCustomer!,
                      selectedCompanyName,
                      dbHelper,
                      discount);

                  print("Response body in home$responseBody");

                  String? salesInvoice;
                  if (responseBody != null && responseBody['message'] != null) {
                    salesInvoice =
                        responseBody['message']['sales_invoice'] as String?;
                  }

                  await dbHelper.insertSalesItems(soldItemsMap, salesInvoice,
                      _selectedCustomer!, discountamount);

                  print("salesinvoiceafterextraction$salesInvoice");
                  String customerName =
                      customerData['customer_name'] ?? 'Unknown';
                  String customerType = customerData['type'] ?? 'Unknown';
                  String customerEmail = customerData['email'] ?? 'Unknown';
                  String customerAddressType =
                      customerData['address_type'] ?? 'Unknown';
                  String customerState = customerData['state'] ?? 'Unknown';
                  String customerPincode = customerData['pincode'] ?? '00000';

                  String customerAddressTitle =
                      (customerData['address_title'] ?? '') +
                          ' ' +
                          (customerData['address_line1'] ?? '') +
                          ' ' +
                          (customerData['address_line2'] ?? '') +
                          ' ' +
                          (customerData['city'] ?? 'Unknown');

                  String customerCountry =
                      customerData['address_country'] ?? 'Unknown';
                  String customerVatNumber =
                      customerData['vat_number'] ?? 'Unknown';
                  String customercompanyCrNo =
                      customerData['cr_no'] ?? 'Unknown';

                  print("addresstitle$customerAddressTitle");

                  //DB_sales_invoice
                  await dbHelper.insertSalesInvoice(
                    salesInvoice: salesInvoice,
                    companyName: selectedCompanyName,
                    customerName: customerName,
                    customerAddressTitle: customerAddressTitle,
                    companyAddress: companyAddress,
                    discountAmount: discountamount,
                    subtotal: subtotal,
                    totaltax: tax,
                    total: total,
                    totalQuantity: fullcount,
                    taxID: fetchVat,
                  );
                  print("fullcount$fullcount");
                  print("fetchVat$fetchVat");

                  // Print bill after inserting and posting
                  final printService = PrintService();
                  final generatePDF = GeneratePDF();

                  // String qrData = await generateQR(selectedCompanyName, fetchVat);
                  // Uint8List qrData = await generateQR(selectedCompanyName, fetchVat);
                  // String base64QrData = base64Encode(qrData);
                  File qrFile = await generateQR(selectedCompanyName, fetchVat);
                  if (salesInvoice != null) {
                    // await printService.printBill(
                     await generatePDF.generate3inch(
                        orderedItems,
                        subtotal,
                        tax,
                        total,
                        _selectedCustomer!,
                        salesInvoice, // Pass the sales_invoice as a string to printBill
                        selectedCompanyName,
                        customerName,
                        customerAddressTitle,
                        customerVatNumber,
                        customercompanyCrNo,
                        companyVatNo,
                        companyCrNo,
                        companyAddress,
                        discountamount,
                        qrFile);
                  } else {
                    print("Error: salesInvoice is null, cannot print bill.");
                  }

                  print("Print job started.");
                  // Update previousCustomer after the sale is successfully processed
                  previousCustomer =
                      _selectedCustomer; // Update to track customer change
                  _clearFields();
                  _clearSelectedCustomerForCurrentPage();
                } catch (e) {
                  print(
                      "Error occurred while processing sale: ${e.toString()}");
                }
              } catch (e) {
                print("Unexpected error: $e");
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
                  // SizedBox(height: 10),
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

  Widget _paidAmount() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(7),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: const Color.fromARGB(155, 222, 229, 231),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: paidAmountController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter
                        .digitsOnly, // Only numbers allowed
                  ],
                  decoration: const InputDecoration(
                    labelText: 'Paying Amount',
                    border: InputBorder.none,
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    double paidAmount =
                        double.tryParse(paidAmountController.text) ?? 0;
                    _setPaidAmountForCurrentPage(paidAmount);
                    print(
                        "Entered amount for Page $currentPageIndex: $paidAmount");
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4285F4),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 15,
                    ),
                    SizedBox(width: 3),
                    Text(
                      'OK',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _modeSelector() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: const Color.fromARGB(155, 222, 229, 231),
      ),
      child: DropdownButton<String>(
        isExpanded: true,
        hint: const Text("Mode Of Payment"),
        value: _getSelectedModeForCurrentPage(),
        items: modesOfPayments.map((mode) {
          return DropdownMenuItem<String>(
            value: mode['mode_name'],
            child: Text(mode['mode_name'] ?? ''),
          );
        }).toList(),
        onChanged: (selected) {
          _setSelectedModeForCurrentPage(selected);
          print("Selected Mode for Page $currentPageIndex: $selected");
        },
      ),
    );
  }

  Widget _viewCustomerList(BuildContext context) {
    return SizedBox(
      width: double.infinity, // Makes the bfutton take full width
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF4285F4), // Set the color here
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
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
                            items: _filteredCustomers.map((String? customer) {
                              return DropdownMenuItem<String>(
                                value: customer,
                                child: Text(
                                  customer!,
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
          mainAxisSize:
              MainAxisSize.max, // Use max to take full available space
          mainAxisAlignment:
              MainAxisAlignment.center, // Center the content horizontally
          crossAxisAlignment:
              CrossAxisAlignment.center, // Center the content vertically
          children: [
            const Icon(
              Icons.person,
              color: Colors.white,
              size: 16, // Icon stays constant
            ),
            const SizedBox(width: 8), // Space between the icon and text
            FittedBox(
              fit: BoxFit.scaleDown, // Ensures the text scales down if needed
              alignment:
                  Alignment.center, // Centers the text inside the FittedBox
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
      ),
    );
  }
}
