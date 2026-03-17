import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';
import 'package:smart_invoice_pro/core/router/app_router.dart';
import 'package:smart_invoice_pro/core/theme/app_theme.dart';
import 'package:smart_invoice_pro/core/theme/theme_provider.dart';
import 'package:overlay_support/overlay_support.dart';

import 'package:smart_invoice_pro/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase with platform-specific options
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  if (kIsWeb) {
    // Initialize database factory for Web
    databaseFactory = createDatabaseFactoryFfiWeb(
      options: SqfliteFfiWebOptions(
        sqlite3WasmUri: Uri.parse('sqlite3.wasm'),
      ),
    );
  } else if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }
  runApp(const ProviderScope(child: SmartInvoiceApp()));
}

class SmartInvoiceApp extends ConsumerWidget {
  const SmartInvoiceApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);
    final router = ref.watch(appRouterProvider);

    return OverlaySupport.global(
      child: MaterialApp.router(
        title: 'SmartInvoice Pro',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: themeMode,
        routerConfig: router,
      ),
    );
  }
}
