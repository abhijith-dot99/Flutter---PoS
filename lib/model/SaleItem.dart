class SalesItem {
  int id;
  String itemCode;
  String itemName;
  String itemDescription;
  String itemGroup;
  String itemImage;
  String itemUom;
  double baseRate;
  double baseAmount;
  double netRate;
  double netAmount;
  String pricingRules;
  bool isFreeItem;
  double itemTaxRate;
  String invoiceNo;
  String customerName;
  int itemCount;
  String date;
  double discount;

  SalesItem({
    required this.id,
    required this.itemCode,
    required this.itemName,
    required this.itemDescription,
    required this.itemGroup,
    required this.itemImage,
    required this.itemUom,
    required this.baseRate,
    required this.baseAmount,
    required this.netRate,
    required this.netAmount,
    required this.pricingRules,
    required this.isFreeItem,
    required this.itemTaxRate,
    required this.invoiceNo,
    required this.customerName,
    required this.itemCount,
    required this.date,
    required this.discount,
  });

  // Convert a SalesItem object into a Map object to store in the database
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'item_code': itemCode,
      'item_name': itemName,
      'item_description': itemDescription,
      'item_group': itemGroup,
      'item_image': itemImage,
      'item_uom': itemUom,
      'base_rate': baseRate,
      'base_amount': baseAmount,
      'net_rate': netRate,
      'net_amount': netAmount,
      'pricing_rules': pricingRules,
      'is_free_item': isFreeItem ? 1 : 0, // Boolean is stored as an int
      'item_tax_rate': itemTaxRate,
      'invoice_no': invoiceNo,
      'customer_name': customerName,
      'item_count': itemCount,
      'date': date, // Store date
      'discount': discount,
    };
  }

  // Convert a Map object from the database into a SalesItem object
  factory SalesItem.fromMap(Map<String, dynamic> map) {
    return SalesItem(
      id: map['id'],
      itemCode: map['item_code'],
      itemName: map['item_name'],
      itemDescription: map['item_description'],
      itemGroup: map['item_group'],
      itemImage: map['item_image'],
      itemUom: map['item_uom'],
      baseRate: map['base_rate'],
      baseAmount: map['base_amount'],
      netRate: map['net_rate'],
      netAmount: map['net_amount'],
      pricingRules: map['pricing_rules'],
      isFreeItem: map['is_free_item'] == 1, // Convert int to bool
      itemTaxRate: map['item_tax_rate'],
      invoiceNo: map['invoice_no'],
      customerName: map['customer_name'],
      itemCount: map['item_count'],
      date: map['date'], // Retrieve date
      discount: map['discount']
    );
  }
}
