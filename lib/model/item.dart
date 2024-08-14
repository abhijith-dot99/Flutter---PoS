// models/item.dart

class Item {
  // final String icon;
  final String image;
  final String title;
  final String price;
  final String tax;
  final String itemCount;
  // int itemCount;
  final String category;

  Item({
    // required this.icon,
    required this.image,
    required this.title,
    required this.price,
    required this.tax,
    required this.itemCount,
    // this.itemCount = 1, // Default item count is 1
    required this.category,
  });

  @override
  String toString() {
    return 'Title: $title, Price: $price, Quantity: $itemCount';
  }
}


class HeldBill {
  final int number;
  final List<Item> items;

  HeldBill({required this.number, required this.items});
}


class Bill {
  List<Item> items;

  Bill({required this.items});
}