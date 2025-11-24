import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/providers.dart';
import '../../common/widgets/common_widgets.dart';

class VariantsScreen extends ConsumerWidget {
  const VariantsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final variantsAsync = ref.watch(variantsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Product Variants')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/variants/add'),
        icon: const Icon(Icons.add),
        label: const Text('Add Variant'),
      ),
      body: variantsAsync.when(
        data: (variants) {
          if (variants.isEmpty) {
            return EmptyStateWidget(
              title: 'No Variants',
              message: 'Add product variants with size and color',
              icon: Icons.shopping_bag_outlined,
              actionLabel: 'Add Variant',
              onAction: () => context.push('/variants/add'),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: variants.length,
            itemBuilder: (context, index) {
              final variant = variants[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: variant.isLowStock
                        ? Colors.orange.shade100
                        : Colors.green.shade100,
                    child: Icon(
                      variant.isLowStock ? Icons.warning_amber : Icons.check,
                      color: variant.isLowStock ? Colors.orange : Colors.green,
                    ),
                  ),
                  title: Text(variant.productName),
                  subtitle: Text(
                    '${variant.size} • ${variant.color} • Stock: ${variant.currentStock}',
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '\$${variant.sellingPrice.toStringAsFixed(2)}',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(Icons.edit_outlined),
                        onPressed: () =>
                            context.push('/variants/edit/${variant.id}'),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
        loading: () => const LoadingWidget(message: 'Loading variants...'),
        error: (error, _) => AppErrorWidget(message: error.toString()),
      ),
    );
  }
}
