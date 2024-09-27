import 'dart:io';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:open_file/open_file.dart';
import 'model/item.dart';

class PrintService {
  Future<void> printBill(
      List<Item> items,
      double subtotal,
      double tax,
      double total,
      String selectedcust,
      String salesInvoice,
      String selectedCompanyName,
      String customerName,
      String customerAddressTitle,
      String customerVatNumber,
      String customerCrNo,
      String cvatNo,
      String crNo,
      String cAddress) async {
    if (Platform.isWindows) {
      await printBillWindows(
          items,
          subtotal,
          tax,
          total,
          selectedcust,
          salesInvoice,
          selectedCompanyName,
          customerName,
          customerAddressTitle,
          customerVatNumber,
          customerCrNo,
          cvatNo,
          crNo,
          cAddress);
    } else if (Platform.isAndroid) {
      await printBillAndroid(
          items,
          subtotal,
          tax,
          total,
          selectedcust,
          salesInvoice,
          selectedCompanyName,
          customerName,
          customerAddressTitle,
          customerVatNumber,
          customerCrNo,
          cvatNo,
          crNo,
          cAddress);
    } else {
      throw UnsupportedError('Unsupported platform');
    }
  }

  Future<void> printBillWindows(
      List<Item> items,
      double subtotal,
      double tax,
      double total,
      String selectedcust,
      String salesInvoice,
      String selectedCompanyName,
      String customerName,
      String customerAddressTitle,
      String customerVatNumber,
      String customerCrNo,
      String cvatNo,
      String crNo,
      String cAddress) async {
    final pdfData = await generatePdf(
        items,
        subtotal,
        tax,
        total,
        selectedcust,
        salesInvoice,
        selectedCompanyName,
        customerName,
        customerAddressTitle,
        customerVatNumber,
        customerCrNo,
        cvatNo,
        crNo,
        cAddress);

    await Printing.directPrintPdf(
      printer: await _getDefaultPrinter(),
      onLayout: (PdfPageFormat format) async => pdfData,
    );
    // print('Order Details windowss:\n$pdfData');
  }

  Future<void> printBillAndroid(
      List<Item> items,
      double subtotal,
      double tax,
      double total,
      String selectedcust,
      String salesInvoice,
      String selectedCompanyName,
      String customerName,
      String customerAddressTitle,
      String customerVatNumber,
      String customerCrNo,
      String cvatNo,
      String crNo,
      String cAddress) async {
    await requestPermissions();
    final pdfData = await generatePdf(
        items,
        subtotal,
        tax,
        total,
        selectedcust,
        salesInvoice,
        selectedCompanyName,
        customerName,
        customerAddressTitle,
        customerVatNumber,
        customerCrNo,
        cvatNo,
        crNo,
        cAddress);
    final filePath = await savePdfToFile(pdfData);
    await openPdfFile(filePath);
    // print('Order Details:\n${pdfData.toString()}');
  }


Future<Uint8List> generatePdf(
  List<Item> items,
  double subtotal,
  double tax,
  double total,
  String selectedcust,
  String salesInvoice,
  String selectedCompanyName,
  String customerName,
  String customerAddressTitle,
  String customerVatNumber,
  String customerCrNo,
  String sellerVatNumber,
  String sellerCrNo,
  String sellerAddress
) async {
  final pdf = pw.Document();

  pdf.addPage(
    pw.Page(
      pageFormat: PdfPageFormat.a4,
      build: (pw.Context context) => pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          // Invoice Heading
          pw.Center(
            child: pw.Text(
              'TAX INVOICE',
              style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
            ),
          ),
          pw.SizedBox(height: 38),

          // Invoice number and date
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text('Invoice No: $salesInvoice', style: pw.TextStyle(fontSize: 10)),
              pw.Text('Date: ${DateTime.now().toString().substring(0, 10)}', style: pw.TextStyle(fontSize: 10)),
            ],
          ),
          pw.SizedBox(height: 16),

          // Seller and Buyer table with column separation for labels and values
          pw.Table(
            columnWidths: {
              0: pw.FlexColumnWidth(1),
              1: pw.FlexColumnWidth(1),
            },
            border: pw.TableBorder.all(
                color: PdfColors.black, width: 1), // Outer border for the table
            children: [
              // Header Row: Seller & Buyer
              pw.TableRow(
                children: [
                  pw.Padding(
                    padding: pw.EdgeInsets.all(8),
                    child: pw.Text(
                      'Seller',
                      style: pw.TextStyle(
                          fontWeight: pw.FontWeight.bold, fontSize: 12),
                      textAlign: pw.TextAlign.center,
                    ),
                  ),
                  pw.Padding(
                    padding: pw.EdgeInsets.all(8),
                    child: pw.Text(
                      'Buyer',
                      style: pw.TextStyle(
                          fontWeight: pw.FontWeight.bold, fontSize: 12),
                      textAlign: pw.TextAlign.center,
                    ),
                  ),
                ],
              ),

              // Row 1: Name for Seller and Buyer
              pw.TableRow(
                children: [
                  pw.Padding(
                    padding: pw.EdgeInsets.all(8),
                    child: pw.Table(
                      columnWidths: {
                        0: pw.FlexColumnWidth(1),
                        1: pw.FlexColumnWidth(2),
                      },
                      children: [
                        pw.TableRow(
                          children: [
                            pw.Text('Name:'),
                            pw.Text('$selectedCompanyName'),
                          ],
                        ),
                      ],
                    ),
                  ),
                  pw.Padding(
                    padding: pw.EdgeInsets.all(8),
                    child: pw.Table(
                      columnWidths: {
                        0: pw.FlexColumnWidth(1),
                        1: pw.FlexColumnWidth(2),
                      },
                      children: [
                        pw.TableRow(
                          children: [
                            pw.Text('Name:'),
                            pw.Text(customerName),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              // Row 2: Address for Seller and Buyer
              pw.TableRow(
                children: [
                  pw.Padding(
                    padding: pw.EdgeInsets.all(8),
                    child: pw.Table(
                      columnWidths: {
                        0: pw.FlexColumnWidth(1),
                        1: pw.FlexColumnWidth(2),
                      },
                      children: [
                        pw.TableRow(
                          children: [
                            pw.Text('Address:'),
                            pw.Text(sellerAddress),
                          ],
                        ),
                      ],
                    ),
                  ),
                  pw.Padding(
                    padding: pw.EdgeInsets.all(8),
                    child: pw.Table(
                      columnWidths: {
                        0: pw.FlexColumnWidth(1),
                        1: pw.FlexColumnWidth(2),
                      },
                      children: [
                        pw.TableRow(
                          children: [
                            pw.Text('Address:'),
                            pw.Text(customerAddressTitle),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              // Row 3: VAT No for Seller and Buyer
              pw.TableRow(
                children: [
                  pw.Padding(
                    padding: pw.EdgeInsets.all(8),
                    child: pw.Table(
                      columnWidths: {
                        0: pw.FlexColumnWidth(1),
                        1: pw.FlexColumnWidth(2),
                      },
                      children: [
                        pw.TableRow(
                          children: [
                            pw.Text('VAT No:'),
                            pw.Text(sellerVatNumber),
                          ],
                        ),
                      ],
                    ),
                  ),
                  pw.Padding(
                    padding: pw.EdgeInsets.all(8),
                    child: pw.Table(
                      columnWidths: {
                        0: pw.FlexColumnWidth(1),
                        1: pw.FlexColumnWidth(2),
                      },
                      children: [
                        pw.TableRow(
                          children: [
                            pw.Text('VAT No:'),
                            pw.Text(customerVatNumber),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              // Row 4: CR No for Seller and Buyer
              pw.TableRow(
                children: [
                  pw.Padding(
                    padding: pw.EdgeInsets.all(8),
                    child: pw.Table(
                      columnWidths: {
                        0: pw.FlexColumnWidth(1),
                        1: pw.FlexColumnWidth(2),
                      },
                      children: [
                        pw.TableRow(
                          children: [
                            pw.Text('CR No:'),
                            pw.Text(sellerCrNo),
                          ],
                        ),
                      ],
                    ),
                  ),
                  pw.Padding(
                    padding: pw.EdgeInsets.all(8),
                    child: pw.Table(
                      columnWidths: {
                        0: pw.FlexColumnWidth(1),
                        1: pw.FlexColumnWidth(2),
                      },
                      children: [
                        pw.TableRow(
                          children: [
                            pw.Text('CR No:'),
                            pw.Text(customerCrNo),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),

          pw.SizedBox(height: 20),

          // Table for items with 'S.No' column and center-aligned content
          pw.Table.fromTextArray(
            headers: [
              'S.No',
              'Particulars',
              'Unit Price',
              'Quantity',
              'Tax',
              'Total'
            ],
            data: items.asMap().entries.map((entry) {
              int index = entry.key + 1; // Serial number (1-based index)
              Item item = entry.value;
                double price = double.tryParse(item.price) ?? 0.0; // Default to 0.0 if parsing fails
  int quantity = item.itemCount; 
          double itemTotal = price * quantity; 
              return [
                index.toString(), // S.No column
                item.itemName,
                item.price,
                item.itemCount,
                tax,
                 itemTotal.toStringAsFixed(2),
              ];
            }).toList(),
            headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            cellAlignment: pw.Alignment.center, // Center-align table cells
          ),

          pw.SizedBox(height: 20),
          pw.Spacer(),

          // Subtotal, Tax, and Total rows
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text('Subtotal:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
              pw.Text('${subtotal.toStringAsFixed(2)}'),
            ],
          ),
          pw.SizedBox(height: 8),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text('Tax:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
              pw.Text('${tax.toStringAsFixed(2)}'),
            ],
          ),
          pw.SizedBox(height: 8),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text('Total:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 16)),
              pw.Text('${total.toStringAsFixed(2)}'),
            ],
          ),
        ],
      ),
    ),
  );

  return pdf.save();
}


}




Future<void> requestPermissions() async {
  print("inside requestpermission");
  if (Platform.isAndroid) {
    if (await Permission.manageExternalStorage.request().isGranted ||
        await Permission.storage.request().isGranted) {
      // Permissions granted
    } else {
      // Handle the case where permissions are not granted
      throw Exception('Storage permission not granted');
    }
  }
}

Future<String> savePdfToFile(Uint8List pdfData) async {
  print("inside savepdf");
  try {
    final directory = await getExternalStorageDirectory();
    if (directory == null) {
      throw Exception('Could not access external storage');
    }

    // Create a base file name
    String baseFileName = 'bill_';
    String fileExtension = '.pdf';

    // Initialize a counter
    int counter = 1;
    String filePath;

    // Find an available file name
    do {
      // Create the full file name
      filePath = '${directory.path}/$baseFileName$counter$fileExtension';
      counter++;
    } while (await File(filePath).exists());

    // Save the PDF file
    final file = File(filePath);
    await file.writeAsBytes(pdfData);
    print('Saved PDF to $filePath');

    return filePath;
  } catch (e) {
    print('Error saving PDF: $e');
    throw Exception('Error saving PDF');
  }
}

Future<void> openPdfFile(String filePath) async {
  final result = await OpenFile.open(filePath);
  if (result.type != ResultType.done) {
    print('Error opening PDF file: ${result.message}');
    // Prompt the user to install a PDF viewer
  }
}

Future<Printer> _getDefaultPrinter() async {
  final printers = await Printing.listPrinters();
  return printers.firstWhere(
    (printer) => printer.name == 'Microsoft Print to PDF',
    orElse: () => printers.first,
  );
}
