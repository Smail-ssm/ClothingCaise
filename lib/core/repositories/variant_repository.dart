import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product_variant.dart';

class VariantRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'productVariants';

  // Get all variants
  Stream<List<ProductVariant>> getVariants() {
    return _firestore
        .collection(_collection)
        .where('isActive', isEqualTo: true)
        .orderBy('productName')
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => ProductVariant.fromJson(doc.data(), doc.id))
              .toList();
        });
  }

  // Get variants by product ID
  Stream<List<ProductVariant>> getVariantsByProduct(String productId) {
    return _firestore
        .collection(_collection)
        .where('productId', isEqualTo: productId)
        .where('isActive', isEqualTo: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => ProductVariant.fromJson(doc.data(), doc.id))
              .toList();
        });
  }

  // Get variant by barcode
  Future<ProductVariant?> getVariantByBarcode(String barcode) async {
    final snapshot = await _firestore
        .collection(_collection)
        .where('barcode', isEqualTo: barcode)
        .where('isActive', isEqualTo: true)
        .limit(1)
        .get();

    if (snapshot.docs.isEmpty) return null;
    return ProductVariant.fromJson(
      snapshot.docs.first.data(),
      snapshot.docs.first.id,
    );
  }

  // Get variant by ID
  Future<ProductVariant?> getVariant(String id) async {
    final doc = await _firestore.collection(_collection).doc(id).get();
    if (!doc.exists) return null;
    return ProductVariant.fromJson(doc.data()!, doc.id);
  }

  // Create variant
  Future<String> createVariant(ProductVariant variant) async {
    final docRef = await _firestore
        .collection(_collection)
        .add(variant.toJson());
    return docRef.id;
  }

  // Update variant
  Future<void> updateVariant(String id, ProductVariant variant) async {
    await _firestore.collection(_collection).doc(id).update(variant.toJson());
  }

  // Update stock
  Future<void> updateStock(String id, int newStock) async {
    await _firestore.collection(_collection).doc(id).update({
      'currentStock': newStock,
      'updatedAt': Timestamp.now(),
    });
  }

  // Deactivate variant
  Future<void> deactivateVariant(String id) async {
    await _firestore.collection(_collection).doc(id).update({
      'isActive': false,
      'updatedAt': Timestamp.now(),
    });
  }

  // Get low stock variants count
  Future<int> getLowStockCount() async {
    final snapshot = await _firestore
        .collection(_collection)
        .where('isActive', isEqualTo: true)
        .get();

    return snapshot.docs.where((doc) {
      final variant = ProductVariant.fromJson(doc.data(), doc.id);
      return variant.isLowStock;
    }).length;
  }

  // Get low stock variants
  Stream<List<ProductVariant>> getLowStockVariants() {
    return _firestore
        .collection(_collection)
        .where('isActive', isEqualTo: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => ProductVariant.fromJson(doc.data(), doc.id))
              .where((variant) => variant.isLowStock)
              .toList();
        });
  }
}
