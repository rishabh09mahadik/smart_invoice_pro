import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:smart_invoice_pro/core/theme/app_theme.dart';
import 'package:smart_invoice_pro/core/widgets/common_widgets.dart';
import 'package:smart_invoice_pro/core/theme/theme_provider.dart';
import 'package:smart_invoice_pro/features/auth/presentation/providers/auth_provider.dart';
import 'package:smart_invoice_pro/core/services/notification_service.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _notificationsEnabled = true;

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeProvider);
    final isDarkMode = themeMode == ThemeMode.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SectionHeader(title: 'Appearance'),
            const SizedBox(height: 16),
            Card(
              child: SwitchListTile(
                title: const Text('Dark Mode'),
                subtitle: const Text('Enable dark theme'),
                value: isDarkMode,
                activeColor: AppTheme.primaryColor,
                onChanged: (value) {
                  ref.read(themeProvider.notifier).toggleTheme(value);
                },
                secondary: const Icon(Icons.dark_mode_outlined),
              ),
            ),
            const SizedBox(height: 24),
            SectionHeader(title: 'Notifications'),
            const SizedBox(height: 16),
            Card(
              child: SwitchListTile(
                title: const Text('Enable Notifications'),
                subtitle: const Text('Receive updates about invoices'),
                value: _notificationsEnabled,
                activeColor: AppTheme.primaryColor,
                onChanged: (value) {
                  setState(() {
                    _notificationsEnabled = value;
                  });
                },
                secondary: const Icon(Icons.notifications_outlined),
              ),
            ),
            const SizedBox(height: 24),
            SectionHeader(title: 'Account'),
            const SizedBox(height: 16),
            Card(
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.person_outline),
                    title: const Text('Edit Profile'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      context.push('/profile');
                    },
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.business_outlined),
                    title: const Text('Business Details'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      context.push('/business-setup');
                    },
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.logout, color: Colors.red),
                    title: const Text('Log Out', style: TextStyle(color: Colors.red)),
                    onTap: () {
                      ref.read(authProvider.notifier).logout();
                      // Navigation is handled by AppRouter redirect
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Center(
              child: Text(
                'Version 1.0.0',
                style: TextStyle(color: Colors.grey.shade500),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
