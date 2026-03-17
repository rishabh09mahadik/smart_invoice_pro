import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:smart_invoice_pro/core/services/pdf_service.dart';
import 'package:smart_invoice_pro/core/theme/app_theme.dart';
import 'package:smart_invoice_pro/core/widgets/common_widgets.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_invoice_pro/features/invoices/presentation/providers/invoice_provider.dart';
import 'package:smart_invoice_pro/features/customers/presentation/providers/customer_provider.dart';
import 'package:smart_invoice_pro/features/invoices/domain/models/invoice_model.dart';

class InvoiceDetailScreen extends ConsumerWidget {
  final String? invoiceId;

  const InvoiceDetailScreen({super.key, this.invoiceId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final invoicesAsync = ref.watch(invoiceListProvider);
    final customersAsync = ref.watch(customerListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Invoice Details'),
        actions: [
          invoicesAsync.when(
            data: (invoices) {
              if (invoiceId == null) return const SizedBox.shrink();
              final invoice = invoices.firstWhere(
                (i) => i.id.toString() == invoiceId,
                orElse: () => throw Exception('Invoice not found'),
              );
              
              return customersAsync.when(
                data: (customers) {
                  final customer = customers.firstWhere(
                    (c) => c.id == invoice.customerId,
                    orElse: () => throw Exception('Customer not found'),
                  );

                  // Helper to format items for PDF
                  final pdfItems = invoice.items.map((item) => {
                    'item': item.itemName,
                    'qty': item.qty,
                    'price': item.price,
                    'tax': item.tax,
                  }).toList();

                  return Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.share_outlined),
                        onPressed: () async {
                          final pdfService = PdfService();
                          final pdfBytes = await pdfService.generateInvoice(
                            invoiceNumber: invoice.invoiceNumber,
                            date: invoice.date,
                            dueDate: invoice.dueDate,
                            customerName: customer.name,
                            customerEmail: customer.email,
                            customerAddress: customer.address,
                            items: pdfItems,
                            subtotal: invoice.subtotal,
                            tax: invoice.tax,
                            discount: invoice.discount,
                            grandTotal: invoice.grandTotal,
                            status: invoice.status,
                          );
                          await pdfService.shareInvoice(pdfBytes, 'invoice_${invoice.invoiceNumber}.pdf');
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.print_outlined),
                        onPressed: () async {
                          final pdfService = PdfService();
                          final pdfBytes = await pdfService.generateInvoice(
                            invoiceNumber: invoice.invoiceNumber,
                            date: invoice.date,
                            dueDate: invoice.dueDate,
                            customerName: customer.name,
                            customerEmail: customer.email,
                            customerAddress: customer.address,
                            items: pdfItems,
                            subtotal: invoice.subtotal,
                            tax: invoice.tax,
                            discount: invoice.discount,
                            grandTotal: invoice.grandTotal,
                            status: invoice.status,
                          );
                          await pdfService.printInvoice(pdfBytes);
                        },
                      ),
                    ],
                  );
                },
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
              );
            },
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),
          PopupMenuButton(
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'delete', child: Text('Delete', style: TextStyle(color: Colors.red))),
            ],
            onSelected: (value) async {
              if (value == 'delete' && invoiceId != null) {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Delete Invoice'),
                    content: const Text('Are you sure you want to delete this invoice?'),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
                      TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete', style: TextStyle(color: Colors.red))),
                    ],
                  ),
                );

                if (confirm == true) {
                  await ref.read(invoiceListProvider.notifier).deleteInvoice(int.parse(invoiceId!));
                  if (context.mounted) Navigator.pop(context);
                }
              }
            },
          ),
        ],
      ),
      body: invoicesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
        data: (invoices) {
          if (invoiceId == null) return const Center(child: Text('Invoice not found'));
          
          final invoice = invoices.firstWhere(
            (i) => i.id.toString() == invoiceId,
            orElse: () => throw Exception('Invoice not found'),
          );

          return customersAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, stack) => Center(child: Text('Error loading customer: $err')),
            data: (customers) {
              final customer = customers.firstWhere(
                (c) => c.id == invoice.customerId,
                orElse: () => throw Exception('Customer not found'),
              );

              // Helper to format items for PDF
              final pdfItems = invoice.items.map((item) => {
                'item': item.itemName,
                'qty': item.qty,
                'price': item.price,
                'tax': item.tax,
              }).toList();

              return SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Status Banner
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: invoice.status == 'PAID' ? Colors.green.shade100 : Colors.orange.shade100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            invoice.status == 'PAID' ? Icons.check_circle : Icons.pending,
                            color: invoice.status == 'PAID' ? Colors.green.shade800 : Colors.orange.shade800,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'This invoice is ${invoice.status}',
                            style: TextStyle(
                              color: invoice.status == 'PAID' ? Colors.green.shade800 : Colors.orange.shade800,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Invoice Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              invoice.invoiceNumber,
                              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Date: ${invoice.date.toString().split(' ')[0]}',
                              style: TextStyle(color: Colors.grey.shade600),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            const Text('Amount Due', style: TextStyle(color: Colors.grey)),
                            const SizedBox(height: 4),
                            Text(
                              '₹${invoice.grandTotal.toStringAsFixed(2)}',
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.primaryColor,
                                  ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Customer Details
                    const Text('Bill To', style: TextStyle(color: Colors.grey)),
                    const SizedBox(height: 8),
                    Text(
                      customer.name,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    Text(customer.email),
                    Text(customer.phone),
                    Text(customer.address),
                    const Divider(height: 32),

                    // Items Table
                    const Text('Items', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 16),
                    Table(
                      columnWidths: const {
                        0: FlexColumnWidth(3),
                        1: FlexColumnWidth(1),
                        2: FlexColumnWidth(1.5),
                      },
                      children: [
                        const TableRow(
                          children: [
                            Padding(padding: EdgeInsets.only(bottom: 8), child: Text('Description', style: TextStyle(color: Colors.grey))),
                            Padding(padding: EdgeInsets.only(bottom: 8), child: Text('Qty', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey))),
                            Padding(padding: EdgeInsets.only(bottom: 8), child: Text('Amount', textAlign: TextAlign.right, style: TextStyle(color: Colors.grey))),
                          ],
                        ),
                        ...invoice.items.map((item) => TableRow(
                              children: [
                                Padding(padding: const EdgeInsets.symmetric(vertical: 8), child: Text(item.itemName)),
                                Padding(padding: const EdgeInsets.symmetric(vertical: 8), child: Text(item.qty.toString(), textAlign: TextAlign.center)),
                                Padding(padding: const EdgeInsets.symmetric(vertical: 8), child: Text('₹${(item.price * item.qty).toStringAsFixed(2)}', textAlign: TextAlign.right)),
                              ],
                            )),
                      ],
                    ),
                    const Divider(height: 32),

                    // Totals
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Subtotal'),
                        Text('₹${invoice.subtotal.toStringAsFixed(2)}'),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Tax'),
                        Text('₹${invoice.tax.toStringAsFixed(2)}'),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Discount'),
                        Text('-₹${invoice.discount.toStringAsFixed(2)}'),
                      ],
                    ),
                    const Divider(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Grand Total',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        Text(
                          '₹${invoice.grandTotal.toStringAsFixed(2)}',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),

                    // Actions
                    if (invoice.status != 'PAID')
                      PrimaryButton(
                        text: 'Record Payment',
                        onPressed: () async {
                          await ref.read(invoiceListProvider.notifier).updateInvoiceStatus(invoice.id!, 'PAID');
                        },
                      ),
                    const SizedBox(height: 16),
                    OutlinedButton(
                      onPressed: () async {
                        final pdfService = PdfService();
                        final pdfBytes = await pdfService.generateInvoice(
                          invoiceNumber: invoice.invoiceNumber,
                          date: invoice.date,
                          dueDate: invoice.dueDate,
                          customerName: customer.name,
                          customerEmail: customer.email,
                          customerAddress: customer.address,
                          items: pdfItems,
                          subtotal: invoice.subtotal,
                          tax: invoice.tax,
                          discount: invoice.discount,
                          grandTotal: invoice.grandTotal,
                          status: invoice.status,
                        );
                        await pdfService.shareInvoice(pdfBytes, 'invoice_${invoice.invoiceNumber}.pdf');
                      },
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 56),
                      ),
                      child: const Text('Download PDF'),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
