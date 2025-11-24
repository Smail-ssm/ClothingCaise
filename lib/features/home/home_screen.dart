import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/providers.dart';
import '../../common/widgets/stats_card.dart';
import '../../common/theme/app_theme.dart';
import '../../core/models/user.dart' as app_models;
import '../../core/utils/platform_utils.dart';
import '../../common/l10n/app_fr.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(currentUserProvider);
    final productsCount = ref.watch(productsCountProvider);
    final lowStockCount = ref.watch(lowStockCountProvider);
    final activeCashSession = ref.watch(activeCashSessionProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          PlatformUtils.isPOSTerminal
              ? AppLocalizations.posTerminal
              : AppLocalizations.home,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await ref.read(authRepositoryProvider).signOut();
            },
          ),
        ],
      ),
      drawer: _buildDrawer(context, currentUser.value),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Section
            currentUser.when(
              data: (user) => user != null
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${AppLocalizations.welcome},',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(color: Colors.grey.shade600),
                        ),
                        Text(
                          user.name,
                          style: Theme.of(context).textTheme.displayMedium,
                        ),
                      ],
                    )
                  : const SizedBox.shrink(),
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
            ),
            const SizedBox(height: 32),

            // Stats Section
            Text(
              AppLocalizations.quickStats,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 16),

            // Stats Grid
            LayoutBuilder(
              builder: (context, constraints) {
                final cardWidth = constraints.maxWidth > 900
                    ? (constraints.maxWidth - 32) / 3
                    : constraints.maxWidth > 600
                    ? (constraints.maxWidth - 16) / 2
                    : constraints.maxWidth;

                return Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  children: [
                    // Only show product stats on mobile
                    if (!PlatformUtils.isPOSTerminal)
                      SizedBox(
                        width: cardWidth,
                        child: productsCount.when(
                          data: (count) => StatsCard(
                            title: AppLocalizations.totalProducts,
                            value: count.toString(),
                            icon: Icons.inventory_2_outlined,
                            color: AppTheme.primaryColor,
                            onTap: () => context.push('/products'),
                          ),
                          loading: () => const Card(
                            child: Center(
                              child: Padding(
                                padding: EdgeInsets.all(40.0),
                                child: CircularProgressIndicator(),
                              ),
                            ),
                          ),
                          error: (_, __) => const Card(
                            child: Center(
                              child: Padding(
                                padding: EdgeInsets.all(40.0),
                                child: Icon(Icons.error_outline),
                              ),
                            ),
                          ),
                        ),
                      ),
                    // Only show stock stats on mobile
                    if (!PlatformUtils.isPOSTerminal)
                      SizedBox(
                        width: cardWidth,
                        child: lowStockCount.when(
                          data: (count) => StatsCard(
                            title: AppLocalizations.lowStockItems,
                            value: count.toString(),
                            icon: Icons.warning_amber_outlined,
                            color: AppTheme.warningColor,
                            onTap: () => context.push('/variants'),
                          ),
                          loading: () => const Card(
                            child: Center(
                              child: Padding(
                                padding: EdgeInsets.all(40.0),
                                child: CircularProgressIndicator(),
                              ),
                            ),
                          ),
                          error: (_, __) => const Card(
                            child: Center(
                              child: Padding(
                                padding: EdgeInsets.all(40.0),
                                child: Icon(Icons.error_outline),
                              ),
                            ),
                          ),
                        ),
                      ),
                    // Cash session stats - show on all platforms
                    SizedBox(
                      width: cardWidth,
                      child: activeCashSession.when(
                        data: (session) => StatsCard(
                          title: AppLocalizations.expectedClosingCash,
                          value: session != null
                              ? '\$${session.expectedClosingCash.toStringAsFixed(2)}'
                              : AppLocalizations.noSession,
                          icon: Icons.attach_money_outlined,
                          color: AppTheme.accentColor,
                          onTap: () => context.push('/cash'),
                        ),
                        loading: () => const Card(
                          child: Center(
                            child: Padding(
                              padding: EdgeInsets.all(40.0),
                              child: CircularProgressIndicator(),
                            ),
                          ),
                        ),
                        error: (_, __) => const Card(
                          child: Center(
                            child: Padding(
                              padding: EdgeInsets.all(40.0),
                              child: Icon(Icons.error_outline),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 32),

            // Quick Actions
            Text(
              AppLocalizations.quickActions,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 16),
            currentUser.when(
              data: (user) => _buildQuickActions(context, user),
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawer(BuildContext context, dynamic user) {
    // On Windows (POS Terminal), limit to POS features only
    final bool isPOSMode = PlatformUtils.isPOSTerminal;

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const Icon(Icons.storefront, size: 48, color: Colors.white),
                const SizedBox(height: 16),
                Text(
                  isPOSMode
                      ? AppLocalizations.posTerminal
                      : AppLocalizations.appTitle,
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(color: Colors.white),
                ),
                if (isPOSMode)
                  const Text(
                    'Windows',
                    style: TextStyle(color: Colors.white70),
                  ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home_outlined),
            title: Text(AppLocalizations.home),
            onTap: () {
              Navigator.pop(context);
              context.go('/');
            },
          ),

          // === POS MODE (Windows): Only Sales & Cash ===
          if (isPOSMode) ...[
            // Sales (POS)
            ListTile(
              leading: const Icon(Icons.point_of_sale_outlined),
              title: Text(AppLocalizations.salesPOS),
              onTap: () {
                Navigator.pop(context);
                context.push('/sales');
              },
            ),
            // Cash Session
            ListTile(
              leading: const Icon(Icons.attach_money_outlined),
              title: Text(AppLocalizations.cashSession),
              onTap: () {
                Navigator.pop(context);
                context.push('/cash');
              },
            ),
          ],

          // === FULL MODE (Mobile): All features visible to all users ===
          // TODO: Implement proper role-based guards at the route/repository level
          // Currently showing all UIs to all users for easier development
          if (!isPOSMode) ...[
            // Products - Visible to all
            ListTile(
              leading: const Icon(Icons.inventory_2_outlined),
              title: Text(AppLocalizations.products),
              onTap: () {
                Navigator.pop(context);
                context.push('/products');
              },
            ),
            // Variants - Visible to all
            ListTile(
              leading: const Icon(Icons.shopping_bag_outlined),
              title: Text(AppLocalizations.variants),
              onTap: () {
                Navigator.pop(context);
                context.push('/variants');
              },
            ),
            // Stock - Visible to all
            ListTile(
              leading: const Icon(Icons.inventory_outlined),
              title: Text(AppLocalizations.stock),
              onTap: () {
                Navigator.pop(context);
                context.push('/stock');
              },
            ),
            // Sales (POS) - Visible to all
            ListTile(
              leading: const Icon(Icons.point_of_sale_outlined),
              title: Text(AppLocalizations.salesPOS),
              onTap: () {
                Navigator.pop(context);
                context.push('/sales');
              },
            ),
            // Cash Session - Visible to all
            ListTile(
              leading: const Icon(Icons.attach_money_outlined),
              title: Text(AppLocalizations.cashSession),
              onTap: () {
                Navigator.pop(context);
                context.push('/cash');
              },
            ),
            // Users - Visible to all
            ListTile(
              leading: const Icon(Icons.people_outline),
              title: Text(AppLocalizations.users),
              onTap: () {
                Navigator.pop(context);
                context.push('/users');
              },
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context, dynamic user) {
    // On Windows (POS Terminal), only show sales
    final bool isPOSMode = PlatformUtils.isPOSTerminal;

    List<Widget> actions = [];

    if (isPOSMode) {
      // POS Mode: Only sales
      actions.add(
        _QuickActionButton(
          icon: Icons.point_of_sale_outlined,
          label: AppLocalizations.newSale,
          color: AppTheme.accentColor,
          onTap: () => context.push('/sales'),
        ),
      );
    } else {
      // Full Mode: All users see all quick actions
      actions.add(
        _QuickActionButton(
          icon: Icons.inventory_2_outlined,
          label: AppLocalizations.products,
          color: AppTheme.secondaryColor,
          onTap: () => context.push('/products'),
        ),
      );
      actions.add(
        _QuickActionButton(
          icon: Icons.shopping_bag_outlined,
          label: AppLocalizations.variants,
          color: AppTheme.accentColor,
          onTap: () => context.push('/variants'),
        ),
      );
      actions.add(
        _QuickActionButton(
          icon: Icons.inventory_outlined,
          label: AppLocalizations.stock,
          color: AppTheme.primaryColor,
          onTap: () => context.push('/stock'),
        ),
      );
      actions.add(
        _QuickActionButton(
          icon: Icons.people_outline,
          label: AppLocalizations.users,
          color: AppTheme.secondaryColor,
          onTap: () => context.push('/users'),
        ),
      );
      actions.add(
        _QuickActionButton(
          icon: Icons.point_of_sale_outlined,
          label: AppLocalizations.newSale,
          color: AppTheme.accentColor,
          onTap: () => context.push('/sales'),
        ),
      );
      actions.add(
        _QuickActionButton(
          icon: Icons.attach_money_outlined,
          label: AppLocalizations.cashSession,
          color: AppTheme.primaryColor,
          onTap: () => context.push('/cash'),
        ),
      );
    }

    return Wrap(spacing: 16, runSpacing: 16, children: actions);
  }
}

class _QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 160,
      height: 120,
      child: Card(
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 40, color: color),
                const SizedBox(height: 12),
                Text(
                  label,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
