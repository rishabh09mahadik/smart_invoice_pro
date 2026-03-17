import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_invoice_pro/features/invoices/data/repositories/invoice_repository.dart';
import 'package:smart_invoice_pro/features/invoices/domain/models/invoice_model.dart';
import 'package:smart_invoice_pro/features/notifications/presentation/providers/notification_provider.dart';
import 'package:smart_invoice_pro/features/notifications/domain/models/notification_model.dart';

final invoiceRepositoryProvider = Provider((ref) => InvoiceRepository());

final invoiceListProvider = StateNotifierProvider<InvoiceListNotifier, AsyncValue<List<Invoice>>>((ref) {
  final repository = ref.watch(invoiceRepositoryProvider);
  final notificationNotifier = ref.watch(notificationListProvider.notifier);
  return InvoiceListNotifier(repository, notificationNotifier);
});

class InvoiceListNotifier extends StateNotifier<AsyncValue<List<Invoice>>> {
  final InvoiceRepository _repository;
  final NotificationListNotifier _notificationNotifier;

  InvoiceListNotifier(this._repository, this._notificationNotifier) : super(const AsyncValue.loading()) {
    loadInvoices();
  }

  Future<void> loadInvoices() async {
    try {
      state = const AsyncValue.loading();
      final invoices = await _repository.readAll();
      state = AsyncValue.data(invoices);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> addInvoice(Invoice invoice) async {
    try {
      await _repository.create(invoice);
      await loadInvoices();
      await _notificationNotifier.addNotification(AppNotification(
        title: 'New Invoice Created',
        message: 'Invoice ${invoice.invoiceNumber} has been created.',
        timestamp: DateTime.now(),
        type: 'invoice',
      ));
    } catch (e) {
      // Handle error
    }
  }

  Future<void> deleteInvoice(int id) async {
    try {
      await _repository.delete(id);
      await loadInvoices();
    } catch (e) {
      // Handle error
    }
  }

  Future<void> updateInvoiceStatus(int id, String status) async {
    try {
      await _repository.updateStatus(id, status);
      await loadInvoices();
      if (status == 'PAID') {
        await _notificationNotifier.addNotification(AppNotification(
          title: 'Payment Received',
          message: 'Invoice #$id has been marked as PAID.',
          timestamp: DateTime.now(),
          type: 'invoice',
        ));
      }
    } catch (e) {
      // Handle error
    }
  }
}
