// models/item.dart
class Item {
  final String image;
  final String title;
  final String price;
  final String tax;
  int itemCount;
  final String category;

  Item({
    required this.image,
    required this.title,
    required this.price,
    required this.tax,
    this.itemCount = 1, // Default item count is 1
    required this.category,
  });

  @override
  String toString() {
    return 'Title: $title, Price: $price, Quantity: $itemCount';
  }
}
