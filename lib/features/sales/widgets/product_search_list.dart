import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/product_variant.dart';
import '../../../core/providers.dart';

class ProductSearchList extends ConsumerStatefulWidget {
  final Function(ProductVariant) onVariantSelected;

  const ProductSearchList({super.key, required this.onVariantSelected});

  @override
  ConsumerState<ProductSearchList> createState() => _ProductSearchListState();
}

class _ProductSearchListState extends ConsumerState<ProductSearchList> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final variantsAsync = ref.watch(variantsProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Column(
        children: [
          TextField(
            controller: _searchController,
            decoration: const InputDecoration(
              labelText: 'Search by name or category',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            onChanged: (value) {
              setState(() {
                _searchQuery = value.toLowerCase();
              });
            },
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 300, // Limit height for the list
            child: variantsAsync.when(
              data: (variants) {
                final filteredVariants = variants.where((variant) {
                  if (_searchQuery.isEmpty) return true;

                  // We might not have category directly on variant, but we have productName.
                  // Ideally we'd join with Product, but for now let's search what we have.
                  // If we need category, we might need to fetch products or update variant model.
                  // Assuming variant.productName contains the name.

                  return variant.productName.toLowerCase().contains(
                        _searchQuery,
                      ) ||
                      variant.size.toLowerCase().contains(_searchQuery) ||
                      variant.color.toLowerCase().contains(_searchQuery);
                }).toList();

                if (filteredVariants.isEmpty) {
                  return const Center(child: Text('No products found'));
                }

                return ListView.builder(
                  itemCount: filteredVariants.length,
                  itemBuilder: (context, index) {
                    final variant = filteredVariants[index];
                    return ListTile(
                      title: Text(variant.productName),
                      subtitle: Text('${variant.size} • ${variant.color}'),
                      trailing: Text(
                        '\$${variant.sellingPrice.toStringAsFixed(2)}',
                      ),
                      onTap: () => widget.onVariantSelected(variant),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(child: Text('Error: $err')),
            ),
          ),
        ],
      ),
    );
  }
}
