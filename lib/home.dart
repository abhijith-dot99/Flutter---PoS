import 'dart:convert';
import 'dart:developer';
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
  final bool? showImages; // Add this parameter
  final bool? a4;
  final Map<String, dynamic>? datas;

  const HomePage({Key? key, this.showImages, this.a4, this.datas})
      : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  final dbHelper = DatabaseHelper(); // Initialize dbHelper
  double companyTax = 0.0;
  double fetchedTax = 0.0;
  String fetchVat = '';
  // String qrData = 'afpc';
// double subtotal = 0.0;
  bool isManuallyUpdated = false;
  double currentDiscount = 0.0;
  String? selectedMode;
  double paidAmount = 0;
  double vatPercent = 0.15;

  String? selectedModePage1, selectedModePage2, selectedModePage3;
  double paidAmountPage1 = 0, paidAmountPage2 = 0, paidAmountPage3 = 0;

  String selectedCategory = 'All'; // Track the selected category
  List<Item> searchResults = [];
  List<Item> orderedItems = [];
  List<Items> soldItems = [];
  int isReturn = 0;
  String? returnAgainst = '';

  List<Map<String, dynamic>> soldItemsMap = [];
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
  String? selectedModeOfPayment;
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
  late final Map<String, dynamic>? _localDatas;

  double jsonDiscount = 0.0;
  double jsonTaxAmount = 0.0;
  double jsonTax = 0.0;
  String? jsonInvoice = '';
  double jsonSubtotal = 0.0;
  double jsonGrandTotal = 0.0;
  double manualDiscount = 0.0;
  bool _isJsonDiscountFetched = false;
  bool _isjsonTaxRateFetched = false;
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
    checkData();

    selectedMode = _getSelectedModeForCurrentPage();

    print("data in home${widget.datas}");
  }

  void checkData() {
    if (widget.datas == null) {
      print("nothing");
    } else {
      final Map<String, dynamic> message = widget.datas?['message'] ?? {};
      double initialPaidAmount = message['paid_amount'] ?? 0.0;

      // Initialize controller and state
      paidAmountController.text = initialPaidAmount.toString();
      _setPaidAmountForCurrentPage(initialPaidAmount);
      _fetchJsonDiscount();
      _fetchJsonTax();
      _fetchJsonSubTotal();
      _fetchJsonGrandTotal();
      // _paidAmount();
    }
  }

  void _fetchJsonDiscount() {
    print("inside fetchdisocunt");
    if (!_isJsonDiscountFetched &&
        widget.datas != null &&
        widget.datas!['message'] != null) {
      final Map<String, dynamic> message = widget.datas!['message']!;
      jsonDiscount = message['discount_amount'] ?? 0.0;

      // Set the initial discount in the controller if JSON discount is valid
      if (jsonDiscount > 0) {
        _discountController.text = jsonDiscount.toStringAsFixed(2);
      }
      _isJsonDiscountFetched = true; // Ensures this runs only once
    }
  }

  String? _fetchInvocie() {
    if (widget.datas != null && widget.datas!['message'] != null) {
      final Map<String, dynamic> message = widget.datas!['message']!;
      String d = message['invoice_no'];
      print("{message$d");
      return message['invoice_no'] ?? ''; // Return the invoice number
    }
    return null; // Return null if no invoice number is found
  }

  // void _fetchJsonTax() {
  //   // Safely check if widget.datas and widget.datas['message'] are not null
  //   final Map<String, dynamic>? message = widget.datas?['message'];

  //   if (message != null &&
  //       message['taxes'] != null &&
  //       message['taxes'].isNotEmpty) {
  //     List<dynamic> taxes = message['taxes'];
  //     for (var tax in taxes) {
  //       // Safely access tax_amount and handle nulls
  //       double taxAmount = tax['tax_amount'] ?? 0.0; // Default to 0.0 if null
  //       print("Fetched Tax Amount: $taxAmount");
  //       jsonTaxAmount = taxAmount;
  //     }
  //   } else {
  //     // If there's no taxes data, you can set default or handle accordingly
  //     print("No taxes data found.");
  //   }
  // }

  void _fetchJsonTax() {
    // Safely check if widget.datas and widget.datas['message'] are not null
    final Map<String, dynamic>? message = widget.datas?['message'];

    if (message != null &&
        message['taxes'] != null &&
        message['taxes'].isNotEmpty) {
      List<dynamic> taxes = message['taxes'];
      if (!isManuallyUpdated) {
        print("isManuallyUpdated$isManuallyUpdated");
        for (var tax in taxes) {
          // Safely access tax_amount and handle nulls
          double taxAmount = tax['tax_amount'] ?? 0.0; // Default to 0.0 if null
          print("Fetched Tax Amount: $taxAmount");
          jsonTaxAmount = taxAmount;
        }
      }
    } else {
      // If there's no taxes data, you can set default or handle accordingly
      print("No taxes data found.");
    }
  }

  void calculateNewTotal() {
    print("Calculating new total...");

    // Initialize subtotal, discount, and tax variables
    double updatedSubtotal = 0.0;
    double updatedTotalTax = 0.0;
    double discount = 0.0;

    // Safely extract items from widget data
    final List<dynamic> items = widget.datas?['message']?['items'] ?? [];
    final Map<String, dynamic>? message = widget.datas?['message'];

    if (message != null) {
      // Fetch discount amount if available
      // discount = (message['discount_amount'] is String)
      //     ? double.tryParse(message['discount_amount']) ?? 0.0
      //     : (message['discount_amount'] ?? 0.0);

      if (_discountController.text.isNotEmpty) {
        print("in if discppunt");
        // discount = double.parse(_discountController.text);
        discount = double.tryParse(_discountController.text) ?? 0;
        print("dicount in $discount");
        // _setDiscountForCurrentPage(discount);
      } else {
        print("in else discount");
        discount = (message['discount_amount'] is String)
            ? double.tryParse(message['discount_amount']) ?? 0.0
            : (message['discount_amount'] ?? 0.0);
      }

      print("Fetched discount: $discount");

      // Fetch company tax rate
      double companyTax = 0.0;
      if (message['taxes'] != null && message['taxes'].isNotEmpty) {
        var tax = message['taxes'][0]; // Assuming single tax rate
        companyTax = (tax['rate'] is String)
            ? double.tryParse(tax['rate']) ?? 0.0
            : (tax['rate'] ?? 0.0);
      }

      print("Fetched company tax rate: $companyTax%");

      // Iterate over updated items to calculate subtotal and tax
      for (var item in items) {
        double price = (item['rate'] is String)
            ? double.tryParse(item['rate']) ?? 0.0
            : (item['rate'] ?? 0.0);
        int quantity = (item['qty'] is String)
            ? int.tryParse(item['qty']) ?? 0
            : (item['qty'] ?? 0);

        double itemTotal = price * quantity;
        double itemTax = itemTotal * (companyTax / 100);

        updatedSubtotal += itemTotal;
        updatedTotalTax += itemTax;

        print(
            "Item ${item['item_code']} - Quantity: $quantity, Price: $price, Item Total: $itemTotal, Item Tax: $itemTax");
      }

      // Apply discount proportion to tax
      double discountProportion =
          updatedSubtotal > 0 ? (discount / updatedSubtotal) : 0.0;
      updatedTotalTax = updatedTotalTax * (1 - discountProportion);
      print("padiamountincalculatnew$paidAmount");

      // Calculate new total
      double newTotal =
          updatedSubtotal + updatedTotalTax - discount;

      // Ensure total is not negative
      if (newTotal < 0) {
        newTotal = 0;
      }

      print("Updated Subtotal: $updatedSubtotal");
      print("Updated Total Tax: $updatedTotalTax");
      print("Updated Grand Total: $newTotal");

      // Assign to jsonGrandTotal
      setState(() {
        jsonGrandTotal = newTotal;
      });
      print("jsongrandinnew$jsonGrandTotal");
    } else {
      print("No valid message data found to calculate new total.");
    }
  }

  void updateTaxDetails() {
    print("Inside updateTaxDetails, Paid Amount: $paidAmount");

    // Extract the data safely
    final Map<String, dynamic>? data = widget.datas?['message'];

    if (data != null && data['taxes'] != null && data['items'] != null) {
      // Safely parse discount amount
      double discountInUp = (data['discount_amount'] is String)
          ? double.tryParse(data['discount_amount']) ?? 0.0
          : (data['discount_amount'] ?? 0.0);
      print("Discount Amount in Update: $discountInUp");

      // Extract items and taxes
      List<dynamic> items = data['items'];
      List<dynamic> taxes = data['taxes'];

      // Calculate subtotal and tax rate
      double subtotal =
          jsonSubtotal; // Use the provided `jsonSubtotal` as the base
      double totalTax = 0.0;

      print("Initial Subtotal: $subtotal");
      print("Initial Tax Amount: $jsonTaxAmount");

      // Fetch tax rate from taxes list
      if (taxes.isNotEmpty) {
        var tax = taxes.first; // Assuming a single tax rate applies
        companyTax = (tax['rate'] is String)
            ? double.tryParse(tax['rate']) ?? 0.0
            : (tax['rate'] ?? 0.0);
        print("Company Tax Rate: $companyTax%");
      } else {
        print("No taxes found in data!");
      }

      // Iterate over items
      for (var item in items) {
        // Safely parse item details
        double price = (item['rate'] is String)
            ? double.tryParse(item['rate']) ?? 0.0
            : (item['rate'] ?? 0.0);
        int itemQuantity = (item['qty'] is String)
            ? int.tryParse(item['qty']) ?? 0
            : (item['qty'] ?? 0);

        print("Processing Item: ${item['item_code'] ?? 'Unknown'}");
        print("Item Price: $price, Item Quantity: $itemQuantity");

        // Calculate item total
        double itemTotal = price * itemQuantity;
        print("Item Total (Price * Quantity): $itemTotal");

        // Calculate company tax for the item
        double companyTaxAmount = itemTotal * (companyTax / 100);
        print("Company Tax Amount (Item Total * Tax Rate): $companyTaxAmount");

        // Calculate discount proportion
        double discountProportion =
            subtotal > 0 ? (discountInUp / subtotal) : 0.0;
        print("Discount Proportion (Discount / Subtotal): $discountProportion");

        // Apply discount to company tax
        double discountedCompanyTax =
            companyTaxAmount * (1 - discountProportion);
        print(
            "Discounted Company Tax (Company Tax * (1 - Discount Proportion)): $discountedCompanyTax");
        print(
            "Discounted Company Tax (Company Tax * (1 - Discount Proportion)): ${discountedCompanyTax.runtimeType}");
        // Add to total tax
        totalTax += discountedCompanyTax;
        print("totaltaxin update${totalTax}");
        print("totaltaxin update${totalTax.runtimeType}");
      }

      // Update jsonTaxAmount with calculated total tax
      jsonTaxAmount = totalTax;
      print("Updated jsonTaxAmount: $jsonTaxAmount");
    } else {
      print("Invalid or missing data. Cannot update tax details.");
    }
  }


  void updateItemDetails(int index, String quantity, String rate) {
    print("insdie updateitems");
    final Map<String, dynamic>? data = widget.datas?['message'];
    List<dynamic> taxes = data?['taxes'];

    for (var tax in taxes) {
      companyTax = (tax['rate'] is String) // Safely parse tax amount
          ? double.tryParse(tax['rate']) ?? 0.0
          : (tax['rate'] ?? 0.0);
      print("Fetched Radd Amount: $companyTax");
    }

    // Update the item at the specified index
    items[index].itemCount = int.parse(quantity); // Convert quantity to integer
    items[index].price = rate; // Update price with new value

    // Mark that the update is coming from the UI (manual)
    isManuallyUpdated = true;

    // Calculate the updated amount locally (you can update a new field or subtotal based on itemCount and price)
    jsonSubtotal = items[index].itemCount * (double.tryParse(rate) ?? 0.0);
    print("companytaxoutinitem$companyTax");

    // double companyTaxAmount = jsonSubtotal;
    // double companyTaxAmount = jsonSubtotal / companyTax;
    // print("companytaxin$companyTaxAmount");
    jsonTaxAmount = companyTax;

    print("Updated Amount: $jsonTaxAmount");

    // After updating the item, calculate the updated subtotal
  }

// Function to fetch and calculate the new subtotal from the API response
  void _fetchJsonSubTotal() {
    print("inside fetchsub");

    // Safely check if widget.datas and widget.datas['message'] are not null
    final Map<String, dynamic>? message = widget.datas?['message'];

    if (message != null &&
        message['taxes'] != null &&
        message['items'].isNotEmpty) {
      List<dynamic> items = message['items'];
      List<dynamic> taxes = message['taxes'];
      for (var tax in items) {
        // Only update if it's not a manual update
        if (!isManuallyUpdated) {
          // Safely access net_amount and handle null values
          double fetchSubAmount =
              tax['net_amount'] ?? 0.0; // Default to 0.0 if null
          print("Fetched Sub Amount: $fetchSubAmount");

          // Only trigger the state update if the value has changed
          if (fetchSubAmount != jsonSubtotal) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              setState(() {
                jsonSubtotal = fetchSubAmount;
              });

              // Optionally, update the UI or perform any other actions with the new subtotal
              print("Updated Subtotal: $jsonSubtotal");
            });
          }
        } else {
          print("Subtotal is manually updated, skipping API update.");
        }
      }
    } else {
      // If there's no taxes data, handle accordingly
      print("No subtotal found.");
    }

    // Reset the flag after the API call
    isManuallyUpdated = false;
  }

  void _fetchJsonGrandTotal() {
    print("insidefetchGrandtotal");
    final List<dynamic> dataItems = widget.datas?['message']?['items'] ?? [];
    final Map<String, dynamic> dataItems1 = widget.datas?['message'] ?? {};

    print("dataitem$dataItems");
    print("dtaitems2$dataItems1");
    if (widget.datas != null && widget.datas!['message'] != null) {
      final Map<String, dynamic> message = widget.datas!['message']!;
      jsonGrandTotal = message['grand_total'] ?? 0.0;
    }
  }

  void _clearFields() {
    setState(() {
      // Clear each widget's controller or variable
      _discountController.clear();
      paidAmountController.clear();
      selectedMode = null;
      orderedItems.clear();

      // _selectedCustomer = null;
      // paidAmount = 0;
      // _getSelectedCustomerForCurrentPage();
    });
  }

  void _clearSelectedCustomerForCurrentPage() {
    setState(() {
      if (currentPageIndex == 1) {
        _selectedCustomerPage1 = null;
        selectedModePage1 = null;
        paidAmountPage1 = 0;
        discountPage1 = 0;
        orderedItemsPage1 = [];
      } else if (currentPageIndex == 2) {
        _selectedCustomerPage2 = null;
        selectedModePage2 = null;
        paidAmountPage2 = 0;
        discountPage1 = 0;
        orderedItemsPage2 = [];
      } else if (currentPageIndex == 3) {
        _selectedCustomerPage3 = null;
        selectedModePage3 = null;
        paidAmountPage3 = 0;
        discountPage1 = 0;
        orderedItemsPage3 = [];
      }
    });
  }

  String? _getSelectedCustomerForCurrentPage() {
    print("inside getselectedcust");
    if (currentPageIndex == 1) {
      // print("getcust$_selectedCustomerPage1");
      print("_selectedCustomerPage1$_selectedCustomerPage1");

      return _selectedCustomerPage1;
    } else if (currentPageIndex == 2) {
      print("_selectedCustomerPage2$_selectedCustomerPage2");
      return _selectedCustomerPage2;
    } else if (currentPageIndex == 3) {
      print("_selectedCustomerPage3$_selectedCustomerPage3");
      return _selectedCustomerPage3;
    }
    return null;
  }

  void _setSelectedCustomerForCurrentPage(String? newValue) {
    print("insdie setselectd");
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

  String? _extractModeOfPayment() {
    if (widget.datas?['message']?['payments'] != null &&
        widget.datas?['message']['payments'].isNotEmpty) {
      return widget.datas?['message']['payments'][0]['mode_of_payment'];
    }
    return null;
  }

// Get the selected mode for the current page with dataItems check
  // String? _getSelectedModeForCurrentPage() {
  //   // If dataItems is not empty, set the initial mode of payment from widget.datas
  //   if ({widget.datas}.isNotEmpty) {
  //     final modeFromData = _extractModeOfPayment();
  //     print("modefromdta$modeFromData");
  //     if (modeFromData != null) {
  //       // Set the mode based on the page index if it's the first time fetching
  //       if (currentPageIndex == 1 && selectedModePage1 == null) {
  //         selectedModePage1 = modeFromData;
  //         return selectedModePage1;
  //       } else if (currentPageIndex == 2 && selectedModePage2 == null) {
  //         selectedModePage2 = modeFromData;
  //         return selectedModePage2;
  //       } else if (currentPageIndex == 3 && selectedModePage3 == null) {
  //         selectedModePage3 = modeFromData;
  //         return selectedModePage3;
  //       }
  //     }
  //   }

  //   // Return the selected mode for the current page
  //   if (currentPageIndex == 1) {
  //     return selectedModePage1;
  //   } else if (currentPageIndex == 2) {
  //     return selectedModePage2;
  //   } else if (currentPageIndex == 3) {
  //     return selectedModePage3;
  //   }
  //   return null;
  // }

  String? _getSelectedModeForCurrentPage() {
    // If widget.datas is not null or empty, set the initial mode of payment from widget.datas
    if (widget.datas != null && widget.datas!.isNotEmpty) {
      final modeFromData = _extractModeOfPayment();
      print("Mode from data: $modeFromData");

      // Set the mode based on the current page if it's the first time fetching
      if (modeFromData != null) {
        if (currentPageIndex == 1 && selectedModePage1 == null) {
          selectedModePage1 = modeFromData;
          return selectedModePage1;
        } else if (currentPageIndex == 2 && selectedModePage2 == null) {
          selectedModePage2 = modeFromData;
          return selectedModePage2;
        } else if (currentPageIndex == 3 && selectedModePage3 == null) {
          selectedModePage3 = modeFromData;
          return selectedModePage3;
        }
      }
    }

    // Return the selected mode for the current page if already set
    if (currentPageIndex == 1) {
      return selectedModePage1;
    } else if (currentPageIndex == 2) {
      return selectedModePage2;
    } else if (currentPageIndex == 3) {
      return selectedModePage3;
    }

    return null;
  }

// Set the selected mode for the current page
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

// Getter for selectedMode
//   String? _getSelectedModeForCurrentPage() {
//     if (currentPageIndex == 1) {
//       return selectedModePage1;
//     } else if (currentPageIndex == 2) {
//       return selectedModePage2;
//     } else if (currentPageIndex == 3) {
//       return selectedModePage3;
//     }
//     return null;
//   }

// // Setter for selectedMode
//   void _setSelectedModeForCurrentPage(String? mode) {
//     setState(() {
//       if (currentPageIndex == 1) {
//         selectedModePage1 = mode;
//         selectedMode = selectedModePage1;
//       } else if (currentPageIndex == 2) {
//         selectedModePage2 = mode;
//         selectedMode = selectedModePage2;
//       } else if (currentPageIndex == 3) {
//         selectedModePage3 = mode;
//         selectedMode = selectedModePage3;
//       }
//     });
//   }

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
    print("inside setdisocunt curretn$discount");
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        if (currentPageIndex == 1) {
          discountPage1 = discount;
          discount = discountPage1;
        } else if (currentPageIndex == 2) {
          discountPage2 = discount;
          discount = discountPage2;
        } else if (currentPageIndex == 3) {
          discountPage3 = discount;
          discount = discountPage3;
        }
      });
    });
  }

  void _openPage(int pageIndex) {
    setState(() {
      // Switch to the new page and load its items
      currentPageIndex = pageIndex;

      if (currentPageIndex == 1) {
        orderedItems = List.from(orderedItemsPage1);
        _selectedCustomer = _selectedCustomerPage1;
        paidAmountController.text = paidAmountPage1.toString();
        //   if (paidAmountController.text.isEmpty) {
        //   paidAmountController.text = paidAmountPage1.toString();
        // }
        _discountController.text = _getDiscountForCurrentPage().toString();
        print(
            "Loaded selected customer and paid amount for Page 1${_discountController.text}");
      } else if (currentPageIndex == 2) {
        orderedItems = List.from(orderedItemsPage2);
        _selectedCustomer = _selectedCustomerPage2;
        paidAmountController.text = paidAmountPage2.toString();
        //   if (paidAmountController.text.isEmpty) {
        //   paidAmountController.text = paidAmountPage2.toString();
        // }
        _discountController.text = _getDiscountForCurrentPage().toString();
        print("Loaded selected customer and paid amount for Page 2");
      } else if (currentPageIndex == 3) {
        orderedItems = List.from(orderedItemsPage3);
        _selectedCustomer = _selectedCustomerPage3;
        paidAmountController.text = paidAmountPage3.toString();
        //   if (paidAmountController.text.isEmpty) {
        //   paidAmountController.text = paidAmountPage3.toString();
        // }
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
    print("inside addditem toordr");
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
                                        widget.showImages! ? item.image : null,
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
    required List<dynamic> items, // Add items parameter
  }) {
    print("insdie itemorder");
    double itemPrice = double.parse(price.replaceAll(' ', ''));

    // int quantity = itemCount;
    int quantity =
        itemCount > 0 ? itemCount : 1; // Ensure quantity starts at 1 if not set

    double total = itemPrice * quantity;
    print("totatl in itemorder$total");
    editingItemIndex = index; // Set the index of the item being edited
    input = ''; //initialized the input
    return GestureDetector(
      onTap: () {
        _showEditDialog(context, index, items);
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


void _showEditDialog(BuildContext context, int index, List<dynamic> items) {
  print("inside showedit dialog");
  final item = items[index];

  // Check if the item is a Map or an Item object
  TextEditingController quantityController = TextEditingController(
      text: item is Map
          ? item['qty']?.toString() ?? '0'
          : item.itemCount.toString());
  TextEditingController priceController = TextEditingController(
      text: item is Map ? item['rate']?.toString() ?? '0' : item.price);

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
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
                hintStyle: TextStyle(color: Colors.black54),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: priceController,
              style: const TextStyle(color: Colors.black),
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
              ],
              decoration: InputDecoration(
                hintText: 'Enter Valid Price',
                hintStyle: TextStyle(color: Colors.black54),
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
            child: const Text('Cancel'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          ElevatedButton(
            child: const Text('Save'),
            onPressed: () {
              setState(() {
                if (item is Item) {
                  // Update the Item object
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
                } else if (item is Map) {
                  // Update the Map structure
                  items[index]['qty'] = int.parse(quantityController.text);
                  items[index]['rate'] = priceController.text;
                  updateItemDetails(
                      index, quantityController.text, priceController.text);
                  updateTaxDetails();
                  calculateNewTotal();
                }
              });
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}

  // void _showEditDialog(BuildContext context, int index, List<dynamic> items) {
  //   print("inside showedit dialog");
  //   final item = items[index];

  //   TextEditingController quantityController = TextEditingController(
  //       text: item['qty']?.toString() ?? item.itemCount.toString());
  //   TextEditingController priceController =
  //       TextEditingController(text: item['rate']?.toString() ?? item.price);

  //   showDialog(
  //     context: context,
  //     builder: (BuildContext context) {
  //       return AlertDialog(
  //         backgroundColor: Colors.white,
  //         shape: RoundedRectangleBorder(
  //           borderRadius: BorderRadius.circular(20),
  //         ),
  //         title: const Text(
  //           'Edit Item',
  //           style: TextStyle(color: Colors.black),
  //         ),
  //         content: Column(
  //           mainAxisSize: MainAxisSize.min,
  //           children: [
  //             TextField(
  //               controller: quantityController,
  //               style: const TextStyle(color: Colors.black),
  //               keyboardType: TextInputType.number,
  //               inputFormatters: [
  //                 FilteringTextInputFormatter.digitsOnly,
  //               ],
  //               decoration: InputDecoration(
  //                 hintText: 'Enter Valid Quantity',
  //                 hintStyle: TextStyle(color: Colors.black54),
  //                 border: OutlineInputBorder(
  //                   borderRadius: BorderRadius.circular(12),
  //                 ),
  //                 filled: true,
  //                 fillColor: Colors.white,
  //               ),
  //             ),
  //             const SizedBox(height: 10),
  //             TextField(
  //               controller: priceController,
  //               style: const TextStyle(color: Colors.black),
  //               keyboardType: TextInputType.number,
  //               inputFormatters: [
  //                 FilteringTextInputFormatter.digitsOnly,
  //               ],
  //               decoration: InputDecoration(
  //                 hintText: 'Enter Valid Price',
  //                 hintStyle: TextStyle(color: Colors.black54),
  //                 border: OutlineInputBorder(
  //                   borderRadius: BorderRadius.circular(12),
  //                 ),
  //                 filled: true,
  //                 fillColor: Colors.white,
  //               ),
  //             ),
  //           ],
  //         ),
  //         actions: <Widget>[
  //           TextButton(
  //             child: const Text('Cancel'),
  //             onPressed: () {
  //               Navigator.of(context).pop();
  //             },
  //           ),
  //           ElevatedButton(
  //             child: const Text('Save'),
  //             onPressed: () {
  //               setState(() {
  //                 if (items == orderedItems) {
  //                   // Update orderedItems
  //                   orderedItems[index] = Item(
  //                     image: item.image,
  //                     itemName: item.itemName,
  //                     itemCode: item.itemCode,
  //                     itemDesciption: item.itemDesciption,
  //                     price: priceController.text,
  //                     tax: item.tax,
  //                     companyTax: item.companyTax,
  //                     itemCount: int.parse(quantityController.text),
  //                     itemtaxtype: item.itemtaxtype,
  //                   );
  //                 } else {
  //                   // Update dataItems structure
  //                   items[index]['qty'] = int.parse(quantityController.text);
  //                   items[index]['rate'] = priceController.text;
  //                   updateItemDetails(
  //                       index, quantityController.text, priceController.text);
  //                   updateTaxDetails();
  //                   calculateNewTotal();
  //                 }
  //               });
  //               Navigator.of(context).pop();
  //             },
  //           ),
  //         ],
  //       );
  //     },
  //   );
  // }


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
      // itemTotal = itemTotal - paidAmount;
      print("qunatity in calculatetax$quantity");
      print("pricein calulatetax$price");
      print("itemTotal$itemTotal");
      print("companyTaxincalculattax$companyTax");

      // Calculate company tax before discount
      double companyTaxAmount = itemTotal * (companyTax / 100);
      print("companyTaxAmount in$companyTaxAmount");

      // Calculate the taxable amount after applying discount proportionally
      double discountProportion = discount / calculateSubtotal();
      print("discountProportion$discount");
      print("discountincalculatetax$discountProportion");
      double discountedCompanyTax = companyTaxAmount * (1 - discountProportion);
      print("discountedcompanytax$discountedCompanyTax");

      // Add discounted tax to the total
      totalTax += discountedCompanyTax;
      print("totalTax$totalTax");
    }
    // totalTax = totalTax - paidAmount;
    return totalTax;
  }

  double calculateTotal() {
    print("inside calculateTotal");
    double subtotal = calculateSubtotal();
    double discount = 0.0;

    // Check if discount is not empty and parse it
    if (_discountController.text.isNotEmpty) {
      discount = double.tryParse(_discountController.text) ?? 0;
    } else {
      // Fallback to `calculateNewTotal` when discount is empty
      calculateNewTotal();
      print("in else");
    }

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

// Calculate the total amount including tax and discount
  // double calculateTotal() {
  //   print("inside calculatetotal");
  //   double subtotal = calculateSubtotal();
  //   double discount = 0.0;

  //   // Check if discount is not empty and parse it
  //   if (_discountController.text.isNotEmpty) {
  //     // discount = double.parse(_discountController.text);
  //     discount = double.tryParse(_discountController.text) ?? 0;
  //     // _setDiscountForCurrentPage(discount);
  //   } else {
  //     calculateNewTotal();
  //     print("in else");
  //   }

  //   double vatAmount = subtotal - discount * vatPercent;

  //   // Calculate tax after applying discount
  //   double totalTax = calculateTax(discount);

  //   // Subtract the discount from the subtotal
  //   double total =
  //       subtotal + totalTax - discount - _getPaidAmountForCurrentPage();

  //   // Ensure total doesn't go below zero
  //   if (total < 0) {
  //     total = 0;
  //   }

  //   return total;
  // }

  double calculateVatAmount() {
    double subtotal = calculateSubtotal();
    double discount = 0.0;

    // Check if discount is not empty and parse it
    if (_discountController.text.isNotEmpty) {
      // discount = double.parse(_discountController.text);
      discount = double.tryParse(_discountController.text) ?? 0;
      // _setDiscountForCurrentPage(discount);
    }
    double vatAmount = subtotal - discount * vatPercent;

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

  void _updateDiscount(double newDiscount) {
    if (newDiscount != currentDiscount) {
      // Only update if the discount is different
      currentDiscount = newDiscount;
      _setDiscountForCurrentPage(newDiscount);
    }
  }

  Widget _calculateAndPrintSection() {
    // final List<dynamic> dataItems = widget.datas?['message']?['items'] ?? [];
    // final Map<String, dynamic> message = widget.datas?['message'] ?? {};
    //   print("dataitems in calculate$message");

    //   double totalAmount = 0.0;
    double discount = 0.0;

    // Determine the discount based on either JSON or manual input
    manualDiscount = double.tryParse(_discountController.text) ?? 0.0;
    discount = jsonDiscount > 0 ? jsonDiscount : manualDiscount;
    print("manual discont$manualDiscount");

    // double subtotal = calculateSubtotal();
    double subtotal = jsonSubtotal > 0.0 ? jsonSubtotal : calculateSubtotal();
    // double tax = calculateTax(discount);
    double tax = jsonTaxAmount > 0.0 ? jsonTaxAmount : calculateTax(discount);
    // double total = calculateTotal();
    double total = jsonGrandTotal > 0.0 ? jsonGrandTotal : calculateTotal();
    // _setPaidAmountForCurrentPage(paidAmount);

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
                //  _setPaidAmountForCurrentPage(paidAmount),
                paidAmount.toStringAsFixed(2),
                // _getPaidAmountForCurrentPage(paidAmount),

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
                  // onChanged: (value) {
                  //   print("changing");
                  //   setState(() {
                  //     total = calculateTotal();
                  //   });
                  // },

                  onChanged: (value) {
                    print("Discount field changed: $value");
                    setState(() {
                      if (!isManuallyUpdated) {
                        // calculateTax(double.tryParse(value) ?? 0.0);
                        total = calculateTotal();
                      } else {
                        calculateNewTotal();
                      }
                      // total = calculateTotal();
                    });
                  },
                ),
              ),
            ],
          ),

          // Row(
          //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //   children: [
          //     const Text('Discount',
          //         style: TextStyle(
          //             fontWeight: FontWeight.bold, color: Colors.black87)),
          //     Row(
          //       children: [
          //         SizedBox(
          //           width: 50, // Adjust the width as needed
          //           child: TextField(
          //             controller: _discountController,
          //             style: const TextStyle(
          //                 fontWeight: FontWeight.bold,
          //                 fontSize: 14,
          //                 color: Colors.black87),
          //             textAlign: TextAlign.end,
          //             decoration: const InputDecoration(
          //               contentPadding:
          //                   EdgeInsets.all(0), // Adjust padding as needed
          //               hintText: '0.00', // Hint text
          //               hintStyle: TextStyle(
          //                 color:
          //                     Colors.grey, // Light grey color for the hint text
          //                 fontWeight: FontWeight.normal, // Adjust font weight
          //               ),
          //             ),
          //             keyboardType:
          //                 const TextInputType.numberWithOptions(decimal: true),
          //             inputFormatters: [
          //               FilteringTextInputFormatter.allow(
          //                   RegExp(r'^\d*\.?\d*')), // Allow decimal numbers
          //             ],
          //           ),
          //         ),
          //         const SizedBox(
          //             width: 10), // Space between TextField and Button
          //         ElevatedButton(
          //           onPressed: () {
          //             setState(() {
          //               // Fetch the discount from the TextField
          //               manualDiscount =
          //                   double.tryParse(_discountController.text) ?? 0.0;
          //             });
          //           },
          //           style: ElevatedButton.styleFrom(
          //             padding: const EdgeInsets.symmetric(
          //                 horizontal: 10, vertical: 5),
          //             backgroundColor: Colors.blue, // Button background color
          //           ),
          //           child: const Text(
          //             'Apply',
          //             style:
          //                 TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
          //           ),
          //         ),
          //       ],
          //     ),
          //   ],
          // ),

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
                            isReturn: 0,
                            returnAgainst: '',
                          ))
                      .toList();

                  void setSoldItemsFromData() {
                    print("Inside setSoldItemsFromData");

                    try {
                      if (soldItemsMap.isEmpty &&
                          widget.datas != null &&
                          widget.datas!['message'] != null) {
                        final Map<String, dynamic> message =
                            widget.datas!['message']!;

                        returnAgainst = _fetchInvocie() ?? '';
                        isReturn = 1;

                        List<dynamic> items = message['items'] ?? [];

                        soldItems = items.map((item) {
                          print("Processing item: $item"); // Debug raw data

                          return Items(
                            itemCode: item['item_code']?.toString() ??
                                '', // Convert to String
                            itemName: item['item_name']?.toString() ??
                                '', // Convert to String
                            itemDescription:
                                item['item_description']?.toString() ?? '',
                            itemGroup: item['item_group']?.toString() ?? '',
                            itemImage: item['item_image']?.toString() ?? '',
                            itemUom: item['item_uom']?.toString() ?? '',
                            baseRate: (item['rate'] is double)
                                ? item['rate']
                                : (item['rate'] is int)
                                    ? (item['rate'] as int).toDouble()
                                    : 0.0, // Default fallback
                            baseAmount: (item['amount'] is double)
                                ? item['amount']
                                : (item['amount'] is int)
                                    ? (item['amount'] as int).toDouble()
                                    : 0.0, // Default fallback
                            netRate: (item['net_rate'] is double)
                                ? item['net_rate']
                                : (item['net_rate'] is int)
                                    ? (item['net_rate'] as int).toDouble()
                                    : 0.0, // Default fallback
                            netAmount: (item['net_amount'] is double)
                                ? item['net_amount']
                                : (item['net_amount'] is int)
                                    ? (item['net_amount'] as int).toDouble()
                                    : 0.0, // Default fallback
                            pricingRules:
                                item['pricing_rules']?.toString() ?? '',
                            isFreeItem: (item['is_free_item'] is int)
                                ? (item['is_free_item'] as int) != 0
                                : (item['is_free_item'] is bool)
                                    ? item['is_free_item'] as bool
                                    : false, // Default fallback
                            itemTaxRate: item['item_tax_rate']?.toString() ??
                                '', // Convert to String
                            customername: message['customer']?.toString() ??
                                '', // Convert to String
                            itemCount: (item['qty'] is int)
                                ? item['qty'] as int
                                : (item['qty'] is double)
                                    ? (item['qty'] as double).toInt()
                                    : 1, // Default fallback
                            isReturn: 1,
                            returnAgainst:
                                returnAgainst, // Use an empty string if _fetchInvocie() returns null
                          );
                        }).toList();

                        print("SoldItems after setting from data: $soldItems");
                      }
                    } catch (e, stackTrace) {
                      print("Error occurred while processing sale: $e");
                      print(
                          stackTrace); // Print stack trace for detailed debugging
                    }
                  }

                  double discountamount = 0.0;

                  if (_discountController.text.isNotEmpty) {
                    // discountamount = double.parse(_discountController.text);
                    discountamount =
                        double.tryParse(_discountController.text) ?? 0;
                    _setDiscountForCurrentPage(discount);
                  }

                  if (soldItems.isEmpty) {
                    setSoldItemsFromData();
                  }
                  // List<Map<String, dynamic>>
                  soldItemsMap = soldItems.map((item) => item.toMap()).toList();
                  print("soldItems: $soldItemsMap");

                  int fullcount = soldItemsMap.fold(
                      0, (sum, item) => sum + (item['item_count'] as int));
                  print("fullcount$fullcount");

                  // Declare responseBody here

                  Map<String, String?> keys = await dbHelper
                      .getApiKeysByCompanyName(selectedCompanyName);
                  String companyVatNo = keys['vat_number'] ?? '';
                  String companyAddress = keys['main_address'] ?? '';
                  String companyCrNo = keys['cr_no'] ?? '';
                  print("selectedCompany: $selectedCompanyName");
                  // print("selectmode$selectedMode");
                  print("salesitemsss$soldItemsMap");
                  print("isretyrn$isReturn");
                  print("returnagainst$returnAgainst");

                  Future prepareAndPostSalesItems(
                      List<Map<String, dynamic>> soldItemsMap,
                      String selectedCustomer,
                      String selectedCompanyName,
                      DatabaseHelper dbHelper,
                      double discount,
                      int isReturn,
                      String returnAgainst) async {
                    print("selectedModeasync$selectedMode");
                    print("paidamountinasync$paidAmount");
                    print("solditemsss$soldItemsMap");

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
                        isReturn,
                        returnAgainst,
                        context);
                  }

                  Map<String, dynamic>? responseBody;
                  // Call the function and assign the result to responseBody
                  responseBody = await prepareAndPostSalesItems(
                      soldItemsMap,
                      _selectedCustomer!,
                      selectedCompanyName,
                      dbHelper,
                      discount,
                      isReturn,
                      returnAgainst!);

                  print("Response body in home$responseBody");

                  String? salesInvoice;
                  if (responseBody != null && responseBody['message'] != null) {
                    salesInvoice =
                        responseBody['message']['sales_invoice'] as String?;
                  }
                  File qrFile = await generateQR(selectedCompanyName, fetchVat);

                  print("salesinvoiceafterextraction$salesInvoice");
                  String customerName =
                      customerData['customer_name'] ?? 'Unknown';

                  String customerAddressTitle =
                      (customerData['address_title'] ?? '') +
                          ' ' +
                          (customerData['address_line1'] ?? '') +
                          ' ' +
                          (customerData['address_line2'] ?? '') +
                          ' ' +
                          (customerData['city'] ?? 'Unknown');

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

                  if (salesInvoice != null) {
                    final printService = PrintService();
                    final generatePDF = GeneratePDF();

                    if (widget.a4 == false) {
                      await generatePDF.generate3inch(
                        orderedItems,
                        subtotal,
                        tax,
                        total,
                        _selectedCustomer!,
                        salesInvoice,
                        selectedCompanyName,
                        customerName,
                        customerAddressTitle,
                        customerVatNumber,
                        customercompanyCrNo,
                        companyVatNo,
                        companyCrNo,
                        companyAddress,
                        discountamount,
                        qrFile,
                      );
                    } else {
                      await printService.printBill(
                        orderedItems,
                        subtotal,
                        tax,
                        total,
                        _selectedCustomer!,
                        salesInvoice,
                        selectedCompanyName,
                        customerName,
                        customerAddressTitle,
                        customerVatNumber,
                        customercompanyCrNo,
                        companyVatNo,
                        companyCrNo,
                        companyAddress,
                        discountamount,
                        qrFile,
                      );
                    }

                    print("Print job started.");
                    // Clear fields only if printing was successful
                    _clearFields();
                    _clearSelectedCustomerForCurrentPage();
                    // Update previousCustomer after successful sale processing
                    previousCustomer = _selectedCustomer;
                    await dbHelper.insertSalesItems(soldItemsMap, salesInvoice,
                        _selectedCustomer!, discountamount);
                  } else {
                    print("Error: salesInvoice is null, cannot print bill.");
                  }
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

  // Widget _buildOrderedItemsSection() {
  //   final List<dynamic> dataItems = widget.datas?['message']?['items'] ?? [];
  //   print("orderitemss$orderedItems");
  //   print("dataitemsa$dataItems");
  //   return Container(
  //     decoration: BoxDecoration(
  //       color: Color.fromARGB(155, 239, 241, 241),
  //       borderRadius: BorderRadius.circular(12),
  //     ),
  //     child: orderedItems.isEmpty
  //         ? const Center(
  //             child: Column(
  //               mainAxisAlignment: MainAxisAlignment.center,
  //               crossAxisAlignment: CrossAxisAlignment.center,
  //               children: [
  //                 Icon(
  //                   Icons.shopping_cart_outlined,
  //                   size: 50,
  //                   color: Colors.black26,
  //                 ),
  //                 // SizedBox(height: 10),
  //                 Text(
  //                   'Cart',
  //                   style: TextStyle(
  //                     color: Colors.black26,
  //                     fontSize: 16,
  //                   ),
  //                 ),
  //               ],
  //             ),
  //           )
  //         : ListView.builder(
  //             itemCount: orderedItems.length,
  //             itemBuilder: (context, index) {
  //               final item = orderedItems[index];
  //               // Print the itemCount and its datatype
  //               return _itemOrder(
  //                 image: item.image,
  //                 itemName: item.itemName,
  //                 price: item.price,
  //                 itemCount: item.itemCount,
  //                 index: index,
  //               );
  //             },
  //           ),

  //   );
  // }

  Widget _buildOrderedItemsSection() {
    // Extract dataItems from widget.datas if available
    final List<dynamic> dataItems = widget.datas?['message']?['items'] ?? [];
    print("dataiteminbuild$dataItems");

    return Container(
      decoration: BoxDecoration(
        color: Color.fromARGB(155, 239, 241, 241),
        borderRadius: BorderRadius.circular(12),
      ),
      child: dataItems.isNotEmpty
          ? ListView.builder(
              itemCount: dataItems.length,
              itemBuilder: (context, index) {
                final item = dataItems[index];
                return _itemOrder(
                  image:
                      null, // Placeholder or null as no image data is provided
                  itemName: item['item_name'] ?? 'Unknown Item',
                  price: item['rate']?.toString() ?? '0.0',
                  itemCount: item['qty']?.toInt() ?? 1,
                  index: index,
                  items: dataItems,
                );
              },
            )
          : (orderedItems.isEmpty
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
                    return _itemOrder(
                      image: item.image,
                      itemName: item.itemName,
                      price: item.price.toString(),
                      itemCount: item.itemCount,
                      index: index,
                      items: orderedItems, // Pass orderedItems
                    );
                  },
                )),
    );
  }

  // Widget _paidAmount() {
  //   return Container(
  //     width: double.infinity,
  //     padding: const EdgeInsets.all(7),
  //     decoration: BoxDecoration(
  //       borderRadius: BorderRadius.circular(14),
  //       color: const Color.fromARGB(155, 222, 229, 231),
  //     ),
  //     child: Column(
  //       children: [
  //         Row(
  //           children: [
  //             Expanded(
  //               child: TextField(
  //                 controller: paidAmountController,
  //                 keyboardType: TextInputType.number,
  // inputFormatters: [
  //   FilteringTextInputFormatter
  //       .digitsOnly, // Only numbers allowed
  // ],
  //                 decoration: const InputDecoration(
  //                   labelText: 'Paying Amount',
  //                   border: InputBorder.none,
  //                 ),
  //               ),
  //             ),
  //             ElevatedButton(
  //               onPressed: () {
  //                 setState(() {
  //                   double paidAmount =
  //                       double.tryParse(paidAmountController.text) ?? 0;
  //                   _setPaidAmountForCurrentPage(paidAmount);
  //                   print(
  //                       "Entered amount for Page $currentPageIndex: $paidAmount");
  //                 });
  //               },
  //               style: ElevatedButton.styleFrom(
  //                 backgroundColor: const Color(0xFF4285F4),
  //                 foregroundColor: Colors.white,
  //                 shape: RoundedRectangleBorder(
  //                   borderRadius: BorderRadius.circular(10),
  //                 ),
  //                 padding:
  //                     const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
  //               ),
  //               child: const Row(
  //                 mainAxisSize: MainAxisSize.min,
  //                 children: [
  //                   Icon(
  //                     Icons.check,
  //                     color: Colors.white,
  //                     size: 15,
  //                   ),
  //                   SizedBox(width: 3),
  //                   Text(
  //                     'OK',
  //                     style: TextStyle(
  //                       fontSize: 12,
  //                       fontWeight: FontWeight.bold,
  //                       letterSpacing: 1.2,
  //                     ),
  //                   ),
  //                 ],
  //               ),
  //             ),
  //           ],
  //         ),
  //       ],
  //     ),
  //   );
  // }

  Widget _paidAmount() {
    // Extract paid_amount from the message if available
    // final Map<String, dynamic> message = widget.datas?['message'] ?? {};
    // double initialPaidAmount =
    //     message['paid_amount'] ?? 0.0; // Default to 0.0 if not found

    // // Set the initial value of the paidAmountController if it's not already set
    // if (paidAmountController.text.isEmpty) {
    //   paidAmountController.text = initialPaidAmount.toString();
    // }

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
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(
                      RegExp(
                          r'^\d*\.?\d*'), // Allows digits and a single decimal point
                    ),
                  ],
                  decoration: const InputDecoration(
                    labelText: 'Paying Amount',
                    border: InputBorder.none,
                  ),
                  onChanged: (value) {
                    // setState(() {
                    // Optionally handle changes in the input in real-time
                    double paidAmount = double.tryParse(value) ?? 0.0;
                    // double paidAmount =
                    //     double.tryParse(paidAmountController.text) ?? 0.0;
                    _setPaidAmountForCurrentPage(paidAmount);
                    // });
                  },
                ),
              ),
              // ElevatedButton(
              //   onPressed: () {
              //     setState(() {
              //       double paidAmount =
              //           double.tryParse(paidAmountController.text) ?? 0.0;
              //       _setPaidAmountForCurrentPage(paidAmount);
              //       print(
              //           "Entered amount for Page $currentPageIndex: $paidAmount");
              //     });
              //   },
              //   style: ElevatedButton.styleFrom(
              //     backgroundColor: const Color(0xFF4285F4),
              //     foregroundColor: Colors.white,
              //     shape: RoundedRectangleBorder(
              //       borderRadius: BorderRadius.circular(10),
              //     ),
              //     padding:
              //         const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
              //   ),
              //   child: const Row(
              //     mainAxisSize: MainAxisSize.min,
              //     children: [
              //       Icon(
              //         Icons.check,
              //         color: Colors.white,
              //         size: 15,
              //       ),
              //       SizedBox(width: 3),
              //       Text(
              //         'OK',
              //         style: TextStyle(
              //           fontSize: 12,
              //           fontWeight: FontWeight.bold,
              //           letterSpacing: 1.2,
              //         ),
              //       ),
              //     ],
              //   ),
              // ),
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
        // value: _getSelectedModeForCurrentPage(),
        value: selectedMode,
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

  // Widget _viewCustomerList(BuildContext context) {
  //   return SizedBox(
  //     width: double.infinity, // Makes the bfutton take full width
  //     child: ElevatedButton(
  //       style: ElevatedButton.styleFrom(
  //         backgroundColor: const Color(0xFF4285F4), // Set the color here
  //         shape: RoundedRectangleBorder(
  //           borderRadius: BorderRadius.circular(20),
  //         ),
  //       ),
  //       onPressed: () {
  //         showDialog(
  //           context: context,
  //           builder: (BuildContext context) {
  //             return Stack(
  //               children: [
  //                 // Add a BackdropFilter to blur the background
  //                 BackdropFilter(
  //                   filter: ImageFilter.blur(
  //                       sigmaX: 5.0, sigmaY: 5.0), // Adjust blur intensity
  //                   child: Container(
  //                     color: Colors.white.withOpacity(
  //                         0), // Just to make the BackdropFilter visible
  //                   ),
  //                 ),
  //                 AlertDialog(
  //                   backgroundColor: const Color.fromARGB(
  //                       255, 255, 255, 255), // Set background color here
  //                   shape: RoundedRectangleBorder(
  //                     borderRadius: BorderRadius.circular(20),
  //                   ),
  //                   title: const Text(
  //                     'Select Customer',
  //                     style: TextStyle(color: Colors.black87), // Title color
  //                   ),
  //                   content: Container(
  //                     width: MediaQuery.of(context).size.width *
  //                         0.8, // Adjust the width as needed
  //                     child: Column(
  //                       mainAxisSize: MainAxisSize.min,
  //                       children: [
  //                         DropdownButton<String>(
  //                           value: _filteredCustomers.contains(
  //                                   _getSelectedCustomerForCurrentPage())
  //                               ? _getSelectedCustomerForCurrentPage()
  //                               : null,
  //                           hint: const Text(
  //                             'Select a customer',
  //                             style: TextStyle(color: Colors.black38),
  //                           ),
  //                           isExpanded: true,
  //                           dropdownColor: Color.fromARGB(255, 226, 226, 233),
  //                           items: _filteredCustomers.map((String? customer) {
  //                             return DropdownMenuItem<String>(
  //                               value: customer,
  //                               child: Text(
  //                                 customer!,
  //                                 style: const TextStyle(color: Colors.black87),
  //                               ),
  //                             );
  //                           }).toList(),
  //                           onChanged: (String? newValue) {
  //                             setState(() {
  //                               _setSelectedCustomerForCurrentPage(newValue);
  //                             });
  //                             Navigator.of(context).pop();
  //                           },
  //                         ),
  //                       ],
  //                     ),
  //                   ),
  //                   actions: <Widget>[
  //                     Row(
  //                       mainAxisSize: MainAxisSize
  //                           .min, // Use min size for the row to wrap its children
  //                       children: [
  //                         TextButton(
  //                           child: const Text(
  //                             'Close',
  //                             style: TextStyle(
  //                                 color: Colors
  //                                     .redAccent), // Close button text color
  //                           ),
  //                           onPressed: () {
  //                             Navigator.of(context).pop();
  //                           },
  //                         ),
  //                       ],
  //                     ),
  //                   ],
  //                 ),
  //               ],
  //             );
  //           },
  //         );
  //       },
  //       child: Row(
  //         mainAxisSize:
  //             MainAxisSize.max, // Use max to take full available space
  //         mainAxisAlignment:
  //             MainAxisAlignment.center, // Center the content horizontally
  //         crossAxisAlignment:
  //             CrossAxisAlignment.center, // Center the content vertically
  //         children: [
  //           const Icon(
  //             Icons.person,
  //             color: Colors.white,
  //             size: 16, // Icon stays constant
  //           ),
  //           const SizedBox(width: 8), // Space between the icon and text
  //           FittedBox(
  //             fit: BoxFit.scaleDown, // Ensures the text scales down if needed
  //             alignment:
  //                 Alignment.center, // Centers the text inside the FittedBox
  //             child: Text(
  //               _getSelectedCustomerForCurrentPage() ?? 'Customer',
  //               style: const TextStyle(
  //                 color: Colors.white,
  //                 fontWeight: FontWeight.bold,
  //               ),
  //             ),
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }

  Widget _viewCustomerList(BuildContext context) {
    // Extract customer name from dataItems if available
    final Map<String, dynamic> message = widget.datas?['message'] ?? {};
    print("customer in message: ${message['customer']}");

    final List<String?> customers = message.isNotEmpty
        ? [message['customer']?.toString() ?? '']
        : _filteredCustomers;

    print("ddddd$customers");

    // Determine the customer name to display on the button
    final String displayedCustomer = message['customer']?.toString() ??
        _getSelectedCustomerForCurrentPage() ??
        'Customer';
    _setSelectedCustomerForCurrentPage(displayedCustomer);

    return SizedBox(
      width: double.infinity, // Makes the button take full width
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
                    backgroundColor: const Color.fromARGB(255, 255, 255, 255),
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
                          // If the customer exists in message, just show it as text.
                          message['customer'] != null
                              ? Text(
                                  message['customer'].toString(),
                                  style: const TextStyle(color: Colors.black87),
                                )
                              : DropdownButton<String?>(
                                  // When no message customer, show dropdown
                                  value: customers.contains(
                                          _getSelectedCustomerForCurrentPage())
                                      ? _getSelectedCustomerForCurrentPage()
                                      : null,
                                  hint: const Text(
                                    'Select a customer',
                                    style: TextStyle(color: Colors.black38),
                                  ),
                                  isExpanded: true,
                                  dropdownColor:
                                      Color.fromARGB(255, 226, 226, 233),
                                  items: customers.map((String? customer) {
                                    return DropdownMenuItem<String?>(
                                      value: customer,
                                      child: Text(
                                        customer ?? '',
                                        style: const TextStyle(
                                            color: Colors.black87),
                                      ),
                                    );
                                  }).toList(),
                                  onChanged: (String? newValue) {
                                    setState(() {
                                      // When the user selects a customer, set the selected customer for the current page
                                      _setSelectedCustomerForCurrentPage(
                                          newValue);
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
                displayedCustomer, // Display the customer name here
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
