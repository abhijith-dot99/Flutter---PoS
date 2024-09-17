class Tax {
  final String taxname;
  final String companyName;
  final String title;
  final String chargeType;
  final String accountHead;
  final String description;
  final double rate;
  final int isInclusive;

  Tax({
    required this.taxname,
    required this.companyName,
    required this.title,
    required this.chargeType,
    required this.accountHead,
    required this.description,
    required this.rate,
    required this.isInclusive,
  });

  Map<String, dynamic> toMap() {
    return {
      'tax_name': taxname,
      'company_name': companyName,
      'account_head': accountHead,
      'charge_type': chargeType,
      'description': description,
      'rate': rate,
      'title': title,
      'is_inclusive': isInclusive,
    };
  }
}
