import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:smart_invoice_pro/core/theme/app_theme.dart';
import 'package:smart_invoice_pro/core/widgets/common_widgets.dart';
import 'package:smart_invoice_pro/features/customers/domain/models/customer_model.dart';
import 'package:smart_invoice_pro/features/customers/presentation/providers/customer_provider.dart';
import 'package:smart_invoice_pro/features/invoices/domain/models/invoice_model.dart';
import 'package:smart_invoice_pro/features/invoices/presentation/providers/invoice_provider.dart';
import 'package:smart_invoice_pro/core/services/notification_service.dart';

class CreateInvoiceScreen extends ConsumerStatefulWidget {
  const CreateInvoiceScreen({super.key});

  @override
  ConsumerState<CreateInvoiceScreen> createState() => _CreateInvoiceScreenState();
}

class _CreateInvoiceScreenState extends ConsumerState<CreateInvoiceScreen> {
  Customer? _selectedCustomer;
  DateTime _selectedDate = DateTime.now();
  DateTime _dueDate = DateTime.now().add(const Duration(days: 7));
  String _status = 'UNPAID';
  final List<Map<String, dynamic>> _items = [];
  bool _isLoading = false;

  void _addItem() {
    setState(() {
      _items.add({
        'name': TextEditingController(),
        'qty': TextEditingController(text: '1'),
        'price': TextEditingController(text: '0.00'),
        'tax': TextEditingController(text: '0.00'),
      });
    });
  }

  void _removeItem(int index) {
    setState(() {
      _items.removeAt(index);
    });
  }

  double _calculateSubtotal() {
    double subtotal = 0;
    for (var item in _items) {
      double qty = double.tryParse(item['qty'].text) ?? 0;
      double price = double.tryParse(item['price'].text) ?? 0;
      subtotal += qty * price;
    }
    return subtotal;
  }

  double _calculateTax() {
    double totalTax = 0;
    for (var item in _items) {
      double qty = double.tryParse(item['qty'].text) ?? 0;
      double price = double.tryParse(item['price'].text) ?? 0;
      double taxRate = double.tryParse(item['tax'].text) ?? 0;
      totalTax += (qty * price) * (taxRate / 100);
    }
    return totalTax;
  }

  double _calculateTotal() {
    return _calculateSubtotal() + _calculateTax();
  }

  Future<void> _saveInvoice() async {
    if (_selectedCustomer == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a customer')),
      );
      return;
    }
    if (_items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add at least one item')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final invoiceItems = _items.map((item) {
        return InvoiceItem(
          itemName: item['name'].text,
          qty: int.tryParse(item['qty'].text) ?? 0,
          price: double.tryParse(item['price'].text) ?? 0.0,
          tax: double.tryParse(item['tax'].text) ?? 0.0,
        );
      }).toList();

      final invoice = Invoice(
        invoiceNumber: 'INV-${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}',
        customerId: _selectedCustomer!.id!,
        customerName: _selectedCustomer!.name,
        date: _selectedDate,
        dueDate: _dueDate,
        items: invoiceItems,
        subtotal: _calculateSubtotal(),
        tax: _calculateTax(),
        discount: 0.0,
        grandTotal: _calculateTotal(),
        status: _status,
      );

      await ref.read(invoiceListProvider.notifier).addInvoice(invoice);
      
      NotificationService().showNotification(
        title: 'Invoice Created',
        body: 'Invoice #${invoice.invoiceNumber} created for ${invoice.customerName}! 📄',
      );

      if (mounted) {
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving invoice: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final customersAsync = ref.watch(customerListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('New Invoice'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Customer Selection
            SectionHeader(title: 'Customer Details'),
            const SizedBox(height: 16),
            customersAsync.when(
              data: (customers) => DropdownButtonFormField<Customer>(
                value: _selectedCustomer,
                decoration: InputDecoration(
                  labelText: 'Select Customer',
                  prefixIcon: const Icon(Icons.person_outline),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                items: customers.map((customer) {
                  return DropdownMenuItem(
                    value: customer,
                    child: Text(customer.name),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedCustomer = value;
                  });
                },
              ),
              loading: () => const CircularProgressIndicator(),
              error: (err, stack) => Text('Error loading customers: $err'),
            ),
            const SizedBox(height: 24),

            // Dates & Status
            Row(
              children: [
                Expanded(
                  child: _buildDatePicker(
                    context,
                    'Invoice Date',
                    _selectedDate,
                    (date) => setState(() => _selectedDate = date),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildDatePicker(
                    context,
                    'Due Date',
                    _dueDate,
                    (date) => setState(() => _dueDate = date),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _status,
              decoration: InputDecoration(
                labelText: 'Status',
                prefixIcon: const Icon(Icons.info_outline),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              items: ['PAID', 'UNPAID', 'PENDING'].map((status) {
                return DropdownMenuItem(
                  value: status,
                  child: Text(status),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() => _status = value);
                }
              },
            ),
            const SizedBox(height: 32),

            // Items
            SectionHeader(
              title: 'Items',
              actionText: 'Add Item',
              onAction: _addItem,
            ),
            const SizedBox(height: 16),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _items.length,
              itemBuilder: (context, index) {
                final item = _items[index];
                return Card(
                  elevation: 2,
                  margin: const EdgeInsets.only(bottom: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Item #${index + 1}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.grey,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline, color: Colors.red),
                              onPressed: () => _removeItem(index),
                              tooltip: 'Remove Item',
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        CustomTextField(
                          label: 'Item Name',
                          hint: 'e.g., Web Design Service',
                          controller: item['name'],
                          prefixIcon: Icons.description_outlined,
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: CustomTextField(
                                label: 'Quantity',
                                hint: '1',
                                controller: item['qty'],
                                keyboardType: TextInputType.number,
                                prefixIcon: Icons.numbers,
                                onChanged: (_) => setState(() {}),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: CustomTextField(
                                label: 'Price',
                                hint: '0.00',
                                controller: item['price'],
                                keyboardType: TextInputType.number,
                                prefixIcon: Icons.currency_rupee, // Rupee Icon
                                onChanged: (_) => setState(() {}),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            // GST Input removed as per user request. Fixed at 18%.
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Builder(
                                    builder: (context) {
                                      double qty = double.tryParse(item['qty'].text) ?? 0;
                                      double price = double.tryParse(item['price'].text) ?? 0;
                                      // Fixed 18% Tax (9% CGST + 9% SGST)
                                      double taxRate = 18.0; 
                                      item['tax'].text = '18.0'; // Update controller for saving

                                      double totalAmount = qty * price;
                                      double taxAmount = totalAmount * (taxRate / 100);
                                      double cgst = taxAmount / 2;
                                      double sgst = taxAmount / 2;
                                      
                                      return Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text('CGST (9%): ₹${cgst.toStringAsFixed(2)}', style: const TextStyle(fontSize: 11, color: Colors.grey)),
                                          const SizedBox(height: 2),
                                          Text('SGST (9%): ₹${sgst.toStringAsFixed(2)}', style: const TextStyle(fontSize: 11, color: Colors.grey)),
                                        ],
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 16),
                            // Display Total for this item
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: AppTheme.primaryColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Total',
                                      style: TextStyle(fontSize: 12, color: Colors.grey),
                                    ),
                                    const SizedBox(height: 4),
                                    Builder(
                                      builder: (context) {
                                        double qty = double.tryParse(item['qty'].text) ?? 0;
                                        double price = double.tryParse(item['price'].text) ?? 0;
                                        double total = qty * price;
                                        return Text(
                                          '₹${total.toStringAsFixed(2)}',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: AppTheme.primaryColor,
                                          ),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            if (_items.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'No items added yet',
                    style: TextStyle(color: Colors.grey.shade500),
                  ),
                ),
              ),
            OutlinedButton.icon(
              onPressed: _addItem,
              icon: const Icon(Icons.add),
              label: const Text('Add Another Item'),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Totals
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.05),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  _buildTotalRow('Subtotal', _calculateSubtotal()),
                  const SizedBox(height: 8),
                  _buildTotalRow('Subtotal', _calculateSubtotal()),
                  const SizedBox(height: 8),
                  _buildTotalRow('CGST', _calculateTax() / 2),
                  const SizedBox(height: 4),
                  _buildTotalRow('SGST', _calculateTax() / 2),
                  const SizedBox(height: 8),
                  _buildTotalRow('Total Tax', _calculateTax(), isBold: false),
                  const Divider(height: 24),
                  _buildTotalRow('Total', _calculateTotal(), isBold: true),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Save Button
            PrimaryButton(
              text: 'Save Invoice',
              onPressed: _saveInvoice,
              isLoading: _isLoading,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDatePicker(BuildContext context, String label, DateTime date, Function(DateTime) onSelect) {
    return InkWell(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: date,
          firstDate: DateTime(2000),
          lastDate: DateTime(2100),
        );
        if (picked != null) {
          onSelect(picked);
        }
      },
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          prefixIcon: const Icon(Icons.calendar_today),
        ),
        child: Text(DateFormat('MMM dd, yyyy').format(date)),
      ),
    );
  }

  Widget _buildTotalRow(String label, double amount, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            fontSize: isBold ? 18 : 16,
          ),
        ),
        Text(
          '₹${amount.toStringAsFixed(2)}',
          style: TextStyle(
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            fontSize: isBold ? 18 : 16,
            color: isBold ? AppTheme.primaryColor : null,
          ),
        ),
      ],
    );
  }
}
