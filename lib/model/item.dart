// models/item.dart
class Item {
  // final String image;
  // final String title;
  final String price;
  final String tax;
  int itemCount;
  // final String category;

  final String itemCode;
  final String itemName;
  final String image;

  Item({
    // required this.image,
    // required this.title,
    required this.price,
    required this.tax,
    this.itemCount = 1,
    // required this.category,

    required this.itemCode,
    required this.itemName,
    required this.image,
  });

  // @override
  // String toString() {
  //   return 'Title: $title, Price: $price, Quantity: $itemCount';
  // }

  factory Item.fromMap(Map<String, dynamic> map) {
    return Item(
      itemCode: map['item_code'],
      itemName: map['item_name'],
      image: map['image'] ?? '', // Assuming you store image paths
      price: map['price'] ?? '0.00',
      tax: map['tax'] ?? '0.00',
      itemCount: map['item_count'] ?? 1,
      // category: map['category'] ?? '',
    );
  }
}
