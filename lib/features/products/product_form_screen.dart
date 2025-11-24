import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/models/product.dart';
import '../../core/providers.dart';
import '../../core/utils/validators.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProductFormScreen extends ConsumerStatefulWidget {
  final String? productId;

  const ProductFormScreen({super.key, this.productId});

  @override
  ConsumerState<ProductFormScreen> createState() => _ProductFormScreenState();
}

class _ProductFormScreenState extends ConsumerState<ProductFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _categoryController = TextEditingController();
  final _brandController = TextEditingController();
  final _genderController = TextEditingController();
  final _seasonController = TextEditingController();
  final _buyingPriceController = TextEditingController();
  final _sellingPriceController = TextEditingController();

  bool _isLoading = false;
  Product? _existingProduct;

  @override
  void initState() {
    super.initState();
    if (widget.productId != null) {
      _loadProduct();
    }
  }

  Future<void> _loadProduct() async {
    setState(() => _isLoading = true);
    try {
      final product = await ref
          .read(productRepositoryProvider)
          .getProduct(widget.productId!);
      if (product != null) {
        _existingProduct = product;
        _nameController.text = product.name;
        _categoryController.text = product.category;
        _brandController.text = product.brand;
        _genderController.text = product.gender;
        _seasonController.text = product.season;
        _buyingPriceController.text = product.baseBuyingPrice.toString();
        _sellingPriceController.text = product.baseSellingPrice.toString();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error loading product: $e')));
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _saveProduct() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final now = DateTime.now();
      final product = Product(
        id: widget.productId ?? '',
        name: _nameController.text.trim(),
        category: _categoryController.text.trim(),
        brand: _brandController.text.trim(),
        gender: _genderController.text.trim(),
        season: _seasonController.text.trim(),
        baseBuyingPrice: double.parse(_buyingPriceController.text),
        baseSellingPrice: double.parse(_sellingPriceController.text),
        isActive: true,
        createdAt: _existingProduct?.createdAt ?? now,
        updatedAt: now,
      );

      if (widget.productId != null) {
        await ref
            .read(productRepositoryProvider)
            .updateProduct(widget.productId!, product);
      } else {
        await ref.read(productRepositoryProvider).createProduct(product);
      }

      if (mounted) {
        context.pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.productId != null ? 'Product updated' : 'Product created',
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
        title: Text(widget.productId != null ? 'Edit Product' : 'Add Product'),
      ),
      body: _isLoading && _existingProduct == null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(labelText: 'Name'),
                      validator: (v) => Validators.validateRequired(v, 'Name'),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _categoryController,
                      decoration: const InputDecoration(labelText: 'Category'),
                      validator: (v) =>
                          Validators.validateRequired(v, 'Category'),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _brandController,
                      decoration: const InputDecoration(labelText: 'Brand'),
                      validator: (v) => Validators.validateRequired(v, 'Brand'),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _genderController,
                      decoration: const InputDecoration(labelText: 'Gender'),
                      validator: (v) =>
                          Validators.validateRequired(v, 'Gender'),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _seasonController,
                      decoration: const InputDecoration(labelText: 'Season'),
                      validator: (v) =>
                          Validators.validateRequired(v, 'Season'),
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
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _saveProduct,
                        child: _isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(
                                widget.productId != null
                                    ? 'Update Product'
                                    : 'Create Product',
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
    _nameController.dispose();
    _categoryController.dispose();
    _brandController.dispose();
    _genderController.dispose();
    _seasonController.dispose();
    _buyingPriceController.dispose();
    _sellingPriceController.dispose();
    super.dispose();
  }
}
