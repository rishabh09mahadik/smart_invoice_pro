import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_invoice_pro/features/auth/presentation/providers/auth_provider.dart';
import 'package:smart_invoice_pro/features/auth/presentation/screens/login_screen.dart';
import 'package:smart_invoice_pro/features/auth/presentation/screens/signup_screen.dart';
import 'package:smart_invoice_pro/features/auth/presentation/screens/welcome_screen.dart';
import 'package:smart_invoice_pro/features/auth/presentation/screens/forgot_password_screen.dart';
import 'package:smart_invoice_pro/features/business/presentation/screens/business_setup_screen.dart';
import 'package:smart_invoice_pro/features/customers/presentation/screens/add_edit_customer_screen.dart';
import 'package:smart_invoice_pro/features/customers/presentation/screens/customer_list_screen.dart';
import 'package:smart_invoice_pro/features/dashboard/presentation/screens/dashboard_screen.dart';
import 'package:smart_invoice_pro/features/invoices/presentation/screens/create_invoice_screen.dart';
import 'package:smart_invoice_pro/features/invoices/presentation/screens/invoice_detail_screen.dart';
import 'package:smart_invoice_pro/features/invoices/presentation/screens/invoice_list_screen.dart';
import 'package:smart_invoice_pro/features/items/presentation/screens/add_edit_item_screen.dart';
import 'package:smart_invoice_pro/features/items/presentation/screens/item_list_screen.dart';
import 'package:smart_invoice_pro/features/settings/presentation/screens/settings_screen.dart';
import 'package:smart_invoice_pro/features/notifications/presentation/screens/notifications_screen.dart';
import 'package:smart_invoice_pro/features/auth/presentation/screens/profile_screen.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    refreshListenable: GoRouterRefreshStream(ref.watch(authProvider.notifier).stream),
    redirect: (context, state) {
      final authState = ref.read(authProvider);
      final isLoggedIn = authState.status == AuthStatus.authenticated;
      final isLoggingIn = state.matchedLocation == '/login' ||
          state.matchedLocation == '/signup' ||
          state.matchedLocation == '/forgot-password' ||
          state.matchedLocation == '/';

      if (!isLoggedIn && !isLoggingIn) {
        return '/';
      }

      if (isLoggedIn && isLoggingIn) {
        return '/dashboard';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const WelcomeScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/forgot-password',
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: '/signup',
        builder: (context, state) => const SignupScreen(),
      ),
      GoRoute(
        path: '/business-setup',
        builder: (context, state) => const BusinessSetupScreen(),
      ),
      GoRoute(
        path: '/dashboard',
        builder: (context, state) => const DashboardScreen(),
      ),
      GoRoute(
        path: '/customers',
        builder: (context, state) => const CustomerListScreen(),
      ),
      GoRoute(
        path: '/add-customer',
        builder: (context, state) => const AddEditCustomerScreen(),
      ),
      GoRoute(
        path: '/edit-customer/:id',
        builder: (context, state) {
          final id = state.pathParameters['id'];
          return AddEditCustomerScreen(customerId: id);
        },
      ),
      GoRoute(
        path: '/items',
        builder: (context, state) => const ItemListScreen(),
      ),
      GoRoute(
        path: '/add-item',
        builder: (context, state) => const AddEditItemScreen(),
      ),
      GoRoute(
        path: '/edit-item/:id',
        builder: (context, state) {
          final id = state.pathParameters['id'];
          return AddEditItemScreen(itemId: id);
        },
      ),
      GoRoute(
        path: '/invoices',
        builder: (context, state) => const InvoiceListScreen(),
      ),
      GoRoute(
        path: '/create-invoice',
        builder: (context, state) => const CreateInvoiceScreen(),
      ),
      GoRoute(
        path: '/invoice-detail/:id',
        builder: (context, state) {
          final id = state.pathParameters['id'];
          return InvoiceDetailScreen(invoiceId: id);
        },
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: '/notifications',
        builder: (context, state) => const NotificationsScreen(),
      ),
      GoRoute(
        path: '/profile',
        builder: (context, state) => const ProfileScreen(),
      ),
    ],
  );
});

class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen(
      (dynamic _) => notifyListeners(),
    );
  }

  late final dynamic _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
