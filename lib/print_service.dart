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
  Future<void> printBill(List<Item> items) async {
    if (Platform.isWindows) {
      await printBillWindows(items);
    } else if (Platform.isAndroid) {
      await printBillAndroid(items);
    } else {
      throw UnsupportedError('Unsupported platform');
    }
  }

  Future<void> printBillWindows(List<Item> items) async {
    final pdfData = await generatePdf(items);

    // Direct print with A4 format on Windows
    await Printing.directPrintPdf(
      printer: await _getDefaultPrinter(),
      onLayout: (PdfPageFormat format) async => pdfData,
    );
    print('Order Details:\n$pdfData');
  }

  Future<void> printBillAndroid(List<Item> items) async {
    await requestPermissions();
    final pdfData = await generatePdf(items);
    final filePath = await savePdfToFile(pdfData);
    await openPdfFile(filePath);
    print('Order Details:\n$pdfData');
  }

  Future<Uint8List> generatePdf(List<Item> items) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text('Bill', style: const pw.TextStyle(fontSize: 24)),
            pw.SizedBox(height: 16),
            // ignore: deprecated_member_use
            // pw.Table.fromTextArray(
            //   headers: ['Item', 'Quantity', 'Price'],
            //   data: items
            //       .map((item) => [item.title, item.itemCount, item.price])
            //       .toList(),
            // ),
          ],
        ),
      ),
    );

    return pdf.save();
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
}
