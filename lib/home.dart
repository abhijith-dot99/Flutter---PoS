// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'sales_report.dart';
// import 'model/item.dart';
// import 'package:flutter/services.dart';
//
// class HomePage extends StatefulWidget {
//   const HomePage({Key? key}) : super(key: key);
//
//   @override
//   State<HomePage> createState() => _HomePageState();
// }
//
// class _HomePageState extends State<HomePage> {
//   String query = '';
//   List<Item> searchResults = [];
//
//   // Initialize items
//   final List<Item> items = [
//     Item(
//       image: 'assets/items/1.png',
//       title: 'Original Burger',
//       price: '\$5.99',
//       itemCount: '11 item',
//     ),
//     Item(
//       image: 'assets/items/2.png',
//       title: 'Double Burger',
//       price: '\$10.99',
//       itemCount: '10 item',
//     ),
//     Item(
//       image: 'assets/items/3.png',
//       title: 'Cheese Burger',
//       price: '\$6.99',
//       itemCount: '7 item',
//     ),
//     Item(
//       image: 'assets/items/4.png',
//       title: 'Double Cheese Burger',
//       price: '\$12.99',
//       itemCount: '20 item',
//     ),
//     Item(
//       image: 'assets/items/5.png',
//       title: 'Spicy Burger',
//       price: '\$7.39',
//       itemCount: '12 item',
//     ),
//     Item(
//       image: 'assets/items/6.png',
//       title: 'Special Black Burger',
//       price: '\$7.39',
//       itemCount: '39 item',
//     ),
//     Item(
//       image: 'assets/items/7.png',
//       title: 'Special Cheese Burger',
//       price: '\$8.00',
//       itemCount: '2 item',
//     ),
//     Item(
//       image: 'assets/items/8.png',
//       title: 'Jumbo Cheese Burger',
//       price: '\$15.99',
//       itemCount: '2 item',
//     ),
//   ];
//
//   @override
//   void initState() {
//     super.initState();
//     // Initialize searchResults with all items
//     searchResults = items;
//   }
//
//   @override
//   Widget build(BuildContext context) {
//
//     // Set the orientation to landscape when the widget is built
//     SystemChrome.setPreferredOrientations([
//       DeviceOrientation.landscapeRight,
//       DeviceOrientation.landscapeLeft,
//     ]);
//
//     print("itemss $items");
//     print("searchre $searchResults");
//
//
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.start,
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Expanded(
//           flex: 14,
//           child: Column(
//             children: [
//               _topMenu(
//                 title: 'Lorem Restaurant',
//                 subTitle: '20 October 2022',
//                 action: _search(),
//               ),
//               Container(
//                 height: 100,
//                 padding: const EdgeInsets.symmetric(vertical: 24),
//                 child: ListView(
//                   scrollDirection: Axis.horizontal,
//                   children: [
//                     _itemTab(
//                       icon: 'assets/icons/icon-burger.png',
//                       title: 'Burger',
//                       isActive: true,
//                     ),
//                     _itemTab(
//                       icon: 'assets/icons/icon-noodles.png',
//                       title: 'Noodles',
//                       isActive: false,
//                     ),
//                     _itemTab(
//                       icon: 'assets/icons/icon-drinks.png',
//                       title: 'Drinks',
//                       isActive: false,
//                     ),
//                     _itemTab(
//                       icon: 'assets/icons/icon-desserts.png',
//                       title: 'Desserts',
//                       isActive: false,
//                     )
//                   ],
//                 ),
//               ),
//               Expanded(
//                 child: GridView.count(
//                   crossAxisCount: 4,
//                   childAspectRatio: (1 / 1.7),
//                   children: items.map((item) {
//                     return _item(
//                       image: item.image,
//                       title: item.title,
//                       price: item.price,
//                       item: item.itemCount,
//                     );
//                   }).toList(),
//                 ),
//               ),
//             ],
//           ),
//         ),
//         Expanded(flex: 1, child: Container()),
//         Expanded(
//           flex: 5,
//           child: Column(
//             children: [
//               // _topMenu(
//               //   title: 'Order',
//               //   subTitle: 'Table 8',
//               //   action: _viewItemListButton(context),
//               // ),
//               _viewItemListButton(context),
//               const SizedBox(height: 20),
//               Expanded(
//                 child: ListView(
//                   children: [
//                     _itemOrder(
//                       image: 'assets/items/1.png',
//                       title: 'Original Burger',
//                       qty: '2',
//                       price: '\$5.99',
//                     ),
//                     _itemOrder(
//                       image: 'assets/items/2.png',
//                       title: 'Double Burger',
//                       qty: '3',
//                       price: '\$10.99',
//                     ),
//                   ],
//                 ),
//               ),
//               Expanded(
//                 child: Container(
//                   padding: const EdgeInsets.all(20),
//                   margin: const EdgeInsets.symmetric(vertical: 10),
//                   decoration: BoxDecoration(
//                     borderRadius: BorderRadius.circular(14),
//                     color: const Color(0xff1f2029),
//                   ),
//                   child: Column(
//                     children: [
//                       const Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           Text(
//                             'Sub Total',
//                             style: TextStyle(
//                                 fontWeight: FontWeight.bold,
//                                 color: Colors.white),
//                           ),
//                           Text(
//                             '\$40.32',
//                             style: TextStyle(
//                                 fontWeight: FontWeight.bold,
//                                 color: Colors.white),
//                           ),
//                         ],
//                       ),
//                       const SizedBox(height: 20),
//                       const Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           Text(
//                             'Tax',
//                             style: TextStyle(
//                                 fontWeight: FontWeight.bold,
//                                 color: Colors.white),
//                           ),
//                           Text(
//                             '\$4.32',
//                             style: TextStyle(
//                                 fontWeight: FontWeight.bold,
//                                 color: Colors.white),
//                           ),
//                         ],
//                       ),
//                       Container(
//                         margin: const EdgeInsets.symmetric(vertical: 20),
//                         height: 2,
//                         width: double.infinity,
//                         color: Colors.white,
//                       ),
//                       const Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           Text(
//                             'Total',
//                             style: TextStyle(
//                                 fontWeight: FontWeight.bold,
//                                 color: Colors.white),
//                           ),
//                           Text(
//                             '\$44.64',
//                             style: TextStyle(
//                                 fontWeight: FontWeight.bold,
//                                 color: Colors.white),
//                           ),
//                         ],
//                       ),
//                       const SizedBox(height: 30),
//                       ElevatedButton(
//                         style: ElevatedButton.styleFrom(
//                           foregroundColor: Colors.white,
//                           backgroundColor: Colors.deepOrange,
//                           padding: const EdgeInsets.symmetric(vertical: 8),
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(8),
//                           ),
//                         ),
//                         onPressed: () {  },
//                         child: const Row(
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           children: [
//                             Icon(Icons.print, size: 16),
//                             SizedBox(width: 6),
//                             Text('Print Bills')
//                           ],
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ],
//     );
//   }
//
//   Widget _itemOrder({
//     required String image,
//     required String title,
//     required String qty,
//     required String price,
//   }) {
//     return Container(
//       padding: const EdgeInsets.all(8),
//       margin: const EdgeInsets.only(bottom: 10),
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(14),
//         color: const Color(0xff1f2029),
//       ),
//       child: Row(
//         children: [
//           Container(
//             height: 60,
//             width: 60,
//             decoration: BoxDecoration(
//               borderRadius: BorderRadius.circular(12),
//               image: DecorationImage(
//                 image: AssetImage(image),
//                 fit: BoxFit.cover,
//               ),
//             ),
//           ),
//           const SizedBox(width: 10),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   title,
//                   style: const TextStyle(
//                     fontSize: 10,
//                     fontWeight: FontWeight.bold,
//                     color: Colors.white,
//                   ),
//                 ),
//                 const SizedBox(height: 10),
//                 Text(
//                   price,
//                   style: const TextStyle(
//                     fontSize: 14,
//                     fontWeight: FontWeight.bold,
//                     color: Colors.white,
//                   ),
//                 )
//               ],
//             ),
//           ),
//           Text(
//             '$qty x',
//             style: const TextStyle(
//               fontSize: 16,
//               fontWeight: FontWeight.bold,
//               color: Colors.white,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _item({
//     required String image,
//     required String title,
//     required String price,
//     required String item,
//   }) {
//     return Container(
//       margin: const EdgeInsets.only(right: 20, bottom: 20),
//       padding: const EdgeInsets.all(12),
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(18),
//         color: const Color(0xff1f2029),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Container(
//             height: 130,
//             decoration: BoxDecoration(
//               borderRadius: BorderRadius.circular(11),
//               image: DecorationImage(
//                 image: AssetImage(image),
//                 fit: BoxFit.cover,
//                 onError: (error, stackTrace) {
//                   if (kDebugMode) {
//                     print('Error loading image: $error');
//                   }
//                 },
//               ),
//             ),
//           ),
//           const SizedBox(height: 10),
//           Text(
//             title,
//             style: const TextStyle(
//               color: Colors.white,
//               fontWeight: FontWeight.bold,
//               fontSize: 14,
//             ),
//           ),
//           const SizedBox(height: 20),
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Text(
//                 price,
//                 style: const TextStyle(
//                   color: Colors.deepOrange,
//                   fontSize: 20,
//                 ),
//               ),
//               Text(
//                 item,
//                 style: const TextStyle(
//                   color: Colors.white60,
//                   fontSize: 12,
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _itemTab({
//     required String icon,
//     required String title,
//     required bool isActive,
//   }) {
//     return Container(
//       width: 180,
//       margin: const EdgeInsets.only(right: 26),
//       padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 24),
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(10),
//         color: const Color(0xff1f2029),
//         border: isActive
//             ? Border.all(color: Colors.deepOrangeAccent, width: 3)
//             : Border.all(color: const Color(0xff1f2029), width: 3),
//       ),
//       child: Row(
//         children: [
//           Image.asset(
//             icon,
//             width: 38,
//             errorBuilder: (context, error, stackTrace) {
//               return const Icon(Icons.error, color: Colors.red);
//             },
//           ),
//           const SizedBox(width: 8),
//           Text(
//             title,
//             style: const TextStyle(
//               fontSize: 14,
//               color: Colors.white,
//               fontWeight: FontWeight.bold,
//             ),
//           )
//         ],
//       ),
//     );
//   }
//
//   Widget _topMenu({
//     required String title,
//     required String subTitle,
//     required Widget action,
//   }) {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.start,
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Column(
//           mainAxisAlignment: MainAxisAlignment.start,
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               title,
//               style: const TextStyle(
//                 color: Colors.white,
//                 fontSize: 20,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//             const SizedBox(height: 6),
//             Text(
//               subTitle,
//               style: const TextStyle(
//                 color: Colors.white54,
//                 fontSize: 10,
//               ),
//             ),
//           ],
//         ),
//         Expanded(flex: 1, child: Container(width: double.infinity)),
//         Expanded(flex: 5, child: action),
//       ],
//     );
//   }
//
//   Widget _search() {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 15),
//       height: 40,
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(18),
//         color: const Color(0xff1f2029),
//       ),
//       child: TextField(
//         onChanged: (String searchQuery) {
//           // Update the search results based on the search query
//           setState(() {
//             searchResults = items
//                 .where((item) =>
//                 item.title.toLowerCase().contains(searchQuery.toLowerCase()))
//                 .toList();
//           });
//         },
//         style: const TextStyle(color: Colors.white54, fontSize: 11),
//         decoration: const InputDecoration(
//           border: InputBorder.none,
//           icon: Icon(
//             Icons.search,
//             color: Colors.white54,
//           ),
//           hintText: 'Search menu here...',
//           hintStyle: TextStyle(color: Colors.white54),
//         ),
//       ),
//     );
//   }
//
//
//   Widget _viewItemListButton(BuildContext context) {
//     return ElevatedButton(
//       style: ElevatedButton.styleFrom(
//         foregroundColor: Colors.white,
//         backgroundColor: Colors.deepOrange,
//         padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 90),
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(8),
//         ),
//       ),
//       onPressed: () {
//         Navigator.push(
//           context,
//           MaterialPageRoute(
//             builder: (context) => SalesReport(items: items),
//           ),
//         );
//       },
//       child: const Row(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Icon(Icons.assignment, color: Colors.white, size: 20,), // Add list icon here
//           SizedBox(width: 8), // Space between icon and text
//           FittedBox(
//             child: Text('Sales report'),
//           ),
//         ],
//       ),
//     );
//   }
//
//
// }







import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'sales_report.dart';
import 'model/item.dart';
import 'package:flutter/services.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String query = '';
  List<Item> searchResults = [];

  // Initialize items
  final List<Item> items = [
    Item(
      image: 'assets/items/1.png',
      title: 'Original Burger',
      price: '\$5.99',
      itemCount: '11 item',
    ),
    Item(
      image: 'assets/items/2.png',
      title: 'Double Burger',
      price: '\$10.99',
      itemCount: '10 item',
    ),
    Item(
      image: 'assets/items/3.png',
      title: 'Cheese Burger',
      price: '\$6.99',
      itemCount: '7 item',
    ),
    Item(
      image: 'assets/items/4.png',
      title: 'Double Cheese Burger',
      price: '\$12.99',
      itemCount: '20 item',
    ),
    Item(
      image: 'assets/items/5.png',
      title: 'Spicy Burger',
      price: '\$7.39',
      itemCount: '12 item',
    ),
    Item(
      image: 'assets/items/6.png',
      title: 'Special Black Burger',
      price: '\$7.39',
      itemCount: '39 item',
    ),
    Item(
      image: 'assets/items/7.png',
      title: 'Special Cheese Burger',
      price: '\$8.00',
      itemCount: '2 item',
    ),
    Item(
      image: 'assets/items/8.png',
      title: 'Jumbo Cheese Burger',
      price: '\$15.99',
      itemCount: '2 item',
    ),
  ];

  @override
  void initState() {
    super.initState();
    // Initialize searchResults with all items
    searchResults = items;
  }

  @override
  Widget build(BuildContext context) {
    // Get the screen width
    final screenWidth = MediaQuery.of(context).size.width;

    // Set orientation to landscape if width is less than 730
    if (screenWidth < 730) {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeRight,
        DeviceOrientation.landscapeLeft,
      ]);
    } else {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
      ]);
    }

    print("Items: $items");
    print("Search results: $searchResults");

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
                subTitle: '20 October 2022',
                action: _search(),
              ),
              Container(
                height: 100,
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    _itemTab(
                      icon: 'assets/icons/icon-burger.png',
                      title: 'Burger',
                      isActive: true,
                    ),
                    _itemTab(
                      icon: 'assets/icons/icon-noodles.png',
                      title: 'Noodles',
                      isActive: false,
                    ),
                    _itemTab(
                      icon: 'assets/icons/icon-drinks.png',
                      title: 'Drinks',
                      isActive: false,
                    ),
                    _itemTab(
                      icon: 'assets/icons/icon-desserts.png',
                      title: 'Desserts',
                      isActive: false,
                    )
                  ],
                ),
              ),
              Expanded(
                child: GridView.count(
                  crossAxisCount: 4,
                  childAspectRatio: (1 / 1.7),
                  children: items.map((item) {
                    return _item(
                      image: item.image,
                      title: item.title,
                      price: item.price,
                      item: item.itemCount,
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
        Expanded(flex: 1, child: Container()),
        Expanded(
          flex: 5,
          child: Column(
            children: [
              _viewItemListButton(context),
              const SizedBox(height: 20),
              Expanded(
                child: ListView(
                  children: [
                    _itemOrder(
                      image: 'assets/items/1.png',
                      title: 'Original Burger',
                      qty: '2',
                      price: '\$5.99',
                    ),
                    _itemOrder(
                      image: 'assets/items/2.png',
                      title: 'Double Burger',
                      qty: '3',
                      price: '\$10.99',
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(20),
                  margin: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    color: const Color(0xff1f2029),
                  ),
                  child: Column(
                    children: [
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Sub Total',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white),
                          ),
                          Text(
                            '\$40.32',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Tax',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white),
                          ),
                          Text(
                            '\$4.32',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white),
                          ),
                        ],
                      ),
                      Container(
                        margin: const EdgeInsets.symmetric(vertical: 20),
                        height: 2,
                        width: double.infinity,
                        color: Colors.white,
                      ),
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Total',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white),
                          ),
                          Text(
                            '\$44.64',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white),
                          ),
                        ],
                      ),
                      const SizedBox(height: 30),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: Colors.deepOrange,
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onPressed: () {  },
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.print, size: 16),
                            SizedBox(width: 6),
                            Text('Print Bills')
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _itemOrder({
    required String image,
    required String title,
    required String qty,
    required String price,
  }) {
    return Container(
      padding: const EdgeInsets.all(8),
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: const Color(0xff1f2029),
      ),
      child: Row(
        children: [
          Container(
            height: 60,
            width: 60,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              image: DecorationImage(
                image: AssetImage(image),
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  price,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                )
              ],
            ),
          ),
          Text(
            '$qty x',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _item({
    required String image,
    required String title,
    required String price,
    required String item,
  }) {
    return Container(
      margin: const EdgeInsets.only(right: 20, bottom: 20),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: const Color(0xff1f2029),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 80,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(11),
              image: DecorationImage(
                image: AssetImage(image),
                fit: BoxFit.cover,
                onError: (error, stackTrace) {
                  if (kDebugMode) {
                    print('Error loading image: $error');
                  }
                },
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                price,
                style: const TextStyle(
                  color: Colors.deepOrange,
                  fontSize: 20,
                ),
              ),
              Text(
                item,
                style: const TextStyle(
                  color: Colors.white60,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _itemTab({
    required String icon,
    required String title,
    required bool isActive,
  }) {
    return Container(
      width: 180,
      margin: const EdgeInsets.only(right: 26),
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: const Color(0xff1f2029),
        border: isActive
            ? Border.all(color: Colors.deepOrangeAccent, width: 3)
            : Border.all(color: const Color(0xff1f2029), width: 3),
      ),
      child: Row(
        children: [
          Image.asset(
            icon,
            width: 38,
            errorBuilder: (context, error, stackTrace) {
              return const Icon(Icons.error, color: Colors.red);
            },
          ),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          )
        ],
      ),
    );
  }

  Widget _topMenu({
    required String title,
    required String subTitle,
    required Widget action,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              subTitle,
              style: const TextStyle(
                color: Colors.white54,
                fontSize: 10,
              ),
            ),
          ],
        ),
        Expanded(flex: 1, child: Container(width: double.infinity)),
        Expanded(flex: 5, child: action),
      ],
    );
  }

  Widget _search() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      height: 40,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: const Color(0xff1f2029),
      ),
      child: TextField(
        onChanged: (String searchQuery) {
          // Update the search results based on the search query
          setState(() {
            searchResults = items
                .where((item) =>
                item.title.toLowerCase().contains(searchQuery.toLowerCase()))
                .toList();
          });
        },
        style: const TextStyle(color: Colors.white54, fontSize: 11),
        decoration: const InputDecoration(
          border: InputBorder.none,
          icon: Icon(
            Icons.search,
            color: Colors.white54,
          ),
          hintText: 'Search menu here...',
          hintStyle: TextStyle(color: Colors.white54),
        ),
      ),
    );
  }

  Widget _viewItemListButton(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: Colors.deepOrange,
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 90),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SalesReport(items: items),
          ),
        );
      },
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.assignment, color: Colors.white, size: 20), // Add list icon here
          SizedBox(width: 8), // Space between icon and text
          FittedBox(
            child: Text('Sales report'),
          ),
        ],
      ),
    );
  }
}

