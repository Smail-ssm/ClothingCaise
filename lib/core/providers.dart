import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'repositories/auth_repository.dart';
import 'repositories/product_repository.dart';
import 'repositories/variant_repository.dart';
import 'repositories/stock_repository.dart';
import 'repositories/sale_repository.dart';
import 'repositories/cash_session_repository.dart';
import 'repositories/user_repository.dart';
import 'repositories/login_token_repository.dart';
import 'services/printing_service.dart';
import 'services/cash_drawer_service.dart';
import 'services/theme_service.dart';
import 'models/user.dart' as app_models;
import 'models/cash_session.dart';
import 'package:flutter/material.dart';

// ============== Repository Providers ==============

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository();
});

final productRepositoryProvider = Provider<ProductRepository>((ref) {
  return ProductRepository();
});

final variantRepositoryProvider = Provider<VariantRepository>((ref) {
  return VariantRepository();
});

final stockRepositoryProvider = Provider<StockRepository>((ref) {
  return StockRepository();
});

final saleRepositoryProvider = Provider<SaleRepository>((ref) {
  return SaleRepository();
});

final cashSessionRepositoryProvider = Provider<CashSessionRepository>((ref) {
  return CashSessionRepository();
});

final userRepositoryProvider = Provider<UserRepository>((ref) {
  return UserRepository();
});

final loginTokenRepositoryProvider = Provider<LoginTokenRepository>((ref) {
  return LoginTokenRepository();
});

// ============== Service Providers ==============

final printingServiceProvider = Provider<PrintingService>((ref) {
  return PrintingService();
});

final cashDrawerServiceProvider = Provider<CashDrawerService>((ref) {
  return CashDrawerService();
});

final themeServiceProvider = Provider<ThemeService>((ref) {
  return ThemeService();
});

// Theme Mode State Provider
final themeModeProvider = StateNotifierProvider<ThemeModeNotifier, ThemeMode>((
  ref,
) {
  return ThemeModeNotifier(ref.watch(themeServiceProvider));
});

class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  final ThemeService _themeService;

  ThemeModeNotifier(this._themeService) : super(ThemeMode.system) {
    _loadThemeMode();
  }

  Future<void> _loadThemeMode() async {
    state = await _themeService.getThemeMode();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    state = mode;
    await _themeService.setThemeMode(mode);
  }
}

// ============== Auth State Providers ==============

final authStateProvider = StreamProvider<User?>((ref) {
  final authRepo = ref.watch(authRepositoryProvider);
  return authRepo.authStateChanges;
});

// We need a way to store the locally authenticated user since we can't rely solely on Firebase Auth state
final localUserProvider = StateProvider<app_models.AppUser?>((ref) => null);

final currentUserProvider = FutureProvider<app_models.AppUser?>((ref) async {
  // Check local user first (set via signIn)
  final localUser = ref.watch(localUserProvider);
  if (localUser != null) return localUser;

  // Fallback to Firebase Auth state
  final authState = ref.watch(authStateProvider);

  return authState.when(
    data: (user) async {
      if (user == null) return null;
      final authRepo = ref.watch(authRepositoryProvider);
      return await authRepo.getUserData(user.uid);
    },
    loading: () => null,
    error: (_, __) => null,
  );
});

// ============== Data Stream Providers ==============

final productsProvider = StreamProvider((ref) {
  final repo = ref.watch(productRepositoryProvider);
  return repo.getProducts();
});

final variantsProvider = StreamProvider((ref) {
  final repo = ref.watch(variantRepositoryProvider);
  return repo.getVariants();
});

final lowStockVariantsProvider = StreamProvider((ref) {
  final repo = ref.watch(variantRepositoryProvider);
  return repo.getLowStockVariants();
});

final recentSalesProvider = StreamProvider((ref) {
  final repo = ref.watch(saleRepositoryProvider);
  return repo.getSales(limit: 50);
});

final activeCashSessionProvider = FutureProvider<CashSession?>((ref) async {
  final user = await ref.watch(currentUserProvider.future);
  if (user == null) return null;

  final repo = ref.watch(cashSessionRepositoryProvider);
  return await repo.getActiveSession(user.id);
});

// ============== Stats Providers ==============

final productsCountProvider = FutureProvider<int>((ref) async {
  final repo = ref.watch(productRepositoryProvider);
  return await repo.getProductsCount();
});

final lowStockCountProvider = FutureProvider<int>((ref) async {
  final repo = ref.watch(variantRepositoryProvider);
  return await repo.getLowStockCount();
});

final productStockMapProvider = Provider<Map<String, int>>((ref) {
  final variantsAsync = ref.watch(variantsProvider);

  return variantsAsync.when(
    data: (variants) {
      final stockMap = <String, int>{};
      for (final variant in variants) {
        stockMap[variant.productId] =
            (stockMap[variant.productId] ?? 0) + variant.currentStock;
      }
      return stockMap;
    },
    loading: () => {},
    error: (_, __) => {},
  );
});
