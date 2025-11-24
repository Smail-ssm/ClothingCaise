import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/models/stock_movement.dart';
import '../../core/models/product_variant.dart';
import '../../core/providers.dart';
// ignore: unused_import
import '../../core/utils/validators.dart';
import '../../common/widgets/barcode_scanner_view.dart';
import 'widgets/variant_selection_dialog.dart';

class StockScreen extends ConsumerStatefulWidget {
  const StockScreen({super.key});

  @override
  ConsumerState<StockScreen> createState() => _StockScreenState();
}

class _StockScreenState extends ConsumerState<StockScreen> {
  final _barcodeController = TextEditingController();
  final _quantityController = TextEditingController();

  MovementDirection _direction = MovementDirection.IN;
  MovementReason _reason = MovementReason.PURCHASE;
  String? _selectedVariantId;
  String? _variantDisplay;

  Future<void> _scanBarcode() async {
    final scannedCode = await Navigator.push<String>(
      context,
      MaterialPageRoute(builder: (context) => const BarcodeScannerView()),
    );

    if (scannedCode != null) {
      _barcodeController.text = scannedCode;
      _searchByBarcode();
    }
  }

  Future<void> _openVariantPicker() async {
    final variant = await showDialog<ProductVariant>(
      context: context,
      builder: (context) => const VariantSelectionDialog(),
    );

    if (variant != null) {
      _selectVariant(variant);
    }
  }

  void _selectVariant(ProductVariant variant) {
    setState(() {
      _selectedVariantId = variant.id;
      _variantDisplay =
          '${variant.productName} (${variant.size}, ${variant.color}) - Stock: ${variant.currentStock}';
      if (variant.barcode != null) {
        _barcodeController.text = variant.barcode!;
      }
    });
  }

  Future<void> _searchByBarcode() async {
    final barcode = _barcodeController.text.trim();
    if (barcode.isEmpty) return;

    try {
      final variant = await ref
          .read(variantRepositoryProvider)
          .getVariantByBarcode(barcode);

      if (variant != null) {
        _selectVariant(variant);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Variant not found')));
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  Future<void> _submitMovement() async {
    if (_selectedVariantId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please select a variant')));
      return;
    }

    final quantity = int.tryParse(_quantityController.text);
    if (quantity == null || quantity <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid quantity')),
      );
      return;
    }

    try {
      final currentUser = await ref.read(currentUserProvider.future);
      if (currentUser == null) {
        throw Exception('User not found');
      }

      final movement = StockMovement(
        id: '',
        variantId: _selectedVariantId!,
        productId: 'product', // Ideally fetch this from variant
        quantity: quantity,
        direction: _direction,
        reason: _reason,
        userId: currentUser.id,
        createdAt: DateTime.now(),
      );

      await ref.read(stockRepositoryProvider).createMovement(movement);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Stock updated successfully')),
        );
        _clearForm();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  void _clearForm() {
    _barcodeController.clear();
    _quantityController.clear();
    setState(() {
      _selectedVariantId = null;
      _variantDisplay = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Stock Management')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Search Product',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _barcodeController,
                            decoration: const InputDecoration(
                              labelText: 'Barcode',
                              prefixIcon: Icon(Icons.qr_code),
                              border: OutlineInputBorder(),
                            ),
                            onSubmitted: (_) => _searchByBarcode(),
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton.filled(
                          onPressed: _scanBarcode,
                          icon: const Icon(Icons.camera_alt),
                          tooltip: 'Scan Barcode',
                        ),
                        const SizedBox(width: 8),
                        IconButton.filledTonal(
                          onPressed: _openVariantPicker,
                          icon: const Icon(Icons.list),
                          tooltip: 'Select from List',
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: _searchByBarcode,
                      child: const Text('Search by Barcode'),
                    ),
                    if (_variantDisplay != null) ...[
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.green.shade50,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          _variantDisplay!,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Stock Movement',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<MovementDirection>(
                      value: _direction,
                      decoration: const InputDecoration(labelText: 'Direction'),
                      items: MovementDirection.values
                          .map(
                            (dir) => DropdownMenuItem(
                              value: dir,
                              child: Text(dir.toString().split('.').last),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        setState(() => _direction = value!);
                      },
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<MovementReason>(
                      value: _reason,
                      decoration: const InputDecoration(labelText: 'Reason'),
                      items: MovementReason.values
                          .map(
                            (reason) => DropdownMenuItem(
                              value: reason,
                              child: Text(reason.toString().split('.').last),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        setState(() => _reason = value!);
                      },
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _quantityController,
                      decoration: const InputDecoration(labelText: 'Quantity'),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _submitMovement,
                      child: const Text('Submit Movement'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _barcodeController.dispose();
    _quantityController.dispose();
    super.dispose();
  }
}
