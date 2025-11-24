import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'common/theme/app_theme.dart';
import 'common/routing/app_router.dart';
import 'core/providers.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: "AIzaSyC9AolU23PH-rpCwzALgTZSzoiD4TZ9MeM",
      appId: "1:141398138140:web:1f9a5e204c5c91de8e6ed9",
      messagingSenderId: "141398138140",
      projectId: "clothing-caisse-manager",
      storageBucket: "clothing-caisse-manager.firebasestorage.app",
    ),
  );

  runApp(const ProviderScope(child: ClothingCaisseApp()));
}

class ClothingCaisseApp extends ConsumerWidget {
  const ClothingCaisseApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp.router(
      title: 'Gestion de Caisse',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme(),
      darkTheme: AppTheme.darkTheme(),
      themeMode: themeMode,
      routerConfig: router,
    );
  }
}
