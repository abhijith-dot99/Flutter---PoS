import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:open_file/open_file.dart';
import 'model/item.dart';

class GeneratePDF {
  Future<void> generate3inch(
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
    String customercompanyCrNo,
    String companyVatNo,
    String companyCrNo,
    String companyAddress,
    double discount,
    File qrData,
  ) async {
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
          customercompanyCrNo,
          companyVatNo,
          companyCrNo,
          companyAddress,
          discount,
          qrData);
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
          customercompanyCrNo,
          companyVatNo,
          companyCrNo,
          companyAddress,
          discount,
          qrData);
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
      String customercompanyCrNo,
      String companyVatNo,
      String companyCrNo,
      String companyAddress,
      discount,
      qrData) async {
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
        customercompanyCrNo,
        companyVatNo,
        companyCrNo,
        companyAddress,
        discount,
        qrData);

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
      String customercompanyCrNo,
      String companyVatNo,
      String companyCrNo,
      String companyAddress,
      discount,
      qrData) async {
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
        customercompanyCrNo,
        companyVatNo,
        companyCrNo,
        companyAddress,
        discount,
        qrData);
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
      String customercompanyCrNo,
      String sellerVatNumber,
      String sellercompanyCrNo,
      String sellerAddress,
      discount,
      qrData) async {
    final pdf = pw.Document();
    final imageBytes = await qrData.readAsBytes();
    pdf.addPage(
      pw.Page(
        // pageFormat: PdfPageFormat.a4,
        // ignore: prefer_const_constructors
        //  pageFormat: PdfPageFormat(72 * PdfPageFormat.mm, PdfPageFormat.undefined as double),
        pageFormat:
            const PdfPageFormat(72 * PdfPageFormat.mm, 200 * PdfPageFormat.mm),
        build: (pw.Context context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            // Invoice Heading
            pw.Center(
              child: pw.Text(
                'TAX INVOICE',
                style:
                    pw.TextStyle(fontSize: 6, fontWeight: pw.FontWeight.bold),
              ),
            ),
            pw.SizedBox(height: 18),
            //   pw.Center(
            //   child: pw.Image(
            //     pw.MemoryImage(
            //       base64Decode(qrData), // Decode the base64 QR data
            //     ),
            //     width: 100,
            //     height: 100,
            //   ),
            // ),

            // pw.Center(
            //   child: pw.Image(
            //     pw.MemoryImage(imageBytes), // Use qrFile for image from file
            //     width: 50,
            //     height: 50,
            //   ),
            // ),

            // Invoice number and date
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text('Invoice No: $salesInvoice',
                    style: const pw.TextStyle(fontSize: 6)),
                pw.Text('Date: ${DateTime.now().toString().substring(0, 10)}',
                    style: const pw.TextStyle(fontSize: 6)),
              ],
            ),
            pw.SizedBox(height: 16),
//buyesr and seller
            pw.Table(
              columnWidths: {
                0: const pw.FlexColumnWidth(1),
                1: const pw.FlexColumnWidth(1),
              },
              border: pw.TableBorder.all(
                color: PdfColors.black,
                width:
                    1, // Outer border for the entire table (including Seller and Buyer)
              ),
              children: [
                // Header Row for Seller and Buyer
                pw.TableRow(
                  children: [
                    pw.Padding(
                      padding: pw.EdgeInsets.all(8),
                      child: pw.Text(
                        'Seller',
                        style: pw.TextStyle(
                          fontWeight: pw.FontWeight.bold,
                          fontSize: 9,
                        ),
                        textAlign: pw.TextAlign.center,
                      ),
                    ),
                    pw.Padding(
                      padding: pw.EdgeInsets.all(8),
                      child: pw.Text(
                        'Buyer',
                        style: pw.TextStyle(
                          fontWeight: pw.FontWeight.bold,
                          fontSize: 9,
                        ),
                        textAlign: pw.TextAlign.center,
                      ),
                    ),
                  ],
                ),

                // Main Table Row containing Seller and Buyer sub-tables
                pw.TableRow(
                  children: [
                    // Seller Table
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(0),
                      child: pw.Table(
                        columnWidths: {
                          0: const pw.FlexColumnWidth(1), // Label column
                          1: const pw.FlexColumnWidth(2), // Data column
                        },
                        border: pw.TableBorder.all(
                          color: PdfColors.black,
                          width:
                              1, // Ensure row-wise and column-wise separation within Seller table
                        ),
                        children: [
                          pw.TableRow(
                            children: [
                              pw.Padding(
                                padding: const pw.EdgeInsets.only(
                                    top: 10, bottom: 10, left: 5),
                                child: pw.Text('Name:',
                                    style: const pw.TextStyle(fontSize: 6)),
                              ),
                              pw.Padding(
                                padding: const pw.EdgeInsets.only(
                                    top: 10, bottom: 10, left: 5),
                                child: pw.Text(selectedCompanyName,
                                    style: const pw.TextStyle(fontSize: 6)),
                              ),
                            ],
                          ),
                          pw.TableRow(
                            children: [
                              pw.Padding(
                                padding: const pw.EdgeInsets.only(
                                    top: 10, bottom: 10, left: 5),
                                child: pw.Text('Address:',
                                    style: const pw.TextStyle(fontSize: 6)),
                              ),
                              pw.Padding(
                                padding: const pw.EdgeInsets.only(
                                    top: 10, bottom: 10, left: 5),
                                child: pw.Text(sellerAddress,
                                    style: const pw.TextStyle(fontSize: 6)),
                              ),
                            ],
                          ),
                          pw.TableRow(
                            children: [
                              pw.Padding(
                                padding: const pw.EdgeInsets.only(
                                    top: 10, bottom: 10, left: 5),
                                child: pw.Text('VAT No:',
                                    style: const pw.TextStyle(fontSize: 6)),
                              ),
                              pw.Padding(
                                padding: const pw.EdgeInsets.only(
                                    top: 10, bottom: 10, left: 5),
                                child: pw.Text(sellerVatNumber,
                                    style: pw.TextStyle(fontSize: 6)),
                              ),
                            ],
                          ),
                          pw.TableRow(
                            children: [
                              pw.Padding(
                                padding: pw.EdgeInsets.only(
                                    top: 10, bottom: 10, left: 5),
                                child: pw.Text('CR No:',
                                    style: pw.TextStyle(fontSize: 6)),
                              ),
                              pw.Padding(
                                padding: pw.EdgeInsets.only(
                                    top: 10, bottom: 10, left: 5),
                                child: pw.Text(sellercompanyCrNo,
                                    style: pw.TextStyle(fontSize: 6)),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Buyer Table
                    pw.Padding(
                      padding: pw.EdgeInsets.all(0),
                      child: pw.Table(
                        columnWidths: {
                          0: pw.FlexColumnWidth(1), // Label column
                          1: pw.FlexColumnWidth(2), // Data column
                        },
                        border: pw.TableBorder.all(
                          color: PdfColors.black,
                          width:
                              1, // Ensure row-wise and column-wise separation within Buyer table
                        ),
                        children: [
                          pw.TableRow(
                            children: [
                              pw.Padding(
                                padding: pw.EdgeInsets.only(
                                    top: 10, bottom: 10, left: 5),
                                child: pw.Text('Name:',
                                    style: pw.TextStyle(fontSize: 6)),
                              ),
                              pw.Padding(
                                padding: pw.EdgeInsets.only(
                                    top: 10, bottom: 10, left: 5),
                                child: pw.Text(customerName,
                                    style: pw.TextStyle(fontSize: 6)),
                              ),
                            ],
                          ),
                          pw.TableRow(
                            children: [
                              pw.Padding(
                                padding: pw.EdgeInsets.only(
                                    top: 10, bottom: 10, left: 5),
                                child: pw.Text('Address:',
                                    style: pw.TextStyle(fontSize: 6)),
                              ),
                              pw.Padding(
                                padding: pw.EdgeInsets.only(
                                    top: 10, bottom: 10, left: 5),
                                child: pw.Text(customerAddressTitle,
                                    style: pw.TextStyle(fontSize: 6)),
                              ),
                            ],
                          ),
                          pw.TableRow(
                            children: [
                              pw.Padding(
                                padding: const pw.EdgeInsets.only(
                                    top: 10, bottom: 10, left: 5),
                                child: pw.Text('VAT No:',
                                    style: pw.TextStyle(fontSize: 6)),
                              ),
                              pw.Padding(
                                padding: const pw.EdgeInsets.only(
                                    top: 10, bottom: 10, left: 5),
                                child: pw.Text(customerVatNumber,
                                    style: pw.TextStyle(fontSize: 6)),
                              ),
                            ],
                          ),
                          pw.TableRow(
                            children: [
                              pw.Padding(
                                padding: const pw.EdgeInsets.only(
                                    top: 10, bottom: 10, left: 5),
                                child: pw.Text('CR No:',
                                    style: const pw.TextStyle(fontSize: 6)),
                              ),
                              pw.Padding(
                                padding: const pw.EdgeInsets.only(
                                    top: 10, bottom: 10, left: 5),
                                child: pw.Text(customercompanyCrNo,
                                    style: const pw.TextStyle(fontSize: 6)),
                              ),
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
            // ignore: deprecated_member_use
            pw.Table.fromTextArray(
              headers: [
                'S.No',
                'Particulars',
                'Unit Price',
                'Quantity',
                // 'Tax',
                'Total'
              ],
              data: items.asMap().entries.map((entry) {
                int index = entry.key + 1; // Serial number (1-based index)
                Item item = entry.value;
                double price = double.tryParse(item.price) ??
                    0.0; // Default to 0.0 if parsing fails
                int quantity = item.itemCount;
                double itemTotal = price * quantity;
                return [
                  index.toString(), // S.No column
                  item.itemName,
                  item.price,
                  item.itemCount,
                  // tax,
                  itemTotal.toStringAsFixed(2),
                ];
              }).toList(),
              headerStyle:
                  pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 8),
              cellStyle: const pw.TextStyle(
                fontSize: 8, // Font size for cell data
              ),
              cellAlignment: pw.Alignment.center, // Center-align table cells
            ),

            pw.SizedBox(height: 20),
            // pw.Spacer(),

            // Subtotal, Tax, and Total rows
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text('Subtotal:',
                    style: pw.TextStyle(
                        fontWeight: pw.FontWeight.bold, fontSize: 10)),
                pw.Text(subtotal.toStringAsFixed(2),
                    style: pw.TextStyle(
                        fontWeight: pw.FontWeight.bold, fontSize: 10)),
              ],
            ),
            pw.SizedBox(height: 8),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text('Tax:',
                    style: pw.TextStyle(
                        fontWeight: pw.FontWeight.bold, fontSize: 10)),
                pw.Text(tax.toStringAsFixed(2),
                    style: pw.TextStyle(
                        fontWeight: pw.FontWeight.bold, fontSize: 10)),
              ],
            ),
            pw.SizedBox(height: 8),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text('Discount:',
                    style: pw.TextStyle(
                        fontWeight: pw.FontWeight.bold, fontSize: 10)),
                pw.Text('${discount.toStringAsFixed(2)}',
                    style: pw.TextStyle(
                        fontWeight: pw.FontWeight.bold, fontSize: 10)),
              ],
            ),
            pw.SizedBox(height: 8),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text('Total:',
                    style: pw.TextStyle(
                        fontWeight: pw.FontWeight.bold, fontSize: 10)),
                pw.Text(total.toStringAsFixed(2),
                    style: pw.TextStyle(
                        fontWeight: pw.FontWeight.bold, fontSize: 10)),
              ],
            ),
             pw.SizedBox(height: 8),
               pw.Center(
              child: pw.Image(
                pw.MemoryImage(imageBytes), // Use qrFile for image from file
                width: 50,
                height: 50,
              ),
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
