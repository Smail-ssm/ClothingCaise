import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/models/product_variant.dart';
import '../../core/providers.dart';
import '../../core/utils/validators.dart';

class VariantFormScreen extends ConsumerStatefulWidget {
  final String? variantId;

  const VariantFormScreen({super.key, this.variantId});

  @override
  ConsumerState<VariantFormScreen> createState() => _VariantFormScreenState();
}

class _VariantFormScreenState extends ConsumerState<VariantFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _productNameController = TextEditingController();
  final _sizeController = TextEditingController();
  final _colorController = TextEditingController();
  final _barcodeController = TextEditingController();
  final _buyingPriceController = TextEditingController();
  final _sellingPriceController = TextEditingController();
  final _stockController = TextEditingController();
  final _minStockController = TextEditingController();

  bool _isLoading = false;
  String? _selectedProductId;
  ProductVariant? _existingVariant;

  @override
  void initState() {
    super.initState();
    if (widget.variantId != null) {
      _loadVariant();
    }
  }

  Future<void> _loadVariant() async {
    setState(() => _isLoading = true);
    try {
      final variant = await ref
          .read(variantRepositoryProvider)
          .getVariant(widget.variantId!);
      if (variant != null) {
        _existingVariant = variant;
        _selectedProductId = variant.productId;
        _productNameController.text = variant.productName;
        _sizeController.text = variant.size;
        _colorController.text = variant.color;
        _barcodeController.text = variant.barcode ?? '';
        _buyingPriceController.text = variant.buyingPrice.toString();
        _sellingPriceController.text = variant.sellingPrice.toString();
        _stockController.text = variant.currentStock.toString();
        _minStockController.text = variant.minStock.toString();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error loading variant: $e')));
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _saveVariant() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedProductId == null && _productNameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter product name')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final now = DateTime.now();
      final variant = ProductVariant(
        id: widget.variantId ?? '',
        productId: _selectedProductId ?? 'manual',
        productName: _productNameController.text.trim(),
        size: _sizeController.text.trim(),
        color: _colorController.text.trim(),
        barcode: _barcodeController.text.trim().isEmpty
            ? null
            : _barcodeController.text.trim(),
        buyingPrice: double.parse(_buyingPriceController.text),
        sellingPrice: double.parse(_sellingPriceController.text),
        currentStock: int.parse(_stockController.text),
        minStock: int.parse(_minStockController.text),
        isActive: true,
        createdAt: _existingVariant?.createdAt ?? now,
        updatedAt: now,
      );

      if (widget.variantId != null) {
        await ref
            .read(variantRepositoryProvider)
            .updateVariant(widget.variantId!, variant);
      } else {
        await ref.read(variantRepositoryProvider).createVariant(variant);
      }

      if (mounted) {
        context.pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.variantId != null ? 'Variant updated' : 'Variant created',
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.variantId != null ? 'Edit Variant' : 'Add Variant'),
      ),
      body: _isLoading && _existingVariant == null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _productNameController,
                      decoration: const InputDecoration(
                        labelText: 'Product Name',
                      ),
                      validator: (v) =>
                          Validators.validateRequired(v, 'Product Name'),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _sizeController,
                      decoration: const InputDecoration(labelText: 'Size'),
                      validator: (v) => Validators.validateRequired(v, 'Size'),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _colorController,
                      decoration: const InputDecoration(labelText: 'Color'),
                      validator: (v) => Validators.validateRequired(v, 'Color'),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _barcodeController,
                      decoration: const InputDecoration(
                        labelText: 'Barcode (Optional)',
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _buyingPriceController,
                      decoration: const InputDecoration(
                        labelText: 'Buying Price',
                      ),
                      keyboardType: TextInputType.number,
                      validator: (v) =>
                          Validators.validatePositiveNumber(v, 'Buying Price'),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _sellingPriceController,
                      decoration: const InputDecoration(
                        labelText: 'Selling Price',
                      ),
                      keyboardType: TextInputType.number,
                      validator: (v) =>
                          Validators.validatePositiveNumber(v, 'Selling Price'),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _stockController,
                      decoration: const InputDecoration(
                        labelText: 'Current Stock',
                      ),
                      keyboardType: TextInputType.number,
                      validator: (v) =>
                          Validators.validateNonNegativeNumber(v, 'Stock'),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _minStockController,
                      decoration: const InputDecoration(
                        labelText: 'Minimum Stock',
                      ),
                      keyboardType: TextInputType.number,
                      validator: (v) => Validators.validateNonNegativeNumber(
                        v,
                        'Minimum Stock',
                      ),
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _saveVariant,
                        child: _isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(
                                widget.variantId != null
                                    ? 'Update Variant'
                                    : 'Create Variant',
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
    _productNameController.dispose();
    _sizeController.dispose();
    _colorController.dispose();
    _barcodeController.dispose();
    _buyingPriceController.dispose();
    _sellingPriceController.dispose();
    _stockController.dispose();
    _minStockController.dispose();
    super.dispose();
  }
}
