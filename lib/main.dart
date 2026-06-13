import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/foundation.dart';
import 'package:easy_localization/easy_localization.dart';

import 'core/theme/app_theme.dart';
import 'core/routing/app_router.dart';
import 'core/services/location_service.dart';
import 'core/services/notification_service.dart';
import 'core/services/offline_service.dart';
import 'core/providers/auth_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Easy Localization
  await EasyLocalization.ensureInitialized();

  // Initialize Firebase (skip strict requirement on web if options are missing)
  try {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: "AIzaSyAubuQbjmN4ZvdsFL6f2fYLMC3fGXEdco0",
        authDomain: "backend-c8c99.firebaseapp.com",
        projectId: "backend-c8c99",
        storageBucket: "backend-c8c99.firebasestorage.app",
        messagingSenderId: "75541301332",
        appId: "1:75541301332:android:a66afeada4ed06108b45c1",
        measurementId: "G-8KVP5C6YME",
      ),
    );
  } catch (e) {
    // On web or missing FirebaseOptions, allow app to continue for non-Firebase flows
    print('Firebase initialization failed: $e');
  }

  // Initialize Hive for local storage
  await Hive.initFlutter();

  // Request permissions (skip on web)
  await _requestPermissions();

  // Initialize services
  await LocationService.initialize();
  if (!kIsWeb) {
    await NotificationService.initialize();
  }
  await OfflineService.initialize();

  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('en'), Locale('hi'), Locale('te')],
      path: 'assets/translations',
      fallbackLocale: const Locale('en'),
      child: const ProviderScope(child: OceanHazardApp()),
    ),
  );
}

Future<void> _requestPermissions() async {
  if (kIsWeb) return;
  await [
    Permission.location,
    Permission.camera,
    Permission.microphone,
    Permission.storage,
    Permission.notification,
  ].request();
}

class OceanHazardApp extends ConsumerWidget {
  const OceanHazardApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Start auth token sync listener
    ref.watch(authTokenSyncProvider);

    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      title: 'app_title'.tr(),
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
    );
  }
}
