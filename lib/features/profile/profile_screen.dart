import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers.dart';
import 'package:go_router/go_router.dart';
import '../../common/l10n/app_fr.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(currentUserProvider);
    final currentTheme = ref.watch(themeModeProvider);

    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.myProfile)),
      body: userAsync.when(
        data: (user) {
          if (user == null) {
            return Center(child: Text(AppLocalizations.noUserLoggedIn));
          }

          // TODO: Implement proper role-based guards at the route/repository level
          // Currently showing all UIs to all users for easier development

          // All features visible to all users
          List<Widget> actions = [
            _buildActionCard(
              context: context,
              icon: Icons.supervisor_account,
              label: AppLocalizations.userManagement,
              onTap: () => context.go('/users'),
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 12),
            _buildActionCard(
              context: context,
              icon: Icons.inventory,
              label: AppLocalizations.products,
              onTap: () => context.go('/products'),
              color: Theme.of(context).colorScheme.secondary,
            ),
            const SizedBox(height: 12),
            _buildActionCard(
              context: context,
              icon: Icons.shopping_bag_outlined,
              label: AppLocalizations.variants,
              onTap: () => context.go('/variants'),
              color: Theme.of(context).colorScheme.tertiary,
            ),
            const SizedBox(height: 12),
            _buildActionCard(
              context: context,
              icon: Icons.inventory_outlined,
              label: AppLocalizations.stockManagement,
              onTap: () => context.go('/stock'),
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 12),
            _buildActionCard(
              context: context,
              icon: Icons.point_of_sale,
              label: AppLocalizations.salesPOS,
              onTap: () => context.go('/sales'),
              color: Theme.of(context).colorScheme.secondary,
            ),
            const SizedBox(height: 12),
            _buildActionCard(
              context: context,
              icon: Icons.attach_money,
              label: AppLocalizations.cashSession,
              onTap: () => context.go('/cash'),
              color: Theme.of(context).colorScheme.tertiary,
            ),
          ];

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Profile Header Card
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundColor: Theme.of(
                            context,
                          ).colorScheme.primary.withOpacity(0.1),
                          child: Text(
                            user.name[0].toUpperCase(),
                            style: TextStyle(
                              fontSize: 48,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          user.name,
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          user.email,
                          style: Theme.of(context).textTheme.bodyLarge
                              ?.copyWith(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurface.withOpacity(0.7),
                              ),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Theme.of(
                              context,
                            ).colorScheme.primaryContainer,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            user.role.name.toUpperCase(),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(
                                context,
                              ).colorScheme.onPrimaryContainer,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Theme Selection Card
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.palette_outlined,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              AppLocalizations.appearance,
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: _buildThemeOption(
                                context: context,
                                ref: ref,
                                icon: Icons.light_mode,
                                label: AppLocalizations.light,
                                mode: ThemeMode.light,
                                isSelected: currentTheme == ThemeMode.light,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildThemeOption(
                                context: context,
                                ref: ref,
                                icon: Icons.dark_mode,
                                label: AppLocalizations.dark,
                                mode: ThemeMode.dark,
                                isSelected: currentTheme == ThemeMode.dark,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildThemeOption(
                                context: context,
                                ref: ref,
                                icon: Icons.settings_brightness,
                                label: AppLocalizations.system,
                                mode: ThemeMode.system,
                                isSelected: currentTheme == ThemeMode.system,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Quick Actions
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppLocalizations.quickActions,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 16),
                        ...actions,
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Sign Out Button
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      await ref.read(authRepositoryProvider).signOut();
                      // Clear local user
                      ref.invalidate(localUserProvider);
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: BorderSide(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                    icon: const Icon(Icons.logout),
                    label: Text(AppLocalizations.signOut),
                  ),
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => Center(child: Text(AppLocalizations.error)),
      ),
    );
  }

  Widget _buildThemeOption({
    required BuildContext context,
    required WidgetRef ref,
    required IconData icon,
    required String label,
    required ThemeMode mode,
    required bool isSelected,
  }) {
    return Material(
      color: isSelected
          ? Theme.of(context).colorScheme.primaryContainer
          : Theme.of(context).colorScheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: () {
          ref.read(themeModeProvider.notifier).setThemeMode(mode);
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 32,
                color: isSelected
                    ? Theme.of(context).colorScheme.onPrimaryContainer
                    : Theme.of(context).colorScheme.onSurface,
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected
                      ? Theme.of(context).colorScheme.onPrimaryContainer
                      : Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionCard({
    required BuildContext context,
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required Color color,
  }) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  label,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}
