class ItemData {
  final String itemCode;
  final String itemName;
  final double itemPrice;
  final double itemTax;
  final String itemGroup;
  final String companyName;
  final String warehouse;
  final String itemPriceList;
  final String uom;
  final String itemTaxType;

  ItemData({
    required this.itemCode,
    required this.itemName,
    required this.itemPrice,
    required this.itemTax,
    required this.itemGroup,
    required this.companyName,
    required this.warehouse,
    required this.itemPriceList,
    required this.uom,
    required this.itemTaxType,
  });

  // Convert a JSON object to an ItemData object
  factory ItemData.fromJson(Map<String, dynamic> json) {
    return ItemData(
      itemCode: json['item_code'] ?? '',
      itemName: json['item_name'] ?? '',
      itemPrice: json['item_price'] != null
          ? (json['item_price'] as num).toDouble()
          : 0.0,
      itemTax:
          json['item_tax'] != null ? (json['item_tax'] as num).toDouble() : 0.0,
      itemGroup: json['item_group'] ?? '',
      companyName: json['company_name'] ?? '',
      warehouse: json['warehouse'] ?? '',
      itemPriceList: json['item_price_list'] ?? '',
      uom: json['uom'] ?? '',
      itemTaxType: json['item_tax_type'] ?? '',
    );
  }

  // Convert an ItemData object to a Map for database insertion
  Map<String, dynamic> toJson() {
    return {
      'item_code': itemCode,
      'item_name': itemName,
      'item_price': itemPrice,
      'item_tax': itemTax,
      'item_group': itemGroup,
      'company_name': companyName,
      'warehouse': warehouse,
      'item_price_list': itemPriceList,
      'uom': uom,
      'item_tax_type': itemTaxType,
    };
  }
}
