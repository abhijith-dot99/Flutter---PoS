// import 'dart:io';
// import 'dart:typed_data';
// import 'package:path_provider/path_provider.dart';
// import 'package:pdf/pdf.dart';
// import 'package:pdf/widgets.dart' as pw;
// import 'package:printing/printing.dart';
// import 'package:permission_handler/permission_handler.dart';
// import 'package:open_file/open_file.dart';
// import 'model/item.dart';

// class Generate3inch {
//   Future<void> printBill(
//       List<Item> items,
//       double subtotal,
//       double tax,
//       double total,
//       String selectedcust,
//       String salesInvoice,
//       String selectedCompanyName,
//       String customerName,
//       String customerAddressTitle,
//       String customerVatNumber,
//       String customercompanyCrNo,
//       String companyVatNo,
//       String companyCrNo,
//       String companyAddress,
//       double discount) async {
//     if (Platform.isWindows) {
//       await printBillWindows(
//           items,
//           subtotal,
//           tax,
//           total,
//           selectedcust,
//           salesInvoice,
//           selectedCompanyName,
//           customerName,
//           customerAddressTitle,
//           customerVatNumber,
//           customercompanyCrNo,
//           companyVatNo,
//           companyCrNo,
//           companyAddress,
//           discount);
//     } else if (Platform.isAndroid) {
//       await printBillAndroid(
//           items,
//           subtotal,
//           tax,
//           total,
//           selectedcust,
//           salesInvoice,
//           selectedCompanyName,
//           customerName,
//           customerAddressTitle,
//           customerVatNumber,
//           customercompanyCrNo,
//           companyVatNo,
//           companyCrNo,
//           companyAddress,
//           discount);
//     } else {
//       throw UnsupportedError('Unsupported platform');
//     }
//   }
// }
