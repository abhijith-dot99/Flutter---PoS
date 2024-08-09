// models/item.dart

class Item {
  // final String icon;
  final String image;
  final String title;
  final String price;
  final String itemCount;
  final String category;

  Item({
    // required this.icon,
    required this.image,
    required this.title,
    required this.price,
    required this.itemCount,
    required this.category,
  });

  @override
  String toString() {
    return 'Title: $title, Price: $price, Quantity: $itemCount';
  }


}
