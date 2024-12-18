// models/item.dart
class Item {
  // final String price;
  String price;
  // final String tax;
  String tax;
  int itemCount;
  final itemDesciption;
  final String itemCode;
  final String itemName;
  final double companyTax;
  final String image;
  final String itemtaxtype;

  Item({
    required this.price,
    required this.tax,
    required this.itemCount,
    required this.itemDesciption,
    required this.itemCode,
    required this.itemName,
    required this.companyTax,
    required this.image,
    required this.itemtaxtype,
  });

  factory Item.fromMap(Map<String, dynamic> map) {
    return Item(
      itemCode: map['item_code'],
      itemName: map['item_name'],
      itemDesciption: map['item_description'] ?? '',
      image: map['image'] ?? '', // Assuming you store image paths
      price: map['item_price'] ?? '0.00',
      tax: map['item_tax'] ?? '0.00',
      companyTax: map['rate'] ?? 0.0,
      itemCount: map['item_count'] ?? 1,
      itemtaxtype: map['item_tax_type'],
    );
  }

  @override
  String toString() {
    return 'Item(name: $itemName, count: $itemCount, price: $price, companyTax: $companyTax, itemDesciption: $itemDesciption)';
    // return 'Item(name: $itemName, count: $itemCount, price: $price, itemTax: $tax)';
  }
}
