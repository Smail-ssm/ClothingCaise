import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/product_variant.dart';
import '../../../core/providers.dart';

class VariantSelectionDialog extends ConsumerStatefulWidget {
  const VariantSelectionDialog({super.key});

  @override
  ConsumerState<VariantSelectionDialog> createState() =>
      _VariantSelectionDialogState();
}

class _VariantSelectionDialogState
    extends ConsumerState<VariantSelectionDialog> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final variantsStream = ref.watch(variantRepositoryProvider).getVariants();

    return Dialog(
      child: Container(
        width: double.maxFinite,
        constraints: const BoxConstraints(maxWidth: 600, maxHeight: 600),
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              'Select Product Variant',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            TextField(
              decoration: const InputDecoration(
                labelText: 'Search by name, size or color',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.toLowerCase();
                });
              },
            ),
            const SizedBox(height: 16),
            Expanded(
              child: StreamBuilder<List<ProductVariant>>(
                stream: variantsStream,
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }

                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final variants = snapshot.data!.where((variant) {
                    final searchLower = _searchQuery.toLowerCase();
                    return variant.productName.toLowerCase().contains(
                          searchLower,
                        ) ||
                        variant.size.toLowerCase().contains(searchLower) ||
                        variant.color.toLowerCase().contains(searchLower) ||
                        (variant.barcode?.contains(searchLower) ?? false);
                  }).toList();

                  if (variants.isEmpty) {
                    return const Center(child: Text('No variants found'));
                  }

                  return ListView.separated(
                    itemCount: variants.length,
                    separatorBuilder: (_, __) => const Divider(),
                    itemBuilder: (context, index) {
                      final variant = variants[index];
                      return ListTile(
                        title: Text(variant.productName),
                        subtitle: Text(
                          '${variant.size} • ${variant.color} • Stock: ${variant.currentStock}',
                        ),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => Navigator.pop(context, variant),
                      );
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
          ],
        ),
      ),
    );
  }
}
