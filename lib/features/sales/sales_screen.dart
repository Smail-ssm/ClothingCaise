import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/models/sale.dart';
import '../../core/models/product_variant.dart';
import '../../core/providers.dart';
import '../../core/utils/format_utils.dart';
import 'widgets/product_search_list.dart';

class SalesScreen extends ConsumerStatefulWidget {
  const SalesScreen({super.key});

  @override
  ConsumerState<SalesScreen> createState() => _SalesScreenState();
}

class _SalesScreenState extends ConsumerState<SalesScreen> {
  final _barcodeController = TextEditingController();
  final List<_CartItem> _cart = [];
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();
  PaymentType _paymentType = PaymentType.CASH;

  Future<void> _searchAndAddToCart() async {
    final barcode = _barcodeController.text.trim();
    if (barcode.isEmpty) return;

    try {
      final variant = await ref
          .read(variantRepositoryProvider)
          .getVariantByBarcode(barcode);

      if (variant != null) {
        _addToCart(variant);
        _barcodeController.clear();
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Product not found'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _addToCart(ProductVariant variant) {
    setState(() {
      final existingIndex = _cart.indexWhere(
        (item) => item.variant.id == variant.id,
      );

      if (existingIndex >= 0) {
        _cart[existingIndex].quantity++;
      } else {
        final newItem = _CartItem(variant: variant, quantity: 1);
        _cart.insert(0, newItem);
        _listKey.currentState?.insertItem(
          0,
          duration: const Duration(milliseconds: 300),
        );
      }
    });
  }

  void _removeFromCart(int index) {
    final item = _cart[index];
    _cart.removeAt(index);
    _listKey.currentState?.removeItem(
      index,
      (context, animation) => _buildCartItem(item, index, animation),
      duration: const Duration(milliseconds: 300),
    );
  }

  double get _total {
    return _cart.fold(
      0,
      (sum, item) => sum + (item.variant.sellingPrice * item.quantity),
    );
  }

  Future<void> _completeSale() async {
    if (_cart.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cart is empty'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    try {
      final currentUser = await ref.read(currentUserProvider.future);
      if (currentUser == null) throw Exception('User not found');

      String? cashSessionId;
      if (_paymentType == PaymentType.CASH) {
        final session = await ref.read(activeCashSessionProvider.future);
        if (session == null) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Please open a cash session first'),
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
          return;
        }
        cashSessionId = session.id;
      }

      final sale = Sale(
        id: '',
        date: DateTime.now(),
        totalAmount: _total,
        paymentType: _paymentType,
        userId: currentUser.id,
        cashSessionId: cashSessionId,
        lines: _cart
            .map(
              (item) => SaleLine(
                variantId: item.variant.id,
                productId: item.variant.productId,
                productName: item.variant.productName,
                size: item.variant.size,
                color: item.variant.color,
                quantity: item.quantity,
                unitPrice: item.variant.sellingPrice,
                totalLine: item.variant.sellingPrice * item.quantity,
              ),
            )
            .toList(),
      );

      await ref.read(saleRepositoryProvider).createSale(sale, currentUser.id);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Sale completed successfully'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
        setState(() {
          _cart.clear();
          // Reset the animated list by rebuilding
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Point of Sale'),
        actions: [
          if (_cart.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    '${_cart.length} items',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _barcodeController,
                        decoration: const InputDecoration(
                          labelText: 'Scan or enter barcode',
                          prefixIcon: Icon(Icons.qr_code_scanner),
                        ),
                        onSubmitted: (_) => _searchAndAddToCart(),
                        autofocus: true,
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: _searchAndAddToCart,
                      child: const Text('Add'),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ExpansionTile(
                  title: const Text('Search Products'),
                  leading: const Icon(Icons.search),
                  children: [
                    ProductSearchList(
                      onVariantSelected: (variant) {
                        _addToCart(variant);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Added ${variant.productName}'),
                            duration: const Duration(seconds: 1),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Cart Items
          Expanded(
            child: _cart.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.shopping_cart_outlined,
                          size: 64,
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withOpacity(0.3),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Cart is empty',
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurface.withOpacity(0.5),
                              ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Scan a barcode or search for products',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurface.withOpacity(0.5),
                              ),
                        ),
                      ],
                    ),
                  )
                : AnimatedList(
                    key: _listKey,
                    initialItemCount: _cart.length,
                    itemBuilder: (context, index, animation) {
                      if (index >= _cart.length) return const SizedBox.shrink();
                      return _buildCartItem(_cart[index], index, animation);
                    },
                  ),
          ),

          // Total and Checkout
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    Text(
                      FormatUtils.formatCurrency(_total),
                      style: Theme.of(context).textTheme.displaySmall?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<PaymentType>(
                  value: _paymentType,
                  decoration: const InputDecoration(labelText: 'Payment Type'),
                  items: PaymentType.values
                      .map(
                        (type) => DropdownMenuItem(
                          value: type,
                          child: Text(type.toString().split('.').last),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    setState(() => _paymentType = value!);
                  },
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _cart.isEmpty ? null : _completeSale,
                    child: const Text('Complete Sale'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCartItem(
    _CartItem item,
    int index,
    Animation<double> animation,
  ) {
    return SizeTransition(
      sizeFactor: animation,
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              // Product Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.variant.productName,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${item.variant.size} • ${item.variant.color}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),

              // Quantity Controls
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.remove_circle_outline),
                    onPressed: () {
                      setState(() {
                        if (item.quantity > 1) {
                          item.quantity--;
                        } else {
                          _removeFromCart(index);
                        }
                      });
                    },
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${item.quantity}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add_circle_outline),
                    onPressed: () {
                      setState(() => item.quantity++);
                    },
                  ),
                ],
              ),

              // Price
              const SizedBox(width: 8),
              SizedBox(
                width: 80,
                child: Text(
                  FormatUtils.formatCurrency(
                    item.variant.sellingPrice * item.quantity,
                  ),
                  textAlign: TextAlign.right,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _barcodeController.dispose();
    super.dispose();
  }
}

class _CartItem {
  final ProductVariant variant;
  int quantity;

  _CartItem({required this.variant, required this.quantity});
}
