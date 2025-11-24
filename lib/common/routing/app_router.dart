import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers.dart';
import '../../features/auth/login_screen.dart';
import '../../features/home/home_screen.dart';
import '../../features/products/products_screen.dart';
import '../../features/products/product_form_screen.dart';
import '../../features/variants/variants_screen.dart';
import '../../features/variants/variant_form_screen.dart';
import '../../features/stock/stock_screen.dart';
import '../../features/sales/sales_screen.dart';
import '../../features/cash/cash_session_screen.dart';
import '../../features/admin/user_management_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: '/login',
    redirect: (context, state) {
      final firebaseUser = authState.value;
      final localUser = ref.watch(localUserProvider);
      final isLoggedIn = firebaseUser != null || localUser != null;
      final isLoggingIn = state.matchedLocation == '/login';

      if (!isLoggedIn && !isLoggingIn) {
        return '/login';
      }

      if (isLoggedIn && isLoggingIn) {
        return '/';
      }

      return null;
    },
    routes: [
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(path: '/', builder: (context, state) => const HomeScreen()),
      GoRoute(
        path: '/products',
        builder: (context, state) => const ProductsScreen(),
      ),
      GoRoute(
        path: '/products/add',
        builder: (context, state) => const ProductFormScreen(),
      ),
      GoRoute(
        path: '/products/edit/:id',
        builder: (context, state) =>
            ProductFormScreen(productId: state.pathParameters['id']),
      ),
      GoRoute(
        path: '/variants',
        builder: (context, state) => const VariantsScreen(),
      ),
      GoRoute(
        path: '/variants/add',
        builder: (context, state) => const VariantFormScreen(),
      ),
      GoRoute(
        path: '/variants/edit/:id',
        builder: (context, state) =>
            VariantFormScreen(variantId: state.pathParameters['id']),
      ),
      GoRoute(path: '/stock', builder: (context, state) => const StockScreen()),
      GoRoute(path: '/sales', builder: (context, state) => const SalesScreen()),
      GoRoute(
        path: '/cash',
        builder: (context, state) => const CashSessionScreen(),
      ),
      GoRoute(
        path: '/users',
        builder: (context, state) => const UserManagementScreen(),
      ),
    ],
  );
});
