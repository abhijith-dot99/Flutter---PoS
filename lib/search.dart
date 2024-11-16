// // search.dart

// class Item {
//   final String image;
//   final String title;
//   final String price;
//   final String itemCount;

//   Item({
//     required this.image,
//     required this.title,
//     required this.price,
//     required this.itemCount,
//   });
// }

// class SearchService {
//   // This method will filter the items based on the search query
//   static List<Item> searchItems(List<Item> items, String query) {
//     if (query.isEmpty) {
//       return items;
//     }

//     return items.where((item) {
//       return item.title.toLowerCase().contains(query.toLowerCase());
//     }).toList();
//   }
// }
