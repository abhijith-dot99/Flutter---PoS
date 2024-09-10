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
  Future<void> printBill(List<Item> items, double subtotal, double tax,
      double total, String selectedcust) async {
    if (Platform.isWindows) {
      await printBillWindows(items, subtotal, tax, total, selectedcust);
    } else if (Platform.isAndroid) {
      await printBillAndroid(items, subtotal, tax, total, selectedcust);
    } else {
      throw UnsupportedError('Unsupported platform');
    }
  }

  Future<void> printBillWindows(List<Item> items, double subtotal, double tax,
      double total, String selectedcust) async {
    final pdfData =
        await generatePdf(items, subtotal, tax, total, selectedcust);

    // Direct print with A4 format on Windows
    await Printing.directPrintPdf(
      printer: await _getDefaultPrinter(),
      onLayout: (PdfPageFormat format) async => pdfData,
    );
    print('Order Details:\n$pdfData');
  }

  Future<void> printBillAndroid(List<Item> items, double subtotal, double tax,
      double total, String selectedcust) async {
    await requestPermissions();
    final pdfData =
        await generatePdf(items, subtotal, tax, total, selectedcust);
    final filePath = await savePdfToFile(pdfData);
    await openPdfFile(filePath);
    print('Order Details:\n$pdfData');
  }

  Future<Uint8List> generatePdf(List<Item> items, double subtotal, double tax,
      double total, String selectedcust) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text('Bill', style: const pw.TextStyle(fontSize: 24)),
            pw.SizedBox(height: 16),
            pw.Table.fromTextArray(
              headers: ['Item', 'Quantity', 'Price', 'Tax', 'Customer'],
              data: items
                  .map((item) => [
                        item.itemName,
                        item.itemCount,
                        item.price,
                        item.tax,
                        selectedcust,
                      ])
                  .toList(),
            ),
            pw.SizedBox(height: 20),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text('Subtotal:',
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                pw.Text('${subtotal.toStringAsFixed(2)}'),
              ],
            ),
            pw.SizedBox(height: 8),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text('Tax:',
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                pw.Text('${tax.toStringAsFixed(2)}'),
              ],
            ),
            pw.SizedBox(height: 8),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text('Total:',
                    style: pw.TextStyle(
                        fontWeight: pw.FontWeight.bold, fontSize: 16)),
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
  if (await Permission.storage.request().isGranted) {
    // Permissions granted
  } else {
    // Handle the case where permissions are not granted
    throw Exception('Storage permission not granted');
  }
}

Future<String> savePdfToFile(Uint8List pdfData) async {
  try {
    final directory = await getExternalStorageDirectory();
    final filePath = '${directory!.path}/bill.pdf';
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
  }
}

Future<Printer> _getDefaultPrinter() async {
  final printers = await Printing.listPrinters();
  return printers.firstWhere(
    (printer) => printer.name == 'Microsoft Print to PDF',
    orElse: () => printers.first,
  );
}
