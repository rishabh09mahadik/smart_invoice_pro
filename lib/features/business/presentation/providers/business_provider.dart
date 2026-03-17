import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_invoice_pro/features/business/data/business_repository.dart';

final businessRepositoryProvider = Provider((ref) => BusinessRepository());

final businessDetailsProvider = FutureProvider<Map<String, String>>((ref) async {
  final repository = ref.read(businessRepositoryProvider);
  return repository.getBusinessDetails();
});

class BusinessNotifier extends StateNotifier<AsyncValue<void>> {
  final BusinessRepository _repository;
  final Ref _ref;

  BusinessNotifier(this._repository, this._ref) : super(const AsyncData(null));

  Future<void> saveDetails({
    required String name,
    required String address,
    required String phone,
    required String email,
    required String gst,
    required String currency,
  }) async {
    state = const AsyncLoading();
    try {
      await _repository.saveBusinessDetails(
        name: name,
        address: address,
        phone: phone,
        email: email,
        gst: gst,
        currency: currency,
      );
      _ref.invalidate(businessDetailsProvider);
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }
}

final businessNotifierProvider = StateNotifierProvider<BusinessNotifier, AsyncValue<void>>((ref) {
  return BusinessNotifier(ref.read(businessRepositoryProvider), ref);
});
