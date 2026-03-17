import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_invoice_pro/features/customers/data/repositories/customer_repository.dart';
import 'package:smart_invoice_pro/features/customers/domain/models/customer_model.dart';
import 'package:smart_invoice_pro/features/notifications/presentation/providers/notification_provider.dart';
import 'package:smart_invoice_pro/features/notifications/domain/models/notification_model.dart';

final customerRepositoryProvider = Provider((ref) => CustomerRepository());

final customerListProvider = StateNotifierProvider<CustomerListNotifier, AsyncValue<List<Customer>>>((ref) {
  final repository = ref.watch(customerRepositoryProvider);
  final notificationNotifier = ref.watch(notificationListProvider.notifier);
  return CustomerListNotifier(repository, notificationNotifier);
});

class CustomerListNotifier extends StateNotifier<AsyncValue<List<Customer>>> {
  final CustomerRepository _repository;
  final NotificationListNotifier _notificationNotifier;

  CustomerListNotifier(this._repository, this._notificationNotifier) : super(const AsyncValue.loading()) {
    loadCustomers();
  }

  Future<void> loadCustomers() async {
    try {
      state = const AsyncValue.loading();
      final customers = await _repository.readAll();
      state = AsyncValue.data(customers);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> addCustomer(Customer customer) async {
    try {
      await _repository.create(customer);
      await loadCustomers();
      await _notificationNotifier.addNotification(AppNotification(
        title: 'New Customer Added',
        message: '${customer.name} has been added to your customers.',
        timestamp: DateTime.now(),
        type: 'customer',
      ));
    } catch (e) {
      // Handle error
    }
  }

  Future<void> updateCustomer(Customer customer) async {
    try {
      await _repository.update(customer);
      await loadCustomers();
    } catch (e) {
      // Handle error
    }
  }

  Future<void> deleteCustomer(int id) async {
    try {
      await _repository.delete(id);
      await loadCustomers();
    } catch (e) {
      // Handle error
    }
  }
}
