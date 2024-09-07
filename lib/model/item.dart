// models/item.dart
class Item {
  final String price;
  final String tax;
  int itemCount;
  final String itemCode;
  final String itemName;
  final String image;
  final String itemtaxtype;

  Item({
    required this.price,
    required this.tax,
    this.itemCount = 1,
    required this.itemCode,
    required this.itemName,
    required this.image,
    required this.itemtaxtype,
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
      price: map['item_price'] ?? '0.00',
      tax: map['item_tax'] ?? '0.00',
      itemCount: map['item_count'] ?? 1,
      itemtaxtype: map['item_tax_type'],
      // category: map['category'] ?? '',
    );
  }
}
