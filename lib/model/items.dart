class Items {
  final String itemCode;
  final String itemName;
  final String itemDescription;
  final String itemGroup;
  final String itemImage;
  final String itemUom;
  final double baseRate;
  final double baseAmount;
  final double netRate;
  final double netAmount;
  final String pricingRules;
  final bool isFreeItem;
  // final Map<String, dynamic> itemTaxList
  // <Map<String, dynamic>> itemsRate;
  final String itemTaxRate;

  final String invoice;
  final String customername;

  Items({
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
    // required this.itemTaxRate,
    required this.itemTaxRate,
    required this.invoice,
    required this.customername,
  });

  // Method to convert an Item object to a Map
  Map<String, dynamic> toMap() {
    return {
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
      'is_free_item': isFreeItem ? 1 : 0,
      'item_tax_rate': itemTaxRate,
      'invoice_no': 'ACC-SINV-2024-00058',
      'customername': customername
    };
  }
}