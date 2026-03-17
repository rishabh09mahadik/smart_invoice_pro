import 'dart:typed_data';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';

class PdfService {
  // Brand Colors
  static const PdfColor _brandBlue = PdfColor.fromInt(0xFF0066FF);
  static const PdfColor _lightGrey = PdfColor.fromInt(0xFFF5F7FA);
  static const PdfColor _darkText = PdfColor.fromInt(0xFF1A1A1A);
  static const PdfColor _pendingRed = PdfColor.fromInt(0xFFFF3B3B);
  static const PdfColor _paidGreen = PdfColor.fromInt(0xFF28C76F);

  Future<Uint8List> generateInvoice({
    required String invoiceNumber,
    required DateTime date,
    required DateTime dueDate,
    required String customerName,
    required String customerEmail,
    required String customerAddress,
    required List<Map<String, dynamic>> items,
    required double subtotal,
    required double tax,
    required double discount,
    required double grandTotal,
    required String status,
  }) async {
    final pdf = pw.Document();

    // Load Fonts
    final fontRegular = await PdfGoogleFonts.robotoRegular();
    final fontBold = await PdfGoogleFonts.robotoBold();
    final fontHeader = await PdfGoogleFonts.poppinsBold();
    final fontIcon = await PdfGoogleFonts.materialIcons();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        theme: pw.ThemeData.withFont(
          base: fontRegular,
          bold: fontBold,
          icons: fontIcon,
        ),
        build: (pw.Context context) {
          return [
            _buildHeader(invoiceNumber, status, fontHeader, date),
            pw.SizedBox(height: 30),
            _buildInvoiceDetails(invoiceNumber, date, fontHeader),
            pw.SizedBox(height: 30),
            _buildCustomerInfo(customerName, customerEmail, customerAddress, fontHeader),
            pw.SizedBox(height: 30),
            _buildInvoiceTable(items, fontHeader),
            pw.SizedBox(height: 20),
            _buildTotalSection(subtotal, tax, discount, grandTotal, fontHeader),
            pw.SizedBox(height: 40),
            _buildFooter(),
          ];
        },
      ),
    );

    return pdf.save();
  }

  pw.Widget _buildHeader(String invoiceNumber, String status, pw.Font fontHeader, DateTime date) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        // Logo & Company Name
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Container(
              padding: const pw.EdgeInsets.all(8),
              decoration: pw.BoxDecoration(
                color: _brandBlue,
                borderRadius: pw.BorderRadius.circular(8),
              ),
              child: pw.Icon(const pw.IconData(0xe0af), color: PdfColors.white, size: 24), // business icon
            ),
            pw.SizedBox(height: 8),
            pw.Text(
              'Smart Invoice',
              style: pw.TextStyle(
                font: fontHeader,
                fontSize: 20,
                color: _brandBlue,
              ),
            ),
          ],
        ),
        // Status Badge
        pw.Container(
          padding: const pw.EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: pw.BoxDecoration(
            color: status == 'PAID' ? _paidGreen : _pendingRed,
            borderRadius: pw.BorderRadius.circular(12),
          ),
          child: pw.Text(
            status.toUpperCase(),
            style: pw.TextStyle(
              font: fontHeader,
              color: PdfColors.white,
              fontSize: 10,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  pw.Widget _buildInvoiceDetails(String invoiceNumber, DateTime date, pw.Font fontHeader) {
    final dateFormat = DateFormat('MMM dd, yyyy');
    return pw.Container(
      padding: const pw.EdgeInsets.all(20),
      decoration: pw.BoxDecoration(
        color: _lightGrey,
        borderRadius: pw.BorderRadius.circular(10),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('Invoice No.', style: const pw.TextStyle(color: PdfColors.grey700, fontSize: 10)),
              pw.SizedBox(height: 2),
              pw.Text(invoiceNumber, style: pw.TextStyle(font: fontHeader, fontSize: 14, color: _darkText)),
            ],
          ),
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
              pw.Text('Issue Date', style: const pw.TextStyle(color: PdfColors.grey700, fontSize: 10)),
              pw.SizedBox(height: 2),
              pw.Text(dateFormat.format(date), style: pw.TextStyle(font: fontHeader, fontSize: 14, color: _darkText)),
            ],
          ),
        ],
      ),
    );
  }

  pw.Widget _buildCustomerInfo(String name, String email, String address, pw.Font fontHeader) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text('Bill To:', style: pw.TextStyle(font: fontHeader, color: PdfColors.grey700, fontSize: 12)),
        pw.SizedBox(height: 8),
        pw.Text(name, style: pw.TextStyle(font: fontHeader, fontSize: 16, color: _darkText)),
        pw.Text(email, style: const pw.TextStyle(color: PdfColors.grey700)),
        pw.Text(address, style: const pw.TextStyle(color: PdfColors.grey700)),
      ],
    );
  }

  pw.Widget _buildInvoiceTable(List<Map<String, dynamic>> items, pw.Font fontHeader) {
    return pw.Container(
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey200),
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        children: [
          // Header
          pw.Container(
            padding: const pw.EdgeInsets.all(12),
            decoration: const pw.BoxDecoration(
              color: _brandBlue,
              borderRadius: pw.BorderRadius.vertical(top: pw.Radius.circular(7)),
            ),
            child: pw.Row(
              children: [
                pw.Expanded(flex: 3, child: pw.Text('Item', style: pw.TextStyle(font: fontHeader, color: PdfColors.white, fontSize: 12))),
                pw.Expanded(flex: 1, child: pw.Text('Qty', textAlign: pw.TextAlign.center, style: pw.TextStyle(font: fontHeader, color: PdfColors.white, fontSize: 12))),
                pw.Expanded(flex: 2, child: pw.Text('Price', textAlign: pw.TextAlign.right, style: pw.TextStyle(font: fontHeader, color: PdfColors.white, fontSize: 12))),
                pw.Expanded(flex: 2, child: pw.Text('Total', textAlign: pw.TextAlign.right, style: pw.TextStyle(font: fontHeader, color: PdfColors.white, fontSize: 12))),
              ],
            ),
          ),
          // Rows
          ...items.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;
            final total = (item['qty'] as int) * (item['price'] as double);
            
            return pw.Container(
              color: index % 2 == 0 ? PdfColors.white : _lightGrey,
              padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: pw.Row(
                children: [
                  pw.Expanded(flex: 3, child: pw.Text(item['item'], style: const pw.TextStyle(color: _darkText))),
                  pw.Expanded(flex: 1, child: pw.Text(item['qty'].toString(), textAlign: pw.TextAlign.center, style: const pw.TextStyle(color: _darkText))),
                  pw.Expanded(flex: 2, child: pw.Text('${item['price']}', textAlign: pw.TextAlign.right, style: const pw.TextStyle(color: _darkText))),
                  pw.Expanded(flex: 2, child: pw.Text('${total.toStringAsFixed(2)}', textAlign: pw.TextAlign.right, style: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: _darkText))),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  pw.Widget _buildTotalSection(double subtotal, double tax, double discount, double grandTotal, pw.Font fontHeader) {
    return pw.Align(
      alignment: pw.Alignment.centerRight,
      child: pw.Container(
        width: 200,
        child: pw.Column(
          children: [
            _buildTotalRow('Subtotal', subtotal),
            pw.SizedBox(height: 5),
            _buildTotalRow('Tax', tax),
            pw.SizedBox(height: 5),
            _buildTotalRow('Discount', discount, isNegative: true),
            pw.SizedBox(height: 10),
            pw.Container(
              padding: const pw.EdgeInsets.all(10),
              decoration: pw.BoxDecoration(
                color: _brandBlue,
                borderRadius: pw.BorderRadius.circular(8),
              ),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('TOTAL', style: pw.TextStyle(font: fontHeader, color: PdfColors.white, fontWeight: pw.FontWeight.bold)),
                  pw.Text('${grandTotal.toStringAsFixed(2)}', style: pw.TextStyle(font: fontHeader, color: PdfColors.white, fontWeight: pw.FontWeight.bold, fontSize: 14)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  pw.Widget _buildTotalRow(String label, double amount, {bool isNegative = false}) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text(label, style: const pw.TextStyle(color: PdfColors.grey700)),
        pw.Text('${isNegative ? "-" : ""}${amount.toStringAsFixed(2)}', style: const pw.TextStyle(color: _darkText)),
      ],
    );
  }

  pw.Widget _buildFooter() {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.center,
      children: [
        pw.Divider(color: PdfColors.grey300),
        pw.SizedBox(height: 10),
        pw.Text('Thank you for your business!', style: const pw.TextStyle(color: PdfColors.grey600)),
      ],
    );
  }

  Future<void> printInvoice(Uint8List pdfBytes) async {
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdfBytes,
    );
  }

  Future<void> shareInvoice(Uint8List pdfBytes, String filename) async {
    await Printing.sharePdf(bytes: pdfBytes, filename: filename);
  }
}
